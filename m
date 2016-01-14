From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 4/6] tcp: refactor pkts acked accounting
Date: Thu, 14 Jan 2016 15:43:32 -0800
Message-ID: <1452815014-601-5-git-send-email-ycheng@google.com>
References: <1452815014-601-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33137 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757214AbcANXoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:44:20 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so384637600pac.0
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 15:44:19 -0800 (PST)
In-Reply-To: <1452815014-601-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A small refactoring that gets number of packets cumulatively acked
from tcp_clean_rtx_queue() directly.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e7a8ce7..2d6eaad 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3106,7 +3106,7 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
  * arrived at the other end.
  */
 static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
-			       u32 prior_snd_una,
+			       u32 prior_snd_una, int *acked,
 			       struct tcp_sacktag_state *sack)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
@@ -3279,6 +3279,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		}
 	}
 #endif
+	*acked = pkts_acked;
 	return flag;
 }
 
@@ -3644,10 +3645,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		goto no_queue;
 
 	/* See if we can take anything off of the retransmit queue. */
-	acked = tp->packets_out;
-	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una,
+	flag |= tcp_clean_rtx_queue(sk, prior_fackets, prior_snd_una, &acked,
 				    &sack_state);
-	acked -= tp->packets_out;
 
 	if (tcp_ack_is_dubious(sk, flag)) {
 		is_dupack = !(flag & (FLAG_SND_UNA_ADVANCED | FLAG_NOT_DUP));
-- 
2.6.0.rc2.230.g3dd15c0
