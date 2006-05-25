From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 3/4] [IrDA] stir4200, switching to the kthread API
Date: Thu, 25 May 2006 06:19:44 +0000
Message-ID: <20060525061944.GC24611@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	hch@lst.de, shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:23767 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932204AbWEXXJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 19:09:39 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stir4200 uses a kernel thread for its TX/RX operations, and it is now
converted to the kernel kthread API.
Tested on an STIR4200 based dongle.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>


---

 drivers/net/irda/stir4200.c |   38 ++++++++++++++------------------------
 1 files changed, 14 insertions(+), 24 deletions(-)

57a09954136abe1a184ff117f92cc7ebd8b93a49
diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 31867e4..d61b208 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -50,6 +50,7 @@ #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/usb.h>
 #include <linux/crc32.h>
+#include <linux/kthread.h>
 #include <net/irda/irda.h>
 #include <net/irda/irlap.h>
 #include <net/irda/irda_device.h>
@@ -173,9 +174,7 @@ struct stir_cb {
         struct qos_info   qos;
 	unsigned 	  speed;	/* Current speed */
 
-	wait_queue_head_t thr_wait;	/* transmit thread wakeup */
-	struct completion thr_exited;
-	pid_t		  thr_pid;
+        struct task_struct *thread;     /* transmit thread */
 
 	struct sk_buff	  *tx_pending;
 	void		  *io_buf;	/* transmit/receive buffer */
@@ -577,7 +576,7 @@ static int stir_hard_xmit(struct sk_buff
 	SKB_LINEAR_ASSERT(skb);
 
 	skb = xchg(&stir->tx_pending, skb);
-	wake_up(&stir->thr_wait);
+        wake_up_process(stir->thread);
 	
 	/* this should never happen unless stop/wakeup problem */
 	if (unlikely(skb)) {
@@ -753,13 +752,7 @@ static int stir_transmit_thread(void *ar
 	struct net_device *dev = stir->netdev;
 	struct sk_buff *skb;
 
-	daemonize("%s", dev->name);
-	allow_signal(SIGTERM);
-
-	while (netif_running(dev)
-	       && netif_device_present(dev)
-	       && !signal_pending(current))
-	{
+        while (!kthread_should_stop()) {
 #ifdef CONFIG_PM
 		/* if suspending, then power off and wait */
 		if (unlikely(freezing(current))) {
@@ -813,10 +806,11 @@ #endif
 		}
 
 		/* sleep if nothing to send */
-		wait_event_interruptible(stir->thr_wait, stir->tx_pending);
-	}
+                set_current_state(TASK_INTERRUPTIBLE);
+                schedule();
 
-	complete_and_exit (&stir->thr_exited, 0);
+	}
+        return 0;
 }
 
 
@@ -859,7 +853,7 @@ static void stir_rcv_irq(struct urb *urb
 		warn("%s: usb receive submit error: %d",
 			stir->netdev->name, err);
 		stir->receiving = 0;
-		wake_up(&stir->thr_wait);
+		wake_up_process(stir->thread);
 	}
 }
 
@@ -928,10 +922,10 @@ static int stir_net_open(struct net_devi
 	}
 
 	/** Start kernel thread for transmit.  */
-	stir->thr_pid = kernel_thread(stir_transmit_thread, stir,
-				      CLONE_FS|CLONE_FILES);
-	if (stir->thr_pid < 0) {
-		err = stir->thr_pid;
+	stir->thread = kthread_run(stir_transmit_thread, stir,
+				   "%s", stir->netdev->name);
+        if (IS_ERR(stir->thread)) {
+                err = PTR_ERR(stir->thread);
 		err("stir4200: unable to start kernel thread");
 		goto err_out6;
 	}
@@ -968,8 +962,7 @@ static int stir_net_close(struct net_dev
 	netif_stop_queue(netdev);
 
 	/* Kill transmit thread */
-	kill_proc(stir->thr_pid, SIGTERM, 1);
-	wait_for_completion(&stir->thr_exited);
+	kthread_stop(stir->thread);
 	kfree(stir->fifo_status);
 
 	/* Mop up receive urb's */
@@ -1084,9 +1077,6 @@ static int stir_probe(struct usb_interfa
 	stir->qos.min_turn_time.bits   &= qos_mtt_bits;
 	irda_qos_bits_to_value(&stir->qos);
 
-	init_completion (&stir->thr_exited);
-	init_waitqueue_head (&stir->thr_wait);
-
 	/* Override the network functions we need to use */
 	net->hard_start_xmit = stir_hard_xmit;
 	net->open            = stir_net_open;
-- 
1.3.2

