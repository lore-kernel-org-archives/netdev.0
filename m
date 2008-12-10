From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 7/9] netns: ip6mr: declare reg_vif_num per-namespace
Date: Wed, 10 Dec 2008 17:03:08 +0100
Message-ID: <20081210160303.678373828@theryb.frec.bull.fr>
References: <20081210160301.883947374@theryb.frec.bull.fr>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42640 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278AbYLJQFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:05:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast forwarding netns-aware.

Declare variable 'reg_vif_num' per-namespace, moves into struct netns_ipv6.

At the moment, this variable is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    3 +++
 net/ipv6/ip6mr.c         |   19 +++++++++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)

Index: net-next-2.6/include/net/netns/ipv6.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv6.h
+++ net-next-2.6/include/net/netns/ipv6.h
@@ -63,6 +63,9 @@ struct netns_ipv6 {
 	atomic_t		cache_resolve_queue_len;
 	int			mroute_do_assert;
 	int			mroute_do_pim;
+#ifdef CONFIG_IPV6_PIMSM_V2
+	int			mroute_reg_vif_num;
+#endif
 #endif
 };
 #endif
Index: net-next-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-next-2.6.orig/net/ipv6/ip6mr.c
+++ net-next-2.6/net/ipv6/ip6mr.c
@@ -333,13 +333,13 @@ static struct file_operations ip6mr_mfc_
 #endif
 
 #ifdef CONFIG_IPV6_PIMSM_V2
-static int reg_vif_num = -1;
 
 static int pim6_rcv(struct sk_buff *skb)
 {
 	struct pimreghdr *pim;
 	struct ipv6hdr   *encap;
 	struct net_device  *reg_dev = NULL;
+	int reg_vif_num = init_net.ipv6.mroute_reg_vif_num;
 
 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
 		goto drop;
@@ -401,7 +401,7 @@ static int reg_vif_xmit(struct sk_buff *
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ip6mr_cache_report(skb, reg_vif_num, MRT6MSG_WHOLEPKT);
+	ip6mr_cache_report(skb, init_net.ipv6.mroute_reg_vif_num, MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
@@ -473,8 +473,8 @@ static int mif6_delete(int vifi)
 	}
 
 #ifdef CONFIG_IPV6_PIMSM_V2
-	if (vifi == reg_vif_num)
-		reg_vif_num = -1;
+	if (vifi == init_net.ipv6.mroute_reg_vif_num)
+		init_net.ipv6.mroute_reg_vif_num = -1;
 #endif
 
 	if (vifi + 1 == init_net.ipv6.maxvif) {
@@ -610,7 +610,7 @@ static int mif6_add(struct mif6ctl *vifc
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (reg_vif_num >= 0)
+		if (init_net.ipv6.mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
 		dev = ip6mr_reg_vif();
 		if (!dev)
@@ -658,7 +658,7 @@ static int mif6_add(struct mif6ctl *vifc
 	v->dev = dev;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	if (v->flags & MIFF_REGISTER)
-		reg_vif_num = vifi;
+		init_net.ipv6.mroute_reg_vif_num = vifi;
 #endif
 	if (vifi + 1 > init_net.ipv6.maxvif)
 		init_net.ipv6.maxvif = vifi + 1;
@@ -777,7 +777,7 @@ static int ip6mr_cache_report(struct sk_
 		msg = (struct mrt6msg *)skb_transport_header(skb);
 		msg->im6_mbz = 0;
 		msg->im6_msgtype = MRT6MSG_WHOLEPKT;
-		msg->im6_mif = reg_vif_num;
+		msg->im6_mif = init_net.ipv6.mroute_reg_vif_num;
 		msg->im6_pad = 0;
 		ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
 		ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
@@ -964,7 +964,6 @@ static struct notifier_block ip6_mr_noti
 static int __net_init ip6mr_net_init(struct net *net)
 {
 	int err = 0;
-
 	net->ipv6.vif6_table = kcalloc(MAXMIFS, sizeof(struct mif_device),
 				       GFP_KERNEL);
 	if (!net->ipv6.vif6_table) {
@@ -980,6 +979,10 @@ static int __net_init ip6mr_net_init(str
 		err = -ENOMEM;
 		goto fail_mfc6_cache;
 	}
+
+#ifdef CONFIG_IPV6_PIMSM_V2
+	net->ipv6.mroute_reg_vif_num = -1;
+#endif
 	return 0;
 
 fail_mfc6_cache:

