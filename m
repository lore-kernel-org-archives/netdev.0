From: David Howells <dhowells@redhat.com>
Subject: [PATCH 02/13] rxrpc: Convert call flag and event numbers into enums
Date: Fri, 04 Mar 2016 16:37:19 +0000
Message-ID: <20160304163719.31057.29626.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert call flag and event numbers into enums and move their definitions
outside of the struct.

Also move the call state enum outside of the struct and add an extra
element to count the number of states.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-ack.c      |    3 +
 net/rxrpc/ar-call.c     |    2 -
 net/rxrpc/ar-internal.h |  107 +++++++++++++++++++++++++++--------------------
 3 files changed, 65 insertions(+), 47 deletions(-)

diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index adc555e0323d..7cb7e45c8bad 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -886,10 +886,11 @@ void rxrpc_process_call(struct work_struct *work)
 	struct rxrpc_header hdr;
 	struct msghdr msg;
 	struct kvec iov[5];
+	enum rxrpc_call_event genbit;
 	unsigned long bits;
 	__be32 data, pad;
 	size_t len;
-	int genbit, loop, nbit, ioc, ret, mtu;
+	int loop, nbit, ioc, ret, mtu;
 	u32 abort_code = RX_PROTOCOL_ERROR;
 	u8 *acks = NULL;
 
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index a9e05db0f5d5..d9a8eeb9290a 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -28,7 +28,7 @@ unsigned rxrpc_max_call_lifetime = 60 * HZ;
  */
 unsigned rxrpc_dead_call_expiry = 2 * HZ;
 
-const char *const rxrpc_call_states[] = {
+const char *const rxrpc_call_states[NR__RXRPC_CALL_STATES] = {
 	[RXRPC_CALL_CLIENT_SEND_REQUEST]	= "ClSndReq",
 	[RXRPC_CALL_CLIENT_AWAIT_REPLY]		= "ClAwtRpl",
 	[RXRPC_CALL_CLIENT_RECV_REPLY]		= "ClRcvRpl",
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2934a73a5981..3aea424a88e4 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -293,6 +293,67 @@ struct rxrpc_connection {
 };
 
 /*
+ * Flags in call->flags.
+ */
+enum rxrpc_call_flag {
+	RXRPC_CALL_RELEASED,		/* call has been released - no more message to userspace */
+	RXRPC_CALL_TERMINAL_MSG,	/* call has given the socket its final message */
+	RXRPC_CALL_RCVD_LAST,		/* all packets received */
+	RXRPC_CALL_RUN_RTIMER,		/* Tx resend timer started */
+	RXRPC_CALL_TX_SOFT_ACK,		/* sent some soft ACKs */
+	RXRPC_CALL_PROC_BUSY,		/* the processor is busy */
+	RXRPC_CALL_INIT_ACCEPT,		/* acceptance was initiated */
+	RXRPC_CALL_HAS_USERID,		/* has a user ID attached */
+	RXRPC_CALL_EXPECT_OOS,		/* expect out of sequence packets */
+};
+
+/*
+ * Events that can be raised on a call.
+ */
+enum rxrpc_call_event {
+	RXRPC_CALL_RCVD_ACKALL,		/* ACKALL or reply received */
+	RXRPC_CALL_RCVD_BUSY,		/* busy packet received */
+	RXRPC_CALL_RCVD_ABORT,		/* abort packet received */
+	RXRPC_CALL_RCVD_ERROR,		/* network error received */
+	RXRPC_CALL_ACK_FINAL,		/* need to generate final ACK (and release call) */
+	RXRPC_CALL_ACK,			/* need to generate ACK */
+	RXRPC_CALL_REJECT_BUSY,		/* need to generate busy message */
+	RXRPC_CALL_ABORT,		/* need to generate abort */
+	RXRPC_CALL_CONN_ABORT,		/* local connection abort generated */
+	RXRPC_CALL_RESEND_TIMER,	/* Tx resend timer expired */
+	RXRPC_CALL_RESEND,		/* Tx resend required */
+	RXRPC_CALL_DRAIN_RX_OOS,	/* drain the Rx out of sequence queue */
+	RXRPC_CALL_LIFE_TIMER,		/* call's lifetimer ran out */
+	RXRPC_CALL_ACCEPTED,		/* incoming call accepted by userspace app */
+	RXRPC_CALL_SECURED,		/* incoming call's connection is now secure */
+	RXRPC_CALL_POST_ACCEPT,		/* need to post an "accept?" message to the app */
+	RXRPC_CALL_RELEASE,		/* need to release the call's resources */
+};
+
+/*
+ * The states that a call can be in.
+ */
+enum rxrpc_call_state {
+	RXRPC_CALL_CLIENT_SEND_REQUEST,	/* - client sending request phase */
+	RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
+	RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
+	RXRPC_CALL_CLIENT_FINAL_ACK,	/* - client sending final ACK phase */
+	RXRPC_CALL_SERVER_SECURING,	/* - server securing request connection */
+	RXRPC_CALL_SERVER_ACCEPTING,	/* - server accepting request */
+	RXRPC_CALL_SERVER_RECV_REQUEST,	/* - server receiving request */
+	RXRPC_CALL_SERVER_ACK_REQUEST,	/* - server pending ACK of request */
+	RXRPC_CALL_SERVER_SEND_REPLY,	/* - server sending reply */
+	RXRPC_CALL_SERVER_AWAIT_ACK,	/* - server awaiting final ACK */
+	RXRPC_CALL_COMPLETE,		/* - call completed */
+	RXRPC_CALL_SERVER_BUSY,		/* - call rejected by busy server */
+	RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
+	RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
+	RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
+	RXRPC_CALL_DEAD,		/* - call is dead */
+	NR__RXRPC_CALL_STATES
+};
+
+/*
  * RxRPC call definition
  * - matched by { connection, call_id }
  */
@@ -317,57 +378,13 @@ struct rxrpc_call {
 	unsigned long		user_call_ID;	/* user-defined call ID */
 	unsigned long		creation_jif;	/* time of call creation */
 	unsigned long		flags;
-#define RXRPC_CALL_RELEASED	0	/* call has been released - no more message to userspace */
-#define RXRPC_CALL_TERMINAL_MSG	1	/* call has given the socket its final message */
-#define RXRPC_CALL_RCVD_LAST	2	/* all packets received */
-#define RXRPC_CALL_RUN_RTIMER	3	/* Tx resend timer started */
-#define RXRPC_CALL_TX_SOFT_ACK	4	/* sent some soft ACKs */
-#define RXRPC_CALL_PROC_BUSY	5	/* the processor is busy */
-#define RXRPC_CALL_INIT_ACCEPT	6	/* acceptance was initiated */
-#define RXRPC_CALL_HAS_USERID	7	/* has a user ID attached */
-#define RXRPC_CALL_EXPECT_OOS	8	/* expect out of sequence packets */
 	unsigned long		events;
-#define RXRPC_CALL_RCVD_ACKALL	0	/* ACKALL or reply received */
-#define RXRPC_CALL_RCVD_BUSY	1	/* busy packet received */
-#define RXRPC_CALL_RCVD_ABORT	2	/* abort packet received */
-#define RXRPC_CALL_RCVD_ERROR	3	/* network error received */
-#define RXRPC_CALL_ACK_FINAL	4	/* need to generate final ACK (and release call) */
-#define RXRPC_CALL_ACK		5	/* need to generate ACK */
-#define RXRPC_CALL_REJECT_BUSY	6	/* need to generate busy message */
-#define RXRPC_CALL_ABORT	7	/* need to generate abort */
-#define RXRPC_CALL_CONN_ABORT	8	/* local connection abort generated */
-#define RXRPC_CALL_RESEND_TIMER	9	/* Tx resend timer expired */
-#define RXRPC_CALL_RESEND	10	/* Tx resend required */
-#define RXRPC_CALL_DRAIN_RX_OOS	11	/* drain the Rx out of sequence queue */
-#define RXRPC_CALL_LIFE_TIMER	12	/* call's lifetimer ran out */
-#define RXRPC_CALL_ACCEPTED	13	/* incoming call accepted by userspace app */
-#define RXRPC_CALL_SECURED	14	/* incoming call's connection is now secure */
-#define RXRPC_CALL_POST_ACCEPT	15	/* need to post an "accept?" message to the app */
-#define RXRPC_CALL_RELEASE	16	/* need to release the call's resources */
-
 	spinlock_t		lock;
 	rwlock_t		state_lock;	/* lock for state transition */
 	atomic_t		usage;
 	atomic_t		sequence;	/* Tx data packet sequence counter */
 	u32			abort_code;	/* local/remote abort code */
-	enum {					/* current state of call */
-		RXRPC_CALL_CLIENT_SEND_REQUEST,	/* - client sending request phase */
-		RXRPC_CALL_CLIENT_AWAIT_REPLY,	/* - client awaiting reply */
-		RXRPC_CALL_CLIENT_RECV_REPLY,	/* - client receiving reply phase */
-		RXRPC_CALL_CLIENT_FINAL_ACK,	/* - client sending final ACK phase */
-		RXRPC_CALL_SERVER_SECURING,	/* - server securing request connection */
-		RXRPC_CALL_SERVER_ACCEPTING,	/* - server accepting request */
-		RXRPC_CALL_SERVER_RECV_REQUEST,	/* - server receiving request */
-		RXRPC_CALL_SERVER_ACK_REQUEST,	/* - server pending ACK of request */
-		RXRPC_CALL_SERVER_SEND_REPLY,	/* - server sending reply */
-		RXRPC_CALL_SERVER_AWAIT_ACK,	/* - server awaiting final ACK */
-		RXRPC_CALL_COMPLETE,		/* - call completed */
-		RXRPC_CALL_SERVER_BUSY,		/* - call rejected by busy server */
-		RXRPC_CALL_REMOTELY_ABORTED,	/* - call aborted by peer */
-		RXRPC_CALL_LOCALLY_ABORTED,	/* - call aborted locally on error or close */
-		RXRPC_CALL_NETWORK_ERROR,	/* - call terminated by network error */
-		RXRPC_CALL_DEAD,		/* - call is dead */
-	} state;
+	enum rxrpc_call_state	state : 8;	/* current state of call */
 	int			debug_id;	/* debug ID for printks */
 	u8			channel;	/* connection channel occupied by this call */
 
