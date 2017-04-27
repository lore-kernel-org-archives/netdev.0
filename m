From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next] net: bridge: Fix improper taking over HW learned FDB
Date: Thu, 27 Apr 2017 11:08:05 +0300
Message-ID: <1493280485-37845-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
        bridge@lists.linux-foundation.org,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:48364 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S967169AbdD0IHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 04:07:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb
entries") added the ability to "take over an entry which was previously
learned via HW when it shows up from a SW port".

However, if an entry was learned via HW and then a control packet
(e.g., ARP request) was trapped to the CPU, the bridge driver will
update the entry and remove the externally learned flag, although the
entry is still present in HW. Instead, only clear the externally learned
flag in case of roaming.

Fixes: 7e26bf45e4cb ("net: bridge: allow SW learn to take over HW fdb entries")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Arkadi Sharashevsky <arkadis@mellanox.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_fdb.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 5a40a87..ab0c7cc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -589,14 +589,14 @@ void br_fdb_update(struct net_bridge *br, struct net_bridge_port *source,
 			if (unlikely(source != fdb->dst)) {
 				fdb->dst = source;
 				fdb_modified = true;
+				/* Take over HW learned entry */
+				if (unlikely(fdb->added_by_external_learn))
+					fdb->added_by_external_learn = 0;
 			}
 			if (now != fdb->updated)
 				fdb->updated = now;
 			if (unlikely(added_by_user))
 				fdb->added_by_user = 1;
-			/* Take over HW learned entry */
-			if (unlikely(fdb->added_by_external_learn))
-				fdb->added_by_external_learn = 0;
 			if (unlikely(fdb_modified))
 				fdb_notify(br, fdb, RTM_NEWNEIGH);
 		}
-- 
2.4.11
