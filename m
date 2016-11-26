From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 5/6] tcp: export sender limits chronographs to TCP_INFO
Date: Sat, 26 Nov 2016 12:10:15 -0800
Message-ID: <1480191016-73210-6-git-send-email-ycheng@google.com>
References: <1480191016-73210-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:33018 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcKZUKk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 15:10:40 -0500
Received: by mail-io0-f179.google.com with SMTP id j65so171980343iof.0
        for <netdev@vger.kernel.org>; Sat, 26 Nov 2016 12:10:40 -0800 (PST)
In-Reply-To: <1480191016-73210-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francis Yan <francisyyan@gmail.com>

This patch exports all the sender chronograph measurements collected
in the previous patches to TCP_INFO interface. Note that busy time
exported includes all the other sending limits (rwnd-limited,
sndbuf-limited). Internally the time unit is jiffy but externally
the measurements are in microseconds for future extensions.

Signed-off-by: Francis Yan <francisyyan@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/uapi/linux/tcp.h |  4 ++++
 net/ipv4/tcp.c           | 20 ++++++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 73ac0db..2863b66 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -214,6 +214,10 @@ struct tcp_info {
 	__u32	tcpi_data_segs_out;	/* RFC4898 tcpEStatsDataSegsOut */
 
 	__u64   tcpi_delivery_rate;
+
+	__u64	tcpi_busy_time;      /* Time (usec) busy sending data */
+	__u64	tcpi_rwnd_limited;   /* Time (usec) limited by receive window */
+	__u64	tcpi_sndbuf_limited; /* Time (usec) limited by send buffer */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 259ffb5..cdde20f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2708,6 +2708,25 @@ int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
 EXPORT_SYMBOL(compat_tcp_setsockopt);
 #endif
 
+static void tcp_get_info_chrono_stats(const struct tcp_sock *tp,
+				      struct tcp_info *info)
+{
+	u64 stats[__TCP_CHRONO_MAX], total = 0;
+	enum tcp_chrono i;
+
+	for (i = TCP_CHRONO_BUSY; i < __TCP_CHRONO_MAX; ++i) {
+		stats[i] = tp->chrono_stat[i - 1];
+		if (i == tp->chrono_type)
+			stats[i] += tcp_time_stamp - tp->chrono_start;
+		stats[i] *= USEC_PER_SEC / HZ;
+		total += stats[i];
+	}
+
+	info->tcpi_busy_time = total;
+	info->tcpi_rwnd_limited = stats[TCP_CHRONO_RWND_LIMITED];
+	info->tcpi_sndbuf_limited = stats[TCP_CHRONO_SNDBUF_LIMITED];
+}
+
 /* Return information about state of tcp endpoint in API format. */
 void tcp_get_info(struct sock *sk, struct tcp_info *info)
 {
@@ -2800,6 +2819,7 @@ void tcp_get_info(struct sock *sk, struct tcp_info *info)
 	info->tcpi_bytes_acked = tp->bytes_acked;
 	info->tcpi_bytes_received = tp->bytes_received;
 	info->tcpi_notsent_bytes = max_t(int, 0, tp->write_seq - tp->snd_nxt);
+	tcp_get_info_chrono_stats(tp, info);
 
 	unlock_sock_fast(sk, slow);
 
-- 
2.8.0.rc3.226.g39d4020
