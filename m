From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v2 4/5] tcp: added segment sent
Date: Sat, 14 Oct 2017 13:47:13 +0200
Message-ID: <20171014114714.3694-5-natale.patriciello@gmail.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33772 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753291AbdJNLtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 07:49:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id z96so2188019wrb.0
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 04:49:52 -0700 (PDT)
In-Reply-To: <20171014114714.3694-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inform the congestion control of the number of segment sent in normal
conditions, it means segments that left the node without involving
recovery or retransmission procedures.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_output.c | 10 +++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3561eca5a61f..aebe225ab8b1 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1021,6 +1021,8 @@ struct tcp_congestion_ops {
 	void (*pacing_timer_expired)(struct sock *sk);
 	/* get the # segs to send out when the timer expires (optional) */
 	u32 (*get_segs_per_round)(struct sock *sk);
+	/* the TCP has sent some segments (optional) */
+	void (*segments_sent)(struct sock *sk, u32 sent);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e37941e4328b..ef50202659da 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2250,6 +2250,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	bool is_cwnd_limited = false, is_rwnd_limited = false;
 	u32 max_segs;
 	u32 pacing_allowed_segs = 0;
+	bool notify = false;
 
 	sent_pkts = 0;
 
@@ -2268,8 +2269,12 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 	if (!tcp_pacing_timer_check(sk)) {
 		pacing_allowed_segs = 1;
-		if (ca_ops && ca_ops->pacing_timer_expired)
+
+		if (ca_ops && ca_ops->pacing_timer_expired) {
 			ca_ops->pacing_timer_expired(sk);
+			notify = true;
+		}
+
 		if (ca_ops && ca_ops->get_segs_per_round)
 			pacing_allowed_segs = ca_ops->get_segs_per_round(sk);
 	}
@@ -2348,6 +2353,9 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			break;
 	}
 
+	if (ca_ops && notify && ca_ops->segments_sent)
+		ca_ops->segments_sent(sk, sent_pkts);
+
 	if (is_rwnd_limited)
 		tcp_chrono_start(sk, TCP_CHRONO_RWND_LIMITED);
 	else
-- 
2.14.2
