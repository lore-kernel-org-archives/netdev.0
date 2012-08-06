From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: ecn: dont delay ACKS after CE
Date: Mon, 06 Aug 2012 23:04:43 +0200
Message-ID: <1344287083.26674.83.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:56789 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756893Ab2HFVEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 17:04:48 -0400
Received: by weyx8 with SMTP id x8so2242456wey.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 14:04:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While playing with CoDel and ECN marking, I discovered a
non optimal behavior of receiver of CE (Congestion Encountered)
segments.

In pathological cases, sender has reduced its cwnd to low values,
and receiver delays its ACK (by 40 ms).

While RFC 3168 6.1.3 (The TCP Receiver) doesn't explicitly recommend
to send immediate ACKS, we believe its better to not delay ACKS, because
a CE segment should give same signal than a dropped segment, and its
quite important to reduce RTT to give ECE/CWR signals as fast as
possible.

Note we already call tcp_enter_quickack_mode() from TCP_ECN_check_ce()
if we receive a retransmit, for the same reason.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2fd2bc9..fa2c2c2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -237,7 +237,11 @@ static inline void TCP_ECN_check_ce(struct tcp_sock *tp, const struct sk_buff *s
 			tcp_enter_quickack_mode((struct sock *)tp);
 		break;
 	case INET_ECN_CE:
-		tp->ecn_flags |= TCP_ECN_DEMAND_CWR;
+		if (!(tp->ecn_flags & TCP_ECN_DEMAND_CWR)) {
+			/* Better not delay acks, sender can have a very low cwnd */
+			tcp_enter_quickack_mode((struct sock *)tp);
+			tp->ecn_flags |= TCP_ECN_DEMAND_CWR;
+		}
 		/* fallinto */
 	default:
 		tp->ecn_flags |= TCP_ECN_SEEN;
