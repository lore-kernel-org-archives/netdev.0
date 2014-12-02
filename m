From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 4/8] tipc: ensure all name
	sequences are properly protected with its lock
Date: Tue, 2 Dec 2014 15:00:26 +0800
Message-ID: <1417503630-31352-5-git-send-email-ying.xue@windriver.com>
References: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC internally created a name table which is used to store name
sequences. Now there is a read-write lock - tipc_nametbl_lock to
protect the table, and each name sequence saved in the table is
protected with its private lock. When a name sequence is inserted
or removed to or from the table, its members might need to change.
Therefore, in normal case, the two locks must be held while TIPC
operates the table. However, there are still several places where
we only hold tipc_nametbl_lock without proprerly obtaining name
sequence lock, which might cause the corruption of name sequence.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_table.c |   48 +++++++++++++++++++++++++++---------------------
 1 file changed, 27 insertions(+), 21 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index ba0ee3e..0d61f58 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -172,18 +172,6 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	return nseq;
 }
 
-/*
- * nameseq_delete_empty - deletes a name sequence structure if now unused
- */
-static void nameseq_delete_empty(struct name_seq *seq)
-{
-	if (!seq->first_free && list_empty(&seq->subscriptions)) {
-		hlist_del_init(&seq->ns_list);
-		kfree(seq->sseqs);
-		kfree(seq);
-	}
-}
-
 /**
  * nameseq_find_subseq - find sub-sequence (if any) matching a name instance
  *
@@ -476,6 +464,7 @@ static struct name_seq *nametbl_find_seq(u32 type)
 struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 					     u32 scope, u32 node, u32 port, u32 key)
 {
+	struct publication *publ;
 	struct name_seq *seq = nametbl_find_seq(type);
 	int index = hash(type);
 
@@ -492,8 +481,11 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 	if (!seq)
 		return NULL;
 
-	return tipc_nameseq_insert_publ(seq, type, lower, upper,
+	spin_lock_bh(&seq->lock);
+	publ = tipc_nameseq_insert_publ(seq, type, lower, upper,
 					scope, node, port, key);
+	spin_unlock_bh(&seq->lock);
+	return publ;
 }
 
 struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
@@ -505,8 +497,16 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 	if (!seq)
 		return NULL;
 
+	spin_lock_bh(&seq->lock);
 	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
-	nameseq_delete_empty(seq);
+	if (!seq->first_free && list_empty(&seq->subscriptions)) {
+		hlist_del_init(&seq->ns_list);
+		spin_unlock_bh(&seq->lock);
+		kfree(seq->sseqs);
+		kfree(seq);
+		return publ;
+	}
+	spin_unlock_bh(&seq->lock);
 	return publ;
 }
 
@@ -539,10 +539,10 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	seq = nametbl_find_seq(type);
 	if (unlikely(!seq))
 		goto not_found;
+	spin_lock_bh(&seq->lock);
 	sseq = nameseq_find_subseq(seq, instance);
 	if (unlikely(!sseq))
-		goto not_found;
-	spin_lock_bh(&seq->lock);
+		goto no_match;
 	info = sseq->info;
 
 	/* Closest-First Algorithm */
@@ -624,7 +624,6 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 		goto exit;
 
 	spin_lock_bh(&seq->lock);
-
 	sseq = seq->sseqs + nameseq_locate_subseq(seq, lower);
 	sseq_stop = seq->sseqs + seq->first_free;
 	for (; sseq != sseq_stop; sseq++) {
@@ -642,7 +641,6 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 		if (info->cluster_list_size != info->node_list_size)
 			res = 1;
 	}
-
 	spin_unlock_bh(&seq->lock);
 exit:
 	read_unlock_bh(&tipc_nametbl_lock);
@@ -747,8 +745,14 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
-		spin_unlock_bh(&seq->lock);
-		nameseq_delete_empty(seq);
+		if (!seq->first_free && list_empty(&seq->subscriptions)) {
+			hlist_del_init(&seq->ns_list);
+			spin_unlock_bh(&seq->lock);
+			kfree(seq->sseqs);
+			kfree(seq);
+		} else {
+			spin_unlock_bh(&seq->lock);
+		}
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
 }
@@ -964,6 +968,7 @@ static void tipc_purge_publications(struct name_seq *seq)
 	struct sub_seq *sseq;
 	struct name_info *info;
 
+	spin_lock_bh(&seq->lock);
 	sseq = seq->sseqs;
 	info = sseq->info;
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
@@ -972,6 +977,8 @@ static void tipc_purge_publications(struct name_seq *seq)
 		kfree(publ);
 	}
 	hlist_del_init(&seq->ns_list);
+	spin_lock_bh(&seq->lock);
+
 	kfree(seq->sseqs);
 	kfree(seq);
 }
@@ -1127,7 +1134,6 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 
 		hlist_for_each_entry_from(seq, ns_list) {
 			spin_lock_bh(&seq->lock);
-
 			err = __tipc_nl_subseq_list(msg, seq, last_lower,
 						    last_publ);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
