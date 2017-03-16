From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: tcp_get_info() should read tcp_time_stamp later
Date: Thu, 16 Mar 2017 15:43:19 -0700
Message-ID: <1489704199.28631.262.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36385 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdCPWnW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:43:22 -0400
Received: by mail-it0-f65.google.com with SMTP id u69so892767ita.3
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 15:43:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Commit b369e7fd41f7 ("tcp: make TCP_INFO more consistent") moved
lock_sock_fast() earlier in tcp_get_info()

This has the minor effect that jiffies value being sampled at the
beginning of tcp_get_info() is more likely to be off by one, and we
report big tcpi_last_data_sent values (like 0xFFFFFFFF).

Since we lock the socket, fetching tcp_time_stamp right before
doing the jiffies_to_msecs() calls is enough to remove these
wrong values.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cf4555581282c608f920254078264e36e18584c6..1e319a525d51b0b603a5ccc5143381c752b9f2c7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2770,7 +2770,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
 	const struct tcp_sock *tp = tcp_sk(sk); /* iff sk_type == SOCK_STREAM */
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	u32 now = tcp_time_stamp, intv;
+	u32 now, intv;
 	u64 rate64;
 	bool slow;
 	u32 rate;
@@ -2839,6 +2839,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_retrans = tp->retrans_out;
 	info->tcpi_fackets = tp->fackets_out;
 
+	now = tcp_time_stamp;
 	info->tcpi_last_data_sent = jiffies_to_msecs(now - tp->lsndtime);
 	info->tcpi_last_data_recv = jiffies_to_msecs(now - icsk->icsk_ack.lrcvtime);
 	info->tcpi_last_ack_recv = jiffies_to_msecs(now - tp->rcv_tstamp);
