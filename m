From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 05/12] net: implement XDP_REDIRECT for xdp generic
Date: Mon, 17 Jul 2017 09:27:50 -0700
Message-ID: <20170717162750.24315.13181.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34542 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751361AbdGQQ2G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:28:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id v190so6248906pgv.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:28:06 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for redirect to xdp generic creating a fall back for
devices that do not yet have support and allowing test infrastructure
using veth pairs to be built.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Tested-by: Andy Gospodarek <andy@greyhouse.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/filter.h |    1 +
 net/core/dev.c         |   22 ++++++++++++++++++++--
 net/core/filter.c      |   26 ++++++++++++++++++++++++++
 3 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 64cae7a..10df7da 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -712,6 +712,7 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 
+int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb);
 int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp);
 
 void bpf_warn_invalid_xdp_action(u32 act);
diff --git a/net/core/dev.c b/net/core/dev.c
index a1ed7b4..9f3f408 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3902,6 +3902,7 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 		__skb_push(skb, -off);
 
 	switch (act) {
+	case XDP_REDIRECT:
 	case XDP_TX:
 		__skb_push(skb, mac_len);
 		/* fall through */
@@ -3956,14 +3957,27 @@ static int do_xdp_generic(struct sk_buff *skb)
 
 	if (xdp_prog) {
 		u32 act = netif_receive_generic_xdp(skb, xdp_prog);
+		int err;
 
 		if (act != XDP_PASS) {
-			if (act == XDP_TX)
+			switch (act) {
+			case XDP_REDIRECT:
+				err = xdp_do_generic_redirect(skb->dev, skb);
+				if (err)
+					goto out_redir;
+			/* fallthru to submit skb */
+			case XDP_TX:
 				generic_xdp_tx(skb, xdp_prog);
+				break;
+			}
 			return XDP_DROP;
 		}
 	}
 	return XDP_PASS;
+out_redir:
+	trace_xdp_exception(skb->dev, xdp_prog, XDP_REDIRECT);
+	kfree_skb(skb);
+	return XDP_DROP;
 }
 
 static int netif_rx_internal(struct sk_buff *skb)
@@ -3977,8 +3991,12 @@ static int netif_rx_internal(struct sk_buff *skb)
 	if (static_key_false(&generic_xdp_needed)) {
 		int ret = do_xdp_generic(skb);
 
+		/* Consider XDP consuming the packet a success from
+		 * the netdev point of view we do not want to count
+		 * this as an error.
+		 */
 		if (ret != XDP_PASS)
-			return NET_RX_DROP;
+			return NET_RX_SUCCESS;
 	}
 
 #ifdef CONFIG_RPS
diff --git a/net/core/filter.c b/net/core/filter.c
index d606a66..eeb7134 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2437,6 +2437,32 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp)
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
+int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	unsigned int len;
+
+	dev = dev_get_by_index_rcu(dev_net(dev), ri->ifindex);
+	ri->ifindex = 0;
+	if (unlikely(!dev)) {
+		bpf_warn_invalid_xdp_redirect(ri->ifindex);
+		goto err;
+	}
+
+	if (unlikely(!(dev->flags & IFF_UP)))
+		goto err;
+
+	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
+	if (skb->len > len)
+		goto err;
+
+	skb->dev = dev;
+	return 0;
+err:
+	return -EINVAL;
+}
+EXPORT_SYMBOL_GPL(xdp_do_generic_redirect);
+
 BPF_CALL_2(bpf_xdp_redirect, u32, ifindex, u64, flags)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
