From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH net-next-2.6] [TIPC]: Fix race condition when creating socket or native port
Date: Mon, 12 May 2008 16:38:46 -0400
Message-ID: <1210624726-3949-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61285 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756865AbYELUn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2008 16:43:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates the (very remote) chance of a crash resulting
from a partially initialized socket or native port unexpectedly
receiving a message.  Now, during the creation of a socket or native
port, the underlying generic port's lock is not released until all
initialization required to handle incoming messages has been done.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/net/tipc/tipc_port.h |    3 ++-
 net/tipc/port.c              |   20 ++++++++++++--------
 net/tipc/ref.c               |   12 ++++++++----
 net/tipc/socket.c            |    5 ++++-
 net/tipc/subscr.c            |    1 +
 5 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
index 11105bc..9923e41 100644
--- a/include/net/tipc/tipc_port.h
+++ b/include/net/tipc/tipc_port.h
@@ -84,7 +84,8 @@ struct tipc_port {
 u32 tipc_createport_raw(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
-			const u32 importance);
+			const u32 importance,
+			struct tipc_port **tp_ptr);
 
 int tipc_reject_msg(struct sk_buff *buf, u32 err);
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2f58064..757de38 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -211,15 +211,18 @@ exit:
 }
 
 /**
- * tipc_createport_raw - create a native TIPC port
+ * tipc_createport_raw - create a generic TIPC port
  *
- * Returns local port reference
+ * Returns port reference, or 0 if unable to create it
+ *
+ * Note: The newly created port is returned in the locked state.
  */
 
 u32 tipc_createport_raw(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
-			const u32 importance)
+			const u32 importance,
+			struct tipc_port **tp_ptr)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -237,7 +240,6 @@ u32 tipc_createport_raw(void *usr_handle,
 		return 0;
 	}
 
-	tipc_port_lock(ref);
 	p_ptr->publ.usr_handle = usr_handle;
 	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
@@ -262,7 +264,7 @@ u32 tipc_createport_raw(void *usr_handle,
 	INIT_LIST_HEAD(&p_ptr->port_list);
 	list_add_tail(&p_ptr->port_list, &ports);
 	spin_unlock_bh(&tipc_port_list_lock);
-	tipc_port_unlock(p_ptr);
+	*tp_ptr = &p_ptr->publ;
 	return ref;
 }
 
@@ -1053,6 +1055,7 @@ int tipc_createport(u32 user_ref,
 {
 	struct user_port *up_ptr;
 	struct port *p_ptr;
+	struct tipc_port *tp_ptr;
 	u32 ref;
 
 	up_ptr = kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
@@ -1060,12 +1063,13 @@ int tipc_createport(u32 user_ref,
 		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
-	ref = tipc_createport_raw(NULL, port_dispatcher, port_wakeup, importance);
-	p_ptr = tipc_port_lock(ref);
-	if (!p_ptr) {
+	ref = tipc_createport_raw(NULL, port_dispatcher, port_wakeup,
+				  importance, &tp_ptr);
+	if (ref == 0) {
 		kfree(up_ptr);
 		return -ENOMEM;
 	}
+	p_ptr = (struct port *)tp_ptr;
 
 	p_ptr->user_port = up_ptr;
 	up_ptr->user_ref = user_ref;
diff --git a/net/tipc/ref.c b/net/tipc/ref.c
index 89cbab2..a101de8 100644
--- a/net/tipc/ref.c
+++ b/net/tipc/ref.c
@@ -142,9 +142,13 @@ void tipc_ref_table_stop(void)
 /**
  * tipc_ref_acquire - create reference to an object
  *
- * Return a unique reference value which can be translated back to the pointer
- * 'object' at a later time.  Also, pass back a pointer to the lock protecting
- * the object, but without locking it.
+ * Register an object pointer in reference table and lock the object.
+ * Returns a unique reference value that is used from then on to retrieve the
+ * object pointer, or to determine that the object has been deregistered.
+ *
+ * Note: The object is returned in the locked state so that the caller can
+ * register a partially initialized object, without running the risk that
+ * the object will be accessed before initialization is complete.
  */
 
 u32 tipc_ref_acquire(void *object, spinlock_t **lock)
@@ -178,13 +182,13 @@ u32 tipc_ref_acquire(void *object, spinlock_t **lock)
 		ref = (next_plus_upper & ~index_mask) + index;
 		entry->ref = ref;
 		entry->object = object;
-		spin_unlock_bh(&entry->lock);
 		*lock = &entry->lock;
 	}
 	else if (tipc_ref_table.init_point < tipc_ref_table.capacity) {
 		index = tipc_ref_table.init_point++;
 		entry = &(tipc_ref_table.entries[index]);
 		spin_lock_init(&entry->lock);
+		spin_lock_bh(&entry->lock);
 		ref = tipc_ref_table.start_mask + index;
 		entry->ref = ref;
 		entry->object = object;
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 230f9ca..38f4879 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -188,6 +188,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	const struct proto_ops *ops;
 	socket_state state;
 	struct sock *sk;
+	struct tipc_port *tp_ptr;
 	u32 portref;
 
 	/* Validate arguments */
@@ -225,7 +226,7 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	/* Allocate TIPC port for socket to use */
 
 	portref = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
-				      TIPC_LOW_IMPORTANCE);
+				      TIPC_LOW_IMPORTANCE, &tp_ptr);
 	if (unlikely(portref == 0)) {
 		sk_free(sk);
 		return -ENOMEM;
@@ -241,6 +242,8 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	sk->sk_backlog_rcv = backlog_rcv;
 	tipc_sk(sk)->p = tipc_get_port(portref);
 
+	spin_unlock_bh(tp_ptr->lock);
+
 	if (sock->state == SS_READY) {
 		tipc_set_portunreturnable(portref, 1);
 		if (sock->type == SOCK_DGRAM)
diff --git a/net/tipc/subscr.c b/net/tipc/subscr.c
index 8c01ccd..8f8d0a6 100644
--- a/net/tipc/subscr.c
+++ b/net/tipc/subscr.c
@@ -474,6 +474,7 @@ static void subscr_named_msg_event(void *usr_handle,
 		kfree(subscriber);
 		return;
 	}
+	spin_unlock_bh(subscriber->lock);
 
 	/* Establish a connection to subscriber */
 
-- 
1.5.3.2

