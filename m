From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/3] bridge: refactor fdb_notify
Date: Tue, 06 Dec 2011 15:02:24 -0800
Message-ID: <20111206230315.904534660@vyatta.com>
References: <20111206230223.191544130@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sfca-50.vyatta.com ([76.74.103.50]:49454 "EHLO fiji.vyatta.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753568Ab1LFXFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 18:05:47 -0500
Content-Disposition: inline; filename=br-local-notify.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move fdb_notify outside of fdb_create. This fixes the problem
that notification of local entries are not flagged correctly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_fdb.c	2011-12-06 14:58:24.122561721 -0800
+++ b/net/bridge/br_fdb.c	2011-12-06 15:01:23.656521166 -0800
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
 
@@ -424,9 +424,11 @@ void br_fdb_update(struct net_bridge *br
 		}
 	} else {
 		spin_lock(&br->hash_lock);
-		if (likely(!fdb_find(head, addr)))
-			fdb_create(head, source, addr);
-
+		if (likely(!fdb_find(head, addr))) {
+			fdb = fdb_create(head, source, addr);
+			if (fdb)
+				fdb_notify(fdb, RTM_NEWNEIGH);
+		}
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
 		 */
@@ -572,6 +574,7 @@ static int fdb_add_entry(struct net_brid
 		fdb = fdb_create(head, source, addr);
 		if (!fdb)
 			return -ENOMEM;
+		fdb_notify(fdb, RTM_NEWNEIGH);
 	} else {
 		if (flags & NLM_F_EXCL)
 			return -EEXIST;
