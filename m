From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 1/3] tcp: Add tcp_validate_incoming & put duplicated code there
Date: Fri, 22 Aug 2008 23:38:27 +0300
Message-ID: <1219437509-10048-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45364 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063AbYHVUib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 16:38:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Large block of code duplication removed.

Sadly, the return value thing is a bit tricky here but it
seems the most sensible way to return positive from validator
on success rather than negative.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |  147 +++++++++++++++++++++++-------------------=
-------
 1 files changed, 69 insertions(+), 78 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4f1cc0e..aa95c68 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4696,6 +4696,67 @@ out:
 }
 #endif /* CONFIG_NET_DMA */
=20
+/* Does PAWS and seqno based validation of an incoming segment, flags =
will
+ * play significant role here.
+ */
+static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
+			      struct tcphdr *th, int syn_inerr)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+
+	/* RFC1323: H1. Apply PAWS check first. */
+	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
+	    tcp_paws_discard(sk, skb)) {
+		if (!th->rst) {
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
+			tcp_send_dupack(sk, skb);
+			goto discard;
+		}
+		/* Reset is accepted even if it did not pass PAWS. */
+	}
+
+	/* Step 1: check sequence number */
+	if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)=
) {
+		/* RFC793, page 37: "In all states except SYN-SENT, all reset
+		 * (RST) segments are validated by checking their SEQ-fields."
+		 * And page 69: "If an incoming segment is not acceptable,
+		 * an acknowledgment should be sent in reply (unless the RST
+		 * bit is set, if so drop the segment and return)".
+		 */
+		if (!th->rst)
+			tcp_send_dupack(sk, skb);
+		goto discard;
+	}
+
+	/* Step 2: check RST bit */
+	if (th->rst) {
+		tcp_reset(sk);
+		goto discard;
+	}
+
+	/* ts_recent update must be made after we are sure that the packet
+	 * is in window.
+	 */
+	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
+
+	/* step 3: check security and precedence [ignored] */
+
+	/* step 4: Check for a SYN in window. */
+	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
+		if (syn_inerr)
+			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
+		tcp_reset(sk);
+		return -1;
+	}
+
+	return 1;
+
+discard:
+	__kfree_skb(skb);
+	return 0;
+}
+
 /*
  *	TCP receive function for the ESTABLISHED state.
  *
@@ -4723,6 +4784,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 			struct tcphdr *th, unsigned len)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+	int res;
=20
 	/*
 	 *	Header prediction.
@@ -4904,51 +4966,12 @@ slow_path:
 		goto csum_error;
=20
 	/*
-	 * RFC1323: H1. Apply PAWS check first.
-	 */
-	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
-	    tcp_paws_discard(sk, skb)) {
-		if (!th->rst) {
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
-			tcp_send_dupack(sk, skb);
-			goto discard;
-		}
-		/* Resets are accepted even if PAWS failed.
-
-		   ts_recent update must be made after we are sure
-		   that the packet is in window.
-		 */
-	}
-
-	/*
 	 *	Standard slow path.
 	 */
=20
-	if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)=
) {
-		/* RFC793, page 37: "In all states except SYN-SENT, all reset
-		 * (RST) segments are validated by checking their SEQ-fields."
-		 * And page 69: "If an incoming segment is not acceptable,
-		 * an acknowledgment should be sent in reply (unless the RST bit
-		 * is set, if so drop the segment and return)".
-		 */
-		if (!th->rst)
-			tcp_send_dupack(sk, skb);
-		goto discard;
-	}
-
-	if (th->rst) {
-		tcp_reset(sk);
-		goto discard;
-	}
-
-	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
-
-	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
-		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
-		tcp_reset(sk);
-		return 1;
-	}
+	res =3D tcp_validate_incoming(sk, skb, th, 1);
+	if (res <=3D 0)
+		return -res;
=20
 step5:
 	if (th->ack)
@@ -5230,6 +5253,7 @@ int tcp_rcv_state_process(struct sock *sk, struct=
 sk_buff *skb,
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
 	int queued =3D 0;
+	int res;
=20
 	tp->rx_opt.saw_tstamp =3D 0;
=20
@@ -5282,42 +5306,9 @@ int tcp_rcv_state_process(struct sock *sk, struc=
t sk_buff *skb,
 		return 0;
 	}
=20
-	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
-	    tcp_paws_discard(sk, skb)) {
-		if (!th->rst) {
-			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
-			tcp_send_dupack(sk, skb);
-			goto discard;
-		}
-		/* Reset is accepted even if it did not pass PAWS. */
-	}
-
-	/* step 1: check sequence number */
-	if (!tcp_sequence(tp, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq)=
) {
-		if (!th->rst)
-			tcp_send_dupack(sk, skb);
-		goto discard;
-	}
-
-	/* step 2: check RST bit */
-	if (th->rst) {
-		tcp_reset(sk);
-		goto discard;
-	}
-
-	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
-
-	/* step 3: check security and precedence [ignored] */
-
-	/*	step 4:
-	 *
-	 *	Check for a SYN in window.
-	 */
-	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONSYN);
-		tcp_reset(sk);
-		return 1;
-	}
+	res =3D tcp_validate_incoming(sk, skb, th, 0);
+	if (res <=3D 0)
+		return -res;
=20
 	/* step 5: check the ACK field */
 	if (th->ack) {
--=20
1.5.2.2

