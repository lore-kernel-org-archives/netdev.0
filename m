From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] nanospin/pg_udelay oversleeping in pktgen
Date: Wed, 8 Dec 2004 23:18:38 +0100
Message-ID: <20041208221838.GA12022@xi.wantstofly.org>
References: <20041208215611.GA11844@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: robert.olsson@data.slu.se
Content-Disposition: inline
In-Reply-To: <20041208215611.GA11844@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 08, 2004 at 10:56:11PM +0100, Lennert Buytenhek wrote:

> One more reason why 'ipg' isn't really working very well for me: pktgen
> tends to oversleep a lot.  When using ipg=1000000 and attached patch, I
> always get output like this:
> 
> 	overslept by 173588 ns
> 	overslept by 171822 ns
> 	overslept by 171234 ns
> 	overslept by 171888 ns
> 	overslept by 171354 ns
> 	overslept by 171974 ns
> 	overslept by 171480 ns

Below patch appears to fix the 'oversleeping' problem by always delaying
in terms of nanoseconds instead of converting nanoseconds and cycles back
and forth.  It still oversleeps, but by ~50-~150ns per call instead of
in the millisecond range.

Comments welcome.


cheers,
Lennert


--- pktgen.c.orig	2004-11-28 22:27:50.000000000 +0100
+++ pktgen.c	2004-12-08 23:09:53.397371873 +0100
@@ -239,7 +239,7 @@
 				*/
         __u64 started_at; /* micro-seconds */
         __u64 stopped_at; /* micro-seconds */
-        __u64 idle_acc;
+        __u64 idle_acc;   /* nano-seconds */
         __u32 seq_num;
         
         int clone_skb; /* Use multiple SKBs during packet gen.  If this number
@@ -717,8 +717,8 @@
                 stopped = now; /* not really stopped, more like last-running-at */
         
         p += sprintf(p, "Current:\n     pkts-sofar: %llu  errors: %llu\n     started: %lluus  stopped: %lluus idle: %lluus\n",
-                     pkt_dev->sofar, pkt_dev->errors, sa, stopped, 
-		     pg_div(pkt_dev->idle_acc, pg_cycles_per_us));
+                     pkt_dev->sofar, pkt_dev->errors, sa, stopped,
+		     pg_div(pkt_dev->idle_acc, 1000));
 
         p += sprintf(p, "     seq_num: %d  cur_dst_mac_offset: %d  cur_src_mac_offset: %d\n",
                      pkt_dev->seq_num, pkt_dev->cur_dst_mac_offset, pkt_dev->cur_src_mac_offset);
@@ -1732,54 +1729,32 @@
 	pkt_dev->nflows = 0;
 }
 
-/* ipg is in nano-seconds */
-static void nanospin(__u32 ipg, struct pktgen_dev *pkt_dev)
+/* spin_until is in nano-seconds */
+static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until)
 {
-	u64 idle_start = get_cycles();
-        u64 idle;
-
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
+	u64 start;
 	u64 now;
-       
-	for (;;) {
-                do_softirq();
-                now = getRelativeCurUs();
-                if (start + delay_us <= (now - 10)) 
-                        break;
 
-                if (!pkt_dev->running)
-                        return;
-                
-                if (need_resched()) 
-                        schedule();
-		
-                now = getRelativeCurUs();
-                if (start + delay_us <= (now - 10)) 
-                        break;
-	}
+	/* Try not to busy-spin if we have larger sleep times.
+	 * TODO:  Investigate better ways to do this.
+	 */
+	start = now = getRelativeCurNs();
+	while (now < spin_until) {
+		if (spin_until - now > 10000) {
+			do_softirq();
+			if (!pkt_dev->running)
+				return;
+			if (need_resched())
+				schedule();
+		}
 
-        pkt_dev->idle_acc += (1000 * (now - start));
+		now = getRelativeCurNs();
+	}
 
-        /* We can break out of the loop up to 10us early, so spend the rest of
-         * it spinning to increase accuracy.
-         */
-        if (start + delay_us > now)
-                nanospin((start + delay_us) - now, pkt_dev);
+	pkt_dev->idle_acc += now - start;
 }
 
+
 /* Returns: cycles per micro-second */
 static int calc_mhz(void)
 {
@@ -2693,33 +2667,16 @@
 {
 	struct net_device *odev = NULL;
 	__u64 idle_start = 0;
-	u32 next_ipg = 0;
-        u64 now = 0;              /* in nano-seconds */
 	int ret;
 
 	odev = pkt_dev->odev;
 	
 	if (pkt_dev->ipg) {
-		now = getRelativeCurNs();
-		if (now < pkt_dev->next_tx_ns) {
-			next_ipg = (u32)(pkt_dev->next_tx_ns - now);
-			
-			/* Try not to busy-spin if we have larger sleep times.
-			 * TODO:  Investigate better ways to do this.
-			 */
+	        u64 now;              /* in nano-seconds */
 
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
+		now = getRelativeCurNs();
+		if (now < pkt_dev->next_tx_ns)
+			spin(pkt_dev, pkt_dev->next_tx_ns);
 
 		/* This is max IPG, this has special meaning of
 		 * "never transmit"
