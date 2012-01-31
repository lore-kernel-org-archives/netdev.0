From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 11:47:18 -0800
Message-ID: <20120131194718.GA9834@dev3310.snc6.facebook.com>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
 <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
 <20120131181554.GA24397@dev3310.snc6.facebook.com>
 <1328035857.6911.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun Sharma <asharma@fb.com>, Bjorn Helgaas <bhelgaas@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>, christoph.paasch@uclouvain.be
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1328035857.6911.8.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 31, 2012 at 10:50:57AM -0800, Joe Perches wrote:
> 
> These 2 blocks emit the messages in different order.
> 
> It might be useful to use a generic routine.

Refactored slightly differently below.

On 1/31/12 11:44 AM, Ingo Molnar wrote:

> A small detail: please don't line break user-visible strings in
> mid sentence. Just keep the line long. Makes it much easier to
> search for the source of a kernel message:
> 

pr_info() on a single line now.

>From 08f36b8fd9f2439001a4192c0d1ff390d13e67e0 Mon Sep 17 00:00:00 2001
From: Arun Sharma <asharma@fb.com>
Date: Mon, 30 Jan 2012 14:16:06 -0800
Subject: [PATCH] net: Disambiguate kernel message

Some of our machines were reporting:

TCP: too many of orphaned sockets

even when the number of orphaned sockets was well below the
limit.

We print a different message depending on whether we're out
of TCP memory or there are too many orphaned sockets.

Signed-off-by: Arun Sharma <asharma@fb.com>
Suggested-by: Mohan Srinivasan <mohan@fb.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: David Miller <davem@davemloft.net>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Ingo Molnar <mingo@elte.hu>
---
 include/net/tcp.h    |   20 ++++++++++++++++----
 net/ipv4/tcp.c       |   11 +++++++----
 net/ipv4/tcp_timer.c |    9 +++++----
 3 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0118ea9..0dba9d6 100644
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
@@ -283,13 +291,17 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 		if (orphans << shift > sysctl_tcp_max_orphans)
 			return true;
 	}
-
-	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-	    sk_memory_allocated(sk) > sk_prot_mem_limits(sk, 2))
-		return true;
 	return false;
 }
 
+static inline void tcp_log_oom(bool orphans, bool socket_memory)
+{
+	if (orphans && net_ratelimit())
+		pr_info("TCP: too many orphaned sockets\n");
+	if (socket_memory && net_ratelimit())
+		pr_info("TCP: out of memory -- consider tuning tcp_mem\n");
+}
+
 /* syncookies: remember time of last synqueue overflow */
 static inline void tcp_synq_overflow(struct sock *sk)
 {
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9bcdec3..9c38b3a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2014,11 +2014,14 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
+		bool too_many_orphans, out_of_socket_memory;
+
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, 0)) {
-			if (net_ratelimit())
-				printk(KERN_INFO "TCP: too many of orphaned "
-				       "sockets\n");
+		too_many_orphans = tcp_too_many_orphans(sk, 0);
+		out_of_socket_memory = tcp_out_of_memory(sk);
+		tcp_log_oom(too_many_orphans, out_of_socket_memory);
+
+		if (too_many_orphans || out_of_socket_memory) {
 			tcp_set_state(sk, TCP_CLOSE);
 			tcp_send_active_reset(sk, GFP_ATOMIC);
 			NET_INC_STATS_BH(sock_net(sk),
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index a516d1e..c47fcb6 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -67,6 +67,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int shift = 0;
+	bool too_many_orphans, out_of_socket_memory;
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
@@ -77,10 +78,10 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 	if (sk->sk_err_soft)
 		shift++;
 
-	if (tcp_too_many_orphans(sk, shift)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "Out of socket memory\n");
-
+	too_many_orphans = tcp_too_many_orphans(sk, shift);
+	out_of_socket_memory = tcp_out_of_memory(sk);
+	tcp_log_oom(too_many_orphans, out_of_socket_memory);
+	if (too_many_orphans || out_of_socket_memory) {
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
 		if ((s32)(tcp_time_stamp - tp->lsndtime) <= TCP_TIMEWAIT_LEN ||
-- 
1.7.4
