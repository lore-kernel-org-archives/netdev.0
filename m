From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 1/9] netns: ipmr: allocate mroute_socket per-namespace.
Date: Thu, 22 Jan 2009 15:56:15 +0100
Message-ID: <20090122145615.142047032@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58505 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbZAVO5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv4 multicast routing netns-aware.

Make IPv4 multicast routing mroute_socket per-namespace,
moves it into struct netns_ipv4.

At the moment, mroute_socket is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

---
 include/net/netns/ipv4.h |    4 ++++
 net/ipv4/ipmr.c          |   28 +++++++++++++---------------
 2 files changed, 17 insertions(+), 15 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -54,5 +54,9 @@ struct netns_ipv4 {
 
 	struct timer_list rt_secret_timer;
 	atomic_t rt_genid;
+
+#ifdef CONFIG_IP_MROUTE
+	struct sock		*mroute_sk;
+#endif
 };
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -67,9 +67,6 @@
 #define CONFIG_IP_PIMSM	1
 #endif
 
-static struct sock *mroute_socket;
-
-
 /* Big lock, protecting vif table, mrt cache and mroute socket state.
    Note that the changes are semaphored via rtnl_lock.
  */
@@ -658,7 +655,7 @@ static int ipmr_cache_report(struct sk_b
 	skb->transport_header = skb->network_header;
 	}
 
-	if (mroute_socket == NULL) {
+	if (init_net.ipv4.mroute_sk == NULL) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -666,7 +663,8 @@ static int ipmr_cache_report(struct sk_b
 	/*
 	 *	Deliver to mrouted
 	 */
-	if ((ret = sock_queue_rcv_skb(mroute_socket, skb))<0) {
+	ret = sock_queue_rcv_skb(init_net.ipv4.mroute_sk, skb);
+	if (ret < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
 		kfree_skb(skb);
@@ -896,11 +894,11 @@ static void mroute_clean_tables(struct s
 static void mrtsock_destruct(struct sock *sk)
 {
 	rtnl_lock();
-	if (sk == mroute_socket) {
+	if (sk == init_net.ipv4.mroute_sk) {
 		IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)--;
 
 		write_lock_bh(&mrt_lock);
-		mroute_socket = NULL;
+		init_net.ipv4.mroute_sk = NULL;
 		write_unlock_bh(&mrt_lock);
 
 		mroute_clean_tables(sk);
@@ -922,7 +920,7 @@ int ip_mroute_setsockopt(struct sock *sk
 	struct mfcctl mfc;
 
 	if (optname != MRT_INIT) {
-		if (sk != mroute_socket && !capable(CAP_NET_ADMIN))
+		if (sk != init_net.ipv4.mroute_sk && !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -935,7 +933,7 @@ int ip_mroute_setsockopt(struct sock *sk
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
-		if (mroute_socket) {
+		if (init_net.ipv4.mroute_sk) {
 			rtnl_unlock();
 			return -EADDRINUSE;
 		}
@@ -943,7 +941,7 @@ int ip_mroute_setsockopt(struct sock *sk
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
 			write_lock_bh(&mrt_lock);
-			mroute_socket = sk;
+			init_net.ipv4.mroute_sk = sk;
 			write_unlock_bh(&mrt_lock);
 
 			IPV4_DEVCONF_ALL(sock_net(sk), MC_FORWARDING)++;
@@ -951,7 +949,7 @@ int ip_mroute_setsockopt(struct sock *sk
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk != mroute_socket)
+		if (sk != init_net.ipv4.mroute_sk)
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
@@ -964,7 +962,7 @@ int ip_mroute_setsockopt(struct sock *sk
 			return -ENFILE;
 		rtnl_lock();
 		if (optname == MRT_ADD_VIF) {
-			ret = vif_add(&vif, sk==mroute_socket);
+			ret = vif_add(&vif, sk == init_net.ipv4.mroute_sk);
 		} else {
 			ret = vif_delete(vif.vifc_vifi, 0);
 		}
@@ -985,7 +983,7 @@ int ip_mroute_setsockopt(struct sock *sk
 		if (optname == MRT_DEL_MFC)
 			ret = ipmr_mfc_delete(&mfc);
 		else
-			ret = ipmr_mfc_add(&mfc, sk==mroute_socket);
+			ret = ipmr_mfc_add(&mfc, sk == init_net.ipv4.mroute_sk);
 		rtnl_unlock();
 		return ret;
 		/*
@@ -1425,9 +1423,9 @@ int ip_mr_input(struct sk_buff *skb)
 			       that we can forward NO IGMP messages.
 			     */
 			    read_lock(&mrt_lock);
-			    if (mroute_socket) {
+			    if (init_net.ipv4.mroute_sk) {
 				    nf_reset(skb);
-				    raw_rcv(mroute_socket, skb);
+				    raw_rcv(init_net.ipv4.mroute_sk, skb);
 				    read_unlock(&mrt_lock);
 				    return 0;
 			    }

