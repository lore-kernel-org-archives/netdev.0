From: Flavio Leitner <fleitner@redhat.com>
Subject: [PATCH] igmp: fix ip_mc_sf_allow race
Date: Wed, 30 Dec 2009 12:23:25 -0200
Message-ID: <1262183005-28406-1-git-send-email-fleitner@redhat.com>
Cc: Flavio Leitner <fleitner@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50759 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751529AbZL3OXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2009 09:23:41 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBUENfBt001152
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 30 Dec 2009 09:23:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Almost all igmp functions accessing inet->mc_list are protected by
rtnl_lock(), but there is one exception which is ip_mc_sf_allow(),
so there is a chance of either ip_mc_drop_socket or ip_mc_leave_group
remove an entry while ip_mc_sf_allow is running causing a crash.

Signed-off-by: Flavio Leitner <fleitner@redhat.com>
---
 net/ipv4/igmp.c |   56 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 44 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 76c0840..d1e2a0c 100644
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
@@ -1854,11 +1854,12 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 
 		(void) ip_mc_leave_src(sk, iml, in_dev);
 
-		*imlp = iml->next;
+		rcu_assign_pointer(*imlp, iml->next);
 
 		if (in_dev)
 			ip_mc_dec_group(in_dev, group);
 		rtnl_unlock();
+		synchronize_rcu();
 		sock_kfree_s(sk, iml, sizeof(*iml));
 		return 0;
 	}
@@ -2209,30 +2210,40 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
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
@@ -2243,15 +2254,21 @@ void ip_mc_drop_socket(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
+	struct ip_mc_socklist *rmlist;
 	struct net *net = sock_net(sk);
 
-	if (inet->mc_list == NULL)
+	rcu_read_lock();
+	if (rcu_dereference(inet->mc_list) == NULL) {
+		rcu_read_unlock();
 		return;
+	}
+	rcu_read_unlock();
 
 	rtnl_lock();
+	rmlist = NULL;
 	while ((iml = inet->mc_list) != NULL) {
 		struct in_device *in_dev;
-		inet->mc_list = iml->next;
+		rcu_assign_pointer(inet->mc_list, iml->next);
 
 		in_dev = inetdev_by_index(net, iml->multi.imr_ifindex);
 		(void) ip_mc_leave_src(sk, iml, in_dev);
@@ -2259,9 +2276,24 @@ void ip_mc_drop_socket(struct sock *sk)
 			ip_mc_dec_group(in_dev, iml->multi.imr_multiaddr.s_addr);
 			in_dev_put(in_dev);
 		}
-		sock_kfree_s(sk, iml, sizeof(*iml));
+		if (rmlist == NULL)  {
+			iml->next = NULL;
+			rmlist = iml;
+		}
+		else {
+			iml->next = rmlist->next;
+			rmlist->next = iml;
+		}
 	}
 	rtnl_unlock();
+
+	synchronize_rcu();
+
+	while (rmlist != NULL) {
+		iml = rmlist;
+		rmlist = iml->next;
+		sock_kfree_s(sk, iml, sizeof(*iml));
+	}
 }
 
 int ip_check_mc(struct in_device *in_dev, __be32 mc_addr, __be32 src_addr, u16 proto)
-- 
1.6.5.2

