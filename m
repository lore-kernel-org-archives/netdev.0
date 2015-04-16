From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: tcp_get_info() should fetch socket fields once
Date: Thu, 16 Apr 2015 16:12:28 -0700
Message-ID: <1429225948.7346.232.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33314 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbDPXM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:12:29 -0400
Received: by igbpi8 with SMTP id pi8so18216717igb.0
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 16:12:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_get_info() can be called without holding socket lock,
so any socket fields can change under us.

Use READ_ONCE() to fetch sk_pacing_rate and sk_max_pacing_rate

Fixes: 977cb0ecf82e ("tcp: add pacing_rate information into tcp_info")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
David, I do not think this needs stable backport, this is a quite
minor bug. I've added the 'Fixes' tag for reference only.

 net/ipv4/tcp.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 18e3a12eb1b2..59c8a027721b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2595,6 +2595,7 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
+	u32 rate;
 
 	memset(info, 0, sizeof(*info));
 
@@ -2655,10 +2656,11 @@ void tcp_get_info(const struct sock *sk, struct tcp_info *info)
 
 	info->tcpi_total_retrans = tp->total_retrans;
 
-	info->tcpi_pacing_rate = sk->sk_pacing_rate != ~0U ?
-					sk->sk_pacing_rate : ~0ULL;
-	info->tcpi_max_pacing_rate = sk->sk_max_pacing_rate != ~0U ?
-					sk->sk_max_pacing_rate : ~0ULL;
+	rate = READ_ONCE(sk->sk_pacing_rate);
+	info->tcpi_pacing_rate = rate != ~0U ? rate : ~0ULL;
+
+	rate = READ_ONCE(sk->sk_max_pacing_rate);
+	info->tcpi_max_pacing_rate = rate != ~0U ? rate : ~0ULL;
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
