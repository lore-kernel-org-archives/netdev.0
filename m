From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.25 2/2][NETNS] net: Add a helper function neigh_param_default_alloc
Date: Fri, 21 Dec 2007 14:59:24 +0100
Message-ID: <20071221144541.263607661@ICON-9-164-138-215.megacenter.de.ibm.com>
References: <20071221135922.726347008@ICON-9-164-138-215.megacenter.de.ibm.com>
Cc: netdev@vger.kernel.org, den@openvz.org, benjamin.thery@bull.net,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:28006 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbXLUOvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:51:54 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBLEpoSo233694
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:50 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBLEpo8V5042236
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:50 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBLEphYM024906
	for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 14:51:44 GMT
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
@@ -1325,6 +1325,20 @@ struct neigh_parms *neigh_parms_alloc(st
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
@@ -2787,6 +2801,7 @@ EXPORT_SYMBOL(neigh_ifdown);
 EXPORT_SYMBOL(neigh_lookup);
 EXPORT_SYMBOL(neigh_lookup_nodev);
 EXPORT_SYMBOL(neigh_parms_alloc);
+EXPORT_SYMBOL(neigh_parms_alloc_default);
 EXPORT_SYMBOL(neigh_parms_release);
 EXPORT_SYMBOL(neigh_rand_reach_time);
 EXPORT_SYMBOL(neigh_resolve_output);

-- 
