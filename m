From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v4 3/3] igmp: convert RTNL lock to a spinlock
Date: Sat, 15 Jun 2013 15:34:44 +0800
Message-ID: <1371281684-26587-3-git-send-email-amwang@redhat.com>
References: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751476Ab3FOHfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 03:35:13 -0400
In-Reply-To: <1371281684-26587-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

It is not necessary to hold RTNL lock to protect mc_list,
at least IPv6 mcast is using a local spinlock, IPv4 can do
this too. This patch converts RTNL lock+RCU to spinlock+RCU.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/igmp.c |  212 ++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 123 insertions(+), 89 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 1a6a626..7fe5103 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -156,15 +156,20 @@ static void ip_ma_put(struct ip_mc_list *im)
 	}
 }
 
+static DEFINE_SPINLOCK(ipv4_sk_mc_lock);
+
 #define for_each_pmc_rcu(in_dev, pmc)				\
 	for (pmc = rcu_dereference(in_dev->mc_list);		\
 	     pmc != NULL;					\
 	     pmc = rcu_dereference(pmc->next_rcu))
 
-#define for_each_pmc_rtnl(in_dev, pmc)				\
-	for (pmc = rtnl_dereference(in_dev->mc_list);		\
+#define for_each_pmc(in_dev, pmc)				\
+	for (pmc = rcu_dereference_protected(in_dev->mc_list,	\
+		lockdep_is_held(&ipv4_sk_mc_lock));		\
 	     pmc != NULL;					\
-	     pmc = rtnl_dereference(pmc->next_rcu))
+	     pmc = rcu_dereference_protected(pmc->next_rcu,	\
+		lockdep_is_held(&ipv4_sk_mc_lock)))
+
 
 #ifdef CONFIG_IP_MULTICAST
 
@@ -1059,7 +1064,7 @@ static void igmpv3_add_delrec(struct in_device *in_dev, struct ip_mc_list *im)
 	 * for deleted items allows change reports to use common code with
 	 * non-deleted or query-response MCA's.
 	 */
-	pmc = kzalloc(sizeof(*pmc), GFP_KERNEL);
+	pmc = kzalloc(sizeof(*pmc), GFP_ATOMIC);
 	if (!pmc)
 		return;
 	spin_lock_bh(&im->lock);
@@ -1228,7 +1233,8 @@ static void ip_mc_hash_add(struct in_device *in_dev,
 	struct ip_mc_list __rcu **mc_hash;
 	u32 hash;
 
-	mc_hash = rtnl_dereference(in_dev->mc_hash);
+	mc_hash = rcu_dereference_protected(in_dev->mc_hash,
+				lockdep_is_held(&ipv4_sk_mc_lock));
 	if (mc_hash) {
 		hash = ip_mc_hash(im);
 		im->next_hash = mc_hash[hash];
@@ -1241,11 +1247,11 @@ static void ip_mc_hash_add(struct in_device *in_dev,
 		return;
 
 	mc_hash = kzalloc(sizeof(struct ip_mc_list *) << MC_HASH_SZ_LOG,
-			  GFP_KERNEL);
+			  GFP_ATOMIC);
 	if (!mc_hash)
 		return;
 
-	for_each_pmc_rtnl(in_dev, im) {
+	for_each_pmc(in_dev, im) {
 		hash = ip_mc_hash(im);
 		im->next_hash = mc_hash[hash];
 		RCU_INIT_POINTER(mc_hash[hash], im);
@@ -1257,13 +1263,15 @@ static void ip_mc_hash_add(struct in_device *in_dev,
 static void ip_mc_hash_remove(struct in_device *in_dev,
 			      struct ip_mc_list *im)
 {
-	struct ip_mc_list __rcu **mc_hash = rtnl_dereference(in_dev->mc_hash);
+	struct ip_mc_list __rcu **mc_hash = rcu_dereference_protected(in_dev->mc_hash,
+						lockdep_is_held(&ipv4_sk_mc_lock));
 	struct ip_mc_list *aux;
 
 	if (!mc_hash)
 		return;
 	mc_hash += ip_mc_hash(im);
-	while ((aux = rtnl_dereference(*mc_hash)) != im)
+	while ((aux = rcu_dereference_protected(*mc_hash,
+			lockdep_is_held(&ipv4_sk_mc_lock))) != im)
 		mc_hash = &aux->next_hash;
 	*mc_hash = im->next_hash;
 }
@@ -1277,19 +1285,20 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 {
 	struct ip_mc_list *im;
 
-	ASSERT_RTNL();
-
-	for_each_pmc_rtnl(in_dev, im) {
+	rcu_read_lock();
+	for_each_pmc_rcu(in_dev, im) {
 		if (im->multiaddr == addr) {
 			im->users++;
 			ip_mc_add_src(in_dev, &addr, MCAST_EXCLUDE, 0, NULL, 0);
-			goto out;
+			rcu_read_unlock();
+			return;
 		}
 	}
+	rcu_read_unlock();
 
 	im = kzalloc(sizeof(*im), GFP_KERNEL);
 	if (!im)
-		goto out;
+		return;
 
 	im->users = 1;
 	im->interface = in_dev;
@@ -1305,11 +1314,13 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	im->unsolicit_count = IGMP_Unsolicited_Report_Count;
 #endif
 
+	spin_lock(&ipv4_sk_mc_lock);
 	im->next_rcu = in_dev->mc_list;
 	in_dev->mc_count++;
 	rcu_assign_pointer(in_dev->mc_list, im);
 
 	ip_mc_hash_add(in_dev, im);
+	spin_unlock(&ipv4_sk_mc_lock);
 
 #ifdef CONFIG_IP_MULTICAST
 	igmpv3_del_delrec(in_dev, im->multiaddr);
@@ -1317,8 +1328,6 @@ void ip_mc_inc_group(struct in_device *in_dev, __be32 addr)
 	igmp_group_added(im);
 	if (!in_dev->dead)
 		ip_rt_multicast_event(in_dev);
-out:
-	return;
 }
 EXPORT_SYMBOL(ip_mc_inc_group);
 
@@ -1355,15 +1364,14 @@ EXPORT_SYMBOL(ip_mc_rejoin_groups);
  *	A socket has left a multicast group on device dev
  */
 
-void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
+static void __ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 {
 	struct ip_mc_list *i;
 	struct ip_mc_list __rcu **ip;
 
-	ASSERT_RTNL();
-
 	for (ip = &in_dev->mc_list;
-	     (i = rtnl_dereference(*ip)) != NULL;
+	     (i = rcu_dereference_protected(*ip,
+			lockdep_is_held(&ipv4_sk_mc_lock))) != NULL;
 	     ip = &i->next_rcu) {
 		if (i->multiaddr == addr) {
 			if (--i->users == 0) {
@@ -1383,6 +1391,14 @@ void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
 		}
 	}
 }
+
+void ip_mc_dec_group(struct in_device *in_dev, __be32 addr)
+{
+	spin_lock(&ipv4_sk_mc_lock);
+	__ip_mc_dec_group(in_dev, addr);
+	spin_unlock(&ipv4_sk_mc_lock);
+}
+
 EXPORT_SYMBOL(ip_mc_dec_group);
 
 /* Device changing type */
@@ -1391,20 +1407,20 @@ void ip_mc_unmap(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
 
-	ASSERT_RTNL();
-
-	for_each_pmc_rtnl(in_dev, pmc)
+	spin_lock(&ipv4_sk_mc_lock);
+	for_each_pmc(in_dev, pmc)
 		igmp_group_dropped(pmc);
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 void ip_mc_remap(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
 
-	ASSERT_RTNL();
-
-	for_each_pmc_rtnl(in_dev, pmc)
+	spin_lock(&ipv4_sk_mc_lock);
+	for_each_pmc(in_dev, pmc)
 		igmp_group_added(pmc);
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 /* Device going down */
@@ -1413,9 +1429,8 @@ void ip_mc_down(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
 
-	ASSERT_RTNL();
-
-	for_each_pmc_rtnl(in_dev, pmc)
+	spin_lock(&ipv4_sk_mc_lock);
+	for_each_pmc(in_dev, pmc)
 		igmp_group_dropped(pmc);
 
 #ifdef CONFIG_IP_MULTICAST
@@ -1427,8 +1442,8 @@ void ip_mc_down(struct in_device *in_dev)
 		__in_dev_put(in_dev);
 	igmpv3_clear_delrec(in_dev);
 #endif
-
-	ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);
+	__ip_mc_dec_group(in_dev, IGMP_ALL_HOSTS);
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 void ip_mc_init_dev(struct in_device *in_dev)
@@ -1452,12 +1467,12 @@ void ip_mc_up(struct in_device *in_dev)
 {
 	struct ip_mc_list *pmc;
 
-	ASSERT_RTNL();
-
 	ip_mc_inc_group(in_dev, IGMP_ALL_HOSTS);
 
-	for_each_pmc_rtnl(in_dev, pmc)
+	spin_lock(&ipv4_sk_mc_lock);
+	for_each_pmc(in_dev, pmc)
 		igmp_group_added(pmc);
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 /*
@@ -1468,19 +1483,20 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 {
 	struct ip_mc_list *i;
 
-	ASSERT_RTNL();
-
 	/* Deactivate timers */
 	ip_mc_down(in_dev);
 
-	while ((i = rtnl_dereference(in_dev->mc_list)) != NULL) {
-		in_dev->mc_list = i->next_rcu;
+	spin_lock(&ipv4_sk_mc_lock);
+	while ((i = rcu_dereference_protected(in_dev->mc_list,
+			lockdep_is_held(&ipv4_sk_mc_lock))) != NULL) {
+		rcu_assign_pointer(in_dev->mc_list, i->next_rcu);
 		in_dev->mc_count--;
 
 		/* We've dropped the groups in ip_mc_down already */
 		ip_mc_clear_src(i);
 		ip_ma_put(i);
 	}
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 /* RTNL is locked */
@@ -1510,7 +1526,7 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 	}
 	if (dev) {
 		imr->imr_ifindex = dev->ifindex;
-		idev = __in_dev_get_rtnl(dev);
+		idev = __in_dev_get_rcu(dev);
 	}
 	return idev;
 }
@@ -1844,10 +1860,8 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
+	rcu_read_lock();
 	in_dev = ip_mc_find_dev(net, imr);
-
 	if (!in_dev) {
 		iml = NULL;
 		err = -ENODEV;
@@ -1856,28 +1870,31 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 
 	err = -EADDRINUSE;
 	ifindex = imr->imr_ifindex;
-	for_each_pmc_rtnl(inet, i) {
+	for_each_pmc_rcu(inet, i) {
 		if (i->multi.imr_multiaddr.s_addr == addr &&
 		    i->multi.imr_ifindex == ifindex)
 			goto done;
 		count++;
 	}
-	err = -ENOBUFS;
+	rcu_read_unlock();
 	if (count >= sysctl_igmp_max_memberships)
-		goto done;
+		return -ENOBUFS;
 	iml = sock_kmalloc(sk, sizeof(*iml), GFP_KERNEL);
 	if (iml == NULL)
-		goto done;
+		return -ENOBUFS;
 
 	memcpy(&iml->multi, imr, sizeof(*imr));
 	iml->next_rcu = inet->mc_list;
 	iml->sflist = NULL;
 	iml->sfmode = MCAST_EXCLUDE;
+
+	spin_lock(&ipv4_sk_mc_lock);
 	rcu_assign_pointer(inet->mc_list, iml);
+	spin_unlock(&ipv4_sk_mc_lock);
 	ip_mc_inc_group(in_dev, addr);
-	err = 0;
+	return 0;
 done:
-	rtnl_unlock();
+	rcu_read_unlock();
 	return err;
 }
 EXPORT_SYMBOL(ip_mc_join_group);
@@ -1885,7 +1902,8 @@ EXPORT_SYMBOL(ip_mc_join_group);
 static void ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 			    struct in_device *in_dev)
 {
-	struct ip_sf_socklist *psf = rtnl_dereference(iml->sflist);
+	struct ip_sf_socklist *psf = rcu_dereference_protected(iml->sflist,
+					lockdep_is_held(&ipv4_sk_mc_lock));
 
 	if (psf == NULL) {
 		/* any-source empty exclude case */
@@ -1916,11 +1934,14 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	rtnl_lock();
+	rcu_read_lock();
 	in_dev = ip_mc_find_dev(net, imr);
 	ifindex = imr->imr_ifindex;
+
+	spin_lock(&ipv4_sk_mc_lock);
 	for (imlp = &inet->mc_list;
-	     (iml = rtnl_dereference(*imlp)) != NULL;
+	     (iml = rcu_dereference_protected(*imlp,
+		    lockdep_is_held(&ipv4_sk_mc_lock))) != NULL;
 	     imlp = &iml->next_rcu) {
 		if (iml->multi.imr_multiaddr.s_addr != group)
 			continue;
@@ -1936,8 +1957,9 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 		*imlp = iml->next_rcu;
 
 		if (in_dev)
-			ip_mc_dec_group(in_dev, group);
-		rtnl_unlock();
+			__ip_mc_dec_group(in_dev, group);
+		spin_unlock(&ipv4_sk_mc_lock);
+		rcu_read_unlock();
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
 		kfree_rcu(iml, rcu);
@@ -1946,7 +1968,8 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 	if (!in_dev)
 		ret = -ENODEV;
-	rtnl_unlock();
+	spin_unlock(&ipv4_sk_mc_lock);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(ip_mc_leave_group);
@@ -1968,20 +1991,20 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
+	rcu_read_lock();
 
 	imr.imr_multiaddr.s_addr = mreqs->imr_multiaddr;
 	imr.imr_address.s_addr = mreqs->imr_interface;
 	imr.imr_ifindex = ifindex;
-	in_dev = ip_mc_find_dev(net, &imr);
 
+	in_dev = ip_mc_find_dev(net, &imr);
 	if (!in_dev) {
 		err = -ENODEV;
 		goto done;
 	}
-	err = -EADDRNOTAVAIL;
 
-	for_each_pmc_rtnl(inet, pmc) {
+	err = -EADDRNOTAVAIL;
+	for_each_pmc_rcu(inet, pmc) {
 		if ((pmc->multi.imr_multiaddr.s_addr ==
 		     imr.imr_multiaddr.s_addr) &&
 		    (pmc->multi.imr_ifindex == imr.imr_ifindex))
@@ -2005,7 +2028,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 		pmc->sfmode = omode;
 	}
 
-	psl = rtnl_dereference(pmc->sflist);
+	psl = rcu_dereference(pmc->sflist);
 	if (!add) {
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
@@ -2047,7 +2070,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 
 		if (psl)
 			count += psl->sl_max;
-		newpsl = sock_kmalloc(sk, IP_SFLSIZE(count), GFP_KERNEL);
+		newpsl = sock_kmalloc(sk, IP_SFLSIZE(count), GFP_ATOMIC);
 		if (!newpsl) {
 			err = -ENOBUFS;
 			goto done;
@@ -2059,10 +2082,15 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			/* decrease mem now to avoid the memleak warning */
 			atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
+			rcu_read_unlock();
 			kfree_rcu(psl, rcu);
-		}
+		} else
+			rcu_read_unlock();
+		spin_lock(&ipv4_sk_mc_lock);
 		rcu_assign_pointer(pmc->sflist, newpsl);
 		psl = newpsl;
+		spin_unlock(&ipv4_sk_mc_lock);
+		rcu_read_lock();
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
 	for (i=0; i<psl->sl_count; i++) {
@@ -2082,7 +2110,7 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	ip_mc_add_src(in_dev, &mreqs->imr_multiaddr, omode, 1,
 		      &mreqs->imr_sourceaddr, 1);
 done:
-	rtnl_unlock();
+	rcu_read_unlock();
 	if (leavegroup)
 		return ip_mc_leave_group(sk, &imr);
 	return err;
@@ -2106,11 +2134,11 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = ifindex;
+
+	rcu_read_lock();
 	in_dev = ip_mc_find_dev(net, &imr);
 
 	if (!in_dev) {
@@ -2124,7 +2152,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 		goto done;
 	}
 
-	for_each_pmc_rtnl(inet, pmc) {
+	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == msf->imsf_multiaddr &&
 		    pmc->multi.imr_ifindex == imr.imr_ifindex)
 			break;
@@ -2135,7 +2163,7 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	}
 	if (msf->imsf_numsrc) {
 		newpsl = sock_kmalloc(sk, IP_SFLSIZE(msf->imsf_numsrc),
-							   GFP_KERNEL);
+							   GFP_ATOMIC);
 		if (!newpsl) {
 			err = -ENOBUFS;
 			goto done;
@@ -2154,21 +2182,29 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 		ip_mc_add_src(in_dev, &msf->imsf_multiaddr,
 			      msf->imsf_fmode, 0, NULL, 0);
 	}
-	psl = rtnl_dereference(pmc->sflist);
+	psl = rcu_dereference(pmc->sflist);
 	if (psl) {
 		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			      psl->sl_count, psl->sl_addr, 0);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(IP_SFLSIZE(psl->sl_max), &sk->sk_omem_alloc);
+		rcu_read_unlock();
 		kfree_rcu(psl, rcu);
-	} else
+	} else {
 		ip_mc_del_src(in_dev, &msf->imsf_multiaddr, pmc->sfmode,
 			      0, NULL, 0);
+		rcu_read_unlock();
+	}
+
+	spin_lock(&ipv4_sk_mc_lock);
 	rcu_assign_pointer(pmc->sflist, newpsl);
 	pmc->sfmode = msf->imsf_fmode;
+	spin_unlock(&ipv4_sk_mc_lock);
 	err = 0;
+	goto out;
 done:
-	rtnl_unlock();
+	rcu_read_unlock();
+out:
 	if (leavegroup)
 		err = ip_mc_leave_group(sk, &imr);
 	return err;
@@ -2189,20 +2225,18 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = 0;
-	in_dev = ip_mc_find_dev(net, &imr);
 
+	rcu_read_lock();
+	in_dev = ip_mc_find_dev(net, &imr);
 	if (!in_dev) {
 		err = -ENODEV;
 		goto done;
 	}
 	err = -EADDRNOTAVAIL;
-
-	for_each_pmc_rtnl(inet, pmc) {
+	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == msf->imsf_multiaddr &&
 		    pmc->multi.imr_ifindex == imr.imr_ifindex)
 			break;
@@ -2210,8 +2244,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	if (!pmc)		/* must have a prior join */
 		goto done;
 	msf->imsf_fmode = pmc->sfmode;
-	psl = rtnl_dereference(pmc->sflist);
-	rtnl_unlock();
+	psl = rcu_dereference(pmc->sflist);
 	if (!psl) {
 		len = 0;
 		count = 0;
@@ -2221,6 +2254,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	copycount = count < msf->imsf_numsrc ? count : msf->imsf_numsrc;
 	len = copycount * sizeof(psl->sl_addr[0]);
 	msf->imsf_numsrc = count;
+	rcu_read_unlock();
 	if (put_user(IP_MSFILTER_SIZE(copycount), optlen) ||
 	    copy_to_user(optval, msf, IP_MSFILTER_SIZE(0))) {
 		return -EFAULT;
@@ -2230,7 +2264,7 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		return -EFAULT;
 	return 0;
 done:
-	rtnl_unlock();
+	rcu_read_unlock();
 	return err;
 }
 
@@ -2251,11 +2285,10 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	err = -EADDRNOTAVAIL;
 
-	for_each_pmc_rtnl(inet, pmc) {
+	rcu_read_lock();
+	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == addr &&
 		    pmc->multi.imr_ifindex == gsf->gf_interface)
 			break;
@@ -2263,11 +2296,11 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!pmc)		/* must have a prior join */
 		goto done;
 	gsf->gf_fmode = pmc->sfmode;
-	psl = rtnl_dereference(pmc->sflist);
-	rtnl_unlock();
+	psl = rcu_dereference(pmc->sflist);
 	count = psl ? psl->sl_count : 0;
 	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
 	gsf->gf_numsrc = count;
+	rcu_read_unlock();
 	if (put_user(GROUP_FILTER_SIZE(copycount), optlen) ||
 	    copy_to_user(optval, gsf, GROUP_FILTER_SIZE(0))) {
 		return -EFAULT;
@@ -2284,7 +2317,7 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	}
 	return 0;
 done:
-	rtnl_unlock();
+	rcu_read_unlock();
 	return err;
 }
 
@@ -2343,23 +2376,24 @@ void ip_mc_drop_socket(struct sock *sk)
 	struct ip_mc_socklist *iml;
 	struct net *net = sock_net(sk);
 
-	if (inet->mc_list == NULL)
+	if (rcu_access_pointer(inet->mc_list) == NULL)
 		return;
 
-	rtnl_lock();
-	while ((iml = rtnl_dereference(inet->mc_list)) != NULL) {
+	spin_lock(&ipv4_sk_mc_lock);
+	while ((iml = rcu_dereference_protected(inet->mc_list,
+			lockdep_is_held(&ipv4_sk_mc_lock))) != NULL) {
 		struct in_device *in_dev;
 
-		inet->mc_list = iml->next_rcu;
+		rcu_assign_pointer(inet->mc_list, iml->next_rcu);
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
 		ip_mc_leave_src(sk, iml, in_dev);
 		if (in_dev != NULL)
-			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
+			__ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
 		kfree_rcu(iml, rcu);
 	}
-	rtnl_unlock();
+	spin_unlock(&ipv4_sk_mc_lock);
 }
 
 /* called with rcu_read_lock() */
-- 
1.7.7.6
