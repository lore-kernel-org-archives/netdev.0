From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 2/5] tcp: use DSACKs that arrive when packets_out is 0
Date: Wed, 16 Nov 2011 13:58:02 -0500
Message-ID: <1321469885-10885-2-git-send-email-ncardwell@google.com>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f202.google.com ([209.85.161.202]:57490 "EHLO
	mail-gx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1KPTD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:03:56 -0500
Received: by ggnp4 with SMTP id p4so5583ggn.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:03:56 -0800 (PST)
In-Reply-To: <1321469885-10885-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bug: Senders ignored DSACKs after recovery when there were no
outstanding packets (a common scenario for HTTP servers).

The change: when there are no outstanding packets (the "no_queue" goto
label), call tcp_fastretrans_alert() in order to use DSACKs to undo
congestion window reductions.

Other patches in this series will provide other changes that are
necessary to fully fix this problem.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f772aaa..b49e418 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3788,6 +3788,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	return 1;
 
 no_queue:
+	/* If data was DSACKed, see if we can undo a cwnd reduction. */
+	if (flag & FLAG_DSACKING_ACK)
+		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
+				      is_dupack, flag);
 	/* If this ack opens up a zero window, clear backoff.  It was
 	 * being used to time the probes, and is probably far higher than
 	 * it needs to be for normal retransmission.
-- 
1.7.3.1
