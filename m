From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] pktgen sleeping/timing rework
Date: Fri, 10 Dec 2004 23:20:58 +0100
Message-ID: <20041210222058.GA5984@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: robert.olsson@data.slu.se
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Robert,

Below is a patch against your latest pktgen devel version which does
the following:
- Remove usage of get_cycles(), mhz calibration, pg_cycles_per_*,
  getRelativeCur[UM]s(), and everything related to reading the CPU
  cycle counter directly.  For one, it can't work correctly on
  machines that can change clock frequency on the fly (such as the
  Via EPIA-based machine I'm working on right now), and since you
  only determine 'clocks per usec' (i.e. determining the mhz rating
  of the CPU), it's not even any more accurate than do_gettimeofday
  already is.
- Fix up handling of inter-packet gap.  There was some code for
  enforcing a certain IPG, but the actual (CPU) cost of the sending
  of the packet was not substracted from that, so the effective IPG
  ended up being IPG+random_overhead.  This now works somewhat better
  and the effective pps rate does seem to end up being ~ 1/ipg, but
  this needs some more testing and tweaking.
- Call schedule_timeout whenever we have to wait longer than a jiffy.
  For me this nicely reduces the CPU overhead when sending out 100pps
  to almost nothing.

TODO:
- When ipg is set close to the HW limit, behavior becomes a bit wonky.
  On my EPIA board I can generate ~110kpps when I set ipg=0, but when I
  set ipg=10000 (which would give 100kpps), I only get ~85kps.
- We should rename 'ipg' to something different since in our case it
  never was and never will be the same as what the ethernet folks mean
  with it.

Comments welcome.


cheers,
Lennert


--- pktgen.c.041209	2004-12-11 21:21:26.000000000 +0100
+++ pktgen.c	2004-12-11 22:57:51.221340048 +0100
@@ -222,14 +222,16 @@
         int min_pkt_size;    /* = ETH_ZLEN; */
         int max_pkt_size;    /* = ETH_ZLEN; */
         int nfrags;
-        __u32 ipg;    /* Default Interpacket gap in nsec */
+        __u32 ipg_us;    /* Default Interpacket gap */
+        __u32 ipg_ns;
         __u64 count;  /* Default No packets to send */
         __u64 sofar;  /* How many pkts we've sent so far */
         __u64 tx_bytes; /* How many bytes we've transmitted */
         __u64 errors;    /* Errors when trying to transmit, pkts will be re-sent */
 
         /* runtime counters relating to clone_skb */
-        __u64 next_tx_ns;          /* timestamp of when to tx next, in nano-seconds */
+        __u64 next_tx_us;          /* timestamp of when to tx next */
+        __u32 next_tx_ns;
         
         __u64 allocated_skbs;
         __u32 clone_count;
@@ -239,7 +241,7 @@
 				*/
         __u64 started_at; /* micro-seconds */
         __u64 stopped_at; /* micro-seconds */
-        __u64 idle_acc;
+        __u64 idle_acc; /* micro-seconds */
         __u32 seq_num;
         
         int clone_skb; /* Use multiple SKBs during packet gen.  If this number
@@ -346,10 +348,6 @@
 #define REMOVE 1
 #define FIND   0
 
-static u32 pg_cycles_per_ns;
-static u32 pg_cycles_per_us;
-static u32 pg_cycles_per_ms;
-
 /*  This code works around the fact that do_div cannot handle two 64-bit
     numbers, and regular 64-bit division doesn't work on x86 kernels.
     --Ben
@@ -452,14 +450,6 @@
 #endif
 }
 
-/* Fast, not horribly accurate, since the machine started. */
-static inline __u64 getRelativeCurMs(void) {
-        return pg_div(get_cycles(), pg_cycles_per_ms);
-}
-
-/* Since the epoc.  More precise over long periods of time than
- * getRelativeCurMs
- */
 static inline __u64 getCurMs(void) 
 {
         struct timeval tv;
@@ -467,9 +457,6 @@
         return tv_to_ms(&tv);
 }
 
-/* Since the epoc.  More precise over long periods of time than
- * getRelativeCurMs
- */
 static inline __u64 getCurUs(void) 
 {
         struct timeval tv;
@@ -477,18 +464,6 @@
         return tv_to_us(&tv);
 }
 
-/* Since the machine booted. */
-static inline __u64 getRelativeCurUs(void) 
-{
-        return pg_div(get_cycles(), pg_cycles_per_us);
-}
-
-/* Since the machine booted. */
-static inline __u64 getRelativeCurNs(void) 
-{
-        return pg_div(get_cycles(), pg_cycles_per_ns);
-}
-
 static inline __u64 tv_diff(const struct timeval* a, const struct timeval* b) 
 {
         return tv_to_us(a) - tv_to_us(b);
@@ -523,11 +498,6 @@
 static unsigned int scan_ip6(const char *s,char ip[16]);
 static unsigned int fmt_ip6(char *s,const char ip[16]);
 
-/* cycles per micro-second */
-static u32 pg_cycles_per_ns;
-static u32 pg_cycles_per_us;
-static u32 pg_cycles_per_ms;
-
 /* Module parameters, defaults. */
 static int pg_count_d = 1000; /* 1000 pkts by default */
 static int pg_ipg_d = 0;
@@ -646,7 +616,7 @@
 		     pkt_dev->count, pkt_dev->min_pkt_size, pkt_dev->max_pkt_size);
 
 	p += sprintf(p, "     frags: %d  ipg: %u  clone_skb: %d  ifname: %s\n",
-                     pkt_dev->nfrags, pkt_dev->ipg, pkt_dev->clone_skb, pkt_dev->ifname);
+                     pkt_dev->nfrags, 1000*pkt_dev->ipg_us+pkt_dev->ipg_ns, pkt_dev->clone_skb, pkt_dev->ifname);
 
 	p += sprintf(p, "     flows: %u flowlen: %u\n", pkt_dev->cflows, pkt_dev->lflow);
 
@@ -718,7 +688,7 @@
         
         p += sprintf(p, "Current:\n     pkts-sofar: %llu  errors: %llu\n     started: %lluus  stopped: %lluus idle: %lluus\n",
                      pkt_dev->sofar, pkt_dev->errors, sa, stopped, 
-		     pg_div(pkt_dev->idle_acc, pg_cycles_per_us));
+		     pkt_dev->idle_acc);
 
         p += sprintf(p, "     seq_num: %d  cur_dst_mac_offset: %d  cur_src_mac_offset: %d\n",
                      pkt_dev->seq_num, pkt_dev->cur_dst_mac_offset, pkt_dev->cur_src_mac_offset);
@@ -932,11 +902,14 @@
 		len = num_arg(&user_buffer[i], 10, &value);
                 if (len < 0) { return len; }
 		i += len;
-		pkt_dev->ipg = value;
-                if ((getRelativeCurNs() + pkt_dev->ipg) > pkt_dev->next_tx_ns) {
-                        pkt_dev->next_tx_ns = getRelativeCurNs() + pkt_dev->ipg;
-                }
-		sprintf(pg_result, "OK: ipg=%u", pkt_dev->ipg);
+		if (value == 0x7FFFFFFF) {
+			pkt_dev->ipg_us = 0x7FFFFFFF;
+			pkt_dev->ipg_ns = 0;
+		} else {
+			pkt_dev->ipg_us = value / 1000;
+			pkt_dev->ipg_ns = value % 1000;
+		}
+		sprintf(pg_result, "OK: ipg=%u", 1000*pkt_dev->ipg_us+pkt_dev->ipg_ns);
 		return count;
 	}
  	if (!strcmp(name, "udp_src_min")) {
@@ -1732,108 +1705,32 @@
 	pkt_dev->nflows = 0;
 }
 
-/* ipg is in nano-seconds */
-static void nanospin(__u32 ipg, struct pktgen_dev *pkt_dev)
+static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 {
-	u64 idle_start = get_cycles();
-        u64 idle;
+	__u64 start;
+	__u64 now;
 
-	for (;;) {
-		barrier();
-		idle = get_cycles() - idle_start;
-		if (idle * 1000 >= ipg * pg_cycles_per_us)
-			break;
-	}
-	pkt_dev->idle_acc += idle;
-}
-
-
-/* ipg is in micro-seconds (usecs) */
-static void pg_udelay(__u32 delay_us, struct pktgen_dev *pkt_dev)
-{
-	u64 start = getRelativeCurUs();
-	u64 now;
-       
-	for (;;) {
-                do_softirq();
-                now = getRelativeCurUs();
-                if (start + delay_us <= (now - 10)) 
-                        break;
+	start = now = getCurUs();
+	printk(KERN_INFO "sleeping for %d\n", (int)(spin_until_us - now));
+	while (now < spin_until_us) {
+		/* TODO: optimise sleeping behavior */
+		if (spin_until_us - now > (1000000/HZ)+1) {
+			current->state = TASK_INTERRUPTIBLE;
+			schedule_timeout(1);
+		} else if (spin_until_us - now > 100) {
+			do_softirq();
+			if (!pkt_dev->running)
+				return;
+			if (need_resched())
+				schedule();
+		}
 
-                if (!pkt_dev->running)
-                        return;
-                
-                if (need_resched()) 
-                        schedule();
-		
-                now = getRelativeCurUs();
-                if (start + delay_us <= (now - 10)) 
-                        break;
+		now = getCurUs();
 	}
 
-        pkt_dev->idle_acc += (1000 * (now - start));
-
-        /* We can break out of the loop up to 10us early, so spend the rest of
-         * it spinning to increase accuracy.
-         */
-        if (start + delay_us > now)
-                nanospin((start + delay_us) - now, pkt_dev);
+	pkt_dev->idle_acc += now - start;
 }
 
-/* Returns: cycles per micro-second */
-static int calc_mhz(void)
-{
-	struct timeval start, stop;
-	u64 start_s;
-        u64 t1, t2;
-        u32 elapsed;
-        u32 clock_time = 0;
-        
-	do_gettimeofday(&start);
-	start_s = get_cycles();
-        /* Spin for 50,000,000 cycles */
-	do {
-		barrier();
-		elapsed = (u32)(get_cycles() - start_s);
-		if (elapsed == 0)
-			return 0;
-	} while (elapsed < 50000000);
-
-	do_gettimeofday(&stop);
-
-        t1 = tv_to_us(&start);
-        t2 = tv_to_us(&stop);
-
-        clock_time = (u32)(t2 - t1);
-        if (clock_time == 0) {
-                printk("pktgen: ERROR:  clock_time was zero..things may not work right, t1: %u  t2: %u ...\n",
-                       (u32)(t1), (u32)(t2));
-                return 0x7FFFFFFF;
-        }
-	return elapsed / clock_time;
-}
-
-/* Calibrate cycles per micro-second */
-static void cycles_calibrate(void)
-{
-	int i;
-
-	for (i = 0; i < 3; i++) {
-		u32 res = calc_mhz();
-		if (res > pg_cycles_per_us)
-			pg_cycles_per_us = res;
-	}
-
-        /* Set these up too, only need to calculate these once. */
-        pg_cycles_per_ns = pg_cycles_per_us / 1000;
-        if (pg_cycles_per_ns == 0) 
-                pg_cycles_per_ns = 1;
-
-        pg_cycles_per_ms = pg_cycles_per_us * 1000;
-        
-        printk("pktgen: cycles_calibrate, cycles_per_ns: %d  per_us: %d  per_ms: %d\n",
-               pg_cycles_per_ns, pg_cycles_per_us, pg_cycles_per_ms);
-}
 
 /* Increment/randomize headers according to flags and current values
  * for IP src/dest, UDP src/dst port, MAC-Addr src/dst
@@ -2455,7 +2352,8 @@
 			pkt_dev->running = 1; /* Cranke yeself! */
 			pkt_dev->skb = NULL;
 			pkt_dev->started_at = getCurUs();
-			pkt_dev->next_tx_ns = 0; /* Transmit immediately */
+			pkt_dev->next_tx_us = getCurUs(); /* Transmit immediately */
+			pkt_dev->next_tx_ns = 0;
 			
 			strcpy(pkt_dev->result, "Starting");
 			started++;
@@ -2568,17 +2466,13 @@
 
        total_us = pkt_dev->stopped_at - pkt_dev->started_at;
 
-       BUG_ON(pg_cycles_per_us == 0);
-
        idle = pkt_dev->idle_acc;
-       do_div(idle, pg_cycles_per_us);
 
        p += sprintf(p, "OK: %llu(c%llu+d%llu) usec, %llu (%dbyte,%dfrags)\n",
                     total_us, (unsigned long long)(total_us - idle), idle,
                     pkt_dev->sofar, pkt_dev->cur_pkt_size, nr_frags);
 
        pps = pkt_dev->sofar * USEC_PER_SEC;
-       
 
        while ((total_us >> 32) != 0) {
                pps >>= 1;
@@ -2626,7 +2520,7 @@
 	for(next=t->if_list; next ; next=next->next) {
 		if(!next->running) continue;
 		if(best == NULL) best=next;
-		else if ( next->next_tx_ns < best->next_tx_ns) 
+		else if ( next->next_tx_us < best->next_tx_us) 
 			best =  next;
 	}
 	if_unlock(t);
@@ -2692,46 +2586,29 @@
 {
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
-	u32 next_ipg = 0;
-        u64 now = 0;              /* in nano-seconds */
 	int ret;
 
 	odev = pkt_dev->odev;
 	
-	if (pkt_dev->ipg) {
-		now = getRelativeCurNs();
-		if (now < pkt_dev->next_tx_ns) {
-			next_ipg = (u32)(pkt_dev->next_tx_ns - now);
-			
-			/* Try not to busy-spin if we have larger sleep times.
-			 * TODO:  Investigate better ways to do this.
-			 */
+	if (pkt_dev->ipg_us || pkt_dev->ipg_ns) {
+		u64 now;
 
-                        /* 10 usecs or less */
-			if (next_ipg < 10000)  
-				nanospin(next_ipg, pkt_dev);
-
-                       /* 10ms or less */			
-			else if (next_ipg < 10000000)  
-				pg_udelay(next_ipg / 1000, pkt_dev);
-
-			/* fall asleep for a 10ms or more. */
-			else 
-				pg_udelay(next_ipg / 1000, pkt_dev);
-		}
+		now = getCurUs();
+		if (now < pkt_dev->next_tx_us)
+			spin(pkt_dev, pkt_dev->next_tx_us);
 
 		/* This is max IPG, this has special meaning of
 		 * "never transmit"
 		 */
-		if (pkt_dev->ipg == 0x7FFFFFFF) {
-			pkt_dev->next_tx_ns = getRelativeCurNs() + pkt_dev->ipg;
+		if (pkt_dev->ipg_us == 0x7FFFFFFF) {
+			pkt_dev->next_tx_us = getCurUs() + pkt_dev->ipg_us;
+			pkt_dev->next_tx_ns = pkt_dev->ipg_ns;
 			goto out;
 		}
 	}
 	
 	if (netif_queue_stopped(odev) || need_resched()) {
-                                
-		idle_start = get_cycles();
+		idle_start = getCurUs();
 		
 		if (!netif_running(odev)) {
 			pktgen_stop_device(pkt_dev);
@@ -2740,10 +2617,11 @@
 		if (need_resched()) 
 			schedule();
 		
-		pkt_dev->idle_acc += get_cycles() - idle_start;
+		pkt_dev->idle_acc += getCurUs() - idle_start;
 		
 		if (netif_queue_stopped(odev)) {
-			pkt_dev->next_tx_ns = getRelativeCurNs(); /* TODO */
+			pkt_dev->next_tx_us = getCurUs(); /* TODO */
+			pkt_dev->next_tx_ns = 0;
 			goto out; /* Try the next interface */
 		}
 	}
@@ -2768,7 +2646,8 @@
 	
 	spin_lock_bh(&odev->xmit_lock);
 	if (!netif_queue_stopped(odev)) {
-		
+		u64 now;
+
 		atomic_inc(&(pkt_dev->skb->users));
 retry_now:
 		ret = odev->hard_start_xmit(pkt_dev->skb, odev);
@@ -2789,16 +2668,32 @@
 			if (debug && net_ratelimit())
 				printk(KERN_INFO "pktgen: Hard xmit error\n");
 			
-				pkt_dev->errors++;
-				pkt_dev->last_ok = 0;
-				pkt_dev->next_tx_ns = getRelativeCurNs(); /* TODO */
+			pkt_dev->errors++;
+			pkt_dev->last_ok = 0;
+			pkt_dev->next_tx_us = getCurUs(); /* TODO */
+			pkt_dev->next_tx_ns = 0;
+		}
+
+		pkt_dev->next_tx_us += pkt_dev->ipg_us;
+		pkt_dev->next_tx_ns += pkt_dev->ipg_ns;
+		if (pkt_dev->next_tx_ns > 1000) {
+			pkt_dev->next_tx_us++;
+			pkt_dev->next_tx_ns -= 1000;
+		}
+
+		now = getCurUs();
+		if (now > pkt_dev->next_tx_us) {
+			/* TODO: this code is slightly wonky.  */
+			pkt_dev->errors++;
+			pkt_dev->next_tx_us = now - pkt_dev->ipg_us;
+			pkt_dev->next_tx_ns = 0;
 		}
-		pkt_dev->next_tx_ns = getRelativeCurNs() + pkt_dev->ipg;
 	} 
 
 	else {  /* Retry it next time */
                 pkt_dev->last_ok = 0;
-                pkt_dev->next_tx_ns = getRelativeCurNs(); /* TODO */
+                pkt_dev->next_tx_us = getCurUs(); /* TODO */
+		pkt_dev->next_tx_ns = 0;
         }
 
 	spin_unlock_bh(&odev->xmit_lock);
@@ -2806,14 +2701,14 @@
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
 		if (atomic_read(&(pkt_dev->skb->users)) != 1) {
-			idle_start = get_cycles();
+			idle_start = getCurUs();
 			while (atomic_read(&(pkt_dev->skb->users)) != 1) {
 				if (signal_pending(current)) {
 					break;
 				}
 				schedule();
 			}
-			pkt_dev->idle_acc += get_cycles() - idle_start;
+			pkt_dev->idle_acc += getCurUs() - idle_start;
 		}
                 
 		/* Done with this */
@@ -3006,7 +2901,8 @@
                 pkt_dev->max_pkt_size = ETH_ZLEN;
                 pkt_dev->nfrags = 0;
                 pkt_dev->clone_skb = pg_clone_skb_d;
-                pkt_dev->ipg = pg_ipg_d;
+                pkt_dev->ipg_us = pg_ipg_d / 1000;
+                pkt_dev->ipg_ns = pg_ipg_d % 1000;
                 pkt_dev->count = pg_count_d;
                 pkt_dev->sofar = 0;
                 pkt_dev->udp_src_min = 9; /* sink port */
@@ -3169,12 +3065,6 @@
 
         module_fname[0] = 0;
 
-	cycles_calibrate();
-	if (pg_cycles_per_us == 0) {
-		printk("pktgen: ERROR: your machine does not have working cycle counter.\n");
-		return -EINVAL;
-	}
-
 	create_proc_dir();
 
         sprintf(module_fname, "net/%s/pgctrl", PG_PROC_DIR);
