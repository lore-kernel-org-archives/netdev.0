From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 13/13] tipc: simplify connection congestion handling
Date: Wed, 25 Jun 2014 20:41:42 -0500
Message-ID: <1403746902-20408-14-git-send-email-jon.maloy@ericsson.com>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24200 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757480AbaFZBtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:49:12 -0400
In-Reply-To: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a consequence of the recently introduced serialized access
to the socket in commit 8d94168a761819d10252bab1f8de6d7b202c3baa
("tipc: same receive code path for connection protocol and data
messages") we can make a number of simplifications in the
detection and handling of connection congestion situations.

- We don't need to keep two counters, one for sent messages and one
  for acked messages. There is no longer any risk for races between
  acknowledge messages arriving in BH and data message sending
  running in user context. So we merge this into one counter,
  'sent_unacked', which is incremented at sending and subtracted
  from at acknowledge reception.

- We don't need to set the 'congested' field in tipc_port to
  true before we sent the message, and clear it when sending
  is successful. (As a matter of fact, it was never necessary;
  the field was set in link_schedule_port() before any wakeup
  could arrive anyway.)

- We keep the conditions for link congestion and connection connection
  congestion separated. There would otherwise be a risk that an arrivin=
g
  acknowledge message may wake up a user sleeping because of link
  congestion.

- We can simplify reception of acknowledge messages.

We also make some cosmetic/structural changes:

- We rename the 'congested' field to the more correct 'link_cong=C2=B4.

- We rename 'conn_unacked' to 'rcv_unacked'

- We move the above mentioned fields from struct tipc_port to
  struct tipc_sock.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c   |   10 +++++++---
 net/tipc/port.c   |   12 ++----------
 net/tipc/port.h   |   16 ----------------
 net/tipc/socket.c |   48 +++++++++++++++++++++++----------------------=
---
 net/tipc/socket.h |   11 +++++++++++
 5 files changed, 43 insertions(+), 54 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 96a8072..a081e7d 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -332,13 +332,15 @@ void tipc_link_delete_list(unsigned int bearer_id=
, bool shutting_down)
 static int link_schedule_port(struct tipc_link *l_ptr, u32 origport, u=
32 sz)
 {
 	struct tipc_port *p_ptr;
+	struct tipc_sock *tsk;
=20
 	spin_lock_bh(&tipc_port_list_lock);
 	p_ptr =3D tipc_port_lock(origport);
 	if (p_ptr) {
 		if (!list_empty(&p_ptr->wait_list))
 			goto exit;
-		p_ptr->congested =3D 1;
+		tsk =3D tipc_port_to_sock(p_ptr);
+		tsk->link_cong =3D 1;
 		p_ptr->waiting_pkts =3D 1 + ((sz - 1) / l_ptr->max_pkt);
 		list_add_tail(&p_ptr->wait_list, &l_ptr->waiting_ports);
 		l_ptr->stats.link_congs++;
@@ -352,6 +354,7 @@ exit:
 void tipc_link_wakeup_ports(struct tipc_link *l_ptr, int all)
 {
 	struct tipc_port *p_ptr;
+	struct tipc_sock *tsk;
 	struct tipc_port *temp_p_ptr;
 	int win =3D l_ptr->queue_limit[0] - l_ptr->out_queue_size;
=20
@@ -367,10 +370,11 @@ void tipc_link_wakeup_ports(struct tipc_link *l_p=
tr, int all)
 				 wait_list) {
 		if (win <=3D 0)
 			break;
+		tsk =3D tipc_port_to_sock(p_ptr);
 		list_del_init(&p_ptr->wait_list);
 		spin_lock_bh(p_ptr->lock);
-		p_ptr->congested =3D 0;
-		tipc_port_wakeup(p_ptr);
+		tsk->link_cong =3D 0;
+		tipc_sock_wakeup(tsk);
 		win -=3D p_ptr->waiting_pkts;
 		spin_unlock_bh(p_ptr->lock);
 	}
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 9f53d5a..0d09dcb 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -186,12 +186,6 @@ exit:
 	tipc_port_list_free(dp);
 }
=20
-
-void tipc_port_wakeup(struct tipc_port *port)
-{
-	tipc_sock_wakeup(tipc_port_to_sock(port));
-}
-
 /* tipc_port_init - intiate TIPC port and lock it
  *
  * Returns obtained reference if initialization is successful, zero ot=
herwise
@@ -209,7 +203,6 @@ u32 tipc_port_init(struct tipc_port *p_ptr,
 	}
=20
 	p_ptr->max_pkt =3D MAX_PKT_DEFAULT;
-	p_ptr->sent =3D 1;
 	p_ptr->ref =3D ref;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
@@ -459,10 +452,9 @@ void tipc_acknowledge(u32 ref, u32 ack)
 	p_ptr =3D tipc_port_lock(ref);
 	if (!p_ptr)
 		return;
-	if (p_ptr->connected) {
-		p_ptr->conn_unacked -=3D ack;
+	if (p_ptr->connected)
 		buf =3D port_build_proto_msg(p_ptr, CONN_ACK, ack);
-	}
+
 	tipc_port_unlock(p_ptr);
 	if (!buf)
 		return;
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 3a4f808..0e47052 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -53,17 +53,13 @@
  * @connected: non-zero if port is currently connected to a peer port
  * @conn_type: TIPC type used when connection was established
  * @conn_instance: TIPC instance used when connection was established
- * @conn_unacked: number of unacknowledged messages received from peer=
 port
  * @published: non-zero if port has one or more associated names
- * @congested: non-zero if cannot send because of link or port congest=
ion
  * @max_pkt: maximum packet size "hint" used when building messages se=
nt by port
  * @ref: unique reference to port in TIPC object registry
  * @phdr: preformatted message header used when sending messages
  * @port_list: adjacent ports in TIPC's global list of ports
  * @wait_list: adjacent ports in list of ports waiting on link congest=
ion
  * @waiting_pkts:
- * @sent: # of non-empty messages sent by port
- * @acked: # of non-empty message acknowledgements from connected port=
's peer
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifeti=
me
  * @probing_state:
@@ -76,17 +72,13 @@ struct tipc_port {
 	int connected;
 	u32 conn_type;
 	u32 conn_instance;
-	u32 conn_unacked;
 	int published;
-	u32 congested;
 	u32 max_pkt;
 	u32 ref;
 	struct tipc_msg phdr;
 	struct list_head port_list;
 	struct list_head wait_list;
 	u32 waiting_pkts;
-	u32 sent;
-	u32 acked;
 	struct list_head publications;
 	u32 pub_count;
 	u32 probing_state;
@@ -120,8 +112,6 @@ int tipc_port_disconnect(u32 portref);
=20
 int tipc_port_shutdown(u32 ref);
=20
-void tipc_port_wakeup(struct tipc_port *port);
-
 /*
  * The following routines require that the port be locked on entry
  */
@@ -161,12 +151,6 @@ static inline void tipc_port_unlock(struct tipc_po=
rt *p_ptr)
 	spin_unlock_bh(p_ptr->lock);
 }
=20
-static inline int tipc_port_congested(struct tipc_port *p_ptr)
-{
-	return ((p_ptr->sent - p_ptr->acked) >=3D TIPC_FLOWCTRL_WIN);
-}
-
-
 static inline u32 tipc_port_peernode(struct tipc_port *p_ptr)
 {
 	return msg_destnode(&p_ptr->phdr);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1762323..ede78b1 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -207,7 +207,7 @@ static int tipc_sk_create(struct net *net, struct s=
ocket *sock,
 	sk->sk_data_ready =3D tipc_data_ready;
 	sk->sk_write_space =3D tipc_write_space;
 	tsk->conn_timeout =3D CONN_TIMEOUT_DEFAULT;
-	tsk->port.sent =3D 0;
+	tsk->sent_unacked =3D 0;
 	atomic_set(&tsk->dupl_rcvcnt, 0);
 	tipc_port_unlock(port);
=20
@@ -513,12 +513,12 @@ static unsigned int tipc_poll(struct file *file, =
struct socket *sock,
=20
 	switch ((int)sock->state) {
 	case SS_UNCONNECTED:
-		if (!tsk->port.congested)
+		if (!tsk->link_cong)
 			mask |=3D POLLOUT;
 		break;
 	case SS_READY:
 	case SS_CONNECTED:
-		if (!tsk->port.congested)
+		if (!tsk->link_cong && !tipc_sk_conn_cong(tsk))
 			mask |=3D POLLOUT;
 		/* fall thru' */
 	case SS_CONNECTING:
@@ -546,7 +546,7 @@ int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *d=
node, struct sk_buff *buf)
 {
 	struct tipc_msg *msg =3D buf_msg(buf);
 	struct tipc_port *port =3D &tsk->port;
-	int wakeable;
+	int conn_cong;
=20
 	/* Ignore if connection cannot be validated: */
 	if (!port->connected || !tipc_port_peer_msg(port, msg))
@@ -555,13 +555,10 @@ int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 =
*dnode, struct sk_buff *buf)
 	port->probing_state =3D TIPC_CONN_OK;
=20
 	if (msg_type(msg) =3D=3D CONN_ACK) {
-		wakeable =3D tipc_port_congested(port) && port->congested;
-		port->acked +=3D msg_msgcnt(msg);
-		if (!tipc_port_congested(port)) {
-			port->congested =3D 0;
-			if (wakeable)
-				tipc_port_wakeup(port);
-		}
+		conn_cong =3D tipc_sk_conn_cong(tsk);
+		tsk->sent_unacked -=3D msg_msgcnt(msg);
+		if (conn_cong)
+			tipc_sock_wakeup(tsk);
 	} else if (msg_type(msg) =3D=3D CONN_PROBE) {
 		if (!tipc_msg_reverse(buf, dnode, TIPC_OK))
 			return TIPC_OK;
@@ -626,7 +623,7 @@ static int tipc_wait_for_sndmsg(struct socket *sock=
, long *timeo_p)
 			return sock_intr_errno(*timeo_p);
=20
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
-		done =3D sk_wait_event(sk, timeo_p, !tsk->port.congested);
+		done =3D sk_wait_event(sk, timeo_p, !tsk->link_cong);
 		finish_wait(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
@@ -800,7 +797,6 @@ static int tipc_wait_for_sndpkt(struct socket *sock=
, long *timeo_p)
 {
 	struct sock *sk =3D sock->sk;
 	struct tipc_sock *tsk =3D tipc_sk(sk);
-	struct tipc_port *port =3D &tsk->port;
 	DEFINE_WAIT(wait);
 	int done;
=20
@@ -819,7 +815,9 @@ static int tipc_wait_for_sndpkt(struct socket *sock=
, long *timeo_p)
=20
 		prepare_to_wait(sk_sleep(sk), &wait, TASK_INTERRUPTIBLE);
 		done =3D sk_wait_event(sk, timeo_p,
-				     (!port->congested || !port->connected));
+				     (!tsk->link_cong &&
+				      !tipc_sk_conn_cong(tsk)) ||
+				     !tsk->port.connected);
 		finish_wait(sk_sleep(sk), &wait);
 	} while (!done);
 	return 0;
@@ -856,7 +854,7 @@ static int tipc_send_stream(struct kiocb *iocb, str=
uct socket *sock,
 	if (unlikely(dest)) {
 		rc =3D tipc_sendmsg(iocb, sock, m, dsz);
 		if (dsz && (dsz =3D=3D rc))
-			tsk->port.sent =3D 1;
+			tsk->sent_unacked =3D 1;
 		return rc;
 	}
 	if (dsz > (uint)INT_MAX)
@@ -875,7 +873,6 @@ static int tipc_send_stream(struct kiocb *iocb, str=
uct socket *sock,
=20
 	timeo =3D sock_sndtimeo(sk, m->msg_flags & MSG_DONTWAIT);
 	dnode =3D tipc_port_peernode(port);
-	port->congested =3D 1;
=20
 next:
 	mtu =3D port->max_pkt;
@@ -884,11 +881,10 @@ next:
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
-		port->congested =3D 1;
-		if (likely(!tipc_port_congested(port))) {
+		if (likely(!tipc_sk_conn_cong(tsk))) {
 			rc =3D tipc_link_xmit2(buf, dnode, ref);
 			if (likely(!rc)) {
-				port->sent++;
+				tsk->sent_unacked++;
 				sent +=3D send;
 				if (sent =3D=3D dsz)
 					break;
@@ -903,8 +899,6 @@ next:
 		}
 		rc =3D tipc_wait_for_sndpkt(sock, &timeo);
 	} while (!rc);
-
-	port->congested =3D 0;
 exit:
 	if (iocb)
 		release_sock(sk);
@@ -1169,8 +1163,10 @@ restart:
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
 		if ((sock->state !=3D SS_READY) &&
-		    (++port->conn_unacked >=3D TIPC_CONNACK_INTV))
-			tipc_acknowledge(port->ref, port->conn_unacked);
+		    (++tsk->rcv_unacked >=3D TIPC_CONNACK_INTV)) {
+			tipc_acknowledge(port->ref, tsk->rcv_unacked);
+			tsk->rcv_unacked =3D 0;
+		}
 		advance_rx_queue(sk);
 	}
 exit:
@@ -1278,8 +1274,10 @@ restart:
=20
 	/* Consume received message (optional) */
 	if (likely(!(flags & MSG_PEEK))) {
-		if (unlikely(++port->conn_unacked >=3D TIPC_CONNACK_INTV))
-			tipc_acknowledge(port->ref, port->conn_unacked);
+		if (unlikely(++tsk->rcv_unacked >=3D TIPC_CONNACK_INTV)) {
+			tipc_acknowledge(port->ref, tsk->rcv_unacked);
+			tsk->rcv_unacked =3D 0;
+		}
 		advance_rx_queue(sk);
 	}
=20
diff --git a/net/tipc/socket.h b/net/tipc/socket.h
index 69fd06b..2cdede9 100644
--- a/net/tipc/socket.h
+++ b/net/tipc/socket.h
@@ -48,6 +48,9 @@
  * @peer_name: the peer of the connection, if any
  * @conn_timeout: the time we can wait for an unresponded setup reques=
t
  * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rc=
v queue
+ * @link_cong: non-zero if owner must sleep because of link congestion
+ * @sent_unacked: # messages sent by socket, and not yet acked by peer
+ * @rcv_unacked: # messages read by user, but not yet acked back to pe=
er
  */
=20
 struct tipc_sock {
@@ -55,6 +58,9 @@ struct tipc_sock {
 	struct tipc_port port;
 	unsigned int conn_timeout;
 	atomic_t dupl_rcvcnt;
+	int link_cong;
+	uint sent_unacked;
+	uint rcv_unacked;
 };
=20
 static inline struct tipc_sock *tipc_sk(const struct sock *sk)
@@ -72,6 +78,11 @@ static inline void tipc_sock_wakeup(struct tipc_sock=
 *tsk)
 	tsk->sk.sk_write_space(&tsk->sk);
 }
=20
+static inline int tipc_sk_conn_cong(struct tipc_sock *tsk)
+{
+	return tsk->sent_unacked >=3D TIPC_FLOWCTRL_WIN;
+}
+
 int tipc_sk_rcv(struct sk_buff *buf);
=20
 #endif
--=20
1.7.9.5
