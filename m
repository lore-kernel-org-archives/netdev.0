From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: do not scale TSO segment size with reordering degree
Date: Mon, 21 Nov 2011 22:15:14 -0500
Message-ID: <1321931714-28176-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f74.google.com ([209.85.161.74]:59528 "EHLO
	mail-fx0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300Ab1KVDPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 22:15:30 -0500
Received: by fabs1 with SMTP id s1so80fab.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 19:15:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 2005 (c1b4a7e69576d65efc31a8cea0714173c2841244)
tcp_tso_should_defer has been using tcp_max_burst() as a target limit
for deciding how large to make outgoing TSO packets when not using
sysctl_tcp_tso_win_divisor. But since 2008
(dd9e0dda66ba38a2ddd1405ac279894260dc5c36) tcp_max_burst() returns the
reordering degree. We should not have tcp_tso_should_defer attempt to
build larger segments just because there is more reordering. This
commit splits the notion of deferral size used in TSO from the notion
of burst size used in cwnd moderation, and returns the TSO deferral
limit to its original value.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/net/tcp.h     |    8 ++++++++
 net/ipv4/tcp_cong.c   |    2 +-
 net/ipv4/tcp_output.c |    2 +-
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 113160b..87e3c80 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -834,6 +834,14 @@ static inline __u32 tcp_current_ssthresh(const struct sock *sk)
 extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(const struct tcp_sock *tp, const struct dst_entry *dst);
 
+/* The maximum number of MSS of available cwnd for which TSO defers
+ * sending if not using sysctl_tcp_tso_win_divisor.
+ */
+static inline __u32 tcp_max_tso_deferred_mss(const struct tcp_sock *tp)
+{
+	return 3;
+}
+
 /* Slow start with delack produces 3 packets of burst, so that
  * it is safe "de facto".  This will be the default - same as
  * the default reordering threshold - but if reordering increases,
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 850c737..fc6d475 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -292,7 +292,7 @@ int tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
 	    left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
 	    left * tp->mss_cache < sk->sk_gso_max_size)
 		return 1;
-	return left <= tcp_max_burst(tp);
+	return left <= tcp_max_tso_deferred_mss(tp);
 }
 EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 63170e2..58f69ac 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1581,7 +1581,7 @@ static int tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 		 * frame, so if we have space for more than 3 frames
 		 * then send now.
 		 */
-		if (limit > tcp_max_burst(tp) * tp->mss_cache)
+		if (limit > tcp_max_tso_deferred_mss(tp) * tp->mss_cache)
 			goto send_now;
 	}
 
-- 
1.7.3.1
