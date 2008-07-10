From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 1/7 net-next-2.6] tipc: Remove unneeded parameter to tipc_createport_raw()
Date: Thu, 10 Jul 2008 17:26:05 -0400
Message-ID: <1215725171-10094-2-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33082 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030AbYGJVZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:08 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates an unneeded parameter when creating a low-level
TIPC port object.  Instead of returning both the pointer to the port
structure and the port's reference ID, it now returns only the pointer
since the port structure contains the reference ID as one of its fields.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 include/net/tipc/tipc_port.h |   13 +++----------
 net/tipc/port.c              |   28 ++++++++++------------------
 net/tipc/socket.c            |   15 +++++++--------
 3 files changed, 20 insertions(+), 36 deletions(-)

diff --git a/include/net/tipc/tipc_port.h b/include/net/tipc/tipc_port.h
index 9923e41..c54917c 100644
--- a/include/net/tipc/tipc_port.h
+++ b/include/net/tipc/tipc_port.h
@@ -2,7 +2,7 @@
  * include/net/tipc/tipc_port.h: Include file for privileged access to TIPC ports
  * 
  * Copyright (c) 1994-2007, Ericsson AB
- * Copyright (c) 2005-2007, Wind River Systems
+ * Copyright (c) 2005-2008, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -75,17 +75,10 @@ struct tipc_port {
 };
 
 
-/**
- * tipc_createport_raw - create a native TIPC port and return it's reference
- *
- * Note: 'dispatcher' and 'wakeup' deliver a locked port.
- */
-
-u32 tipc_createport_raw(void *usr_handle,
+struct tipc_port *tipc_createport_raw(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
-			const u32 importance,
-			struct tipc_port **tp_ptr);
+			const u32 importance);
 
 int tipc_reject_msg(struct sk_buff *buf, u32 err);
 
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 2e0cff4..ffba1e7 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -2,7 +2,7 @@
  * net/tipc/port.c: TIPC port code
  *
  * Copyright (c) 1992-2007, Ericsson AB
- * Copyright (c) 2004-2007, Wind River Systems
+ * Copyright (c) 2004-2008, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -213,16 +213,13 @@ exit:
 /**
  * tipc_createport_raw - create a generic TIPC port
  *
- * Returns port reference, or 0 if unable to create it
- *
- * Note: The newly created port is returned in the locked state.
+ * Returns pointer to (locked) TIPC port, or NULL if unable to create it
  */
 
-u32 tipc_createport_raw(void *usr_handle,
+struct tipc_port *tipc_createport_raw(void *usr_handle,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
-			const u32 importance,
-			struct tipc_port **tp_ptr)
+			const u32 importance)
 {
 	struct port *p_ptr;
 	struct tipc_msg *msg;
@@ -231,13 +228,13 @@ u32 tipc_createport_raw(void *usr_handle,
 	p_ptr = kzalloc(sizeof(*p_ptr), GFP_ATOMIC);
 	if (!p_ptr) {
 		warn("Port creation failed, no memory\n");
-		return 0;
+		return NULL;
 	}
 	ref = tipc_ref_acquire(p_ptr, &p_ptr->publ.lock);
 	if (!ref) {
 		warn("Port creation failed, reference table exhausted\n");
 		kfree(p_ptr);
-		return 0;
+		return NULL;
 	}
 
 	p_ptr->publ.usr_handle = usr_handle;
@@ -260,8 +257,7 @@ u32 tipc_createport_raw(void *usr_handle,
 	INIT_LIST_HEAD(&p_ptr->port_list);
 	list_add_tail(&p_ptr->port_list, &ports);
 	spin_unlock_bh(&tipc_port_list_lock);
-	*tp_ptr = &p_ptr->publ;
-	return ref;
+	return &(p_ptr->publ);
 }
 
 int tipc_deleteport(u32 ref)
@@ -1044,21 +1040,18 @@ int tipc_createport(u32 user_ref,
 {
 	struct user_port *up_ptr;
 	struct port *p_ptr;
-	struct tipc_port *tp_ptr;
-	u32 ref;
 
 	up_ptr = kmalloc(sizeof(*up_ptr), GFP_ATOMIC);
 	if (!up_ptr) {
 		warn("Port creation failed, no memory\n");
 		return -ENOMEM;
 	}
-	ref = tipc_createport_raw(NULL, port_dispatcher, port_wakeup,
-				  importance, &tp_ptr);
-	if (ref == 0) {
+	p_ptr = (struct port *)tipc_createport_raw(NULL, port_dispatcher,
+						   port_wakeup, importance);
+	if (!p_ptr) {
 		kfree(up_ptr);
 		return -ENOMEM;
 	}
-	p_ptr = (struct port *)tp_ptr;
 
 	p_ptr->user_port = up_ptr;
 	up_ptr->user_ref = user_ref;
@@ -1074,7 +1067,6 @@ int tipc_createport(u32 user_ref,
 	INIT_LIST_HEAD(&up_ptr->uport_list);
 	tipc_reg_add_port(up_ptr);
 	*portref = p_ptr->publ.ref;
-	dbg(" tipc_createport: %x with ref %u\n", p_ptr, p_ptr->publ.ref);
 	tipc_port_unlock(p_ptr);
 	return TIPC_OK;
 }
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 38f4879..9c362c5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2,7 +2,7 @@
  * net/tipc/socket.c: TIPC socket API
  *
  * Copyright (c) 2001-2007, Ericsson AB
- * Copyright (c) 2004-2007, Wind River Systems
+ * Copyright (c) 2004-2008, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -189,7 +189,6 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	socket_state state;
 	struct sock *sk;
 	struct tipc_port *tp_ptr;
-	u32 portref;
 
 	/* Validate arguments */
 
@@ -225,9 +224,9 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 
 	/* Allocate TIPC port for socket to use */
 
-	portref = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
-				      TIPC_LOW_IMPORTANCE, &tp_ptr);
-	if (unlikely(portref == 0)) {
+	tp_ptr = tipc_createport_raw(sk, &dispatch, &wakeupdispatch,
+				     TIPC_LOW_IMPORTANCE);
+	if (unlikely(!tp_ptr)) {
 		sk_free(sk);
 		return -ENOMEM;
 	}
@@ -240,14 +239,14 @@ static int tipc_create(struct net *net, struct socket *sock, int protocol)
 	sock_init_data(sock, sk);
 	sk->sk_rcvtimeo = msecs_to_jiffies(CONN_TIMEOUT_DEFAULT);
 	sk->sk_backlog_rcv = backlog_rcv;
-	tipc_sk(sk)->p = tipc_get_port(portref);
+	tipc_sk(sk)->p = tp_ptr;
 
 	spin_unlock_bh(tp_ptr->lock);
 
 	if (sock->state == SS_READY) {
-		tipc_set_portunreturnable(portref, 1);
+		tipc_set_portunreturnable(tp_ptr->ref, 1);
 		if (sock->type == SOCK_DGRAM)
-			tipc_set_portunreliable(portref, 1);
+			tipc_set_portunreliable(tp_ptr->ref, 1);
 	}
 
 	atomic_inc(&tipc_user_count);
-- 
1.5.4.3

