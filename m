From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next] tcp: temporarily disable Fast Open on SYN timeout
Date: Tue, 29 Oct 2013 10:09:05 -0700
Message-ID: <1383066545-27348-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:35390 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757850Ab3J2RJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 13:09:12 -0400
Received: by mail-pa0-f73.google.com with SMTP id kp14so44890pab.0
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 10:09:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fast Open currently has a fall back feature to address SYN-data
being dropped by but it requires the middle-box to pass on regular
SYN retry after SYN-data. This is implemented in commit aab487435
("net-tcp: Fast Open client - detecting SYN-data drops")

However some NAT boxes will drop all subsequent packets after first
SYN-data and blackholes the entire connections.  An example is incommit
356d7d8 "netfilter: nf_conntrack: fix tcp_in_window for Fast Open".

The sender should note such incidents and falls back to use regular
TCP handshake on subsequent attempt temporarily as well: after the
second SYN timeouts the original Fast Open SYN is most likely lost.
When such an event recurs Fast Open is disabled based on the number
of recurrences exponentially.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_metrics.c | 5 +++--
 net/ipv4/tcp_timer.c   | 6 +++++-
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 4a2a841..2ab09cb 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -671,8 +671,9 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
 
 		write_seqlock_bh(&fastopen_seqlock);
-		tfom->mss = mss;
-		if (cookie->len > 0)
+		if (mss)
+			tfom->mss = mss;
+		if (cookie && cookie->len > 0)
 			tfom->cookie = *cookie;
 		if (syn_lost) {
 			++tfom->syn_loss;
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index af07b5b..64f0354 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -156,12 +156,16 @@ static bool retransmits_timed_out(struct sock *sk,
 static int tcp_write_timeout(struct sock *sk)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_sock *tp = tcp_sk(sk);
 	int retry_until;
 	bool do_reset, syn_set = false;
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
-		if (icsk->icsk_retransmits)
+		if (icsk->icsk_retransmits) {
 			dst_negative_advice(sk);
+			if (tp->syn_fastopen || tp->syn_data)
+				tcp_fastopen_cache_set(sk, 0, NULL, true);
+		}
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 		syn_set = true;
 	} else {
-- 
1.8.4.1
