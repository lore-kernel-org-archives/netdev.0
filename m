From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 5/6] tipc: fix memory leak during
	module removal
Date: Tue, 4 Mar 2014 09:05:42 +0100
Message-ID: <1393920343-4134-6-git-send-email-erik.hugne@ericsson.com>
References: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1393920343-4134-1-git-send-email-erik.hugne@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

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


------------------------------------------------------------------------------
Subversion Kills Productivity. Get off Subversion & Make the Move to Perforce.
With Perforce, you get hassle-free workflows. Merge that actually works. 
Faster operations. Version large binaries.  Built-in WAN optimization and the
freedom to use Git, Perforce or both. Make the move to Perforce.
http://pubads.g.doubleclick.net/gampad/clk?id=122218951&iu=/4140/ostg.clktrk
