From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 8/8] tipc: convert name table
	read-write lock to RCU
Date: Tue, 2 Dec 2014 15:00:30 +0800
Message-ID: <1417503630-31352-9-git-send-email-ying.xue@windriver.com>
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

Convert tipc name table read-write lock to RCU. After this change,
a new spin lock is used to protect name table on write side while
RCU is applied on read side.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 include/linux/rculist.h |    9 +++++
 net/tipc/name_distr.c   |   28 +++++++--------
 net/tipc/name_table.c   |   87 +++++++++++++++++++++++------------------------
 net/tipc/name_table.h   |    4 ++-
 4 files changed, 69 insertions(+), 59 deletions(-)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 372ad5e..aa79b3c 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -542,6 +542,15 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
 	     pos = hlist_entry_safe(rcu_dereference_bh((pos)->member.next),\
 			typeof(*(pos)), member))
 
+/**
+ * hlist_for_each_entry_from_rcu - iterate over a hlist continuing from current point
+ * @pos:	the type * to use as a loop cursor.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_from_rcu(pos, member)			\
+	for (; pos;							\
+	     pos = hlist_entry_safe(rcu_dereference((pos)->member.next),\
+			typeof(*(pos)), member))
 
 #endif	/* __KERNEL__ */
 #endif
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index ed00929..ba6083d 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -113,8 +113,8 @@ struct sk_buff *tipc_named_publish(struct publication *publ)
 	struct sk_buff *buf;
 	struct distr_item *item;
 
-	list_add_tail(&publ->local_list,
-		      &tipc_nametbl->publ_list[publ->scope]);
+	list_add_tail_rcu(&publ->local_list,
+			  &tipc_nametbl->publ_list[publ->scope]);
 
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
@@ -208,12 +208,12 @@ void tipc_named_node_up(u32 dnode)
 
 	__skb_queue_head_init(&head);
 
-	read_lock_bh(&tipc_nametbl_lock);
+	rcu_read_lock();
 	named_distribute(&head, dnode,
 			 &tipc_nametbl->publ_list[TIPC_CLUSTER_SCOPE]);
 	named_distribute(&head, dnode,
 			 &tipc_nametbl->publ_list[TIPC_ZONE_SCOPE]);
-	read_unlock_bh(&tipc_nametbl_lock);
+	rcu_read_unlock();
 
 	tipc_link_xmit(&head, dnode, dnode);
 }
@@ -260,12 +260,12 @@ static void tipc_publ_purge(struct publication *publ, u32 addr)
 {
 	struct publication *p;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower,
 				     publ->node, publ->ref, publ->key);
 	if (p)
 		tipc_publ_unsubscribe(p, addr);
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (p != publ) {
 		pr_err("Unable to remove publication from failed node\n"
@@ -274,7 +274,7 @@ static void tipc_publ_purge(struct publication *publ, u32 addr)
 		       publ->key);
 	}
 
-	kfree(p);
+	kfree_rcu(p, rcu);
 }
 
 void tipc_publ_notify(struct list_head *nsub_list, u32 addr)
@@ -311,7 +311,7 @@ static bool tipc_update_nametbl(struct distr_item *i, u32 node, u32 dtype)
 						ntohl(i->key));
 		if (publ) {
 			tipc_publ_unsubscribe(publ, node);
-			kfree(publ);
+			kfree_rcu(publ, rcu);
 			return true;
 		}
 	} else {
@@ -376,14 +376,14 @@ void tipc_named_rcv(struct sk_buff *buf)
 	u32 count = msg_data_sz(msg) / ITEM_SIZE;
 	u32 node = msg_orignode(msg);
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	while (count--) {
 		if (!tipc_update_nametbl(item, node, msg_type(msg)))
 			tipc_named_add_backlog(item, msg_type(msg), node);
 		item++;
 	}
 	tipc_named_process_backlog();
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 	kfree_skb(buf);
 }
 
@@ -399,12 +399,12 @@ void tipc_named_reinit(void)
 	struct publication *publ;
 	int scope;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 
 	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_NODE_SCOPE; scope++)
-		list_for_each_entry(publ, &tipc_nametbl->publ_list[scope],
-				    local_list)
+		list_for_each_entry_rcu(publ, &tipc_nametbl->publ_list[scope],
+					local_list)
 			publ->node = tipc_own_addr;
 
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 }
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 3c2e0c3..aafa684c 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -92,6 +92,7 @@ struct sub_seq {
  * @ns_list: links to adjacent name sequences in hash chain
  * @subscriptions: list of subscriptions for this 'type'
  * @lock: spinlock controlling access to publication lists of all sub-sequences
+ * @rcu: RCU callback head used for deferred freeing
  */
 struct name_seq {
 	u32 type;
@@ -101,10 +102,11 @@ struct name_seq {
 	struct hlist_node ns_list;
 	struct list_head subscriptions;
 	spinlock_t lock;
+	struct rcu_head rcu;
 };
 
 struct name_table *tipc_nametbl;
-DEFINE_RWLOCK(tipc_nametbl_lock);
+DEFINE_SPINLOCK(tipc_nametbl_lock);
 
 static int hash(int x)
 {
@@ -166,7 +168,7 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
 	nseq->alloc = 1;
 	INIT_HLIST_NODE(&nseq->ns_list);
 	INIT_LIST_HEAD(&nseq->subscriptions);
-	hlist_add_head(&nseq->ns_list, seq_head);
+	hlist_add_head_rcu(&nseq->ns_list, seq_head);
 	return nseq;
 }
 
@@ -451,7 +453,7 @@ static struct name_seq *nametbl_find_seq(u32 type)
 	struct name_seq *ns;
 
 	seq_head = &tipc_nametbl->seq_hlist[hash(type)];
-	hlist_for_each_entry(ns, seq_head, ns_list) {
+	hlist_for_each_entry_rcu(ns, seq_head, ns_list) {
 		if (ns->type == type)
 			return ns;
 	}
@@ -498,10 +500,10 @@ struct publication *tipc_nametbl_remove_publ(u32 type, u32 lower,
 	spin_lock_bh(&seq->lock);
 	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
 	if (!seq->first_free && list_empty(&seq->subscriptions)) {
-		hlist_del_init(&seq->ns_list);
-		spin_unlock_bh(&seq->lock);
+		hlist_del_init_rcu(&seq->ns_list);
 		kfree(seq->sseqs);
-		kfree(seq);
+		spin_unlock_bh(&seq->lock);
+		kfree_rcu(seq, rcu);
 		return publ;
 	}
 	spin_unlock_bh(&seq->lock);
@@ -533,7 +535,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 	if (!tipc_in_scope(*destnode, tipc_own_addr))
 		return 0;
 
-	read_lock_bh(&tipc_nametbl_lock);
+	rcu_read_lock();
 	seq = nametbl_find_seq(type);
 	if (unlikely(!seq))
 		goto not_found;
@@ -590,7 +592,7 @@ u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *destnode)
 no_match:
 	spin_unlock_bh(&seq->lock);
 not_found:
-	read_unlock_bh(&tipc_nametbl_lock);
+	rcu_read_unlock();
 	*destnode = node;
 	return ref;
 }
@@ -616,7 +618,7 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 	struct name_info *info;
 	int res = 0;
 
-	read_lock_bh(&tipc_nametbl_lock);
+	rcu_read_lock();
 	seq = nametbl_find_seq(type);
 	if (!seq)
 		goto exit;
@@ -641,7 +643,7 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 	}
 	spin_unlock_bh(&seq->lock);
 exit:
-	read_unlock_bh(&tipc_nametbl_lock);
+	rcu_read_unlock();
 	return res;
 }
 
@@ -654,11 +656,11 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 	struct publication *publ;
 	struct sk_buff *buf = NULL;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	if (tipc_nametbl->local_publ_count >= TIPC_MAX_PUBLICATIONS) {
 		pr_warn("Publication failed, local publication limit reached (%u)\n",
 			TIPC_MAX_PUBLICATIONS);
-		write_unlock_bh(&tipc_nametbl_lock);
+		spin_unlock_bh(&tipc_nametbl_lock);
 		return NULL;
 	}
 
@@ -670,7 +672,7 @@ struct publication *tipc_nametbl_publish(u32 type, u32 lower, u32 upper,
 		/* Any pending external events? */
 		tipc_named_process_backlog();
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (buf)
 		named_cluster_distribute(buf);
@@ -685,7 +687,7 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 	struct publication *publ;
 	struct sk_buff *skb = NULL;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
 	if (likely(publ)) {
 		tipc_nametbl->local_publ_count--;
@@ -693,13 +695,13 @@ int tipc_nametbl_withdraw(u32 type, u32 lower, u32 ref, u32 key)
 		/* Any pending external events? */
 		tipc_named_process_backlog();
 		list_del_init(&publ->pport_list);
-		kfree(publ);
+		kfree_rcu(publ, rcu);
 	} else {
 		pr_err("Unable to remove local publication\n"
 		       "(type=%u, lower=%u, ref=%u, key=%u)\n",
 		       type, lower, ref, key);
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 
 	if (skb) {
 		named_cluster_distribute(skb);
@@ -717,7 +719,7 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 	int index = hash(type);
 	struct name_seq *seq;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	seq = nametbl_find_seq(type);
 	if (!seq)
 		seq = tipc_nameseq_create(type,
@@ -730,7 +732,7 @@ void tipc_nametbl_subscribe(struct tipc_subscription *s)
 		pr_warn("Failed to create subscription for {%u,%u,%u}\n",
 			s->seq.type, s->seq.lower, s->seq.upper);
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 }
 
 /**
@@ -740,24 +742,23 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 {
 	struct name_seq *seq;
 
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	seq = nametbl_find_seq(s->seq.type);
 	if (seq != NULL) {
 		spin_lock_bh(&seq->lock);
 		list_del_init(&s->nameseq_list);
 		if (!seq->first_free && list_empty(&seq->subscriptions)) {
-			hlist_del_init(&seq->ns_list);
-			spin_unlock_bh(&seq->lock);
+			hlist_del_init_rcu(&seq->ns_list);
 			kfree(seq->sseqs);
-			kfree(seq);
+			spin_unlock_bh(&seq->lock);
+			kfree_rcu(seq, rcu);
 		} else {
 			spin_unlock_bh(&seq->lock);
 		}
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 }
 
-
 /**
  * subseq_list - print specified sub-sequence contents into the given buffer
  */
@@ -880,7 +881,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		upbound = ~0;
 		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 			seq_head = &tipc_nametbl->seq_hlist[i];
-			hlist_for_each_entry(seq, seq_head, ns_list) {
+			hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
 						   depth, seq->type,
 						   lowbound, upbound, i);
@@ -896,7 +897,7 @@ static int nametbl_list(char *buf, int len, u32 depth_info,
 		ret += nametbl_header(buf + ret, len - ret, depth);
 		i = hash(type);
 		seq_head = &tipc_nametbl->seq_hlist[i];
-		hlist_for_each_entry(seq, seq_head, ns_list) {
+		hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
 			if (seq->type == type) {
 				ret += nameseq_list(seq, buf + ret, len - ret,
 						   depth, type,
@@ -928,11 +929,11 @@ struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space)
 	pb = TLV_DATA(rep_tlv);
 	pb_len = ULTRA_STRING_MAX_LEN;
 	argv = (struct tipc_name_table_query *)TLV_DATA(req_tlv_area);
-	read_lock_bh(&tipc_nametbl_lock);
+	rcu_read_lock();
 	str_len = nametbl_list(pb, pb_len, ntohl(argv->depth),
 			       ntohl(argv->type),
 			       ntohl(argv->lowbound), ntohl(argv->upbound));
-	read_unlock_bh(&tipc_nametbl_lock);
+	rcu_read_unlock();
 	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
 	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
@@ -974,13 +975,13 @@ static void tipc_purge_publications(struct name_seq *seq)
 	list_for_each_entry_safe(publ, safe, &info->zone_list, zone_list) {
 		tipc_nametbl_remove_publ(publ->type, publ->lower, publ->node,
 					 publ->ref, publ->key);
-		kfree(publ);
+		kfree_rcu(publ, rcu);
 	}
-	hlist_del_init(&seq->ns_list);
+	hlist_del_init_rcu(&seq->ns_list);
+	kfree(seq->sseqs);
 	spin_lock_bh(&seq->lock);
 
-	kfree(seq->sseqs);
-	kfree(seq);
+	kfree_rcu(seq, rcu);
 }
 
 void tipc_nametbl_stop(void)
@@ -988,22 +989,22 @@ void tipc_nametbl_stop(void)
 	u32 i;
 	struct name_seq *seq;
 	struct hlist_head *seq_head;
-	struct hlist_node *safe;
 
 	/* Verify name table is empty and purge any lingering
 	 * publications, then release the name table
 	 */
-	write_lock_bh(&tipc_nametbl_lock);
+	spin_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
 		if (hlist_empty(&tipc_nametbl->seq_hlist[i]))
 			continue;
 		seq_head = &tipc_nametbl->seq_hlist[i];
-		hlist_for_each_entry_safe(seq, safe, seq_head, ns_list) {
+		hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
 			tipc_purge_publications(seq);
 		}
 	}
-	write_unlock_bh(&tipc_nametbl_lock);
+	spin_unlock_bh(&tipc_nametbl_lock);
 
+	synchronize_net();
 	kfree(tipc_nametbl);
 
 }
@@ -1109,7 +1110,7 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 			      u32 *last_lower, u32 *last_publ)
 {
 	struct hlist_head *seq_head;
-	struct name_seq *seq;
+	struct name_seq *seq = NULL;
 	int err;
 	int i;
 
@@ -1126,13 +1127,13 @@ static int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type,
 			if (!seq)
 				return -EPIPE;
 		} else {
-			seq = hlist_entry_safe((seq_head)->first,
-					       struct name_seq, ns_list);
+			hlist_for_each_entry_rcu(seq, seq_head, ns_list)
+				break;
 			if (!seq)
 				continue;
 		}
 
-		hlist_for_each_entry_from(seq, ns_list) {
+		hlist_for_each_entry_from_rcu(seq, ns_list) {
 			spin_lock_bh(&seq->lock);
 			err = __tipc_nl_subseq_list(msg, seq, last_lower,
 						    last_publ);
@@ -1165,8 +1166,7 @@ int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	msg.portid = NETLINK_CB(cb->skb).portid;
 	msg.seq = cb->nlh->nlmsg_seq;
 
-	read_lock_bh(&tipc_nametbl_lock);
-
+	rcu_read_lock();
 	err = __tipc_nl_seq_list(&msg, &last_type, &last_lower, &last_publ);
 	if (!err) {
 		done = 1;
@@ -1179,8 +1179,7 @@ int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		 */
 		cb->prev_seq = 1;
 	}
-
-	read_unlock_bh(&tipc_nametbl_lock);
+	rcu_read_unlock();
 
 	cb->args[0] = last_type;
 	cb->args[1] = last_lower;
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index c1fd734..5f0dee9 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -62,6 +62,7 @@ struct tipc_port_list;
  * @node_list: adjacent matching name seq publications with >= node scope
  * @cluster_list: adjacent matching name seq publications with >= cluster scope
  * @zone_list: adjacent matching name seq publications with >= zone scope
+ * @rcu: RCU callback head used for deferred freeing
  *
  * Note that the node list, cluster list, and zone list are circular lists.
  */
@@ -79,6 +80,7 @@ struct publication {
 	struct list_head node_list;
 	struct list_head cluster_list;
 	struct list_head zone_list;
+	struct rcu_head rcu;
 };
 
 /**
@@ -93,7 +95,7 @@ struct name_table {
 	u32 local_publ_count;
 };
 
-extern rwlock_t tipc_nametbl_lock;
+extern spinlock_t tipc_nametbl_lock;
 extern struct name_table *tipc_nametbl;
 
 int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb);
-- 
1.7.9.5


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
