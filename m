From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 3/3] [TCP]: Perform setting of common control fields in one place
Date: Thu,  3 Jan 2008 13:00:07 +0200
Message-ID: <11993580071094-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11993580071900-git-send-email-ilpo.jarvinen@helsinki.fi> <11993580071646-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54022 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbYACLAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 06:00:10 -0500
In-Reply-To: <11993580071646-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of segments which are purely for control without any
data (SYN/ACK/FIN/RST), many fields are set to common values
in multiple places.

i386 results:

$ gcc --version
gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13)

$ codiff tcp_output.o.old tcp_output.o.new
net/ipv4/tcp_output.c:
  tcp_xmit_probe_skb    |  -48
  tcp_send_ack          |  -56
  tcp_retransmit_skb    |  -79
  tcp_connect           |  -43
  tcp_send_active_reset |  -35
  tcp_make_synack       |  -42
  tcp_send_fin          |  -48
 7 functions changed, 351 bytes removed

net/ipv4/tcp_output.c:
  tcp_init_nondata_skb |  +90
 1 function changed, 90 bytes added

tcp_output.o.mid:
 8 functions changed, 90 bytes added, 351 bytes removed, diff: -261

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   91 +++++++++++++++++++----------------------=
-------
 1 files changed, 36 insertions(+), 55 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 6c7cd0a..89f0188 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -327,6 +327,26 @@ static inline void TCP_ECN_send(struct sock *sk, s=
truct sk_buff *skb,
 	}
 }
=20
+/* Constructs common control bits of non-data skb. If SYN/FIN is prese=
nt,
+ * auto increment end seqno.
+ */
+static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flag=
s)
+{
+	skb->csum =3D 0;
+
+	TCP_SKB_CB(skb)->flags =3D flags;
+	TCP_SKB_CB(skb)->sacked =3D 0;
+
+	skb_shinfo(skb)->gso_segs =3D 1;
+	skb_shinfo(skb)->gso_size =3D 0;
+	skb_shinfo(skb)->gso_type =3D 0;
+
+	TCP_SKB_CB(skb)->seq =3D seq;
+	if (flags & (TCPCB_FLAG_SYN | TCPCB_FLAG_FIN))
+		seq++;
+	TCP_SKB_CB(skb)->end_seq =3D seq;
+}
+
 static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock =
*tp,
 					 __u32 tstamp, __u8 **md5_hash)
 {
@@ -1864,12 +1884,10 @@ int tcp_retransmit_skb(struct sock *sk, struct =
sk_buff *skb)
 	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
 	    tp->snd_una =3D=3D (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
-			TCP_SKB_CB(skb)->seq =3D TCP_SKB_CB(skb)->end_seq - 1;
-			skb_shinfo(skb)->gso_segs =3D 1;
-			skb_shinfo(skb)->gso_size =3D 0;
-			skb_shinfo(skb)->gso_type =3D 0;
+			/* Reuse, even though it does some unnecessary work */
+			tcp_init_nondata_skb(skb, TCP_SKB_CB(skb)->end_seq - 1,
+					     TCP_SKB_CB(skb)->flags);
 			skb->ip_summed =3D CHECKSUM_NONE;
-			skb->csum =3D 0;
 		}
 	}
=20
@@ -2068,16 +2086,9 @@ void tcp_send_fin(struct sock *sk)
=20
 		/* Reserve space for headers and prepare control bits. */
 		skb_reserve(skb, MAX_TCP_HEADER);
-		skb->csum =3D 0;
-		TCP_SKB_CB(skb)->flags =3D (TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
-		TCP_SKB_CB(skb)->sacked =3D 0;
-		skb_shinfo(skb)->gso_segs =3D 1;
-		skb_shinfo(skb)->gso_size =3D 0;
-		skb_shinfo(skb)->gso_type =3D 0;
-
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). =
*/
-		TCP_SKB_CB(skb)->seq =3D tp->write_seq;
-		TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq + 1;
+		tcp_init_nondata_skb(skb, tp->write_seq,
+				     TCPCB_FLAG_ACK | TCPCB_FLAG_FIN);
 		tcp_queue_skb(sk, skb);
 	}
 	__tcp_push_pending_frames(sk, mss_now, TCP_NAGLE_OFF);
@@ -2101,16 +2112,9 @@ void tcp_send_active_reset(struct sock *sk, gfp_=
t priority)
=20
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, MAX_TCP_HEADER);
-	skb->csum =3D 0;
-	TCP_SKB_CB(skb)->flags =3D (TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
-	TCP_SKB_CB(skb)->sacked =3D 0;
-	skb_shinfo(skb)->gso_segs =3D 1;
-	skb_shinfo(skb)->gso_size =3D 0;
-	skb_shinfo(skb)->gso_type =3D 0;
-
+	tcp_init_nondata_skb(skb, tcp_acceptable_seq(sk),
+			     TCPCB_FLAG_ACK | TCPCB_FLAG_RST);
 	/* Send it off. */
-	TCP_SKB_CB(skb)->seq =3D tcp_acceptable_seq(sk);
-	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq;
 	TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 	if (tcp_transmit_skb(sk, skb, 0, priority))
 		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
@@ -2198,12 +2202,11 @@ struct sk_buff *tcp_make_synack(struct sock *sk=
, struct dst_entry *dst,
 	TCP_ECN_make_synack(req, th);
 	th->source =3D inet_sk(sk)->sport;
 	th->dest =3D ireq->rmt_port;
-	TCP_SKB_CB(skb)->seq =3D tcp_rsk(req)->snt_isn;
-	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq + 1;
-	TCP_SKB_CB(skb)->sacked =3D 0;
-	skb_shinfo(skb)->gso_segs =3D 1;
-	skb_shinfo(skb)->gso_size =3D 0;
-	skb_shinfo(skb)->gso_type =3D 0;
+	/* Setting of flags are superfluous here for callers (and ECE is
+	 * not even correctly set)
+	 */
+	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
+			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
 	th->seq =3D htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq =3D htonl(tcp_rsk(req)->rcv_isn + 1);
 	if (req->rcv_wnd =3D=3D 0) { /* ignored for retransmitted syns */
@@ -2235,7 +2238,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, =
struct dst_entry *dst,
 			       NULL)
 			      );
=20
-	skb->csum =3D 0;
 	th->doff =3D (tcp_header_size >> 2);
 	TCP_INC_STATS(TCP_MIB_OUTSEGS);
=20
@@ -2327,16 +2329,9 @@ int tcp_connect(struct sock *sk)
 	/* Reserve space for headers. */
 	skb_reserve(buff, MAX_TCP_HEADER);
=20
-	TCP_SKB_CB(buff)->flags =3D TCPCB_FLAG_SYN;
-	TCP_ECN_send_syn(sk, buff);
-	TCP_SKB_CB(buff)->sacked =3D 0;
-	skb_shinfo(buff)->gso_segs =3D 1;
-	skb_shinfo(buff)->gso_size =3D 0;
-	skb_shinfo(buff)->gso_type =3D 0;
-	buff->csum =3D 0;
 	tp->snd_nxt =3D tp->write_seq;
-	TCP_SKB_CB(buff)->seq =3D tp->write_seq++;
-	TCP_SKB_CB(buff)->end_seq =3D tp->write_seq;
+	tcp_init_nondata_skb(buff, tp->write_seq++, TCPCB_FLAG_SYN);
+	TCP_ECN_send_syn(sk, buff);
=20
 	/* Send it off. */
 	TCP_SKB_CB(buff)->when =3D tcp_time_stamp;
@@ -2441,15 +2436,9 @@ void tcp_send_ack(struct sock *sk)
=20
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(buff, MAX_TCP_HEADER);
-	buff->csum =3D 0;
-	TCP_SKB_CB(buff)->flags =3D TCPCB_FLAG_ACK;
-	TCP_SKB_CB(buff)->sacked =3D 0;
-	skb_shinfo(buff)->gso_segs =3D 1;
-	skb_shinfo(buff)->gso_size =3D 0;
-	skb_shinfo(buff)->gso_type =3D 0;
+	tcp_init_nondata_skb(buff, tcp_acceptable_seq(sk), TCPCB_FLAG_ACK);
=20
 	/* Send it off, this clears delayed acks for us. */
-	TCP_SKB_CB(buff)->seq =3D TCP_SKB_CB(buff)->end_seq =3D tcp_acceptabl=
e_seq(sk);
 	TCP_SKB_CB(buff)->when =3D tcp_time_stamp;
 	tcp_transmit_skb(sk, buff, 0, GFP_ATOMIC);
 }
@@ -2477,19 +2466,11 @@ static int tcp_xmit_probe_skb(struct sock *sk, =
int urgent)
=20
 	/* Reserve space for headers and set control bits. */
 	skb_reserve(skb, MAX_TCP_HEADER);
-	skb->csum =3D 0;
-	TCP_SKB_CB(skb)->flags =3D TCPCB_FLAG_ACK;
-	TCP_SKB_CB(skb)->sacked =3D 0;
-	skb_shinfo(skb)->gso_segs =3D 1;
-	skb_shinfo(skb)->gso_size =3D 0;
-	skb_shinfo(skb)->gso_type =3D 0;
-
 	/* Use a previous sequence.  This should cause the other
 	 * end to send an ack.  Don't queue or clone SKB, just
 	 * send it.
 	 */
-	TCP_SKB_CB(skb)->seq =3D tp->snd_una - !urgent;
-	TCP_SKB_CB(skb)->end_seq =3D TCP_SKB_CB(skb)->seq;
+	tcp_init_nondata_skb(skb, tp->snd_una - !urgent, TCPCB_FLAG_ACK);
 	TCP_SKB_CB(skb)->when =3D tcp_time_stamp;
 	return tcp_transmit_skb(sk, skb, 0, GFP_ATOMIC);
 }
--=20
1.5.0.6

