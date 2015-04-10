From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: get rid of central timewait timer
Date: Fri, 10 Apr 2015 12:19:34 -0700
Message-ID: <1428693574.25985.326.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:36564 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752861AbbDJTTh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:19:37 -0400
Received: by iebrs15 with SMTP id rs15so25199745ieb.3
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 12:19:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using a timer wheel for timewait sockets was nice ~15 years ago when
memory was expensive and machines had a single processor.

This does not scale, code is ugly and source of huge latencies
(Typically 30 ms have been seen, cpus spinning on death_lock spinlock.)

We can afford to use an extra 64 bytes per timewait sock and spread
timewait load to all cpus to have better behavior.

Tested:

On following test, /proc/sys/net/ipv4/tcp_tw_recycle is set to 1
on the target (lpaa24)

Before patch :

lpaa23:~# ./super_netperf 200 -H lpaa24 -t TCP_CC -l 60 -- -p0,0
419594

lpaa23:~# ./super_netperf 200 -H lpaa24 -t TCP_CC -l 60 -- -p0,0
437171

While test is running, we can observe 25 or even 33 ms latencies.

lpaa24:~# ping -c 1000 -i 0.02 -qn lpaa23
PING lpaa23.prod.google.com (10.246.7.151) 56(84) bytes of data.

--- lpaa23.prod.google.com ping statistics ---
1000 packets transmitted, 1000 received, 0% packet loss, time 20601ms
rtt min/avg/max/mdev = 0.020/0.217/25.771/1.535 ms, pipe 2
lpaa24:~# ping -c 1000 -i 0.02 -qn lpaa23
PING lpaa23.prod.google.com (10.246.7.151) 56(84) bytes of data.

--- lpaa23.prod.google.com ping statistics ---
1000 packets transmitted, 1000 received, 0% packet loss, time 20702ms
rtt min/avg/max/mdev = 0.019/0.183/33.761/1.441 ms, pipe 2

After patch :

About 90% increase of throughput :

lpaa23:~# ./super_netperf 200 -H lpaa24 -t TCP_CC -l 60 -- -p0,0
810442

lpaa23:~# ./super_netperf 200 -H lpaa24 -t TCP_CC -l 60 -- -p0,0
800992


And latencies are kept to minimal values during this load, even
if network utilization is 90% higher :

lpaa24:~# ping -c 1000 -i 0.02 -qn lpaa23
PING lpaa23.prod.google.com (10.246.7.151) 56(84) bytes of data.

--- lpaa23.prod.google.com ping statistics ---
1000 packets transmitted, 1000 received, 0% packet loss, time 19991ms
rtt min/avg/max/mdev = 0.023/0.064/0.360/0.042 ms


Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_timewait_sock.h |  101 -----------
 net/dccp/minisocks.c             |   16 -
 net/ipv4/inet_diag.c             |    4 
 net/ipv4/inet_hashtables.c       |    4 
 net/ipv4/inet_timewait_sock.c    |  262 +++--------------------------
 net/ipv4/proc.c                  |    2 
 net/ipv4/tcp_ipv4.c              |    4 
 net/ipv4/tcp_minisocks.c         |   20 --
 net/ipv6/inet6_hashtables.c      |    2 
 net/ipv6/tcp_ipv6.c              |    4 
 net/netfilter/xt_TPROXY.c        |    4 
 11 files changed, 56 insertions(+), 367 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index b7ce1003c429..717879c089db 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -31,67 +31,14 @@
 
 struct inet_hashinfo;
 
-#define INET_TWDR_RECYCLE_SLOTS_LOG	5
-#define INET_TWDR_RECYCLE_SLOTS		(1 << INET_TWDR_RECYCLE_SLOTS_LOG)
-
-/*
- * If time > 4sec, it is "slow" path, no recycling is required,
- * so that we select tick to get range about 4 seconds.
- */
-#if HZ <= 16 || HZ > 4096
-# error Unsupported: HZ <= 16 or HZ > 4096
-#elif HZ <= 32
-# define INET_TWDR_RECYCLE_TICK (5 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 64
-# define INET_TWDR_RECYCLE_TICK (6 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 128
-# define INET_TWDR_RECYCLE_TICK (7 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 256
-# define INET_TWDR_RECYCLE_TICK (8 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 512
-# define INET_TWDR_RECYCLE_TICK (9 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 1024
-# define INET_TWDR_RECYCLE_TICK (10 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#elif HZ <= 2048
-# define INET_TWDR_RECYCLE_TICK (11 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#else
-# define INET_TWDR_RECYCLE_TICK (12 + 2 - INET_TWDR_RECYCLE_SLOTS_LOG)
-#endif
-
-static inline u32 inet_tw_time_stamp(void)
-{
-	return jiffies;
-}
-
-/* TIME_WAIT reaping mechanism. */
-#define INET_TWDR_TWKILL_SLOTS	8 /* Please keep this a power of 2. */
-
-#define INET_TWDR_TWKILL_QUOTA 100
-
 struct inet_timewait_death_row {
-	/* Short-time timewait calendar */
-	int			twcal_hand;
-	unsigned long		twcal_jiffie;
-	struct timer_list	twcal_timer;
-	struct hlist_head	twcal_row[INET_TWDR_RECYCLE_SLOTS];
-
-	spinlock_t		death_lock;
-	int			tw_count;
-	int			period;
-	u32			thread_slots;
-	struct work_struct	twkill_work;
-	struct timer_list	tw_timer;
-	int			slot;
-	struct hlist_head	cells[INET_TWDR_TWKILL_SLOTS];
-	struct inet_hashinfo 	*hashinfo;
+	atomic_t		tw_count;
+
+	struct inet_hashinfo 	*hashinfo ____cacheline_aligned_in_smp;
 	int			sysctl_tw_recycle;
 	int			sysctl_max_tw_buckets;
 };
 
-void inet_twdr_hangman(unsigned long data);
-void inet_twdr_twkill_work(struct work_struct *work);
-void inet_twdr_twcal_tick(unsigned long data);
-
 struct inet_bind_bucket;
 
 /*
@@ -139,46 +86,12 @@ struct inet_timewait_sock {
 				tw_pad		: 2,	/* 2 bits hole */
 				tw_tos		: 8;
 	kmemcheck_bitfield_end(flags);
-	u32			tw_ttd;
+	struct timer_list	tw_timer;
 	struct inet_bind_bucket	*tw_tb;
-	struct hlist_node	tw_death_node;
+	struct inet_timewait_death_row *tw_dr;
 };
 #define tw_tclass tw_tos
 
-static inline int inet_twsk_dead_hashed(const struct inet_timewait_sock *tw)
-{
-	return !hlist_unhashed(&tw->tw_death_node);
-}
-
-static inline void inet_twsk_dead_node_init(struct inet_timewait_sock *tw)
-{
-	tw->tw_death_node.pprev = NULL;
-}
-
-static inline void __inet_twsk_del_dead_node(struct inet_timewait_sock *tw)
-{
-	__hlist_del(&tw->tw_death_node);
-	inet_twsk_dead_node_init(tw);
-}
-
-static inline int inet_twsk_del_dead_node(struct inet_timewait_sock *tw)
-{
-	if (inet_twsk_dead_hashed(tw)) {
-		__inet_twsk_del_dead_node(tw);
-		return 1;
-	}
-	return 0;
-}
-
-#define inet_twsk_for_each(tw, node, head) \
-	hlist_nulls_for_each_entry(tw, node, head, tw_node)
-
-#define inet_twsk_for_each_inmate(tw, jail) \
-	hlist_for_each_entry(tw, jail, tw_death_node)
-
-#define inet_twsk_for_each_inmate_safe(tw, safe, jail) \
-	hlist_for_each_entry_safe(tw, safe, jail, tw_death_node)
-
 static inline struct inet_timewait_sock *inet_twsk(const struct sock *sk)
 {
 	return (struct inet_timewait_sock *)sk;
@@ -193,6 +106,7 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 			  struct inet_hashinfo *hashinfo);
 
 struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
+					   struct inet_timewait_death_row *dr,
 					   const int state);
 
 void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
@@ -201,8 +115,7 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 void inet_twsk_schedule(struct inet_timewait_sock *tw,
 			struct inet_timewait_death_row *twdr,
 			const int timeo, const int timewait_len);
-void inet_twsk_deschedule(struct inet_timewait_sock *tw,
-			  struct inet_timewait_death_row *twdr);
+void inet_twsk_deschedule(struct inet_timewait_sock *tw);
 
 void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 		     struct inet_timewait_death_row *twdr, int family);
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 332f7d6d9942..f1163164a85a 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -27,28 +27,16 @@
 
 struct inet_timewait_death_row dccp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
-	.period		= DCCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
-	.death_lock	= __SPIN_LOCK_UNLOCKED(dccp_death_row.death_lock),
 	.hashinfo	= &dccp_hashinfo,
-	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
-					    (unsigned long)&dccp_death_row),
-	.twkill_work	= __WORK_INITIALIZER(dccp_death_row.twkill_work,
-					     inet_twdr_twkill_work),
-/* Short-time timewait calendar */
-
-	.twcal_hand	= -1,
-	.twcal_timer	= TIMER_INITIALIZER(inet_twdr_twcal_tick, 0,
-					    (unsigned long)&dccp_death_row),
 };
 
 EXPORT_SYMBOL_GPL(dccp_death_row);
 
 void dccp_time_wait(struct sock *sk, int state, int timeo)
 {
-	struct inet_timewait_sock *tw = NULL;
+	struct inet_timewait_sock *tw;
 
-	if (dccp_death_row.tw_count < dccp_death_row.sysctl_max_tw_buckets)
-		tw = inet_twsk_alloc(sk, state);
+	tw = inet_twsk_alloc(sk, &dccp_death_row, state);
 
 	if (tw != NULL) {
 		const struct inet_connection_sock *icsk = inet_csk(sk);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 76322c9867d5..70e8b3c308ec 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -248,7 +248,7 @@ static int inet_twsk_diag_fill(struct sock *sk,
 	struct inet_timewait_sock *tw = inet_twsk(sk);
 	struct inet_diag_msg *r;
 	struct nlmsghdr *nlh;
-	s32 tmo;
+	long tmo;
 
 	nlh = nlmsg_put(skb, portid, seq, unlh->nlmsg_type, sizeof(*r),
 			nlmsg_flags);
@@ -258,7 +258,7 @@ static int inet_twsk_diag_fill(struct sock *sk,
 	r = nlmsg_data(nlh);
 	BUG_ON(tw->tw_state != TCP_TIME_WAIT);
 
-	tmo = tw->tw_ttd - inet_tw_time_stamp();
+	tmo = tw->tw_timer.expires - jiffies;
 	if (tmo < 0)
 		tmo = 0;
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index d4630bf2d9aa..c6fb80bd5826 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -388,7 +388,7 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 		*twp = tw;
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw, death_row);
+		inet_twsk_deschedule(tw);
 
 		inet_twsk_put(tw);
 	}
@@ -565,7 +565,7 @@ ok:
 		spin_unlock(&head->lock);
 
 		if (tw) {
-			inet_twsk_deschedule(tw, death_row);
+			inet_twsk_deschedule(tw);
 			while (twrefcnt) {
 				twrefcnt--;
 				inet_twsk_put(tw);
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 118f0f195820..531d8804c8cd 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -67,9 +67,9 @@ int inet_twsk_bind_unhash(struct inet_timewait_sock *tw,
 }
 
 /* Must be called with locally disabled BHs. */
-static void __inet_twsk_kill(struct inet_timewait_sock *tw,
-			     struct inet_hashinfo *hashinfo)
+static void inet_twsk_kill(struct inet_timewait_sock *tw)
 {
+	struct inet_hashinfo *hashinfo = tw->tw_dr->hashinfo;
 	struct inet_bind_hashbucket *bhead;
 	int refcnt;
 	/* Unlink from established hashes. */
@@ -89,6 +89,8 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
 
 	BUG_ON(refcnt >= atomic_read(&tw->tw_refcnt));
 	atomic_sub(refcnt, &tw->tw_refcnt);
+	atomic_dec(&tw->tw_dr->tw_count);
+	inet_twsk_put(tw);
 }
 
 void inet_twsk_free(struct inet_timewait_sock *tw)
@@ -168,16 +170,31 @@ void __inet_twsk_hashdance(struct inet_timewait_sock *tw, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(__inet_twsk_hashdance);
 
-struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int state)
+void tw_timer_handler(unsigned long data)
 {
-	struct inet_timewait_sock *tw =
-		kmem_cache_alloc(sk->sk_prot_creator->twsk_prot->twsk_slab,
-				 GFP_ATOMIC);
+	struct inet_timewait_sock *tw = (struct inet_timewait_sock *)data;
+
+	NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITED); /* TW */
+	inet_twsk_kill(tw);
+}
+
+struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk,
+					   struct inet_timewait_death_row *dr,
+					   const int state)
+{
+	struct inet_timewait_sock *tw;
+
+	if (atomic_read(&dr->tw_count) >= dr->sysctl_max_tw_buckets)
+		return NULL;
+
+	tw = kmem_cache_alloc(sk->sk_prot_creator->twsk_prot->twsk_slab,
+			      GFP_ATOMIC);
 	if (tw) {
 		const struct inet_sock *inet = inet_sk(sk);
 
 		kmemcheck_annotate_bitfield(tw, flags);
 
+		tw->tw_dr	    = dr;
 		/* Give us an identity. */
 		tw->tw_daddr	    = inet->inet_daddr;
 		tw->tw_rcv_saddr    = inet->inet_rcv_saddr;
@@ -196,13 +213,14 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_prot	    = sk->sk_prot_creator;
 		atomic64_set(&tw->tw_cookie, atomic64_read(&sk->sk_cookie));
 		twsk_net_set(tw, sock_net(sk));
+		setup_timer(&tw->tw_timer, tw_timer_handler, (unsigned long)tw);
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
 		 * to a non null value before everything is setup for this
 		 * timewait socket.
 		 */
 		atomic_set(&tw->tw_refcnt, 0);
-		inet_twsk_dead_node_init(tw);
+
 		__module_get(tw->tw_prot->owner);
 	}
 
@@ -210,129 +228,15 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 }
 EXPORT_SYMBOL_GPL(inet_twsk_alloc);
 
-/* Returns non-zero if quota exceeded.  */
-static int inet_twdr_do_twkill_work(struct inet_timewait_death_row *twdr,
-				    const int slot)
-{
-	struct inet_timewait_sock *tw;
-	unsigned int killed;
-	int ret;
-
-	/* NOTE: compare this to previous version where lock
-	 * was released after detaching chain. It was racy,
-	 * because tw buckets are scheduled in not serialized context
-	 * in 2.3 (with netfilter), and with softnet it is common, because
-	 * soft irqs are not sequenced.
-	 */
-	killed = 0;
-	ret = 0;
-rescan:
-	inet_twsk_for_each_inmate(tw, &twdr->cells[slot]) {
-		__inet_twsk_del_dead_node(tw);
-		spin_unlock(&twdr->death_lock);
-		__inet_twsk_kill(tw, twdr->hashinfo);
-#ifdef CONFIG_NET_NS
-		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITED);
-#endif
-		inet_twsk_put(tw);
-		killed++;
-		spin_lock(&twdr->death_lock);
-		if (killed > INET_TWDR_TWKILL_QUOTA) {
-			ret = 1;
-			break;
-		}
-
-		/* While we dropped twdr->death_lock, another cpu may have
-		 * killed off the next TW bucket in the list, therefore
-		 * do a fresh re-read of the hlist head node with the
-		 * lock reacquired.  We still use the hlist traversal
-		 * macro in order to get the prefetches.
-		 */
-		goto rescan;
-	}
-
-	twdr->tw_count -= killed;
-#ifndef CONFIG_NET_NS
-	NET_ADD_STATS_BH(&init_net, LINUX_MIB_TIMEWAITED, killed);
-#endif
-	return ret;
-}
-
-void inet_twdr_hangman(unsigned long data)
-{
-	struct inet_timewait_death_row *twdr;
-	unsigned int need_timer;
-
-	twdr = (struct inet_timewait_death_row *)data;
-	spin_lock(&twdr->death_lock);
-
-	if (twdr->tw_count == 0)
-		goto out;
-
-	need_timer = 0;
-	if (inet_twdr_do_twkill_work(twdr, twdr->slot)) {
-		twdr->thread_slots |= (1 << twdr->slot);
-		schedule_work(&twdr->twkill_work);
-		need_timer = 1;
-	} else {
-		/* We purged the entire slot, anything left?  */
-		if (twdr->tw_count)
-			need_timer = 1;
-		twdr->slot = ((twdr->slot + 1) & (INET_TWDR_TWKILL_SLOTS - 1));
-	}
-	if (need_timer)
-		mod_timer(&twdr->tw_timer, jiffies + twdr->period);
-out:
-	spin_unlock(&twdr->death_lock);
-}
-EXPORT_SYMBOL_GPL(inet_twdr_hangman);
-
-void inet_twdr_twkill_work(struct work_struct *work)
-{
-	struct inet_timewait_death_row *twdr =
-		container_of(work, struct inet_timewait_death_row, twkill_work);
-	int i;
-
-	BUILD_BUG_ON((INET_TWDR_TWKILL_SLOTS - 1) >
-			(sizeof(twdr->thread_slots) * 8));
-
-	while (twdr->thread_slots) {
-		spin_lock_bh(&twdr->death_lock);
-		for (i = 0; i < INET_TWDR_TWKILL_SLOTS; i++) {
-			if (!(twdr->thread_slots & (1 << i)))
-				continue;
-
-			while (inet_twdr_do_twkill_work(twdr, i) != 0) {
-				if (need_resched()) {
-					spin_unlock_bh(&twdr->death_lock);
-					schedule();
-					spin_lock_bh(&twdr->death_lock);
-				}
-			}
-
-			twdr->thread_slots &= ~(1 << i);
-		}
-		spin_unlock_bh(&twdr->death_lock);
-	}
-}
-EXPORT_SYMBOL_GPL(inet_twdr_twkill_work);
-
 /* These are always called from BH context.  See callers in
  * tcp_input.c to verify this.
  */
 
 /* This is for handling early-kills of TIME_WAIT sockets. */
-void inet_twsk_deschedule(struct inet_timewait_sock *tw,
-			  struct inet_timewait_death_row *twdr)
+void inet_twsk_deschedule(struct inet_timewait_sock *tw)
 {
-	spin_lock(&twdr->death_lock);
-	if (inet_twsk_del_dead_node(tw)) {
-		inet_twsk_put(tw);
-		if (--twdr->tw_count == 0)
-			del_timer(&twdr->tw_timer);
-	}
-	spin_unlock(&twdr->death_lock);
-	__inet_twsk_kill(tw, twdr->hashinfo);
+	if (del_timer_sync(&tw->tw_timer))
+		inet_twsk_kill(tw);
 }
 EXPORT_SYMBOL(inet_twsk_deschedule);
 
@@ -340,9 +244,6 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
 		       struct inet_timewait_death_row *twdr,
 		       const int timeo, const int timewait_len)
 {
-	struct hlist_head *list;
-	int slot;
-
 	/* timeout := RTO * 3.5
 	 *
 	 * 3.5 = 1+2+0.5 to wait for two retransmits.
@@ -367,115 +268,14 @@ void inet_twsk_schedule(struct inet_timewait_sock *tw,
 	 * is greater than TS tick!) and detect old duplicates with help
 	 * of PAWS.
 	 */
-	slot = (timeo + (1 << INET_TWDR_RECYCLE_TICK) - 1) >> INET_TWDR_RECYCLE_TICK;
 
-	spin_lock(&twdr->death_lock);
-
-	/* Unlink it, if it was scheduled */
-	if (inet_twsk_del_dead_node(tw))
-		twdr->tw_count--;
-	else
+	if (!mod_timer_pinned(&tw->tw_timer, jiffies + timeo)) {
 		atomic_inc(&tw->tw_refcnt);
-
-	if (slot >= INET_TWDR_RECYCLE_SLOTS) {
-		/* Schedule to slow timer */
-		if (timeo >= timewait_len) {
-			slot = INET_TWDR_TWKILL_SLOTS - 1;
-		} else {
-			slot = DIV_ROUND_UP(timeo, twdr->period);
-			if (slot >= INET_TWDR_TWKILL_SLOTS)
-				slot = INET_TWDR_TWKILL_SLOTS - 1;
-		}
-		tw->tw_ttd = inet_tw_time_stamp() + timeo;
-		slot = (twdr->slot + slot) & (INET_TWDR_TWKILL_SLOTS - 1);
-		list = &twdr->cells[slot];
-	} else {
-		tw->tw_ttd = inet_tw_time_stamp() + (slot << INET_TWDR_RECYCLE_TICK);
-
-		if (twdr->twcal_hand < 0) {
-			twdr->twcal_hand = 0;
-			twdr->twcal_jiffie = jiffies;
-			twdr->twcal_timer.expires = twdr->twcal_jiffie +
-					      (slot << INET_TWDR_RECYCLE_TICK);
-			add_timer(&twdr->twcal_timer);
-		} else {
-			if (time_after(twdr->twcal_timer.expires,
-				       jiffies + (slot << INET_TWDR_RECYCLE_TICK)))
-				mod_timer(&twdr->twcal_timer,
-					  jiffies + (slot << INET_TWDR_RECYCLE_TICK));
-			slot = (twdr->twcal_hand + slot) & (INET_TWDR_RECYCLE_SLOTS - 1);
-		}
-		list = &twdr->twcal_row[slot];
+		atomic_inc(&twdr->tw_count);
 	}
-
-	hlist_add_head(&tw->tw_death_node, list);
-
-	if (twdr->tw_count++ == 0)
-		mod_timer(&twdr->tw_timer, jiffies + twdr->period);
-	spin_unlock(&twdr->death_lock);
 }
 EXPORT_SYMBOL_GPL(inet_twsk_schedule);
 
-void inet_twdr_twcal_tick(unsigned long data)
-{
-	struct inet_timewait_death_row *twdr;
-	int n, slot;
-	unsigned long j;
-	unsigned long now = jiffies;
-	int killed = 0;
-	int adv = 0;
-
-	twdr = (struct inet_timewait_death_row *)data;
-
-	spin_lock(&twdr->death_lock);
-	if (twdr->twcal_hand < 0)
-		goto out;
-
-	slot = twdr->twcal_hand;
-	j = twdr->twcal_jiffie;
-
-	for (n = 0; n < INET_TWDR_RECYCLE_SLOTS; n++) {
-		if (time_before_eq(j, now)) {
-			struct hlist_node *safe;
-			struct inet_timewait_sock *tw;
-
-			inet_twsk_for_each_inmate_safe(tw, safe,
-						       &twdr->twcal_row[slot]) {
-				__inet_twsk_del_dead_node(tw);
-				__inet_twsk_kill(tw, twdr->hashinfo);
-#ifdef CONFIG_NET_NS
-				NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITKILLED);
-#endif
-				inet_twsk_put(tw);
-				killed++;
-			}
-		} else {
-			if (!adv) {
-				adv = 1;
-				twdr->twcal_jiffie = j;
-				twdr->twcal_hand = slot;
-			}
-
-			if (!hlist_empty(&twdr->twcal_row[slot])) {
-				mod_timer(&twdr->twcal_timer, j);
-				goto out;
-			}
-		}
-		j += 1 << INET_TWDR_RECYCLE_TICK;
-		slot = (slot + 1) & (INET_TWDR_RECYCLE_SLOTS - 1);
-	}
-	twdr->twcal_hand = -1;
-
-out:
-	if ((twdr->tw_count -= killed) == 0)
-		del_timer(&twdr->tw_timer);
-#ifndef CONFIG_NET_NS
-	NET_ADD_STATS_BH(&init_net, LINUX_MIB_TIMEWAITKILLED, killed);
-#endif
-	spin_unlock(&twdr->death_lock);
-}
-EXPORT_SYMBOL_GPL(inet_twdr_twcal_tick);
-
 void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 		     struct inet_timewait_death_row *twdr, int family)
 {
@@ -509,7 +309,7 @@ restart:
 
 			rcu_read_unlock();
 			local_bh_disable();
-			inet_twsk_deschedule(tw, twdr);
+			inet_twsk_deschedule(tw);
 			local_bh_enable();
 			inet_twsk_put(tw);
 			goto restart_rcu;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index d8953ef0770c..e1f3b911dd1e 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -63,7 +63,7 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 	socket_seq_show(seq);
 	seq_printf(seq, "TCP: inuse %d orphan %d tw %d alloc %d mem %ld\n",
 		   sock_prot_inuse_get(net, &tcp_prot), orphans,
-		   tcp_death_row.tw_count, sockets,
+		   atomic_read(&tcp_death_row.tw_count), sockets,
 		   proto_memory_allocated(&tcp_prot));
 	seq_printf(seq, "UDP: inuse %d mem %ld\n",
 		   sock_prot_inuse_get(net, &udp_prot),
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 37578d52897e..3571f2be4470 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1685,7 +1685,7 @@ do_time_wait:
 							iph->daddr, th->dest,
 							inet_iif(skb));
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_deschedule(inet_twsk(sk));
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
 			goto process;
@@ -2242,9 +2242,9 @@ static void get_tcp4_sock(struct sock *sk, struct seq_file *f, int i)
 static void get_timewait4_sock(const struct inet_timewait_sock *tw,
 			       struct seq_file *f, int i)
 {
+	long delta = tw->tw_timer.expires - jiffies;
 	__be32 dest, src;
 	__u16 destp, srcp;
-	s32 delta = tw->tw_ttd - inet_tw_time_stamp();
 
 	dest  = tw->tw_daddr;
 	src   = tw->tw_rcv_saddr;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2088fdcca141..a6c067f0e10c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -34,18 +34,7 @@ int sysctl_tcp_abort_on_overflow __read_mostly;
 
 struct inet_timewait_death_row tcp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
-	.period		= TCP_TIMEWAIT_LEN / INET_TWDR_TWKILL_SLOTS,
-	.death_lock	= __SPIN_LOCK_UNLOCKED(tcp_death_row.death_lock),
 	.hashinfo	= &tcp_hashinfo,
-	.tw_timer	= TIMER_INITIALIZER(inet_twdr_hangman, 0,
-					    (unsigned long)&tcp_death_row),
-	.twkill_work	= __WORK_INITIALIZER(tcp_death_row.twkill_work,
-					     inet_twdr_twkill_work),
-/* Short-time timewait calendar */
-
-	.twcal_hand	= -1,
-	.twcal_timer	= TIMER_INITIALIZER(inet_twdr_twcal_tick, 0,
-					    (unsigned long)&tcp_death_row),
 };
 EXPORT_SYMBOL_GPL(tcp_death_row);
 
@@ -158,7 +147,7 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		if (!th->fin ||
 		    TCP_SKB_CB(skb)->end_seq != tcptw->tw_rcv_nxt + 1) {
 kill_with_rst:
-			inet_twsk_deschedule(tw, &tcp_death_row);
+			inet_twsk_deschedule(tw);
 			inet_twsk_put(tw);
 			return TCP_TW_RST;
 		}
@@ -211,7 +200,7 @@ kill_with_rst:
 			 */
 			if (sysctl_tcp_rfc1337 == 0) {
 kill:
-				inet_twsk_deschedule(tw, &tcp_death_row);
+				inet_twsk_deschedule(tw);
 				inet_twsk_put(tw);
 				return TCP_TW_SUCCESS;
 			}
@@ -283,16 +272,15 @@ EXPORT_SYMBOL(tcp_timewait_state_process);
  */
 void tcp_time_wait(struct sock *sk, int state, int timeo)
 {
-	struct inet_timewait_sock *tw = NULL;
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	const struct tcp_sock *tp = tcp_sk(sk);
+	struct inet_timewait_sock *tw;
 	bool recycle_ok = false;
 
 	if (tcp_death_row.sysctl_tw_recycle && tp->rx_opt.ts_recent_stamp)
 		recycle_ok = tcp_remember_stamp(sk);
 
-	if (tcp_death_row.tw_count < tcp_death_row.sysctl_max_tw_buckets)
-		tw = inet_twsk_alloc(sk, state);
+	tw = inet_twsk_alloc(sk, &tcp_death_row.tw_count, state);
 
 	if (tw) {
 		struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 033f17816ef4..871641bc1ed4 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -246,7 +246,7 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 		*twp = tw;
 	} else if (tw) {
 		/* Silly. Should hash-dance instead... */
-		inet_twsk_deschedule(tw, death_row);
+		inet_twsk_deschedule(tw);
 
 		inet_twsk_put(tw);
 	}
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f73a97f6e68e..ad51df85aa00 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1486,7 +1486,7 @@ do_time_wait:
 					    ntohs(th->dest), tcp_v6_iif(skb));
 		if (sk2) {
 			struct inet_timewait_sock *tw = inet_twsk(sk);
-			inet_twsk_deschedule(tw, &tcp_death_row);
+			inet_twsk_deschedule(tw);
 			inet_twsk_put(tw);
 			sk = sk2;
 			tcp_v6_restore_cb(skb);
@@ -1728,9 +1728,9 @@ static void get_tcp6_sock(struct seq_file *seq, struct sock *sp, int i)
 static void get_timewait6_sock(struct seq_file *seq,
 			       struct inet_timewait_sock *tw, int i)
 {
+	long delta = tw->tw_timer.expires - jiffies;
 	const struct in6_addr *dest, *src;
 	__u16 destp, srcp;
-	s32 delta = tw->tw_ttd - inet_tw_time_stamp();
 
 	dest = &tw->tw_v6_daddr;
 	src  = &tw->tw_v6_rcv_saddr;
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index c205b26a2bee..cca96cec1b68 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -272,7 +272,7 @@ tproxy_handle_time_wait4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 					    hp->source, lport ? lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_deschedule(inet_twsk(sk));
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
 		}
@@ -437,7 +437,7 @@ tproxy_handle_time_wait6(struct sk_buff *skb, int tproto, int thoff,
 					    tgi->lport ? tgi->lport : hp->dest,
 					    skb->dev, NFT_LOOKUP_LISTENER);
 		if (sk2) {
-			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_deschedule(inet_twsk(sk));
 			inet_twsk_put(inet_twsk(sk));
 			sk = sk2;
 		}
