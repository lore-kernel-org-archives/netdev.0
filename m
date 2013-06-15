From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4 2/3] ipv6,mcast: make some functions void
Date: Sat, 15 Jun 2013 15:34:43 +0800
Message-ID: <1371281684-26587-2-git-send-email-amwang@redhat.com>
References: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3110 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab3FOHfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 03:35:10 -0400
In-Reply-To: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

ip6_mc_leave_src() can become avoid, because even if it fails,
the operations after it can still continue.

ip6_mc_del_src() can become avoid, because no one cares and
some errors are ignored on purpose.

Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv6/mcast.c |   52 +++++++++++++++++++++++-----------------------------
 1 files changed, 23 insertions(+), 29 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 72c8bfe..51ebf92 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -97,14 +97,14 @@ static void mld_clear_delrec(struct inet6_dev *idev);
 static int sf_setstate(struct ifmcaddr6 *pmc);
 static void sf_markstate(struct ifmcaddr6 *pmc);
 static void ip6_mc_clear_src(struct ifmcaddr6 *pmc);
-static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+static void ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
 			  int delta);
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
@@ -513,17 +513,17 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 		}
 	} else {
 		newpsl = NULL;
-		(void) ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
+		ip6_mc_add_src(idev, group, gsf->gf_fmode, 0, NULL, 0);
 	}
 
 	write_lock(&pmc->sflock);
 	psl = pmc->sflist;
 	if (psl) {
-		(void) ip6_mc_del_src(idev, group, pmc->sfmode,
-			psl->sl_count, psl->sl_addr, 0);
+		ip6_mc_del_src(idev, group, pmc->sfmode,
+			       psl->sl_count, psl->sl_addr, 0);
 		sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 	} else
-		(void) ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
+		ip6_mc_del_src(idev, group, pmc->sfmode, 0, NULL, 0);
 	pmc->sflist = newpsl;
 	pmc->sfmode = gsf->gf_fmode;
 	write_unlock(&pmc->sflock);
@@ -1852,16 +1852,16 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	return rv;
 }
 
-static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
-			  int sfmode, int sfcount, const struct in6_addr *psfsrc,
-			  int delta)
+static void ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
+			   int sfmode, int sfcount, const struct in6_addr *psfsrc,
+			   int delta)
 {
 	struct ifmcaddr6 *pmc;
 	int	changerec = 0;
-	int	i, err;
+	int	i;
 
 	if (!idev)
-		return -ENODEV;
+		return;
 	read_lock_bh(&idev->lock);
 	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
@@ -1870,7 +1870,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!pmc) {
 		/* MCA not found?? bug */
 		read_unlock_bh(&idev->lock);
-		return -ESRCH;
+		return;
 	}
 	spin_lock_bh(&pmc->mca_lock);
 	sf_markstate(pmc);
@@ -1878,17 +1878,14 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		if (!pmc->mca_sfcount[sfmode]) {
 			spin_unlock_bh(&pmc->mca_lock);
 			read_unlock_bh(&idev->lock);
-			return -EINVAL;
+			return;
 		}
 		pmc->mca_sfcount[sfmode]--;
 	}
-	err = 0;
 	for (i=0; i<sfcount; i++) {
 		int rv = ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
-		if (!err && rv < 0)
-			err = rv;
 	}
 	if (pmc->mca_sfmode == MCAST_EXCLUDE &&
 	    pmc->mca_sfcount[MCAST_EXCLUDE] == 0 &&
@@ -1906,7 +1903,6 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		mld_ifc_event(pmc->idev);
 	spin_unlock_bh(&pmc->mca_lock);
 	read_unlock_bh(&idev->lock);
-	return err;
 }
 
 /*
@@ -2120,23 +2116,21 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
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
