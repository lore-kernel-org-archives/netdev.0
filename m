From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/17] tipc: Combine port structure with tipc_port structure
Date: Wed, 23 Feb 2011 20:26:29 -0500
Message-ID: <1298510805-20630-2-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34448 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755569Ab1BXB1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:03 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Merge two distinct structures containing information about a TIPC port
into a single structure. The structures were previously kept separate
so that public information about a port could be made available to
applications using TIPC's native API, while the remaining information
was kept private for use by TIPC itself. However, now that the native
API has been removed there is no longer any need for this somewhat
confusing arrangement.

Since one of the structures was already embedded within the other, the
change largely involves replacing instances of "publ.foo" with "foo".
The changes do not otherwise alter the operation of TIPC ports.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c   |   46 +++++-----
 net/tipc/link.h   |    6 +-
 net/tipc/port.c   |  234 ++++++++++++++++++++++++++--------------------------
 net/tipc/port.h   |   67 +++++++---------
 net/tipc/subscr.c |    6 +-
 5 files changed, 175 insertions(+), 184 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 18702f5..e30770d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2,7 +2,7 @@
  * net/tipc/link.c: TIPC link code
  *
  * Copyright (c) 1996-2007, Ericsson AB
- * Copyright (c) 2004-2007, Wind River Systems
+ * Copyright (c) 2004-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -90,7 +90,7 @@ static void link_handle_out_of_seq_msg(struct link *l_ptr,
 static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf);
 static int  link_recv_changeover_msg(struct link **l_ptr, struct sk_buff **buf);
 static void link_set_supervision_props(struct link *l_ptr, u32 tolerance);
-static int  link_send_sections_long(struct port *sender,
+static int  link_send_sections_long(struct tipc_port *sender,
 				    struct iovec const *msg_sect,
 				    u32 num_sect, u32 destnode);
 static void link_check_defragm_bufs(struct link *l_ptr);
@@ -406,7 +406,7 @@ static void link_start(struct link *l_ptr)
 
 static int link_schedule_port(struct link *l_ptr, u32 origport, u32 sz)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	spin_lock_bh(&tipc_port_list_lock);
 	p_ptr = tipc_port_lock(origport);
@@ -415,7 +415,7 @@ static int link_schedule_port(struct link *l_ptr, u32 origport, u32 sz)
 			goto exit;
 		if (!list_empty(&p_ptr->wait_list))
 			goto exit;
-		p_ptr->publ.congested = 1;
+		p_ptr->congested = 1;
 		p_ptr->waiting_pkts = 1 + ((sz - 1) / l_ptr->max_pkt);
 		list_add_tail(&p_ptr->wait_list, &l_ptr->waiting_ports);
 		l_ptr->stats.link_congs++;
@@ -428,8 +428,8 @@ exit:
 
 void tipc_link_wakeup_ports(struct link *l_ptr, int all)
 {
-	struct port *p_ptr;
-	struct port *temp_p_ptr;
+	struct tipc_port *p_ptr;
+	struct tipc_port *temp_p_ptr;
 	int win = l_ptr->queue_limit[0] - l_ptr->out_queue_size;
 
 	if (all)
@@ -445,11 +445,11 @@ void tipc_link_wakeup_ports(struct link *l_ptr, int all)
 		if (win <= 0)
 			break;
 		list_del_init(&p_ptr->wait_list);
-		spin_lock_bh(p_ptr->publ.lock);
-		p_ptr->publ.congested = 0;
-		p_ptr->wakeup(&p_ptr->publ);
+		spin_lock_bh(p_ptr->lock);
+		p_ptr->congested = 0;
+		p_ptr->wakeup(p_ptr);
 		win -= p_ptr->waiting_pkts;
-		spin_unlock_bh(p_ptr->publ.lock);
+		spin_unlock_bh(p_ptr->lock);
 	}
 
 exit:
@@ -1027,12 +1027,12 @@ int tipc_send_buf_fast(struct sk_buff *buf, u32 destnode)
  * except for total message length.
  * Returns user data length or errno.
  */
-int tipc_link_send_sections_fast(struct port *sender,
+int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
 				 u32 destaddr)
 {
-	struct tipc_msg *hdr = &sender->publ.phdr;
+	struct tipc_msg *hdr = &sender->phdr;
 	struct link *l_ptr;
 	struct sk_buff *buf;
 	struct tipc_node *node;
@@ -1045,7 +1045,7 @@ again:
 	 * (Must not hold any locks while building message.)
 	 */
 
-	res = tipc_msg_build(hdr, msg_sect, num_sect, sender->publ.max_pkt,
+	res = tipc_msg_build(hdr, msg_sect, num_sect, sender->max_pkt,
 			!sender->user_port, &buf);
 
 	read_lock_bh(&tipc_net_lock);
@@ -1056,7 +1056,7 @@ again:
 		if (likely(l_ptr)) {
 			if (likely(buf)) {
 				res = link_send_buf_fast(l_ptr, buf,
-							 &sender->publ.max_pkt);
+							 &sender->max_pkt);
 				if (unlikely(res < 0))
 					buf_discard(buf);
 exit:
@@ -1075,7 +1075,7 @@ exit:
 			if (link_congested(l_ptr) ||
 			    !list_empty(&l_ptr->b_ptr->cong_links)) {
 				res = link_schedule_port(l_ptr,
-							 sender->publ.ref, res);
+							 sender->ref, res);
 				goto exit;
 			}
 
@@ -1084,12 +1084,12 @@ exit:
 			 * then re-try fast path or fragment the message
 			 */
 
-			sender->publ.max_pkt = l_ptr->max_pkt;
+			sender->max_pkt = l_ptr->max_pkt;
 			tipc_node_unlock(node);
 			read_unlock_bh(&tipc_net_lock);
 
 
-			if ((msg_hdr_sz(hdr) + res) <= sender->publ.max_pkt)
+			if ((msg_hdr_sz(hdr) + res) <= sender->max_pkt)
 				goto again;
 
 			return link_send_sections_long(sender, msg_sect,
@@ -1123,14 +1123,14 @@ exit:
  *
  * Returns user data length or errno.
  */
-static int link_send_sections_long(struct port *sender,
+static int link_send_sections_long(struct tipc_port *sender,
 				   struct iovec const *msg_sect,
 				   u32 num_sect,
 				   u32 destaddr)
 {
 	struct link *l_ptr;
 	struct tipc_node *node;
-	struct tipc_msg *hdr = &sender->publ.phdr;
+	struct tipc_msg *hdr = &sender->phdr;
 	u32 dsz = msg_data_sz(hdr);
 	u32 max_pkt, fragm_sz, rest;
 	struct tipc_msg fragm_hdr;
@@ -1142,7 +1142,7 @@ static int link_send_sections_long(struct port *sender,
 
 again:
 	fragm_no = 1;
-	max_pkt = sender->publ.max_pkt - INT_H_SIZE;
+	max_pkt = sender->max_pkt - INT_H_SIZE;
 		/* leave room for tunnel header in case of link changeover */
 	fragm_sz = max_pkt - INT_H_SIZE;
 		/* leave room for fragmentation header in each fragment */
@@ -1157,7 +1157,7 @@ again:
 
 	tipc_msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
 		 INT_H_SIZE, msg_destnode(hdr));
-	msg_set_link_selector(&fragm_hdr, sender->publ.ref);
+	msg_set_link_selector(&fragm_hdr, sender->ref);
 	msg_set_size(&fragm_hdr, max_pkt);
 	msg_set_fragm_no(&fragm_hdr, 1);
 
@@ -1238,13 +1238,13 @@ error:
 	node = tipc_node_find(destaddr);
 	if (likely(node)) {
 		tipc_node_lock(node);
-		l_ptr = node->active_links[sender->publ.ref & 1];
+		l_ptr = node->active_links[sender->ref & 1];
 		if (!l_ptr) {
 			tipc_node_unlock(node);
 			goto reject;
 		}
 		if (l_ptr->max_pkt < max_pkt) {
-			sender->publ.max_pkt = l_ptr->max_pkt;
+			sender->max_pkt = l_ptr->max_pkt;
 			tipc_node_unlock(node);
 			for (; buf_chain; buf_chain = buf) {
 				buf = buf_chain->next;
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 70967e6..85fd3bc 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -2,7 +2,7 @@
  * net/tipc/link.h: Include file for TIPC link code
  *
  * Copyright (c) 1995-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -211,7 +211,7 @@ struct link {
 	} stats;
 };
 
-struct port;
+struct tipc_port;
 
 struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 			      const struct tipc_media_addr *media_addr);
@@ -230,7 +230,7 @@ void tipc_link_reset(struct link *l_ptr);
 int tipc_link_send(struct sk_buff *buf, u32 dest, u32 selector);
 int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf);
 u32 tipc_link_get_max_pkt(u32 dest, u32 selector);
-int tipc_link_send_sections_fast(struct port *sender,
+int tipc_link_send_sections_fast(struct tipc_port *sender,
 				 struct iovec const *msg_sect,
 				 const u32 num_sect,
 				 u32 destnode);
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 067bab2..aff5dc0 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -2,7 +2,7 @@
  * net/tipc/port.c: TIPC port code
  *
  * Copyright (c) 1992-2007, Ericsson AB
- * Copyright (c) 2004-2008, Wind River Systems
+ * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -54,29 +54,29 @@ static DEFINE_SPINLOCK(queue_lock);
 
 static LIST_HEAD(ports);
 static void port_handle_node_down(unsigned long ref);
-static struct sk_buff *port_build_self_abort_msg(struct port *, u32 err);
-static struct sk_buff *port_build_peer_abort_msg(struct port *, u32 err);
+static struct sk_buff *port_build_self_abort_msg(struct tipc_port *, u32 err);
+static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *, u32 err);
 static void port_timeout(unsigned long ref);
 
 
-static u32 port_peernode(struct port *p_ptr)
+static u32 port_peernode(struct tipc_port *p_ptr)
 {
-	return msg_destnode(&p_ptr->publ.phdr);
+	return msg_destnode(&p_ptr->phdr);
 }
 
-static u32 port_peerport(struct port *p_ptr)
+static u32 port_peerport(struct tipc_port *p_ptr)
 {
-	return msg_destport(&p_ptr->publ.phdr);
+	return msg_destport(&p_ptr->phdr);
 }
 
-static u32 port_out_seqno(struct port *p_ptr)
+static u32 port_out_seqno(struct tipc_port *p_ptr)
 {
-	return msg_transp_seqno(&p_ptr->publ.phdr);
+	return msg_transp_seqno(&p_ptr->phdr);
 }
 
-static void port_incr_out_seqno(struct port *p_ptr)
+static void port_incr_out_seqno(struct tipc_port *p_ptr)
 {
-	struct tipc_msg *m = &p_ptr->publ.phdr;
+	struct tipc_msg *m = &p_ptr->phdr;
 
 	if (likely(!msg_routed(m)))
 		return;
@@ -94,7 +94,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 	struct sk_buff *buf;
 	struct sk_buff *ibuf = NULL;
 	struct port_list dports = {0, NULL, };
-	struct port *oport = tipc_port_deref(ref);
+	struct tipc_port *oport = tipc_port_deref(ref);
 	int ext_targets;
 	int res;
 
@@ -103,7 +103,7 @@ int tipc_multicast(u32 ref, struct tipc_name_seq const *seq,
 
 	/* Create multicast message */
 
-	hdr = &oport->publ.phdr;
+	hdr = &oport->phdr;
 	msg_set_type(hdr, TIPC_MCAST_MSG);
 	msg_set_nametype(hdr, seq->type);
 	msg_set_namelower(hdr, seq->lower);
@@ -211,7 +211,7 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 			void (*wakeup)(struct tipc_port *),
 			const u32 importance)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 	u32 ref;
 
@@ -220,17 +220,17 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 		warn("Port creation failed, no memory\n");
 		return NULL;
 	}
-	ref = tipc_ref_acquire(p_ptr, &p_ptr->publ.lock);
+	ref = tipc_ref_acquire(p_ptr, &p_ptr->lock);
 	if (!ref) {
 		warn("Port creation failed, reference table exhausted\n");
 		kfree(p_ptr);
 		return NULL;
 	}
 
-	p_ptr->publ.usr_handle = usr_handle;
-	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
-	p_ptr->publ.ref = ref;
-	msg = &p_ptr->publ.phdr;
+	p_ptr->usr_handle = usr_handle;
+	p_ptr->max_pkt = MAX_PKT_DEFAULT;
+	p_ptr->ref = ref;
+	msg = &p_ptr->phdr;
 	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_origport(msg, ref);
 	p_ptr->last_in_seqno = 41;
@@ -246,12 +246,12 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	INIT_LIST_HEAD(&p_ptr->port_list);
 	list_add_tail(&p_ptr->port_list, &ports);
 	spin_unlock_bh(&tipc_port_list_lock);
-	return &(p_ptr->publ);
+	return p_ptr;
 }
 
 int tipc_deleteport(u32 ref)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
 
 	tipc_withdraw(ref, 0, NULL);
@@ -263,7 +263,7 @@ int tipc_deleteport(u32 ref)
 	tipc_port_unlock(p_ptr);
 
 	k_cancel_timer(&p_ptr->timer);
-	if (p_ptr->publ.connected) {
+	if (p_ptr->connected) {
 		buf = port_build_peer_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
 		tipc_nodesub_unsubscribe(&p_ptr->subscription);
 	}
@@ -279,14 +279,14 @@ int tipc_deleteport(u32 ref)
 	return 0;
 }
 
-static int port_unreliable(struct port *p_ptr)
+static int port_unreliable(struct tipc_port *p_ptr)
 {
-	return msg_src_droppable(&p_ptr->publ.phdr);
+	return msg_src_droppable(&p_ptr->phdr);
 }
 
 int tipc_portunreliable(u32 ref, unsigned int *isunreliable)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
@@ -298,24 +298,24 @@ int tipc_portunreliable(u32 ref, unsigned int *isunreliable)
 
 int tipc_set_portunreliable(u32 ref, unsigned int isunreliable)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	msg_set_src_droppable(&p_ptr->publ.phdr, (isunreliable != 0));
+	msg_set_src_droppable(&p_ptr->phdr, (isunreliable != 0));
 	tipc_port_unlock(p_ptr);
 	return 0;
 }
 
-static int port_unreturnable(struct port *p_ptr)
+static int port_unreturnable(struct tipc_port *p_ptr)
 {
-	return msg_dest_droppable(&p_ptr->publ.phdr);
+	return msg_dest_droppable(&p_ptr->phdr);
 }
 
 int tipc_portunreturnable(u32 ref, unsigned int *isunrejectable)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
@@ -327,12 +327,12 @@ int tipc_portunreturnable(u32 ref, unsigned int *isunrejectable)
 
 int tipc_set_portunreturnable(u32 ref, unsigned int isunrejectable)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	msg_set_dest_droppable(&p_ptr->publ.phdr, (isunrejectable != 0));
+	msg_set_dest_droppable(&p_ptr->phdr, (isunrejectable != 0));
 	tipc_port_unlock(p_ptr);
 	return 0;
 }
@@ -413,10 +413,10 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	/* send self-abort message when rejecting on a connected port */
 	if (msg_connected(msg)) {
 		struct sk_buff *abuf = NULL;
-		struct port *p_ptr = tipc_port_lock(msg_destport(msg));
+		struct tipc_port *p_ptr = tipc_port_lock(msg_destport(msg));
 
 		if (p_ptr) {
-			if (p_ptr->publ.connected)
+			if (p_ptr->connected)
 				abuf = port_build_self_abort_msg(p_ptr, err);
 			tipc_port_unlock(p_ptr);
 		}
@@ -429,7 +429,7 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 	return data_sz;
 }
 
-int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
+int tipc_port_reject_sections(struct tipc_port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err)
 {
@@ -446,13 +446,13 @@ int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
 
 static void port_timeout(unsigned long ref)
 {
-	struct port *p_ptr = tipc_port_lock(ref);
+	struct tipc_port *p_ptr = tipc_port_lock(ref);
 	struct sk_buff *buf = NULL;
 
 	if (!p_ptr)
 		return;
 
-	if (!p_ptr->publ.connected) {
+	if (!p_ptr->connected) {
 		tipc_port_unlock(p_ptr);
 		return;
 	}
@@ -463,7 +463,7 @@ static void port_timeout(unsigned long ref)
 	} else {
 		buf = port_build_proto_msg(port_peerport(p_ptr),
 					   port_peernode(p_ptr),
-					   p_ptr->publ.ref,
+					   p_ptr->ref,
 					   tipc_own_addr,
 					   CONN_MANAGER,
 					   CONN_PROBE,
@@ -481,7 +481,7 @@ static void port_timeout(unsigned long ref)
 
 static void port_handle_node_down(unsigned long ref)
 {
-	struct port *p_ptr = tipc_port_lock(ref);
+	struct tipc_port *p_ptr = tipc_port_lock(ref);
 	struct sk_buff *buf = NULL;
 
 	if (!p_ptr)
@@ -492,15 +492,15 @@ static void port_handle_node_down(unsigned long ref)
 }
 
 
-static struct sk_buff *port_build_self_abort_msg(struct port *p_ptr, u32 err)
+static struct sk_buff *port_build_self_abort_msg(struct tipc_port *p_ptr, u32 err)
 {
-	u32 imp = msg_importance(&p_ptr->publ.phdr);
+	u32 imp = msg_importance(&p_ptr->phdr);
 
-	if (!p_ptr->publ.connected)
+	if (!p_ptr->connected)
 		return NULL;
 	if (imp < TIPC_CRITICAL_IMPORTANCE)
 		imp++;
-	return port_build_proto_msg(p_ptr->publ.ref,
+	return port_build_proto_msg(p_ptr->ref,
 				    tipc_own_addr,
 				    port_peerport(p_ptr),
 				    port_peernode(p_ptr),
@@ -512,17 +512,17 @@ static struct sk_buff *port_build_self_abort_msg(struct port *p_ptr, u32 err)
 }
 
 
-static struct sk_buff *port_build_peer_abort_msg(struct port *p_ptr, u32 err)
+static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 err)
 {
-	u32 imp = msg_importance(&p_ptr->publ.phdr);
+	u32 imp = msg_importance(&p_ptr->phdr);
 
-	if (!p_ptr->publ.connected)
+	if (!p_ptr->connected)
 		return NULL;
 	if (imp < TIPC_CRITICAL_IMPORTANCE)
 		imp++;
 	return port_build_proto_msg(port_peerport(p_ptr),
 				    port_peernode(p_ptr),
-				    p_ptr->publ.ref,
+				    p_ptr->ref,
 				    tipc_own_addr,
 				    imp,
 				    TIPC_CONN_MSG,
@@ -534,31 +534,31 @@ static struct sk_buff *port_build_peer_abort_msg(struct port *p_ptr, u32 err)
 void tipc_port_recv_proto_msg(struct sk_buff *buf)
 {
 	struct tipc_msg *msg = buf_msg(buf);
-	struct port *p_ptr = tipc_port_lock(msg_destport(msg));
+	struct tipc_port *p_ptr = tipc_port_lock(msg_destport(msg));
 	u32 err = TIPC_OK;
 	struct sk_buff *r_buf = NULL;
 	struct sk_buff *abort_buf = NULL;
 
 	if (!p_ptr) {
 		err = TIPC_ERR_NO_PORT;
-	} else if (p_ptr->publ.connected) {
+	} else if (p_ptr->connected) {
 		if ((port_peernode(p_ptr) != msg_orignode(msg)) ||
 		    (port_peerport(p_ptr) != msg_origport(msg))) {
 			err = TIPC_ERR_NO_PORT;
 		} else if (msg_type(msg) == CONN_ACK) {
 			int wakeup = tipc_port_congested(p_ptr) &&
-				     p_ptr->publ.congested &&
+				     p_ptr->congested &&
 				     p_ptr->wakeup;
 			p_ptr->acked += msg_msgcnt(msg);
 			if (tipc_port_congested(p_ptr))
 				goto exit;
-			p_ptr->publ.congested = 0;
+			p_ptr->congested = 0;
 			if (!wakeup)
 				goto exit;
-			p_ptr->wakeup(&p_ptr->publ);
+			p_ptr->wakeup(p_ptr);
 			goto exit;
 		}
-	} else if (p_ptr->publ.published) {
+	} else if (p_ptr->published) {
 		err = TIPC_ERR_NO_PORT;
 	}
 	if (err) {
@@ -596,29 +596,29 @@ exit:
 	buf_discard(buf);
 }
 
-static void port_print(struct port *p_ptr, struct print_buf *buf, int full_id)
+static void port_print(struct tipc_port *p_ptr, struct print_buf *buf, int full_id)
 {
 	struct publication *publ;
 
 	if (full_id)
 		tipc_printf(buf, "<%u.%u.%u:%u>:",
 			    tipc_zone(tipc_own_addr), tipc_cluster(tipc_own_addr),
-			    tipc_node(tipc_own_addr), p_ptr->publ.ref);
+			    tipc_node(tipc_own_addr), p_ptr->ref);
 	else
-		tipc_printf(buf, "%-10u:", p_ptr->publ.ref);
+		tipc_printf(buf, "%-10u:", p_ptr->ref);
 
-	if (p_ptr->publ.connected) {
+	if (p_ptr->connected) {
 		u32 dport = port_peerport(p_ptr);
 		u32 destnode = port_peernode(p_ptr);
 
 		tipc_printf(buf, " connected to <%u.%u.%u:%u>",
 			    tipc_zone(destnode), tipc_cluster(destnode),
 			    tipc_node(destnode), dport);
-		if (p_ptr->publ.conn_type != 0)
+		if (p_ptr->conn_type != 0)
 			tipc_printf(buf, " via {%u,%u}",
-				    p_ptr->publ.conn_type,
-				    p_ptr->publ.conn_instance);
-	} else if (p_ptr->publ.published) {
+				    p_ptr->conn_type,
+				    p_ptr->conn_instance);
+	} else if (p_ptr->published) {
 		tipc_printf(buf, " bound to");
 		list_for_each_entry(publ, &p_ptr->publications, pport_list) {
 			if (publ->lower == publ->upper)
@@ -639,7 +639,7 @@ struct sk_buff *tipc_port_get_ports(void)
 	struct sk_buff *buf;
 	struct tlv_desc *rep_tlv;
 	struct print_buf pb;
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	int str_len;
 
 	buf = tipc_cfg_reply_alloc(TLV_SPACE(MAX_PORT_QUERY));
@@ -650,9 +650,9 @@ struct sk_buff *tipc_port_get_ports(void)
 	tipc_printbuf_init(&pb, TLV_DATA(rep_tlv), MAX_PORT_QUERY);
 	spin_lock_bh(&tipc_port_list_lock);
 	list_for_each_entry(p_ptr, &ports, port_list) {
-		spin_lock_bh(p_ptr->publ.lock);
+		spin_lock_bh(p_ptr->lock);
 		port_print(p_ptr, &pb, 0);
-		spin_unlock_bh(p_ptr->publ.lock);
+		spin_unlock_bh(p_ptr->lock);
 	}
 	spin_unlock_bh(&tipc_port_list_lock);
 	str_len = tipc_printbuf_validate(&pb);
@@ -665,12 +665,12 @@ struct sk_buff *tipc_port_get_ports(void)
 
 void tipc_port_reinit(void)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 
 	spin_lock_bh(&tipc_port_list_lock);
 	list_for_each_entry(p_ptr, &ports, port_list) {
-		msg = &p_ptr->publ.phdr;
+		msg = &p_ptr->phdr;
 		if (msg_orignode(msg) == tipc_own_addr)
 			break;
 		msg_set_prevnode(msg, tipc_own_addr);
@@ -695,7 +695,7 @@ static void port_dispatcher_sigh(void *dummy)
 	spin_unlock_bh(&queue_lock);
 
 	while (buf) {
-		struct port *p_ptr;
+		struct tipc_port *p_ptr;
 		struct user_port *up_ptr;
 		struct tipc_portid orig;
 		struct tipc_name_seq dseq;
@@ -720,8 +720,8 @@ static void port_dispatcher_sigh(void *dummy)
 		orig.node = msg_orignode(msg);
 		up_ptr = p_ptr->user_port;
 		usr_handle = up_ptr->usr_handle;
-		connected = p_ptr->publ.connected;
-		published = p_ptr->publ.published;
+		connected = p_ptr->connected;
+		published = p_ptr->published;
 
 		if (unlikely(msg_errcode(msg)))
 			goto err;
@@ -742,10 +742,10 @@ static void port_dispatcher_sigh(void *dummy)
 				} else if ((msg_origport(msg) != peer_port) ||
 					   (msg_orignode(msg) != peer_node))
 					goto reject;
-				if (unlikely(++p_ptr->publ.conn_unacked >=
+				if (unlikely(++p_ptr->conn_unacked >=
 					     TIPC_FLOW_CONTROL_WIN))
 					tipc_acknowledge(dref,
-							 p_ptr->publ.conn_unacked);
+							 p_ptr->conn_unacked);
 				skb_pull(buf, msg_hdr_sz(msg));
 				cb(usr_handle, dref, &buf, msg_data(msg),
 				   msg_data_sz(msg));
@@ -872,7 +872,7 @@ static u32 port_dispatcher(struct tipc_port *dummy, struct sk_buff *buf)
 
 static void port_wakeup_sh(unsigned long ref)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct user_port *up_ptr;
 	tipc_continue_event cb = NULL;
 	void *uh = NULL;
@@ -898,14 +898,14 @@ static void port_wakeup(struct tipc_port *p_ptr)
 
 void tipc_acknowledge(u32 ref, u32 ack)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return;
-	if (p_ptr->publ.connected) {
-		p_ptr->publ.conn_unacked -= ack;
+	if (p_ptr->connected) {
+		p_ptr->conn_unacked -= ack;
 		buf = port_build_proto_msg(port_peerport(p_ptr),
 					   port_peernode(p_ptr),
 					   ref,
@@ -936,14 +936,14 @@ int tipc_createport(void *usr_handle,
 		    u32 *portref)
 {
 	struct user_port *up_ptr;
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	up_ptr = kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
 	if (!up_ptr) {
 		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
-	p_ptr = (struct port *)tipc_createport_raw(NULL, port_dispatcher,
+	p_ptr = (struct tipc_port *)tipc_createport_raw(NULL, port_dispatcher,
 						   port_wakeup, importance);
 	if (!p_ptr) {
 		kfree(up_ptr);
@@ -952,7 +952,7 @@ int tipc_createport(void *usr_handle,
 
 	p_ptr->user_port = up_ptr;
 	up_ptr->usr_handle = usr_handle;
-	up_ptr->ref = p_ptr->publ.ref;
+	up_ptr->ref = p_ptr->ref;
 	up_ptr->err_cb = error_cb;
 	up_ptr->named_err_cb = named_error_cb;
 	up_ptr->conn_err_cb = conn_error_cb;
@@ -960,26 +960,26 @@ int tipc_createport(void *usr_handle,
 	up_ptr->named_msg_cb = named_msg_cb;
 	up_ptr->conn_msg_cb = conn_msg_cb;
 	up_ptr->continue_event_cb = continue_event_cb;
-	*portref = p_ptr->publ.ref;
+	*portref = p_ptr->ref;
 	tipc_port_unlock(p_ptr);
 	return 0;
 }
 
 int tipc_portimportance(u32 ref, unsigned int *importance)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	*importance = (unsigned int)msg_importance(&p_ptr->publ.phdr);
+	*importance = (unsigned int)msg_importance(&p_ptr->phdr);
 	tipc_port_unlock(p_ptr);
 	return 0;
 }
 
 int tipc_set_portimportance(u32 ref, unsigned int imp)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 
 	if (imp > TIPC_CRITICAL_IMPORTANCE)
 		return -EINVAL;
@@ -987,7 +987,7 @@ int tipc_set_portimportance(u32 ref, unsigned int imp)
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	msg_set_importance(&p_ptr->publ.phdr, (u32)imp);
+	msg_set_importance(&p_ptr->phdr, (u32)imp);
 	tipc_port_unlock(p_ptr);
 	return 0;
 }
@@ -995,7 +995,7 @@ int tipc_set_portimportance(u32 ref, unsigned int imp)
 
 int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct publication *publ;
 	u32 key;
 	int res = -EINVAL;
@@ -1004,7 +1004,7 @@ int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 	if (!p_ptr)
 		return -EINVAL;
 
-	if (p_ptr->publ.connected)
+	if (p_ptr->connected)
 		goto exit;
 	if (seq->lower > seq->upper)
 		goto exit;
@@ -1016,11 +1016,11 @@ int tipc_publish(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 		goto exit;
 	}
 	publ = tipc_nametbl_publish(seq->type, seq->lower, seq->upper,
-				    scope, p_ptr->publ.ref, key);
+				    scope, p_ptr->ref, key);
 	if (publ) {
 		list_add(&publ->pport_list, &p_ptr->publications);
 		p_ptr->pub_count++;
-		p_ptr->publ.published = 1;
+		p_ptr->published = 1;
 		res = 0;
 	}
 exit:
@@ -1030,7 +1030,7 @@ exit:
 
 int tipc_withdraw(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct publication *publ;
 	struct publication *tpubl;
 	int res = -EINVAL;
@@ -1063,37 +1063,37 @@ int tipc_withdraw(u32 ref, unsigned int scope, struct tipc_name_seq const *seq)
 		}
 	}
 	if (list_empty(&p_ptr->publications))
-		p_ptr->publ.published = 0;
+		p_ptr->published = 0;
 	tipc_port_unlock(p_ptr);
 	return res;
 }
 
 int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 	int res = -EINVAL;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
-	if (p_ptr->publ.published || p_ptr->publ.connected)
+	if (p_ptr->published || p_ptr->connected)
 		goto exit;
 	if (!peer->ref)
 		goto exit;
 
-	msg = &p_ptr->publ.phdr;
+	msg = &p_ptr->phdr;
 	msg_set_destnode(msg, peer->node);
 	msg_set_destport(msg, peer->ref);
 	msg_set_orignode(msg, tipc_own_addr);
-	msg_set_origport(msg, p_ptr->publ.ref);
+	msg_set_origport(msg, p_ptr->ref);
 	msg_set_transp_seqno(msg, 42);
 	msg_set_type(msg, TIPC_CONN_MSG);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
 	p_ptr->probing_interval = PROBING_INTERVAL;
 	p_ptr->probing_state = CONFIRMED;
-	p_ptr->publ.connected = 1;
+	p_ptr->connected = 1;
 	k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 
 	tipc_nodesub_subscribe(&p_ptr->subscription, peer->node,
@@ -1102,7 +1102,7 @@ int tipc_connect2port(u32 ref, struct tipc_portid const *peer)
 	res = 0;
 exit:
 	tipc_port_unlock(p_ptr);
-	p_ptr->publ.max_pkt = tipc_link_get_max_pkt(peer->node, ref);
+	p_ptr->max_pkt = tipc_link_get_max_pkt(peer->node, ref);
 	return res;
 }
 
@@ -1120,7 +1120,7 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr)
 		tp_ptr->connected = 0;
 		/* let timer expire on it's own to avoid deadlock! */
 		tipc_nodesub_unsubscribe(
-			&((struct port *)tp_ptr)->subscription);
+			&((struct tipc_port *)tp_ptr)->subscription);
 		res = 0;
 	} else {
 		res = -ENOTCONN;
@@ -1135,7 +1135,7 @@ int tipc_disconnect_port(struct tipc_port *tp_ptr)
 
 int tipc_disconnect(u32 ref)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	int res;
 
 	p_ptr = tipc_port_lock(ref);
@@ -1151,15 +1151,15 @@ int tipc_disconnect(u32 ref)
  */
 int tipc_shutdown(u32 ref)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct sk_buff *buf = NULL;
 
 	p_ptr = tipc_port_lock(ref);
 	if (!p_ptr)
 		return -EINVAL;
 
-	if (p_ptr->publ.connected) {
-		u32 imp = msg_importance(&p_ptr->publ.phdr);
+	if (p_ptr->connected) {
+		u32 imp = msg_importance(&p_ptr->phdr);
 		if (imp < TIPC_CRITICAL_IMPORTANCE)
 			imp++;
 		buf = port_build_proto_msg(port_peerport(p_ptr),
@@ -1182,13 +1182,13 @@ int tipc_shutdown(u32 ref)
  *                        message for this node.
  */
 
-static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
+static int tipc_port_recv_sections(struct tipc_port *sender, unsigned int num_sect,
 				   struct iovec const *msg_sect)
 {
 	struct sk_buff *buf;
 	int res;
 
-	res = tipc_msg_build(&sender->publ.phdr, msg_sect, num_sect,
+	res = tipc_msg_build(&sender->phdr, msg_sect, num_sect,
 			MAX_MSG_SIZE, !sender->user_port, &buf);
 	if (likely(buf))
 		tipc_port_recv_msg(buf);
@@ -1201,15 +1201,15 @@ static int tipc_port_recv_sections(struct port *sender, unsigned int num_sect,
 
 int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	u32 destnode;
 	int res;
 
 	p_ptr = tipc_port_deref(ref);
-	if (!p_ptr || !p_ptr->publ.connected)
+	if (!p_ptr || !p_ptr->connected)
 		return -EINVAL;
 
-	p_ptr->publ.congested = 1;
+	p_ptr->congested = 1;
 	if (!tipc_port_congested(p_ptr)) {
 		destnode = port_peernode(p_ptr);
 		if (likely(destnode != tipc_own_addr))
@@ -1220,13 +1220,13 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 
 		if (likely(res != -ELINKCONG)) {
 			port_incr_out_seqno(p_ptr);
-			p_ptr->publ.congested = 0;
+			p_ptr->congested = 0;
 			p_ptr->sent++;
 			return res;
 		}
 	}
 	if (port_unreliable(p_ptr)) {
-		p_ptr->publ.congested = 0;
+		p_ptr->congested = 0;
 		/* Just calculate msg length and return */
 		return tipc_msg_calc_data_size(msg_sect, num_sect);
 	}
@@ -1240,17 +1240,17 @@ int tipc_send(u32 ref, unsigned int num_sect, struct iovec const *msg_sect)
 int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	   unsigned int num_sect, struct iovec const *msg_sect)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 	u32 destnode = domain;
 	u32 destport;
 	int res;
 
 	p_ptr = tipc_port_deref(ref);
-	if (!p_ptr || p_ptr->publ.connected)
+	if (!p_ptr || p_ptr->connected)
 		return -EINVAL;
 
-	msg = &p_ptr->publ.phdr;
+	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_NAMED_MSG);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
@@ -1287,15 +1287,15 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	   unsigned int num_sect, struct iovec const *msg_sect)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 	int res;
 
 	p_ptr = tipc_port_deref(ref);
-	if (!p_ptr || p_ptr->publ.connected)
+	if (!p_ptr || p_ptr->connected)
 		return -EINVAL;
 
-	msg = &p_ptr->publ.phdr;
+	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
@@ -1322,15 +1322,15 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 	       struct sk_buff *buf, unsigned int dsz)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg;
 	int res;
 
-	p_ptr = (struct port *)tipc_ref_deref(ref);
-	if (!p_ptr || p_ptr->publ.connected)
+	p_ptr = (struct tipc_port *)tipc_ref_deref(ref);
+	if (!p_ptr || p_ptr->connected)
 		return -EINVAL;
 
-	msg = &p_ptr->publ.phdr;
+	msg = &p_ptr->phdr;
 	msg_set_type(msg, TIPC_DIRECT_MSG);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 8e84b98..f8722af 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -2,7 +2,7 @@
  * net/tipc/port.h: Include file for TIPC port code
  *
  * Copyright (c) 1994-2007, Ericsson AB
- * Copyright (c) 2004-2007, Wind River Systems
+ * Copyright (c) 2004-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -95,7 +95,7 @@ struct user_port {
 };
 
 /**
- * struct tipc_port - TIPC port info available to socket API
+ * struct tipc_port - TIPC port structure
  * @usr_handle: pointer to additional user-defined information about port
  * @lock: pointer to spinlock for controlling access to port
  * @connected: non-zero if port is currently connected to a peer port
@@ -107,24 +107,6 @@ struct user_port {
  * @max_pkt: maximum packet size "hint" used when building messages sent by port
  * @ref: unique reference to port in TIPC object registry
  * @phdr: preformatted message header used when sending messages
- */
-struct tipc_port {
-	void *usr_handle;
-	spinlock_t *lock;
-	int connected;
-	u32 conn_type;
-	u32 conn_instance;
-	u32 conn_unacked;
-	int published;
-	u32 congested;
-	u32 max_pkt;
-	u32 ref;
-	struct tipc_msg phdr;
-};
-
-/**
- * struct port - TIPC port structure
- * @publ: TIPC port info available to privileged users
  * @port_list: adjacent ports in TIPC's global list of ports
  * @dispatcher: ptr to routine which handles received messages
  * @wakeup: ptr to routine to call when port is no longer congested
@@ -141,9 +123,18 @@ struct tipc_port {
  * @timer_ref:
  * @subscription: "node down" subscription used to terminate failed connections
  */
-
-struct port {
-	struct tipc_port publ;
+struct tipc_port {
+	void *usr_handle;
+	spinlock_t *lock;
+	int connected;
+	u32 conn_type;
+	u32 conn_instance;
+	u32 conn_unacked;
+	int published;
+	u32 congested;
+	u32 max_pkt;
+	u32 ref;
+	struct tipc_msg phdr;
 	struct list_head port_list;
 	u32 (*dispatcher)(struct tipc_port *, struct sk_buff *);
 	void (*wakeup)(struct tipc_port *);
@@ -230,7 +221,7 @@ int tipc_send_buf2port(u32 portref, struct tipc_portid const *dest,
 int tipc_multicast(u32 portref, struct tipc_name_seq const *seq,
 		unsigned int section_count, struct iovec const *msg);
 
-int tipc_port_reject_sections(struct port *p_ptr, struct tipc_msg *hdr,
+int tipc_port_reject_sections(struct tipc_port *p_ptr, struct tipc_msg *hdr,
 			      struct iovec const *msg_sect, u32 num_sect,
 			      int err);
 struct sk_buff *tipc_port_get_ports(void);
@@ -242,9 +233,9 @@ void tipc_port_reinit(void);
  * tipc_port_lock - lock port instance referred to and return its pointer
  */
 
-static inline struct port *tipc_port_lock(u32 ref)
+static inline struct tipc_port *tipc_port_lock(u32 ref)
 {
-	return (struct port *)tipc_ref_lock(ref);
+	return (struct tipc_port *)tipc_ref_lock(ref);
 }
 
 /**
@@ -253,27 +244,27 @@ static inline struct port *tipc_port_lock(u32 ref)
  * Can use pointer instead of tipc_ref_unlock() since port is already locked.
  */
 
-static inline void tipc_port_unlock(struct port *p_ptr)
+static inline void tipc_port_unlock(struct tipc_port *p_ptr)
 {
-	spin_unlock_bh(p_ptr->publ.lock);
+	spin_unlock_bh(p_ptr->lock);
 }
 
-static inline struct port *tipc_port_deref(u32 ref)
+static inline struct tipc_port *tipc_port_deref(u32 ref)
 {
-	return (struct port *)tipc_ref_deref(ref);
+	return (struct tipc_port *)tipc_ref_deref(ref);
 }
 
-static inline u32 tipc_peer_port(struct port *p_ptr)
+static inline u32 tipc_peer_port(struct tipc_port *p_ptr)
 {
-	return msg_destport(&p_ptr->publ.phdr);
+	return msg_destport(&p_ptr->phdr);
 }
 
-static inline u32 tipc_peer_node(struct port *p_ptr)
+static inline u32 tipc_peer_node(struct tipc_port *p_ptr)
 {
-	return msg_destnode(&p_ptr->publ.phdr);
+	return msg_destnode(&p_ptr->phdr);
 }
 
-static inline int tipc_port_congested(struct port *p_ptr)
+static inline int tipc_port_congested(struct tipc_port *p_ptr)
 {
 	return (p_ptr->sent - p_ptr->acked) >= (TIPC_FLOW_CONTROL_WIN * 2);
 }
@@ -284,7 +275,7 @@ static inline int tipc_port_congested(struct port *p_ptr)
 
 static inline int tipc_port_recv_msg(struct sk_buff *buf)
 {
-	struct port *p_ptr;
+	struct tipc_port *p_ptr;
 	struct tipc_msg *msg = buf_msg(buf);
 	u32 destport = msg_destport(msg);
 	u32 dsz = msg_data_sz(msg);
@@ -299,7 +290,7 @@ static inline int tipc_port_recv_msg(struct sk_buff *buf)
 	/* validate destination & pass to port, otherwise reject message */
 	p_ptr = tipc_port_lock(destport);
 	if (likely(p_ptr)) {
-		if (likely(p_ptr->publ.connected)) {
+		if (likely(p_ptr->connected)) {
 			if ((unlikely(msg_origport(msg) != tipc_peer_port(p_ptr))) ||
 			    (unlikely(msg_orignode(msg) != tipc_peer_node(p_ptr))) ||
 			    (unlikely(!msg_connected(msg)))) {
@@ -308,7 +299,7 @@ static inline int tipc_port_recv_msg(struct sk_buff *buf)
 				goto reject;
 			}
 		}
-		err = p_ptr->dispatcher(&p_ptr->publ, buf);
+		err = p_ptr->dispatcher(p_ptr, buf);
 		tipc_port_unlock(p_ptr);
 		if (likely(!err))
 			return dsz;
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index ca04479..98ee50b 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -2,7 +2,7 @@
  * net/tipc/subscr.c: TIPC network topology service
  *
  * Copyright (c) 2000-2006, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2007, 2010-2011, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -160,7 +160,7 @@ void tipc_subscr_report_overlap(struct subscription *sub,
 
 static void subscr_timeout(struct subscription *sub)
 {
-	struct port *server_port;
+	struct tipc_port *server_port;
 
 	/* Validate server port reference (in case subscriber is terminating) */
 
@@ -508,7 +508,7 @@ static void subscr_named_msg_event(void *usr_handle,
 
 	/* Lock server port (& save lock address for future use) */
 
-	subscriber->lock = tipc_port_lock(subscriber->port_ref)->publ.lock;
+	subscriber->lock = tipc_port_lock(subscriber->port_ref)->lock;
 
 	/* Add subscriber to topology server's subscriber list */
 
-- 
1.7.3.3

