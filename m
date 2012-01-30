From: Arun Sharma <asharma@fb.com>
Subject: [PATCH] net: Disambiguate kernel message
Date: Mon, 30 Jan 2012 14:41:44 -0800
Message-ID: <1327963304-24828-1-git-send-email-asharma@fb.com>
Cc: Arun Sharma <asharma@fb.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of our machines were reporting:

TCP: too many of orphaned sockets

even when the number of orphaned sockets was well below the
limit.

We print a different message depending on whether we're out
of TCP memory or there are too many orphan sockets.

Signed-off-by: Arun Sharma <asharma@fb.com>
Suggested-by: Mohan Srinivasan <mohan@fb.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/net/tcp.h    |   12 ++++++++----
 net/ipv4/tcp.c       |   14 +++++++++++++-
 net/ipv4/tcp_timer.c |    9 +++++++--
 3 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..92965dd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -273,6 +273,14 @@ static inline int between(__u32 seq1, __u32 seq2, __u32 seq3)
 	return seq3 - seq2 >= seq1 - seq2;
 }
 
+static inline bool tcp_out_of_memory(struct sock *sk)
+{
+	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
+	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
+		return true;
+	return false;
+}
+
 static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 {
 	struct percpu_counter *ocp = sk->sk_prot->orphan_count;
@@ -283,10 +291,6 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 		if (orphans << shift > sysctl_tcp_max_orphans)
 			return true;
 	}
-
-	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
-		return true;
 	return false;
 }
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..395a4ef 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2015,10 +2015,22 @@ adjudge_to_death:
 	}
 	if (sk->sk_state != TCP_CLOSE) {
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, 0)) {
+		bool too_many_orphans = tcp_too_many_orphans(sk, 0);
+		bool out_of_socket_memory = tcp_out_of_memory(sk);
+
+		if (too_many_orphans) {
 			if (net_ratelimit())
 				printk(KERN_INFO "TCP: too many of orphaned "
 				       "sockets\n");
+		}
+
+		if (out_of_socket_memory) {
+			if (net_ratelimit())
+				printk(KERN_INFO "TCP: out of memory. "
+				       "Consider tuning tcp_mem\n");
+		}
+
+		if (too_many_orphans || out_of_socket_memory) {
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			NET_INC_STATS_BH(sock_net(sk),
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a516d1e..89907c3 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -67,6 +67,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int shift = 0;
+	bool too_many_orphans, out_of_socket_memory;
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
@@ -77,9 +78,13 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 	if (sk->sk_err_soft)
 		shift++;
 
-	if (tcp_too_many_orphans(sk, shift)) {
-		if (net_ratelimit())
+	too_many_orphans = tcp_too_many_orphans(sk, shift);
+	out_of_socket_memory = tcp_out_of_memory(sk);
+	if (too_many_orphans || out_of_socket_memory) {
+		if (out_of_socket_memory && net_ratelimit())
 			printk(KERN_INFO "Out of socket memory\n");
+		if (too_many_orphans && net_ratelimit())
+			printk(KERN_INFO "TCP: too many orphaned sockets\n");
 
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
-- 
1.7.4
