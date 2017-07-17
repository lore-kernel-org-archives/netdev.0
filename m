From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 09/12] bpf: add bpf_redirect_map helper routine
Date: Mon, 17 Jul 2017 09:29:18 -0700
Message-ID: <20170717162918.24315.8414.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34823 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQQ3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:29:34 -0400
Received: by mail-pg0-f66.google.com with SMTP id d193so20003590pgc.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:29:34 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF programs can use the devmap with a bpf_redirect_map() helper
routine to forward packets to netdevice in map.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |    3 +++
 include/uapi/linux/bpf.h |    8 ++++++-
 kernel/bpf/devmap.c      |   12 +++++++++++
 kernel/bpf/verifier.c    |    4 ++++
 net/core/filter.c        |   52 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 78 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b69e7a5..d0d3281 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -379,4 +379,7 @@ static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
 void bpf_user_rnd_init_once(void);
 u64 bpf_user_rnd_u32(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
+/* Map specifics */
+struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ecbb0e7..1106a8c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -348,6 +348,11 @@ enum bpf_attach_type {
  *     @flags: bit 0 - if set, redirect to ingress instead of egress
  *             other bits - reserved
  *     Return: TC_ACT_REDIRECT
+ * int bpf_redirect_map(key, map, flags)
+ *     redirect to endpoint in map
+ *     @key: index in map to lookup
+ *     @map: fd of map to do lookup in
+ *     @flags: --
  *
  * u32 bpf_get_route_realm(skb)
  *     retrieve a dst's tclassid
@@ -592,7 +597,8 @@ enum bpf_attach_type {
 	FN(get_socket_uid),		\
 	FN(set_hash),			\
 	FN(setsockopt),			\
-	FN(skb_adjust_room),
+	FN(skb_adjust_room),		\
+	FN(redirect_map),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 1a87835..36dc13de 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -159,6 +159,18 @@ static int dev_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	return 0;
 }
 
+struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key)
+{
+	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
+	struct bpf_dtab_netdev *dev;
+
+	if (key >= map->max_entries)
+		return NULL;
+
+	dev = READ_ONCE(dtab->netdev_map[key]);
+	return dev ? dev->dev : NULL;
+}
+
 /* rcu_read_lock (from syscall and BPF contexts) ensures that if a delete and/or
  * update happens in parallel here a dev_put wont happen until after reading the
  * ifindex.
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4016774..df05d65 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1312,6 +1312,10 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 		if (map->map_type != BPF_MAP_TYPE_CGROUP_ARRAY)
 			goto error;
 		break;
+	case BPF_FUNC_redirect_map:
+		if (map->map_type != BPF_MAP_TYPE_DEVMAP)
+			goto error;
+		break;
 	default:
 		break;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index e30d38b..e93a558 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1779,6 +1779,7 @@ static int __bpf_redirect(struct sk_buff *skb, struct net_device *dev,
 struct redirect_info {
 	u32 ifindex;
 	u32 flags;
+	struct bpf_map *map;
 };
 
 static DEFINE_PER_CPU(struct redirect_info, redirect_info);
@@ -1792,6 +1793,7 @@ struct redirect_info {
 
 	ri->ifindex = ifindex;
 	ri->flags = flags;
+	ri->map = NULL;
 
 	return TC_ACT_REDIRECT;
 }
@@ -1819,6 +1821,29 @@ int skb_do_redirect(struct sk_buff *skb)
 	.arg2_type      = ARG_ANYTHING,
 };
 
+BPF_CALL_3(bpf_redirect_map, struct bpf_map *, map, u32, ifindex, u64, flags)
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
+static const struct bpf_func_proto bpf_redirect_map_proto = {
+	.func           = bpf_redirect_map,
+	.gpl_only       = false,
+	.ret_type       = RET_INTEGER,
+	.arg1_type      = ARG_CONST_MAP_PTR,
+	.arg2_type      = ARG_ANYTHING,
+	.arg3_type      = ARG_ANYTHING,
+};
+
 BPF_CALL_1(bpf_get_cgroup_classid, const struct sk_buff *, skb)
 {
 	return task_get_classid(skb);
@@ -2423,14 +2448,39 @@ static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
 	return -EOPNOTSUPP;
 }
 
+int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
+			struct bpf_prog *xdp_prog)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct bpf_map *map = ri->map;
+	struct net_device *fwd;
+	int err = -EINVAL;
+
+	ri->ifindex = 0;
+	ri->map = NULL;
+
+	fwd = __dev_map_lookup_elem(map, ri->ifindex);
+	if (!fwd)
+		goto out;
+
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
+	err = __bpf_tx_xdp(fwd, xdp);
+out:
+	return err;
+}
+
 int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 		    struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct net_device *fwd;
 
+	if (ri->map)
+		return xdp_do_redirect_map(dev, xdp, xdp_prog);
+
 	fwd = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
 	ri->ifindex = 0;
+	ri->map = NULL;
 	if (unlikely(!fwd)) {
 		bpf_warn_invalid_xdp_redirect(ri->ifindex);
 		return -EINVAL;
@@ -3089,6 +3139,8 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 		return &bpf_xdp_adjust_head_proto;
 	case BPF_FUNC_redirect:
 		return &bpf_xdp_redirect_proto;
+	case BPF_FUNC_redirect_map:
+		return &bpf_redirect_map_proto;
 	default:
 		return bpf_base_func_proto(func_id);
 	}
