From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/9] [TCP]: Access to highest_sack obsoletes forward_cnt_hint
Date: Sat, 26 May 2007 11:35:57 +0300
Message-ID: <11801685621216-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11801685622325-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685621267-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685626-git-send-email-ilpo.jarvinen@helsinki.fi> <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47757 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbXEZIgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 04:36:07 -0400
In-Reply-To: <11801685623173-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

In addition, added a reference about the purpose of the loop.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h   |    1 -
 net/ipv4/tcp_output.c |   23 +++++++++--------------
 2 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 63e04f4..1ce9fd4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -343,7 +343,6 @@ struct tcp_sock {
=20
 	int     fastpath_cnt_hint;
 	int     retransmit_cnt_hint;
-	int     forward_cnt_hint;
=20
 	u16	advmss;		/* Advertised MSS			*/
 	u16	prior_ssthresh; /* ssthresh saved at recovery start	*/
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d67fb3d..f33e25b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1931,33 +1931,28 @@ void tcp_xmit_retransmit_queue(struct sock *sk)
 	 * and retransmission... Both ways have their merits...
 	 *
 	 * For now we do not retransmit anything, while we have some new
-	 * segments to send.
+	 * segments to send. In the other cases, follow rule 3 for
+	 * NextSeg() specified in RFC3517.
 	 */
=20
 	if (tcp_may_send_now(sk))
 		return;
=20
-	if (tp->forward_skb_hint) {
+	/* If nothing is SACKed, highest_sack in the loop won't be valid */
+	if (!tp->sacked_out)
+		return;
+
+	if (tp->forward_skb_hint)
 		skb =3D tp->forward_skb_hint;
-		packet_cnt =3D tp->forward_cnt_hint;
-	} else{
+	else
 		skb =3D tcp_write_queue_head(sk);
-		packet_cnt =3D 0;
-	}
=20
 	tcp_for_write_queue_from(skb, sk) {
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
-		tp->forward_cnt_hint =3D packet_cnt;
 		tp->forward_skb_hint =3D skb;
=20
-		/* Similar to the retransmit loop above we
-		 * can pretend that the retransmitted SKB
-		 * we send out here will be composed of one
-		 * real MSS sized packet because tcp_retransmit_skb()
-		 * will fragment it if necessary.
-		 */
-		if (++packet_cnt > tp->fackets_out)
+		if (after(TCP_SKB_CB(skb)->seq, tp->highest_sack))
 			break;
=20
 		if (tcp_packets_in_flight(tp) >=3D tp->snd_cwnd)
--=20
1.5.0.6

