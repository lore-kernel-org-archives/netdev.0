From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 2/3] rxrpc: Consolidate sendmsg parameters
Date: Wed, 07 Jun 2017 17:26:55 +0100
Message-ID: <149685281542.8474.229261830977659845.stgit@warthog.procyon.org.uk>
References: <149685280179.8474.3836343127280242150.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149685280179.8474.3836343127280242150.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Consolidate the sendmsg control message parameters into a struct rather
than passing them individually through the argument list of
rxrpc_sendmsg_cmsg().  This makes it easier to add more parameters.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |   83 +++++++++++++++++++++++++--------------------------
 1 file changed, 41 insertions(+), 42 deletions(-)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 5a4801e7f560..d939a5b1abc3 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -28,6 +28,14 @@ enum rxrpc_command {
 	RXRPC_CMD_REJECT_BUSY,		/* [server] reject a call as busy */
 };
 
+struct rxrpc_send_params {
+	unsigned long		user_call_ID;	/* User's call ID */
+	u32			abort_code;	/* Abort code to Tx (if abort) */
+	enum rxrpc_command	command : 8;	/* The command to implement */
+	bool			exclusive;	/* Shared or exclusive call */
+	bool			upgrade;	/* If the connection is upgradeable */
+};
+
 /*
  * wait for space to appear in the transmit/ACK window
  * - caller holds the socket locked
@@ -362,19 +370,12 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 /*
  * extract control messages from the sendmsg() control buffer
  */
-static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
-			      unsigned long *user_call_ID,
-			      enum rxrpc_command *command,
-			      u32 *abort_code,
-			      bool *_exclusive,
-			      bool *_upgrade)
+static int rxrpc_sendmsg_cmsg(struct msghdr *msg, struct rxrpc_send_params *p)
 {
 	struct cmsghdr *cmsg;
 	bool got_user_ID = false;
 	int len;
 
-	*command = RXRPC_CMD_SEND_DATA;
-
 	if (msg->msg_controllen == 0)
 		return -EINVAL;
 
@@ -394,45 +395,43 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
 			if (msg->msg_flags & MSG_CMSG_COMPAT) {
 				if (len != sizeof(u32))
 					return -EINVAL;
-				*user_call_ID = *(u32 *) CMSG_DATA(cmsg);
+				p->user_call_ID = *(u32 *)CMSG_DATA(cmsg);
 			} else {
 				if (len != sizeof(unsigned long))
 					return -EINVAL;
-				*user_call_ID = *(unsigned long *)
+				p->user_call_ID = *(unsigned long *)
 					CMSG_DATA(cmsg);
 			}
-			_debug("User Call ID %lx", *user_call_ID);
 			got_user_ID = true;
 			break;
 
 		case RXRPC_ABORT:
-			if (*command != RXRPC_CMD_SEND_DATA)
+			if (p->command != RXRPC_CMD_SEND_DATA)
 				return -EINVAL;
-			*command = RXRPC_CMD_SEND_ABORT;
-			if (len != sizeof(*abort_code))
+			p->command = RXRPC_CMD_SEND_ABORT;
+			if (len != sizeof(p->abort_code))
 				return -EINVAL;
-			*abort_code = *(unsigned int *) CMSG_DATA(cmsg);
-			_debug("Abort %x", *abort_code);
-			if (*abort_code == 0)
+			p->abort_code = *(unsigned int *)CMSG_DATA(cmsg);
+			if (p->abort_code == 0)
 				return -EINVAL;
 			break;
 
 		case RXRPC_ACCEPT:
-			if (*command != RXRPC_CMD_SEND_DATA)
+			if (p->command != RXRPC_CMD_SEND_DATA)
 				return -EINVAL;
-			*command = RXRPC_CMD_ACCEPT;
+			p->command = RXRPC_CMD_ACCEPT;
 			if (len != 0)
 				return -EINVAL;
 			break;
 
 		case RXRPC_EXCLUSIVE_CALL:
-			*_exclusive = true;
+			p->exclusive = true;
 			if (len != 0)
 				return -EINVAL;
 			break;
 
 		case RXRPC_UPGRADE_SERVICE:
-			*_upgrade = true;
+			p->upgrade = true;
 			if (len != 0)
 				return -EINVAL;
 			break;
@@ -455,8 +454,7 @@ static int rxrpc_sendmsg_cmsg(struct msghdr *msg,
  */
 static struct rxrpc_call *
 rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
-				  unsigned long user_call_ID, bool exclusive,
-				  bool upgrade)
+				  struct rxrpc_send_params *p)
 	__releases(&rx->sk.sk_lock.slock)
 {
 	struct rxrpc_conn_parameters cp;
@@ -480,10 +478,10 @@ rxrpc_new_client_call_for_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	cp.local		= rx->local;
 	cp.key			= rx->key;
 	cp.security_level	= rx->min_sec_level;
-	cp.exclusive		= rx->exclusive | exclusive;
-	cp.upgrade		= upgrade;
+	cp.exclusive		= rx->exclusive | p->exclusive;
+	cp.upgrade		= p->upgrade;
 	cp.service_id		= srx->srx_service;
-	call = rxrpc_new_client_call(rx, &cp, srx, user_call_ID, GFP_KERNEL);
+	call = rxrpc_new_client_call(rx, &cp, srx, p->user_call_ID, GFP_KERNEL);
 	/* The socket is now unlocked */
 
 	_leave(" = %p\n", call);
@@ -499,26 +497,28 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	__releases(&rx->sk.sk_lock.slock)
 {
 	enum rxrpc_call_state state;
-	enum rxrpc_command cmd;
 	struct rxrpc_call *call;
-	unsigned long user_call_ID = 0;
-	bool exclusive = false;
-	bool upgrade = true;
-	u32 abort_code = 0;
 	int ret;
 
+	struct rxrpc_send_params p = {
+		.user_call_ID	= 0,
+		.abort_code	= 0,
+		.command	= RXRPC_CMD_SEND_DATA,
+		.exclusive	= false,
+		.upgrade	= true,
+	};
+
 	_enter("");
 
-	ret = rxrpc_sendmsg_cmsg(msg, &user_call_ID, &cmd, &abort_code,
-				 &exclusive, &upgrade);
+	ret = rxrpc_sendmsg_cmsg(msg, &p);
 	if (ret < 0)
 		goto error_release_sock;
 
-	if (cmd == RXRPC_CMD_ACCEPT) {
+	if (p.command == RXRPC_CMD_ACCEPT) {
 		ret = -EINVAL;
 		if (rx->sk.sk_state != RXRPC_SERVER_LISTENING)
 			goto error_release_sock;
-		call = rxrpc_accept_call(rx, user_call_ID, NULL);
+		call = rxrpc_accept_call(rx, p.user_call_ID, NULL);
 		/* The socket is now unlocked. */
 		if (IS_ERR(call))
 			return PTR_ERR(call);
@@ -526,13 +526,12 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		return 0;
 	}
 
-	call = rxrpc_find_call_by_user_ID(rx, user_call_ID);
+	call = rxrpc_find_call_by_user_ID(rx, p.user_call_ID);
 	if (!call) {
 		ret = -EBADSLT;
-		if (cmd != RXRPC_CMD_SEND_DATA)
+		if (p.command != RXRPC_CMD_SEND_DATA)
 			goto error_release_sock;
-		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
-							 exclusive, upgrade);
+		call = rxrpc_new_client_call_for_sendmsg(rx, msg, &p);
 		/* The socket is now unlocked... */
 		if (IS_ERR(call))
 			return PTR_ERR(call);
@@ -565,11 +564,11 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 	if (state >= RXRPC_CALL_COMPLETE) {
 		/* it's too late for this call */
 		ret = -ESHUTDOWN;
-	} else if (cmd == RXRPC_CMD_SEND_ABORT) {
+	} else if (p.command == RXRPC_CMD_SEND_ABORT) {
 		ret = 0;
-		if (rxrpc_abort_call("CMD", call, 0, abort_code, -ECONNABORTED))
+		if (rxrpc_abort_call("CMD", call, 0, p.abort_code, -ECONNABORTED))
 			ret = rxrpc_send_abort_packet(call);
-	} else if (cmd != RXRPC_CMD_SEND_DATA) {
+	} else if (p.command != RXRPC_CMD_SEND_DATA) {
 		ret = -EINVAL;
 	} else if (rxrpc_is_client_call(call) &&
 		   state != RXRPC_CALL_CLIENT_SEND_REQUEST) {
