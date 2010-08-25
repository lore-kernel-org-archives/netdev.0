From: David Miller <davem@davemloft.net>
Subject: Re: Spurious "TCP: too many of orphaned sockets", unable to
 allocate sockets
Date: Wed, 25 Aug 2010 01:20:58 -0700 (PDT)
Message-ID: <20100825.012058.116362511.davem@davemloft.net>
References: <20100825071626.GA13681@kryten>
	<20100825.005929.15250658.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miltonm@bga.com, eric.dumazet@gmail.com
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751838Ab0HYIUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 04:20:41 -0400
In-Reply-To: <20100825.005929.15250658.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 25 Aug 2010 00:59:29 -0700 (PDT)

> Solution seems simple, if the too many orphan check triggers, simply
> redo the check using the expensive but more accurate per-cpu counter
> read (which avoids the skew) to make sure.

Something like this:

tcp: Combat per-cpu skew in orphan tests.

As reported by Anton Blanchard when we use
percpu_counter_read_positive() to make our orphan socket limit checks,
the check can be off by up to num_cpus_online() * batch (which is 32
by default) which on a 128 cpu machine can be as large as the default
orphan limit itself.

Fix this by doing the full expensive sum check if the optimized check
triggers.

Reported-by: Anton Blanchard <anton@samba.org>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index df6a2eb..eaa9582 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -268,11 +268,21 @@ static inline int between(__u32 seq1, __u32 seq2, __u32 seq3)
 	return seq3 - seq2 >= seq1 - seq2;
 }
 
-static inline int tcp_too_many_orphans(struct sock *sk, int num)
+static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
 {
-	return (num > sysctl_tcp_max_orphans) ||
-		(sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
-		 atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2]);
+	struct percpu_counter *ocp = sk->sk_prot->orphan_count;
+	int orphans = percpu_counter_read_positive(ocp);
+
+	if (orphans << shift > sysctl_tcp_max_orphans) {
+		orphans = percpu_counter_sum_positive(ocp);
+		if (orphans << shift > sysctl_tcp_max_orphans)
+			return true;
+	}
+
+	if (sk->sk_wmem_queued > SOCK_MIN_SNDBUF &&
+	    atomic_read(&tcp_memory_allocated) > sysctl_tcp_mem[2])
+		return true;
+	return false;
 }
 
 /* syncookies: remember time of last synqueue overflow */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 176e11a..197b9b7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2011,11 +2011,8 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
-		int orphan_count = percpu_counter_read_positive(
-						sk->sk_prot->orphan_count);
-
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, orphan_count)) {
+		if (tcp_too_many_orphans(sk, 0)) {
 			if (net_ratelimit())
 				printk(KERN_INFO "TCP: too many of orphaned "
 				       "sockets\n");
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 808bb92..c35b469 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -66,18 +66,18 @@ static void tcp_write_err(struct sock *sk)
 static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	int orphans = percpu_counter_read_positive(&tcp_orphan_count);
+	int shift = 0;
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
 	if ((s32)(tcp_time_stamp - tp->lsndtime) > 2*TCP_RTO_MAX || !do_reset)
-		orphans <<= 1;
+		shift++;
 
 	/* If some dubious ICMP arrived, penalize even more. */
 	if (sk->sk_err_soft)
-		orphans <<= 1;
+		shift++;
 
-	if (tcp_too_many_orphans(sk, orphans)) {
+	if (tcp_too_many_orphans(sk, shift)) {
 		if (net_ratelimit())
 			printk(KERN_INFO "Out of socket memory\n");
 
