From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net 5/4] tcp: fix rcu usage around __sk_dst_get in tcp_update_metrics
Date: Fri,  1 Apr 2016 01:48:43 +0200
Message-ID: <1459468123-31474-1-git-send-email-hannes@stressinduktion.org>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Cc: netdev@vger.kernel.org, sasha.levin@oracle.com,
	daniel@iogearbox.net, alexei.starovoitov@gmail.com,
	mkubecek@suse.cz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60617 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757408AbcCaXsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 19:48:51 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 8DD2720807
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 19:48:50 -0400 (EDT)
In-Reply-To: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Already another one fix I overlooked.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/tcp_metrics.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 33a36648423e8b..196de79902819a 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -367,7 +367,7 @@ static struct tcp_metrics_block *tcp_get_metrics(struct sock *sk,
 void tcp_update_metrics(struct sock *sk)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct dst_entry *dst = __sk_dst_get(sk);
+	struct dst_entry *dst;
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct net *net = sock_net(sk);
 	struct tcp_metrics_block *tm;
@@ -375,13 +375,14 @@ void tcp_update_metrics(struct sock *sk)
 	u32 val;
 	int m;
 
+	rcu_read_lock();
+	dst = __sk_dst_get(sk);
 	if (sysctl_tcp_nometrics_save || !dst)
-		return;
+		goto out_unlock;
 
 	if (dst->flags & DST_HOST)
 		dst_confirm(dst);
 
-	rcu_read_lock();
 	if (icsk->icsk_backoff || !tp->srtt_us) {
 		/* This session failed to estimate rtt. Why?
 		 * Probably, no packets returned in time.  Reset our
-- 
2.5.5
