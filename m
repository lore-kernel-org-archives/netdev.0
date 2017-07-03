From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: allow ext learned entries to change ports
Date: Mon,  3 Jul 2017 15:14:59 -0700
Message-ID: <1499120099-46428-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        jiri@resnulli.us, idosch@mellanox.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34854 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752674AbdGCWPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 18:15:04 -0400
Received: by mail-pg0-f46.google.com with SMTP id j186so100554900pge.2
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2017 15:15:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

current code silently ignores change of port in the request
message. This patch makes sure the port is modified and
notification is sent to userspace.

Fixes: cf6b8e1eedff ("bridge: add API to notify bridge driver of learned FBD on offloaded device")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index fef7872..a5e4a73 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -1079,8 +1079,9 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 			      const unsigned char *addr, u16 vid)
 {
-	struct hlist_head *head;
 	struct net_bridge_fdb_entry *fdb;
+	struct hlist_head *head;
+	bool modified = false;
 	int err = 0;
 
 	spin_lock_bh(&br->hash_lock);
@@ -1095,14 +1096,25 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
 		}
 		fdb->added_by_external_learn = 1;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
-	} else if (fdb->added_by_external_learn) {
-		/* Refresh entry */
-		fdb->updated = fdb->used = jiffies;
-	} else if (!fdb->added_by_user) {
-		/* Take over SW learned entry */
-		fdb->added_by_external_learn = 1;
+	} else {
 		fdb->updated = jiffies;
-		fdb_notify(br, fdb, RTM_NEWNEIGH);
+
+		if (fdb->dst != p) {
+			fdb->dst = p;
+			modified = true;
+		}
+
+		if (fdb->added_by_external_learn) {
+			/* Refresh entry */
+			fdb->used = jiffies;
+		} else if (!fdb->added_by_user) {
+			/* Take over SW learned entry */
+			fdb->added_by_external_learn = 1;
+			modified = true;
+		}
+
+		if (modified)
+			fdb_notify(br, fdb, RTM_NEWNEIGH);
 	}
 
 err_unlock:
-- 
1.9.1
