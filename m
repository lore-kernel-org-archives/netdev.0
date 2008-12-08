From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 6/8] netns: ip6mr: declare reg_vif_num per-namespace
Date: Mon, 08 Dec 2008 17:02:02 +0100
Message-ID: <20081208160157.780663725@localhost.localdomain>
References: <20081208160156.343758157@localhost.localdomain>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:35138 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbYLHQD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:03:56 -0500
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

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index b17e522..c0e3189 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -62,6 +62,9 @@ struct netns_ipv6 {
 	int			maxvif;
 	int			mroute_do_assert;
 	int			mroute_do_pim;
+#ifdef CONFIG_IPV6_PIMSM_V2
+	int			mroute_reg_vif_num;
+#endif
 #endif
 };
 #endif
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1583202..b9f03f7 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -334,13 +334,13 @@ static struct file_operations ip6mr_mfc_fops = {
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
@@ -402,7 +402,7 @@ static int reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	read_lock(&mrt_lock);
 	dev->stats.tx_bytes += skb->len;
 	dev->stats.tx_packets++;
-	ip6mr_cache_report(skb, reg_vif_num, MRT6MSG_WHOLEPKT);
+	ip6mr_cache_report(skb, init_net.ipv6.mroute_reg_vif_num, MRT6MSG_WHOLEPKT);
 	read_unlock(&mrt_lock);
 	kfree_skb(skb);
 	return 0;
@@ -474,8 +474,8 @@ static int mif6_delete(int vifi)
 	}
 
 #ifdef CONFIG_IPV6_PIMSM_V2
-	if (vifi == reg_vif_num)
-		reg_vif_num = -1;
+	if (vifi == init_net.ipv6.mroute_reg_vif_num)
+		init_net.ipv6.mroute_reg_vif_num = -1;
 #endif
 
 	if (vifi + 1 == init_net.ipv6.maxvif) {
@@ -613,7 +613,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 		 * Special Purpose VIF in PIM
 		 * All the packets will be sent to the daemon
 		 */
-		if (reg_vif_num >= 0)
+		if (init_net.ipv6.mroute_reg_vif_num >= 0)
 			return -EADDRINUSE;
 		dev = ip6mr_reg_vif();
 		if (!dev)
@@ -661,7 +661,7 @@ static int mif6_add(struct mif6ctl *vifc, int mrtsock)
 	v->dev = dev;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	if (v->flags & MIFF_REGISTER)
-		reg_vif_num = vifi;
+		init_net.ipv6.mroute_reg_vif_num = vifi;
 #endif
 	if (vifi + 1 > init_net.ipv6.maxvif)
 		init_net.ipv6.maxvif = vifi + 1;
@@ -780,7 +780,7 @@ static int ip6mr_cache_report(struct sk_buff *pkt, mifi_t mifi, int assert)
 		msg = (struct mrt6msg *)skb_transport_header(skb);
 		msg->im6_mbz = 0;
 		msg->im6_msgtype = MRT6MSG_WHOLEPKT;
-		msg->im6_mif = reg_vif_num;
+		msg->im6_mif = init_net.ipv6.mroute_reg_vif_num;
 		msg->im6_pad = 0;
 		ipv6_addr_copy(&msg->im6_src, &ipv6_hdr(pkt)->saddr);
 		ipv6_addr_copy(&msg->im6_dst, &ipv6_hdr(pkt)->daddr);
@@ -966,7 +966,6 @@ static struct notifier_block ip6_mr_notifier = {
 static int __net_init ip6mr_net_init(struct net *net)
 {
 	int err = 0;
-
 	net->ipv6.vif6_table = kcalloc(MAXMIFS, sizeof(struct mif_device),
 				       GFP_KERNEL);
 	if (!net->ipv6.vif6_table) {
@@ -982,6 +981,10 @@ static int __net_init ip6mr_net_init(struct net *net)
 		err = -ENOMEM;
 		goto fail_mfc6_cache;
 	}
+
+#ifdef CONFIG_IPV6_PIMSM_V2
+	net->ipv6.mroute_reg_vif_num = -1;
+#endif
 	return 0;
 
 fail_mfc6_cache:

