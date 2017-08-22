From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: misc xdp redirect cleanups
Date: Wed, 23 Aug 2017 01:47:53 +0200
Message-ID: <fc4275ee676032382d6c7101b75cd3b071e35fe4.1503445395.git.daniel@iogearbox.net>
References: <cover.1503445395.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52256 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752619AbdHVXsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 19:48:06 -0400
In-Reply-To: <cover.1503445395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1503445395.git.daniel@iogearbox.net>
References: <cover.1503445395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few cleanups including: bpf_redirect_map() is really XDP only due to
the return code. Move it to a more appropriate location where we do
the XDP redirect handling and change it's name into bpf_xdp_redirect_map()
to make it consistent to the bpf_xdp_redirect() helper.

xdp_do_redirect_map() helper can be static since only used out of filter.c
file. Drop the goto in xdp_do_generic_redirect() and only return errors
directly. In xdp_do_flush_map() only clear ri->map_to_flush which is the
arg we're using in that function, ri->map is cleared earlier along with
ri->ifindex.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 72 +++++++++++++++++++++++++------------------------------
 1 file changed, 32 insertions(+), 40 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index fa21156..2a0d762 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1835,29 +1835,6 @@ int skb_do_redirect(struct sk_buff *skb)
 	.arg2_type      = ARG_ANYTHING,
 };
 
-BPF_CALL_3(bpf_redirect_map, struct bpf_map *, map, u32, ifindex, u64, flags)
-{
-	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
-
-	if (unlikely(flags))
-		return XDP_ABORTED;
-
-	ri->ifindex = ifindex;
-	ri->flags = flags;
-	ri->map = map;
-
-	return XDP_REDIRECT;
-}
-
-static const struct bpf_func_proto bpf_redirect_map_proto = {
-	.func           = bpf_redirect_map,
-	.gpl_only       = false,
-	.ret_type       = RET_INTEGER,
-	.arg1_type      = ARG_CONST_MAP_PTR,
-	.arg2_type      = ARG_ANYTHING,
-	.arg3_type      = ARG_ANYTHING,
-};
-
 BPF_CALL_3(bpf_sk_redirect_map, struct bpf_map *, map, u32, key, u64, flags)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
@@ -2506,13 +2483,11 @@ static int __bpf_tx_xdp(struct net_device *dev,
 	err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
 	if (err)
 		return err;
-
 	if (map)
 		__dev_map_insert_ctx(map, index);
 	else
 		dev->netdev_ops->ndo_xdp_flush(dev);
-
-	return err;
+	return 0;
 }
 
 void xdp_do_flush_map(void)
@@ -2520,16 +2495,14 @@ void xdp_do_flush_map(void)
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct bpf_map *map = ri->map_to_flush;
 
-	ri->map = NULL;
 	ri->map_to_flush = NULL;
-
 	if (map)
 		__dev_map_flush(map);
 }
 EXPORT_SYMBOL_GPL(xdp_do_flush_map);
 
-int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
-			struct bpf_prog *xdp_prog)
+static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
+			       struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct bpf_map *map = ri->map;
@@ -2545,14 +2518,12 @@ int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 		err = -EINVAL;
 		goto out;
 	}
-
-	if (ri->map_to_flush && (ri->map_to_flush != map))
+	if (ri->map_to_flush && ri->map_to_flush != map)
 		xdp_do_flush_map();
 
 	err = __bpf_tx_xdp(fwd, map, xdp, index);
 	if (likely(!err))
 		ri->map_to_flush = map;
-
 out:
 	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT, err);
 	return err;
@@ -2594,20 +2565,17 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 	ri->ifindex = 0;
 	if (unlikely(!dev)) {
 		bpf_warn_invalid_xdp_redirect(index);
-		goto err;
+		return -EINVAL;
 	}
 
 	if (unlikely(!(dev->flags & IFF_UP)))
-		goto err;
-
+		return -ENETDOWN;
 	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
 	if (skb->len > len)
-		goto err;
+		return -E2BIG;
 
 	skb->dev = dev;
 	return 0;
-err:
-	return -EINVAL;
 }
 EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
 
@@ -2620,6 +2588,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 
 	ri->ifindex = ifindex;
 	ri->flags = flags;
+
 	return XDP_REDIRECT;
 }
 
@@ -2631,6 +2600,29 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
 	.arg2_type      = ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_xdp_redirect_map, struct bpf_map *, map, u32, ifindex, u64, flags)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+
+	if (unlikely(flags))
+		return XDP_ABORTED;
+
+	ri->ifindex = ifindex;
+	ri->flags = flags;
+	ri->map = map;
+
+	return XDP_REDIRECT;
+}
+
+static const struct bpf_func_proto bpf_xdp_redirect_map_proto = {
+	.func           = bpf_xdp_redirect_map,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_CONST_MAP_PTR,
+	.arg2_type      = ARG_ANYTHING,
+	.arg3_type      = ARG_ANYTHING,
+};
+
 bool bpf_helper_changes_pkt_data(void *func)
 {
 	if (func == bpf_skb_vlan_push ||
@@ -3233,7 +3225,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	case BPF_FUNC_redirect:
 		return &bpf_xdp_redirect_proto;
 	case BPF_FUNC_redirect_map:
-		return &bpf_redirect_map_proto;
+		return &bpf_xdp_redirect_map_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
-- 
1.9.3
