From: Natale Patriciello <natale.patriciello@gmail.com>
Subject: [RFC PATCH v2 1/5] tcp: Added a function to retrieve pacing timer
Date: Sat, 14 Oct 2017 13:47:10 +0200
Message-ID: <20171014114714.3694-2-natale.patriciello@gmail.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Natale Patriciello <natale.patriciello@gmail.com>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:44720 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753178AbdJNLtt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 07:49:49 -0400
Received: by mail-wm0-f68.google.com with SMTP id 196so30680966wma.1
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 04:49:48 -0700 (PDT)
In-Reply-To: <20171014114714.3694-1-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow congestion control modules to set a custom pacing time between
the transmission of segments.
Moreover, it is assumed that the time returned by the congestion module
in the past is firm, until the timer expires; therefore, do not re-start
the timer if it is already active.

Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
---
 include/net/tcp.h     |  2 ++
 net/ipv4/tcp_output.c | 36 +++++++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 89974c5286d8..42c7aa96c4cf 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1015,6 +1015,8 @@ struct tcp_congestion_ops {
 	/* get info for inet_diag (optional) */
 	size_t (*get_info)(struct sock *sk, u32 ext, int *attr,
 			   union tcp_cc_info *info);
+	/* get the expiration time for the pacing timer (optional) */
+	u64 (*get_pacing_time)(struct sock *sk);
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0bc9e46a5369..ec5977156c26 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -950,22 +950,36 @@ static bool tcp_needs_internal_pacing(const struct sock *sk)
 	return smp_load_acquire(&sk->sk_pacing_status) == SK_PACING_NEEDED;
 }
 
+static bool tcp_pacing_timer_check(const struct sock *sk)
+{
+	return hrtimer_active(&tcp_sk(sk)->pacing_timer);
+}
+
 static void tcp_internal_pacing(struct sock *sk, const struct sk_buff *skb)
 {
+	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
 	u64 len_ns;
-	u32 rate;
 
 	if (!tcp_needs_internal_pacing(sk))
 		return;
-	rate = sk->sk_pacing_rate;
-	if (!rate || rate == ~0U)
-		return;
-
-	/* Should account for header sizes as sch_fq does,
-	 * but lets make things simple.
-	 */
-	len_ns = (u64)skb->len * NSEC_PER_SEC;
-	do_div(len_ns, rate);
+
+	if (ca_ops && ca_ops->get_pacing_time) {
+		if (tcp_pacing_timer_check(sk))
+			return;
+
+		len_ns = ca_ops->get_pacing_time(sk);
+	} else {
+		u32 rate = sk->sk_pacing_rate;
+
+		if (!rate || rate == ~0U)
+			return;
+
+		/* Should account for header sizes as sch_fq does,
+		 * but lets make things simple.
+		 */
+		len_ns = (u64)skb->len * NSEC_PER_SEC;
+		do_div(len_ns, rate);
+	}
 	hrtimer_start(&tcp_sk(sk)->pacing_timer,
 		      ktime_add_ns(ktime_get(), len_ns),
 		      HRTIMER_MODE_ABS_PINNED);
@@ -2123,7 +2137,7 @@ static int tcp_mtu_probe(struct sock *sk)
 static bool tcp_pacing_check(const struct sock *sk)
 {
 	return tcp_needs_internal_pacing(sk) &&
-	       hrtimer_active(&tcp_sk(sk)->pacing_timer);
+		tcp_pacing_timer_check(sk);
 }
 
 /* TCP Small Queues :
-- 
2.14.2
