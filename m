From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] wan: convert taskqueues to workqueues
Date: Fri, 19 Sep 2003 11:46:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030919114641.43d57172.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ncorbic@sangoma.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

This patch converts (or attempts to convert) drivers/net/wan/*
from task queues to the workqueue API, plus a few other small
cleanups.

I haven't used workqueues much, so some review would be a good
thing (depending on the answer to the following question).

Nenad, what are the plans for drivers/net/wan/ in 2.6?
Will these drivers be updated or will they just bitrot?

Thanks,
--
~Randy


patch_name:	wan_sdla_workqueue.patch
patch_version:	2003-09-19.11:31:30
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	convert wan/sdlamain.c from task queue to workqueue API;
product:	Linux
product_versions: 2.6.0-test5
changelog:	use workqueue API;
		don't init static globals to 0;
		kill 1 unused variable (warning);
		fix spelling/typos;
		convert 2 caller modules to use new interface;
		use request/release_region instead of check_region;
maintainer:	ncorbic@sangoma.com
diffstat:	=
 drivers/net/wan/sdla_fr.c  |   30 +++++-------
 drivers/net/wan/sdla_x25.c |   20 +++-----
 drivers/net/wan/sdlamain.c |  104 ++++++++++++++++++++-------------------------
 3 files changed, 68 insertions(+), 86 deletions(-)


diff -Naurp ./drivers/net/wan/sdlamain.c~wrkque ./drivers/net/wan/sdlamain.c
--- ./drivers/net/wan/sdlamain.c~wrkque	2003-09-08 12:50:18.000000000 -0700
+++ ./drivers/net/wan/sdlamain.c	2003-09-19 11:28:13.000000000 -0700
@@ -189,7 +189,6 @@ static int ioctl_exec	(sdla_t* card, sdl
 /* Miscellaneous functions */
 STATIC irqreturn_t sdla_isr	(int irq, void* dev_id, struct pt_regs *regs);
 static void release_hw  (sdla_t *card);
-static void run_wanpipe_tq (unsigned long);
 
 static int check_s508_conflicts (sdla_t* card,wandev_conf_t* conf, int*);
 static int check_s514_conflicts (sdla_t* card,wandev_conf_t* conf, int*);
@@ -203,29 +202,21 @@ static int check_s514_conflicts (sdla_t*
 static char drvname[]	= "wanpipe";
 static char fullname[]	= "WANPIPE(tm) Multiprotocol Driver";
 static char copyright[]	= "(c) 1995-2000 Sangoma Technologies Inc.";
-static int ncards = 0; 
-static sdla_t* card_array = NULL;	/* adapter data space */
+static int ncards; 
+static sdla_t* card_array;		/* adapter data space */
 
-/* Wanpipe's own task queue, used for all API's.
- * All protocol specific tasks will be instered
- * into "wanpipe_tq_custom" task_queue. 
-
- * On each rx_interrupt, the whole task queue
- * (wanpipe_tq_custom) will be queued into 
- * IMMEDIATE_BH via wanpipe_mark_bh() call. 
- 
- * The IMMEDIATE_BH will execute run_wanpipe_tq() 
- * function, which will execute all pending,
- * tasks in wanpipe_tq_custom queue */
-
-DECLARE_TASK_QUEUE(wanpipe_tq_custom);
-static struct tq_struct wanpipe_tq_task = 
-{
-	.routine = (void (*)(void *)) run_wanpipe_tq,
-	.data = &wanpipe_tq_custom
-};
+/* Wanpipe's own workqueue, used for all API's.
+ * All protocol specific tasks will be inserted
+ * into the "wanpipe_wq" workqueue. 
+
+ * The kernel workqueue mechanism will execute
+ * all pending tasks in the "wanpipe_wq" workqueue.
+ */
 
-static int wanpipe_bh_critical=0;
+struct workqueue_struct *wanpipe_wq;
+DECLARE_WORK(wanpipe_work, NULL, NULL);
+
+static int wanpipe_bh_critical;
 
 /******* Kernel Loadable Module Entry Points ********************************/
 
@@ -249,6 +240,10 @@ int wanpipe_init(void)
 	printk(KERN_INFO "%s v%u.%u %s\n",
 		fullname, DRV_VERSION, DRV_RELEASE, copyright);
 
+	wanpipe_wq = create_workqueue("wanpipe_wq");
+	if (!wanpipe_wq)
+		return -ENOMEM;
+
 	/* Probe for wanpipe cards and return the number found */
 	printk(KERN_INFO "wanpipe: Probing for WANPIPE hardware.\n");
 	ncards = wanpipe_hw_probe();
@@ -256,13 +251,16 @@ int wanpipe_init(void)
 		printk(KERN_INFO "wanpipe: Allocating maximum %i devices: wanpipe%i - wanpipe%i.\n",ncards,1,ncards);
 	}else{
 		printk(KERN_INFO "wanpipe: No S514/S508 cards found, unloading modules!\n");
+		destroy_workqueue(wanpipe_wq);
 		return -ENODEV;
 	}
 	
 	/* Verify number of cards and allocate adapter data space */
 	card_array = kmalloc(sizeof(sdla_t) * ncards, GFP_KERNEL);
-	if (card_array == NULL)
+	if (card_array == NULL) {
+		destroy_workqueue(wanpipe_wq);
 		return -ENOMEM;
+	}
 
 	memset(card_array, 0, sizeof(sdla_t) * ncards);
 
@@ -292,6 +290,7 @@ int wanpipe_init(void)
 		ncards = cnt;	/* adjust actual number of cards */
 	}else {
 		kfree(card_array);
+		destroy_workqueue(wanpipe_wq);
 		printk(KERN_INFO "IN Init Module: NO Cards registered\n");
 		err = -ENODEV;
 	}
@@ -316,6 +315,7 @@ static void wanpipe_cleanup(void)
 		sdla_t* card = &card_array[i];
 		unregister_wan_device(card->devname);
 	}
+	destroy_workqueue(wanpipe_wq);
 	kfree(card_array);
 
 	printk(KERN_INFO "\nwanpipe: WANPIPE Modules Unloaded.\n");
@@ -673,15 +673,20 @@ static int check_s508_conflicts (sdla_t*
 	
 
 	/* Make sure I/O port region is available only if we are the
-	 * master device.  If we are running in piggibacking mode, 
-	 * we will use the resources of the master card */
-	if (check_region(conf->ioport, SDLA_MAXIORANGE) && 
-	    !card->wandev.piggyback) {
-		printk(KERN_INFO
-			"%s: I/O region 0x%X - 0x%X is in use!\n",
-			card->wandev.name, conf->ioport,
-			conf->ioport + SDLA_MAXIORANGE);
-		return -EINVAL;
+	 * master device.  If we are running in piggybacking mode, 
+	 * we will use the resources of the master card. */
+	if (!card->wandev.piggyback) {
+		struct resource *rr =
+			request_region(conf->ioport, SDLA_MAXIORANGE, "sdlamain");
+		release_region(conf->ioport, SDLA_MAXIORANGE);
+
+		if (!rr) {
+			printk(KERN_INFO
+				"%s: I/O region 0x%X - 0x%X is in use!\n",
+				card->wandev.name, conf->ioport,
+				conf->ioport + SDLA_MAXIORANGE - 1);
+			return -EINVAL;
+		}
 	}
 
 	return 0;
@@ -1029,7 +1034,6 @@ static int ioctl_exec (sdla_t* card, sdl
 STATIC irqreturn_t sdla_isr (int irq, void* dev_id, struct pt_regs *regs)
 {
 #define	card	((sdla_t*)dev_id)
-	int handled = 0;
 
 	if(card->hw.type == SDLA_S514) {	/* handle interrrupt on S514 */
                 u32 int_status;
@@ -1210,6 +1214,7 @@ sdla_t * wanpipe_find_card (char *name)
 	}
 	return NULL;
 }
+
 sdla_t * wanpipe_find_card_num (int num)
 {
 	if (num < 1 || num > ncards)
@@ -1218,35 +1223,20 @@ sdla_t * wanpipe_find_card_num (int num)
 	return &card_array[num];
 }
 
-
-static void run_wanpipe_tq (unsigned long data)
-{
-	task_queue *tq_queue = (task_queue *)data;
-	if (test_and_set_bit(2,(void*)&wanpipe_bh_critical))
-		printk(KERN_INFO "CRITICAL IN RUNNING TASK QUEUE\n");
-	run_task_queue (tq_queue);
-	clear_bit(2,(void*)&wanpipe_bh_critical);
-
-}
-
-void wanpipe_queue_tq (struct tq_struct *bh_pointer)
+/*
+ * @work_pointer:	work_struct to be done;
+ * 			should already have PREPARE_WORK() or
+ * 			  INIT_WORK() done on it by caller;
+ */
+void wanpipe_queue_work (struct work_struct *work_pointer)
 {
-	if (test_and_set_bit(1,(void*)&wanpipe_bh_critical))
-		printk(KERN_INFO "CRITICAL IN QUEUING TASK\n");
+	if (test_and_set_bit(1, (void*)&wanpipe_bh_critical))
+		printk(KERN_INFO "CRITICAL IN QUEUING WORK\n");
 
-	queue_task(bh_pointer,&wanpipe_tq_custom);
+	queue_work(wanpipe_wq, work_pointer);
 	clear_bit(1,(void*)&wanpipe_bh_critical);
 }
 
-void wanpipe_mark_bh (void)
-{
-	if (!test_and_set_bit(0,(void*)&wanpipe_bh_critical)){
-		queue_task(&wanpipe_tq_task,&tq_immediate);
-		mark_bh(IMMEDIATE_BH);
-		clear_bit(0,(void*)&wanpipe_bh_critical);
-	}
-} 
-
 void wakeup_sk_bh(struct net_device *dev)
 {
 	wanpipe_common_t *chan = dev->priv;
diff -Naurp ./drivers/net/wan/sdla_fr.c~wrkque ./drivers/net/wan/sdla_fr.c
--- ./drivers/net/wan/sdla_fr.c~wrkque	2003-09-08 12:50:41.000000000 -0700
+++ ./drivers/net/wan/sdla_fr.c	2003-09-19 10:22:24.000000000 -0700
@@ -147,6 +147,7 @@
 #include <linux/slab.h>	/* kmalloc(), kfree() */
 #include <linux/wanrouter.h>	/* WAN router definitions */
 #include <linux/wanpipe.h>	/* WANPIPE common user API definitions */
+#include <linux/workqueue.h>
 #include <linux/if_arp.h>	/* ARPHRD_* defines */
 #include <asm/byteorder.h>	/* htons(), etc. */
 #include <asm/io.h>		/* for inb(), outb(), etc. */
@@ -247,7 +248,7 @@ typedef struct fr_channel
 	/* Polling task queue. Each interface
          * has its own task queue, which is used
          * to defer events from the interrupt */
-	struct tq_struct fr_poll_task;
+	struct work_struct fr_poll_work;
 	struct timer_list fr_arp_timer;
 
 	u32 ip_local;
@@ -987,9 +988,7 @@ static int new_if(struct wan_device* wan
          * We need a poll routine for each network
          * interface. 
          */
-	chan->fr_poll_task.sync = 0;
-	chan->fr_poll_task.routine = (void *)(void *)fr_poll;
-	chan->fr_poll_task.data = dev;
+	INIT_WORK(&chan->fr_poll_work, (void *)fr_poll, dev);
 
 	init_timer(&chan->fr_arp_timer);
 	chan->fr_arp_timer.data=(unsigned long)dev;
@@ -1212,9 +1211,7 @@ static int if_open(struct net_device* de
 	/* Initialize the task queue */
 	chan->tq_working=0;
 
-	chan->common.wanpipe_task.sync = 0;
-	chan->common.wanpipe_task.routine = (void *)(void *)fr_bh;
-	chan->common.wanpipe_task.data = dev;
+	INIT_WORK(&chan->common.wanpipe_work, (void *)fr_bh, dev);
 
 	/* Allocate and initialize BH circular buffer */
 	chan->bh_head = kmalloc((sizeof(bh_data_t)*MAX_BH_BUFF),GFP_ATOMIC);
@@ -2178,7 +2175,7 @@ static void rx_intr (sdla_t* card)
 		} 
 		
 
-		/* Send a packed up the IP stack */
+		/* Send a packet up the IP stack */
 		skb->dev->last_rx = jiffies;
 		netif_rx(skb);
 		++chan->drvstats_rx_intr.rx_intr_bfr_passed_to_stack;
@@ -2216,8 +2213,8 @@ rx_done:
  *         dlci number.
  *      2. Check that network interface is up and
  *         properly setup.
- * 	3. Check for a buffered packed.
- *      4. Transmit the packed.
+ * 	3. Check for a buffered packet.
+ *      4. Transmit the packet.
  *	5. If we are in WANPIPE mode, mark the 
  *         NET_BH handler. 
  *      6. If we are in API mode, kick
@@ -4359,8 +4356,8 @@ void s508_s514_unlock(sdla_t *card, unsi
  * bh_enqueue
  *
  * Description:
- *	Insert a received packed into a circular
- *      rx queue.  This packed will be picked up 
+ *	Insert a received packet into a circular
+ *      rx queue.  This packet will be picked up 
  *      by fr_bh() and sent up the stack to the
  *      user.
  *       	
@@ -4411,8 +4408,7 @@ static int bh_enqueue(struct net_device 
 static void trigger_fr_bh (fr_channel_t *chan)
 {
 	if (!test_and_set_bit(0,&chan->tq_working)){
-		wanpipe_queue_tq(&chan->common.wanpipe_task);
-		wanpipe_mark_bh();
+		wanpipe_queue_work(&chan->common.wanpipe_work);
 	}
 }
 
@@ -4435,10 +4431,10 @@ static void trigger_fr_bh (fr_channel_t 
  *      card into an skb buffer, the skb buffer
  *  	is appended to a circular BH buffer.
  *  	Then the interrupt kicks fr_bh() to finish the
- *      job at a later time (no within the interrupt).
+ *      job at a later time (not within the interrupt).
  *       
  * Usage:
- * 	Interrupts use this to defer a taks to 
+ * 	Interrupts use this to defer a task to 
  *      a polling routine.
  *
  */	
@@ -4527,7 +4523,7 @@ static int fr_bh_cleanup(struct net_devi
 static void trigger_fr_poll(struct net_device *dev)
 {
 	fr_channel_t* chan = dev->priv;
-	schedule_task(&chan->fr_poll_task);
+	schedule_work(&chan->fr_poll_work);
 	return;
 }
 
diff -Naurp ./drivers/net/wan/sdla_x25.c~wrkque ./drivers/net/wan/sdla_x25.c
--- ./drivers/net/wan/sdla_x25.c~wrkque	2003-09-08 12:50:16.000000000 -0700
+++ ./drivers/net/wan/sdla_x25.c	2003-09-19 10:09:03.000000000 -0700
@@ -91,6 +91,7 @@
 #include <linux/slab.h>	/* kmalloc(), kfree() */
 #include <linux/wanrouter.h>	/* WAN router definitions */
 #include <linux/wanpipe.h>	/* WANPIPE common user API definitions */
+#include <linux/workqueue.h>
 #include <asm/byteorder.h>	/* htons(), etc. */
 #include <asm/atomic.h>
 #include <linux/delay.h>	/* Experimental delay */
@@ -790,9 +791,7 @@ int wpx_init (sdla_t* card, wandev_conf_
 	
 	init_global_statistics(card);	
 
-	card->u.x.x25_poll_task.sync=0;
-	card->u.x.x25_poll_task.routine = (void*)(void*)wpx_poll;
-	card->u.x.x25_poll_task.data = card;
+	INIT_WORK(&card->u.x.x25_poll_work, (void *)wpx_poll, card);
 
 	init_timer(&card->u.x.x25_timer);
 	card->u.x.x25_timer.data = (unsigned long)card;
@@ -1175,7 +1174,7 @@ static int if_init(struct net_device* de
  * Warnings:	None
  *
  * Return: 	0 	Ok
- * 		<0 	Failur: Interface will not come up.
+ * 		<0 	Failure: Interface will not come up.
  */
 
 static int if_open(struct net_device* dev)
@@ -1190,10 +1189,8 @@ static int if_open(struct net_device* de
 
 	chan->tq_working = 0;
 
-	/* Initialize the task queue */
-	chan->common.wanpipe_task.sync = 0;
-	chan->common.wanpipe_task.routine = (void *)(void *)x25api_bh;
-	chan->common.wanpipe_task.data = dev;
+	/* Initialize the workqueue */
+	INIT_WORK(&chan->common.wanpipe_work, (void *)x25api_bh, dev);
 
 	/* Allocate and initialize BH circular buffer */
 	/* Add 1 to MAX_BH_BUFF so we don't have test with (MAX_BH_BUFF-1) */
@@ -1732,8 +1729,7 @@ static void rx_intr (sdla_t* card)
 
 		chan->rx_skb = NULL;
 		if (!test_and_set_bit(0, &chan->tq_working)){
-			wanpipe_queue_tq(&chan->common.wanpipe_task);
-			wanpipe_mark_bh();
+			wanpipe_queue_work(&chan->common.wanpipe_work);
 		}
 		return;
 	}
@@ -2227,7 +2223,7 @@ static void spur_intr (sdla_t* card)
 
 /*====================================================================
  * 	Main polling routine.
- * 	This routine is repeatedly called by the WANPIPE 'thead' to allow for
+ * 	This routine is repeatedly called by the WANPIPE 'thread' to allow for
  * 	time-dependent housekeeping work.
  *
  * 	Notes:
@@ -2274,7 +2270,7 @@ wpx_poll_exit:
 
 static void trigger_x25_poll(sdla_t *card)
 {
-	schedule_task(&card->u.x.x25_poll_task);
+	schedule_work(&card->u.x.x25_poll_work);
 }
 
 /*====================================================================
