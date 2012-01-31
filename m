From: Arun Sharma <asharma@fb.com>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 10:15:54 -0800
Message-ID: <20120131181554.GA24397@dev3310.snc6.facebook.com>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
 <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun Sharma <asharma@fb.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	Ingo Molnar <mingo@elte.hu>, christoph.paasch@uclouvain.be
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 08:22:03PM -0800, Bjorn Helgaas wrote:
> > We print a different message depending on whether we're out
> > of TCP memory or there are too many orphan sockets.
> 
> This patch mentions pairs of messages that are almost the same, but
> not quite.  If they're supposed to be different, I'd suggest making
> them clearly different.  As it is, the differences look like careless
> mistakes:

Good point. Updated patch changes the existing printks to be
the same as well.

On 1/31/12 12:51 AM, Christoph Paasch wrote:

>> --- a/net/ipv4/tcp.c
>> +++ b/net/ipv4/tcp.c
>> @@ -2015,10 +2015,22 @@ adjudge_to_death:
>>   	}
>>   	if (sk->sk_state != TCP_CLOSE) {
>>   		sk_mem_reclaim(sk);
>> -		if (tcp_too_many_orphans(sk, 0)) {
>> +		bool too_many_orphans = tcp_too_many_orphans(sk, 0);
>> +		bool out_of_socket_memory = tcp_out_of_memory(sk);
> 
> This introduces a compiler warning because you have the declarations
> after the code (sk_mem_reclaim()):
> 

Fixed by the patch below.

 -Arun

>From 505717e51b15304b0bf50fc9dfed43fd06fad09a Mon Sep 17 00:00:00 2001
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
 include/net/tcp.h    |   12 ++++++++----
 net/ipv4/tcp.c       |   17 +++++++++++++++--
 net/ipv4/tcp_timer.c |   12 +++++++++---
 3 files changed, 32 insertions(+), 9 deletions(-)

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
index 9bcdec3..27de5e4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2014,11 +2014,24 @@ adjudge_to_death:
 		}
 	}
 	if (sk->sk_state != TCP_CLOSE) {
+		bool too_many_orphans, out_of_socket_memory;
+
 		sk_mem_reclaim(sk);
-		if (tcp_too_many_orphans(sk, 0)) {
+		too_many_orphans = tcp_too_many_orphans(sk, 0);
+		out_of_socket_memory = tcp_out_of_memory(sk);
+		if (too_many_orphans) {
 			if (net_ratelimit())
-				printk(KERN_INFO "TCP: too many of orphaned "
+				printk(KERN_INFO "TCP: too many orphaned "
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
index a516d1e..0ac006b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -67,6 +67,7 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int shift = 0;
+	bool too_many_orphans, out_of_socket_memory;
 
 	/* If peer does not open window for long time, or did not transmit
 	 * anything for long time, penalize it. */
@@ -77,9 +78,14 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 	if (sk->sk_err_soft)
 		shift++;
 
-	if (tcp_too_many_orphans(sk, shift)) {
-		if (net_ratelimit())
-			printk(KERN_INFO "Out of socket memory\n");
+	too_many_orphans = tcp_too_many_orphans(sk, shift);
+	out_of_socket_memory = tcp_out_of_memory(sk);
+	if (too_many_orphans || out_of_socket_memory) {
+		if (out_of_socket_memory && net_ratelimit())
+			printk(KERN_INFO "TCP: out of memory. "
+					 "Consider tuning tcp_mem\n");
+		if (too_many_orphans && net_ratelimit())
+			printk(KERN_INFO "TCP: too many orphaned sockets\n");
 
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
-- 
1.7.4
