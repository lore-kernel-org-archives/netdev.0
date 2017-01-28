From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/2] tcp: record pkts sent and retransmistted
Date: Fri, 27 Jan 2017 16:24:38 -0800
Message-ID: <20170128002439.128487-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35333 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdA1AYt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 19:24:49 -0500
Received: by mail-pf0-f182.google.com with SMTP id f144so76636289pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 16:24:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two stats in SCM_TIMESTAMPING_OPT_STATS:

TCP_NLA_DATA_SEGS_OUT: total data packets sent including retransmission
TCP_NLA_TOTAL_RETRANS: total data packets retransmitted

The names are picked to be consistent with corresponding fields in
TCP_INFO. This allows applications that are using the timestamping
API to measure latency stats to also retrive retransmission rate
of application write.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/tcp.h | 2 ++
 net/ipv4/tcp.c           | 6 +++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 6ff35eb48d10..38a2b07afdff 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -227,6 +227,8 @@ enum {
 	TCP_NLA_BUSY,		/* Time (usec) busy sending data */
 	TCP_NLA_RWND_LIMITED,	/* Time (usec) limited by receive window */
 	TCP_NLA_SNDBUF_LIMITED,	/* Time (usec) limited by send buffer */
+	TCP_NLA_DATA_SEGS_OUT,	/* Data pkts sent including retransmission */
+	TCP_NLA_TOTAL_RETRANS,	/* Data pkts retransmitted */
 };
 
 /* for TCP_MD5SIG socket option */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2ed472ebf3b5..b751abc56935 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2870,7 +2870,7 @@ struct sk_buff *tcp_get_timestamping_opt_stats(const struct sock *sk)
 	struct sk_buff *stats;
 	struct tcp_info info;
 
-	stats = alloc_skb(3 * nla_total_size_64bit(sizeof(u64)), GFP_ATOMIC);
+	stats = alloc_skb(5 * nla_total_size_64bit(sizeof(u64)), GFP_ATOMIC);
 	if (!stats)
 		return NULL;
 
@@ -2881,6 +2881,10 @@ struct sk_buff *tcp_get_timestamping_opt_stats(const struct sock *sk)
 			  info.tcpi_rwnd_limited, TCP_NLA_PAD);
 	nla_put_u64_64bit(stats, TCP_NLA_SNDBUF_LIMITED,
 			  info.tcpi_sndbuf_limited, TCP_NLA_PAD);
+	nla_put_u64_64bit(stats, TCP_NLA_DATA_SEGS_OUT,
+			  tp->data_segs_out, TCP_NLA_PAD);
+	nla_put_u64_64bit(stats, TCP_NLA_TOTAL_RETRANS,
+			  tp->total_retrans, TCP_NLA_PAD);
 	return stats;
 }
 
-- 
2.11.0.483.g087da7b7c-goog
