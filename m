From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/6][NETNS][IPV6] ndisc - make ndisc handle multiple network namespaces
Date: Fri, 07 Mar 2008 16:26:40 +0100
Message-ID: <20080307152938.830429876@mai.toulouse-stg.fr.ibm.com>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:28338 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759894AbYCGPaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 10:30:10 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m27FU99B179696
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 15:30:09 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27FU9Lu2023656
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:09 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27FU8Po019151
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2008 16:30:08 +0100
Content-Disposition: inline; filename=ndisc-make-ndisc-handle-multiple-network-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ndisc handle multiple network namespaces: 
Remove references to init_net, add network namespace parameters and add 
pernet_operations for ndisc

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ndisc.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -541,7 +541,7 @@ static void ndisc_send_na(struct net_dev
 	};
 
 	/* for anycast or proxy, solicited_addr != src_addr */
-	ifp = ipv6_get_ifaddr(&init_net, solicited_addr, dev, 1);
+	ifp = ipv6_get_ifaddr(dev->nd_net, solicited_addr, dev, 1);
 	if (ifp) {
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
@@ -601,7 +601,7 @@ void ndisc_send_rs(struct net_device *de
 	 * suppress the inclusion of the sllao.
 	 */
 	if (send_sllao) {
-		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(&init_net, saddr,
+		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(dev->nd_net, saddr,
 							   dev, 1);
 		if (ifp) {
 			if (ifp->flags & IFA_F_OPTIMISTIC)  {
@@ -639,7 +639,7 @@ static void ndisc_solicit(struct neighbo
 	struct in6_addr *target = (struct in6_addr *)&neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 
-	if (skb && ipv6_chk_addr(&init_net, &ipv6_hdr(skb)->saddr, dev, 1))
+	if (skb && ipv6_chk_addr(dev->nd_net, &ipv6_hdr(skb)->saddr, dev, 1))
 		saddr = &ipv6_hdr(skb)->saddr;
 
 	if ((probes -= neigh->parms->ucast_probes) < 0) {
@@ -727,7 +727,8 @@ static void ndisc_recv_ns(struct sk_buff
 
 	inc = ipv6_addr_is_multicast(daddr);
 
-	if ((ifp = ipv6_get_ifaddr(&init_net, &msg->target, dev, 1)) != NULL) {
+	ifp = ipv6_get_ifaddr(dev->nd_net, &msg->target, dev, 1);
+	if (ifp) {
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
@@ -775,7 +776,7 @@ static void ndisc_recv_ns(struct sk_buff
 		if (ipv6_chk_acast_addr(dev, &msg->target) ||
 		    (idev->cnf.forwarding &&
 		     (ipv6_devconf.proxy_ndp || idev->cnf.proxy_ndp) &&
-		     (pneigh = pneigh_lookup(&nd_tbl, &init_net,
+		     (pneigh = pneigh_lookup(&nd_tbl, dev->nd_net,
 					     &msg->target, dev, 0)) != NULL)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
@@ -885,7 +886,8 @@ static void ndisc_recv_na(struct sk_buff
 			return;
 		}
 	}
-	if ((ifp = ipv6_get_ifaddr(&init_net, &msg->target, dev, 1))) {
+	ifp = ipv6_get_ifaddr(dev->nd_net, &msg->target, dev, 1);
+	if (ifp) {
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			addrconf_dad_failure(ifp);
 			return;
@@ -916,7 +918,7 @@ static void ndisc_recv_na(struct sk_buff
 		 */
 		if (lladdr && !memcmp(lladdr, dev->dev_addr, dev->addr_len) &&
 		    ipv6_devconf.forwarding && ipv6_devconf.proxy_ndp &&
-		    pneigh_lookup(&nd_tbl, &init_net, &msg->target, dev, 0)) {
+		    pneigh_lookup(&nd_tbl, dev->nd_net, &msg->target, dev, 0)) {
 			/* XXX: idev->cnf.prixy_ndp */
 			goto out;
 		}
@@ -1006,6 +1008,7 @@ static void ndisc_ra_useropt(struct sk_b
 	struct sk_buff *skb;
 	struct nlmsghdr *nlh;
 	struct nduseroptmsg *ndmsg;
+	struct net *net = ra->dev->nd_net;
 	int err;
 	int base_size = NLMSG_ALIGN(sizeof(struct nduseroptmsg)
 				    + (opt->nd_opt_len << 3));
@@ -1035,7 +1038,7 @@ static void ndisc_ra_useropt(struct sk_b
 		&ipv6_hdr(ra)->saddr);
 	nlmsg_end(skb, nlh);
 
-	err = rtnl_notify(skb, &init_net, 0, RTNLGRP_ND_USEROPT, NULL,
+	err = rtnl_notify(skb, net, 0, RTNLGRP_ND_USEROPT, NULL,
 			  GFP_ATOMIC);
 	if (err < 0)
 		goto errout;
@@ -1046,7 +1049,7 @@ nla_put_failure:
 	nlmsg_free(skb);
 	err = -EMSGSIZE;
 errout:
-	rtnl_set_sk_err(&init_net, RTNLGRP_ND_USEROPT, err);
+	rtnl_set_sk_err(net, RTNLGRP_ND_USEROPT, err);
 }
 
 static void ndisc_router_discovery(struct sk_buff *skb)
@@ -1600,9 +1603,6 @@ static int ndisc_netdev_event(struct not
 	struct net_device *dev = ptr;
 	struct net *net = dev->nd_net;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);

-- 
