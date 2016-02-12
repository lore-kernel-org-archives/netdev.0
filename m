From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: add tcpi_min_rtt and tcpi_notsent_bytes to
 tcp_info
Date: Thu, 11 Feb 2016 22:02:53 -0800
Message-ID: <1455256973.18740.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34276 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbcBLGCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 01:02:54 -0500
Received: by mail-wm0-f54.google.com with SMTP id 128so48662033wmz.1
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 22:02:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcpi_min_rtt reports the minimal rtt observed by TCP stack for the flow,
in usec unit. Might be ~0U if not yet known.

tcpi_notsent_bytes reports the amount of bytes in the write queue that
were not yet sent.

This is done in a single patch to not add a temporary 32bit padding hole
in tcp_info.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/tcp.h |    3 +++
 net/ipv4/tcp.c           |    6 ++++++
 2 files changed, 9 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 65a77b071e22..fe95446e9abf 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -196,6 +196,9 @@ struct tcp_info {
 	__u64	tcpi_bytes_received; /* RFC4898 tcpEStatsAppHCThruOctetsReceived */
 	__u32	tcpi_segs_out;	     /* RFC4898 tcpEStatsPerfSegsOut */
 	__u32	tcpi_segs_in;	     /* RFC4898 tcpEStatsPerfSegsIn */
+
+	__u32	tcpi_notsent_bytes;
+	__u32	tcpi_min_rtt;
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 014f18e2f7b3..f93150d15199 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2642,6 +2642,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 now = tcp_time_stamp;
 	unsigned int start;
+	int notsent_bytes;
 	u64 rate64;
 	u32 rate;
 
@@ -2722,6 +2723,11 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	} while (u64_stats_fetch_retry_irq(&tp->syncp, start));
 	info->tcpi_segs_out = tp->segs_out;
 	info->tcpi_segs_in = tp->segs_in;
+
+	notsent_bytes = READ_ONCE(tp->write_seq) - READ_ONCE(tp->snd_nxt);
+	info->tcpi_notsent_bytes = max(0, notsent_bytes);
+
+	info->tcpi_min_rtt = tcp_min_rtt(tp);
 }
 EXPORT_SYMBOL_GPL(tcp_get_info);
 
