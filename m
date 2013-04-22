From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v3 net-next] bridge: Add fdb dst check during fdb update
Date: Mon, 22 Apr 2013 15:56:49 -0700
Message-ID: <20130422155649.2e4aebcf@nehalam.linuxnetplumber.net>
References: <1365968593-28725-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	nolan@cumulusnetworks.com, shm@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:55363 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab3DVW4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 18:56:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id v10so260pde.18
        for <netdev@vger.kernel.org>; Mon, 22 Apr 2013 15:56:54 -0700 (PDT)
In-Reply-To: <1365968593-28725-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes a real oversight in the forwarding database management stuff.

A couple of minor tweaks.
 1. Always update used value but don't change 'updated' value unless changed.
 2. Rename notify flag to modified
 3. Add some whitespace.


From: roopa <roopa@cumulusnetworks.com>

Current bridge fdb update code does not seem to update the port
during fdb update. This patch adds a check for fdb dst (port)
change during fdb update. Also rearranges the call to
fdb_notify to send only one notification for create and update.

Changelog:
v2 - Change notify flag to bool

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/bridge/br_fdb.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

--- a/net/bridge/br_fdb.c	2013-03-28 14:26:20.746064670 -0700
+++ b/net/bridge/br_fdb.c	2013-04-22 15:52:24.183494631 -0700
@@ -615,6 +615,7 @@ static int fdb_add_entry(struct net_brid
 	struct net_bridge *br = source->br;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
 	struct net_bridge_fdb_entry *fdb;
+	bool modified = false;
 
 	fdb = fdb_find(head, addr, vid);
 	if (fdb == NULL) {
@@ -624,10 +625,16 @@ static int fdb_add_entry(struct net_brid
 		fdb = fdb_create(head, source, addr, vid);
 		if (!fdb)
 			return -ENOMEM;
-		fdb_notify(br, fdb, RTM_NEWNEIGH);
+
+		modified = true;
 	} else {
 		if (flags & NLM_F_EXCL)
 			return -EEXIST;
+
+		if (fdb->dst != source) {
+			fdb->dst = source;
+			modified = true;
+		}
 	}
 
 	if (fdb_to_nud(fdb) != state) {
@@ -639,7 +646,12 @@ static int fdb_add_entry(struct net_brid
 		} else
 			fdb->is_local = fdb->is_static = 0;
 
-		fdb->updated = fdb->used = jiffies;
+		modified = true;
+	}
+
+	fdb->used = jiffies;
+	if (modified) {
+		fdb->updated = jiffies;
 		fdb_notify(br, fdb, RTM_NEWNEIGH);
 	}
 
