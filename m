From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v2 2/5] tcp: implemented pacing_expired
Date: Sat, 14 Oct 2017 13:47:11 +0200
Message-ID: <20171014114714.3694-3-natale.patriciello@gmail.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34990 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753184AbdJNLtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 07:49:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id y44so2182590wry.2
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 04:49:49 -0700 (PDT)
In-Reply-To: <20171014114714.3694-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inform the congestion control that the pacing timer, previously set,
has expired. The commit does not consider situations in which another
kind of timer has expired (e.g., a tail loss probe, a retransmission
timer...)

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
---
 include/net/tcp.h     | 2 ++
 net/ipv4/tcp_output.c | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 42c7aa96c4cf..e817f0669d0e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1017,6 +1017,8 @@ struct tcp_congestion_ops {
 			   union tcp_cc_info *info);
 	/* get the expiration time for the pacing timer (optional) */
 	u64 (*get_pacing_time)(struct sock *sk);
+	/* the pacing timer is expired (optional) */
+	void (*pacing_timer_expired)(struct sock *sk);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ec5977156c26..25b4cf0802f2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2241,6 +2241,7 @@ void tcp_chrono_stop(struct sock *sk, const enum tcp_chrono type)
 static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 			   int push_one, gfp_t gfp)
 {
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *skb;
 	unsigned int tso_segs, sent_pkts;
@@ -2263,6 +2264,11 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 
 	max_segs = tcp_tso_segs(sk, mss_now);
 	tcp_mstamp_refresh(tp);
+
+	if (!tcp_pacing_timer_check(sk) &&
+	    ca_ops && ca_ops->pacing_timer_expired)
+		ca_ops->pacing_timer_expired(sk);
+
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
-- 
2.14.2
