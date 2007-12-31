From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/9] [TCP]: Remove TCPCB_URG & TCPCB_AT_TAIL as unnecessary
Date: Mon, 31 Dec 2007 12:47:54 +0200
Message-ID: <11990980772445-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46986 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbXLaKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:48:01 -0500
In-Reply-To: <11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The snd_up check should be enough. I suspect this has been
there to provide a minor optimization in clean_rtx_queue which
used to have a small if (!->sacked) block which could skip
snd_up check among the other work.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |    4 ----
 net/ipv4/tcp.c        |    1 -
 net/ipv4/tcp_input.c  |    3 +--
 net/ipv4/tcp_output.c |    7 +++----
 4 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6a732d4..48081ad 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -578,10 +578,6 @@ struct tcp_skb_cb {
 #define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
=20
-#define TCPCB_URG		0x20	/* Urgent pointer advanced here	*/
-
-#define TCPCB_AT_TAIL		(TCPCB_URG)
-
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
 };
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2cbfa6d..34085e3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -497,7 +497,6 @@ static inline void tcp_mark_urg(struct tcp_sock *tp=
, int flags,
 	if (flags & MSG_OOB) {
 		tp->urg_mode =3D 1;
 		tp->snd_up =3D tp->write_seq;
-		TCP_SKB_CB(skb)->sacked |=3D TCPCB_URG;
 	}
 }
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7bac1fa..1e7fd81 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2821,8 +2821,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
 		if (sacked & TCPCB_LOST)
 			tp->lost_out -=3D acked_pcount;
=20
-		if (unlikely((sacked & TCPCB_URG) && tp->urg_mode &&
-			     !before(end_seq, tp->snd_up)))
+		if (unlikely(tp->urg_mode && !before(end_seq, tp->snd_up)))
 			tp->urg_mode =3D 0;
=20
 		tp->packets_out -=3D acked_pcount;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 202d60c..182ae21 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -711,7 +711,6 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len, unsigned int mss
 	TCP_SKB_CB(skb)->flags =3D flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
 	TCP_SKB_CB(buff)->flags =3D flags;
 	TCP_SKB_CB(buff)->sacked =3D TCP_SKB_CB(skb)->sacked;
-	TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_AT_TAIL;
=20
 	if (!skb_shinfo(skb)->nr_frags && skb->ip_summed !=3D CHECKSUM_PARTIA=
L) {
 		/* Copy and checksum data tail into the new buffer. */
@@ -1721,7 +1720,7 @@ static void tcp_retrans_try_collapse(struct sock =
*sk, struct sk_buff *skb, int m
 		/* All done, get rid of second SKB and account for it so
 		 * packet counting does not break.
 		 */
-		TCP_SKB_CB(skb)->sacked |=3D TCP_SKB_CB(next_skb)->sacked&(TCPCB_EVE=
R_RETRANS|TCPCB_AT_TAIL);
+		TCP_SKB_CB(skb)->sacked |=3D TCP_SKB_CB(next_skb)->sacked & TCPCB_EV=
ER_RETRANS;
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_SACKED_RETRANS)
 			tp->retrans_out -=3D tcp_skb_pcount(next_skb);
 		if (TCP_SKB_CB(next_skb)->sacked&TCPCB_LOST)
@@ -2470,7 +2469,7 @@ static int tcp_xmit_probe_skb(struct sock *sk, in=
t urgent)
 	skb_reserve(skb, MAX_TCP_HEADER);
 	skb->csum =3D 0;
 	TCP_SKB_CB(skb)->flags =3D TCPCB_FLAG_ACK;
-	TCP_SKB_CB(skb)->sacked =3D urgent;
+	TCP_SKB_CB(skb)->sacked =3D 0;
 	skb_shinfo(skb)->gso_segs =3D 1;
 	skb_shinfo(skb)->gso_size =3D 0;
 	skb_shinfo(skb)->gso_type =3D 0;
@@ -2522,7 +2521,7 @@ int tcp_write_wakeup(struct sock *sk)
 		} else {
 			if (tp->urg_mode &&
 			    between(tp->snd_up, tp->snd_una+1, tp->snd_una+0xFFFF))
-				tcp_xmit_probe_skb(sk, TCPCB_URG);
+				tcp_xmit_probe_skb(sk, 1);
 			return tcp_xmit_probe_skb(sk, 0);
 		}
 	}
--=20
1.5.0.6

