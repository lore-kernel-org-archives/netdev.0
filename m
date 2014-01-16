From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net v2] tcp: metrics: Avoid duplicate entries with the same destination-IP
Date: Thu, 16 Jan 2014 20:01:21 +0100
Message-ID: <1389898881-11393-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:38502 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaAPTBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 14:01:52 -0500
Received: by mail-ea0-f182.google.com with SMTP id r15so487492ead.27
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 11:01:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because the tcp-metrics is an RCU-list, it may be that two
soft-interrupts are inside __tcp_get_metrics() for the same
destination-IP at the same time. If this destination-IP is not yet part of
the tcp-metrics, both soft-interrupts will end up in tcpm_new and create
a new entry for this IP.
So, we will have two tcp-metrics with the same destination-IP in the list.

This patch checks twice __tcp_get_metrics(). First without holding the
lock, then while holding the lock. The second one is there to confirm
that the entry has not been added by another soft-irq while waiting for
the spin-lock.

Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---

v2: As requested by Eric D.: Check the cache twice. Once without holding the lock,
    and then again while holding the lock. That way we avoid taking the lock
    needlessly.

 net/ipv4/tcp_metrics.c | 51 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 32 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 06493736fbc8..098b3a29f6f3 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -22,6 +22,9 @@
 
 int sysctl_tcp_nometrics_save __read_mostly;
 
+static struct tcp_metrics_block *__tcp_get_metrics(const struct inetpeer_addr *addr,
+						   struct net *net, unsigned int hash);
+
 struct tcp_fastopen_metrics {
 	u16	mss;
 	u16	syn_loss:10;		/* Recurring Fast Open SYN losses */
@@ -130,16 +133,41 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst,
 	}
 }
 
+#define TCP_METRICS_TIMEOUT		(60 * 60 * HZ)
+
+static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst)
+{
+	if (tm && unlikely(time_after(jiffies, tm->tcpm_stamp + TCP_METRICS_TIMEOUT)))
+		tcpm_suck_dst(tm, dst, false);
+}
+
+#define TCP_METRICS_RECLAIM_DEPTH	5
+#define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
+
 static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 					  struct inetpeer_addr *addr,
-					  unsigned int hash,
-					  bool reclaim)
+					  unsigned int hash)
 {
 	struct tcp_metrics_block *tm;
 	struct net *net;
+	bool reclaim = false;
 
 	spin_lock_bh(&tcp_metrics_lock);
 	net = dev_net(dst->dev);
+
+	/* While waiting for the spin-lock the cache might have been populated
+	 * with this entry and so we have to check again.
+	 */
+	tm = __tcp_get_metrics(addr, net, hash);
+	if (tm == TCP_METRICS_RECLAIM_PTR) {
+		reclaim = true;
+		tm = NULL;
+	}
+	if (tm) {
+		tcpm_check_stamp(tm, dst);
+		goto out_unlock;
+	}
+
 	if (unlikely(reclaim)) {
 		struct tcp_metrics_block *oldest;
 
@@ -169,17 +197,6 @@ out_unlock:
 	return tm;
 }
 
-#define TCP_METRICS_TIMEOUT		(60 * 60 * HZ)
-
-static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst)
-{
-	if (tm && unlikely(time_after(jiffies, tm->tcpm_stamp + TCP_METRICS_TIMEOUT)))
-		tcpm_suck_dst(tm, dst, false);
-}
-
-#define TCP_METRICS_RECLAIM_DEPTH	5
-#define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
-
 static struct tcp_metrics_block *tcp_get_encode(struct tcp_metrics_block *tm, int depth)
 {
 	if (tm)
@@ -282,7 +299,6 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	struct inetpeer_addr addr;
 	unsigned int hash;
 	struct net *net;
-	bool reclaim;
 
 	addr.family = sk->sk_family;
 	switch (addr.family) {
@@ -304,13 +320,10 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
 	tm = __tcp_get_metrics(&addr, net, hash);
-	reclaim = false;
-	if (tm == TCP_METRICS_RECLAIM_PTR) {
-		reclaim = true;
+	if (tm == TCP_METRICS_RECLAIM_PTR)
 		tm = NULL;
-	}
 	if (!tm && create)
-		tm = tcpm_new(dst, &addr, hash, reclaim);
+		tm = tcpm_new(dst, &addr, hash);
 	else
 		tcpm_check_stamp(tm, dst);
 
-- 
1.8.3.2
