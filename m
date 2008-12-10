From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/9] netns: ip6mr: allocate mroute6_socket per-namespace.
Date: Wed, 10 Dec 2008 17:03:02 +0100
Message-ID: <20081210160302.115739798@theryb.frec.bull.fr>
References: <20081210160301.883947374@theryb.frec.bull.fr>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42207 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbYLJQEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:04:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast forwarding netns-aware.

Make IPv6 multicast forwarding mroute6_socket per-namespace,
moves it into struct netns_ipv6.

At the moment, mroute6_socket is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/linux/mroute6.h  |    8 ++++++--
 include/net/netns/ipv6.h |    3 +++
 net/ipv6/ip6_output.c    |    3 ++-
 net/ipv6/ip6mr.c         |   22 ++++++++++------------
 4 files changed, 21 insertions(+), 15 deletions(-)

Index: net-next-2.6/include/linux/mroute6.h
===================================================================
--- net-next-2.6.orig/include/linux/mroute6.h
+++ net-next-2.6/include/linux/mroute6.h
@@ -117,6 +117,7 @@ struct sioc_mif_req6
 
 #include <linux/pim.h>
 #include <linux/skbuff.h>	/* for struct sk_buff_head */
+#include <net/net_namespace.h>
 
 #ifdef CONFIG_IPV6_MROUTE
 static inline int ip6_mroute_opt(int opt)
@@ -232,10 +233,13 @@ struct rtmsg;
 extern int ip6mr_get_route(struct sk_buff *skb, struct rtmsg *rtm, int nowait);
 
 #ifdef CONFIG_IPV6_MROUTE
-extern struct sock *mroute6_socket;
+static inline struct sock *mroute6_socket(struct net *net)
+{
+	return net->ipv6.mroute6_sk;
+}
 extern int ip6mr_sk_done(struct sock *sk);
 #else
-#define mroute6_socket NULL
+static inline struct sock *mroute6_socket(struct net *net) { return NULL; }
 static inline int ip6mr_sk_done(struct sock *sk) { return 0; }
 #endif
 #endif
Index: net-next-2.6/include/net/netns/ipv6.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv6.h
+++ net-next-2.6/include/net/netns/ipv6.h
@@ -55,5 +55,8 @@ struct netns_ipv6 {
 	struct sock             *ndisc_sk;
 	struct sock             *tcp_sk;
 	struct sock             *igmp_sk;
+#ifdef CONFIG_IPV6_MROUTE
+	struct sock		*mroute6_sk;
+#endif
 };
 #endif
Index: net-next-2.6/net/ipv6/ip6_output.c
===================================================================
--- net-next-2.6.orig/net/ipv6/ip6_output.c
+++ net-next-2.6/net/ipv6/ip6_output.c
@@ -137,7 +137,8 @@ static int ip6_output2(struct sk_buff *s
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
 		if (!(dev->flags & IFF_LOOPBACK) && (!np || np->mc_loop) &&
-		    ((mroute6_socket && !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
+		    ((mroute6_socket(dev_net(dev)) &&
+		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
 					 &ipv6_hdr(skb)->saddr))) {
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
Index: net-next-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-next-2.6.orig/net/ipv6/ip6mr.c
+++ net-next-2.6/net/ipv6/ip6mr.c
@@ -49,9 +49,6 @@
 #include <net/addrconf.h>
 #include <linux/netfilter_ipv6.h>
 
-struct sock *mroute6_socket;
-
-
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
  */
@@ -820,7 +817,7 @@ static int ip6mr_cache_report(struct sk_
 	skb_pull(skb, sizeof(struct ipv6hdr));
 	}
 
-	if (mroute6_socket == NULL) {
+	if (init_net.ipv6.mroute6_sk == NULL) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -828,7 +825,8 @@ static int ip6mr_cache_report(struct sk_
 	/*
 	 *	Deliver to user space multicast routing algorithms
 	 */
-	if ((ret = sock_queue_rcv_skb(mroute6_socket, skb)) < 0) {
+	ret = sock_queue_rcv_skb(init_net.ipv6.mroute6_sk, skb);
+	if (ret < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute6: pending queue full, dropping entries.\n");
 		kfree_skb(skb);
@@ -1145,8 +1143,8 @@ static int ip6mr_sk_init(struct sock *sk
 
 	rtnl_lock();
 	write_lock_bh(&mrt_lock);
-	if (likely(mroute6_socket == NULL))
-		mroute6_socket = sk;
+	if (likely(init_net.ipv6.mroute6_sk == NULL))
+		init_net.ipv6.mroute6_sk = sk;
 	else
 		err = -EADDRINUSE;
 	write_unlock_bh(&mrt_lock);
@@ -1161,9 +1159,9 @@ int ip6mr_sk_done(struct sock *sk)
 	int err = 0;
 
 	rtnl_lock();
-	if (sk == mroute6_socket) {
+	if (sk == init_net.ipv6.mroute6_sk) {
 		write_lock_bh(&mrt_lock);
-		mroute6_socket = NULL;
+		init_net.ipv6.mroute6_sk = NULL;
 		write_unlock_bh(&mrt_lock);
 
 		mroute_clean_tables(sk);
@@ -1189,7 +1187,7 @@ int ip6_mroute_setsockopt(struct sock *s
 	mifi_t mifi;
 
 	if (optname != MRT6_INIT) {
-		if (sk != mroute6_socket && !capable(CAP_NET_ADMIN))
+		if (sk != init_net.ipv6.mroute6_sk && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -1214,7 +1212,7 @@ int ip6_mroute_setsockopt(struct sock *s
 		if (vif.mif6c_mifi >= MAXMIFS)
 			return -ENFILE;
 		rtnl_lock();
-		ret = mif6_add(&vif, sk == mroute6_socket);
+		ret = mif6_add(&vif, sk == init_net.ipv6.mroute6_sk);
 		rtnl_unlock();
 		return ret;
 
@@ -1242,7 +1240,7 @@ int ip6_mroute_setsockopt(struct sock *s
 		if (optname == MRT6_DEL_MFC)
 			ret = ip6mr_mfc_delete(&mfc);
 		else
-			ret = ip6mr_mfc_add(&mfc, sk == mroute6_socket);
+			ret = ip6mr_mfc_add(&mfc, sk == init_net.ipv6.mroute6_sk);
 		rtnl_unlock();
 		return ret;
 

