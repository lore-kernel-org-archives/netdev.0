From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 12/16] tipc: name tipc name table
	support net namespace
Date: Fri, 9 Jan 2015 15:27:09 +0800
Message-ID: <1420788433-17960-13-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

TIPC name table is used to store the mapping relationship between
TIPC service name and socket port ID. When tipc supports namespace,
it allows users to publish service names only owned by a certain
namespace. Therefore, every namespace must have its private name
table to prevent service names published to one namespace from being
contaminated by other service names in another namespace. Therefore,
The name table global variable (ie, nametbl) and its lock must be
moved to tipc_net structure, and a parameter of namespace must be
added for necessary functions so that they can obtain name table
variable defined in tipc_net structure.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c     |    3 +-
 net/tipc/core.c       |   19 +++++---
 net/tipc/core.h       |    4 ++
 net/tipc/msg.c        |    4 +-
 net/tipc/msg.h        |    2 +-
 net/tipc/name_distr.c |   37 ++++++++------
 net/tipc/name_distr.h |    4 +-
 net/tipc/name_table.c |  128 +++++++++++++++++++++++++++----------------------
 net/tipc/name_table.h |   25 +++++-----
 net/tipc/net.c        |    2 +-
 net/tipc/server.c     |    3 +-
 net/tipc/server.h     |   10 ++--
 net/tipc/socket.c     |   11 ++---
 net/tipc/subscr.c     |   16 ++++---
 net/tipc/subscr.h     |    2 +
 15 files changed, 154 insertions(+), 116 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 20b1c58..974723a 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -248,7 +248,8 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 							req_tlv_space);
 		break;
 	case TIPC_CMD_SHOW_NAME_TABLE:
-		rep_tlv_buf = tipc_nametbl_get(req_tlv_area, req_tlv_space);
+		rep_tlv_buf = tipc_nametbl_get(net, req_tlv_area,
+					       req_tlv_space);
 		break;
 	case TIPC_CMD_GET_BEARER_NAMES:
 		rep_tlv_buf = tipc_bearer_get_names(net);
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 23ff3ca..63cde81 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -62,12 +62,24 @@ static int __net_init tipc_init_net(struct net *net)
 	spin_lock_init(&tn->node_list_lock);
 
 	err = tipc_sk_rht_init(net);
+	if (err)
+		goto out_sk_rht;
+
+	err = tipc_nametbl_init(net);
+	if (err)
+		goto out_nametbl;
+	return 0;
+
+out_nametbl:
+	tipc_sk_rht_destroy(net);
+out_sk_rht:
 	return err;
 }
 
 static void __net_exit tipc_exit_net(struct net *net)
 {
 	tipc_net_stop(net);
+	tipc_nametbl_stop(net);
 	tipc_sk_rht_destroy(net);
 }
 
@@ -98,10 +110,6 @@ static int __init tipc_init(void)
 	if (err)
 		goto out_pernet;
 
-	err = tipc_nametbl_init();
-	if (err)
-		goto out_nametbl;
-
 	err = tipc_netlink_start();
 	if (err)
 		goto out_netlink;
@@ -133,8 +141,6 @@ out_sysctl:
 out_socket:
 	tipc_netlink_stop();
 out_netlink:
-	tipc_nametbl_stop();
-out_nametbl:
 	unregister_pernet_subsys(&tipc_net_ops);
 out_pernet:
 	pr_err("Unable to start in single node mode\n");
@@ -147,7 +153,6 @@ static void __exit tipc_exit(void)
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
 	tipc_subscr_stop();
-	tipc_nametbl_stop();
 	tipc_socket_stop();
 	tipc_unregister_sysctl();
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 1a7f816..8939929 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -105,6 +105,10 @@ struct tipc_net {
 
 	/* Socket hash table */
 	struct rhashtable sk_rht;
+
+	/* Name table */
+	spinlock_t nametbl_lock;
+	struct name_table *nametbl;
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index a38f6a6..642fb13 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -426,7 +426,7 @@ exit:
  * Returns 0 (TIPC_OK) if message ok and we can try again, -TIPC error
  * code if message to be rejected
  */
-int tipc_msg_eval(struct sk_buff *buf, u32 *dnode)
+int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode)
 {
 	struct tipc_msg *msg = buf_msg(buf);
 	u32 dport;
@@ -441,7 +441,7 @@ int tipc_msg_eval(struct sk_buff *buf, u32 *dnode)
 		return -TIPC_ERR_NO_NAME;
 
 	*dnode = addr_domain(msg_lookup_scope(msg));
-	dport = tipc_nametbl_translate(msg_nametype(msg),
+	dport = tipc_nametbl_translate(net, msg_nametype(msg),
 				       msg_nameinst(msg),
 				       dnode);
 	if (!dport)
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 75f3242..69f37e6 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -749,7 +749,7 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 
 struct sk_buff *tipc_buf_acquire(u32 size);
 bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err);
-int tipc_msg_eval(struct sk_buff *buf, u32 *dnode);
+int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode);
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index d40df58..ba42132 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -109,13 +109,14 @@ void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 /**
  * tipc_named_publish - tell other nodes about a new publication by this node
  */
-struct sk_buff *tipc_named_publish(struct publication *publ)
+struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *buf;
 	struct distr_item *item;
 
 	list_add_tail_rcu(&publ->local_list,
-			  &tipc_nametbl->publ_list[publ->scope]);
+			  &tn->nametbl->publ_list[publ->scope]);
 
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
@@ -206,15 +207,16 @@ static void named_distribute(struct net *net, struct sk_buff_head *list,
  */
 void tipc_named_node_up(struct net *net, u32 dnode)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff_head head;
 
 	__skb_queue_head_init(&head);
 
 	rcu_read_lock();
 	named_distribute(net, &head, dnode,
-			 &tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
+			 &tn->nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
 	named_distribute(net, &head, dnode,
-			 &tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
+			 &tn->nametbl->publ_list[TIPC_ZONE_SCOPE]);
 	rcu_read_unlock();
 
 	tipc_link_xmit(net, &head, dnode, dnode);
@@ -262,14 +264,15 @@ static void tipc_publ_unsubscribe(struct net *net, struct publication *publ,
  */
 static void tipc_publ_purge(struct net *net, struct publication *publ, u32 addr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct publication *p;
 
-	spin_lock_bh(&tipc_nametbl_lock);
-	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
+	spin_lock_bh(&tn->nametbl_lock);
+	p = tipc_nametbl_remove_publ(net, publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
 	if (p)
 		tipc_publ_unsubscribe(net, p, addr);
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 
 	if (p != publ) {
 		pr_err("Unable to remove publication from failed node\n"
@@ -302,7 +305,8 @@ static bool tipc_update_nametbl(struct net *net, struct distr_item *i,
 	struct publication *publ = NULL;
 
 	if (dtype == PUBLICATION) {
-		publ = tipc_nametbl_insert_publ(ntohl(i->type), ntohl(i->lower),
+		publ = tipc_nametbl_insert_publ(net, ntohl(i->type),
+						ntohl(i->lower),
 						ntohl(i->upper),
 						TIPC_CLUSTER_SCOPE, node,
 						ntohl(i->ref), ntohl(i->key));
@@ -311,7 +315,8 @@ static bool tipc_update_nametbl(struct net *net, struct distr_item *i,
 			return true;
 		}
 	} else if (dtype == WITHDRAWAL) {
-		publ = tipc_nametbl_remove_publ(ntohl(i->type), ntohl(i->lower),
+		publ = tipc_nametbl_remove_publ(net, ntohl(i->type),
+						ntohl(i->lower),
 						node, ntohl(i->ref),
 						ntohl(i->key));
 		if (publ) {
@@ -376,19 +381,20 @@ void tipc_named_process_backlog(struct net *net)
  */
 void tipc_named_rcv(struct net *net, struct sk_buff *buf)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_msg *msg = buf_msg(buf);
 	struct distr_item *item = (struct distr_item *)msg_data(msg);
 	u32 count = msg_data_sz(msg) / ITEM_SIZE;
 	u32 node = msg_orignode(msg);
 
-	spin_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tn->nametbl_lock);
 	while (count--) {
 		if (!tipc_update_nametbl(net, item, node, msg_type(msg)))
 			tipc_named_add_backlog(item, msg_type(msg), node);
 		item++;
 	}
 	tipc_named_process_backlog(net);
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 	kfree_skb(buf);
 }
 
@@ -399,17 +405,18 @@ void tipc_named_rcv(struct net *net, struct sk_buff *buf)
  * All name table entries published by this node are updated to reflect
  * the node's new network address.
  */
-void tipc_named_reinit(void)
+void tipc_named_reinit(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct publication *publ;
 	int scope;
 
-	spin_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tn->nametbl_lock);
 
 	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_NODE_SCOPE; scope++)
-		list_for_each_entry_rcu(publ, &tipc_nametbl->publ_list[scope],
+		list_for_each_entry_rcu(publ, &tn->nametbl->publ_list[scope],
 					local_list)
 			publ->node = tipc_own_addr;
 
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 }
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index 8039d84..1ed2d7e 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -67,12 +67,12 @@ struct distr_item {
 	__be32 key;
 };
 
-struct sk_buff *tipc_named_publish(struct publication *publ);
+struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ);
 struct sk_buff *tipc_named_withdraw(struct publication *publ);
 void named_cluster_distribute(struct net *net, struct sk_buff *buf);
 void tipc_named_node_up(struct net *net, u32 dnode);
 void tipc_named_rcv(struct net *net, struct sk_buff *buf);
-void tipc_named_reinit(void);
+void tipc_named_reinit(struct net *net);
 void tipc_named_process_backlog(struct net *net);
 void tipc_publ_notify(struct net *net, struct list_head *nsub_list, u32 addr);
 
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index beed5fd..57e39c1 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -34,6 +34,7 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/sock.h>
 #include "core.h"
 #include "config.h"
 #include "name_table.h"
@@ -106,9 +107,6 @@ struct name_seq {
 	struct rcu_head rcu;
 };
 
-struct name_table *tipc_nametbl;
-DEFINE_SPINLOCK(tipc_nametbl_lock);
-
 static int hash(int x)
 {
 	return x & (TIPC_NAMETBL_SIZE - 1);
@@ -448,12 +446,13 @@ static void tipc_nameseq_subscribe(struct name_seq *nseq,
 	}
 }
 
-static struct name_seq *nametbl_find_seq(u32 type)
+static struct name_seq *nametbl_find_seq(struct net *net, u32 type)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct hlist_head *seq_head;
 	struct name_seq *ns;
 
-	seq_head = &tipc_nametbl->seq_hlist[hash(type)];
+	seq_head = &tn->nametbl->seq_hlist[hash(type)];
 	hlist_for_each_entry_rcu(ns, seq_head, ns_list) {
 		if (ns->type == type)
 			return ns;
@@ -462,11 +461,13 @@ static struct name_seq *nametbl_find_seq(u32 type)
 	return NULL;
 };
 
-struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
-					     u32 scope, u32 node, u32 port, u32 key)
+struct publication *tipc_nametbl_insert_publ(struct net *net, u32 type,
+					     u32 lower, u32 upper, u32 scope,
+					     u32 node, u32 port, u32 key)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct publication *publ;
-	struct name_seq *seq = nametbl_find_seq(type);
+	struct name_seq *seq = nametbl_find_seq(net, type);
 	int index = hash(type);
 
 	if ((scope < TIPC_ZONE_SCOPE) || (scope > TIPC_NODE_SCOPE) ||
@@ -477,8 +478,7 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 	}
 
 	if (!seq)
-		seq = tipc_nameseq_create(type,
-					  &tipc_nametbl->seq_hlist[index]);
+		seq = tipc_nameseq_create(type, &tn->nametbl->seq_hlist[index]);
 	if (!seq)
 		return NULL;
 
@@ -489,11 +489,12 @@ struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
 	return publ;
 }
 
-struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
-					     u32 node, u32 ref, u32 key)
+struct publication *tipc_nametbl_remove_publ(struct net *net, u32 type,
+					     u32 lower, u32 node, u32 ref,
+					     u32 key)
 {
 	struct publication *publ;
-	struct name_seq *seq = nametbl_find_seq(type);
+	struct name_seq *seq = nametbl_find_seq(net, type);
 
 	if (!seq)
 		return NULL;
@@ -524,7 +525,8 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
  * - if name translation is attempted and fails, sets 'destnode' to 0
  *   and returns 0
  */
-u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
+u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance,
+			   u32 *destnode)
 {
 	struct sub_seq *sseq;
 	struct name_info *info;
@@ -537,7 +539,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 		return 0;
 
 	rcu_read_lock();
-	seq = nametbl_find_seq(type);
+	seq = nametbl_find_seq(net, type);
 	if (unlikely(!seq))
 		goto not_found;
 	spin_lock_bh(&seq->lock);
@@ -610,8 +612,8 @@ not_found:
  *
  * Returns non-zero if any off-node ports overlap
  */
-int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
-			      struct tipc_port_list *dports)
+int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
+			      u32 limit, struct tipc_port_list *dports)
 {
 	struct name_seq *seq;
 	struct sub_seq *sseq;
@@ -620,7 +622,7 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 	int res = 0;
 
 	rcu_read_lock();
-	seq = nametbl_find_seq(type);
+	seq = nametbl_find_seq(net, type);
 	if (!seq)
 		goto exit;
 
@@ -657,24 +659,25 @@ struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
 {
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	spin_lock_bh(&tipc_nametbl_lock);
-	if (tipc_nametbl->local_publ_count >= TIPC_MAX_PUBLICATIONS) {
+	spin_lock_bh(&tn->nametbl_lock);
+	if (tn->nametbl->local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
 			TIPC_MAX_PUBLICATIONS);
-		spin_unlock_bh(&tipc_nametbl_lock);
+		spin_unlock_bh(&tn->nametbl_lock);
 		return NULL;
 	}
 
-	publ = tipc_nametbl_insert_publ(type, lower, upper, scope,
-				   tipc_own_addr, port_ref, key);
+	publ = tipc_nametbl_insert_publ(net, type, lower, upper, scope,
+					tipc_own_addr, port_ref, key);
 	if (likely(publ)) {
-		tipc_nametbl->local_publ_count++;
-		buf = tipc_named_publish(publ);
+		tn->nametbl->local_publ_count++;
+		buf = tipc_named_publish(net, publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog(net);
 	}
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 
 	if (buf)
 		named_cluster_distribute(net, buf);
@@ -689,11 +692,13 @@ int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
 {
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
-	spin_lock_bh(&tipc_nametbl_lock);
-	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
+	spin_lock_bh(&tn->nametbl_lock);
+	publ = tipc_nametbl_remove_publ(net, type, lower, tipc_own_addr,
+					ref, key);
 	if (likely(publ)) {
-		tipc_nametbl->local_publ_count--;
+		tn->nametbl->local_publ_count--;
 		skb = tipc_named_withdraw(publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog(net);
@@ -704,7 +709,7 @@ int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
 		       "(type=%u, lower=%u, ref=%u, key=%u)\n",
 		       type, lower, ref, key);
 	}
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 
 	if (skb) {
 		named_cluster_distribute(net, skb);
@@ -718,15 +723,15 @@ int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
  */
 void tipc_nametbl_subscribe(struct tipc_subscription *s)
 {
+	struct tipc_net *tn = net_generic(s->net, tipc_net_id);
 	u32 type = s->seq.type;
 	int index = hash(type);
 	struct name_seq *seq;
 
-	spin_lock_bh(&tipc_nametbl_lock);
-	seq = nametbl_find_seq(type);
+	spin_lock_bh(&tn->nametbl_lock);
+	seq = nametbl_find_seq(s->net, type);
 	if (!seq)
-		seq = tipc_nameseq_create(type,
-					  &tipc_nametbl->seq_hlist[index]);
+		seq = tipc_nameseq_create(type, &tn->nametbl->seq_hlist[index]);
 	if (seq) {
 		spin_lock_bh(&seq->lock);
 		tipc_nameseq_subscribe(seq, s);
@@ -735,7 +740,7 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 		pr_warn("Failed to create subscription for {%u,%u,%u}\n",
 			s->seq.type, s->seq.lower, s->seq.upper);
 	}
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 }
 
 /**
@@ -743,10 +748,11 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
  */
 void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 {
+	struct tipc_net *tn = net_generic(s->net, tipc_net_id);
 	struct name_seq *seq;
 
-	spin_lock_bh(&tipc_nametbl_lock);
-	seq = nametbl_find_seq(s->seq.type);
+	spin_lock_bh(&tn->nametbl_lock);
+	seq = nametbl_find_seq(s->net, s->seq.type);
 	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
@@ -759,7 +765,7 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 			spin_unlock_bh(&seq->lock);
 		}
 	}
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 }
 
 /**
@@ -861,9 +867,10 @@ static int nametbl_header(char *buf, int len, u32 depth)
 /**
  * nametbl_list - print specified name table contents into the given buffer
  */
-static int nametbl_list(char *buf, int len, u32 depth_info,
+static int nametbl_list(struct net *net, char *buf, int len, u32 depth_info,
 			u32 type, u32 lowbound, u32 upbound)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct hlist_head *seq_head;
 	struct name_seq *seq;
 	int all_types;
@@ -883,7 +890,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		lowbound = 0;
 		upbound = ~0;
 		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
-			seq_head = &tipc_nametbl->seq_hlist[i];
+			seq_head = &tn->nametbl->seq_hlist[i];
 			hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
 						   depth, seq->type,
@@ -899,7 +906,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		}
 		ret += nametbl_header(buf + ret, len - ret, depth);
 		i = hash(type);
-		seq_head = &tipc_nametbl->seq_hlist[i];
+		seq_head = &tn->nametbl->seq_hlist[i];
 		hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
 			if (seq->type == type) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
@@ -912,7 +919,8 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 	return ret;
 }
 
-struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
+struct sk_buff *tipc_nametbl_get(struct net *net, const void *req_tlv_area,
+				 int req_tlv_space)
 {
 	struct sk_buff *buf;
 	struct tipc_name_table_query *argv;
@@ -933,7 +941,7 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 	pb_len = ULTRA_STRING_MAX_LEN;
 	argv = (struct tipc_name_table_query *)TLV_DATA(req_tlv_area);
 	rcu_read_lock();
-	str_len = nametbl_list(pb, pb_len, ntohl(argv->depth),
+	str_len = nametbl_list(net, pb, pb_len, ntohl(argv->depth),
 			       ntohl(argv->type),
 			       ntohl(argv->lowbound), ntohl(argv->upbound));
 	rcu_read_unlock();
@@ -944,8 +952,10 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 	return buf;
 }
 
-int tipc_nametbl_init(void)
+int tipc_nametbl_init(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct name_table *tipc_nametbl;
 	int i;
 
 	tipc_nametbl = kzalloc(sizeof(*tipc_nametbl), GFP_ATOMIC);
@@ -958,6 +968,8 @@ int tipc_nametbl_init(void)
 	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
 	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
 	INIT_LIST_HEAD(&tipc_nametbl->publ_list[TIPC_NODE_SCOPE]);
+	tn->nametbl = tipc_nametbl;
+	spin_lock_init(&tn->nametbl_lock);
 	return 0;
 }
 
@@ -966,7 +978,7 @@ int tipc_nametbl_init(void)
  *
  * tipc_nametbl_lock must be held when calling this function
  */
-static void tipc_purge_publications(struct name_seq *seq)
+static void tipc_purge_publications(struct net *net, struct name_seq *seq)
 {
 	struct publication *publ, *safe;
 	struct sub_seq *sseq;
@@ -976,8 +988,8 @@ static void tipc_purge_publications(struct name_seq *seq)
 	sseq = seq->sseqs;
 	info = sseq->info;
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
-		tipc_nametbl_remove_publ(publ->type, publ->lower, publ->node,
-					 publ->ref, publ->key);
+		tipc_nametbl_remove_publ(net, publ->type, publ->lower,
+					 publ->node, publ->ref, publ->key);
 		kfree_rcu(publ, rcu);
 	}
 	hlist_del_init_rcu(&seq->ns_list);
@@ -987,25 +999,27 @@ static void tipc_purge_publications(struct name_seq *seq)
 	kfree_rcu(seq, rcu);
 }
 
-void tipc_nametbl_stop(void)
+void tipc_nametbl_stop(struct net *net)
 {
 	u32 i;
 	struct name_seq *seq;
 	struct hlist_head *seq_head;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+	struct name_table *tipc_nametbl = tn->nametbl;
 
 	/* Verify name table is empty and purge any lingering
 	 * publications, then release the name table
 	 */
-	spin_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tn->nametbl_lock);
 	for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 		if (hlist_empty(&tipc_nametbl->seq_hlist[i]))
 			continue;
 		seq_head = &tipc_nametbl->seq_hlist[i];
 		hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
-			tipc_purge_publications(seq);
+			tipc_purge_publications(net, seq);
 		}
 	}
-	spin_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tn->nametbl_lock);
 
 	synchronize_net();
 	kfree(tipc_nametbl);
@@ -1109,9 +1123,10 @@ static int __tipc_nl_subseq_list(struct tipc_nl_msg *msg, struct name_seq *seq,
 	return 0;
 }
 
-static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
-			      u32 *last_lower, u32 *last_publ)
+static int tipc_nl_seq_list(struct net *net, struct tipc_nl_msg *msg,
+			    u32 *last_type, u32 *last_lower, u32 *last_publ)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct hlist_head *seq_head;
 	struct name_seq *seq = NULL;
 	int err;
@@ -1123,10 +1138,10 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 		i = 0;
 
 	for (; i < TIPC_NAMETBL_SIZE; i++) {
-		seq_head = &tipc_nametbl->seq_hlist[i];
+		seq_head = &tn->nametbl->seq_hlist[i];
 
 		if (*last_type) {
-			seq = nametbl_find_seq(*last_type);
+			seq = nametbl_find_seq(net, *last_type);
 			if (!seq)
 				return -EPIPE;
 		} else {
@@ -1160,6 +1175,7 @@ int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	u32 last_type = cb->args[0];
 	u32 last_lower = cb->args[1];
 	u32 last_publ = cb->args[2];
+	struct net *net = sock_net(skb->sk);
 	struct tipc_nl_msg msg;
 
 	if (done)
@@ -1170,7 +1186,7 @@ int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	msg.seq = cb->nlh->nlmsg_seq;
 
 	rcu_read_lock();
-	err = __tipc_nl_seq_list(&msg, &last_type, &last_lower, &last_publ);
+	err = tipc_nl_seq_list(net, &msg, &last_type, &last_lower, &last_publ);
 	if (!err) {
 		done = 1;
 	} else if (err != -EMSGSIZE) {
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index efccaca..f67b3d8 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -95,28 +95,27 @@ struct name_table {
 	u32 local_publ_count;
 };
 
-extern spinlock_t tipc_nametbl_lock;
-extern struct name_table *tipc_nametbl;
-
 int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space);
-u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *node);
-int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
-			      struct tipc_port_list *dports);
+struct sk_buff *tipc_nametbl_get(struct net *net, const void *req_tlv_area,
+				 int req_tlv_space);
+u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance, u32 *node);
+int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
+			      u32 limit, struct tipc_port_list *dports);
 struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
 					 u32 upper, u32 scope, u32 port_ref,
 					 u32 key);
 int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
 			  u32 key);
-struct publication *tipc_nametbl_insert_publ(u32 type, u32 lower, u32 upper,
-					     u32 scope, u32 node, u32 ref,
+struct publication *tipc_nametbl_insert_publ(struct net *net, u32 type,
+					     u32 lower, u32 upper, u32 scope,
+					     u32 node, u32 ref, u32 key);
+struct publication *tipc_nametbl_remove_publ(struct net *net, u32 type,
+					     u32 lower, u32 node, u32 ref,
 					     u32 key);
-struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower, u32 node,
-					     u32 ref, u32 key);
 void tipc_nametbl_subscribe(struct tipc_subscription *s);
 void tipc_nametbl_unsubscribe(struct tipc_subscription *s);
-int tipc_nametbl_init(void);
-void tipc_nametbl_stop(void);
+int tipc_nametbl_init(struct net *net);
+void tipc_nametbl_stop(struct net *net);
 
 #endif
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 44ccf47..04445d21 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -116,7 +116,7 @@ int tipc_net_start(struct net *net, u32 addr)
 	int res;
 
 	tipc_own_addr = addr;
-	tipc_named_reinit();
+	tipc_named_reinit(net);
 	tipc_sk_reinit(net);
 	res = tipc_bclink_init(net);
 	if (res)
diff --git a/net/tipc/server.c b/net/tipc/server.c
index 869eb09..b5bdaf7 100644
--- a/net/tipc/server.c
+++ b/net/tipc/server.c
@@ -256,7 +256,8 @@ static int tipc_receive_from_sock(struct tipc_conn *con)
 		goto out_close;
 	}
 
-	s->tipc_conn_recvmsg(con->conid, &addr, con->usr_data, buf, ret);
+	s->tipc_conn_recvmsg(sock_net(con->sock->sk), con->conid, &addr,
+			     con->usr_data, buf, ret);
 
 	kmem_cache_free(s->rcvbuf_cache, buf);
 
diff --git a/net/tipc/server.h b/net/tipc/server.h
index 87bc05c..9c979a0 100644
--- a/net/tipc/server.h
+++ b/net/tipc/server.h
@@ -38,6 +38,7 @@
 
 #include <linux/idr.h>
 #include <linux/tipc.h>
+#include <net/net_namespace.h>
 
 #define TIPC_SERVER_NAME_LEN	32
 
@@ -66,10 +67,11 @@ struct tipc_server {
 	struct workqueue_struct *rcv_wq;
 	struct workqueue_struct *send_wq;
 	int max_rcvbuf_size;
-	void *(*tipc_conn_new) (int conid);
-	void (*tipc_conn_shutdown) (int conid, void *usr_data);
-	void (*tipc_conn_recvmsg) (int conid, struct sockaddr_tipc *addr,
-				   void *usr_data, void *buf, size_t len);
+	void *(*tipc_conn_new)(int conid);
+	void (*tipc_conn_shutdown)(int conid, void *usr_data);
+	void (*tipc_conn_recvmsg)(struct net *net, int conid,
+				  struct sockaddr_tipc *addr, void *usr_data,
+				  void *buf, size_t len);
 	struct sockaddr_tipc *saddr;
 	const char name[TIPC_SERVER_NAME_LEN];
 	int imp;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index accb02c..4670e1e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -778,11 +778,8 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 		scope = TIPC_NODE_SCOPE;
 
 	/* Create destination port list: */
-	tipc_nametbl_mc_translate(msg_nametype(msg),
-				  msg_namelower(msg),
-				  msg_nameupper(msg),
-				  scope,
-				  &dports);
+	tipc_nametbl_mc_translate(net, msg_nametype(msg), msg_namelower(msg),
+				  msg_nameupper(msg), scope, &dports);
 	last = dports.count;
 	if (!last) {
 		kfree_skb(buf);
@@ -943,7 +940,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 		msg_set_nametype(mhdr, type);
 		msg_set_nameinst(mhdr, inst);
 		msg_set_lookup_scope(mhdr, tipc_addr_scope(domain));
-		dport = tipc_nametbl_translate(type, inst, &dnode);
+		dport = tipc_nametbl_translate(net, type, inst, &dnode);
 		msg_set_destnode(mhdr, dnode);
 		msg_set_destport(mhdr, dport);
 		if (unlikely(!dport && !dnode)) {
@@ -1765,7 +1762,7 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	/* Validate destination and message */
 	tsk = tipc_sk_lookup(net, dport);
 	if (unlikely(!tsk)) {
-		rc = tipc_msg_eval(skb, &dnode);
+		rc = tipc_msg_eval(net, skb, &dnode);
 		goto exit;
 	}
 	sk = &tsk->sk;
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index e6cb959..b71dbc0 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -50,8 +50,9 @@ struct tipc_subscriber {
 	struct list_head subscription_list;
 };
 
-static void subscr_conn_msg_event(int conid, struct sockaddr_tipc *addr,
-				  void *usr_data, void *buf, size_t len);
+static void subscr_conn_msg_event(struct net *net, int conid,
+				  struct sockaddr_tipc *addr, void *usr_data,
+				  void *buf, size_t len);
 static void *subscr_named_msg_event(int conid);
 static void subscr_conn_shutdown_event(int conid, void *usr_data);
 
@@ -260,7 +261,7 @@ static void subscr_cancel(struct tipc_subscr *s,
  *
  * Called with subscriber lock held.
  */
-static int subscr_subscribe(struct tipc_subscr *s,
+static int subscr_subscribe(struct net *net, struct tipc_subscr *s,
 			    struct tipc_subscriber *subscriber,
 			    struct tipc_subscription **sub_p) {
 	struct tipc_subscription *sub;
@@ -291,6 +292,7 @@ static int subscr_subscribe(struct tipc_subscr *s,
 	}
 
 	/* Initialize subscription object */
+	sub->net = net;
 	sub->seq.type = htohl(s->seq.type, swap);
 	sub->seq.lower = htohl(s->seq.lower, swap);
 	sub->seq.upper = htohl(s->seq.upper, swap);
@@ -323,14 +325,16 @@ static void subscr_conn_shutdown_event(int conid, void *usr_data)
 }
 
 /* Handle one request to create a new subscription for the subscriber */
-static void subscr_conn_msg_event(int conid, struct sockaddr_tipc *addr,
-				  void *usr_data, void *buf, size_t len)
+static void subscr_conn_msg_event(struct net *net, int conid,
+				  struct sockaddr_tipc *addr, void *usr_data,
+				  void *buf, size_t len)
 {
 	struct tipc_subscriber *subscriber = usr_data;
 	struct tipc_subscription *sub = NULL;
 
 	spin_lock_bh(&subscriber->lock);
-	if (subscr_subscribe((struct tipc_subscr *)buf, subscriber, &sub) < 0) {
+	if (subscr_subscribe(net, (struct tipc_subscr *)buf, subscriber,
+			     &sub) < 0) {
 		spin_unlock_bh(&subscriber->lock);
 		subscr_terminate(subscriber);
 		return;
diff --git a/net/tipc/subscr.h b/net/tipc/subscr.h
index 0d39589..670f570 100644
--- a/net/tipc/subscr.h
+++ b/net/tipc/subscr.h
@@ -49,6 +49,7 @@ struct tipc_subscriber;
  * struct tipc_subscription - TIPC network topology subscription object
  * @subscriber: pointer to its subscriber
  * @seq: name sequence associated with subscription
+ * @net: point to network namespace
  * @timeout: duration of subscription (in ms)
  * @filter: event filtering to be done for subscription
  * @timer: timer governing subscription duration (optional)
@@ -61,6 +62,7 @@ struct tipc_subscriber;
 struct tipc_subscription {
 	struct tipc_subscriber *subscriber;
 	struct tipc_name_seq seq;
+	struct net *net;
 	unsigned long timeout;
 	u32 filter;
 	struct timer_list timer;
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
