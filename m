From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/4] rxrpc: Separate the connection's protocol
 service ID from the lookup ID
Date: Tue, 06 Jun 2017 10:54:28 +0100
Message-ID: <149674286816.26138.14078585419110118952.stgit@warthog.procyon.org.uk>
References: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149674286135.26138.12623162384868251541.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep the rxrpc_connection struct's idea of the service ID that is exposed
in the protocol separate from the service ID that's used as a lookup key.

This allows the protocol service ID on a client connection to get upgraded
without making the connection unfindable for other client calls that also
would like to use the upgraded connection.

The connection's actual service ID is then returned through recvmsg() by
way of msg_name.

Whilst we're at it, we get rid of the last_service_id field from each
channel.  The service ID is per-connection, not per-call and an entire
connection is upgraded in one go.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |    5 ++---
 net/rxrpc/ar-internal.h  |    2 +-
 net/rxrpc/conn_client.c  |    4 ++++
 net/rxrpc/conn_event.c   |    4 ++--
 net/rxrpc/conn_object.c  |    1 -
 net/rxrpc/conn_service.c |    1 +
 net/rxrpc/proc.c         |    2 +-
 net/rxrpc/recvmsg.c      |    7 +++++--
 net/rxrpc/rxkad.c        |    2 +-
 net/rxrpc/security.c     |    4 ++--
 10 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index cd34ffbff1d1..1e4ac889ec00 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -131,9 +131,8 @@ static int rxrpc_validate_address(struct rxrpc_sock *rx,
 static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 {
 	struct sockaddr_rxrpc *srx = (struct sockaddr_rxrpc *)saddr;
-	struct sock *sk = sock->sk;
 	struct rxrpc_local *local;
-	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
 	u16 service_id = srx->srx_service;
 	int ret;
 
@@ -152,7 +151,7 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	memcpy(&rx->srx, srx, sizeof(rx->srx));
 
-	local = rxrpc_lookup_local(sock_net(sock->sk), &rx->srx);
+	local = rxrpc_lookup_local(sock_net(&rx->sk), &rx->srx);
 	if (IS_ERR(local)) {
 		ret = PTR_ERR(local);
 		goto error_unlock;
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 067dbb3121d0..de98a49adb35 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -386,7 +386,6 @@ struct rxrpc_connection {
 		u32			call_counter;	/* Call ID counter */
 		u32			last_call;	/* ID of last call */
 		u8			last_type;	/* Type of last packet */
-		u16			last_service_id;
 		union {
 			u32		last_seq;
 			u32		last_abort;
@@ -417,6 +416,7 @@ struct rxrpc_connection {
 	atomic_t		serial;		/* packet serial number counter */
 	unsigned int		hi_serial;	/* highest serial number received */
 	u32			security_nonce;	/* response re-use preventer */
+	u16			service_id;	/* Service ID, possibly upgraded */
 	u8			size_align;	/* data size alignment (for security) */
 	u8			security_size;	/* security header size */
 	u8			security_ix;	/* security type */
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index c86f3202f967..3f358bf424ad 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -188,6 +188,7 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	conn->params		= *cp;
 	conn->out_clientflag	= RXRPC_CLIENT_INITIATED;
 	conn->state		= RXRPC_CONN_CLIENT;
+	conn->service_id	= cp->service_id;
 
 	ret = rxrpc_get_client_connection_id(conn, gfp);
 	if (ret < 0)
@@ -343,6 +344,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 	if (cp->exclusive) {
 		call->conn = candidate;
 		call->security_ix = candidate->security_ix;
+		call->service_id = candidate->service_id;
 		_leave(" = 0 [exclusive %d]", candidate->debug_id);
 		return 0;
 	}
@@ -392,6 +394,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 	set_bit(RXRPC_CONN_IN_CLIENT_CONNS, &candidate->flags);
 	call->conn = candidate;
 	call->security_ix = candidate->security_ix;
+	call->service_id = candidate->service_id;
 	spin_unlock(&local->client_conns_lock);
 	_leave(" = 0 [new %d]", candidate->debug_id);
 	return 0;
@@ -413,6 +416,7 @@ static int rxrpc_get_client_conn(struct rxrpc_call *call,
 	spin_lock(&conn->channel_lock);
 	call->conn = conn;
 	call->security_ix = conn->security_ix;
+	call->service_id = conn->service_id;
 	list_add(&call->chan_wait_link, &conn->waiting_calls);
 	spin_unlock(&conn->channel_lock);
 	_leave(" = 0 [extant %d]", conn->debug_id);
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index 46babcf82ce8..59a51a56e7c8 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -74,7 +74,7 @@ static void rxrpc_conn_retransmit_call(struct rxrpc_connection *conn,
 	pkt.whdr.userStatus	= 0;
 	pkt.whdr.securityIndex	= conn->security_ix;
 	pkt.whdr._rsvd		= 0;
-	pkt.whdr.serviceId	= htons(chan->last_service_id);
+	pkt.whdr.serviceId	= htons(conn->service_id);
 
 	len = sizeof(pkt.whdr);
 	switch (chan->last_type) {
@@ -208,7 +208,7 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	whdr.userStatus	= 0;
 	whdr.securityIndex = conn->security_ix;
 	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(conn->params.service_id);
+	whdr.serviceId	= htons(conn->service_id);
 
 	word		= htonl(conn->local_abort);
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index ade4d3d0b2a7..5bb255107427 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -167,7 +167,6 @@ void __rxrpc_disconnect_call(struct rxrpc_connection *conn,
 		 * through the channel, whilst disposing of the actual call record.
 		 */
 		trace_rxrpc_disconnect_call(call);
-		chan->last_service_id = call->service_id;
 		if (call->abort_code) {
 			chan->last_abort = call->abort_code;
 			chan->last_type = RXRPC_PACKET_TYPE_ABORT;
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index edfc633f7d5e..c7f8682a55b2 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -160,6 +160,7 @@ void rxrpc_new_incoming_connection(struct rxrpc_connection *conn,
 	conn->proto.epoch	= sp->hdr.epoch;
 	conn->proto.cid		= sp->hdr.cid & RXRPC_CIDMASK;
 	conn->params.service_id	= sp->hdr.serviceId;
+	conn->service_id	= sp->hdr.serviceId;
 	conn->security_ix	= sp->hdr.securityIndex;
 	conn->out_clientflag	= 0;
 	if (conn->security_ix)
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index e92d8405b15a..7421656963a9 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -190,7 +190,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		   " %s %08x %08x %08x\n",
 		   lbuff,
 		   rbuff,
-		   conn->params.service_id,
+		   conn->service_id,
 		   conn->proto.cid,
 		   rxrpc_conn_is_service(conn) ? "Svc" : "Clt",
 		   atomic_read(&conn->usage),
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index f9caf3b77509..bdece21f313d 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -522,8 +522,11 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 	}
 
 	if (msg->msg_name) {
-		size_t len = sizeof(call->conn->params.peer->srx);
-		memcpy(msg->msg_name, &call->conn->params.peer->srx, len);
+		struct sockaddr_rxrpc *srx = msg->msg_name;
+		size_t len = sizeof(call->peer->srx);
+
+		memcpy(msg->msg_name, &call->peer->srx, len);
+		srx->srx_service = call->service_id;
 		msg->msg_namelen = len;
 	}
 
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 29fe20ad04aa..46d1a1f0b55b 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -649,7 +649,7 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	whdr.userStatus	= 0;
 	whdr.securityIndex = conn->security_ix;
 	whdr._rsvd	= 0;
-	whdr.serviceId	= htons(conn->params.service_id);
+	whdr.serviceId	= htons(conn->service_id);
 
 	iov[0].iov_base	= &whdr;
 	iov[0].iov_len	= sizeof(whdr);
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 7d921e56e715..b9f5dbbe0b8b 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -121,7 +121,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	_enter("");
 
-	sprintf(kdesc, "%u:%u", conn->params.service_id, conn->security_ix);
+	sprintf(kdesc, "%u:%u", conn->service_id, conn->security_ix);
 
 	sec = rxrpc_security_lookup(conn->security_ix);
 	if (!sec) {
@@ -133,7 +133,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	read_lock(&local->services_lock);
 	rx = rcu_dereference_protected(local->service,
 				       lockdep_is_held(&local->services_lock));
-	if (rx && rx->srx.srx_service == conn->params.service_id)
+	if (rx && rx->srx.srx_service == conn->service_id)
 		goto found_service;
 
 	/* the service appears to have died */
