From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] stir4200" switch to the kthread API
Date: Fri, 14 Apr 2006 20:23:07 +0200
Message-ID: <20060414182307.GA20862@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.210]:55688 "EHLO mail.lst.de")
	by vger.kernel.org with ESMTP id S1751386AbWDNSXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2006 14:23:15 -0400
To: shemminger@osdl.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/drivers/net/irda/stir4200.c
===================================================================
--- linux-2.6.orig/drivers/net/irda/stir4200.c	2006-04-14 20:12:37.000000000 +0200
+++ linux-2.6/drivers/net/irda/stir4200.c	2006-04-14 20:21:29.000000000 +0200
@@ -50,6 +50,7 @@
 #include <linux/delay.h>
 #include <linux/usb.h>
 #include <linux/crc32.h>
+#include <linux/kthread.h>
 #include <net/irda/irda.h>
 #include <net/irda/irlap.h>
 #include <net/irda/irda_device.h>
@@ -173,9 +174,7 @@
         struct qos_info   qos;
 	unsigned 	  speed;	/* Current speed */
 
-	wait_queue_head_t thr_wait;	/* transmit thread wakeup */
-	struct completion thr_exited;
-	pid_t		  thr_pid;
+	struct task_struct *thread;	/* transmit thread */
 
 	struct sk_buff	  *tx_pending;
 	void		  *io_buf;	/* transmit/receive buffer */
@@ -577,7 +576,7 @@
 	SKB_LINEAR_ASSERT(skb);
 
 	skb = xchg(&stir->tx_pending, skb);
-	wake_up(&stir->thr_wait);
+	wake_up_process(stir->thread);
 	
 	/* this should never happen unless stop/wakeup problem */
 	if (unlikely(skb)) {
@@ -753,13 +752,7 @@
 	struct net_device *dev = stir->netdev;
 	struct sk_buff *skb;
 
-	daemonize("%s", dev->name);
-	allow_signal(SIGTERM);
-
-	while (netif_running(dev)
-	       && netif_device_present(dev)
-	       && !signal_pending(current))
-	{
+	while (!kthread_should_stop()) {
 #ifdef CONFIG_PM
 		/* if suspending, then power off and wait */
 		if (unlikely(freezing(current))) {
@@ -813,10 +806,11 @@
 		}
 
 		/* sleep if nothing to send */
-		wait_event_interruptible(stir->thr_wait, stir->tx_pending);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
 	}
 
-	complete_and_exit (&stir->thr_exited, 0);
+	return 0;
 }
 
 
@@ -859,7 +853,7 @@
 		warn("%s: usb receive submit error: %d",
 			stir->netdev->name, err);
 		stir->receiving = 0;
-		wake_up(&stir->thr_wait);
+		wake_up_process(stir->thread);
 	}
 }
 
@@ -928,10 +922,10 @@
 	}
 
 	/** Start kernel thread for transmit.  */
-	stir->thr_pid = kernel_thread(stir_transmit_thread, stir,
-				      CLONE_FS|CLONE_FILES);
-	if (stir->thr_pid < 0) {
-		err = stir->thr_pid;
+	stir->thread = kthread_run(stir_transmit_thread, stir,
+			"%s", stir->netdev->name);
+	if (IS_ERR(stir->thread)) {
+		err = PTR_ERR(stir->thread);
 		err("stir4200: unable to start kernel thread");
 		goto err_out6;
 	}
@@ -968,8 +962,7 @@
 	netif_stop_queue(netdev);
 
 	/* Kill transmit thread */
-	kill_proc(stir->thr_pid, SIGTERM, 1);
-	wait_for_completion(&stir->thr_exited);
+	kthread_stop(stir->thread);
 	kfree(stir->fifo_status);
 
 	/* Mop up receive urb's */
@@ -1084,9 +1077,6 @@
 	stir->qos.min_turn_time.bits   &= qos_mtt_bits;
 	irda_qos_bits_to_value(&stir->qos);
 
-	init_completion (&stir->thr_exited);
-	init_waitqueue_head (&stir->thr_wait);
-
 	/* Override the network functions we need to use */
 	net->hard_start_xmit = stir_hard_xmit;
 	net->open            = stir_net_open;

----- End forwarded message -----
