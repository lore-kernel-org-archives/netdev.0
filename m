From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: SACK reneging clears stale recv_sack_cache
Date: Fri, 30 Mar 2007 17:55:46 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0703301740060.23854@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1869638151-1175266546=:23854"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51976 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350AbXC3Ozu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2007 10:55:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1869638151-1175266546=:23854
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Though not very efficient, the previous way of maintaining a
stale SACK cache past reneging protected better against misuse
because receiver couldn't cause set-clear ping-pong for
SACKED_ACKED for a large number of skbs.

Mostly copy-paste from sacktag clearer. Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 97b9be2..ea196de 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1509,7 +1509,7 @@ void tcp_enter_loss(struct sock *sk, int
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	int cnt = 0;
+	int cnt = 0, i;
 
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder || tp->snd_una == tp->high_seq ||
@@ -1527,8 +1527,15 @@ void tcp_enter_loss(struct sock *sk, int
 
 	/* Push undo marker, if it was plain RTO and nothing
 	 * was retransmitted. */
-	if (!how)
+	if (!how) {
 		tp->undo_marker = tp->snd_una;
+	} else {
+		/* We're going to flush SACKed state, every SACK counts again */
+		for (i = 0; i < ARRAY_SIZE(tp->recv_sack_cache); i++) {
+			tp->recv_sack_cache[i].start_seq = 0;
+			tp->recv_sack_cache[i].end_seq = 0;
+		}
+	}
 
 	tcp_for_write_queue(skb, sk) {
 		if (skb == tcp_send_head(sk))
-- 
1.4.2

---696243703-1869638151-1175266546=:23854--
