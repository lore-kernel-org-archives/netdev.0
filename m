From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [RFC net] tcp: metrics: Avoid duplicate entries with the same destination-IP
Date: Mon, 13 Jan 2014 16:25:36 +0100
Message-ID: <1389626736-3143-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:62290 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751655AbaAMPZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 10:25:45 -0500
Received: by mail-we0-f179.google.com with SMTP id w62so1471939wes.24
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 07:25:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: This patch is based on "net" and so the source-IP is not yet part
of the tcp-metrics.

Because the tcp-metrics is an RCU-list, it may be that two
soft-interrupts are inside __tcp_get_metrics() for the same
destination-IP at the same time. If this destination-IP is not yet part of
the tcp-metrics, both soft-interrupts will end up in tcpm_new and create
a new entry for this IP.
So, we will have two tcp-metrics with the same destination-IP in the list.

This patch now takes the tcp_metrics_lock before calling
__tcp_get_metrics().

I post this as an RFC, because this patch will make the TCP-stack take
the tcp_metrics_lock even if the metric is already in the cache.

I tested it with apache-benchmark on a short file with
ab -c 100 -n 100000 server/1KB
IMO this should stress the code most, but there was no significant
performance regression.

Another solution might be to leave tcp_get_metrics() as it is, and in
tcpm_new do another call to __tcp_get_metrics() while holding the
spin-lock. We would then check __tcp_get_metrics twice for new entries
but we won't hold the spin-lock needlessly anymore.

So, it's a tradeoff between taking the tcp_metrics_lock more often vs.
calling __tcp_get_metrics twice for new entries.

Suggestions are very welcome.

Fixes: 51c5d0c4b169b (tcp: Maintain dynamic metrics in local cache.)
Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 net/ipv4/tcp_metrics.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 06493736fbc8..7748a5d9f37a 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -138,7 +138,6 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	struct tcp_metrics_block *tm;
 	struct net *net;
 
-	spin_lock_bh(&tcp_metrics_lock);
 	net = dev_net(dst->dev);
 	if (unlikely(reclaim)) {
 		struct tcp_metrics_block *oldest;
@@ -153,7 +152,7 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 	} else {
 		tm = kmalloc(sizeof(*tm), GFP_ATOMIC);
 		if (!tm)
-			goto out_unlock;
+			return NULL;
 	}
 	tm->tcpm_addr = *addr;
 
@@ -164,8 +163,6 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
 		rcu_assign_pointer(net->ipv4.tcp_metrics_hash[hash].chain, tm);
 	}
 
-out_unlock:
-	spin_unlock_bh(&tcp_metrics_lock);
 	return tm;
 }
 
@@ -303,6 +300,8 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	net = dev_net(dst->dev);
 	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
 
+	spin_lock_bh(&tcp_metrics_lock);
+
 	tm = __tcp_get_metrics(&addr, net, hash);
 	reclaim = false;
 	if (tm == TCP_METRICS_RECLAIM_PTR) {
@@ -314,6 +313,8 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 	else
 		tcpm_check_stamp(tm, dst);
 
+	spin_unlock_bh(&tcp_metrics_lock);
+
 	return tm;
 }
 
-- 
1.8.3.2
