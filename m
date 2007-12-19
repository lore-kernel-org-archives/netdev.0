From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/2][NETNS] net: Add a helper function neigh_param_default_alloc
Date: Wed, 19 Dec 2007 15:55:46 +0100
Message-ID: <20071219145846.105708749@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071219145544.184198087@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:14707 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192AbXLSPEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 10:04:10 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id lBJF4AjX018466
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 15:04:10 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBJF49jw2728134
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:04:09 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBJF484d024567
	for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 16:04:09 +0100
Content-Disposition: inline; filename=0002-net-Add-a-helper-function-neigh_param_default_alloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the presence of multiple network namespaces the logic needed
to allocate the a default parameter table is just barely non-trivial.
So add a function to automate it to make everyone's life easier.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/net/neighbour.h |    1 +
 net/core/neighbour.c    |   15 +++++++++++++++
 2 files changed, 16 insertions(+)

Index: net-2.6.25/include/net/neighbour.h
===================================================================
--- net-2.6.25.orig/include/net/neighbour.h
+++ net-2.6.25/include/net/neighbour.h
@@ -208,6 +208,7 @@ extern struct neighbour 	*neigh_event_ns
 						struct net_device *dev);
 
 extern struct neigh_parms	*neigh_parms_alloc(struct net_device *dev, struct neigh_table *tbl);
+extern struct neigh_parms	*neigh_parms_alloc_default(struct neigh_table *tbl, struct net *net);
 extern void			neigh_parms_release(struct neigh_table *tbl, struct neigh_parms *parms);
 extern void			neigh_parms_destroy(struct neigh_parms *parms);
 extern unsigned long		neigh_rand_reach_time(unsigned long base);
Index: net-2.6.25/net/core/neighbour.c
===================================================================
--- net-2.6.25.orig/net/core/neighbour.c
+++ net-2.6.25/net/core/neighbour.c
@@ -1327,6 +1327,20 @@ struct neigh_parms *neigh_parms_alloc(st
 	return p;
 }
 
+struct neigh_parms *neigh_parms_alloc_default(struct neigh_table *tbl,
+						struct net *net)
+{
+	struct neigh_parms *parms;
+	if (net != &init_net) {
+		parms = neigh_parms_alloc(NULL, tbl);
+		release_net(parms->net);
+		parms->net = hold_net(net);
+	}
+	else
+		parms = neigh_parms_clone(&tbl->parms);
+	return parms;
+}
+
 static void neigh_rcu_free_parms(struct rcu_head *head)
 {
 	struct neigh_parms *parms =
@@ -2789,6 +2803,7 @@ EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
 EXPORT_SYMBOL(neigh_lookup_nodev);
 EXPORT_SYMBOL(neigh_parms_alloc);
+EXPORT_SYMBOL(neigh_parms_alloc_default);
 EXPORT_SYMBOL(neigh_parms_release);
 EXPORT_SYMBOL(neigh_rand_reach_time);
 EXPORT_SYMBOL(neigh_resolve_output);

-- 
