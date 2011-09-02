From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] bridge: set flags in RTM_NEWNEIGH message correctly
Date: Fri, 02 Sep 2011 10:22:22 -0700
Message-ID: <20110902172247.481785452@vyatta.com>
References: <20110902172220.830228928@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:48253 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753867Ab1IBRe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 13:34:28 -0400
Content-Disposition: inline; filename=bridge-newneigh-state.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functionality for notification was added with 3.0. kernel
but bridge would always send new neighbour message with state == 0.
The problem is that the notify needs to be done after
the flags on ther forwarding engry are set.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---

--- a/net/bridge/br_fdb.c	2011-08-26 09:41:25.966304883 -0700
+++ b/net/bridge/br_fdb.c	2011-09-01 17:21:43.755481630 -0700
@@ -347,7 +347,6 @@ static struct net_bridge_fdb_entry *fdb_
 		fdb->is_static = 0;
 		fdb->updated = fdb->used = jiffies;
 		hlist_add_head_rcu(&fdb->hlist, head);
-		fdb_notify(fdb, RTM_NEWNEIGH);
 	}
 	return fdb;
 }
@@ -379,6 +378,7 @@ static int fdb_insert(struct net_bridge
 		return -ENOMEM;
 
 	fdb->is_local = fdb->is_static = 1;
+	fdb_notify(fdb, RTM_NEWNEIGH);
 	return 0;
 }
 
@@ -424,8 +424,11 @@ void br_fdb_update(struct net_bridge *br
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (likely(!fdb_find(head, addr)))
-			fdb_create(head, source, addr);
+		if (!fdb_find(head, addr)) {
+			fdb = fdb_create(head, source, addr);
+			if (fdb)
+				fdb_notify(fdb, RTM_NEWNEIGH);
+		}
 
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
@@ -576,6 +579,8 @@ static int fdb_add_entry(struct net_brid
 		fdb->is_local = fdb->is_static = 1;
 	else if (state & NUD_NOARP)
 		fdb->is_static = 1;
+
+	fdb_notify(fdb, RTM_NEWNEIGH);
 	return 0;
 }
 
