From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 6/8] tcp: tcp_mtu_probe() is likely to exit early
Date: Sat,  3 Dec 2016 11:14:55 -0800
Message-ID: <1480792497-16607-7-git-send-email-edumazet@google.com>
References: <1480792497-16607-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32978 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcLCTQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 14:16:28 -0500
Received: by mail-pg0-f50.google.com with SMTP id 3so120162113pgd.0
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 11:15:14 -0800 (PST)
In-Reply-To: <1480792497-16607-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a likely() in tcp_mtu_probe() moves its code which used to
be inlined in front of tcp_write_xmit()

We still have a cache line miss to access icsk->icsk_mtup.enabled,
we will probably have to reorganize fields to help data locality.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d5c46749adab..5f04bee4c86a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1932,26 +1932,26 @@ static inline void tcp_mtu_check_reprobe(struct sock *sk)
  */
 static int tcp_mtu_probe(struct sock *sk)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb, *nskb, *next;
 	struct net *net = sock_net(sk);
-	int len;
 	int probe_size;
 	int size_needed;
-	int copy;
+	int copy, len;
 	int mss_now;
 	int interval;
 
 	/* Not currently probing/verifying,
 	 * not in recovery,
 	 * have enough cwnd, and
-	 * not SACKing (the variable headers throw things off) */
-	if (!icsk->icsk_mtup.enabled ||
-	    icsk->icsk_mtup.probe_size ||
-	    inet_csk(sk)->icsk_ca_state != TCP_CA_Open ||
-	    tp->snd_cwnd < 11 ||
-	    tp->rx_opt.num_sacks || tp->rx_opt.dsack)
+	 * not SACKing (the variable headers throw things off)
+	 */
+	if (likely(!icsk->icsk_mtup.enabled ||
+		   icsk->icsk_mtup.probe_size ||
+		   inet_csk(sk)->icsk_ca_state != TCP_CA_Open ||
+		   tp->snd_cwnd < 11 ||
+		   tp->rx_opt.num_sacks || tp->rx_opt.dsack))
 		return -1;
 
 	/* Use binary search for probe_size between tcp_mss_base,
-- 
2.8.0.rc3.226.g39d4020
