From: David Miller <davem@davemloft.net>
Subject: [PATCH 07/16] tcp: Remove tw->tw_peer
Date: Tue, 10 Jul 2012 08:07:29 -0700 (PDT)
Message-ID: <20120710.080729.1055309331548852318.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754685Ab2GJPHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 11:07:30 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C000758662D
	for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 08:07:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No longer used.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/tcp.h      |    1 -
 net/ipv4/tcp_minisocks.c |   16 ++--------------
 2 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 7d3bced..2de9cf4 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -506,7 +506,6 @@ struct tcp_timewait_sock {
 	u32			  tw_rcv_wnd;
 	u32			  tw_ts_recent;
 	long			  tw_ts_recent_stamp;
-	struct inet_peer	  *tw_peer;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	  *tw_md5_key;
 #endif
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index a51aa53..6560886 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -267,12 +267,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
 	bool recycle_ok = false;
-	bool recycle_on = false;
 
-	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp) {
+	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
-		recycle_on = true;
-	}
 
 	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
 		tw = inet_twsk_alloc(sk, state);
@@ -281,7 +278,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 		const int rto = (icsk->icsk_rto << 2) - (icsk->icsk_rto >> 1);
 		struct inet_sock *inet = inet_sk(sk);
-		struct inet_peer *peer = NULL;
 
 		tw->tw_transparent	= inet->transparent;
 		tw->tw_rcv_wscale	= tp->rx_opt.rcv_wscale;
@@ -305,12 +301,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		}
 #endif
 
-		if (recycle_on)
-			peer = icsk->icsk_af_ops->get_peer(sk);
-		tcptw->tw_peer = peer;
-		if (peer)
-			atomic_inc(&peer->refcnt);
-
 #ifdef CONFIG_TCP_MD5SIG
 		/*
 		 * The timewait bucket does not have the key DB from the
@@ -362,11 +352,9 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 
 void tcp_twsk_destructor(struct sock *sk)
 {
+#ifdef CONFIG_TCP_MD5SIG
 	struct tcp_timewait_sock *twsk = tcp_twsk(sk);
 
-	if (twsk->tw_peer)
-		inet_putpeer(twsk->tw_peer);
-#ifdef CONFIG_TCP_MD5SIG
 	if (twsk->tw_md5_key) {
 		tcp_free_md5sig_pool();
 		kfree_rcu(twsk->tw_md5_key, rcu);
-- 
1.7.10.4
