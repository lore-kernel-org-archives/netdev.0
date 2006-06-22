From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 28/32] [TIPC] First phase of assert() cleanup
Date: Thu, 22 Jun 2006 15:59:41 +0200
Message-ID: <11509847874089-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:54970 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030657AbWFVN7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This also contains enhancements to simplify comparisons in name table
publication removal algorithm and to simplify name table sanity checking
when shutting down TIPC.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/link.c        |   13 ++-
 net/tipc/name_distr.c  |   20 +++++
 net/tipc/name_table.c  |  179 +++++++++++++++++++++++++-----------------------
 net/tipc/node.c        |    3 -
 net/tipc/node_subscr.c |   15 ++--
 net/tipc/port.c        |    1 
 net/tipc/ref.c         |   31 +++++++-
 7 files changed, 153 insertions(+), 109 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index ff40c91..2efced5 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -574,7 +574,6 @@ void tipc_link_wakeup_ports(struct link 
 			break;
 		list_del_init(&p_ptr->wait_list);
 		p_ptr->congested_link = NULL;
-		assert(p_ptr->wakeup);
 		spin_lock_bh(p_ptr->publ.lock);
 		p_ptr->publ.congested = 0;
 		p_ptr->wakeup(&p_ptr->publ);
@@ -1246,8 +1245,6 @@ int tipc_link_send_sections_fast(struct 
 	int res;
 	u32 selector = msg_origport(hdr) & 1;
 
-	assert(destaddr != tipc_own_addr);
-
 again:
 	/*
 	 * Try building message using port's max_pkt hint.
@@ -2310,7 +2307,6 @@ void tipc_link_tunnel(struct link *l_ptr
 	memcpy(buf->data + INT_H_SIZE, (unchar *)msg, length);
 	dbg("%c->%c:", l_ptr->b_ptr->net_plane, tunnel->b_ptr->net_plane);
 	msg_dbg(buf_msg(buf), ">SEND>");
-	assert(tunnel);
 	tipc_link_send_buf(tunnel, buf);
 }
 
@@ -2339,10 +2335,10 @@ void tipc_link_changeover(struct link *l
 		 ORIGINAL_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
+
 	if (!l_ptr->first_out) {
 		struct sk_buff *buf;
 
-		assert(!msgcount);
 		buf = buf_acquire(INT_H_SIZE);
 		if (buf) {
 			memcpy(buf->data, (unchar *)&tunnel_hdr, INT_H_SIZE);
@@ -2356,6 +2352,7 @@ void tipc_link_changeover(struct link *l
 		}
 		return;
 	}
+
 	while (crs) {
 		struct tipc_msg *msg = buf_msg(crs);
 
@@ -2455,11 +2452,15 @@ static int link_recv_changeover_msg(stru
 	u32 msg_count = msg_msgcnt(tunnel_msg);
 
 	dest_link = (*l_ptr)->owner->links[msg_bearer_id(tunnel_msg)];
-	assert(dest_link != *l_ptr);
 	if (!dest_link) {
 		msg_dbg(tunnel_msg, "NOLINK/<REC<");
 		goto exit;
 	}
+	if (dest_link == *l_ptr) {
+		err("Unexpected changeover message on link <%s>\n", 
+		    (*l_ptr)->name);
+		goto exit;
+	}
 	dbg("%c<-%c:", dest_link->b_ptr->net_plane,
 	    (*l_ptr)->b_ptr->net_plane);
 	*l_ptr = dest_link;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index a3bbc89..5718ecb 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -174,7 +174,6 @@ void tipc_named_node_up(unsigned long no
 	u32 rest;
 	u32 max_item_buf;
 
-	assert(in_own_cluster(node));
 	read_lock_bh(&tipc_nametbl_lock); 
 	max_item_buf = TIPC_MAX_USER_MSG_SIZE / ITEM_SIZE;
 	max_item_buf *= ITEM_SIZE;
@@ -221,15 +220,24 @@ exit:
 static void node_is_down(struct publication *publ)
 {
 	struct publication *p;
+
         write_lock_bh(&tipc_nametbl_lock);
 	dbg("node_is_down: withdrawing %u, %u, %u\n", 
 	    publ->type, publ->lower, publ->upper);
         publ->key += 1222345;
 	p = tipc_nametbl_remove_publ(publ->type, publ->lower, 
 				     publ->node, publ->ref, publ->key);
-        assert(p == publ);
 	write_unlock_bh(&tipc_nametbl_lock);
-	kfree(publ);
+
+        if (p != publ) {
+		err("Unable to remove publication from failed node\n"
+		    "(type=%u, lower=%u, node=0x%x, ref=%u, key=%u)\n",
+		    publ->type, publ->lower, publ->node, publ->ref, publ->key);
+	}
+
+	if (p) {
+		kfree(p);
+	}
 }
 
 /**
@@ -275,6 +283,12 @@ void tipc_named_recv(struct sk_buff *buf
 			if (publ) {
 				tipc_nodesub_unsubscribe(&publ->subscr);
         			kfree(publ);
+			} else {
+				err("Unable to remove publication by node 0x%x\n"
+				    "(type=%u, lower=%u, ref=%u, key=%u)\n",
+				    msg_orignode(msg),
+				    ntohl(item->type), ntohl(item->lower),
+				    ntohl(item->ref), ntohl(item->key));
 			}
 		} else {
 			warn("tipc_named_recv: unknown msg\n");
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 0511436..e90dc80 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -71,7 +71,7 @@ struct sub_seq {
  * @sseq: pointer to dynamically-sized array of sub-sequences of this 'type';
  *        sub-sequences are sorted in ascending order
  * @alloc: number of sub-sequences currently in array
- * @first_free: upper bound of highest sub-sequence + 1
+ * @first_free: array index of first unused sub-sequence entry
  * @ns_list: links to adjacent name sequences in hash chain
  * @subscriptions: list of subscriptions for this 'type'
  * @lock: spinlock controlling access to name sequence structure
@@ -175,7 +175,7 @@ static struct name_seq *tipc_nameseq_cre
 	nseq->lock = SPIN_LOCK_UNLOCKED;
 	nseq->type = type;
 	nseq->sseqs = sseq;
-	dbg("tipc_nameseq_create() nseq = %x type %u, ssseqs %x, ff: %u\n",
+	dbg("tipc_nameseq_create(): nseq = %p, type %u, ssseqs %p, ff: %u\n",
 	    nseq, type, nseq->sseqs, nseq->first_free);
 	nseq->alloc = 1;
 	INIT_HLIST_NODE(&nseq->ns_list);
@@ -253,16 +253,16 @@ static struct publication *tipc_nameseq_
 	struct sub_seq *sseq;
 	int created_subseq = 0;
 
-	assert(nseq->first_free <= nseq->alloc);
 	sseq = nameseq_find_subseq(nseq, lower);
-	dbg("nameseq_ins: for seq %x,<%u,%u>, found sseq %x\n",
+	dbg("nameseq_ins: for seq %p, {%u,%u}, found sseq %p\n",
 	    nseq, type, lower, sseq);
 	if (sseq) {
 
 		/* Lower end overlaps existing entry => need an exact match */
 
 		if ((sseq->lower != lower) || (sseq->upper != upper)) {
-			warn("Overlapping publ <%u,%u,%u>\n", type, lower, upper);
+			warn("Cannot publish {%u,%u,%u}, overlap error\n",
+			     type, lower, upper);
 			return NULL;
 		}
 	} else {
@@ -277,7 +277,8 @@ static struct publication *tipc_nameseq_
 
 		if ((inspos < nseq->first_free) &&
 		    (upper >= nseq->sseqs[inspos].lower)) {
-			warn("Overlapping publ <%u,%u,%u>\n", type, lower, upper);
+			warn("Cannot publish {%u,%u,%u}, overlap error\n",
+			     type, lower, upper);
 			return NULL;
 		}
 
@@ -287,7 +288,8 @@ static struct publication *tipc_nameseq_
 			struct sub_seq *sseqs = tipc_subseq_alloc(nseq->alloc * 2);
 
 			if (!sseqs) {
-				warn("Memory squeeze; failed to create sub-sequence\n");
+				warn("Cannot publish {%u,%u,%u}, no memory\n",
+				     type, lower, upper);
 				return NULL;
 			}
 			dbg("Allocated %u more sseqs\n", nseq->alloc);
@@ -311,7 +313,7 @@ static struct publication *tipc_nameseq_
 		sseq->upper = upper;
 		created_subseq = 1;
 	}
-	dbg("inserting (%u %u %u) from %x:%u into sseq %x(%u,%u) of seq %x\n",
+	dbg("inserting {%u,%u,%u} from <0x%x:%u> into sseq %p(%u,%u) of seq %p\n",
 	    type, lower, upper, node, port, sseq,
 	    sseq->lower, sseq->upper, nseq);
 
@@ -320,7 +322,7 @@ static struct publication *tipc_nameseq_
 	publ = publ_create(type, lower, upper, scope, node, port, key);
 	if (!publ)
 		return NULL;
-	dbg("inserting publ %x, node=%x publ->node=%x, subscr->node=%x\n",
+	dbg("inserting publ %p, node=0x%x publ->node=0x%x, subscr->node=%p\n",
 	    publ, node, publ->node, publ->subscr.node);
 
 	if (!sseq->zone_list)
@@ -367,45 +369,47 @@ static struct publication *tipc_nameseq_
 
 /**
  * tipc_nameseq_remove_publ -
+ * 
+ * NOTE: There may be cases where TIPC is asked to remove a publication
+ * that is not in the name table.  For example, if another node issues a
+ * publication for a name sequence that overlaps an existing name sequence
+ * the publication will not be recorded, which means the publication won't
+ * be found when the name sequence is later withdrawn by that node.
+ * A failed withdraw request simply returns a failure indication and lets the
+ * caller issue any error or warning messages associated with such a problem.
  */
 
 static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 inst,
 						    u32 node, u32 ref, u32 key)
 {
 	struct publication *publ;
+	struct publication *curr;
 	struct publication *prev;
 	struct sub_seq *sseq = nameseq_find_subseq(nseq, inst);
 	struct sub_seq *free;
 	struct subscription *s, *st;
 	int removed_subseq = 0;
 
-	assert(nseq);
-
-	if (!sseq) {
-		int i;
-
-		warn("Withdraw unknown <%u,%u>?\n", nseq->type, inst);
-		assert(nseq->sseqs);
-		dbg("Dumping subseqs %x for %x, alloc = %u,ff=%u\n",
-		    nseq->sseqs, nseq, nseq->alloc, 
-		    nseq->first_free);
-		for (i = 0; i < nseq->first_free; i++) {
-			dbg("Subseq %u(%x): lower = %u,upper = %u\n",
-			    i, &nseq->sseqs[i], nseq->sseqs[i].lower,
-			    nseq->sseqs[i].upper);
-		}
+	if (!sseq)
 		return NULL;
-	}
-	dbg("nameseq_remove: seq: %x, sseq %x, <%u,%u> key %u\n",
+
+	dbg("tipc_nameseq_remove_publ: seq: %p, sseq %p, {%u,%u}, key %u\n",
 	    nseq, sseq, nseq->type, inst, key);
 
+	/* Remove publication from zone scope list */
+
 	prev = sseq->zone_list;
 	publ = sseq->zone_list->zone_list_next;
 	while ((publ->key != key) || (publ->ref != ref) || 
 	       (publ->node && (publ->node != node))) {
 		prev = publ;
 		publ = publ->zone_list_next;
-		assert(prev != sseq->zone_list);
+		if (prev == sseq->zone_list) {
+			
+			/* Prevent endless loop if publication not found */
+
+			return NULL;
+		}
 	}
 	if (publ != sseq->zone_list)
 		prev->zone_list_next = publ->zone_list_next;
@@ -416,14 +420,24 @@ static struct publication *tipc_nameseq_
 		sseq->zone_list = NULL;
 	}
 
+	/* Remove publication from cluster scope list, if present */
+
 	if (in_own_cluster(node)) {
 		prev = sseq->cluster_list;
-		publ = sseq->cluster_list->cluster_list_next;
-		while ((publ->key != key) || (publ->ref != ref) || 
-		       (publ->node && (publ->node != node))) {
-			prev = publ;
-			publ = publ->cluster_list_next;
-			assert(prev != sseq->cluster_list);
+		curr = sseq->cluster_list->cluster_list_next;
+		while (curr != publ) {
+			prev = curr;
+			curr = curr->cluster_list_next;
+			if (prev == sseq->cluster_list) {
+
+				/* Prevent endless loop for malformed list */
+
+				err("Unable to de-list cluster publication\n"
+				    "{%u%u}, node=0x%x, ref=%u, key=%u)\n",
+				    publ->type, publ->lower, publ->node, 
+				    publ->ref, publ->key);
+				goto end_cluster;
+			}
 		}
 		if (publ != sseq->cluster_list)
 			prev->cluster_list_next = publ->cluster_list_next;
@@ -434,15 +448,26 @@ static struct publication *tipc_nameseq_
 			sseq->cluster_list = NULL;
 		}
 	}
+end_cluster:
+
+	/* Remove publication from node scope list, if present */
 
 	if (node == tipc_own_addr) {
 		prev = sseq->node_list;
-		publ = sseq->node_list->node_list_next;
-		while ((publ->key != key) || (publ->ref != ref) || 
-		       (publ->node && (publ->node != node))) {
-			prev = publ;
-			publ = publ->node_list_next;
-			assert(prev != sseq->node_list);
+		curr = sseq->node_list->node_list_next;
+		while (curr != publ) {
+			prev = curr;
+			curr = curr->node_list_next;
+			if (prev == sseq->node_list) {
+
+				/* Prevent endless loop for malformed list */
+
+				err("Unable to de-list node publication\n"
+				    "{%u%u}, node=0x%x, ref=%u, key=%u)\n",
+				    publ->type, publ->lower, publ->node, 
+				    publ->ref, publ->key);
+				goto end_node;
+			}
 		}
 		if (publ != sseq->node_list)
 			prev->node_list_next = publ->node_list_next;
@@ -453,22 +478,18 @@ static struct publication *tipc_nameseq_
 			sseq->node_list = NULL;
 		}
 	}
-	assert(!publ->node || (publ->node == node));
-	assert(publ->ref == ref);
-	assert(publ->key == key);
+end_node:
 
-	/* 
-	 * Contract subseq list if no more publications:
-	 */
-	if (!sseq->node_list && !sseq->cluster_list && !sseq->zone_list) {
+	/* Contract subseq list if no more publications for that subseq */
+
+	if (!sseq->zone_list) {
 		free = &nseq->sseqs[nseq->first_free--];
 		memmove(sseq, sseq + 1, (free - (sseq + 1)) * sizeof (*sseq));
 		removed_subseq = 1;
 	}
 
-	/* 
-	 * Any subscriptions waiting ? 
-	 */
+	/* Notify any waiting subscriptions */
+
 	list_for_each_entry_safe(s, st, &nseq->subscriptions, nameseq_list) {
 		tipc_subscr_report_overlap(s,
 					   publ->lower,
@@ -478,6 +499,7 @@ static struct publication *tipc_nameseq_
 					   publ->node,
 					   removed_subseq);
 	}
+
 	return publ;
 }
 
@@ -530,7 +552,7 @@ static struct name_seq *nametbl_find_seq
 	seq_head = &table.types[hash(type)];
 	hlist_for_each_entry(ns, seq_node, seq_head, ns_list) {
 		if (ns->type == type) {
-			dbg("found %x\n", ns);
+			dbg("found %p\n", ns);
 			return ns;
 		}
 	}
@@ -543,22 +565,21 @@ struct publication *tipc_nametbl_insert_
 {
 	struct name_seq *seq = nametbl_find_seq(type);
 
-	dbg("ins_publ: <%u,%x,%x> found %x\n", type, lower, upper, seq);
+	dbg("tipc_nametbl_insert_publ: {%u,%u,%u} found %p\n", type, lower, upper, seq);
 	if (lower > upper) {
-		warn("Failed to publish illegal <%u,%u,%u>\n",
+		warn("Failed to publish illegal {%u,%u,%u}\n",
 		     type, lower, upper);
 		return NULL;
 	}
 
-	dbg("Publishing <%u,%u,%u> from %x\n", type, lower, upper, node);
+	dbg("Publishing {%u,%u,%u} from 0x%x\n", type, lower, upper, node);
 	if (!seq) {
 		seq = tipc_nameseq_create(type, &table.types[hash(type)]);
-		dbg("tipc_nametbl_insert_publ: created %x\n", seq);
+		dbg("tipc_nametbl_insert_publ: created %p\n", seq);
 	}
 	if (!seq)
 		return NULL;
 
-	assert(seq->type == type);
 	return tipc_nameseq_insert_publ(seq, type, lower, upper,
 					scope, node, port, key);
 }
@@ -572,7 +593,7 @@ struct publication *tipc_nametbl_remove_
 	if (!seq)
 		return NULL;
 
-	dbg("Withdrawing <%u,%u> from %x\n", type, lower, node);
+	dbg("Withdrawing {%u,%u} from 0x%x\n", type, lower, node);
 	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
 
 	if (!seq->first_free && list_empty(&seq->subscriptions)) {
@@ -743,7 +764,7 @@ struct publication *tipc_nametbl_publish
 		return NULL;
 	}
 	if ((type < TIPC_RESERVED_TYPES) && !atomic_read(&rsv_publ_ok)) {
-		warn("Failed to publish reserved name <%u,%u,%u>\n",
+		warn("Publication failed, reserved name {%u,%u,%u}\n",
 		     type, lower, upper);
 		return NULL;
 	}
@@ -767,10 +788,10 @@ int tipc_nametbl_withdraw(u32 type, u32 
 {
 	struct publication *publ;
 
-	dbg("tipc_nametbl_withdraw:<%d,%d,%d>\n", type, lower, key);
+	dbg("tipc_nametbl_withdraw: {%u,%u}, key=%u\n", type, lower, key);
 	write_lock_bh(&tipc_nametbl_lock);
 	publ = tipc_nametbl_remove_publ(type, lower, tipc_own_addr, ref, key);
-	if (publ) {
+	if (likely(publ)) {
 		table.local_publ_count--;
 		if (publ->scope != TIPC_NODE_SCOPE)
 			tipc_named_withdraw(publ);
@@ -780,6 +801,9 @@ int tipc_nametbl_withdraw(u32 type, u32 
 		return 1;
 	}
 	write_unlock_bh(&tipc_nametbl_lock);
+	err("Unable to remove local publication\n"
+	    "(type=%u, lower=%u, ref=%u, key=%u)\n",
+	    type, lower, ref, key);
 	return 0;
 }
 
@@ -787,8 +811,7 @@ int tipc_nametbl_withdraw(u32 type, u32 
  * tipc_nametbl_subscribe - add a subscription object to the name table
  */
 
-void
-tipc_nametbl_subscribe(struct subscription *s)
+void tipc_nametbl_subscribe(struct subscription *s)
 {
 	u32 type = s->seq.type;
 	struct name_seq *seq;
@@ -800,11 +823,13 @@ tipc_nametbl_subscribe(struct subscripti
 	}
         if (seq){
                 spin_lock_bh(&seq->lock);
-                dbg("tipc_nametbl_subscribe:found %x for <%u,%u,%u>\n",
+                dbg("tipc_nametbl_subscribe:found %p for {%u,%u,%u}\n",
                     seq, type, s->seq.lower, s->seq.upper);
-                assert(seq->type == type);
                 tipc_nameseq_subscribe(seq, s);
                 spin_unlock_bh(&seq->lock);
+        } else {
+		warn("Failed to create subscription for {%u,%u,%u}\n",
+		     s->seq.type, s->seq.lower, s->seq.upper);
         }
         write_unlock_bh(&tipc_nametbl_lock);
 }
@@ -813,8 +838,7 @@ tipc_nametbl_subscribe(struct subscripti
  * tipc_nametbl_unsubscribe - remove a subscription object from name table
  */
 
-void
-tipc_nametbl_unsubscribe(struct subscription *s)
+void tipc_nametbl_unsubscribe(struct subscription *s)
 {
 	struct name_seq *seq;
 
@@ -1049,35 +1073,20 @@ int tipc_nametbl_init(void)
 
 void tipc_nametbl_stop(void)
 {
-	struct hlist_head *seq_head;
-	struct hlist_node *seq_node;
-	struct hlist_node *tmp;
-	struct name_seq *seq;
 	u32 i;
 
 	if (!table.types)
 		return;
 
+	/* Verify name table is empty, then release it */
+
 	write_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < tipc_nametbl_size; i++) {
-		seq_head = &table.types[i];
-		hlist_for_each_entry_safe(seq, seq_node, tmp, seq_head, ns_list) {
-			struct sub_seq *sseq = seq->sseqs;
-
-			for (; sseq != &seq->sseqs[seq->first_free]; sseq++) {
-				struct publication *publ = sseq->zone_list;
-				assert(publ);
-				do {
-					struct publication *next =
-						publ->zone_list_next;
-					kfree(publ);
-					publ = next;
-				}
-				while (publ != sseq->zone_list);
-			}
-		}
+		if (!hlist_empty(&table.types[i]))
+			err("tipc_nametbl_stop(): hash chain %u is non-null\n", i);
 	}
 	kfree(table.types);
 	table.types = NULL;
 	write_unlock_bh(&tipc_nametbl_lock);
 }
+
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 0d5db06..b54462b 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -234,7 +234,6 @@ struct node *tipc_node_attach_link(struc
 		u32 bearer_id = l_ptr->b_ptr->identity;
 		char addr_string[16];
 
-                assert(bearer_id < MAX_BEARERS);
                 if (n_ptr->link_cnt >= 2) {
 			char addr_string[16];
 
@@ -314,7 +313,7 @@ static void node_established_contact(str
 	struct cluster *c_ptr;
 
 	dbg("node_established_contact:-> %x\n", n_ptr->addr);
-	if (!tipc_node_has_active_routes(n_ptr)) { 
+	if (!tipc_node_has_active_routes(n_ptr) && in_own_cluster(n_ptr->addr)) { 
 		tipc_k_signal((Handler)tipc_named_node_up, n_ptr->addr);
 	}
 
diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
index cff4068..cc3fff3 100644
--- a/net/tipc/node_subscr.c
+++ b/net/tipc/node_subscr.c
@@ -47,18 +47,19 @@ #include "addr.h"
 void tipc_nodesub_subscribe(struct node_subscr *node_sub, u32 addr, 
 		       void *usr_handle, net_ev_handler handle_down)
 {
-	node_sub->node = NULL;
-	if (addr == tipc_own_addr)
+	if (addr == tipc_own_addr) {
+		node_sub->node = NULL;
 		return;
-	if (!tipc_addr_node_valid(addr)) {
-		warn("node_subscr with illegal %x\n", addr);
+	}
+	
+	node_sub->node = tipc_node_find(addr);
+	if (!node_sub->node) {
+		warn("Node subscription rejected, unknown node 0x%x\n", addr);
 		return;
 	}
-
 	node_sub->handle_node_down = handle_down;
 	node_sub->usr_handle = usr_handle;
-	node_sub->node = tipc_node_find(addr);
-	assert(node_sub->node);
+
 	tipc_node_lock(node_sub->node);
 	list_add_tail(&node_sub->nodesub_list, &node_sub->node->nsub);
 	tipc_node_unlock(node_sub->node);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 99846a1..3aab67a 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -168,7 +168,6 @@ void tipc_port_recv_mcast(struct sk_buff
 	struct port_list *item = dp;
 	int cnt = 0;
 
-	assert(buf);
 	msg = buf_msg(buf);
 
 	/* Create destination port list, if one wasn't supplied */
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 33bbf50..d2f0cce 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -127,7 +127,14 @@ u32 tipc_ref_acquire(void *object, spinl
 	u32 next_plus_upper;
 	u32 reference = 0;
 
-	assert(tipc_ref_table.entries && object);
+	if (!object) {
+		err("Attempt to acquire reference to non-existent object\n");
+		return 0;
+	}
+	if (!tipc_ref_table.entries) {
+		err("Reference table not found during acquisition attempt\n");
+		return 0;
+	}
 
 	write_lock_bh(&ref_table_lock);
 	if (tipc_ref_table.first_free) {
@@ -162,15 +169,28 @@ void tipc_ref_discard(u32 ref)
 	u32 index; 
 	u32 index_mask;
 
-	assert(tipc_ref_table.entries);
-	assert(ref != 0);
+	if (!ref) {
+		err("Attempt to discard reference 0\n");
+		return;
+	}
+	if (!tipc_ref_table.entries) {
+		err("Reference table not found during discard attempt\n");
+		return;
+	}
 
 	write_lock_bh(&ref_table_lock);
 	index_mask = tipc_ref_table.index_mask;
 	index = ref & index_mask;
 	entry = &(tipc_ref_table.entries[index]);
-	assert(entry->object != 0);
-	assert(entry->data.reference == ref);
+
+	if (!entry->object) {
+		err("Attempt to discard reference to non-existent object\n");
+		goto exit;
+	}
+	if (entry->data.reference != ref) {
+		err("Attempt to discard non-existent reference\n");
+		goto exit;
+	}
 
 	/* mark entry as unused */
 	entry->object = NULL;
@@ -184,6 +204,7 @@ void tipc_ref_discard(u32 ref)
 
 	/* increment upper bits of entry to invalidate subsequent references */
 	entry->data.next_plus_upper = (ref & ~index_mask) + (index_mask + 1);
+exit:
 	write_unlock_bh(&ref_table_lock);
 }
 
-- 
1.4.0

