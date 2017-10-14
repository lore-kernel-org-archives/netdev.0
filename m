From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v2 3/5] tcp: added get_segs_per_round
Date: Sat, 14 Oct 2017 13:47:12 +0200
Message-ID: <20171014114714.3694-4-natale.patriciello@gmail.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38289 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753178AbdJNLtv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 07:49:51 -0400
Received: by mail-wr0-f196.google.com with SMTP id v91so1264534wrc.5
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 04:49:50 -0700 (PDT)
In-Reply-To: <20171014114714.3694-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usually, the pacing time is provided per-segment. In some occasion, this
time refers to the time between a group of segments. With this commit, add
the possibility for the congestion control module to tell the TCP socket
how many segments can be sent out before pausing and setting a pacing
timer.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_output.c | 13 +++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e817f0669d0e..3561eca5a61f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1019,6 +1019,8 @@ struct tcp_congestion_ops {
 	u64 (*get_pacing_time)(struct sock *sk);
 	/* the pacing timer is expired (optional) */
 	void (*pacing_timer_expired)(struct sock *sk);
+	/* get the # segs to send out when the timer expires (optional) */
+	u32 (*get_segs_per_round)(struct sock *sk);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 25b4cf0802f2..e37941e4328b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2249,6 +2249,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	int result;
 	bool is_cwnd_limited = false, is_rwnd_limited = false;
 	u32 max_segs;
+	u32 pacing_allowed_segs = 0;
 
 	sent_pkts = 0;
 
@@ -2265,14 +2266,18 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	max_segs = tcp_tso_segs(sk, mss_now);
 	tcp_mstamp_refresh(tp);
 
-	if (!tcp_pacing_timer_check(sk) &&
-	    ca_ops && ca_ops->pacing_timer_expired)
-		ca_ops->pacing_timer_expired(sk);
+	if (!tcp_pacing_timer_check(sk)) {
+		pacing_allowed_segs = 1;
+		if (ca_ops && ca_ops->pacing_timer_expired)
+			ca_ops->pacing_timer_expired(sk);
+		if (ca_ops && ca_ops->get_segs_per_round)
+			pacing_allowed_segs = ca_ops->get_segs_per_round(sk);
+	}
 
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
-		if (tcp_pacing_check(sk))
+		if (sent_pkts >= pacing_allowed_segs)
 			break;
 
 		tso_segs = tcp_init_tso_segs(skb, mss_now);
-- 
2.14.2
