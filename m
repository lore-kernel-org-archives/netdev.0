From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: use _bh spinlock variant for br_fdb_update to avoid lockup
Date: Fri,  5 Jun 2015 00:52:57 -0700
Message-ID: <1433490777-22880-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:36696 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbbFEHxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 03:53:05 -0400
Received: by qgep100 with SMTP id p100so25938935qge.3
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 00:53:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

br_fdb_update() can be called in process context in the following way:
br_fdb_add() -> __br_fdb_add() -> br_fdb_update() (if NTF_USE flag is set)
so we need to use spin_lock_bh because there are softirq users of the
hash_lock. One easy way to reproduce this is to modify the bridge utility
to set NTF_USE, enable stp and then set maxageing to a low value so
br_fdb_cleanup() is called frequently and then just add new entries in
a loop. This happens because br_fdb_cleanup() is called from timer/softirq
context. These locks were _bh before commit f8ae737deea1
("[BRIDGE]: forwarding remove unneeded preempt and bh diasables")
and at the time that commit was correct because br_fdb_update() couldn't be
called from process context, but that changed after commit:
292d1398983f ("bridge: add NTF_USE support")

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: 292d1398983f ("bridge: add NTF_USE support")
---
Nik: Something that just occurred - we can disable softirqs around the call
     to br_fdb_update() in br_fdb_add() so we can keep the optimization.
     What do you think ?

 net/bridge/br_fdb.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 7896cf143045..523d329a5bd1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -569,7 +569,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
 	} else {
-		spin_lock(&br->hash_lock);
+		spin_lock_bh(&br->hash_lock);
 		if (likely(!fdb_find(head, addr, vid))) {
 			fdb = fdb_create(head, source, addr, vid);
 			if (fdb) {
@@ -581,7 +581,7 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 		/* else  we lose race and someone else inserts
 		 * it first, don't bother updating
 		 */
-		spin_unlock(&br->hash_lock);
+		spin_unlock_bh(&br->hash_lock);
 	}
 }
 
-- 
1.7.10.4
