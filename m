From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/17] tipc: Revert name table translation optimization
Date: Wed, 29 Feb 2012 18:18:38 -0500
Message-ID: <1330557523-2024-13-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53984 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965376Ab2B2XTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:06 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Restores name table translation using a non-zero domain that is
"out of scope", which was broken by an earlier commit
(5d9c54c1e9ececcf7e99c4f014f9bec7ee3a7def). Comments have now been
added to the name table translation routine to make it clear that
there are actually three possible outcomes to a translation request
(found/not found/deferred), rather than just two (found/not found).

Note that a straightforward revert of the earlier commit is not
possible, as other changes to the name table translation logic
have occurred since the incorrect optimization was made.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |   17 +++++++++++++----
 net/tipc/port.c       |    2 +-
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index c2224f9..c6a1ae3 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -539,10 +539,17 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 }
 
 /*
- * tipc_nametbl_translate - translate name to port id
+ * tipc_nametbl_translate - perform name translation
  *
- * Note: on entry 'destnode' is the search domain used during translation;
- *       on exit it passes back the node address of the matching port (if any)
+ * On entry, 'destnode' is the search domain used during translation.
+ *
+ * On exit:
+ * - if name translation is deferred to another node/cluster/zone,
+ *   leaves 'destnode' unchanged (will be non-zero) and returns 0
+ * - if name translation is attempted and succeeds, sets 'destnode'
+ *   to publishing node and returns port reference (will be non-zero)
+ * - if name translation is attempted and fails, sets 'destnode' to 0
+ *   and returns 0
  */
 
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
@@ -552,6 +559,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	struct publication *publ;
 	struct name_seq *seq;
 	u32 ref = 0;
+	u32 node = 0;
 
 	if (!tipc_in_scope(*destnode, tipc_own_addr))
 		return 0;
@@ -609,11 +617,12 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	}
 
 	ref = publ->ref;
-	*destnode = publ->node;
+	node = publ->node;
 no_match:
 	spin_unlock_bh(&seq->lock);
 not_found:
 	read_unlock_bh(&tipc_nametbl_lock);
+	*destnode = node;
 	return ref;
 }
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index c4b5a34..b103d76 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -1221,7 +1221,7 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	msg_set_destnode(msg, destnode);
 	msg_set_destport(msg, destport);
 
-	if (likely(destport)) {
+	if (likely(destport || destnode)) {
 		if (likely(destnode == tipc_own_addr))
 			res = tipc_port_recv_sections(p_ptr, num_sect,
 						      msg_sect, total_len);
-- 
1.7.9.1
