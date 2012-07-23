From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] tcp: avoid oops in tcp_metrics and reset tcpm_stamp
Date: Mon, 23 Jul 2012 10:46:38 +0300
Message-ID: <1343029598-4975-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57071 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753926Ab2GWHjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2012 03:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	In tcp_tw_remember_stamp we incorrectly checked tw
instead of tm, it can lead to oops if the cached entry is
not found.

	tcpm_stamp was not updated in tcpm_check_stamp when
tcpm_suck_dst was called, move the update into tcpm_suck_dst,
so that we do not call it infinitely on every next cache hit
after TCP_METRICS_TIMEOUT.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/tcp_metrics.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 992f1bf..2288a63 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -107,6 +107,8 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
 {
 	u32 val;
 
+	tm->tcpm_stamp = jiffies;
+
 	val = 0;
 	if (dst_metric_locked(dst, RTAX_RTT))
 		val |= 1 << TCP_METRIC_RTT;
@@ -158,7 +160,6 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 			goto out_unlock;
 	}
 	tm->tcpm_addr = *addr;
-	tm->tcpm_stamp = jiffies;
 
 	tcpm_suck_dst(tm, dst);
 
@@ -621,7 +622,7 @@ bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
 
 	rcu_read_lock();
 	tm = __tcp_get_metrics_tw(tw);
-	if (tw) {
+	if (tm) {
 		const struct tcp_timewait_sock *tcptw;
 		struct sock *sk = (struct sock *) tw;
 
-- 
1.7.3.4
