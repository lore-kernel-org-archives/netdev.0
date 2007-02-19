From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 5/18] [TCP] FRTO: Consecutive RTOs keep prior_ssthresh and ssthresh
Date: Mon, 19 Feb 2007 13:37:59 +0200
Message-ID: <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126AbXBSLiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:15 -0500
In-Reply-To: <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case a latency spike causes more than one RTO, the later should not
cause the already reduced ssthresh to propagate into the prior_ssthresh
since FRTO declares all such RTOs spurious at once or none of them. In
treating of ssthresh, we mimic what tcp_enter_loss() does.

The previous state (in frto_counter) must be available until we have
checked it in tcp_enter_frto(), and also ACK information flag in
process_frto().

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f645c3e..c846beb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1252,6 +1252,10 @@ int tcp_use_frto(const struct sock *sk)
 /* RTO occurred, but do not yet enter Loss state. Instead, defer RTO
  * recovery a bit and use heuristics in tcp_process_frto() to detect i=
f
  * the RTO was spurious.
+ *
+ * Do like tcp_enter_loss() would; when RTO expires the second time it
+ * does:
+ *  "Reduce ssthresh if it has not yet been made inside this window."
  */
 void tcp_enter_frto(struct sock *sk)
 {
@@ -1259,11 +1263,10 @@ void tcp_enter_frto(struct sock *sk)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
=20
-	tp->frto_counter =3D 1;
-
-	if (icsk->icsk_ca_state <=3D TCP_CA_Disorder ||
+	if ((!tp->frto_counter && icsk->icsk_ca_state <=3D TCP_CA_Disorder) |=
|
 	    tp->snd_una =3D=3D tp->high_seq ||
-	    (icsk->icsk_ca_state =3D=3D TCP_CA_Loss && !icsk->icsk_retransmit=
s)) {
+	    ((icsk->icsk_ca_state =3D=3D TCP_CA_Loss || tp->frto_counter) &&
+	     !icsk->icsk_retransmits)) {
 		tp->prior_ssthresh =3D tcp_current_ssthresh(sk);
 		tp->snd_ssthresh =3D icsk->icsk_ca_ops->ssthresh(sk);
 		tcp_ca_event(sk, CA_EVENT_FRTO);
@@ -1285,6 +1288,7 @@ void tcp_enter_frto(struct sock *sk)
=20
 	tcp_set_ca_state(sk, TCP_CA_Open);
 	tp->frto_highmark =3D tp->snd_nxt;
+	tp->frto_counter =3D 1;
 }
=20
 /* Enter Loss state after F-RTO was applied. Dupack arrived after RTO,
@@ -2513,12 +2517,16 @@ static void tcp_conservative_spur_to_res
  *     to prove that the RTO is indeed spurious. It transfers the cont=
rol
  *     from F-RTO to the conventional RTO recovery
  */
-static void tcp_process_frto(struct sock *sk, u32 prior_snd_una)
+static void tcp_process_frto(struct sock *sk, u32 prior_snd_una, int f=
lag)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
=20
 	tcp_sync_left_out(tp);
=20
+	/* Duplicate the behavior from Loss state (fastretrans_alert) */
+	if (flag&FLAG_DATA_ACKED)
+		inet_csk(sk)->icsk_retransmits =3D 0;
+
 	if (tp->snd_una =3D=3D prior_snd_una ||
 	    !before(tp->snd_una, tp->frto_highmark)) {
 		tcp_enter_frto_loss(sk);
@@ -2607,7 +2615,7 @@ static int tcp_ack(struct sock *sk, stru
 	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt);
=20
 	if (tp->frto_counter)
-		tcp_process_frto(sk, prior_snd_una);
+		tcp_process_frto(sk, prior_snd_una, flag);
=20
 	if (tcp_ack_is_dubious(sk, flag)) {
 		/* Advance CWND, if state allows this. */
--=20
1.4.2

