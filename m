From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: [PATCH] abysmal e1000 performance (DITR)
Date: Tue, 01 Jun 2004 17:05:12 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086131111.20113.22.camel@tubarao>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The introduction of Dynamic Interrupt Throttling Rate (DITR) in the 4.x
-> 5.x e1000 driver change can cause serious performance problems.  The
ITR can be reduced when the system is *not* under load which results in
gratuitous latencies for network traffic.  In other words - why is the
interrupt load reduced when the system isn't under load?

This is a patch to include system load when calculating the DITR.  It
only allows the diff/goc ratio to factor into the DITR when the 1 minute
load average is above .50.  It appears to work quite well and prevents
throttling when the load is below .50 and allows throttling when the
load is in excess of .50.

There are a few concerns.  The patch requires kernel/timer.c to
EXPORT_SYMBOL(avenrun) - otherwise the symbol isn't available to the
driver when built as a module.  This symbol "clutter" may be undesirable
to some.  Another concern is that NAPI accomplishes a similar interrupt
load reduction and is likely a better solution than ITR.


diff -ur linux-2.4.21-99/drivers/net/e1000/e1000_main.c linux-2.4.21-99-e1000/drivers/net/e1000/e1000_main.c
--- linux-2.4.21-99/drivers/net/e1000/e1000_main.c	2003-09-24 05:47:33.000000000 -0700
+++ linux-2.4.21-99-e1000/drivers/net/e1000/e1000_main.c	2004-05-27 23:38:02.000000000 -0700
@@ -27,6 +27,8 @@
 *******************************************************************************/
 
 #include "e1000.h"
+/* for avenrun[] */
+#include <linux/sched.h>
 
 /* Change Log
  *
@@ -1429,14 +1431,34 @@
 
 	/* Dynamic mode for Interrupt Throttle Rate (ITR) */
 	if(adapter->hw.mac_type >= e1000_82540 && adapter->itr == 1) {
+		/* fixed fractional part of .50 */
+#define FIXED_F50 (FIXED_1 >> 1)
+		/* This maps the range of .50-.99 -> 0-100 */
+#define FIXED_1_MAPPED (FIXED_1 - FIXED_F50)
+		unsigned long laf;	/* load average fractional part */
+		uint32_t goc;		/* good octet count */
+		uint32_t dif;		/* dif between tx and rx goc */
+		uint32_t itr;		/* inturrept throttle rate */
+		/* laf range is mapped:
+		 *     .00-.50 -> .00
+		 *     .50-.99 -> .00-.99
+		 *    1.00+    -> 1.00 */
+		if (avenrun[0] + FIXED_1/200 > FIXED_1)
+			laf = FIXED_1_MAPPED;
+		else if (avenrun[0] + FIXED_1/200 < FIXED_F50)
+			laf = 0;
+		else
+			laf = ((avenrun[0] + FIXED_1/2000) & (FIXED_1 - 1)) - FIXED_1_MAPPED;
 		/* Symmetric Tx/Rx gets a reduced ITR=2000; Total
 		 * asymmetrical Tx or Rx gets ITR=8000; everyone
 		 * else is between 2000-8000. */
-		uint32_t goc = (adapter->gotcl + adapter->gorcl) / 10000;
-		uint32_t dif = (adapter->gotcl > adapter->gorcl ? 
-			adapter->gotcl - adapter->gorcl :
-			adapter->gorcl - adapter->gotcl) / 10000;
-		uint32_t itr = goc > 0 ? (dif * 6000 / goc + 2000) : 8000;
+		goc = (adapter->gotcl + adapter->gorcl) / 10000;
+		dif = (adapter->gotcl > adapter->gorcl ? 
+		       adapter->gotcl - adapter->gorcl :
+		       adapter->gorcl - adapter->gotcl) / 10000;
+		itr = goc > 0
+			? 8000 + 6000*laf/FIXED_1_MAPPED*dif/goc - 6000*laf/FIXED_1_MAPPED
+			: 8000;
 		E1000_WRITE_REG(&adapter->hw, ITR, 1000000000 / (itr * 256));
 	}
 
diff -ur linux-2.4.21-99/kernel/Makefile linux-2.4.21-99-e1000/kernel/Makefile
--- linux-2.4.21-99/kernel/Makefile	2003-09-24 05:47:27.000000000 -0700
+++ linux-2.4.21-99-e1000/kernel/Makefile	2004-05-26 23:45:47.000000000 -0700
@@ -11,7 +11,7 @@
 
 export-objs = signal.o sys.o kmod.o context.o ksyms.o pm.o exec_domain.o \
 	      printk.o cpufreq.o rcupdate.o syscall_ksyms.o fork.o hook.o \
-	      rashooks.o module.o
+	      rashooks.o module.o timer.o
 
 obj-y     = sched.o dma.o fork.o exec_domain.o panic.o printk.o \
 	    module.o exit.o itimer.o info.o time.o softirq.o resource.o \
diff -ur linux-2.4.21-99/kernel/timer.c linux-2.4.21-99-e1000/kernel/timer.c
--- linux-2.4.21-99/kernel/timer.c	2003-09-24 05:47:27.000000000 -0700
+++ linux-2.4.21-99-e1000/kernel/timer.c	2004-05-27 00:54:29.000000000 -0700
@@ -686,6 +686,7 @@
  * all seem to differ on different machines.
  */
 unsigned long avenrun[3];
+EXPORT_SYMBOL(avenrun);
 
 static inline void calc_load(unsigned long ticks)
 {

-- 
Thayne Harbaugh
Linux Networx
