From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH 5/20] net/pktgen: remove interruptible_sleep_on_timeout() usage
Date: Thu, 3 Feb 2005 16:24:54 +0100
Message-ID: <16898.16966.272116.431070@robur.slu.se>
References: <20050202185823.GG2546@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, robert.olsson@its.uu.se, netdev@oss.sgi.com,
        kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050202185823.GG2546@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Nishanth Aravamudan writes:

 > The first and last replacements in the following patch were slightly confusing
 > to me, as I have not used wait-queues that much myself. I did not exactly
 > understand how a locally defined wait-queue could be slept on, especially since
 > there are no wake_up() calls in pktgen.c. I was tempted to make the first sleep
 > a msleep_interruptible(100), but decided to patch for the same code before I did
 > that.
 > 
 > Description: Replace deprecated interruptible_sleep_on_timeout() with direct
 > wait-queue usage or wait_event_interruptible_timeout() as appropriate.

 Tbanks!

 I've tested the patch  w. msleep_interruptible(). It seems fine. 
 Dave. This is on top of a patch I sent some days ago..

						--ro


--- net/core/pktgen.c.050201	2005-02-03 14:38:33.337577424 +0100
+++ net/core/pktgen.c	2005-02-03 15:44:22.959143680 +0100
@@ -104,6 +104,8 @@
  * Corrections from Nikolai Malykh (nmalykh@bilim.com) 
  * Removed unused flags F_SET_SRCMAC & F_SET_SRCIP 041230
  *
+ * interruptible_sleep_on_timeout() replaced Nishanth Aravamudan <nacc@us.ibm.com> 
+ * 050103
  */
 #include <linux/sys.h>
 #include <linux/types.h>
@@ -135,6 +137,7 @@
 #include <linux/ipv6.h>
 #include <linux/udp.h>
 #include <linux/proc_fs.h>
+#include <linux/wait.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -148,7 +151,7 @@
 #include <asm/timex.h>
 
 
-#define VERSION  "pktgen v2.56: Packet Generator for packet performance testing.\n"
+#define VERSION  "pktgen v2.57: Packet Generator for packet performance testing.\n"
 
 /* #define PG_DEBUG(a) a */
 #define PG_DEBUG(a) 
@@ -2402,16 +2405,14 @@
 
 static int pktgen_wait_thread_run(struct pktgen_thread *t )
 {
-        wait_queue_head_t queue;
-        
-        init_waitqueue_head(&queue);
-        
         if_lock(t);
 
         while(thread_is_running(t)) {
+
                 if_unlock(t);
-        
-                interruptible_sleep_on_timeout(&queue, HZ/10);
+
+		msleep_interruptible(100); 
+
                 if (signal_pending(current)) 
                         goto signal;
                 if_lock(t);
@@ -2733,6 +2734,7 @@
 
 static void pktgen_thread_worker(struct pktgen_thread *t) 
 {
+	DEFINE_WAIT(wait);
         struct pktgen_dev *pkt_dev = NULL;
 	int cpu = t->cpu;
 	sigset_t tmpsig;
@@ -2800,9 +2802,11 @@
 					do_softirq();
 				tx_since_softirq = 0;
 			}
+		} else {
+			prepare_to_wait(&(t->queue), &wait, TASK_INTERRUPTIBLE);
+			schedule_timeout(HZ/10);
+			finish_wait(&(t->queue), &wait);
 		}
-                else 
-                        interruptible_sleep_on_timeout(&(t->queue), HZ/10);
 
                 /* 
 		 * Back from sleep, either due to the timeout or signal.
@@ -3112,8 +3116,7 @@
                 struct pktgen_thread *t = pktgen_threads;
                 pktgen_threads->control |= (T_TERMINATE);
 
-                while( t == pktgen_threads) 
-                        interruptible_sleep_on_timeout(&queue, HZ);
+		wait_event_interruptible_timeout(queue, (t != pktgen_threads), HZ);
         }
 
         /* Un-register us from receiving netdevice events */
