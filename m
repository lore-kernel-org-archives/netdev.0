From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP] FRTO: Delay skb available check until it's mandatory
Date: Wed, 11 Apr 2007 12:25:50 +0300
Message-ID: <11762835513275-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43890 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751653AbXDKJZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 05:25:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No new data is needed until the first ACK comes, so no need to
check for application limitedness until then.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 107bece..21fd8fb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1312,20 +1312,15 @@ #endif
 	return state.flag;
 }
=20
-/* F-RTO can only be used if these conditions are satisfied:
- *  - there must be some unsent new data
- *  - the advertised window should allow sending it
- *  - TCP has never retransmitted anything other than head (SACK enhan=
ced
- *    variant from Appendix B of RFC4138 is more robust here)
+/* F-RTO can only be used if TCP has never retransmitted anything othe=
r than
+ * head (SACK enhanced variant from Appendix B of RFC4138 is more robu=
st here)
  */
 int tcp_use_frto(struct sock *sk)
 {
 	const struct tcp_sock *tp =3D tcp_sk(sk);
 	struct sk_buff *skb;
-
-	if (!sysctl_tcp_frto || !tcp_send_head(sk) ||
-		after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
-		      tp->snd_una + tp->snd_wnd))
+
+	if (!sysctl_tcp_frto)
 		return 0;
=20
 	if (IsSackFrto())
@@ -2849,6 +2844,14 @@ static int tcp_process_frto(struct sock=20
 	}
=20
 	if (tp->frto_counter =3D=3D 1) {
+		/* Sending of the next skb must be allowed or no FRTO */
+		if (!tcp_send_head(sk) ||
+		    after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
+				     tp->snd_una + tp->snd_wnd)) {
+			tcp_enter_frto_loss(sk, tp->frto_counter + 1, flag);
+			return 1;
+		}
+
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
 		tp->frto_counter =3D 2;
 		return 1;
--=20
1.4.2

