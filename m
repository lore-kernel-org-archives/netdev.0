From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 6/7] [TCP]: Fix lost_retrans loop vs fastpath problems
Date: Thu, 11 Oct 2007 14:41:06 +0300
Message-ID: <11921028671668-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi> <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248AbXJKLlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:17 -0400
In-Reply-To: <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Detection implemented with lost_retrans must work also when
fastpath is taken, yet most of the queue is skipped including
(very likely) those retransmitted skb's we're interested in.
This problem appeared when the hints got added, which removed
a need to always walk over the whole write queue head.
Therefore decicion for the lost_retrans worker loop entry must
be separated from the sacktag processing more than it was
necessary before.

It turns out to be problematic to optimize the worker loop
very heavily because ack_seqs of skb may have a number of
discontinuity points. Maybe similar approach as currently is
implemented could be attempted but that's becoming more and
more complex because the trend is towards less skb walking
in sacktag marker. Trying a simple work until all rexmitted
skbs heve been processed approach.

Maybe after(highest_sack_end_seq, tp->high_seq) checking is not
sufficiently accurate and causes entry too often in no-work-to-do
cases. Since that's not known, I've separated solution to that
from this patch.

Noticed because of report against a related problem from TAKANO
Ryousei <takano@axe-inc.co.jp>. He also provided a patch to
that part of the problem. This patch includes solution to it
(though this patch has to use somewhat different placement).
TAKANO's description and patch is available here:

  http://marc.info/?l=3Dlinux-netdev&m=3D119149311913288&w=3D2

=2E..In short, TAKANO's problem is that end_seq the loop is using
not necessarily the largest SACK block's end_seq because the
current ACK may still have higher SACK blocks which are later
by the loop.

Cc: TAKANO Ryousei <takano@axe-inc.co.jp>
Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a066039..d5e0fcc 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1109,27 +1109,34 @@ static int tcp_is_sackblock_valid(struct tcp_so=
ck *tp, int is_dsack,
 /* Check for lost retransmit. This superb idea is borrowed from "rateh=
alving".
  * Event "C". Later note: FACK people cheated me again 8), we have to =
account
  * for reordering! Ugly, but should help.
+ *
+ * Search retransmitted skbs from write_queue that were sent when snd_=
nxt was
+ * less than what is now known to be received by the other end (derive=
d from
+ * SACK blocks by the caller).
  */
-static int tcp_mark_lost_retrans(struct sock *sk, u32 lost_retrans)
+static int tcp_mark_lost_retrans(struct sock *sk, u32 received_upto)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
 	int flag =3D 0;
+	int cnt =3D 0;
=20
 	tcp_for_write_queue(skb, sk) {
 		u32 ack_seq =3D TCP_SKB_CB(skb)->ack_seq;
=20
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		if (after(TCP_SKB_CB(skb)->seq, lost_retrans))
+		if (cnt =3D=3D tp->retrans_out)
 			break;
 		if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
 			continue;
=20
-		if ((TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS) &&
-		    after(lost_retrans, ack_seq) &&
+		if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS))
+			continue;
+
+		if (after(received_upto, ack_seq) &&
 		    (tcp_is_fack(tp) ||
-		     !before(lost_retrans,
+		     !before(received_upto,
 			     ack_seq + tp->reordering * tp->mss_cache))) {
 			TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 			tp->retrans_out -=3D tcp_skb_pcount(skb);
@@ -1143,6 +1150,8 @@ static int tcp_mark_lost_retrans(struct sock *sk,=
 u32 lost_retrans)
 				flag |=3D FLAG_DATA_SACKED;
 				NET_INC_STATS_BH(LINUX_MIB_TCPLOSTRETRANSMIT);
 			}
+		} else {
+			cnt +=3D tcp_skb_pcount(skb);
 		}
 	}
 	return flag;
@@ -1225,7 +1234,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int num_sacks =3D (ptr[1] - TCPOLEN_SACK_BASE)>>3;
 	int reord =3D tp->packets_out;
 	int prior_fackets;
-	u32 lost_retrans =3D 0;
+	u32 highest_sack_end_seq =3D 0;
 	int flag =3D 0;
 	int found_dup_sack =3D 0;
 	int cached_fack_count;
@@ -1396,11 +1405,6 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 				continue;
 			}
=20
-			if ((sacked&TCPCB_SACKED_RETRANS) &&
-			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!lost_retrans || after(end_seq, lost_retrans)))
-				lost_retrans =3D end_seq;
-
 			if (!in_sack)
 				continue;
=20
@@ -1454,9 +1458,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 				if (fack_count > tp->fackets_out)
 					tp->fackets_out =3D fack_count;
=20
-				if (after(TCP_SKB_CB(skb)->seq,
-				    tp->highest_sack))
+				if (after(TCP_SKB_CB(skb)->seq, tp->highest_sack)) {
 					tp->highest_sack =3D TCP_SKB_CB(skb)->seq;
+					highest_sack_end_seq =3D TCP_SKB_CB(skb)->end_seq;
+				}
 			} else {
 				if (dup_sack && (sacked&TCPCB_RETRANS))
 					reord =3D min(fack_count, reord);
@@ -1476,8 +1481,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 		}
 	}
=20
-	if (lost_retrans && icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
-		flag |=3D tcp_mark_lost_retrans(sk, lost_retrans);
+	if (tp->retrans_out && highest_sack_end_seq &&
+	    after(highest_sack_end_seq, tp->high_seq) &&
+	    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
+		flag |=3D tcp_mark_lost_retrans(sk, highest_sack_end_seq);
=20
 	tcp_verify_left_out(tp);
=20
--=20
1.5.0.6

