From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: align tcp_xmit_size_goal() on tcp_tso_autosize()
Date: Thu, 05 Mar 2015 08:03:06 -0800
Message-ID: <1425571386.5130.247.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33937 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756915AbbCEQDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 11:03:08 -0500
Received: by iecvy18 with SMTP id vy18so13559883iec.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 08:03:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With some mss values, it is possible tcp_xmit_size_goal() puts
one segment more in TSO packet than tcp_tso_autosize().

We send then one TSO packet followed by one single MSS.

It is not a serious bug, but we can do slightly better, especially
for drivers using netif_set_gso_max_size() to lower gso_max_size.

Using same formula avoids these corner cases and makes
tcp_xmit_size_goal() a bit faster.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")
---
 net/ipv4/tcp.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9d72a0fcd928..995a2259bcfc 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -835,17 +835,13 @@ static unsigned int tcp_xmit_size_goal(struct sock *sk, u32 mss_now,
 				       int large_allowed)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	u32 new_size_goal, size_goal, hlen;
+	u32 new_size_goal, size_goal;
 
 	if (!large_allowed || !sk_can_gso(sk))
 		return mss_now;
 
-	/* Maybe we should/could use sk->sk_prot->max_header here ? */
-	hlen = inet_csk(sk)->icsk_af_ops->net_header_len +
-	       inet_csk(sk)->icsk_ext_hdr_len +
-	       tp->tcp_header_len;
-
-	new_size_goal = sk->sk_gso_max_size - 1 - hlen;
+	/* Note : tcp_tso_autosize() will eventually split this later */
+	new_size_goal = sk->sk_gso_max_size - 1 - MAX_TCP_HEADER;
 	new_size_goal = tcp_bound_to_half_wnd(tp, new_size_goal);
 
 	/* We try hard to avoid divides here */
