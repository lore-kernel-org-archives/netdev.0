From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH net-next v5 1/2] igmp v6: add __ipv6_sock_mc_join and __ipv6_sock_mc_drop
Date: Wed, 25 Feb 2015 09:58:34 -0800
Message-ID: <1424887115-3483-2-git-send-email-challa@noironetworks.com>
References: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: eric.dumazet@gmail.com, davem@davemloft.net, daniel@iogearbox.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:43017 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbbBYSPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 13:15:04 -0500
Received: by pdev10 with SMTP id v10so6541803pde.10
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 10:15:03 -0800 (PST)
In-Reply-To: <1424887115-3483-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the igmp v4 changes from Eric Dumazet.
959d10f6bbf6("igmp: add __ip_mc_{join|leave}_group()")

These changes are needed to perform igmp v6 join/leave while
RTNL is held.

Make ipv6_sock_mc_join and ipv6_sock_mc_drop wrappers around
__ipv6_sock_mc_join and  __ipv6_sock_mc_drop to avoid
proliferation of work queues.

Signed-off-by: Madhu Challa <challa@noironetworks.com>
---
 include/net/ipv6.h |  8 ++++++++
 net/ipv6/mcast.c   | 40 +++++++++++++++++++++++++++++++---------
 2 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4c9fe22..b767306 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -940,4 +940,12 @@ int ipv6_sysctl_register(void);
 void ipv6_sysctl_unregister(void);
 #endif
 
+int ipv6_sock_mc_join(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+int __ipv6_sock_mc_join(struct sock *sk, int ifindex,
+			const struct in6_addr *addr);
+int ipv6_sock_mc_drop(struct sock *sk, int ifindex,
+		      const struct in6_addr *addr);
+int __ipv6_sock_mc_drop(struct sock *sk, int ifindex,
+			const struct in6_addr *addr);
 #endif /* _NET_IPV6_H */
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5ce107c..e4955d0 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -132,7 +132,7 @@ static int unsolicited_report_interval(struct inet6_dev *idev)
 	return iv > 0 ? iv : 1;
 }
 
-int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
+int __ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct net_device *dev = NULL;
 	struct ipv6_mc_socklist *mc_lst;
@@ -140,6 +140,8 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct net *net = sock_net(sk);
 	int err;
 
+	ASSERT_RTNL();
+
 	if (!ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 
@@ -161,7 +163,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->next = NULL;
 	mc_lst->addr = *addr;
 
-	rtnl_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
@@ -173,7 +174,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		dev = __dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
-		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return -ENODEV;
 	}
@@ -190,7 +190,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	err = ipv6_dev_mc_inc(dev, addr);
 
 	if (err) {
-		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return err;
 	}
@@ -198,25 +197,37 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->next = np->ipv6_mc_list;
 	rcu_assign_pointer(np->ipv6_mc_list, mc_lst);
 
+	return 0;
+}
+EXPORT_SYMBOL(__ipv6_sock_mc_join);
+
+int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = __ipv6_sock_mc_join(sk, ifindex, addr);
 	rtnl_unlock();
 
-	return 0;
+	return ret;
 }
+EXPORT_SYMBOL(ipv6_sock_mc_join);
 
 /*
  *	socket leave on multicast group
  */
-int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
+int __ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct ipv6_mc_socklist *mc_lst;
 	struct ipv6_mc_socklist __rcu **lnk;
 	struct net *net = sock_net(sk);
 
+	ASSERT_RTNL();
+
 	if (!ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
 	for (lnk = &np->ipv6_mc_list;
 	     (mc_lst = rtnl_dereference(*lnk)) != NULL;
 	      lnk = &mc_lst->next) {
@@ -235,17 +246,28 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 					__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 			} else
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
-			rtnl_unlock();
 
 			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
 			kfree_rcu(mc_lst, rcu);
 			return 0;
 		}
 	}
-	rtnl_unlock();
 
 	return -EADDRNOTAVAIL;
 }
+EXPORT_SYMBOL(__ipv6_sock_mc_drop);
+
+int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = __ipv6_sock_mc_drop(sk, ifindex, addr);
+	rtnl_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(ipv6_sock_mc_drop);
 
 /* called with rcu_read_lock() */
 static struct inet6_dev *ip6_mc_find_dev_rcu(struct net *net,
-- 
1.9.1
