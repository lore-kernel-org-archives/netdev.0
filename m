From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 06/13] tipc: separate building and sending of rejected messages
Date: Wed, 25 Jun 2014 20:41:35 -0500
Message-ID: <1403746902-20408-7-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24154 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756874AbaFZBs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:58 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The way we build and send rejected message is currenty perceived as
hard to follow, partly because we let the transmission go via deep
call chains through functions such as tipc_reject_msg() and
net_route_msg().

We want to remove those functions, and make the call sequences shallower
and simpler. For this purpose, we separate building and sending of
rejected messages. We build the reject message using the new function
tipc_msg_reverse(), and let the transmission go via the newly introduced
tipc_link_xmit2() function, as all transmission eventually will do. We
also ensure that all calls to tipc_link_xmit2() are made outside
port_lock/bh_lock_sock.

Finally, we replace all calls to tipc_reject_msg() with the two new
calls at all locations in the code that we want to keep. The remaining
calls are made from code that we are planning to remove, along with
tipc_reject_msg() itself.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/msg.c    |   42 ++++++++++++++++++++++++++++++++++++++++++
 net/tipc/msg.h    |    2 ++
 net/tipc/socket.c |   28 ++++++++++++++++++++--------
 3 files changed, 64 insertions(+), 8 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 4093b4c..6070dd0 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -37,6 +37,8 @@
 #include "core.h"
 #include "msg.h"
 
+#define MAX_FORWARD_SIZE 1024
+
 static unsigned int align(unsigned int i)
 {
 	return (i + 3) & ~3u;
@@ -328,3 +330,43 @@ bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode)
 	*buf = bbuf;
 	return true;
 }
+
+/**
+ * tipc_msg_reverse(): swap source and destination addresses and add error code
+ * @buf:  buffer containing message to be reversed
+ * @dnode: return value: node where to send message after reversal
+ * @err:  error code to be set in message
+ * Consumes buffer if failure
+ * Returns true if success, otherwise false
+ */
+bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err)
+{
+	struct tipc_msg *msg = buf_msg(buf);
+	uint imp = msg_importance(msg);
+	struct tipc_msg ohdr;
+	uint rdsz = min_t(uint, msg_data_sz(msg), MAX_FORWARD_SIZE);
+
+	if (skb_linearize(buf) || !msg_isdata(msg))
+		goto exit;
+	if (msg_dest_droppable(msg) || msg_errcode(msg))
+		goto exit;
+
+	memcpy(&ohdr, msg, msg_hdr_sz(msg));
+	msg_set_importance(msg, min_t(uint, ++imp, TIPC_CRITICAL_IMPORTANCE));
+	msg_set_errcode(msg, err);
+	msg_set_origport(msg, msg_destport(&ohdr));
+	msg_set_destport(msg, msg_origport(&ohdr));
+	msg_set_prevnode(msg, tipc_own_addr);
+	if (!msg_short(msg)) {
+		msg_set_orignode(msg, msg_destnode(&ohdr));
+		msg_set_destnode(msg, msg_orignode(&ohdr));
+	}
+	msg_set_size(msg, msg_hdr_sz(msg) + rdsz);
+	skb_trim(buf, msg_size(msg));
+	skb_orphan(buf);
+	*dnode = msg_orignode(&ohdr);
+	return true;
+exit:
+	kfree_skb(buf);
+	return false;
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5e1339d..3805094 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -725,6 +725,8 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 	return msg_origport(m);
 }
 
+bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err);
+
 void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
 		   u32 destnode);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 9a95dab..5961a63 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -39,6 +39,7 @@
 #include "node.h"
 
 #include <linux/export.h>
+#include "link.h"
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
@@ -123,9 +124,12 @@ static void advance_rx_queue(struct sock *sk)
 static void reject_rx_queue(struct sock *sk)
 {
 	struct sk_buff *buf;
+	u32 dnode;
 
-	while ((buf = __skb_dequeue(&sk->sk_receive_queue)))
-		tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
+	while ((buf = __skb_dequeue(&sk->sk_receive_queue))) {
+		if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
+			tipc_link_xmit2(buf, dnode, 0);
+	}
 }
 
 /**
@@ -303,6 +307,7 @@ static int tipc_release(struct socket *sock)
 	struct tipc_sock *tsk;
 	struct tipc_port *port;
 	struct sk_buff *buf;
+	u32 dnode;
 
 	/*
 	 * Exit if socket isn't fully initialized (occurs when a failed accept()
@@ -331,7 +336,8 @@ static int tipc_release(struct socket *sock)
 				sock->state = SS_DISCONNECTING;
 				tipc_port_disconnect(port->ref);
 			}
-			tipc_reject_msg(buf, TIPC_ERR_NO_PORT);
+			if (tipc_msg_reverse(buf, &dnode, TIPC_ERR_NO_PORT))
+				tipc_link_xmit2(buf, dnode, 0);
 		}
 	}
 
@@ -1430,14 +1436,15 @@ static int filter_rcv(struct sock *sk, struct sk_buff *buf)
 static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *buf)
 {
 	int rc;
+	u32 onode;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	uint truesize = buf->truesize;
 
 	rc = filter_rcv(sk, buf);
-	if (unlikely(rc))
-		tipc_reject_msg(buf, -rc);
 
-	if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
+	if (unlikely(rc && tipc_msg_reverse(buf, &onode, -rc)))
+		tipc_link_xmit2(buf, onode, 0);
+	else if (atomic_read(&tsk->dupl_rcvcnt) < TIPC_CONN_OVERLOAD_LIMIT)
 		atomic_add(truesize, &tsk->dupl_rcvcnt);
 
 	return 0;
@@ -1457,6 +1464,7 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	u32 dport = msg_destport(buf_msg(buf));
 	int rc = TIPC_OK;
 	uint limit;
+	u32 dnode;
 
 	/* Forward unresolved named message */
 	if (unlikely(!dport)) {
@@ -1493,7 +1501,9 @@ int tipc_sk_rcv(struct sk_buff *buf)
 	if (likely(!rc))
 		return 0;
 exit:
-	tipc_reject_msg(buf, -rc);
+	if (!tipc_msg_reverse(buf, &dnode, -rc))
+		return -EHOSTUNREACH;
+	tipc_link_xmit2(buf, dnode, 0);
 	return -EHOSTUNREACH;
 }
 
@@ -1758,6 +1768,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_port *port = &tsk->port;
 	struct sk_buff *buf;
+	u32 peer;
 	int res;
 
 	if (how != SHUT_RDWR)
@@ -1778,7 +1789,8 @@ restart:
 				goto restart;
 			}
 			tipc_port_disconnect(port->ref);
-			tipc_reject_msg(buf, TIPC_CONN_SHUTDOWN);
+			if (tipc_msg_reverse(buf, &peer, TIPC_CONN_SHUTDOWN))
+				tipc_link_xmit2(buf, peer, 0);
 		} else {
 			tipc_port_shutdown(port->ref);
 		}
-- 
1.7.9.5
