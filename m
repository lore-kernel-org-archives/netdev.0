From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: hang in ip_finish_output
Date: Sun, 17 Jan 2016 19:12:14 -0800
Message-ID: <1453086734.1223.215.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+bdpCR_rmiDAUi8ge3iecBOpaAat6S3o_GDjt-p2c53BA@mail.gmail.com>
	 <CAEfhGixTRfTviSiaiqYHPDxxz2af4Xbm198WuM1dR6BQKojPxQ@mail.gmail.com>
	 <1452929396.1223.202.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452929396.1223.202.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-01-15 at 23:29 -0800, Eric Dumazet wrote:
> On Fri, 2016-01-15 at 19:20 -0500, Craig Gallek wrote:
> 
> > I wasn't able to reproduce this exact stack trace, but I was able to
> > cause soft lockup messages with a fork bomb of your test program.  It
> > is certainly related to my recent SO_REUSEPORT change (reverting it
> > seems to fix the problem).  I haven't completely figured out the exact
> > cause yet, though.  Could you please post your configuration and
> > exactly how you are running this 'parallel loop'?
> 
> There is a problem in the lookup functions (udp4_lib_lookup2() &
> __udp4_lib_lookup())
> 
> Because of RCU SLAB_DESTROY_BY_RCU semantics (check
> Documentation/RCU/rculist_nulls.txt for some details), you should not
> call reuseport_select_sock(sk, ...) without taking a stable reference on
> the sk socket. (and checking the lookup keys again)
> 
> This is because sk could be freed, re-used by a totally different UDP
> socket on a different port, and the incoming frame(s) could be delivered
> on the wrong socket/channel/application :(
> 
> Note that we discussed some time ago to remove SLAB_DESTROY_BY_RCU for
> UDP sockets (and freeing them after rcu grace period instead), so make
> UDP rx path faster, as we would no longer need to increment/decrement
> the socket refcount. This also would remove the added false sharing on
> sk_refcnt for the case the UDP socket serves as a tunnel (up->encap_rcv
> being non NULL)

Hmm... not it looks you do the lookup , refcnt change, re-lookup just
fine.

The problem here is that UDP connected sockets update the
sk->sk_incoming_cpu from __udp_queue_rcv_skb()

This means that we can find the first socket in hash table with a
matching incoming cpu, and badness == high_score + 1

Then, the reuseport_select_sock() can selects another socket from the
array (using bpf or the hash )

We do the atomic_inc_not_zero_hint() to update sk_refcnt on the new
socket, then compute_score2() returns high_score (< badness)

So we loop back to the beginning of udp4_lib_lookup2(), and we loop
forever (as long as the first socket in hash table has still this match
about incoming cpu)

In short, the recent SO_REUSE_PORT changes are not compatible with the
SO_INCOMING_CPU ones, if connected UDP sockets are used.

A fix could be to not check sk_incoming_cpu on connected sockets (this
makes really little sense, as this option was meant to spread traffic on
UDP _servers_ ). Also it collides with SO_REUSEPORT notion of a group of
sockets having the same score.

Dmitry, could you test it ? I could not get the trace you reported.

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index dc45b538e237..f76cf0ec82b1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -413,6 +413,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		if (inet->inet_daddr != saddr)
 			return -1;
 		score += 4;
+	} else if (sk->sk_incoming_cpu == raw_smp_processor_id()) {
+		score++;
 	}
 
 	if (inet->inet_dport) {
@@ -426,8 +428,6 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
 	return score;
 }
 
@@ -457,6 +457,8 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		if (inet->inet_daddr != saddr)
 			return -1;
 		score += 4;
+	} else if (sk->sk_incoming_cpu == raw_smp_processor_id()) {
+		score++;
 	}
 
 	if (inet->inet_dport) {
@@ -470,10 +472,6 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 			return -1;
 		score += 4;
 	}
-
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
-
 	return score;
 }
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5d2c2afffe7b..0d87b1ded070 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -190,6 +190,8 @@ static inline int compute_score(struct sock *sk, struct net *net,
 		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
 			return -1;
 		score++;
+	} else if (sk->sk_incoming_cpu == raw_smp_processor_id()) {
+		score++;
 	}
 
 	if (sk->sk_bound_dev_if) {
@@ -197,10 +199,6 @@ static inline int compute_score(struct sock *sk, struct net *net,
 			return -1;
 		score++;
 	}
-
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
-
 	return score;
 }
 
@@ -233,6 +231,8 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 		if (!ipv6_addr_equal(&sk->sk_v6_daddr, saddr))
 			return -1;
 		score++;
+	} else if (sk->sk_incoming_cpu == raw_smp_processor_id()) {
+		score++;
 	}
 
 	if (sk->sk_bound_dev_if) {
@@ -240,10 +240,6 @@ static inline int compute_score2(struct sock *sk, struct net *net,
 			return -1;
 		score++;
 	}
-
-	if (sk->sk_incoming_cpu == raw_smp_processor_id())
-		score++;
-
 	return score;
 }
 
