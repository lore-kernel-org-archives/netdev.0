From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v2 2/3] ipv6,mcast: fix return values of some functions
Date: Wed,  5 Jun 2013 17:38:20 +0800
Message-ID: <1370425101-31683-2-git-send-email-amwang@redhat.com>
References: <1370425101-31683-1-git-send-email-amwang@redhat.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756Ab3FEJit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 05:38:49 -0400
In-Reply-To: <1370425101-31683-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

There are some places casting the return value to void, actually
they can respect the return value.

ip6_mc_leave_src() can become avoid, because even if it fails,
the operations after it can still continue.

Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/mcast.c |   36 +++++++++++++++++-------------------
 1 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 72c8bfe..dd945a9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -103,8 +103,8 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta);
-static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
-			    struct inet6_dev *idev);
+static void ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
+			     struct inet6_dev *idev);
 
 
 #define IGMP6_UNSOLICITED_IVAL	(10*HZ)
@@ -231,11 +231,11 @@ int ipv6_sock_mc_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			if (dev != NULL) {
 				struct inet6_dev *idev = __in6_dev_get(dev);
 
-				(void) ip6_mc_leave_src(sk, mc_lst, idev);
+				ip6_mc_leave_src(sk, mc_lst, idev);
 				if (idev)
 					__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 			} else
-				(void) ip6_mc_leave_src(sk, mc_lst, NULL);
+				ip6_mc_leave_src(sk, mc_lst, NULL);
 			rcu_read_unlock();
 			atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
 			kfree_rcu(mc_lst, rcu);
@@ -300,11 +300,11 @@ void ipv6_sock_mc_close(struct sock *sk)
 		if (dev) {
 			struct inet6_dev *idev = __in6_dev_get(dev);
 
-			(void) ip6_mc_leave_src(sk, mc_lst, idev);
+			ip6_mc_leave_src(sk, mc_lst, idev);
 			if (idev)
 				__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 		} else
-			(void) ip6_mc_leave_src(sk, mc_lst, NULL);
+			ip6_mc_leave_src(sk, mc_lst, NULL);
 		rcu_read_unlock();
 
 		atomic_sub(sizeof(*mc_lst), &sk->sk_omem_alloc);
@@ -434,9 +434,8 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;
 	psl->sl_count++;
-	err = 0;
 	/* update the interface list */
-	ip6_mc_add_src(idev, group, omode, 1, source, 1);
+	err = ip6_mc_add_src(idev, group, omode, 1, source, 1);
 done:
 	if (pmclocked)
 		write_unlock(&pmc->sflock);
@@ -513,21 +512,22 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 		}
 	} else {
 		newpsl = NULL;
-		(void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+		err = ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+		if (err)
+			goto done;
 	}
 
 	write_lock(&pmc->sflock);
 	psl = pmc->sflist;
 	if (psl) {
-		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
+		err = ip6_mc_del_src(idev, group, pmc->sfmode,
 			psl->sl_count, psl->sl_addr, 0);
 		sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 	} else
-		(void) ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
+		err = ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
 	pmc->sflist = newpsl;
 	pmc->sfmode = gsf->gf_fmode;
 	write_unlock(&pmc->sflock);
-	err = 0;
 done:
 	read_unlock_bh(&idev->lock);
 	rcu_read_unlock();
@@ -2120,23 +2120,21 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
 	spin_unlock_bh(&ma->mca_lock);
 }
 
-static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
-			    struct inet6_dev *idev)
+static void ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
+			     struct inet6_dev *idev)
 {
-	int err;
-
 	/* callers have the socket lock and a write lock on ipv6_sk_mc_lock,
 	 * so no other readers or writers of iml or its sflist
 	 */
 	if (!iml->sflist) {
 		/* any-source empty exclude case */
-		return ip6_mc_del_src(idev, &iml->addr, iml->sfmode, 0, NULL, 0);
+		ip6_mc_del_src(idev, &iml->addr, iml->sfmode, 0, NULL, 0);
+		return;
 	}
-	err = ip6_mc_del_src(idev, &iml->addr, iml->sfmode,
+	ip6_mc_del_src(idev, &iml->addr, iml->sfmode,
 		iml->sflist->sl_count, iml->sflist->sl_addr, 0);
 	sock_kfree_s(sk, iml->sflist, IP6_SFLSIZE(iml->sflist->sl_max));
 	iml->sflist = NULL;
-	return err;
 }
 
 static void igmp6_leave_group(struct ifmcaddr6 *ma)
-- 
1.7.7.6
