From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 13/17] tipc: remove port_lock
Date: Fri, 22 Aug 2014 18:09:16 -0400
Message-ID: <1408745360-23560-14-git-send-email-jon.maloy@ericsson.com>
References: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In previous commits we have reduced usage of port_lock to a minimum,
and complemented it with usage of bh_lock_sock() at the remaining
locations. The purpose has been to remove this lock altogether, since
it largely duplicates the role of bh_lock_sock. We are now ready to do
this.

However, we still need to protect the BH callers from inadvertent
release of the socket while they hold a reference to it. We do this by
replacing port_lock by a combination of a rw-lock protecting the
reference table as such, and updating the socket reference counter while
the socket is referenced from BH. This technique is more standard and
comprehensible than the previous approach, and turns out to have a
positive effect on overall performance.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/port.h   |   20 -------
 net/tipc/ref.c    |  158 ++++++++++++++++++++++++-----------------------------
 net/tipc/ref.h    |   15 +++--
 net/tipc/socket.c |   64 +++++++++-------------
 4 files changed, 108 insertions(+), 149 deletions(-)

diff --git a/net/tipc/port.h b/net/tipc/port.h
index 33e52fe..38bf8cb 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -37,7 +37,6 @@
 #ifndef _TIPC_PORT_H
 #define _TIPC_PORT_H
 
-#include "ref.h"
 #include "net.h"
 #include "msg.h"
 #include "node_subscr.h"
@@ -65,7 +64,6 @@
  * @timer_ref:
  */
 struct tipc_port {
-	spinlock_t *lock;
 	int connected;
 	u32 conn_type;
 	u32 conn_instance;
@@ -98,24 +96,6 @@ int tipc_port_peer_msg(struct tipc_port *p_ptr, struct tipc_msg *msg);
 
 void tipc_port_reinit(void);
 
-/**
- * tipc_port_lock - lock port instance referred to and return its pointer
- */
-static inline struct tipc_sock *tipc_port_lock(u32 ref)
-{
-	return (struct tipc_sock *)tipc_ref_lock(ref);
-}
-
-/**
- * tipc_port_unlock - unlock a port instance
- *
- * Can use pointer instead of tipc_ref_unlock() since port is already locked.
- */
-static inline void tipc_port_unlock(struct tipc_port *p_ptr)
-{
-	spin_unlock_bh(p_ptr->lock);
-}
-
 static inline u32 tipc_port_peernode(struct tipc_port *p_ptr)
 {
 	return msg_destnode(&p_ptr->phdr);
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 7fc2740..ea981be 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -1,7 +1,7 @@
 /*
- * net/tipc/ref.c: TIPC object registry code
+ * net/tipc/ref.c: TIPC socket registry code
  *
- * Copyright (c) 1991-2006, Ericsson AB
+ * Copyright (c) 1991-2006, 2014, Ericsson AB
  * Copyright (c) 2004-2007, Wind River Systems
  * All rights reserved.
  *
@@ -38,24 +38,22 @@
 #include "ref.h"
 
 /**
- * struct reference - TIPC object reference entry
- * @object: pointer to object associated with reference entry
- * @lock: spinlock controlling access to object
- * @ref: reference value for object (combines instance & array index info)
+ * struct reference - TIPC socket reference entry
+ * @tsk: pointer to socket associated with reference entry
+ * @ref: reference value for socket (combines instance & array index info)
  */
 struct reference {
-	void *object;
-	spinlock_t lock;
+	struct tipc_sock *tsk;
 	u32 ref;
 };
 
 /**
- * struct tipc_ref_table - table of TIPC object reference entries
+ * struct tipc_ref_table - table of TIPC socket reference entries
  * @entries: pointer to array of reference entries
  * @capacity: array index of first unusable entry
  * @init_point: array index of first uninitialized entry
- * @first_free: array index of first unused object reference entry
- * @last_free: array index of last unused object reference entry
+ * @first_free: array index of first unused socket reference entry
+ * @last_free: array index of last unused socket reference entry
  * @index_mask: bitmask for array index portion of reference values
  * @start_mask: initial value for instance value portion of reference values
  */
@@ -70,9 +68,9 @@ struct ref_table {
 };
 
 /*
- * Object reference table consists of 2**N entries.
+ * Socket reference table consists of 2**N entries.
  *
- * State	Object ptr	Reference
+ * State	Socket ptr	Reference
  * -----        ----------      ---------
  * In use        non-NULL       XXXX|own index
  *				(XXXX changes each time entry is acquired)
@@ -89,10 +87,10 @@ struct ref_table {
 
 static struct ref_table tipc_ref_table;
 
-static DEFINE_SPINLOCK(ref_table_lock);
+static DEFINE_RWLOCK(ref_table_lock);
 
 /**
- * tipc_ref_table_init - create reference table for objects
+ * tipc_ref_table_init - create reference table for sockets
  */
 int tipc_ref_table_init(u32 requested_size, u32 start)
 {
@@ -122,84 +120,69 @@ int tipc_ref_table_init(u32 requested_size, u32 start)
 }
 
 /**
- * tipc_ref_table_stop - destroy reference table for objects
+ * tipc_ref_table_stop - destroy reference table for sockets
  */
 void tipc_ref_table_stop(void)
 {
+	if (!tipc_ref_table.entries)
+		return;
 	vfree(tipc_ref_table.entries);
 	tipc_ref_table.entries = NULL;
 }
 
-/**
- * tipc_ref_acquire - create reference to an object
+/* tipc_ref_acquire - create reference to a socket
  *
- * Register an object pointer in reference table and lock the object.
+ * Register an socket pointer in the reference table.
  * Returns a unique reference value that is used from then on to retrieve the
- * object pointer, or to determine that the object has been deregistered.
- *
- * Note: The object is returned in the locked state so that the caller can
- * register a partially initialized object, without running the risk that
- * the object will be accessed before initialization is complete.
+ * socket pointer, or to determine if the socket has been deregistered.
  */
-u32 tipc_ref_acquire(void *object, spinlock_t **lock)
+u32 tipc_ref_acquire(struct tipc_sock *tsk)
 {
 	u32 index;
 	u32 index_mask;
 	u32 next_plus_upper;
-	u32 ref;
-	struct reference *entry = NULL;
+	u32 ref = 0;
+	struct reference *entry;
 
-	if (!object) {
+	if (unlikely(!tsk)) {
 		pr_err("Attempt to acquire ref. to non-existent obj\n");
 		return 0;
 	}
-	if (!tipc_ref_table.entries) {
+	if (unlikely(!tipc_ref_table.entries)) {
 		pr_err("Ref. table not found in acquisition attempt\n");
 		return 0;
 	}
 
-	/* take a free entry, if available; otherwise initialize a new entry */
-	spin_lock_bh(&ref_table_lock);
-	if (tipc_ref_table.first_free) {
+	/* Take a free entry, if available; otherwise initialize a new one */
+	write_lock_bh(&ref_table_lock);
+	index = tipc_ref_table.first_free;
+	entry = &tipc_ref_table.entries[index];
+
+	if (likely(index)) {
 		index = tipc_ref_table.first_free;
 		entry = &(tipc_ref_table.entries[index]);
 		index_mask = tipc_ref_table.index_mask;
 		next_plus_upper = entry->ref;
 		tipc_ref_table.first_free = next_plus_upper & index_mask;
 		ref = (next_plus_upper & ~index_mask) + index;
+		entry->tsk = tsk;
 	} else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
 		index = tipc_ref_table.init_point++;
 		entry = &(tipc_ref_table.entries[index]);
-		spin_lock_init(&entry->lock);
 		ref = tipc_ref_table.start_mask + index;
-	} else {
-		ref = 0;
 	}
-	spin_unlock_bh(&ref_table_lock);
 
-	/*
-	 * Grab the lock so no one else can modify this entry
-	 * While we assign its ref value & object pointer
-	 */
-	if (entry) {
-		spin_lock_bh(&entry->lock);
+	if (ref) {
 		entry->ref = ref;
-		entry->object = object;
-		*lock = &entry->lock;
-		/*
-		 * keep it locked, the caller is responsible
-		 * for unlocking this when they're done with it
-		 */
+		entry->tsk = tsk;
 	}
-
+	write_unlock_bh(&ref_table_lock);
 	return ref;
 }
 
-/**
- * tipc_ref_discard - invalidate references to an object
+/* tipc_ref_discard - invalidate reference to an socket
  *
- * Disallow future references to an object and free up the entry for re-use.
- * Note: The entry's spin_lock may still be busy after discard
+ * Disallow future references to an socket and free up the entry for re-use.
  */
 void tipc_ref_discard(u32 ref)
 {
@@ -207,7 +190,7 @@ void tipc_ref_discard(u32 ref)
 	u32 index;
 	u32 index_mask;
 
-	if (!tipc_ref_table.entries) {
+	if (unlikely(!tipc_ref_table.entries)) {
 		pr_err("Ref. table not found during discard attempt\n");
 		return;
 	}
@@ -216,71 +199,72 @@ void tipc_ref_discard(u32 ref)
 	index = ref & index_mask;
 	entry = &(tipc_ref_table.entries[index]);
 
-	spin_lock_bh(&ref_table_lock);
+	write_lock_bh(&ref_table_lock);
 
-	if (!entry->object) {
-		pr_err("Attempt to discard ref. to non-existent obj\n");
+	if (unlikely(!entry->tsk)) {
+		pr_err("Attempt to discard ref. to non-existent socket\n");
 		goto exit;
 	}
-	if (entry->ref != ref) {
+	if (unlikely(entry->ref != ref)) {
 		pr_err("Attempt to discard non-existent reference\n");
 		goto exit;
 	}
 
 	/*
-	 * mark entry as unused; increment instance part of entry's reference
+	 * Mark entry as unused; increment instance part of entry's reference
 	 * to invalidate any subsequent references
 	 */
-	entry->object = NULL;
+	entry->tsk = NULL;
 	entry->ref = (ref & ~index_mask) + (index_mask + 1);
 
-	/* append entry to free entry list */
-	if (tipc_ref_table.first_free == 0)
+	/* Append entry to free entry list */
+	if (unlikely(tipc_ref_table.first_free == 0))
 		tipc_ref_table.first_free = index;
 	else
 		tipc_ref_table.entries[tipc_ref_table.last_free].ref |= index;
 	tipc_ref_table.last_free = index;
-
 exit:
-	spin_unlock_bh(&ref_table_lock);
+	write_unlock_bh(&ref_table_lock);
 }
 
-/**
- * tipc_ref_lock - lock referenced object and return pointer to it
+/* tipc_sk_get - find referenced socket and return pointer to it
  */
-void *tipc_ref_lock(u32 ref)
+struct tipc_sock *tipc_sk_get(u32 ref)
 {
-	if (likely(tipc_ref_table.entries)) {
-		struct reference *entry;
+	struct reference *entry;
+	struct tipc_sock *tsk;
 
-		entry = &tipc_ref_table.entries[ref &
-						tipc_ref_table.index_mask];
-		if (likely(entry->ref != 0)) {
-			spin_lock_bh(&entry->lock);
-			if (likely((entry->ref == ref) && (entry->object)))
-				return entry->object;
-			spin_unlock_bh(&entry->lock);
-		}
-	}
-	return NULL;
+	if (unlikely(!tipc_ref_table.entries))
+		return NULL;
+	read_lock_bh(&ref_table_lock);
+	entry = &tipc_ref_table.entries[ref & tipc_ref_table.index_mask];
+	tsk = entry->tsk;
+	if (likely(tsk && (entry->ref == ref)))
+		sock_hold(&tsk->sk);
+	else
+		tsk = NULL;
+	read_unlock_bh(&ref_table_lock);
+	return tsk;
 }
 
-/* tipc_ref_lock_next - lock & return next object after referenced one
+/* tipc_sk_get_next - lock & return next socket after referenced one
 */
-void *tipc_ref_lock_next(u32 *ref)
+struct tipc_sock *tipc_sk_get_next(u32 *ref)
 {
 	struct reference *entry;
+	struct tipc_sock *tsk = NULL;
 	uint index = *ref & tipc_ref_table.index_mask;
 
+	read_lock_bh(&ref_table_lock);
 	while (++index < tipc_ref_table.capacity) {
 		entry = &tipc_ref_table.entries[index];
-		if (!entry->object)
+		if (!entry->tsk)
 			continue;
-		spin_lock_bh(&entry->lock);
+		tsk = entry->tsk;
+		sock_hold(&tsk->sk);
 		*ref = entry->ref;
-		if (entry->object)
-			return entry->object;
-		spin_unlock_bh(&entry->lock);
+		break;
 	}
-	return NULL;
+	read_unlock_bh(&ref_table_lock);
+	return tsk;
 }
diff --git a/net/tipc/ref.h b/net/tipc/ref.h
index e236fa5..2b75a89 100644
--- a/net/tipc/ref.h
+++ b/net/tipc/ref.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/ref.h: Include file for TIPC object registry code
  *
- * Copyright (c) 1991-2006, Ericsson AB
+ * Copyright (c) 1991-2006, 2014, Ericsson AB
  * Copyright (c) 2005-2006, Wind River Systems
  * All rights reserved.
  *
@@ -37,13 +37,20 @@
 #ifndef _TIPC_REF_H
 #define _TIPC_REF_H
 
+#include "socket.h"
+
 int tipc_ref_table_init(u32 requested_size, u32 start);
 void tipc_ref_table_stop(void);
 
-u32 tipc_ref_acquire(void *object, spinlock_t **lock);
+u32 tipc_ref_acquire(struct tipc_sock *tsk);
 void tipc_ref_discard(u32 ref);
 
-void *tipc_ref_lock(u32 ref);
-void *tipc_ref_lock_next(u32 *ref);
+struct tipc_sock *tipc_sk_get(u32 ref);
+struct tipc_sock *tipc_sk_get_next(u32 *ref);
+
+static inline void tipc_sk_put(struct tipc_sock *tsk)
+{
+	sock_put(&tsk->sk);
+}
 
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 247f245..7e6240e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -35,6 +35,7 @@
  */
 
 #include "core.h"
+#include "ref.h"
 #include "port.h"
 #include "name_table.h"
 #include "node.h"
@@ -111,13 +112,6 @@ static struct proto tipc_proto_kern;
 
 #include "socket.h"
 
-/* tipc_sk_lock_next: find & lock next socket in registry from given port number
-*/
-static struct tipc_sock *tipc_sk_lock_next(u32 *ref)
-{
-	return (struct tipc_sock *)tipc_ref_lock_next(ref);
-}
-
 /**
  * advance_rx_queue - discard first buffer in socket receive queue
  *
@@ -200,7 +194,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 
 	tsk = tipc_sk(sk);
 	port = &tsk->port;
-	ref = tipc_ref_acquire(tsk, &port->lock);
+	ref = tipc_ref_acquire(tsk);
 	if (!ref) {
 		pr_warn("Socket create failed; reference table exhausted\n");
 		return -ENOMEM;
@@ -226,7 +220,6 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	tsk->conn_timeout = CONN_TIMEOUT_DEFAULT;
 	tsk->sent_unacked = 0;
 	atomic_set(&tsk->dupl_rcvcnt, 0);
-	tipc_port_unlock(port);
 
 	if (sock->state == SS_READY) {
 		tipc_port_set_unreturnable(port, true);
@@ -364,9 +357,7 @@ static int tipc_release(struct socket *sock)
 	}
 
 	tipc_withdraw(port, 0, NULL);
-	spin_lock_bh(port->lock);
 	tipc_ref_discard(port->ref);
-	spin_unlock_bh(port->lock);
 	k_cancel_timer(&port->timer);
 	if (port->connected) {
 		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
@@ -1651,7 +1642,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	u32 dnode;
 
 	/* Validate destination and message */
-	tsk = tipc_port_lock(dport);
+	tsk = tipc_sk_get(dport);
 	if (unlikely(!tsk)) {
 		rc = tipc_msg_eval(buf, &dnode);
 		goto exit;
@@ -1672,8 +1663,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 			rc = -TIPC_ERR_OVERLOAD;
 	}
 	bh_unlock_sock(sk);
-	tipc_port_unlock(port);
-
+	tipc_sk_put(tsk);
 	if (likely(!rc))
 		return 0;
 exit:
@@ -1997,23 +1987,23 @@ restart:
 
 static void tipc_sk_timeout(unsigned long ref)
 {
-	struct tipc_sock *tsk = tipc_port_lock(ref);
+	struct tipc_sock *tsk;
 	struct tipc_port *port;
 	struct sock *sk;
 	struct sk_buff *buf = NULL;
-	struct tipc_msg *msg = NULL;
 	u32 peer_port, peer_node;
 
+	tsk = tipc_sk_get(ref);
 	if (!tsk)
-		return;
-
+		goto exit;
+	sk = &tsk->sk;
 	port = &tsk->port;
+
+	bh_lock_sock(sk);
 	if (!port->connected) {
-		tipc_port_unlock(port);
-		return;
+		bh_unlock_sock(sk);
+		goto exit;
 	}
-	sk = &tsk->sk;
-	bh_lock_sock(sk);
 	peer_port = tipc_port_peerport(port);
 	peer_node = tipc_port_peernode(port);
 
@@ -2031,12 +2021,10 @@ static void tipc_sk_timeout(unsigned long ref)
 		k_start_timer(&port->timer, port->probing_interval);
 	}
 	bh_unlock_sock(sk);
-	tipc_port_unlock(port);
-	if (!buf)
-		return;
-
-	msg = buf_msg(buf);
-	tipc_link_xmit(buf, msg_destnode(msg),	msg_link_selector(msg));
+	if (buf)
+		tipc_link_xmit(buf, peer_node, ref);
+exit:
+	tipc_sk_put(tsk);
 }
 
 static int tipc_sk_show(struct tipc_port *port, char *buf,
@@ -2100,13 +2088,13 @@ struct sk_buff *tipc_sk_socks_show(void)
 	pb = TLV_DATA(rep_tlv);
 	pb_len = ULTRA_STRING_MAX_LEN;
 
-	tsk = tipc_sk_lock_next(&ref);
-	for (; tsk; tsk = tipc_sk_lock_next(&ref)) {
-		bh_lock_sock(&tsk->sk);
+	tsk = tipc_sk_get_next(&ref);
+	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
+		lock_sock(&tsk->sk);
 		str_len += tipc_sk_show(&tsk->port, pb + str_len,
 					pb_len - str_len, 0);
-		bh_unlock_sock(&tsk->sk);
-		tipc_port_unlock(&tsk->port);
+		release_sock(&tsk->sk);
+		tipc_sk_put(tsk);
 	}
 	str_len += 1;	/* for "\0" */
 	skb_put(buf, TLV_SPACE(str_len));
@@ -2122,15 +2110,15 @@ void tipc_sk_reinit(void)
 {
 	struct tipc_msg *msg;
 	u32 ref = 0;
-	struct tipc_sock *tsk = tipc_sk_lock_next(&ref);
+	struct tipc_sock *tsk = tipc_sk_get_next(&ref);
 
-	for (; tsk; tsk = tipc_sk_lock_next(&ref)) {
-		bh_lock_sock(&tsk->sk);
+	for (; tsk; tsk = tipc_sk_get_next(&ref)) {
+		lock_sock(&tsk->sk);
 		msg = &tsk->port.phdr;
 		msg_set_prevnode(msg, tipc_own_addr);
 		msg_set_orignode(msg, tipc_own_addr);
-		bh_unlock_sock(&tsk->sk);
-		tipc_port_unlock(&tsk->port);
+		release_sock(&tsk->sk);
+		tipc_sk_put(tsk);
 	}
 }
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
