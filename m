From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCHv2 net-2.6 1/4] [TCP]: Restore 2.6.24 mark_head_lost behavior for newreno/fack
Date: Mon,  7 Apr 2008 14:55:41 +0300
Message-ID: <1207569344-19687-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Soeren Sonnenburg <kernel@nn7.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47053 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024AbYDGLzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 07:55:51 -0400
In-Reply-To: <1207569344-19687-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fast retransmission can be forced locally to the rfc3517
branch in tcp_update_scoreboard instead of making such fragile
constructs deeper in tcp_mark_head_lost.

This is necessary for the next patch which must not have
loopholes for cnt > packets check. As one can notice,
readability got some improvements too because of this :-).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6e46b4c..f82b573 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2134,7 +2134,7 @@ static void tcp_verify_retransmit_hint(struct tcp=
_sock *tp, struct sk_buff *skb)
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
-static void tcp_mark_head_lost(struct sock *sk, int packets, int fast_=
rexmit)
+static void tcp_mark_head_lost(struct sock *sk, int packets)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
@@ -2161,7 +2161,7 @@ static void tcp_mark_head_lost(struct sock *sk, i=
nt packets, int fast_rexmit)
 		    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 			cnt +=3D tcp_skb_pcount(skb);
=20
-		if (((!fast_rexmit || (tp->lost_out > 0)) && (cnt > packets)) ||
+		if ((cnt > packets) ||
 		    after(TCP_SKB_CB(skb)->end_seq, tp->high_seq))
 			break;
 		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
@@ -2180,17 +2180,17 @@ static void tcp_update_scoreboard(struct sock *=
sk, int fast_rexmit)
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	if (tcp_is_reno(tp)) {
-		tcp_mark_head_lost(sk, 1, fast_rexmit);
+		tcp_mark_head_lost(sk, 1);
 	} else if (tcp_is_fack(tp)) {
 		int lost =3D tp->fackets_out - tp->reordering;
 		if (lost <=3D 0)
 			lost =3D 1;
-		tcp_mark_head_lost(sk, lost, fast_rexmit);
+		tcp_mark_head_lost(sk, lost);
 	} else {
 		int sacked_upto =3D tp->sacked_out - tp->reordering;
-		if (sacked_upto < 0)
-			sacked_upto =3D 0;
-		tcp_mark_head_lost(sk, sacked_upto, fast_rexmit);
+		if (sacked_upto < fast_rexmit)
+			sacked_upto =3D fast_rexmit;
+		tcp_mark_head_lost(sk, sacked_upto);
 	}
=20
 	/* New heuristics: it is possible only after we switched
@@ -2524,7 +2524,7 @@ static void tcp_fastretrans_alert(struct sock *sk=
, int pkts_acked, int flag)
 	    before(tp->snd_una, tp->high_seq) &&
 	    icsk->icsk_ca_state !=3D TCP_CA_Open &&
 	    tp->fackets_out > tp->reordering) {
-		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering, 0);
+		tcp_mark_head_lost(sk, tp->fackets_out - tp->reordering);
 		NET_INC_STATS_BH(LINUX_MIB_TCPLOSS);
 	}
=20
--=20
1.5.2.2

