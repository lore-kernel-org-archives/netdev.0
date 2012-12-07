From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/10] tipc: consolidate connection-oriented message reception in one function
Date: Fri, 7 Dec 2012 09:28:14 -0500
Message-ID: <1354890498-6448-7-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62571 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030760Ab2LGO2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:37 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ying Xue <ying.xue@windriver.com>

Handling of connection-related message reception is currently scattered
around at different places in the code. This makes it harder to verify
that things are handled correctly in all possible scenarios.
So we consolidate the existing processing of connection-oriented
message reception in a single routine.  In the process, we convert the
chain of if/else into a switch/case for improved readability.

A cast on the socket_state in the switch is needed to avoid compile
warnings on 32 bit, like "net/tipc/socket.c:1252:2: warning: case value
=E2=80=984294967295=E2=80=99 not in enumerated type".  This happens bec=
ause existing
tipc code pseudo extends the default linux socket state values with:

	#define SS_LISTENING    -1      /* socket is listening */
	#define SS_READY        -2      /* socket is connectionless */

It may make sense to add these as _positive_ values to the existing
socket state enum list someday, vs. these already existing defines.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
[PG: add cast to fix warning; remove returns from middle of switch]
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c | 75 +++++++++++++++++++++++++++++++++++++----------=
--------
 1 file changed, 51 insertions(+), 24 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4d56eae..fc0aa4f 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1192,6 +1192,53 @@ static int rx_queue_full(struct tipc_msg *msg, u=
32 queue_size, u32 base)
 }
=20
 /**
+ * filter_connect - Handle all incoming messages for a connection-base=
d socket
+ * @tsock: TIPC socket
+ * @msg: message
+ *
+ * Returns TIPC error status code and socket error status code
+ * once it encounters some errors
+ */
+static u32 filter_connect(struct tipc_sock *tsock, struct sk_buff **bu=
f)
+{
+	struct socket *sock =3D tsock->sk.sk_socket;
+	struct tipc_msg *msg =3D buf_msg(*buf);
+	u32 retval =3D TIPC_ERR_NO_PORT;
+
+	if (msg_mcast(msg))
+		return retval;
+
+	switch ((int)sock->state) {
+	case SS_CONNECTED:
+		/* Accept only connection-based messages sent by peer */
+		if (msg_connected(msg) && tipc_port_peer_msg(tsock->p, msg)) {
+			if (unlikely(msg_errcode(msg))) {
+				sock->state =3D SS_DISCONNECTING;
+				__tipc_disconnect(tsock->p);
+			}
+			retval =3D TIPC_OK;
+		}
+		break;
+	case SS_CONNECTING:
+		/* Accept only ACK or NACK message */
+		if (msg_connected(msg) || (msg_errcode(msg)))
+			retval =3D TIPC_OK;
+		break;
+	case SS_LISTENING:
+	case SS_UNCONNECTED:
+		/* Accept only SYN message */
+		if (!msg_connected(msg) && !(msg_errcode(msg)))
+			retval =3D TIPC_OK;
+		break;
+	case SS_DISCONNECTING:
+		break;
+	default:
+		pr_err("Unknown socket state %u\n", sock->state);
+	}
+	return retval;
+}
+
+/**
  * filter_rcv - validate incoming message
  * @sk: socket
  * @buf: message
@@ -1208,6 +1255,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_=
buff *buf)
 	struct socket *sock =3D sk->sk_socket;
 	struct tipc_msg *msg =3D buf_msg(buf);
 	u32 recv_q_len;
+	u32 res =3D TIPC_OK;
=20
 	/* Reject message if it is wrong sort of message for socket */
 	if (msg_type(msg) > TIPC_DIRECT_MSG)
@@ -1226,24 +1274,9 @@ static u32 filter_rcv(struct sock *sk, struct sk=
_buff *buf)
 				return TIPC_ERR_OVERLOAD;
 		}
 	} else {
-		if (msg_mcast(msg))
-			return TIPC_ERR_NO_PORT;
-		if (sock->state =3D=3D SS_CONNECTED) {
-			if (!msg_connected(msg) ||
-			    !tipc_port_peer_msg(tipc_sk_port(sk), msg))
-				return TIPC_ERR_NO_PORT;
-		} else if (sock->state =3D=3D SS_CONNECTING) {
-			if (!msg_connected(msg) && (msg_errcode(msg) =3D=3D 0))
-				return TIPC_ERR_NO_PORT;
-		} else if (sock->state =3D=3D SS_LISTENING) {
-			if (msg_connected(msg) || msg_errcode(msg))
-				return TIPC_ERR_NO_PORT;
-		} else if (sock->state =3D=3D SS_DISCONNECTING) {
-			return TIPC_ERR_NO_PORT;
-		} else /* (sock->state =3D=3D SS_UNCONNECTED) */ {
-			if (msg_connected(msg) || msg_errcode(msg))
-				return TIPC_ERR_NO_PORT;
-		}
+		res =3D filter_connect(tipc_sk(sk), &buf);
+		if (res !=3D TIPC_OK || buf =3D=3D NULL)
+			return res;
 	}
=20
 	/* Enqueue message (finally!) */
@@ -1251,12 +1284,6 @@ static u32 filter_rcv(struct sock *sk, struct sk=
_buff *buf)
 	atomic_inc(&tipc_queue_size);
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
=20
-	/* Initiate connection termination for an incoming 'FIN' */
-	if (unlikely(msg_errcode(msg) && (sock->state =3D=3D SS_CONNECTED))) =
{
-		sock->state =3D SS_DISCONNECTING;
-		__tipc_disconnect(tipc_sk_port(sk));
-	}
-
 	sk->sk_data_ready(sk, 0);
 	return TIPC_OK;
 }
--=20
1.7.12.1
