From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 5/20] net/pktgen: remove
	interruptible_sleep_on_timeout() usage
Date: Wed, 2 Feb 2005 10:58:23 -0800
Message-ID: <20050202185823.GG2546@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============54228534473740186=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
To: robert.olsson@its.uu.se
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============54228534473740186==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

The first and last replacements in the following patch were slightly confusing
to me, as I have not used wait-queues that much myself. I did not exactly
understand how a locally defined wait-queue could be slept on, especially since
there are no wake_up() calls in pktgen.c. I was tempted to make the first sleep
a msleep_interruptible(100), but decided to patch for the same code before I did
that.

Description: Replace deprecated interruptible_sleep_on_timeout() with direct
wait-queue usage or wait_event_interruptible_timeout() as appropriate.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc2-kj-v/net/core/pktgen.c	2005-01-24 09:34:21.000000000 -0800
+++ 2.6.11-rc2-kj/net/core/pktgen.c	2005-02-02 10:57:02.000000000 -0800
@@ -135,6 +135,7 @@
 #include <linux/ipv6.h>
 #include <linux/udp.h>
 #include <linux/proc_fs.h>
+#include <linux/wait.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -2409,16 +2410,18 @@ static int running(struct pktgen_thread 
 
 static int pktgen_wait_thread_run(struct pktgen_thread *t )
 {
-        wait_queue_head_t queue;
-        
-        init_waitqueue_head(&queue);
-        
+	DEFINE_WAIT(wait);
+	wait_queue_head_t queue;
+	init_waitqueue_head(&queue);
+
         if_lock(t);
 
         while(running(t)) {
                 if_unlock(t);
-        
-                interruptible_sleep_on_timeout(&queue, HZ/10);
+
+		prepare_to_wait(&queue, &wait, TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ/10);
+		finish_wait(&queue, &wait);
                 if (signal_pending(current)) 
                         goto signal;
                 if_lock(t);
@@ -2738,6 +2741,7 @@ __inline__ void pktgen_xmit(struct pktge
 
 static void pktgen_thread_worker(struct pktgen_thread *t) 
 {
+	DEFINE_WAIT(wait);
         struct pktgen_dev *pkt_dev = NULL;
 	int cpu = t->cpu;
 	sigset_t tmpsig;
@@ -2805,9 +2809,11 @@ static void pktgen_thread_worker(struct 
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
@@ -3118,8 +3124,7 @@ static void __exit pg_cleanup(void)
                 struct pktgen_thread *t = pktgen_threads;
                 pktgen_threads->control |= (T_TERMINATE);
 
-                while( t == pktgen_threads) 
-                        interruptible_sleep_on_timeout(&queue, HZ);
+		wait_event_interruptible_timeout(queue, (t != pktgen_threads), HZ);
         }
 
         /* Un-register us from receiving netdevice events */

--===============54228534473740186==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============54228534473740186==--
