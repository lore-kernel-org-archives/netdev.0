From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: do not expire TCP fastopen cookies
Date: Fri, 03 May 2013 22:12:45 -0700
Message-ID: <1367644365.22983.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:32926 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751542Ab3EDFMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 May 2013 01:12:48 -0400
Received: by mail-pd0-f174.google.com with SMTP id u10so1221164pdi.33
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 22:12:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP metric cache expires entries after one hour.

This probably make sense for TCP RTT/RTTVAR/CWND, but not
for TCP fastopen cookies.

Its better to try previous cookie. If it appears to be obsolete,
server will send us new cookie anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_metrics.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index f696d7c..f6a005c 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -96,7 +96,8 @@ struct tcpm_hash_bucket {
 
 static DEFINE_SPINLOCK(tcp_metrics_lock);
 
-static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
+static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
+			  bool fastopen_clear)
 {
 	u32 val;
 
@@ -122,9 +123,11 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
 	tm->tcpm_vals[TCP_METRIC_REORDERING] = dst_metric_raw(dst, RTAX_REORDERING);
 	tm->tcpm_ts = 0;
 	tm->tcpm_ts_stamp = 0;
-	tm->tcpm_fastopen.mss = 0;
-	tm->tcpm_fastopen.syn_loss = 0;
-	tm->tcpm_fastopen.cookie.len = 0;
+	if (fastopen_clear) {
+		tm->tcpm_fastopen.mss = 0;
+		tm->tcpm_fastopen.syn_loss = 0;
+		tm->tcpm_fastopen.cookie.len = 0;
+	}
 }
 
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
@@ -154,7 +157,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	}
 	tm->tcpm_addr = *addr;
 
-	tcpm_suck_dst(tm, dst);
+	tcpm_suck_dst(tm, dst, true);
 
 	if (likely(!reclaim)) {
 		tm->tcpm_next = net->ipv4.tcp_metrics_hash[hash].chain;
@@ -171,7 +174,7 @@ out_unlock:
 static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst)
 {
 	if (tm && unlikely(time_after(jiffies, tm->tcpm_stamp + TCP_METRICS_TIMEOUT)))
-		tcpm_suck_dst(tm, dst);
+		tcpm_suck_dst(tm, dst, false);
 }
 
 #define TCP_METRICS_RECLAIM_DEPTH	5
