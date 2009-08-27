From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/14] pktgen: convert to use ktime_t
Date: Thu, 27 Aug 2009 16:55:16 -0700
Message-ID: <20090827235705.904783256@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58757 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015AbZH0X70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:26 -0400
Content-Disposition: inline; filename=pktgen-ktime.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel ktime_t is a nice generic infrastructure for mananging
high resolution times, as is done in pktgen.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |  185 ++++++++++++++++++++++++------------------------------
 1 file changed, 85 insertions(+), 100 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 12:04:15.087541783 -0700
+++ b/net/core/pktgen.c	2009-08-27 12:43:35.843546115 -0700
@@ -246,16 +246,14 @@ struct pktgen_dev {
 	int max_pkt_size;	/* = ETH_ZLEN; */
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
-	__u32 delay_us;		/* Default delay */
-	__u32 delay_ns;
+	u64 delay;		/* nano-seconds */
+
 	__u64 count;		/* Default No packets to send */
 	__u64 sofar;		/* How many pkts we've sent so far */
 	__u64 tx_bytes;		/* How many bytes we've transmitted */
 	__u64 errors;		/* Errors when trying to transmit, pkts will be re-sent */
 
 	/* runtime counters relating to clone_skb */
-	__u64 next_tx_us;	/* timestamp of when to tx next */
-	__u32 next_tx_ns;
 
 	__u64 allocated_skbs;
 	__u32 clone_count;
@@ -263,9 +261,11 @@ struct pktgen_dev {
 				 * Or a failed transmit of some sort?  This will keep
 				 * sequence numbers in order, for example.
 				 */
-	__u64 started_at;	/* micro-seconds */
-	__u64 stopped_at;	/* micro-seconds */
-	__u64 idle_acc;		/* micro-seconds */
+	ktime_t next_tx;
+	ktime_t started_at;
+	ktime_t stopped_at;
+	u64	idle_acc;	/* nano-seconds */
+
 	__u32 seq_num;
 
 	int clone_skb;		/* Use multiple SKBs during packet gen.  If this number
@@ -397,23 +397,20 @@ struct pktgen_thread {
 #define REMOVE 1
 #define FIND   0
 
-/** Convert to micro-seconds */
-static inline __u64 tv_to_us(const struct timeval *tv)
+static inline ktime_t ktime_now(void)
 {
-	__u64 us = tv->tv_usec;
-	us += (__u64) tv->tv_sec * (__u64) 1000000;
-	return us;
+	struct timespec ts;
+	ktime_get_ts(&ts);
+
+	return timespec_to_ktime(ts);
 }
 
-static __u64 getCurUs(void)
+/* This works even if 32 bit because of careful byte order choice */
+static inline int ktime_lt(const ktime_t cmp1, const ktime_t cmp2)
 {
-	struct timeval tv;
-	do_gettimeofday(&tv);
-	return tv_to_us(&tv);
+	return cmp1.tv64 < cmp2.tv64;
 }
 
-/* old include end */
-
 static const char version[] __initconst = VERSION;
 
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen_dev *i);
@@ -510,9 +507,8 @@ static const struct file_operations pktg
 static int pktgen_if_show(struct seq_file *seq, void *v)
 {
 	const struct pktgen_dev *pkt_dev = seq->private;
-	__u64 sa;
-	__u64 stopped;
-	__u64 now = getCurUs();
+	ktime_t stopped;
+	u64 idle;
 
 	seq_printf(seq,
 		   "Params: count %llu  min_pkt_size: %u  max_pkt_size: %u\n",
@@ -520,9 +516,8 @@ static int pktgen_if_show(struct seq_fil
 		   pkt_dev->max_pkt_size);
 
 	seq_printf(seq,
-		   "     frags: %d  delay: %u  clone_skb: %d  ifname: %s\n",
-		   pkt_dev->nfrags,
-		   1000 * pkt_dev->delay_us + pkt_dev->delay_ns,
+		   "     frags: %d  delay: %llu  clone_skb: %d  ifname: %s\n",
+		   pkt_dev->nfrags, (unsigned long long) pkt_dev->delay,
 		   pkt_dev->clone_skb, pkt_dev->odev->name);
 
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
@@ -654,17 +649,21 @@ static int pktgen_if_show(struct seq_fil
 
 	seq_puts(seq, "\n");
 
-	sa = pkt_dev->started_at;
-	stopped = pkt_dev->stopped_at;
-	if (pkt_dev->running)
-		stopped = now;	/* not really stopped, more like last-running-at */
+	/* not really stopped, more like last-running-at */
+	stopped = pkt_dev->running ? ktime_now() : pkt_dev->stopped_at;
+	idle = pkt_dev->idle_acc;
+	do_div(idle, NSEC_PER_USEC);
 
 	seq_printf(seq,
-		   "Current:\n     pkts-sofar: %llu  errors: %llu\n     started: %lluus  stopped: %lluus idle: %lluus\n",
+		   "Current:\n     pkts-sofar: %llu  errors: %llu\n",
 		   (unsigned long long)pkt_dev->sofar,
-		   (unsigned long long)pkt_dev->errors, (unsigned long long)sa,
-		   (unsigned long long)stopped,
-		   (unsigned long long)pkt_dev->idle_acc);
+		   (unsigned long long)pkt_dev->errors);
+
+	seq_printf(seq,
+		   "     started: %lluus  stopped: %lluus idle: %lluus\n",
+		   (unsigned long long) ktime_to_us(pkt_dev->started_at),
+		   (unsigned long long) ktime_to_us(stopped),
+		   (unsigned long long) idle);
 
 	seq_printf(seq,
 		   "     seq_num: %d  cur_dst_mac_offset: %d  cur_src_mac_offset: %d\n",
@@ -950,15 +949,13 @@ static ssize_t pktgen_if_write(struct fi
 			return len;
 		}
 		i += len;
-		if (value == 0x7FFFFFFF) {
-			pkt_dev->delay_us = 0x7FFFFFFF;
-			pkt_dev->delay_ns = 0;
-		} else {
-			pkt_dev->delay_us = value / 1000;
-			pkt_dev->delay_ns = value % 1000;
-		}
-		sprintf(pg_result, "OK: delay=%u",
-			1000 * pkt_dev->delay_us + pkt_dev->delay_ns);
+		if (value == 0x7FFFFFFF)
+			pkt_dev->delay = ULLONG_MAX;
+		else
+			pkt_dev->delay = (u64)value * NSEC_PER_USEC;
+
+		sprintf(pg_result, "OK: delay=%llu",
+			(unsigned long long) pkt_dev->delay);
 		return count;
 	}
 	if (!strcmp(name, "udp_src_min")) {
@@ -2089,27 +2086,33 @@ static void pktgen_setup_inject(struct p
 	pkt_dev->nflows = 0;
 }
 
-static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
+static inline s64 delta_ns(ktime_t a, ktime_t b)
+{
+	return ktime_to_ns(ktime_sub(a, b));
+}
+
+static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
-	__u64 start;
-	__u64 now;
+	ktime_t start, now;
+	s64 dt;
 
-	start = now = getCurUs();
-	while (now < spin_until_us) {
+	start = now = ktime_now();
+
+	while ((dt = delta_ns(spin_until, now)) > 0) {
 		/* TODO: optimize sleeping behavior */
-		if (spin_until_us - now > jiffies_to_usecs(1) + 1)
+		if (dt > TICK_NSEC)
 			schedule_timeout_interruptible(1);
-		else if (spin_until_us - now > 100) {
+		else if (dt > 100*NSEC_PER_USEC) {
 			if (!pkt_dev->running)
 				return;
 			if (need_resched())
 				schedule();
 		}
 
-		now = getCurUs();
+		now = ktime_now();
 	}
 
-	pkt_dev->idle_acc += now - start;
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(now, start));
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
@@ -3070,9 +3073,9 @@ static void pktgen_run(struct pktgen_thr
 			pktgen_clear_counters(pkt_dev);
 			pkt_dev->running = 1;	/* Cranke yeself! */
 			pkt_dev->skb = NULL;
-			pkt_dev->started_at = getCurUs();
-			pkt_dev->next_tx_us = getCurUs();	/* Transmit immediately */
-			pkt_dev->next_tx_ns = 0;
+			pkt_dev->started_at =
+				pkt_dev->next_tx = ktime_now();
+
 			set_pkt_overhead(pkt_dev);
 
 			strcpy(pkt_dev->result, "Starting");
@@ -3188,28 +3191,21 @@ static void pktgen_reset_all_threads(voi
 
 static void show_results(struct pktgen_dev *pkt_dev, int nr_frags)
 {
-	__u64 total_us, bps, mbps, pps, idle;
+	__u64 bps, mbps, pps;
 	char *p = pkt_dev->result;
-
-	total_us = pkt_dev->stopped_at - pkt_dev->started_at;
-
-	idle = pkt_dev->idle_acc;
-
-	p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)\n",
-		     (unsigned long long)total_us,
-		     (unsigned long long)(total_us - idle),
-		     (unsigned long long)idle,
+	ktime_t elapsed = ktime_sub(pkt_dev->stopped_at,
+				    pkt_dev->started_at);
+	ktime_t idle = ns_to_ktime(pkt_dev->idle_acc);
+
+	p += sprintf(p, "OK: %llu(c%llu+d%llu) nsec, %llu (%dbyte,%dfrags)\n",
+		     (unsigned long long)ktime_to_us(elapsed),
+		     (unsigned long long)ktime_to_us(ktime_sub(elapsed, idle)),
+		     (unsigned long long)ktime_to_us(idle),
 		     (unsigned long long)pkt_dev->sofar,
 		     pkt_dev->cur_pkt_size, nr_frags);
 
-	pps = pkt_dev->sofar * USEC_PER_SEC;
-
-	while ((total_us >> 32) != 0) {
-		pps >>= 1;
-		total_us >>= 1;
-	}
-
-	do_div(pps, total_us);
+	pps = div64_u64(pkt_dev->sofar * NSEC_PER_SEC,
+			ktime_to_ns(elapsed));
 
 	bps = pps * 8 * pkt_dev->cur_pkt_size;
 
@@ -3235,7 +3231,7 @@ static int pktgen_stop_device(struct pkt
 
 	kfree_skb(pkt_dev->skb);
 	pkt_dev->skb = NULL;
-	pkt_dev->stopped_at = getCurUs();
+	pkt_dev->stopped_at = ktime_now();
 	pkt_dev->running = 0;
 
 	show_results(pkt_dev, nr_frags);
@@ -3254,7 +3250,7 @@ static struct pktgen_dev *next_to_run(st
 			continue;
 		if (best == NULL)
 			best = pkt_dev;
-		else if (pkt_dev->next_tx_us < best->next_tx_us)
+		else if (ktime_lt(pkt_dev->next_tx, best->next_tx))
 			best = pkt_dev;
 	}
 	if_unlock(t);
@@ -3343,16 +3339,17 @@ static void pktgen_rem_thread(struct pkt
 
 static void idle(struct pktgen_dev *pkt_dev)
 {
-	u64 idle_start = getCurUs();
+	ktime_t idle_start = ktime_now();
 
 	if (need_resched())
 		schedule();
 	else
 		cpu_relax();
 
-	pkt_dev->idle_acc += getCurUs() - idle_start;
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), idle_start));
 }
 
+
 static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
@@ -3362,19 +3359,15 @@ static void pktgen_xmit(struct pktgen_de
 	u16 queue_map;
 	int ret;
 
-	if (pkt_dev->delay_us || pkt_dev->delay_ns) {
-		u64 now;
-
-		now = getCurUs();
-		if (now < pkt_dev->next_tx_us)
-			spin(pkt_dev, pkt_dev->next_tx_us);
+	if (pkt_dev->delay) {
+		if (ktime_lt(ktime_now(), pkt_dev->next_tx))
+			spin(pkt_dev, pkt_dev->next_tx);
 
 		/* This is max DELAY, this has special meaning of
 		 * "never transmit"
 		 */
-		if (pkt_dev->delay_us == 0x7FFFFFFF) {
-			pkt_dev->next_tx_us = getCurUs() + pkt_dev->delay_us;
-			pkt_dev->next_tx_ns = pkt_dev->delay_ns;
+		if (pkt_dev->delay == ULLONG_MAX) {
+			pkt_dev->next_tx = ktime_add_ns(ktime_now(), ULONG_MAX);
 			return;
 		}
 	}
@@ -3450,32 +3443,24 @@ static void pktgen_xmit(struct pktgen_de
 			pkt_dev->last_ok = 0;
 		}
 
-		if (pkt_dev->delay_us || pkt_dev->delay_ns) {
-			pkt_dev->next_tx_us = getCurUs();
-			pkt_dev->next_tx_ns = 0;
-
-			pkt_dev->next_tx_us += pkt_dev->delay_us;
-			pkt_dev->next_tx_ns += pkt_dev->delay_ns;
-
-			if (pkt_dev->next_tx_ns > 1000) {
-				pkt_dev->next_tx_us++;
-				pkt_dev->next_tx_ns -= 1000;
-			}
-		}
+		if (pkt_dev->delay)
+			pkt_dev->next_tx = ktime_add_ns(ktime_now(),
+							pkt_dev->delay);
 	}
 	__netif_tx_unlock_bh(txq);
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
 		if (atomic_read(&(pkt_dev->skb->users)) != 1) {
-			u64 idle_start = getCurUs();
+			ktime_t idle_start = ktime_now();
 			while (atomic_read(&(pkt_dev->skb->users)) != 1) {
 				if (signal_pending(current)) {
 					break;
 				}
 				schedule();
 			}
-			pkt_dev->idle_acc += getCurUs() - idle_start;
+			pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(),
+								   idle_start));
 		}
 
 		/* Done with this */
@@ -3634,8 +3619,7 @@ static int pktgen_add_device(struct pktg
 	pkt_dev->max_pkt_size = ETH_ZLEN;
 	pkt_dev->nfrags = 0;
 	pkt_dev->clone_skb = pg_clone_skb_d;
-	pkt_dev->delay_us = pg_delay_d / 1000;
-	pkt_dev->delay_ns = pg_delay_d % 1000;
+	pkt_dev->delay = pg_delay_d;
 	pkt_dev->count = pg_count_d;
 	pkt_dev->sofar = 0;
 	pkt_dev->udp_src_min = 9;	/* sink port */

-- 

