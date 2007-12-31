From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/9] [TCP]: Dropped unnecessary skb/sacked accessing in reneging
Date: Mon, 31 Dec 2007 12:47:53 +0200
Message-ID: <11990980773732-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi> <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980773391-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980771495-git-send-email-ilpo.jarvinen@helsinki.fi> <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42223 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755032AbXLaKsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:48:01 -0500
In-Reply-To: <11990980772309-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SACK reneging can be precalculated to a FLAG in clean_rtx_queue
which has the right skb looked up. This will help a bit in
future because skb->sacked access will be changed eventually,
changing it already won't hurt any.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 366f63a..7bac1fa 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -105,6 +105,7 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!=3D FLAG_=
DATA_ACKED) */
 #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info *=
/
 #define FLAG_NONHEAD_RETRANS_ACKED	0x1000 /* Non-head rexmitted data w=
as ACKed */
+#define FLAG_SACK_RENEGING	0x2000 /* snd_una advanced to a sacked seq =
*/
=20
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@ -1918,18 +1919,15 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tp->frto_counter =3D 0;
 }
=20
-static int tcp_check_sack_reneging(struct sock *sk)
+/* If ACK arrived pointing to a remembered SACK, it means that our
+ * remembered SACKs do not reflect real state of receiver i.e.
+ * receiver _host_ is heavily congested (or buggy).
+ *
+ * Do processing similar to RTO timeout.
+ */
+static int tcp_check_sack_reneging(struct sock *sk, int flag)
 {
-	struct sk_buff *skb;
-
-	/* If ACK arrived pointing to a remembered SACK,
-	 * it means that our remembered SACKs do not reflect
-	 * real state of receiver i.e.
-	 * receiver _host_ is heavily congested (or buggy).
-	 * Do processing similar to RTO timeout.
-	 */
-	if ((skb =3D tcp_write_queue_head(sk)) !=3D NULL &&
-	    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED)) {
+	if (flag & FLAG_SACK_RENEGING) {
 		struct inet_connection_sock *icsk =3D inet_csk(sk);
 		NET_INC_STATS_BH(LINUX_MIB_TCPSACKRENEGING);
=20
@@ -2515,7 +2513,7 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_a=
cked, int flag)
 		tp->prior_ssthresh =3D 0;
=20
 	/* B. In all the states check for reneging SACKs. */
-	if (tp->sacked_out && tcp_check_sack_reneging(sk))
+	if (tcp_check_sack_reneging(sk, flag))
 		return;
=20
 	/* C. Process data loss notification, provided it is valid. */
@@ -2852,6 +2850,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, i=
nt prior_fackets)
 		tcp_clear_all_retrans_hints(tp);
 	}
=20
+	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
+		flag |=3D FLAG_SACK_RENEGING;
+
 	if (flag & FLAG_ACKED) {
 		const struct tcp_congestion_ops *ca_ops
 			=3D inet_csk(sk)->icsk_ca_ops;
--=20
1.5.0.6

