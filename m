From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: tcp_replace_ts_recent() should not be called from
 tcp_validate_incoming()
Date: Tue, 13 Nov 2012 00:05:51 -0800
Message-ID: <1352793951.6185.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:42985 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab2KMIFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 03:05:53 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so479102iay.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 00:05:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We added support for RFC 5962 in latest kernels but TCP fails
to perform exhaustive check of ACK sequence.

We can update our view of peer tsval from a frame that is
later discarded by tcp_ack()

This makes timestamps enabled sessions vulnerable to injection of
a high tsval : peers start an ACK storm, since the victim
sends a dupack each time it receives an ACK from the other peer.

As tcp_validate_incoming() is called before tcp_ack(), we should
not peform tcp_replace_ts_recent() from it, and let callers do it
at the right time.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
---
 net/ipv4/tcp_input.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7839d51..fc67831 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5320,11 +5320,6 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 		goto discard;
 	}
 
-	/* ts_recent update must be made after we are sure that the packet
-	 * is in window.
-	 */
-	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
-
 	/* step 3: check security and precedence [ignored] */
 
 	/* step 4: Check for a SYN
@@ -5559,6 +5554,11 @@ step5:
 	if (th->ack && tcp_ack(sk, skb, FLAG_SLOWPATH) < 0)
 		goto discard;
 
+	/* ts_recent update must be made after we are sure that the packet
+	 * is acceptable.
+	 */
+	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
+
 	tcp_rcv_rtt_measure_ts(sk, skb);
 
 	/* Process urgent data. */
@@ -6137,6 +6137,11 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	} else
 		goto discard;
 
+	/* ts_recent update must be made after we are sure that the packet
+	 * is in acceptable.
+	 */
+	tcp_replace_ts_recent(tp, TCP_SKB_CB(skb)->seq);
+
 	/* step 6: check the URG bit */
 	tcp_urg(sk, skb, th);
 
