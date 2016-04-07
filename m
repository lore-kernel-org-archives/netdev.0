From: David Howells <dhowells@redhat.com>
Subject: [PATCH 9/9] rxrpc: Create a null security type and get rid of
 conditional calls
Date: Thu, 07 Apr 2016 17:23:58 +0100
Message-ID: <20160407162358.21283.86909.stgit@warthog.procyon.org.uk>
References: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160407162256.21283.47849.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create a null security type for security index 0 and get rid of all
conditional calls to the security operations.  We expect normally to be
using security, so this should be of little negative impact.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/Makefile        |    1 +
 net/rxrpc/ar-ack.c        |    3 +-
 net/rxrpc/ar-connection.c |    9 +++--
 net/rxrpc/ar-connevent.c  |   11 +-----
 net/rxrpc/ar-input.c      |    2 +
 net/rxrpc/ar-internal.h   |   10 +++--
 net/rxrpc/ar-output.c     |    4 +-
 net/rxrpc/ar-security.c   |   43 +----------------------
 net/rxrpc/insecure.c      |   83 +++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 105 insertions(+), 61 deletions(-)
 create mode 100644 net/rxrpc/insecure.c

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index fa09cb55bfce..e05a06ef2254 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -19,6 +19,7 @@ af-rxrpc-y := \
 	ar-security.o \
 	ar-skbuff.o \
 	ar-transport.o \
+	insecure.o \
 	misc.o
 
 af-rxrpc-$(CONFIG_PROC_FS) += ar-proc.o
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 3cd9264806a4..374478e006e7 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -588,7 +588,8 @@ process_further:
 		_proto("OOSQ DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
 
 		/* secured packets must be verified and possibly decrypted */
-		if (rxrpc_verify_packet(call, skb, _abort_code) < 0)
+		if (call->conn->security->verify_packet(call, skb,
+							_abort_code) < 0)
 			goto protocol_error;
 
 		rxrpc_insert_oos_packet(call, skb);
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 9b6966777633..97f4fae74bca 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -207,6 +207,7 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		INIT_LIST_HEAD(&conn->bundle_link);
 		conn->calls = RB_ROOT;
 		skb_queue_head_init(&conn->rx_queue);
+		conn->security = &rxrpc_no_security;
 		rwlock_init(&conn->lock);
 		spin_lock_init(&conn->state_lock);
 		atomic_set(&conn->usage, 1);
@@ -564,8 +565,7 @@ int rxrpc_connect_call(struct rxrpc_sock *rx,
 		     candidate->debug_id, candidate->trans->debug_id);
 
 		rxrpc_assign_connection_id(candidate);
-		if (candidate->security)
-			candidate->security->prime_packet_security(candidate);
+		candidate->security->prime_packet_security(candidate);
 
 		/* leave the candidate lurking in zombie mode attached to the
 		 * bundle until we're ready for it */
@@ -830,7 +830,10 @@ static void rxrpc_destroy_connection(struct rxrpc_connection *conn)
 	ASSERT(RB_EMPTY_ROOT(&conn->calls));
 	rxrpc_purge_queue(&conn->rx_queue);
 
-	rxrpc_clear_conn_security(conn);
+	conn->security->clear(conn);
+	key_put(conn->key);
+	key_put(conn->server_key);
+
 	rxrpc_put_transport(conn->trans);
 	kfree(conn);
 	_leave("");
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 291522392ac7..5f9563968a5b 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -174,15 +174,10 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return -ECONNABORTED;
 
 	case RXRPC_PACKET_TYPE_CHALLENGE:
-		if (conn->security)
-			return conn->security->respond_to_challenge(
-				conn, skb, _abort_code);
-		return -EPROTO;
+		return conn->security->respond_to_challenge(conn, skb,
+							    _abort_code);
 
 	case RXRPC_PACKET_TYPE_RESPONSE:
-		if (!conn->security)
-			return -EPROTO;
-
 		ret = conn->security->verify_response(conn, skb, _abort_code);
 		if (ret < 0)
 			return ret;
@@ -238,8 +233,6 @@ static void rxrpc_secure_connection(struct rxrpc_connection *conn)
 		}
 	}
 
-	ASSERT(conn->security != NULL);
-
 	if (conn->security->issue_challenge(conn) < 0) {
 		abort_code = RX_CALL_DEAD;
 		ret = -ENOMEM;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 401ea55fb773..c91420eda26c 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -193,7 +193,7 @@ static int rxrpc_fast_process_data(struct rxrpc_call *call,
 
 	/* if the packet need security things doing to it, then it goes down
 	 * the slow path */
-	if (call->conn->security)
+	if (call->conn->security_ix)
 		goto enqueue_packet;
 
 	sp->call = call;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 72fd675a891e..f0b807a163fa 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -9,6 +9,7 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <net/sock.h>
 #include <rxrpc/packet.h>
 
 #if 0
@@ -612,10 +613,6 @@ int __init rxrpc_init_security(void);
 void rxrpc_exit_security(void);
 int rxrpc_init_client_conn_security(struct rxrpc_connection *);
 int rxrpc_init_server_conn_security(struct rxrpc_connection *);
-int rxrpc_secure_packet(const struct rxrpc_call *, struct sk_buff *, size_t,
-			void *);
-int rxrpc_verify_packet(const struct rxrpc_call *, struct sk_buff *, u32 *);
-void rxrpc_clear_conn_security(struct rxrpc_connection *);
 
 /*
  * ar-skbuff.c
@@ -635,6 +632,11 @@ struct rxrpc_transport *rxrpc_find_transport(struct rxrpc_local *,
 					     struct rxrpc_peer *);
 
 /*
+ * insecure.c
+ */
+extern const struct rxrpc_security rxrpc_no_security;
+
+/*
  * misc.c
  */
 extern unsigned int rxrpc_requested_ack_delay;
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 94e7d9537437..51cb10062a8d 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -663,7 +663,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			size_t pad;
 
 			/* pad out if we're using security */
-			if (conn->security) {
+			if (conn->security_ix) {
 				pad = conn->security_size + skb->mark;
 				pad = conn->size_align - pad;
 				pad &= conn->size_align - 1;
@@ -695,7 +695,7 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 			if (more && seq & 1)
 				sp->hdr.flags |= RXRPC_REQUEST_ACK;
 
-			ret = rxrpc_secure_packet(
+			ret = conn->security->secure_packet(
 				call, skb, skb->mark,
 				skb->head + sizeof(struct rxrpc_wire_header));
 			if (ret < 0)
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index 6946aec7ab1f..d223253b22fa 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -23,6 +23,7 @@ static LIST_HEAD(rxrpc_security_methods);
 static DECLARE_RWSEM(rxrpc_security_sem);
 
 static const struct rxrpc_security *rxrpc_security_types[] = {
+	[RXRPC_SECURITY_NONE]	= &rxrpc_no_security,
 #ifdef CONFIG_RXKAD
 	[RXRPC_SECURITY_RXKAD]	= &rxkad,
 #endif
@@ -98,7 +99,7 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 
 	ret = conn->security->init_connection_security(conn);
 	if (ret < 0) {
-		conn->security = NULL;
+		conn->security = &rxrpc_no_security;
 		return ret;
 	}
 
@@ -165,43 +166,3 @@ found_service:
 	_leave(" = 0");
 	return 0;
 }
-
-/*
- * secure a packet prior to transmission
- */
-int rxrpc_secure_packet(const struct rxrpc_call *call,
-			struct sk_buff *skb,
-			size_t data_size,
-			void *sechdr)
-{
-	if (call->conn->security)
-		return call->conn->security->secure_packet(
-			call, skb, data_size, sechdr);
-	return 0;
-}
-
-/*
- * secure a packet prior to transmission
- */
-int rxrpc_verify_packet(const struct rxrpc_call *call, struct sk_buff *skb,
-			u32 *_abort_code)
-{
-	if (call->conn->security)
-		return call->conn->security->verify_packet(
-			call, skb, _abort_code);
-	return 0;
-}
-
-/*
- * clear connection security
- */
-void rxrpc_clear_conn_security(struct rxrpc_connection *conn)
-{
-	_enter("{%d}", conn->debug_id);
-
-	if (conn->security)
-		conn->security->clear(conn);
-
-	key_put(conn->key);
-	key_put(conn->server_key);
-}
diff --git a/net/rxrpc/insecure.c b/net/rxrpc/insecure.c
new file mode 100644
index 000000000000..e571403613c1
--- /dev/null
+++ b/net/rxrpc/insecure.c
@@ -0,0 +1,83 @@
+/* Null security operations.
+ *
+ * Copyright (C) 2016 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+static int none_init_connection_security(struct rxrpc_connection *conn)
+{
+	return 0;
+}
+
+static void none_prime_packet_security(struct rxrpc_connection *conn)
+{
+}
+
+static int none_secure_packet(const struct rxrpc_call *call,
+			       struct sk_buff *skb,
+			       size_t data_size,
+			       void *sechdr)
+{
+	return 0;
+}
+
+static int none_verify_packet(const struct rxrpc_call *call,
+			       struct sk_buff *skb,
+			       u32 *_abort_code)
+{
+	return 0;
+}
+
+static int none_respond_to_challenge(struct rxrpc_connection *conn,
+				      struct sk_buff *skb,
+				      u32 *_abort_code)
+{
+	*_abort_code = RX_PROTOCOL_ERROR;
+	return -EPROTO;
+}
+
+static int none_verify_response(struct rxrpc_connection *conn,
+				 struct sk_buff *skb,
+				 u32 *_abort_code)
+{
+	*_abort_code = RX_PROTOCOL_ERROR;
+	return -EPROTO;
+}
+
+static void none_clear(struct rxrpc_connection *conn)
+{
+}
+
+static int none_init(void)
+{
+	return 0;
+}
+
+static void none_exit(void)
+{
+}
+
+/*
+ * RxRPC Kerberos-based security
+ */
+const struct rxrpc_security rxrpc_no_security = {
+	.name				= "none",
+	.security_index			= RXRPC_SECURITY_NONE,
+	.init				= none_init,
+	.exit				= none_exit,
+	.init_connection_security	= none_init_connection_security,
+	.prime_packet_security		= none_prime_packet_security,
+	.secure_packet			= none_secure_packet,
+	.verify_packet			= none_verify_packet,
+	.respond_to_challenge		= none_respond_to_challenge,
+	.verify_response		= none_verify_response,
+	.clear				= none_clear,
+};
