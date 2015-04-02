From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp: fix FRTO undo on cumulative ACK of SACKed range
Date: Wed,  1 Apr 2015 20:26:46 -0400
Message-ID: <1427934406-18743-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34549 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbbDBA1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 20:27:20 -0400
Received: by ykef74 with SMTP id f74so18240975yke.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 17:27:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On processing cumulative ACKs, the FRTO code was not checking the
SACKed bit, meaning that there could be a spurious FRTO undo on a
cumulative ACK of a previously SACKed skb.

The FRTO code should only consider a cumulative ACK to indicate that
an original/unretransmitted skb is newly ACKed if the skb was not yet
SACKed.

The effect of the spurious FRTO undo would typically be to make the
connection think that all previously-sent packets were in flight when
they really weren't, leading to a stall and an RTO.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Fixes: e33099f96d99c ("tcp: implement RFC5682 F-RTO")
---
 net/ipv4/tcp_input.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fb4cf8b..f501ac04 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3105,10 +3105,11 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 			if (!first_ackt.v64)
 				first_ackt = last_ackt;
 
-			if (!(sacked & TCPCB_SACKED_ACKED))
+			if (!(sacked & TCPCB_SACKED_ACKED)) {
 				reord = min(pkts_acked, reord);
-			if (!after(scb->end_seq, tp->high_seq))
-				flag |= FLAG_ORIG_SACK_ACKED;
+				if (!after(scb->end_seq, tp->high_seq))
+					flag |= FLAG_ORIG_SACK_ACKED;
+			}
 		}
 
 		if (sacked & TCPCB_SACKED_ACKED)
-- 
2.2.0.rc0.207.ga3a616c
