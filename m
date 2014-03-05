From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 5/6] tipc: fix memory leak during module removal
Date: Wed, 5 Mar 2014 08:56:17 +0100
Message-ID: <1394006178-23966-6-git-send-email-erik.hugne@ericsson.com>
References: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:54930 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661AbaCEHzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 02:55:49 -0500
In-Reply-To: <1394006178-23966-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When the TIPC module is removed, the tasklet handler is disabled
before all other subsystems. This will cause lingering publications
in the name table because the node_down tasklets responsible to
clean up publications from an unreachable node will never run.
When the name table is shut down, these publications are detected
and an error message is logged:
tipc: nametbl_stop(): orphaned hash chain detected
This is actually a memory leak, introduced with commit
993b858e37b3120ee76d9957a901cca22312ffaa ("tipc: correct the order
of stopping services at rmmod")

Instead of just logging an error and leaking memory, we free
the orphaned entries during nametable shutdown.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/name_table.c | 37 ++++++++++++++++++++++++++++++++++---
 1 file changed, 34 insertions(+), 3 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 92a1533..25c32dd 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -941,20 +941,51 @@ int tipc_nametbl_init(void)
 	return 0;
 }
 
+/**
+ * tipc_purge_publications - remove all publications for a given type
+ *
+ * tipc_nametbl_lock must be held when calling this function
+ */
+static void tipc_purge_publications(struct name_seq *seq)
+{
+	struct publication *publ, *safe;
+	struct sub_seq *sseq;
+	struct name_info *info;
+
+	if (!seq->sseqs) {
+		nameseq_delete_empty(seq);
+		return;
+	}
+	sseq = seq->sseqs;
+	info = sseq->info;
+	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
+		tipc_nametbl_remove_publ(publ->type, publ->lower, publ->node,
+					 publ->ref, publ->key);
+	}
+}
+
 void tipc_nametbl_stop(void)
 {
 	u32 i;
+	struct name_seq *seq;
+	struct hlist_head *seq_head;
+	struct hlist_node *safe;
 
 	if (!table.types)
 		return;
 
-	/* Verify name table is empty, then release it */
+	/* Verify name table is empty and purge any lingering
+	 * publications, then release the name table
+	 */
 	write_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 		if (hlist_empty(&table.types[i]))
 			continue;
-		pr_err("nametbl_stop(): orphaned hash chain detected\n");
-		break;
+		seq_head = &table.types[i];
+		hlist_for_each_entry_safe(seq, safe, seq_head, ns_list) {
+			tipc_purge_publications(seq);
+		}
+		continue;
 	}
 	kfree(table.types);
 	table.types = NULL;
-- 
1.8.3.2
