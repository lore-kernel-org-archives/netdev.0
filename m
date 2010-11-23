From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: mcast: RCU conversion
Date: Wed, 24 Nov 2010 00:12:15 +0100
Message-ID: <1290553935.2866.82.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f47.google.com ([74.125.82.47]:40579 "EHLO
	mail-ww0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016Ab0KWXMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 18:12:21 -0500
Received: by mail-ww0-f47.google.com with SMTP id 39so275666wwb.4
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 15:12:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_sk_mc_lock rwlock becomes a spinlock.

readers (inet6_mc_check()) now takes rcu_read_lock() instead of read
lock. Writers dont need to disable BH anymore.

struct ipv6_mc_socklist objects are reclaimed after one RCU grace
period.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/ipv6.h   |    2 -
 include/net/if_inet6.h |    3 +
 net/ipv6/mcast.c       |   75 ++++++++++++++++++++++-----------------
 3 files changed, 47 insertions(+), 33 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 8e429d0..0c99776 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -364,7 +364,7 @@ struct ipv6_pinfo {
 
 	__u32			dst_cookie;
 
-	struct ipv6_mc_socklist	*ipv6_mc_list;
+	struct ipv6_mc_socklist	__rcu *ipv6_mc_list;
 	struct ipv6_ac_socklist	*ipv6_ac_list;
 	struct ipv6_fl_socklist *ipv6_fl_list;
 
diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index f95ff8d..04977ee 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -89,10 +89,11 @@ struct ip6_sf_socklist {
 struct ipv6_mc_socklist {
 	struct in6_addr		addr;
 	int			ifindex;
-	struct ipv6_mc_socklist *next;
+	struct ipv6_mc_socklist __rcu *next;
 	rwlock_t		sflock;
 	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip6_sf_socklist	*sflist;
+	struct rcu_head		rcu;
 };
 
 struct ip6_sf_list {
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 9c50745..49f986d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -82,7 +82,7 @@ static void *__mld2_query_bugs[] __attribute__((__unused__)) = {
 static struct in6_addr mld2_all_mcr = MLD2_ALL_MCR_INIT;
 
 /* Big mc list lock for all the sockets */
-static DEFINE_RWLOCK(ipv6_sk_mc_lock);
+static DEFINE_SPINLOCK(ipv6_sk_mc_lock);
 
 static void igmp6_join_group(struct ifmcaddr6 *ma);
 static void igmp6_leave_group(struct ifmcaddr6 *ma);
@@ -123,6 +123,11 @@ int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
  *	socket join on multicast group
  */
 
+#define for_each_pmc_rcu(np, pmc)				\
+	for (pmc = rcu_dereference(np->ipv6_mc_list);		\
+	     pmc != NULL;					\
+	     pmc = rcu_dereference(pmc->next))
+
 int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct net_device *dev = NULL;
@@ -134,15 +139,15 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	if (!ipv6_addr_is_multicast(addr))
 		return -EINVAL;
 
-	read_lock_bh(&ipv6_sk_mc_lock);
-	for (mc_lst=np->ipv6_mc_list; mc_lst; mc_lst=mc_lst->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(np, mc_lst) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
-			read_unlock_bh(&ipv6_sk_mc_lock);
+			rcu_read_unlock();
 			return -EADDRINUSE;
 		}
 	}
-	read_unlock_bh(&ipv6_sk_mc_lock);
+	rcu_read_unlock();
 
 	mc_lst = sock_kmalloc(sk, sizeof(struct ipv6_mc_socklist), GFP_KERNEL);
 
@@ -186,33 +191,41 @@ int ipv6_sock_mc_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		return err;
 	}
 
-	write_lock_bh(&ipv6_sk_mc_lock);
+	spin_lock(&ipv6_sk_mc_lock);
 	mc_lst->next = np->ipv6_mc_list;
-	np->ipv6_mc_list = mc_lst;
-	write_unlock_bh(&ipv6_sk_mc_lock);
+	rcu_assign_pointer(np->ipv6_mc_list, mc_lst);
+	spin_unlock(&ipv6_sk_mc_lock);
 
 	rcu_read_unlock();
 
 	return 0;
 }
 
+static void ipv6_mc_socklist_reclaim(struct rcu_head *head)
+{
+	kfree(container_of(head, struct ipv6_mc_socklist, rcu));
+}
 /*
  *	socket leave on multicast group
  */
 int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct ipv6_mc_socklist *mc_lst, **lnk;
+	struct ipv6_mc_socklist *mc_lst;
+	struct ipv6_mc_socklist __rcu **lnk;
 	struct net *net = sock_net(sk);
 
-	write_lock_bh(&ipv6_sk_mc_lock);
-	for (lnk = &np->ipv6_mc_list; (mc_lst = *lnk) !=NULL ; lnk = &mc_lst->next) {
+	spin_lock(&ipv6_sk_mc_lock);
+	for (lnk = &np->ipv6_mc_list;
+	     (mc_lst = rcu_dereference_protected(*lnk,
+			lockdep_is_held(&ipv6_sk_mc_lock))) !=NULL ;
+	      lnk = &mc_lst->next) {
 		if ((ifindex == 0 || mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_equal(&mc_lst->addr, addr)) {
 			struct net_device *dev;
 
 			*lnk = mc_lst->next;
-			write_unlock_bh(&ipv6_sk_mc_lock);
+			spin_unlock(&ipv6_sk_mc_lock);
 
 			rcu_read_lock();
 			dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
@@ -225,11 +238,12 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			} else
 				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
 			rcu_read_unlock();
-			sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
+			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
+			call_rcu(&mc_lst->rcu, ipv6_mc_socklist_reclaim);
 			return 0;
 		}
 	}
-	write_unlock_bh(&ipv6_sk_mc_lock);
+	spin_unlock(&ipv6_sk_mc_lock);
 
 	return -EADDRNOTAVAIL;
 }
@@ -272,12 +286,13 @@ void ipv6_sock_mc_close(struct sock *sk)
 	struct ipv6_mc_socklist *mc_lst;
 	struct net *net = sock_net(sk);
 
-	write_lock_bh(&ipv6_sk_mc_lock);
-	while ((mc_lst = np->ipv6_mc_list) != NULL) {
+	spin_lock(&ipv6_sk_mc_lock);
+	while ((mc_lst = rcu_dereference_protected(np->ipv6_mc_list,
+				lockdep_is_held(&ipv6_sk_mc_lock))) != NULL) {
 		struct net_device *dev;
 
 		np->ipv6_mc_list = mc_lst->next;
-		write_unlock_bh(&ipv6_sk_mc_lock);
+		spin_unlock(&ipv6_sk_mc_lock);
 
 		rcu_read_lock();
 		dev = dev_get_by_index_rcu(net, mc_lst->ifindex);
@@ -290,11 +305,13 @@ void ipv6_sock_mc_close(struct sock *sk)
 		} else
 			(void) ip6_mc_leave_src(sk, mc_lst, NULL);
 		rcu_read_unlock();
-		sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
 
-		write_lock_bh(&ipv6_sk_mc_lock);
+		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
+		call_rcu(&mc_lst->rcu, ipv6_mc_socklist_reclaim);
+
+		spin_lock(&ipv6_sk_mc_lock);
 	}
-	write_unlock_bh(&ipv6_sk_mc_lock);
+	spin_unlock(&ipv6_sk_mc_lock);
 }
 
 int ip6_mc_source(int add, int omode, struct sock *sk,
@@ -328,8 +345,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 
 	err = -EADDRNOTAVAIL;
 
-	read_lock(&ipv6_sk_mc_lock);
-	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
+	for_each_pmc_rcu(inet6, pmc) {
 		if (pgsr->gsr_interface && pmc->ifindex != pgsr->gsr_interface)
 			continue;
 		if (ipv6_addr_equal(&pmc->addr, group))
@@ -428,7 +444,6 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 done:
 	if (pmclocked)
 		write_unlock(&pmc->sflock);
-	read_unlock(&ipv6_sk_mc_lock);
 	read_unlock_bh(&idev->lock);
 	rcu_read_unlock();
 	if (leavegroup)
@@ -466,14 +481,13 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 	dev = idev->dev;
 
 	err = 0;
-	read_lock(&ipv6_sk_mc_lock);
 
 	if (gsf->gf_fmode == MCAST_INCLUDE && gsf->gf_numsrc == 0) {
 		leavegroup = 1;
 		goto done;
 	}
 
-	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
+	for_each_pmc_rcu(inet6, pmc) {
 		if (pmc->ifindex != gsf->gf_interface)
 			continue;
 		if (ipv6_addr_equal(&pmc->addr, group))
@@ -521,7 +535,6 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 	write_unlock(&pmc->sflock);
 	err = 0;
 done:
-	read_unlock(&ipv6_sk_mc_lock);
 	read_unlock_bh(&idev->lock);
 	rcu_read_unlock();
 	if (leavegroup)
@@ -562,7 +575,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	 * so reading the list is safe.
 	 */
 
-	for (pmc=inet6->ipv6_mc_list; pmc; pmc=pmc->next) {
+	for_each_pmc_rcu(inet6, pmc) {
 		if (pmc->ifindex != gsf->gf_interface)
 			continue;
 		if (ipv6_addr_equal(group, &pmc->addr))
@@ -612,13 +625,13 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	struct ip6_sf_socklist *psl;
 	int rv = 1;
 
-	read_lock(&ipv6_sk_mc_lock);
-	for (mc = np->ipv6_mc_list; mc; mc = mc->next) {
+	rcu_read_lock();
+	for_each_pmc_rcu(np, mc) {
 		if (ipv6_addr_equal(&mc->addr, mc_addr))
 			break;
 	}
 	if (!mc) {
-		read_unlock(&ipv6_sk_mc_lock);
+		rcu_read_unlock();
 		return 1;
 	}
 	read_lock(&mc->sflock);
@@ -638,7 +651,7 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 			rv = 0;
 	}
 	read_unlock(&mc->sflock);
-	read_unlock(&ipv6_sk_mc_lock);
+	rcu_read_unlock();
 
 	return rv;
 }


