From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: Add fdb dst check during fdb update
Date: Sat, 13 Apr 2013 21:58:49 -0700
Message-ID: <1365915529-8317-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nolan@cumulusnetworks.com, shm@cumulusnetworks.com,
	wkok@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:47037 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791Ab3DNFHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 01:07:06 -0400
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>

Current bridge fdb update code does not seem to update the port
during fdb update. This patch adds a check for fdb dst (port)
change during fdb update. Also rearranges the call to
fdb_notify to send only one notification for create and update.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_fdb.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index c581f12..7a7d920 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -615,6 +615,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 	struct net_bridge *br = source->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
+	int notify = 0;
 
 	fdb = fdb_find(head, addr, vid);
 	if (fdb == NULL) {
@@ -624,7 +625,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 		fdb = fdb_create(head, source, addr, vid);
 		if (!fdb)
 			return -ENOMEM;
-		fdb_notify(br, fdb, RTM_NEWNEIGH);
+		notify = 1;
 	} else {
 		if (flags & NLM_F_EXCL)
 			return -EEXIST;
@@ -638,7 +639,15 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 			fdb->is_static = 1;
 		} else
 			fdb->is_local = fdb->is_static = 0;
+		notify = 1;
+	}
+
+	if (fdb->dst != source) {
+		fdb->dst = source;
+		notify = 1;
+	}
 
+	if (notify) {
 		fdb->updated = fdb->used = jiffies;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	}
-- 
1.7.10.4
