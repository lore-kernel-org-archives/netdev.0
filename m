From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 14:37:01 +0100
Message-ID: <5716347D.3030808@solarflare.com>
References: <5716338E.4050003@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:19871 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbcDSNhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 09:37:13 -0400
In-Reply-To: <5716338E.4050003@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also involved adding a way to run a netfilter hook over a list of packets.
Rather than attempting to make netfilter know about lists (which would be
horrendous) we just let it call the regular okfn (in this case
ip_rcv_finish()) for any packets it steals, and have it give us back a list
of packets it's synchronously accepted (which normally NF_HOOK would
automatically call okfn() on, but we want to be able to potentially pass
the list to a listified version of okfn().)

There is potential for out-of-order receives if the netfilter hook ends up
synchronously stealing packets, as they will be processed before any accepts
earlier in the list.  However, it was already possible for an asynchronous
accept to cause out-of-order receives, so hopefully I haven't broken
anything that wasn't broken already.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 include/linux/netdevice.h |  3 ++
 include/linux/netfilter.h | 27 +++++++++++++++++
 include/net/ip.h          |  2 ++
 net/core/dev.c            | 11 +++++--
 net/ipv4/af_inet.c        |  1 +
 net/ipv4/ip_input.c       | 75 ++++++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 110 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 682d0ad..292f2d5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2143,6 +2143,9 @@ struct packet_type {
 					 struct net_device *,
 					 struct packet_type *,
 					 struct net_device *);
+	void			(*list_func) (struct sk_buff_head *,
+					      struct packet_type *,
+					      struct net_device *);
 	bool			(*id_match)(struct packet_type *ptype,
 					    struct sock *sk);
 	void			*af_packet_priv;
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 9230f9a..e18e91b 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -220,6 +220,24 @@ NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	return ret;
 }
 
+static inline void
+NF_HOOK_LIST_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
+		    struct sk_buff_head *list, struct sk_buff_head *sublist,
+		    struct net_device *in, struct net_device *out,
+		    int (*okfn)(struct net *, struct sock *, struct sk_buff *),
+		    int thresh)
+{
+	struct sk_buff *skb;
+
+	__skb_queue_head_init(sublist); /* list of synchronously ACCEPTed skbs */
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn,
+					 thresh);
+		if (ret == 1)
+			__skb_queue_tail(sublist, skb);
+	}
+}
+
 static inline int
 NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
@@ -242,6 +260,15 @@ NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk, struct
 	return NF_HOOK_THRESH(pf, hook, net, sk, skb, in, out, okfn, INT_MIN);
 }
 
+static inline void
+NF_HOOK_LIST(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
+	     struct sk_buff_head *list, struct sk_buff_head *sublist,
+	     struct net_device *in, struct net_device *out,
+	     int (*okfn)(struct net *, struct sock *, struct sk_buff *))
+{
+	NF_HOOK_LIST_THRESH(pf, hook, net, sk, list, sublist, in, out, okfn, INT_MIN);
+}
+
 /* Call setsockopt() */
 int nf_setsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
 		  unsigned int len);
diff --git a/include/net/ip.h b/include/net/ip.h
index 93725e5..c994c44 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -106,6 +106,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 			  struct ip_options_rcu *opt);
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	   struct net_device *orig_dev);
+void ip_list_rcv(struct sk_buff_head *list, struct packet_type *pt,
+		 struct net_device *orig_dev);
 int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index db1d16a..da768e2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4230,8 +4230,15 @@ static inline void __netif_receive_skb_list_ptype(struct sk_buff_head *list,
 {
 	struct sk_buff *skb;
 
-	while ((skb = __skb_dequeue(list)) != NULL)
-		pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+	if (!pt_prev)
+		return;
+	if (skb_queue_empty(list))
+		return;
+	if (pt_prev->list_func != NULL)
+		pt_prev->list_func(list, pt_prev, orig_dev);
+	else
+		while ((skb = __skb_dequeue(list)) != NULL)
+			pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
 
 static void __netif_receive_skb_list_core(struct sk_buff_head *list, bool pfmemalloc)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 2e6e65f..1424147 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1757,6 +1757,7 @@ fs_initcall(ipv4_offload_init);
 static struct packet_type ip_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
 	.func = ip_rcv,
+	.list_func = ip_list_rcv,
 };
 
 static int __init inet_init(void)
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e3d7827..e7d0d85 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -395,10 +395,9 @@ drop:
 /*
  * 	Main IP Receive routine.
  */
-int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
+static struct sk_buff *ip_rcv_core(struct sk_buff *skb, struct net *net)
 {
 	const struct iphdr *iph;
-	struct net *net;
 	u32 len;
 
 	/* When the interface is in promisc. mode, drop all the crap
@@ -408,7 +407,6 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 
 
-	net = dev_net(dev);
 	IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_IN, skb->len);
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
@@ -475,9 +473,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
-		       net, NULL, skb, dev, NULL,
-		       ip_rcv_finish);
+	return skb;
 
 csum_error:
 	IP_INC_STATS_BH(net, IPSTATS_MIB_CSUMERRORS);
@@ -486,5 +482,70 @@ inhdr_error:
 drop:
 	kfree_skb(skb);
 out:
-	return NET_RX_DROP;
+	return NULL;
+}
+
+/*
+ * IP receive entry point
+ */
+int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
+	   struct net_device *orig_dev)
+{
+	struct net *net = dev_net(dev);
+
+	skb = ip_rcv_core(skb, net);
+	if (skb == NULL)
+		return NET_RX_DROP;
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
+		       net, NULL, skb, dev, NULL,
+		       ip_rcv_finish);
+}
+
+static void ip_sublist_rcv(struct sk_buff_head *list, struct net_device *dev,
+			   struct net *net)
+{
+	struct sk_buff_head sublist;
+	struct sk_buff *skb;
+
+	NF_HOOK_LIST(NFPROTO_IPV4, NF_INET_PRE_ROUTING, net, NULL,
+		     list, &sublist, dev, NULL, ip_rcv_finish);
+	while ((skb = __skb_dequeue(&sublist)) != NULL)
+		ip_rcv_finish(net, NULL, skb);
+}
+
+/* Receive a list of IP packets */
+void ip_list_rcv(struct sk_buff_head *list, struct packet_type *pt,
+		 struct net_device *orig_dev)
+{
+	struct net_device *curr_dev = NULL;
+	struct net *curr_net = NULL;
+	struct sk_buff_head sublist;
+	struct sk_buff *skb;
+
+	__skb_queue_head_init(&sublist);
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		struct net_device *dev = skb->dev;
+		struct net *net = dev_net(dev);
+
+		skb = ip_rcv_core(skb, net);
+		if (skb == NULL)
+			continue;
+
+		if (skb_queue_empty(&sublist)) {
+			curr_dev = dev;
+			curr_net = net;
+		} else if (curr_dev != dev || curr_net != net) {
+			/* dispatch old sublist */
+			ip_sublist_rcv(&sublist, dev, net);
+			/* start new sublist */
+			__skb_queue_head_init(&sublist);
+			curr_dev = dev;
+			curr_net = net;
+		}
+		/* add to current sublist */
+		__skb_queue_tail(&sublist, skb);
+	}
+	/* dispatch final sublist */
+	ip_sublist_rcv(&sublist, curr_dev, curr_net);
 }
