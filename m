From: Flavio Leitner <fbl@sysclose.org>
Subject: [PATCH] igmp: fix ip_mc_sf_allow race [v5]
Date: Thu, 28 Jan 2010 14:13:38 -0200
Message-ID: <20100128161338.GB3544@sysclose.org>
References: <4B42E252.1080405@gmail.com>
 <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbigip.dreamhost.com ([208.97.132.5]:58654 "EHLO
	homiemail-a13.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755388Ab0A1QNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 11:13:42 -0500
Content-Disposition: inline
In-Reply-To: <1262724742-5232-1-git-send-email-fleitner@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This is another version considering the suggestions. Thanks!
I didn't convert to list_head yet because a lot more code needs
to be changed so I'd rather leave that to another patch.
8<---------

Almost all igmp functions accessing inet->mc_list are protected by
rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
remove an entry while ip_mc_sf_allow is running causing a crash.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 include/linux/igmp.h |    2 +
 net/ipv4/igmp.c      |   83 +++++++++++++++++++++++++++++++++++++------------
 2 files changed, 64 insertions(+), 21 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 724c27e..93fc244 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -153,6 +153,7 @@ extern int sysctl_igmp_max_msf;
 struct ip_sf_socklist {
 	unsigned int		sl_max;
 	unsigned int		sl_count;
+	struct rcu_head		rcu;
 	__be32			sl_addr[0];
 };
 
@@ -170,6 +171,7 @@ struct ip_mc_socklist {
 	struct ip_mreqn		multi;
 	unsigned int		sfmode;		/* MCAST_{INCLUDE,EXCLUDE} */
 	struct ip_sf_socklist	*sflist;
+	struct rcu_head		rcu;
 };
 
 struct ip_sf_list {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 76c0840..54003a5 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1799,7 +1799,7 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	iml->next = inet->mc_list;
 	iml->sflist = NULL;
 	iml->sfmode = MCAST_EXCLUDE;
-	inet->mc_list = iml;
+	rcu_assign_pointer(inet->mc_list, iml);
 	ip_mc_inc_group(in_dev, addr);
 	err = 0;
 done:
@@ -1807,24 +1807,46 @@ done:
 	return err;
 }
 
+static void ip_sf_socklist_reclaim(struct rcu_head *rp)
+{
+	struct ip_sf_socklist *psf;
+
+	psf = container_of(rp, struct ip_sf_socklist, rcu);
+	/* sk_omem_alloc should have been decreased by the caller*/
+	kfree(psf);
+}
+
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 			   struct in_device *in_dev)
 {
+	struct ip_sf_socklist *psf = iml->sflist;
 	int err;
 
-	if (iml->sflist == NULL) {
+	if (psf == NULL) {
 		/* any-source empty exclude case */
 		return ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
 			iml->sfmode, 0, NULL, 0);
 	}
 	err = ip_mc_del_src(in_dev, &iml->multi.imr_multiaddr.s_addr,
-			iml->sfmode, iml->sflist->sl_count,
-			iml->sflist->sl_addr, 0);
-	sock_kfree_s(sk, iml->sflist, IP_SFLSIZE(iml->sflist->sl_max));
-	iml->sflist = NULL;
+			iml->sfmode, psf->sl_count, psf->sl_addr, 0);
+	rcu_assign_pointer(iml->sflist, NULL);
+	/* decrease mem now to avoid the memleak warning */
+	atomic_sub(IP_SFLSIZE(psf->sl_max), &sk->sk_omem_alloc);
+	call_rcu(&psf->rcu, ip_sf_socklist_reclaim);
 	return err;
 }
 
+
+static void ip_mc_socklist_reclaim(struct rcu_head *rp)
+{
+	struct ip_mc_socklist *iml;
+
+	iml = container_of(rp, struct ip_mc_socklist, rcu);
+	/* sk_omem_alloc should have been decreased by the caller*/
+	kfree(iml);
+}
+
+
 /*
  *	Ask a socket to leave a group.
  */
@@ -1854,12 +1876,14 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 		(void) ip_mc_leave_src(sk, iml, in_dev);
 
-		*imlp = iml->next;
+		rcu_assign_pointer(*imlp, iml->next);
 
 		if (in_dev)
 			ip_mc_dec_group(in_dev, group);
 		rtnl_unlock();
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		/* decrease mem now to avoid the memleak warning */
+		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
+		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
 		return 0;
 	}
 	if (!in_dev)
@@ -1974,9 +1998,12 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		if (psl) {
 			for (i=0; i<psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
-			sock_kfree_s(sk, psl, IP_SFLSIZE(psl->sl_max));
+			/* decrease mem now to avoid the memleak warning */
+			atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
+			call_rcu(&psl->rcu, ip_sf_socklist_reclaim);
 		}
-		pmc->sflist = psl = newpsl;
+		rcu_assign_pointer(pmc->sflist, newpsl);
+		psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
 	for (i=0; i<psl->sl_count; i++) {
@@ -2072,11 +2099,13 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	if (psl) {
 		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			psl->sl_count, psl->sl_addr, 0);
-		sock_kfree_s(sk, psl, IP_SFLSIZE(psl->sl_max));
+		/* decrease mem now to avoid the memleak warning */
+		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
+		call_rcu(&psl->rcu, ip_sf_socklist_reclaim);
 	} else
 		(void) ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			0, NULL, 0);
-	pmc->sflist = newpsl;
+	rcu_assign_pointer(pmc->sflist, newpsl);
 	pmc->sfmode = msf->imsf_fmode;
 	err = 0;
 done:
@@ -2209,30 +2238,40 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	struct ip_mc_socklist *pmc;
 	struct ip_sf_socklist *psl;
 	int i;
+	int ret;
 
+	ret = 1;
 	if (!ipv4_is_multicast(loc_addr))
-		return 1;
+		goto out;
 
-	for (pmc=inet->mc_list; pmc; pmc=pmc->next) {
+	rcu_read_lock();
+	for (pmc=rcu_dereference(inet->mc_list); pmc; pmc=rcu_dereference(pmc->next)) {
 		if (pmc->multi.imr_multiaddr.s_addr == loc_addr &&
 		    pmc->multi.imr_ifindex == dif)
 			break;
 	}
+	ret = inet->mc_all;
 	if (!pmc)
-		return inet->mc_all;
+		goto unlock;
 	psl = pmc->sflist;
+	ret = (pmc->sfmode == MCAST_EXCLUDE);
 	if (!psl)
-		return pmc->sfmode == MCAST_EXCLUDE;
+		goto unlock;
 
 	for (i=0; i<psl->sl_count; i++) {
 		if (psl->sl_addr[i] == rmt_addr)
 			break;
 	}
+	ret = 0;
 	if (pmc->sfmode == MCAST_INCLUDE && i >= psl->sl_count)
-		return 0;
+		goto unlock;
 	if (pmc->sfmode == MCAST_EXCLUDE && i < psl->sl_count)
-		return 0;
-	return 1;
+		goto unlock;
+	ret = 1;
+unlock:
+	rcu_read_unlock();
+out:
+	return ret;
 }
 
 /*
@@ -2251,7 +2290,7 @@ void ip_mc_drop_socket(struct sock *sk)
 	rtnl_lock();
 	while ((iml = inet->mc_list) != NULL) {
 		struct in_device *in_dev;
-		inet->mc_list = iml->next;
+		rcu_assign_pointer(inet->mc_list, iml->next);
 
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
@@ -2259,7 +2298,9 @@ void ip_mc_drop_socket(struct sock *sk)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 			in_dev_put(in_dev);
 		}
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		/* decrease mem now to avoid the memleak warning */
+		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
+		call_rcu(&iml->rcu, ip_mc_socklist_reclaim);
 	}
 	rtnl_unlock();
 }
-- 
1.6.5.2

