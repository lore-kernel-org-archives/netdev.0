From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/4] ipmr: RCU conversion of mroute_sk
Date: Sat, 02 Oct 2010 04:15:01 +0200
Message-ID: <1285985701.2582.522.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:54582 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab0JBCPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 22:15:06 -0400
Received: by mail-fx0-f46.google.com with SMTP id 14so992146fxm.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 19:15:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU and RTNL to protect (struct mr_table)->mroute_sk

Readers use RCU, writers use RTNL.

ip_ra_control() already use an RCU grace period before
ip_ra_destroy_rcu(), so we dont need synchronize_rcu() in 
mrtsock_destruct()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipmr.c |   91
++++++++++++++++++++++++++++++--------------------------
 1 file changed, 49 insertions(+), 42 deletions(-)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 1a92ebd..e2db2ea 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -75,7 +75,7 @@ struct mr_table {
 	struct net		*net;
 #endif
 	u32			id;
-	struct sock		*mroute_sk;
+	struct sock __rcu	*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
 	struct list_head	mfc_unres_queue;
 	struct list_head	mfc_cache_array[MFC_LINES];
@@ -867,6 +867,7 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	const int ihl = ip_hdrlen(pkt);
 	struct igmphdr *igmp;
 	struct igmpmsg *msg;
+	struct sock *mroute_sk;
 	int ret;
 
 #ifdef CONFIG_IP_PIMSM
@@ -925,7 +926,10 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	skb->transport_header = skb->network_header;
 	}
 
-	if (mrt->mroute_sk == NULL) {
+	rcu_read_lock();
+	mroute_sk = rcu_dereference(mrt->mroute_sk);
+	if (mroute_sk == NULL) {
+		rcu_read_unlock();
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -933,7 +937,8 @@ static int ipmr_cache_report(struct mr_table *mrt,
 	/*
 	 *	Deliver to mrouted
 	 */
-	ret = sock_queue_rcv_skb(mrt->mroute_sk, skb);
+	ret = sock_queue_rcv_skb(mroute_sk, skb);
+	rcu_read_unlock();
 	if (ret < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "mroute: pending queue full, dropping entries.\n");
@@ -1164,6 +1169,9 @@ static void mroute_clean_tables(struct mr_table *mrt)
 	}
 }
 
+/* called from ip_ra_control(), before an RCU grace period,
+ * we dont need to call synchronize_rcu() here
+ */
 static void mrtsock_destruct(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
@@ -1171,13 +1179,9 @@ static void mrtsock_destruct(struct sock *sk)
 
 	rtnl_lock();
 	ipmr_for_each_table(mrt, net) {
-		if (sk == mrt->mroute_sk) {
+		if (sk == rtnl_dereference(mrt->mroute_sk)) {
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)--;
-
-			write_lock_bh(&mrt_lock);
-			mrt->mroute_sk = NULL;
-			write_unlock_bh(&mrt_lock);
-
+			rcu_assign_pointer(mrt->mroute_sk, NULL);
 			mroute_clean_tables(mrt);
 		}
 	}
@@ -1204,7 +1208,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return -ENOENT;
 
 	if (optname != MRT_INIT) {
-		if (sk != mrt->mroute_sk && !capable(CAP_NET_ADMIN))
+		if (sk != rcu_dereference_raw(mrt->mroute_sk) &&
+		    !capable(CAP_NET_ADMIN))
 			return -EACCES;
 	}
 
@@ -1217,23 +1222,20 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -ENOPROTOOPT;
 
 		rtnl_lock();
-		if (mrt->mroute_sk) {
+		if (rtnl_dereference(mrt->mroute_sk)) {
 			rtnl_unlock();
 			return -EADDRINUSE;
 		}
 
 		ret = ip_ra_control(sk, 1, mrtsock_destruct);
 		if (ret == 0) {
-			write_lock_bh(&mrt_lock);
-			mrt->mroute_sk = sk;
-			write_unlock_bh(&mrt_lock);
-
+			rcu_assign_pointer(mrt->mroute_sk, sk);
 			IPV4_DEVCONF_ALL(net, MC_FORWARDING)++;
 		}
 		rtnl_unlock();
 		return ret;
 	case MRT_DONE:
-		if (sk != mrt->mroute_sk)
+		if (sk != rcu_dereference_raw(mrt->mroute_sk))
 			return -EACCES;
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
@@ -1246,7 +1248,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -ENFILE;
 		rtnl_lock();
 		if (optname == MRT_ADD_VIF) {
-			ret = vif_add(net, mrt, &vif, sk == mrt->mroute_sk);
+			ret = vif_add(net, mrt, &vif,
+				      sk == rtnl_dereference(mrt->mroute_sk));
 		} else {
 			ret = vif_delete(mrt, vif.vifc_vifi, 0, NULL);
 		}
@@ -1267,7 +1270,8 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		if (optname == MRT_DEL_MFC)
 			ret = ipmr_mfc_delete(mrt, &mfc);
 		else
-			ret = ipmr_mfc_add(net, mrt, &mfc, sk == mrt->mroute_sk);
+			ret = ipmr_mfc_add(net, mrt, &mfc,
+					   sk == rtnl_dereference(mrt->mroute_sk));
 		rtnl_unlock();
 		return ret;
 		/*
@@ -1309,14 +1313,16 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -EINVAL;
 		if (get_user(v, (u32 __user *)optval))
 			return -EFAULT;
-		if (sk == mrt->mroute_sk)
-			return -EBUSY;
 
 		rtnl_lock();
 		ret = 0;
-		if (!ipmr_new_table(net, v))
-			ret = -ENOMEM;
-		raw_sk(sk)->ipmr_table = v;
+		if (sk == rtnl_dereference(mrt->mroute_sk)) {
+			ret = -EBUSY;
+		} else {
+			if (!ipmr_new_table(net, v))
+				ret = -ENOMEM;
+			raw_sk(sk)->ipmr_table = v;
+		}
 		rtnl_unlock();
 		return ret;
 	}
@@ -1713,6 +1719,7 @@ dont_forward:
 
 /*
  *	Multicast packets for forwarding arrive here
+ *	Called with rcu_read_lock();
  */
 
 int ip_mr_input(struct sk_buff *skb)
@@ -1726,7 +1733,7 @@ int ip_mr_input(struct sk_buff *skb)
 	/* Packet is looped back after forward, it should not be
 	   forwarded second time, but still can be delivered locally.
 	 */
-	if (IPCB(skb)->flags&IPSKB_FORWARDED)
+	if (IPCB(skb)->flags & IPSKB_FORWARDED)
 		goto dont_forward;
 
 	err = ipmr_fib_lookup(net, &skb_rtable(skb)->fl, &mrt);
@@ -1736,24 +1743,24 @@ int ip_mr_input(struct sk_buff *skb)
 	}
 
 	if (!local) {
-		    if (IPCB(skb)->opt.router_alert) {
-			    if (ip_call_ra_chain(skb))
-				    return 0;
-		    } else if (ip_hdr(skb)->protocol == IPPROTO_IGMP){
-			    /* IGMPv1 (and broken IGMPv2 implementations sort of
-			       Cisco IOS <= 11.2(8)) do not put router alert
-			       option to IGMP packets destined to routable
-			       groups. It is very bad, because it means
-			       that we can forward NO IGMP messages.
-			     */
-			    read_lock(&mrt_lock);
-			    if (mrt->mroute_sk) {
-				    nf_reset(skb);
-				    raw_rcv(mrt->mroute_sk, skb);
-				    read_unlock(&mrt_lock);
-				    return 0;
-			    }
-			    read_unlock(&mrt_lock);
+		if (IPCB(skb)->opt.router_alert) {
+			if (ip_call_ra_chain(skb))
+				return 0;
+		} else if (ip_hdr(skb)->protocol == IPPROTO_IGMP) {
+			/* IGMPv1 (and broken IGMPv2 implementations sort of
+			 * Cisco IOS <= 11.2(8)) do not put router alert
+			 * option to IGMP packets destined to routable
+			 * groups. It is very bad, because it means
+			 * that we can forward NO IGMP messages.
+			 */
+			struct sock *mroute_sk;
+
+			mroute_sk = rcu_dereference(mrt->mroute_sk);
+			if (mroute_sk) {
+				nf_reset(skb);
+				raw_rcv(mroute_sk, skb);
+				return 0;
+			}
 		    }
 	}
 


