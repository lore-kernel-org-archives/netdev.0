From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: limit GSO packets to half cwnd
Date: Thu, 13 Nov 2014 09:45:22 -0800
Message-ID: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:40086 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933428AbaKMRpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 12:45:25 -0500
Received: by mail-ig0-f179.google.com with SMTP id r10so85222igi.12
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 09:45:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In DC world, GSO packets initially cooked by tcp_sendmsg() are usually
big, as sk_pacing_rate is high.

When network is congested, cwnd can be smaller than the GSO packets
found in socket write queue. tcp_write_xmit() splits GSO packets
using the available cwnd, and we end up sending a single GSO packet,
consuming all available cwnd.

With GRO aggregation on the receiver, we might handle a single GRO
packet, sending back a single ACK.

1) This single ACK might be lost
   TLP or RTO are forced to attempt a retransmit.
2) This ACK releases a full cwnd, sender sends another big GSO packet,
   in a ping pong mode.

This behavior does not fill the pipes in the best way, because of
scheduling artifacts.

Make sure we always have at least two GSO packets in flight.

This allows us to safely increase GRO efficiency without risking
spurious retransmits.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0b88158dd4a70d5007e79f0d8251fee2f7c6c7f8..eb73a1dccf56b823a45c0ca034e40dc50fc48068 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1562,7 +1562,7 @@ static unsigned int tcp_mss_split_point(const struct sock *sk,
 static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
 					 const struct sk_buff *skb)
 {
-	u32 in_flight, cwnd;
+	u32 in_flight, cwnd, halfcwnd;
 
 	/* Don't be strict about the congestion window for the final FIN.  */
 	if ((TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN) &&
@@ -1571,10 +1571,14 @@ static inline unsigned int tcp_cwnd_test(const struct tcp_sock *tp,
 
 	in_flight = tcp_packets_in_flight(tp);
 	cwnd = tp->snd_cwnd;
-	if (in_flight < cwnd)
-		return (cwnd - in_flight);
+	if (in_flight >= cwnd)
+		return 0;
 
-	return 0;
+	/* For better scheduling, ensure we have at least
+	 * 2 GSO packets in flight.
+	 */
+	halfcwnd = max(cwnd >> 1, 1U);
+	return min(halfcwnd, cwnd - in_flight);
 }
 
 /* Initialize TSO state of a skb.
