From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4 1/3] igmp: make some functions void
Date: Sat, 15 Jun 2013 15:34:42 +0800
Message-ID: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Cc: David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25211 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab3FOHe4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 03:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

ip_mc_leave_src() can become avoid, because even if it fails,
the operations after it can still continue.

ip_mc_del_src() can become avoid, because no one cares and
some errors are ignored on purpose.

Cc: David Stevens <dlstevens@us.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/igmp.c |   47 +++++++++++++++++++++--------------------------
 1 files changed, 21 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index cd71190..1a6a626 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1571,15 +1571,15 @@ static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
 #define igmp_ifc_event(x)	do { } while (0)
 #endif
 
-static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
-			 int sfcount, __be32 *psfsrc, int delta)
+static void ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
+			  int sfcount, __be32 *psfsrc, int delta)
 {
 	struct ip_mc_list *pmc;
 	int	changerec = 0;
-	int	i, err;
+	int	i;
 
 	if (!in_dev)
-		return -ENODEV;
+		return;
 	rcu_read_lock();
 	for_each_pmc_rcu(in_dev, pmc) {
 		if (*pmca == pmc->multiaddr)
@@ -1588,7 +1588,7 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	if (!pmc) {
 		/* MCA not found?? bug */
 		rcu_read_unlock();
-		return -ESRCH;
+		return;
 	}
 	spin_lock_bh(&pmc->lock);
 	rcu_read_unlock();
@@ -1596,18 +1596,14 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	sf_markstate(pmc);
 #endif
 	if (!delta) {
-		err = -EINVAL;
 		if (!pmc->sfcount[sfmode])
 			goto out_unlock;
 		pmc->sfcount[sfmode]--;
 	}
-	err = 0;
 	for (i=0; i<sfcount; i++) {
 		int rv = ip_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
-		if (!err && rv < 0)
-			err = rv;
 	}
 	if (pmc->sfmode == MCAST_EXCLUDE &&
 	    pmc->sfcount[MCAST_EXCLUDE] == 0 &&
@@ -1631,7 +1627,6 @@ static int ip_mc_del_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 	}
 out_unlock:
 	spin_unlock_bh(&pmc->lock);
-	return err;
 }
 
 /*
@@ -1783,7 +1778,7 @@ static int ip_mc_add_src(struct in_device *in_dev, __be32 *pmca, int sfmode,
 		if (!delta)
 			pmc->sfcount[sfmode]--;
 		for (j=0; j<i; j++)
-			(void) ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
+			ip_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->sfcount[MCAST_EXCLUDE] != 0)) {
 #ifdef CONFIG_IP_MULTICAST
 		struct ip_sf_list *psf;
@@ -1887,24 +1882,23 @@ done:
 }
 EXPORT_SYMBOL(ip_mc_join_group);
 
-static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
-			   struct in_device *in_dev)
+static void ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
+			    struct in_device *in_dev)
 {
 	struct ip_sf_socklist *psf = rtnl_dereference(iml->sflist);
-	int err;
 
 	if (psf == NULL) {
 		/* any-source empty exclude case */
-		return ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
+		ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
 			iml->sfmode, 0, NULL, 0);
+		return;
 	}
-	err = ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
+	ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
 			iml->sfmode, psf->sl_count, psf->sl_addr, 0);
 	RCU_INIT_POINTER(iml->sflist, NULL);
 	/* decrease mem now to avoid the memleak warning */
 	atomic_sub(IP_SFLSIZE(psf->sl_max), &sk->sk_omem_alloc);
 	kfree_rcu(psf, rcu);
-	return err;
 }
 
 /*
@@ -1937,7 +1931,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 				iml->multi.imr_address.s_addr)
 			continue;
 
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 
 		*imlp = iml->next_rcu;
 
@@ -1949,6 +1943,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 		kfree_rcu(iml, rcu);
 		return 0;
 	}
+
 	if (!in_dev)
 		ret = -ENODEV;
 	rtnl_unlock();
@@ -2085,7 +2080,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	err = 0;
 	/* update the interface list */
 	ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
-		&mreqs->imr_sourceaddr, 1);
+		      &mreqs->imr_sourceaddr, 1);
 done:
 	rtnl_unlock();
 	if (leavegroup)
@@ -2156,19 +2151,19 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 		}
 	} else {
 		newpsl = NULL;
-		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
-				     msf->imsf_fmode, 0, NULL, 0);
+		ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
+			      msf->imsf_fmode, 0, NULL, 0);
 	}
 	psl = rtnl_dereference(pmc->sflist);
 	if (psl) {
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
-			psl->sl_count, psl->sl_addr, 0);
+		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+			      psl->sl_count, psl->sl_addr, 0);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
 		kfree_rcu(psl, rcu);
 	} else
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
-			0, NULL, 0);
+		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+			      0, NULL, 0);
 	rcu_assign_pointer(pmc->sflist, newpsl);
 	pmc->sfmode = msf->imsf_fmode;
 	err = 0;
@@ -2357,7 +2352,7 @@ void ip_mc_drop_socket(struct sock *sk)
 
 		inet->mc_list = iml->next_rcu;
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
-- 
1.7.7.6
