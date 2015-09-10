From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net 1/2] tcp: generate CA_EVENT_TX_START on data frames
Date: Wed, 09 Sep 2015 21:54:37 -0700
Message-ID: <1441860877.4619.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Jana Iyengar <jri@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Lawrence Brakmo <lawrence@brakmo.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36195 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512AbbIJEyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 00:54:40 -0400
Received: by padhk3 with SMTP id hk3so31122317pad.3
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 21:54:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>

Issuing a CC TX_START event on control frames like pure ACK
is a waste of time, as a CC should not care.

Following patch needs this change, as we want CUBIC to properly track
idle time at a low cost, with a single TX_START being generated.

Yuchung might slightly refine the condition triggering TX_START
on a followup patch.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Cc: Jana Iyengar <jri@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Sangtae Ha <sangtae.ha@gmail.com>
Cc: Lawrence Brakmo <lawrence@brakmo.org>
---
 net/ipv4/tcp_output.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1188e4fcf23b..f9a8a12b62ee 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -164,6 +164,9 @@ static void tcp_event_data_sent(struct tcp_sock *tp,
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	const u32 now = tcp_time_stamp;
 
+	if (tcp_packets_in_flight(tp) == 0)
+		tcp_ca_event(sk, CA_EVENT_TX_START);
+
 	tp->lsndtime = now;
 
 	/* If it is a reply for ato after last received
@@ -940,9 +943,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 							   &md5);
 	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
-	if (tcp_packets_in_flight(tp) == 0)
-		tcp_ca_event(sk, CA_EVENT_TX_START);
-
 	/* if no packet is in qdisc/device queue, then allow XPS to select
 	 * another queue. We can be called from tcp_tsq_handler()
 	 * which holds one reference to sk_wmem_alloc.
