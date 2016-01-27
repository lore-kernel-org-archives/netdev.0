From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: beware of alignments in tcp_get_info()
Date: Wed, 27 Jan 2016 10:52:43 -0800
Message-ID: <1453920763.20722.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36857 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934715AbcA0Swp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 13:52:45 -0500
Received: by mail-pf0-f176.google.com with SMTP id n128so9016908pfn.3
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 10:52:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

With some combinations of user provided flags in netlink command,
it is possible to call tcp_get_info() with a buffer that is not 8-bytes
aligned.

It does matter on some arches, so we need to use put_unaligned() to
store the u64 fields.

Current iproute2 package does not trigger this particular issue.

Fixes: 0df48c26d841 ("tcp: add tcpi_bytes_acked to tcp_info")
Fixes: 977cb0ecf82e ("tcp: add pacing_rate information into tcp_info")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index fd17eec93525..19746b3fcbbe 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,6 +279,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
+#include <asm/unaligned.h>
 #include <net/busy_poll.h>
 
 int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
@@ -2638,6 +2639,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
 	unsigned int start;
+	u64 rate64;
 	u32 rate;
 
 	memset(info, 0, sizeof(*info));
@@ -2703,15 +2705,17 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_total_retrans = tp->total_retrans;
 
 	rate = READ_ONCE(sk->sk_pacing_rate);
-	info->tcpi_pacing_rate = rate != ~0U ? rate : ~0ULL;
+	rate64 = rate != ~0U ? rate : ~0ULL;
+	put_unaligned(rate64, &info->tcpi_pacing_rate);
 
 	rate = READ_ONCE(sk->sk_max_pacing_rate);
-	info->tcpi_max_pacing_rate = rate != ~0U ? rate : ~0ULL;
+	rate64 = rate != ~0U ? rate : ~0ULL;
+	put_unaligned(rate64, &info->tcpi_max_pacing_rate);
 
 	do {
 		start = u64_stats_fetch_begin_irq(&tp->syncp);
-		info->tcpi_bytes_acked = tp->bytes_acked;
-		info->tcpi_bytes_received = tp->bytes_received;
+		put_unaligned(tp->bytes_acked, &info->tcpi_bytes_acked);
+		put_unaligned(tp->bytes_received, &info->tcpi_bytes_received);
 	} while (u64_stats_fetch_retry_irq(&tp->syncp, start));
 	info->tcpi_segs_out = tp->segs_out;
 	info->tcpi_segs_in = tp->segs_in;
