From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/5] rxrpc: Tidy up the rxrpc_call struct a bit
Date: Tue, 23 Aug 2016 16:26:32 +0100
Message-ID: <147196599214.28271.8529794995585869671.stgit@warthog.procyon.org.uk>
References: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do a little tidying of the rxrpc_call struct:

 (1) in_clientflag is no longer compared against the value that's in the
     packet, so keeping it in this form isn't necessary.  Use a flag in
     flags instead and provide a pair of wrapper functions.

 (2) We don't read the epoch value, so that can go.

 (3) Move what remains of the data that were used for hashing up in the
     struct to be with the channel number.

 (4) Get rid of the local pointer.  We can get at this via the socket
     struct and we only use this in the procfs viewer.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   23 +++++++++++++++--------
 net/rxrpc/call_object.c |    7 +------
 net/rxrpc/conn_client.c |    1 -
 net/rxrpc/output.c      |    4 ++--
 net/rxrpc/proc.c        |    6 +++---
 5 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3a2f4c214811..0e6bc8227d54 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -344,6 +344,7 @@ enum rxrpc_call_flag {
 	RXRPC_CALL_INIT_ACCEPT,		/* acceptance was initiated */
 	RXRPC_CALL_HAS_USERID,		/* has a user ID attached */
 	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
+	RXRPC_CALL_IS_SERVICE,		/* Call is service call */
 };
 
 /*
@@ -431,8 +432,11 @@ struct rxrpc_call {
 	int			error_report;	/* Network error (ICMP/local transport) */
 	int			error;		/* Local error incurred */
 	enum rxrpc_call_state	state : 8;	/* current state of call */
-	int			debug_id;	/* debug ID for printks */
 	u8			channel;	/* connection channel occupied by this call */
+	u16			service_id;	/* service ID */
+	u32			call_id;	/* call ID on connection  */
+	u32			cid;		/* connection ID plus channel index */
+	int			debug_id;	/* debug ID for printks */
 
 	/* transmission-phase ACK management */
 	u8			acks_head;	/* offset into window of first entry */
@@ -460,13 +464,6 @@ struct rxrpc_call {
 	/* received packet records, 1 bit per record */
 #define RXRPC_ACKR_WINDOW_ASZ DIV_ROUND_UP(RXRPC_MAXACKS, BITS_PER_LONG)
 	unsigned long		ackr_window[RXRPC_ACKR_WINDOW_ASZ + 1];
-
-	u8			in_clientflag;	/* Copy of conn->in_clientflag */
-	struct rxrpc_local	*local;		/* Local endpoint. */
-	u32			call_id;	/* call ID on connection  */
-	u32			cid;		/* connection ID plus channel index */
-	u32			epoch;		/* epoch of this connection */
-	u16			service_id;	/* service ID */
 };
 
 /*
@@ -527,6 +524,16 @@ void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
 void __rxrpc_put_call(struct rxrpc_call *);
 void __exit rxrpc_destroy_all_calls(void);
 
+static inline bool rxrpc_is_service_call(const struct rxrpc_call *call)
+{
+	return test_bit(RXRPC_CALL_IS_SERVICE, &call->flags);
+}
+
+static inline bool rxrpc_is_client_call(const struct rxrpc_call *call)
+{
+	return !rxrpc_is_service_call(call);
+}
+
 /*
  * conn_client.c
  */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index ae057e0740f3..5007e7ac889f 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -167,10 +167,7 @@ static struct rxrpc_call *rxrpc_alloc_client_call(struct rxrpc_sock *rx,
 	sock_hold(&rx->sk);
 	call->socket = rx;
 	call->rx_data_post = 1;
-
-	call->local = rx->local;
 	call->service_id = srx->srx_service;
-	call->in_clientflag = 0;
 
 	_leave(" = %p", call);
 	return call;
@@ -323,6 +320,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate->channel	= chan;
 	candidate->rx_data_post	= 0;
 	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
+	candidate->flags	|= (1 << RXRPC_CALL_IS_SERVICE);
 	if (conn->security_ix > 0)
 		candidate->state = RXRPC_CALL_SERVER_SECURING;
 
@@ -397,10 +395,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	list_add_tail(&call->link, &rxrpc_calls);
 	write_unlock_bh(&rxrpc_call_lock);
 
-	call->local = conn->params.local;
-	call->epoch = conn->proto.epoch;
 	call->service_id = conn->params.service_id;
-	call->in_clientflag = RXRPC_CLIENT_INITIATED;
 
 	_net("CALL incoming %d on CONN %d", call->debug_id, call->conn->debug_id);
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 9e91f27b0d0f..d8dd8e6bb172 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -281,7 +281,6 @@ found_channel:
 	_debug("found chan");
 	call->conn	= conn;
 	call->channel	= chan;
-	call->epoch	= conn->proto.epoch;
 	call->cid	= conn->proto.cid | chan;
 	call->call_id	= ++conn->channels[chan].call_counter;
 	conn->channels[chan].call_id = call->call_id;
diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index f4bda06b7d2d..9e626f1e2668 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -218,11 +218,11 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = 0;
 	} else if (cmd != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
-	} else if (!call->in_clientflag &&
+	} else if (rxrpc_is_client_call(call) &&
 		   call->state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
 		/* request phase complete for this client call */
 		ret = -EPROTO;
-	} else if (call->in_clientflag &&
+	} else if (rxrpc_is_service_call(call) &&
 		   call->state != RXRPC_CALL_SERVER_ACK_REQUEST &&
 		   call->state != RXRPC_CALL_SERVER_SEND_REPLY) {
 		/* Reply phase not begun or not complete for service call. */
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index ced5f07444e5..f92de18b5893 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -61,8 +61,8 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	call = list_entry(v, struct rxrpc_call, link);
 
 	sprintf(lbuff, "%pI4:%u",
-		&call->local->srx.transport.sin.sin_addr,
-		ntohs(call->local->srx.transport.sin.sin_port));
+		&call->socket->local->srx.transport.sin.sin_addr,
+		ntohs(call->socket->local->srx.transport.sin.sin_port));
 
 	conn = call->conn;
 	if (conn)
@@ -80,7 +80,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   call->service_id,
 		   call->cid,
 		   call->call_id,
-		   call->in_clientflag ? "Svc" : "Clt",
+		   rxrpc_is_service_call(call) ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
 		   call->remote_abort ?: call->local_abort,
