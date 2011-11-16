From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 3/5] tcp: use SACKs and DSACKs that arrive on ACKs below snd_una
Date: Wed, 16 Nov 2011 13:58:03 -0500
Message-ID: <1321469885-10885-3-git-send-email-ncardwell@google.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f74.google.com ([209.85.213.74]:39000 "EHLO
	mail-yw0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831Ab1KPTVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:21:42 -0500
Received: by ywb5 with SMTP id 5so8838ywb.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:21:41 -0800 (PST)
In-Reply-To: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug: When the ACK field is below snd_una (which can happen when
ACKs are reordered), senders ignored DSACKs (preventing undo) and did
not call tcp_fastretrans_alert, so they did not increment
prr_delivered to reflect newly-SACKed sequence ranges, and did not
call tcp_xmit_retransmit_queue, thus passing up chances to send out
more retransmitted and new packets based on any newly-SACKed packets.

The change: When the ACK field is below snd_una (the "old_ack" goto
label), call tcp_fastretrans_alert to allow undo based on any
newly-arrived DSACKs and try to send out more packets based on
newly-SACKed packets.

Other patches in this series will provide other changes that are
necessary to fully fix this problem.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index b49e418..751d390 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3805,10 +3805,14 @@ invalid_ack:
 	return -1;
 
 old_ack:
+	/* If data was SACKed, tag it and see if we should send more data.
+	 * If data was DSACKed, see if we can undo a cwnd reduction.
+	 */
 	if (TCP_SKB_CB(skb)->sacked) {
-		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
-		if (icsk->icsk_ca_state == TCP_CA_Open)
-			tcp_try_keep_open(sk);
+		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
+		newly_acked_sacked = tp->sacked_out - prior_sacked;
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	}
 
 	SOCK_DEBUG(sk, "Ack %u before %u:%u\n", ack, tp->snd_una, tp->snd_nxt);
-- 
1.7.3.1
