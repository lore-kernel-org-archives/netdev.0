From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/5] rxrpc: Drop channel number field from
 rxrpc_call struct
Date: Tue, 23 Aug 2016 16:26:47 +0100
Message-ID: <147196600734.28271.5566666142358830242.stgit@warthog.procyon.org.uk>
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

Drop the channel number (channel) field from the rxrpc_call struct to
reduce the size of the call struct.  The field is redundant: if the call is
attached to a connection, the channel can be obtained from there by AND'ing
with RXRPC_CHANNELMASK.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 -
 net/rxrpc/call_object.c |    7 +++----
 net/rxrpc/conn_client.c |    1 -
 net/rxrpc/conn_object.c |    5 +++--
 net/rxrpc/rxkad.c       |    4 ++--
 5 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 0e6bc8227d54..648060a5df35 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -432,7 +432,6 @@ struct rxrpc_call {
 	int			error_report;	/* Network error (ICMP/local transport) */
 	int			error;		/* Local error incurred */
 	enum rxrpc_call_state	state : 8;	/* current state of call */
-	u8			channel;	/* connection channel occupied by this call */
 	u16			service_id;	/* service ID */
 	u32			call_id;	/* call ID on connection  */
 	u32			cid;		/* connection ID plus channel index */
diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 008188103fd6..4af01805bfc7 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -317,7 +317,6 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate->conn		= conn;
 	candidate->cid		= sp->hdr.cid;
 	candidate->call_id	= sp->hdr.callNumber;
-	candidate->channel	= chan;
 	candidate->rx_data_post	= 0;
 	candidate->state	= RXRPC_CALL_SERVER_ACCEPTING;
 	candidate->flags	|= (1 << RXRPC_CALL_IS_SERVICE);
@@ -330,7 +329,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	call = rcu_dereference_protected(conn->channels[chan].call,
 					 lockdep_is_held(&conn->channel_lock));
 
-	_debug("channel[%u] is %p", candidate->channel, call);
+	_debug("channel[%u] is %p", candidate->cid & RXRPC_CHANNELMASK, call);
 	if (call && call->call_id == sp->hdr.callNumber) {
 		/* already set; must've been a duplicate packet */
 		_debug("extant call [%d]", call->state);
@@ -677,8 +676,8 @@ static void rxrpc_destroy_call(struct work_struct *work)
 	struct rxrpc_call *call =
 		container_of(work, struct rxrpc_call, destroyer);
 
-	_enter("%p{%d,%d,%p}",
-	       call, atomic_read(&call->usage), call->channel, call->conn);
+	_enter("%p{%d,%x,%p}",
+	       call, atomic_read(&call->usage), call->cid, call->conn);
 
 	ASSERTCMP(call->state, ==, RXRPC_CALL_DEAD);
 
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index d8dd8e6bb172..fc32cc67c2de 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -280,7 +280,6 @@ attached:
 found_channel:
 	_debug("found chan");
 	call->conn	= conn;
-	call->channel	= chan;
 	call->cid	= conn->proto.cid | chan;
 	call->call_id	= ++conn->channels[chan].call_counter;
 	conn->channels[chan].call_id = call->call_id;
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 896d84493a05..6a5a17efc538 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -156,9 +156,10 @@ not_found:
 void __rxrpc_disconnect_call(struct rxrpc_call *call)
 {
 	struct rxrpc_connection *conn = call->conn;
-	struct rxrpc_channel *chan = &conn->channels[call->channel];
+	struct rxrpc_channel *chan =
+		&conn->channels[call->cid & RXRPC_CHANNELMASK];
 
-	_enter("%d,%d", conn->debug_id, call->channel);
+	_enter("%d,%x", conn->debug_id, call->cid);
 
 	if (rcu_access_pointer(chan->call) == call) {
 		/* Save the result of the call so that we can repeat it if necessary
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 63afa9e9cc08..89f475febfd7 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -275,7 +275,7 @@ static int rxkad_secure_packet(struct rxrpc_call *call,
 	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
 
 	/* calculate the security checksum */
-	x = call->channel << (32 - RXRPC_CIDSHIFT);
+	x = (call->cid & RXRPC_CHANNELMASK) << (32 - RXRPC_CIDSHIFT);
 	x |= sp->hdr.seq & 0x3fffffff;
 	call->crypto_buf[0] = htonl(sp->hdr.callNumber);
 	call->crypto_buf[1] = htonl(x);
@@ -507,7 +507,7 @@ static int rxkad_verify_packet(struct rxrpc_call *call,
 	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
 
 	/* validate the security checksum */
-	x = call->channel << (32 - RXRPC_CIDSHIFT);
+	x = (call->cid & RXRPC_CHANNELMASK) << (32 - RXRPC_CIDSHIFT);
 	x |= sp->hdr.seq & 0x3fffffff;
 	call->crypto_buf[0] = htonl(call->call_id);
 	call->crypto_buf[1] = htonl(x);
