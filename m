From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 5/8] ipv6: drop ipv6_sk_mc_lock in mcast
Date: Thu, 11 Sep 2014 15:35:13 -0700
Message-ID: <1410474916-21873-6-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:52065 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbaIKWfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:44 -0400
Received: by mail-pd0-f181.google.com with SMTP id w10so9082922pde.26
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:44 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly the code is already protected by rtnl lock.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/mcast.c | 18 ++----------------
 1 file changed, 2 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 484a942..27ca0b7 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -73,9 +73,6 @@ static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
 
 static struct in6_addr mld2_all_mcr = MLD2_ALL_MCR_INIT;
 
-/* Big mc list lock for all the sockets */
-static DEFINE_SPINLOCK(ipv6_sk_mc_lock);
-
 static void igmp6_join_group(struct ifmcaddr6 *ma);
 static void igmp6_leave_group(struct ifmcaddr6 *ma);
 static void igmp6_timer_handler(unsigned long data);
@@ -201,10 +198,8 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		return err;
 	}
 
-	spin_lock(&ipv6_sk_mc_lock);
 	mc_lst->next = np->ipv6_mc_list;
 	rcu_assign_pointer(np->ipv6_mc_list, mc_lst);
-	spin_unlock(&ipv6_sk_mc_lock);
 
 	rcu_read_unlock();
 	rtnl_unlock();
@@ -226,17 +221,14 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		return -EINVAL;
 
 	rtnl_lock();
-	spin_lock(&ipv6_sk_mc_lock);
 	for (lnk = &np->ipv6_mc_list;
-	     (mc_lst = rcu_dereference_protected(*lnk,
-			lockdep_is_held(&ipv6_sk_mc_lock))) != NULL;
+	     (mc_lst = rtnl_dereference(*lnk)) != NULL;
 	      lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
 			struct net_device *dev;
 
 			*lnk = mc_lst->next;
-			spin_unlock(&ipv6_sk_mc_lock);
 
 			rcu_read_lock();
 			dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
@@ -256,7 +248,6 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			return 0;
 		}
 	}
-	spin_unlock(&ipv6_sk_mc_lock);
 	rtnl_unlock();
 
 	return -EADDRNOTAVAIL;
@@ -303,13 +294,10 @@ void ipv6_sock_mc_close(struct sock *sk)
 		return;
 
 	rtnl_lock();
-	spin_lock(&ipv6_sk_mc_lock);
-	while ((mc_lst = rcu_dereference_protected(np->ipv6_mc_list,
-				lockdep_is_held(&ipv6_sk_mc_lock))) != NULL) {
+	while ((mc_lst = rtnl_dereference(np->ipv6_mc_list)) != NULL) {
 		struct net_device *dev;
 
 		np->ipv6_mc_list = mc_lst->next;
-		spin_unlock(&ipv6_sk_mc_lock);
 
 		rcu_read_lock();
 		dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
@@ -326,9 +314,7 @@ void ipv6_sock_mc_close(struct sock *sk)
 		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
 		kfree_rcu(mc_lst, rcu);
 
-		spin_lock(&ipv6_sk_mc_lock);
 	}
-	spin_unlock(&ipv6_sk_mc_lock);
 	rtnl_unlock();
 }
 
-- 
1.8.3.1
