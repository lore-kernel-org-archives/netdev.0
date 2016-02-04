From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 11/13] net: Enable IPsec software GSO.
Date: Thu, 4 Feb 2016 07:37:04 +0100
Message-ID: <1454567826-13018-12-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36682 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751703AbcBDHFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:50 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch hooks the IPsec GSO code into the generic
network stack.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h |  2 +-
 include/net/xfrm.h        |  1 +
 net/core/dev.c            | 40 +++++++++++++++++++++++++++++++++++-----
 net/ipv4/ip_output.c      |  8 +++++---
 net/ipv4/xfrm4_output.c   |  2 +-
 net/sched/sch_generic.c   |  2 +-
 net/xfrm/xfrm_output.c    | 14 +++++++++++++-
 7 files changed, 57 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d049c02..659eeec 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3192,7 +3192,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
-struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
+struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev, int *ret);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
 int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb);
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 7939c39..3a69883 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1505,6 +1505,7 @@ struct xfrmk_spdinfo {
 	u32 spdhmcnt;
 };
 
+void xfrm_dev_backlog(struct sk_buff_head *xfrm_backlog);
 struct xfrm_state *xfrm_find_acq_byseq(struct net *net, u32 mark, u32 seq);
 int xfrm_state_delete(struct xfrm_state *x);
 int xfrm_state_flush(struct net *net, u8 proto, bool task_valid);
diff --git a/net/core/dev.c b/net/core/dev.c
index f083cbb..611e93c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2911,9 +2911,10 @@ static struct sk_buff *validate_xmit_vlan(struct sk_buff *skb,
 	return skb;
 }
 
-static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
+static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev, int *ret)
 {
 	netdev_features_t features;
+	int err = 0;
 
 	if (skb->next)
 		return skb;
@@ -2925,6 +2926,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 
 	if (netif_needs_gso(skb, features)) {
 		struct sk_buff *segs;
+		struct sk_buff *skb2;
 
 		segs = skb_gso_segment(skb, features);
 		if (IS_ERR(segs)) {
@@ -2932,7 +2934,25 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 		} else if (segs) {
 			consume_skb(skb);
 			skb = segs;
+
+			if  (skb->hw_xfrm) {
+				do {
+					skb2 = segs->next;
+					segs->next = NULL;
+
+					err = dev->xfrmdev_ops->xdo_dev_validate(segs);
+					if (!err)
+						segs->next = skb2;
+					else if (err != -EINPROGRESS)
+						kfree_skb(segs);
+					else if (skb == segs)
+						skb = skb2;
+
+					segs = skb2;
+				} while (segs);
+			}
 		}
+
 	} else {
 		if (skb_needs_linearize(skb, features) &&
 		    __skb_linearize(skb))
@@ -2955,6 +2975,9 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 		}
 	}
 
+	if ((err == -EINPROGRESS) && !skb)
+		*ret = NETDEV_TX_OK;
+
 	return skb;
 
 out_kfree_skb:
@@ -2963,7 +2986,7 @@ out_null:
 	return NULL;
 }
 
-struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
+struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev, int *ret)
 {
 	struct sk_buff *next, *head = NULL, *tail;
 
@@ -2974,7 +2997,7 @@ struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *d
 		/* in case skb wont be segmented, point to itself */
 		skb->prev = skb;
 
-		skb = validate_xmit_skb(skb, dev);
+		skb = validate_xmit_skb(skb, dev, ret);
 		if (!skb)
 			continue;
 
@@ -3347,8 +3370,10 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 			if (__this_cpu_read(xmit_recursion) > RECURSION_LIMIT)
 				goto recursion_alert;
 
-			skb = validate_xmit_skb(skb, dev);
-			if (!skb)
+			skb = validate_xmit_skb(skb, dev, &rc);
+			if (!skb && rc == NETDEV_TX_OK)
+				goto out;
+			else if (!skb)
 				goto drop;
 
 			HARD_TX_LOCK(dev, txq, cpu);
@@ -3867,6 +3892,11 @@ static void net_tx_action(struct softirq_action *h)
 			}
 		}
 	}
+
+#ifdef CONFIG_XFRM
+	if (!skb_queue_empty(&sd->xfrm_backlog))
+			xfrm_dev_backlog(&sd->xfrm_backlog);
+#endif
 }
 
 #if (defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)) && \
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 64878ef..0d75161 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -173,7 +173,7 @@ EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
 static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb_dst(skb);
+	struct dst_entry *dst = skb_dst(skb)->path;
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
@@ -269,7 +269,9 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
-	if (skb_dst(skb)->xfrm) {
+	if (skb_dst(skb)->xfrm &&
+	    !((skb_dst(skb)->dev->features & NETIF_F_ESP_OFFLOAD) ||
+	      (skb_shinfo(skb)->gso_type & SKB_GSO_ESP))) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(net, sk, skb);
 	}
@@ -348,7 +350,7 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net_device *dev = skb_dst(skb)->dev;
+	struct net_device *dev = skb_dst(skb)->path->dev;
 
 	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 7ee6518..14e42ba 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -29,7 +29,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 		goto out;
 
 	mtu = dst_mtu(skb_dst(skb));
-	if (skb->len > mtu) {
+	if ((!skb_is_gso(skb) && skb->len > mtu) || (skb_is_gso(skb) && skb_gso_network_seglen(skb) > ip_skb_dst_mtu(skb))) {
 		skb->protocol = htons(ETH_P_IP);
 
 		if (skb->sk)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 16bc83b..5b11424 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -157,7 +157,7 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
 	/* Note that we validate skb (GSO, checksum, ...) outside of locks */
 	if (validate)
-		skb = validate_xmit_skb_list(skb, dev);
+		skb = validate_xmit_skb_list(skb, dev, &ret);
 
 	if (skb) {
 		HARD_TX_LOCK(dev, txq, smp_processor_id());
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index ff4a91f..ad452e0 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -196,9 +196,21 @@ static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb
 
 int xfrm_output(struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
+	struct net_device *dev = skb_dst(skb)->dev;
+	struct net *net = dev_net(dev);
 	int err;
 
+	if ((dev->features & NETIF_F_ESP_OFFLOAD) || skb_is_gso(skb)) {
+		err = skb_dst(skb)->ops->local_out(net, skb->sk, skb);
+		if (unlikely(err != 1))
+			return err;
+
+		if (skb_is_gso(skb))
+			skb_shinfo(skb)->gso_type |= SKB_GSO_ESP;
+
+		return dev->xfrmdev_ops->xdo_dev_encap(skb);
+	}
+
 	if (skb_is_gso(skb))
 		return xfrm_output_gso(net, sk, skb);
 
-- 
1.9.1
