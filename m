From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Thu,  6 Jun 2013 10:20:09 +0800
Message-ID: <1370485211-11498-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55029 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab3FFCU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 22:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

There are some places casting the return value to void, actually
they can respect the return value.

ip_mc_leave_src() can become avoid, because even if it fails,
the operations after it can still continue.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v2: fix the indention

 net/ipv4/igmp.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 450f625..bf185df 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1837,24 +1837,23 @@ done:
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
@@ -1887,7 +1886,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 				iml->multi.imr_address.s_addr)
 			continue;
 
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 
 		*imlp = iml->next_rcu;
 
@@ -1899,6 +1898,7 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 		kfree_rcu(iml, rcu);
 		return 0;
 	}
+
 	if (!in_dev)
 		ret = -ENODEV;
 	rtnl_unlock();
@@ -2032,10 +2032,9 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = mreqs->imr_sourceaddr;
 	psl->sl_count++;
-	err = 0;
 	/* update the interface list */
-	ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
-		&mreqs->imr_sourceaddr, 1);
+	err = ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
+			    &mreqs->imr_sourceaddr, 1);
 done:
 	rtnl_unlock();
 	if (leavegroup)
@@ -2106,22 +2105,23 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 		}
 	} else {
 		newpsl = NULL;
-		(void) ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
+		err = ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
 				     msf->imsf_fmode, 0, NULL, 0);
+		if (err)
+			goto done;
 	}
 	psl = rtnl_dereference(pmc->sflist);
 	if (psl) {
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+		err = ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			psl->sl_count, psl->sl_addr, 0);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
 		kfree_rcu(psl, rcu);
 	} else
-		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
+		err = ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			0, NULL, 0);
 	rcu_assign_pointer(pmc->sflist, newpsl);
 	pmc->sfmode = msf->imsf_fmode;
-	err = 0;
 done:
 	rtnl_unlock();
 	if (leavegroup)
@@ -2307,7 +2307,7 @@ void ip_mc_drop_socket(struct sock *sk)
 
 		inet->mc_list = iml->next_rcu;
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
-		(void) ip_mc_leave_src(sk, iml, in_dev);
+		ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
-- 
1.7.7.6
