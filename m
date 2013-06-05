From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v1 1/3] igmp: avoid taking RTNL for ip_mc_find_dev()
Date: Wed,  5 Jun 2013 11:33:29 +0800
Message-ID: <1370403211-6851-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307Ab3FEDdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 23:33:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

RCU is enough to protect ip_mc_find_dev().

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/ipv4/igmp.c |   48 ++++++++++++++++++------------------------------
 1 files changed, 18 insertions(+), 30 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 450f625..d3218c0 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1433,7 +1433,6 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 	}
 }
 
-/* RTNL is locked */
 static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
 	struct net_device *dev = NULL;
@@ -1459,8 +1458,10 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 		}
 	}
 	if (dev) {
+		rcu_read_lock();
 		imr->imr_ifindex = dev->ifindex;
-		idev = __in_dev_get_rtnl(dev);
+		idev = __in_dev_get_rcu(dev);
+		rcu_read_unlock();
 	}
 	return idev;
 }
@@ -1799,17 +1800,13 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	in_dev = ip_mc_find_dev(net, imr);
-
-	if (!in_dev) {
-		iml = NULL;
-		err = -ENODEV;
-		goto done;
-	}
+	if (!in_dev)
+		return -ENODEV;
 
 	err = -EADDRINUSE;
+
+	rtnl_lock();
 	ifindex = imr->imr_ifindex;
 	for_each_pmc_rtnl(inet, i) {
 		if (i->multi.imr_multiaddr.s_addr == addr &&
@@ -1872,8 +1869,8 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	rtnl_lock();
 	in_dev = ip_mc_find_dev(net, imr);
+	rtnl_lock();
 	ifindex = imr->imr_ifindex;
 	for (imlp = &inet->mc_list;
 	     (iml = rtnl_dereference(*imlp)) != NULL;
@@ -1923,18 +1920,16 @@ int ip_mc_source(int add, int omode, struct sock *sk, struct
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = mreqs->imr_multiaddr;
 	imr.imr_address.s_addr = mreqs->imr_interface;
 	imr.imr_ifindex = ifindex;
 	in_dev = ip_mc_find_dev(net, &imr);
 
-	if (!in_dev) {
-		err = -ENODEV;
-		goto done;
-	}
+	if (!in_dev)
+		return -ENODEV;
+
 	err = -EADDRNOTAVAIL;
+	rtnl_lock();
 
 	for_each_pmc_rtnl(inet, pmc) {
 		if ((pmc->multi.imr_multiaddr.s_addr ==
@@ -2061,18 +2056,14 @@ int ip_mc_msfilter(struct sock *sk, struct ip_msfilter *msf, int ifindex)
 	    msf->imsf_fmode != MCAST_EXCLUDE)
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = ifindex;
 	in_dev = ip_mc_find_dev(net, &imr);
+	if (!in_dev)
+		return -ENODEV;
 
-	if (!in_dev) {
-		err = -ENODEV;
-		goto done;
-	}
-
+	rtnl_lock();
 	/* special case - (INCLUDE, empty) == LEAVE_GROUP */
 	if (msf->imsf_fmode == MCAST_INCLUDE && msf->imsf_numsrc == 0) {
 		leavegroup = 1;
@@ -2144,18 +2135,15 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = 0;
 	in_dev = ip_mc_find_dev(net, &imr);
+	if (!in_dev)
+		return -ENODEV;
 
-	if (!in_dev) {
-		err = -ENODEV;
-		goto done;
-	}
 	err = -EADDRNOTAVAIL;
+	rtnl_lock();
 
 	for_each_pmc_rtnl(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == msf->imsf_multiaddr &&
-- 
1.7.7.6
