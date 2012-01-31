From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 14:05:22 -0800
Message-ID: <20120131220521.GA1505@dev3310.snc6.facebook.com>
References: <1328040546.8012.6.camel@joe2Laptop>
 <4F285310.5060104@fb.com>
 <1328043341.8702.3.camel@joe2Laptop>
 <20120131.161535.422381201029777577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, asharma@fb.com, bhelgaas@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	glommer@parallels.com, mingo@elte.hu, christoph.paasch@uclouvain.be
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120131.161535.422381201029777577.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2012 at 04:15:35PM -0500, David Miller wrote:
> > 
> > shrug. That isn't currently used and 
> > tcp_too_many_orphans and tcp_out_of_memory
> > could still be checked.
> > 
> > I think the routine could be moved out-of-line.
> 
> Indeed, and make the out-of-line combined routine (that does the test
> as well as the conditional logging) return a boolean that determines
> if the "if (too_many_orphans || out_of_socket_memory)" test should
> pass.

Updated patch below. No change in the size of .text
.rodata is a bit larger.

 -Arun

>From f4a973dfbc9c624c9b93d2662f77eeae04e84497 Mon Sep 17 00:00:00 2001
From: Arun Sharma <asharma@fb.com>
Date: Mon, 30 Jan 2012 14:16:06 -0800
Subject: [PATCH] net: Disambiguate kernel message

Some of our machines were reporting:

TCP: too many of orphaned sockets

even when the number of orphaned sockets was well below the
limit.

We print a different message depending on whether we're out
of TCP memory or there are too many orphaned sockets.

Also move the check out of line and cleanup the messages
that were printed.

Signed-off-by: Arun Sharma <asharma@fb.com>
Suggested-by: Mohan Srinivasan <mohan@fb.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Joe Perches <joe@perches.com>
---
 include/net/tcp.h    |   14 ++++++++++----
 net/ipv4/tcp.c       |   19 +++++++++++++++----
 net/ipv4/tcp_timer.c |    5 +----
 3 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..9e158f1 100644
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
@@ -283,13 +291,11 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 		if (orphans << shift > sysctl_tcp_max_orphans)
 			return true;
 	}
-
-	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
-		return true;
 	return false;
 }
 
+extern bool tcp_check_oom(struct sock *sk, int shift);
+
 /* syncookies: remember time of last synqueue overflow */
 static inline void tcp_synq_overflow(struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..5c1cb35 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1876,6 +1876,20 @@ void tcp_shutdown(struct sock *sk, int how)
 }
 EXPORT_SYMBOL(tcp_shutdown);
 
+bool tcp_check_oom(struct sock *sk, int shift)
+{
+	bool too_many_orphans, out_of_socket_memory;
+
+	too_many_orphans = tcp_too_many_orphans(sk, shift);
+	out_of_socket_memory = tcp_out_of_memory(sk);
+
+	if (too_many_orphans && net_ratelimit())
+		pr_info("TCP: too many orphaned sockets\n");
+	if (out_of_socket_memory && net_ratelimit())
+		pr_info("TCP: out of memory -- consider tuning tcp_mem\n");
+	return too_many_orphans || out_of_socket_memory;
+}
+
 void tcp_close(struct sock *sk, long timeout)
 {
 	struct sk_buff *skb;
@@ -2015,10 +2029,7 @@ adjudge_to_death:
 	}
 	if (sk->sk_state != TCP_CLOSE) {
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, 0)) {
-			if (net_ratelimit())
-				printk(KERN_INFO "TCP: too many of orphaned "
-				       "sockets\n");
+		if (tcp_check_oom(sk, 0)) {
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			NET_INC_STATS_BH(sock_net(sk),
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a516d1e..cd2e072 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -77,10 +77,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 	if (sk->sk_err_soft)
 		shift++;
 
-	if (tcp_too_many_orphans(sk, shift)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "Out of socket memory\n");
-
+	if (tcp_check_oom(sk, shift)) {
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
 		if ((s32)(tcp_time_stamp - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
-- 
1.7.4
