From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: move the delivery of named
	messages out of nametbl lock
Date: Mon, 28 Apr 2014 18:00:10 +0800
Message-ID: <1398679210-13668-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Commit a89778d8baf19cd7e728d81121a294a06cedaad1 ("tipc: add support
for link state subscriptions") introduced below possible deadlock
scenario:

       CPU0                          CPU1
T0:   tipc_publish()                 link_timeout()
T1:   tipc_nametbl_publish()         [grab node lock]*
T2:   [grab nametbl write lock]*     link_state_event()
T3:   named_cluster_distribute()     link_activate()
T4:   [grab node lock]*              tipc_node_link_up()
T5:                                  tipc_nametbl_publish()
T6:                                  [grab nametble write lock]*

The opposite order of holding nametbl write lock and node lock on
above two different paths may result in a deadlock. If we move the
the delivery of named messages via link out of name nametbl lock,
the reverse order of holding locks will be eliminated, as a result,
the deadlock will be killed as well.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/name_distr.c |   18 +++++++++---------
 net/tipc/name_distr.h |    5 +++--
 net/tipc/name_table.c |   12 ++++++++++--
 3 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 36a7282..974a73f 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -127,7 +127,7 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 	return buf;
 }
 
-static void named_cluster_distribute(struct sk_buff *buf)
+void named_cluster_distribute(struct sk_buff *buf)
 {
 	struct sk_buff *buf_copy;
 	struct tipc_node *n_ptr;
@@ -156,7 +156,7 @@ static void named_cluster_distribute(struct sk_buff *buf)
 /**
  * tipc_named_publish - tell other nodes about a new publication by this node
  */
-void tipc_named_publish(struct publication *publ)
+struct sk_buff *tipc_named_publish(struct publication *publ)
 {
 	struct sk_buff *buf;
 	struct distr_item *item;
@@ -165,23 +165,23 @@ void tipc_named_publish(struct publication *publ)
 	publ_lists[publ->scope]->size++;
 
 	if (publ->scope == TIPC_NODE_SCOPE)
-		return;
+		return NULL;
 
 	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
 		pr_warn("Publication distribution failure\n");
-		return;
+		return NULL;
 	}
 
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
-	named_cluster_distribute(buf);
+	return buf;
 }
 
 /**
  * tipc_named_withdraw - tell other nodes about a withdrawn publication by this node
  */
-void tipc_named_withdraw(struct publication *publ)
+struct sk_buff *tipc_named_withdraw(struct publication *publ)
 {
 	struct sk_buff *buf;
 	struct distr_item *item;
@@ -190,17 +190,17 @@ void tipc_named_withdraw(struct publication *publ)
 	publ_lists[publ->scope]->size--;
 
 	if (publ->scope == TIPC_NODE_SCOPE)
-		return;
+		return NULL;
 
 	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
 		pr_warn("Withdrawal distribution failure\n");
-		return;
+		return NULL;
 	}
 
 	item = (struct distr_item *)msg_data(buf_msg(buf));
 	publ_to_item(item, publ);
-	named_cluster_distribute(buf);
+	return buf;
 }
 
 /*
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index 9b312cc..47ff829 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -39,8 +39,9 @@
 
 #include "name_table.h"
 
-void tipc_named_publish(struct publication *publ);
-void tipc_named_withdraw(struct publication *publ);
+struct sk_buff *tipc_named_publish(struct publication *publ);
+struct sk_buff *tipc_named_withdraw(struct publication *publ);
+void named_cluster_distribute(struct sk_buff *buf);
 void tipc_named_node_up(unsigned long node);
 void tipc_named_rcv(struct sk_buff *buf);
 void tipc_named_reinit(void);
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 042e8e3..9bcf4b5 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -664,6 +664,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 					 u32 scope, u32 port_ref, u32 key)
 {
 	struct publication *publ;
+	struct sk_buff *buf = NULL;
 
 	if (table.local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
@@ -676,9 +677,12 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 				   tipc_own_addr, port_ref, key);
 	if (likely(publ)) {
 		table.local_publ_count++;
-		tipc_named_publish(publ);
+		buf = tipc_named_publish(publ);
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
+
+	if (buf)
+		named_cluster_distribute(buf);
 	return publ;
 }
 
@@ -688,15 +692,19 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 {
 	struct publication *publ;
+	struct sk_buff *buf;
 
 	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
 		table.local_publ_count--;
-		tipc_named_withdraw(publ);
+		buf = tipc_named_withdraw(publ);
 		write_unlock_bh(&tipc_nametbl_lock);
 		list_del_init(&publ->pport_list);
 		kfree(publ);
+
+		if (buf)
+			named_cluster_distribute(buf);
 		return 1;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.  Get 
unparalleled scalability from the best Selenium testing platform available.
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
