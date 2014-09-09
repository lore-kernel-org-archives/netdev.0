From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next 5/5] ipv6: drop some rcu_read_lock in mcast
Date: Tue,  9 Sep 2014 16:52:18 -0700
Message-ID: <1410306738-18036-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58207 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbaIIXwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:52:41 -0400
Received: by mail-pd0-f173.google.com with SMTP id ft15so7987888pdb.32
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 16:52:41 -0700 (PDT)
In-Reply-To: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly the code is already protected by rtnl lock.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/mcast.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d2b7dd8..255409c 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -171,7 +171,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->addr = *addr;
 
 	rtnl_lock();
-	rcu_read_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 		rt = rt6_lookup(net, addr, NULL, 0, 0);
@@ -180,10 +179,9 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			ip6_rt_put(rt);
 		}
 	} else
-		dev = dev_get_by_index_rcu(net, ifindex);
+		dev = __dev_get_by_index(net, ifindex);
 
 	if (dev == NULL) {
-		rcu_read_unlock();
 		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return -ENODEV;
@@ -201,7 +199,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	err = ipv6_dev_mc_inc(dev, addr);
 
 	if (err) {
-		rcu_read_unlock();
 		rtnl_unlock();
 		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 		return err;
@@ -210,7 +207,6 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	mc_lst->next = np->ipv6_mc_list;
 	rcu_assign_pointer(np->ipv6_mc_list, mc_lst);
 
-	rcu_read_unlock();
 	rtnl_unlock();
 
 	return 0;
@@ -239,8 +235,7 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 			*lnk = mc_lst->next;
 
-			rcu_read_lock();
-			dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
+			dev = __dev_get_by_index(net, mc_lst->ifindex);
 			if (dev != NULL) {
 				struct inet6_dev *idev = __in6_dev_get(dev);
 
@@ -249,7 +244,6 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 					__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 			} else
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
-			rcu_read_unlock();
 			rtnl_unlock();
 
 			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
@@ -308,8 +302,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 
 		np->ipv6_mc_list = mc_lst->next;
 
-		rcu_read_lock();
-		dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
+		dev = __dev_get_by_index(net, mc_lst->ifindex);
 		if (dev) {
 			struct inet6_dev *idev = __in6_dev_get(dev);
 
@@ -318,7 +311,6 @@ void ipv6_sock_mc_close(struct sock *sk)
 				__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 		} else
 			(void) ip6_mc_leave_src(sk, mc_lst, NULL);
-		rcu_read_unlock();
 
 		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
 		kfree_rcu(mc_lst, rcu);
@@ -943,7 +935,7 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 	struct inet6_dev *idev;
 	int err;
 
-	rcu_read_lock();
+	ASSERT_RTNL();
 
 	idev = __in6_dev_get(dev);
 	if (!idev)
@@ -951,7 +943,6 @@ int ipv6_dev_mc_dec(struct net_device *dev, const struct in6_addr *addr)
 	else
 		err = __ipv6_dev_mc_dec(idev, addr);
 
-	rcu_read_unlock();
 	return err;
 }
 
-- 
1.8.3.1
