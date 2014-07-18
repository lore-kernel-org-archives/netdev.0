From: David Laight <David.Laight@ACULAB.COM>
Subject: [PATCH net-next v3 3/3] Add support for MSG_MORE on SCTP
Date: Fri, 18 Jul 2014 17:36:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17278F4B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: 'David Miller' <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40052 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1030515AbaGRRhl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2014 13:37:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13783-06 for <netdev@vger.kernel.org>;
 Fri, 18 Jul 2014 18:37:31 +0100 (BST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If MSG_MORE is set then the data chunk will be buffered until either
a full packet would be generated, or something causes a chunk to be
sent (eg data without MSG_MORE or a heartbeat).

The MSG_MORE flag is saved 'per association' along with a copy
of the SCTP_NODELAY/Nagle flag.

It is expected that an application will only set MSG_MORE when it
has an additional data chunk ready to send. The sends could be done
with a single sendmmsg() system call.

Signed-off-by: David Laight <david.laight@aculab.com>
---

Changes from v2:
- MSG_MORE is now saved per association (not per socket)
- The first data chunk is also not sent

 include/net/sctp/structs.h |  9 ++++++++-
 net/sctp/endpointola.c     |  3 +++
 net/sctp/output.c          | 16 ++++++++++++----
 net/sctp/socket.c          | 24 +++++++++++++++++++++---
 4 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0dfcc92..441320a 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -209,7 +209,11 @@ struct sctp_sock {
 	struct sctp_assocparams assocparams;
 	int user_frag;
 	__u32 autoclose;
-	__u8 nodelay;
+
+#define	SCTP_F_TX_NODELAY	0
+#define	SCTP_F_TX_NAGLE		1	/* SCTP_NODELAY not set */
+#define	SCTP_F_TX_MSG_MORE	2	/* MSG_MORE set on last send */
+	__u8 tx_delay;
 	__u8 disable_fragments;
 	__u8 v4mapped;
 	__u8 frag_interleave;
@@ -1581,6 +1585,9 @@ struct sctp_association {
 	/* Flag that path mtu update is pending */
 	__u8   pmtu_pending;
 
+	/* SCTP_F_TX_xxx, Nagle copied from socket */
+	__u8 tx_delay;
+
 	/* Association : The smallest PMTU discovered for all of the
 	 * PMTU	       : peer's transport addresses.
 	 */
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 3d9f429..077220f 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -221,6 +221,9 @@ void sctp_endpoint_add_asoc(struct sctp_endpoint *ep,
 	/* Increment the backlog value for a TCP-style listening socket. */
 	if (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))
 		sk->sk_ack_backlog++;
+
+	/* Cache SCTP_NODELAY (aka Nagle) state */
+	asoc->tx_delay = sctp_sk(sk)->tx_delay;
 }
 
 /* Free the endpoint structure.  Delay cleanup until
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 7f28a8e..275a1ab 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -679,22 +679,30 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	    flight_size >= transport->cwnd)
 		return SCTP_XMIT_RWND_FULL;
 
+	/* If MSG_MORE is set we probably shouldn't create a new message.
+	 * However unless we also implement a timeout (preferable settable
+	 * as a socket option) then data could easily be left unsent.
+	 * Instead we ignore MSG_MORE on the first data chunk.
+	 * This makes the implementation of MSG_MORE the same as the
+	 * implementation of Nagle.
+	 */
+
 	/* Nagle's algorithm to solve small-packet problem:
 	 * Inhibit the sending of new chunks when new outgoing data arrives
 	 * if any previously transmitted data on the connection remains
 	 * unacknowledged.
 	 */
 
-	if (sctp_sk(asoc->base.sk)->nodelay)
-		/* Nagle disabled */
+	if (asoc->tx_delay == SCTP_F_TX_NODELAY)
+		/* Nagle disabled and MSG_MORE unset */
 		return SCTP_XMIT_OK;
 
 	if (!sctp_packet_empty(packet))
 		/* Append to packet */
 		return SCTP_XMIT_OK;
 
-	if (inflight == 0)
-		/* Nothing unacked */
+	if (inflight == 0 && !(asoc->tx_delay & SCTP_F_TX_MSG_MORE))
+		/* Nothing unacked and application isn't going to send more */
 		return SCTP_XMIT_OK;
 	
 	if (!sctp_state(asoc, ESTABLISHED))
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fee06b9..73a421d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1927,6 +1927,18 @@ static int sctp_sendmsg(struct kiocb *iocb, struct sock *sk,
 		pr_debug("%s: we associated primitively\n", __func__);
 	}
 
+	/* Setting MSG_MORE currently has the same effect as enabling Nagle.
+	 * This means that the user can't force bundling of the first two data
+	 * chunks.  It does mean that all the data chunks will be sent
+	 * without an extra timer.
+	 * It is enough to save the last value since any data sent with
+	 * MSG_MORE clear will already have been sent (subject to flow control).
+	 */
+	if (msg->msg_flags & MSG_MORE)
+		asoc->tx_delay |= SCTP_F_TX_MSG_MORE;
+	else
+		asoc->tx_delay &= ~SCTP_F_TX_MSG_MORE;
+
 	/* Break the message into multiple chunks of maximum size. */
 	datamsg = sctp_datamsg_from_user(asoc, sinfo, msg, msg_len);
 	if (IS_ERR(datamsg)) {
@@ -2814,6 +2826,7 @@ static int sctp_setsockopt_primary_addr(struct sock *sk, char __user *optval,
 static int sctp_setsockopt_nodelay(struct sock *sk, char __user *optval,
 				   unsigned int optlen)
 {
+	struct sctp_association *asoc;
 	int val;
 
 	if (optlen < sizeof(int))
@@ -2821,7 +2834,12 @@ static int sctp_setsockopt_nodelay(struct sock *sk, char __user *optval,
 	if (get_user(val, (int __user *)optval))
 		return -EFAULT;
 
-	sctp_sk(sk)->nodelay = (val == 0) ? 0 : 1;
+	val = val == 0 ? SCTP_F_TX_NAGLE : SCTP_F_TX_NODELAY;
+	sctp_sk(sk)->tx_delay = val;
+
+	/* Update cached value on each asoc (clears SCTP_F_TX_MSG_MORE) */
+	list_for_each_entry(asoc, &sctp_sk(sk)->ep->asocs, asocs)
+		asoc->tx_delay = val;
 	return 0;
 }
 
@@ -3968,7 +3986,7 @@ static int sctp_init_sock(struct sock *sk)
 	sp->disable_fragments = 0;
 
 	/* Enable Nagle algorithm by default.  */
-	sp->nodelay           = 0;
+	sp->tx_delay          = SCTP_F_TX_NAGLE;
 
 	/* Enable by default. */
 	sp->v4mapped          = 1;
@@ -5020,7 +5038,7 @@ static int sctp_getsockopt_nodelay(struct sock *sk, int len,
 		return -EINVAL;
 
 	len = sizeof(int);
-	val = (sctp_sk(sk)->nodelay == 1);
+	val = sctp_sk(sk)->tx_delay & SCTP_F_TX_NAGLE ? 0 : 1;
 	if (put_user(len, optlen))
 		return -EFAULT;
 	if (copy_to_user(optval, &val, len))
-- 
1.8.1.2
