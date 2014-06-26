From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 12/13] tipc: clean up connection protocol reception function
Date: Wed, 25 Jun 2014 20:41:41 -0500
Message-ID: <1403746902-20408-13-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24193 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757394AbaFZBtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:10 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We simplify the code for receiving connection probes, leveraging the
recently introduced tipc_msg_reverse() function. We also stick to
the principle of sending a possible response message directly from
the calling (tipc_sk_rcv or backlog_rcv) functions, hence making
the call chain shallower and easier to follow.

We make one small protocol change here, allowed according to
the spec. If a protocol message arrives from a remote socket that
is not the one we are connected to, we are currently generating a
connection abort message and send it to the source. This behavior
is unnecessary, and might even be a security risk, so instead we
now choose to only ignore the message. The consequnce for the sender
is that he will need longer time to discover his mistake (until the
next timeout), but this is an extreme corner case, and may happen
anyway under other circumstances, so we deem this change acceptable.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.c    |   10 ++++++---
 net/tipc/port.c   |   53 +++-----------------------------------------
 net/tipc/port.h   |    1 -
 net/tipc/socket.c |   64 +++++++++++++++++++++++++++++++++++++++++++++--------
 net/tipc/socket.h |    3 +++
 5 files changed, 68 insertions(+), 63 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 7bfc442..6ec9584 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -348,13 +348,17 @@ bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err)
 	struct tipc_msg ohdr;
 	uint rdsz = min_t(uint, msg_data_sz(msg), MAX_FORWARD_SIZE);
 
-	if (skb_linearize(buf) || !msg_isdata(msg))
+	if (skb_linearize(buf))
+		goto exit;
+	if (msg_dest_droppable(msg))
 		goto exit;
-	if (msg_dest_droppable(msg) || msg_errcode(msg))
+	if (msg_errcode(msg))
 		goto exit;
 
 	memcpy(&ohdr, msg, msg_hdr_sz(msg));
-	msg_set_importance(msg, min_t(uint, ++imp, TIPC_CRITICAL_IMPORTANCE));
+	imp = min_t(uint, imp + 1, TIPC_CRITICAL_IMPORTANCE);
+	if (msg_isdata(msg))
+		msg_set_importance(msg, imp);
 	msg_set_errcode(msg, err);
 	msg_set_origport(msg, msg_destport(&ohdr));
 	msg_set_destport(msg, msg_origport(&ohdr));
diff --git a/net/tipc/port.c b/net/tipc/port.c
index dcc6309..9f53d5a 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -42,8 +42,6 @@
 
 /* Connection management: */
 #define PROBING_INTERVAL 3600000	/* [ms] => 1 h */
-#define CONFIRMED 0
-#define PROBING 1
 
 #define MAX_REJECT_SIZE 1024
 
@@ -299,11 +297,11 @@ static void port_timeout(unsigned long ref)
 	}
 
 	/* Last probe answered ? */
-	if (p_ptr->probing_state == PROBING) {
+	if (p_ptr->probing_state == TIPC_CONN_PROBING) {
 		buf = port_build_self_abort_msg(p_ptr, TIPC_ERR_NO_PORT);
 	} else {
 		buf = port_build_proto_msg(p_ptr, CONN_PROBE, 0);
-		p_ptr->probing_state = PROBING;
+		p_ptr->probing_state = TIPC_CONN_PROBING;
 		k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 	}
 	tipc_port_unlock(p_ptr);
@@ -365,51 +363,6 @@ static struct sk_buff *port_build_peer_abort_msg(struct tipc_port *p_ptr, u32 er
 	return buf;
 }
 
-void tipc_port_proto_rcv(struct tipc_port *p_ptr, struct sk_buff *buf)
-{
-	struct tipc_msg *msg = buf_msg(buf);
-	struct sk_buff *r_buf = NULL;
-	u32 destport = msg_destport(msg);
-	int wakeable;
-
-	/* Validate connection */
-	if (!p_ptr || !p_ptr->connected || !tipc_port_peer_msg(p_ptr, msg)) {
-		r_buf = tipc_buf_acquire(BASIC_H_SIZE);
-		if (r_buf) {
-			msg = buf_msg(r_buf);
-			tipc_msg_init(msg, TIPC_HIGH_IMPORTANCE, TIPC_CONN_MSG,
-				      BASIC_H_SIZE, msg_orignode(msg));
-			msg_set_errcode(msg, TIPC_ERR_NO_PORT);
-			msg_set_origport(msg, destport);
-			msg_set_destport(msg, msg_origport(msg));
-		}
-		goto exit;
-	}
-
-	/* Process protocol message sent by peer */
-	switch (msg_type(msg)) {
-	case CONN_ACK:
-		wakeable = tipc_port_congested(p_ptr) && p_ptr->congested;
-		p_ptr->acked += msg_msgcnt(msg);
-		if (!tipc_port_congested(p_ptr)) {
-			p_ptr->congested = 0;
-			if (wakeable)
-				tipc_port_wakeup(p_ptr);
-		}
-		break;
-	case CONN_PROBE:
-		r_buf = port_build_proto_msg(p_ptr, CONN_PROBE_REPLY, 0);
-		break;
-	default:
-		/* CONN_PROBE_REPLY or unrecognized - no action required */
-		break;
-	}
-	p_ptr->probing_state = CONFIRMED;
-exit:
-	tipc_link_xmit2(r_buf, msg_destnode(msg), msg_link_selector(msg));
-	kfree_skb(buf);
-}
-
 static int port_print(struct tipc_port *p_ptr, char *buf, int len, int full_id)
 {
 	struct publication *publ;
@@ -613,7 +566,7 @@ int __tipc_port_connect(u32 ref, struct tipc_port *p_ptr,
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
 	p_ptr->probing_interval = PROBING_INTERVAL;
-	p_ptr->probing_state = CONFIRMED;
+	p_ptr->probing_state = TIPC_CONN_OK;
 	p_ptr->connected = 1;
 	k_start_timer(&p_ptr->timer, p_ptr->probing_interval);
 
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3f28fd4..3a4f808 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -140,7 +140,6 @@ int tipc_port_mcast_xmit(struct tipc_port *port,
 			 unsigned int len);
 
 struct sk_buff *tipc_port_get_ports(void);
-void tipc_port_proto_rcv(struct tipc_port *port, struct sk_buff *buf);
 void tipc_port_mcast_rcv(struct sk_buff *buf, struct tipc_port_list *dp);
 void tipc_port_reinit(void);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d838a4b..1762323 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -46,6 +46,7 @@
 #define SS_READY	-2	/* socket is connectionless */
 
 #define CONN_TIMEOUT_DEFAULT	8000	/* default connect timeout = 8s */
+#define TIPC_FWD_MSG	        1
 
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb);
 static void tipc_data_ready(struct sock *sk);
@@ -534,6 +535,46 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 }
 
 /**
+ * tipc_sk_proto_rcv - receive a connection mng protocol message
+ * @tsk: receiving socket
+ * @dnode: node to send response message to, if any
+ * @buf: buffer containing protocol message
+ * Returns 0 (TIPC_OK) if message was consumed, 1 (TIPC_FWD_MSG) if
+ * (CONN_PROBE_REPLY) message should be forwarded.
+ */
+int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode, struct sk_buff *buf)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	struct tipc_port *port = &tsk->port;
+	int wakeable;
+
+	/* Ignore if connection cannot be validated: */
+	if (!port->connected || !tipc_port_peer_msg(port, msg))
+		goto exit;
+
+	port->probing_state = TIPC_CONN_OK;
+
+	if (msg_type(msg) == CONN_ACK) {
+		wakeable = tipc_port_congested(port) && port->congested;
+		port->acked += msg_msgcnt(msg);
+		if (!tipc_port_congested(port)) {
+			port->congested = 0;
+			if (wakeable)
+				tipc_port_wakeup(port);
+		}
+	} else if (msg_type(msg) == CONN_PROBE) {
+		if (!tipc_msg_reverse(buf, dnode, TIPC_OK))
+			return TIPC_OK;
+		msg_set_type(msg, CONN_PROBE_REPLY);
+		return TIPC_FWD_MSG;
+	}
+	/* Do nothing if msg_type() == CONN_PROBE_REPLY */
+exit:
+	kfree_skb(buf);
+	return TIPC_OK;
+}
+
+/**
  * dest_name_check - verify user is permitted to send to specified port name
  * @dest: destination address
  * @m: descriptor for message to be sent
@@ -1406,7 +1447,7 @@ static unsigned int rcvbuf_limit(struct sock *sk, struct sk_buff *buf)
  * Called with socket lock already taken; port lock may also be taken.
  *
  * Returns 0 (TIPC_OK) if message was consumed, -TIPC error code if message
- * to be rejected.
+ * to be rejected, 1 (TIPC_FWD_MSG) if (CONN_MANAGER) message to be forwarded
  */
 static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 {
@@ -1414,12 +1455,11 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *msg = buf_msg(buf);
 	unsigned int limit = rcvbuf_limit(sk, buf);
+	u32 onode;
 	int rc = TIPC_OK;
 
-	if (unlikely(msg_user(msg) == CONN_MANAGER)) {
-		tipc_port_proto_rcv(&tsk->port, buf);
-		return TIPC_OK;
-	}
+	if (unlikely(msg_user(msg) == CONN_MANAGER))
+		return tipc_sk_proto_rcv(tsk, &onode, buf);
 
 	/* Reject message if it is wrong sort of message for socket */
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
@@ -1465,10 +1505,16 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 
 	rc = filter_rcv(sk, buf);
 
-	if (unlikely(rc && tipc_msg_reverse(buf, &onode, -rc)))
-		tipc_link_xmit2(buf, onode, 0);
-	else if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
-		atomic_add(truesize, &tsk->dupl_rcvcnt);
+	if (likely(!rc)) {
+		if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
+			atomic_add(truesize, &tsk->dupl_rcvcnt);
+		return 0;
+	}
+
+	if ((rc < 0) && !tipc_msg_reverse(buf, &onode, -rc))
+		return 0;
+
+	tipc_link_xmit2(buf, onode, 0);
 
 	return 0;
 }
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 3afcd2a..69fd06b 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -38,6 +38,9 @@
 #include "port.h"
 #include <net/sock.h>
 
+#define TIPC_CONN_OK      0
+#define TIPC_CONN_PROBING 1
+
 /**
  * struct tipc_sock - TIPC socket structure
  * @sk: socket - interacts with 'port' and with user via the socket API
-- 
1.7.9.5
