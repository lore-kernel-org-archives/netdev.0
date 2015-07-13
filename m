From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: don't use F-RTO on non-recurring timeouts
Date: Mon, 13 Jul 2015 12:10:20 -0700
Message-ID: <1436814620-5889-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33934 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024AbbGMTK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 15:10:29 -0400
Received: by iebmu5 with SMTP id mu5so241117545ieb.1
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 12:10:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently F-RTO may repeatedly send new data packets on non-recurring
timeouts in CA_Loss mode. This is a bug because F-RTO (RFC5682)
should only be used on either new recovery or recurring timeouts.

This exacerbates the recovery progress during frequent timeout &
repair, because we prioritize sending new data packets instead of
repairing the holes when the bandwidth is already scarce.

Fix it by correcting the test of a new recovery episode.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1578fc2..0cef1af 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1920,14 +1920,13 @@ void tcp_enter_loss(struct sock *sk)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
-	bool new_recovery = false;
+	bool new_recovery = icsk->icsk_ca_state < TCP_CA_Recovery;
 	bool is_reneg;			/* is receiver reneging on SACKs? */
 
 	/* Reduce ssthresh if it has not yet been made inside this window. */
 	if (icsk->icsk_ca_state <= TCP_CA_Disorder ||
 	    !after(tp->high_seq, tp->snd_una) ||
 	    (icsk->icsk_ca_state == TCP_CA_Loss && !icsk->icsk_retransmits)) {
-		new_recovery = true;
 		tp->prior_ssthresh = tcp_current_ssthresh(sk);
 		tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
 		tcp_ca_event(sk, CA_EVENT_LOSS);
-- 
2.4.3.573.g4eafbef
