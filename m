From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 4/5] s390: lcs driver bug fixes and improvements [1/2]
Date: Wed, 24 May 2006 09:51:17 +0200
Message-ID: <20060524095117.3b6b24cd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:60973 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S932648AbWEXHuy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 03:50:54 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k4O7orW0051794
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 07:50:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4O7qVkc139318
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:52:31 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4O7oqJL029178
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:50:53 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



From: Klaus Wacker <kdwacker@de.ibm.com>

	Several problems occured with lcs device driver:
	 - device not operational anymore after cable pull/plug-in.
       	 - unpredictable results occured, e.g. kernel panic
	   using cards of type QD8F.
	 - STOPLAN and delete multicast address command
           were not proper recognized by OSA card under heavy network workload.
       	 - channel/device error checks missing in interrupt handler.
	To fix all problems at once recovery of lcs devices has been improved.
	missing error checks in lcs interrupt handler has been added.
	Once a hardware problem occurs lcs will recover the device now properly.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/lcs.c |  341 ++++++++++++++++++++++++------------------------
 1 files changed, 171 insertions(+), 170 deletions(-)

c9db4a2d4c97370d5a65ef0654342052c80ed7a2
diff --git a/drivers/s390/net/lcs.c b/drivers/s390/net/lcs.c
index e65da92..c915bb5 100644
--- a/drivers/s390/net/lcs.c
+++ b/drivers/s390/net/lcs.c
@@ -68,6 +68,7 @@ static void lcs_tasklet(unsigned long);
 static void lcs_start_kernel_thread(struct lcs_card *card);
 static void lcs_get_frames_cb(struct lcs_channel *, struct lcs_buffer *);
 static int lcs_send_delipm(struct lcs_card *, struct lcs_ipm_list *);
+static int lcs_recovery(void *ptr);
 
 /**
  * Debug Facility Stuff
@@ -429,12 +430,6 @@ lcs_setup_card(struct lcs_card *card)
 	card->tx_buffer = NULL;
 	card->tx_emitted = 0;
 
-	/* Initialize kernel thread task used for LGW commands. */
-	INIT_WORK(&card->kernel_thread_starter,
-		  (void *)lcs_start_kernel_thread,card);
-	card->thread_start_mask = 0;
-	card->thread_allowed_mask = 0;
-	card->thread_running_mask = 0;
 	init_waitqueue_head(&card->wait_q);
 	spin_lock_init(&card->lock);
 	spin_lock_init(&card->ipm_lock);
@@ -675,8 +670,9 @@ lcs_ready_buffer(struct lcs_channel *cha
 	int index, rc;
 
 	LCS_DBF_TEXT(5, trace, "rdybuff");
-	BUG_ON(buffer->state != BUF_STATE_LOCKED &&
-		buffer->state != BUF_STATE_PROCESSED);
+	if (buffer->state != BUF_STATE_LOCKED &&
+	    buffer->state != BUF_STATE_PROCESSED)
+		BUG();
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	buffer->state = BUF_STATE_READY;
 	index = buffer - channel->iob;
@@ -700,7 +696,8 @@ __lcs_processed_buffer(struct lcs_channe
 	int index, prev, next;
 
 	LCS_DBF_TEXT(5, trace, "prcsbuff");
-	BUG_ON(buffer->state != BUF_STATE_READY);
+	if (buffer->state != BUF_STATE_READY)
+		BUG();
 	buffer->state = BUF_STATE_PROCESSED;
 	index = buffer - channel->iob;
 	prev = (index - 1) & (LCS_NUM_BUFFS - 1);
@@ -732,8 +729,9 @@ lcs_release_buffer(struct lcs_channel *c
 	unsigned long flags;
 
 	LCS_DBF_TEXT(5, trace, "relbuff");
-	BUG_ON(buffer->state != BUF_STATE_LOCKED &&
-		buffer->state != BUF_STATE_PROCESSED);
+	if (buffer->state != BUF_STATE_LOCKED &&
+	    buffer->state != BUF_STATE_PROCESSED)
+		BUG();
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	buffer->state = BUF_STATE_EMPTY;
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
@@ -1147,8 +1145,6 @@ list_modified:
 		list_add_tail(&ipm->list, &card->ipm_list);
 	}
 	spin_unlock_irqrestore(&card->ipm_lock, flags);
-	if (card->state == DEV_STATE_UP)
-		netif_wake_queue(card->dev);
 }
 
 /**
@@ -1231,17 +1227,17 @@ lcs_set_mc_addresses(struct lcs_card *ca
 		if (ipm != NULL)
 			continue;	/* Address already in list. */
 		ipm = (struct lcs_ipm_list *)
-			kmalloc(sizeof(struct lcs_ipm_list), GFP_ATOMIC);
+			kzalloc(sizeof(struct lcs_ipm_list), GFP_ATOMIC);
 		if (ipm == NULL) {
 			PRINT_INFO("Not enough memory to add "
 				   "new multicast entry!\n");
 			break;
 		}
-		memset(ipm, 0, sizeof(struct lcs_ipm_list));
 		memcpy(&ipm->ipm.mac_addr, buf, LCS_MAC_LENGTH);
 		ipm->ipm.ip_addr = im4->multiaddr;
 		ipm->ipm_state = LCS_IPM_STATE_SET_REQUIRED;
 		spin_lock_irqsave(&card->ipm_lock, flags);
+		LCS_DBF_HEX(2,trace,&ipm->ipm.ip_addr,4);
 		list_add(&ipm->list, &card->ipm_list);
 		spin_unlock_irqrestore(&card->ipm_lock, flags);
 	}
@@ -1269,7 +1265,15 @@ lcs_register_mc_addresses(void *data)
 	read_unlock(&in4_dev->mc_list_lock);
 	in_dev_put(in4_dev);
 
+	netif_carrier_off(card->dev);
+	netif_tx_disable(card->dev);
+	wait_event(card->write.wait_q,
+			(card->write.state != CH_STATE_RUNNING));
 	lcs_fix_multicast_list(card);
+	if (card->state == DEV_STATE_UP) {
+		netif_carrier_on(card->dev);
+		netif_wake_queue(card->dev);
+	}
 out:
 	lcs_clear_thread_running_bit(card, LCS_SET_MC_THREAD);
 	return 0;
@@ -1318,6 +1322,53 @@ lcs_check_irb_error(struct ccw_device *c
 	return PTR_ERR(irb);
 }
 
+static int
+lcs_get_problem(struct ccw_device *cdev, struct irb *irb)
+{
+	int dstat, cstat;
+	char *sense;
+
+	sense = (char *) irb->ecw;
+	cstat = irb->scsw.cstat;
+	dstat = irb->scsw.dstat;
+
+	if (cstat & (SCHN_STAT_CHN_CTRL_CHK | SCHN_STAT_INTF_CTRL_CHK |
+		     SCHN_STAT_CHN_DATA_CHK | SCHN_STAT_CHAIN_CHECK |
+		     SCHN_STAT_PROT_CHECK   | SCHN_STAT_PROG_CHECK)) {
+		LCS_DBF_TEXT(2, trace, "CGENCHK");
+		return 1;
+	}
+	if (dstat & DEV_STAT_UNIT_CHECK) {
+		if (sense[LCS_SENSE_BYTE_1] &
+		    LCS_SENSE_RESETTING_EVENT) {
+			LCS_DBF_TEXT(2, trace, "REVIND");
+			return 1;
+		}
+		if (sense[LCS_SENSE_BYTE_0] &
+		    LCS_SENSE_CMD_REJECT) {
+			LCS_DBF_TEXT(2, trace, "CMDREJ");
+			return 0;
+		}
+		if ((!sense[LCS_SENSE_BYTE_0]) &&
+		    (!sense[LCS_SENSE_BYTE_1]) &&
+		    (!sense[LCS_SENSE_BYTE_2]) &&
+		    (!sense[LCS_SENSE_BYTE_3])) {
+			LCS_DBF_TEXT(2, trace, "ZEROSEN");
+			return 0;
+		}
+		LCS_DBF_TEXT(2, trace, "DGENCHK");
+		return 1;
+	}
+	return 0;
+}
+
+void
+lcs_schedule_recovery(struct lcs_card *card)
+{
+	LCS_DBF_TEXT(2, trace, "startrec");
+	if (!lcs_set_thread_start_bit(card, LCS_RECOVERY_THREAD))
+		schedule_work(&card->kernel_thread_starter);
+}
 
 /**
  * IRQ Handler for LCS channels
@@ -1327,7 +1378,8 @@ lcs_irq(struct ccw_device *cdev, unsigne
 {
 	struct lcs_card *card;
 	struct lcs_channel *channel;
-	int index;
+	int rc, index;
+	int cstat, dstat;
 
 	if (lcs_check_irb_error(cdev, irb))
 		return;
@@ -1338,10 +1390,23 @@ lcs_irq(struct ccw_device *cdev, unsigne
 	else
 		channel = &card->write;
 
+	cstat = irb->scsw.cstat;
+	dstat = irb->scsw.dstat;
 	LCS_DBF_TEXT_(5, trace, "Rint%s",cdev->dev.bus_id);
 	LCS_DBF_TEXT_(5, trace, "%4x%4x",irb->scsw.cstat, irb->scsw.dstat);
 	LCS_DBF_TEXT_(5, trace, "%4x%4x",irb->scsw.fctl, irb->scsw.actl);
 
+	/* Check for channel and device errors presented */
+	rc = lcs_get_problem(cdev, irb);
+	if (rc || (dstat & DEV_STAT_UNIT_EXCEP)) {
+		PRINT_WARN("check on device %s, dstat=0x%X, cstat=0x%X \n", 
+			    cdev->dev.bus_id, dstat, cstat);
+		if (rc) {
+			lcs_schedule_recovery(card);
+			wake_up(&card->wait_q);
+			return;
+		}
+	}
 	/* How far in the ccw chain have we processed? */
 	if ((channel->state != CH_STATE_INIT) &&
 	    (irb->scsw.fctl & SCSW_FCTL_START_FUNC)) {
@@ -1367,7 +1432,6 @@ lcs_irq(struct ccw_device *cdev, unsigne
 	else if (irb->scsw.actl & SCSW_ACTL_SUSPENDED)
 		/* CCW execution stopped on a suspend bit. */
 		channel->state = CH_STATE_SUSPENDED;
-
 	if (irb->scsw.fctl & SCSW_FCTL_HALT_FUNC) {
 		if (irb->scsw.cc != 0) {
 			ccw_device_halt(channel->ccwdev, (addr_t) channel);
@@ -1376,7 +1440,6 @@ lcs_irq(struct ccw_device *cdev, unsigne
 		/* The channel has been stopped by halt_IO. */
 		channel->state = CH_STATE_HALTED;
 	}
-
 	if (irb->scsw.fctl & SCSW_FCTL_CLEAR_FUNC) {
 		channel->state = CH_STATE_CLEARED;
 	}
@@ -1452,7 +1515,7 @@ lcs_txbuffer_cb(struct lcs_channel *chan
 	lcs_release_buffer(channel, buffer);
 	card = (struct lcs_card *)
 		((char *) channel - offsetof(struct lcs_card, write));
-	if (netif_queue_stopped(card->dev))
+	if (netif_queue_stopped(card->dev) && netif_carrier_ok(card->dev))
 		netif_wake_queue(card->dev);
 	spin_lock(&card->lock);
 	card->tx_emitted--;
@@ -1488,6 +1551,10 @@ __lcs_start_xmit(struct lcs_card *card, 
 		card->stats.tx_carrier_errors++;
 		return 0;
 	}
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		dev_kfree_skb(skb);
+		return 0;
+	}
 	netif_stop_queue(card->dev);
 	spin_lock(&card->lock);
 	if (card->tx_buffer != NULL &&
@@ -1633,30 +1700,6 @@ lcs_detect(struct lcs_card *card)
 }
 
 /**
- * reset card
- */
-static int
-lcs_resetcard(struct lcs_card *card)
-{
-	int retries;
-
-	LCS_DBF_TEXT(2, trace, "rescard");
-	for (retries = 0; retries < 10; retries++) {
-		if (lcs_detect(card) == 0) {
-			netif_wake_queue(card->dev);
-			card->state = DEV_STATE_UP;
-			PRINT_INFO("LCS device %s successfully restarted!\n",
-				   card->dev->name);
-			return 0;
-		}
-		msleep(3000);
-	}
-	PRINT_ERR("Error in Reseting LCS card!\n");
-	return -EIO;
-}
-
-
-/**
  * LCS Stop card
  */
 static int
@@ -1680,126 +1723,18 @@ lcs_stopcard(struct lcs_card *card)
 }
 
 /**
- * LGW initiated commands
- */
-static int
-lcs_lgw_startlan_thread(void *data)
-{
-	struct lcs_card *card;
-
-	card = (struct lcs_card *) data;
-	daemonize("lgwstpln");
-
-	if (!lcs_do_run_thread(card, LCS_STARTLAN_THREAD))
-		return 0;
-	LCS_DBF_TEXT(4, trace, "lgwstpln");
-	if (card->dev)
-		netif_stop_queue(card->dev);
-	if (lcs_startlan(card) == 0) {
-		netif_wake_queue(card->dev);
-		card->state = DEV_STATE_UP;
-		PRINT_INFO("LCS Startlan for device %s succeeded!\n",
-			   card->dev->name);
-
-	} else
-		PRINT_ERR("LCS Startlan for device %s failed!\n",
-			  card->dev->name);
-	lcs_clear_thread_running_bit(card, LCS_STARTLAN_THREAD);
-	return 0;
-}
-
-/**
- * Send startup command initiated by Lan Gateway
- */
-static int
-lcs_lgw_startup_thread(void *data)
-{
-	int rc;
-
-	struct lcs_card *card;
-
-	card = (struct lcs_card *) data;
-	daemonize("lgwstaln");
-
-	if (!lcs_do_run_thread(card, LCS_STARTUP_THREAD))
-		return 0;
-	LCS_DBF_TEXT(4, trace, "lgwstaln");
-	if (card->dev)
-		netif_stop_queue(card->dev);
-	rc = lcs_send_startup(card, LCS_INITIATOR_LGW);
-	if (rc != 0) {
-		PRINT_ERR("Startup for LCS device %s initiated " \
-			  "by LGW failed!\nReseting card ...\n",
-			  card->dev->name);
-		/* do a card reset */
-		rc = lcs_resetcard(card);
-		if (rc == 0)
-			goto Done;
-	}
-	rc = lcs_startlan(card);
-	if (rc == 0) {
-		netif_wake_queue(card->dev);
-		card->state = DEV_STATE_UP;
-	}
-Done:
-	if (rc == 0)
-		PRINT_INFO("LCS Startup for device %s succeeded!\n",
-			   card->dev->name);
-	else
-		PRINT_ERR("LCS Startup for device %s failed!\n",
-			  card->dev->name);
-	lcs_clear_thread_running_bit(card, LCS_STARTUP_THREAD);
-	return 0;
-}
-
-
-/**
- * send stoplan command initiated by Lan Gateway
- */
-static int
-lcs_lgw_stoplan_thread(void *data)
-{
-	struct lcs_card *card;
-	int rc;
-
-	card = (struct lcs_card *) data;
-	daemonize("lgwstop");
-
-	if (!lcs_do_run_thread(card, LCS_STOPLAN_THREAD))
-		return 0;
-	LCS_DBF_TEXT(4, trace, "lgwstop");
-	if (card->dev)
-		netif_stop_queue(card->dev);
-	if (lcs_send_stoplan(card, LCS_INITIATOR_LGW) == 0)
-		PRINT_INFO("Stoplan for %s initiated by LGW succeeded!\n",
-			   card->dev->name);
-	else
-		PRINT_ERR("Stoplan %s initiated by LGW failed!\n",
-			  card->dev->name);
-	/*Try to reset the card, stop it on failure */
-        rc = lcs_resetcard(card);
-        if (rc != 0)
-                rc = lcs_stopcard(card);
-	lcs_clear_thread_running_bit(card, LCS_STOPLAN_THREAD);
-        return rc;
-}
-
-/**
  * Kernel Thread helper functions for LGW initiated commands
  */
 static void
 lcs_start_kernel_thread(struct lcs_card *card)
 {
 	LCS_DBF_TEXT(5, trace, "krnthrd");
-	if (lcs_do_start_thread(card, LCS_STARTUP_THREAD))
-		kernel_thread(lcs_lgw_startup_thread, (void *) card, SIGCHLD);
-	if (lcs_do_start_thread(card, LCS_STARTLAN_THREAD))
-		kernel_thread(lcs_lgw_startlan_thread, (void *) card, SIGCHLD);
-	if (lcs_do_start_thread(card, LCS_STOPLAN_THREAD))
-		kernel_thread(lcs_lgw_stoplan_thread, (void *) card, SIGCHLD);
+	if (lcs_do_start_thread(card, LCS_RECOVERY_THREAD))
+		kernel_thread(lcs_recovery, (void *) card, SIGCHLD);
 #ifdef CONFIG_IP_MULTICAST
 	if (lcs_do_start_thread(card, LCS_SET_MC_THREAD))
-		kernel_thread(lcs_register_mc_addresses, (void *) card, SIGCHLD);
+		kernel_thread(lcs_register_mc_addresses, 
+				(void *) card, SIGCHLD);
 #endif
 }
 
@@ -1813,19 +1748,14 @@ lcs_get_control(struct lcs_card *card, s
 	if (cmd->initiator == LCS_INITIATOR_LGW) {
 		switch(cmd->cmd_code) {
 		case LCS_CMD_STARTUP:
-			if (!lcs_set_thread_start_bit(card,
-						      LCS_STARTUP_THREAD))
-				schedule_work(&card->kernel_thread_starter);
-			break;
 		case LCS_CMD_STARTLAN:
-			if (!lcs_set_thread_start_bit(card,
-						      LCS_STARTLAN_THREAD))
-				schedule_work(&card->kernel_thread_starter);
+			lcs_schedule_recovery(card);
 			break;
 		case LCS_CMD_STOPLAN:
-			if (!lcs_set_thread_start_bit(card,
-						      LCS_STOPLAN_THREAD))
-				schedule_work(&card->kernel_thread_starter);
+			PRINT_WARN("Stoplan for %s initiated by LGW.\n",
+					card->dev->name);
+			if (card->dev)
+				netif_carrier_off(card->dev);
 			break;
 		default:
 			PRINT_INFO("UNRECOGNIZED LGW COMMAND\n");
@@ -1941,8 +1871,11 @@ lcs_stop_device(struct net_device *dev)
 
 	LCS_DBF_TEXT(2, trace, "stopdev");
 	card   = (struct lcs_card *) dev->priv;
-	netif_stop_queue(dev);
+	netif_carrier_off(dev);
+	netif_tx_disable(dev);
 	dev->flags &= ~IFF_UP;
+	wait_event(card->write.wait_q,
+		(card->write.state != CH_STATE_RUNNING));
 	rc = lcs_stopcard(card);
 	if (rc)
 		PRINT_ERR("Try it again!\n ");
@@ -1968,6 +1901,7 @@ lcs_open_device(struct net_device *dev)
 
 	} else {
 		dev->flags |= IFF_UP;
+		netif_carrier_on(dev);
 		netif_wake_queue(dev);
 		card->state = DEV_STATE_UP;
 	}
@@ -2059,10 +1993,31 @@ lcs_timeout_store (struct device *dev, s
 
 DEVICE_ATTR(lancmd_timeout, 0644, lcs_timeout_show, lcs_timeout_store);
 
+static ssize_t
+lcs_dev_recover_store(struct device *dev, struct device_attribute *attr, 
+		      const char *buf, size_t count)
+{
+	struct lcs_card *card = dev->driver_data;
+	char *tmp;
+	int i;
+
+	if (!card)
+		return -EINVAL;
+	if (card->state != DEV_STATE_UP)
+		return -EPERM;
+	i = simple_strtoul(buf, &tmp, 16);
+	if (i == 1)
+		lcs_schedule_recovery(card);
+	return count;
+}
+
+static DEVICE_ATTR(recover, 0200, NULL, lcs_dev_recover_store);
+
 static struct attribute * lcs_attrs[] = {
 	&dev_attr_portno.attr,
 	&dev_attr_type.attr,
 	&dev_attr_lancmd_timeout.attr,
+	&dev_attr_recover.attr,
 	NULL,
 };
 
@@ -2099,6 +2054,12 @@ lcs_probe_device(struct ccwgroup_device 
 	ccwgdev->dev.driver_data = card;
 	ccwgdev->cdev[0]->handler = lcs_irq;
 	ccwgdev->cdev[1]->handler = lcs_irq;
+	card->gdev = ccwgdev;
+	INIT_WORK(&card->kernel_thread_starter,
+		  (void *) lcs_start_kernel_thread, card);
+	card->thread_start_mask = 0;
+	card->thread_allowed_mask = 0;
+	card->thread_running_mask = 0;
         return 0;
 }
 
@@ -2200,6 +2161,7 @@ netdev_out:
 	if (recover_state == DEV_STATE_RECOVER) {
 		lcs_set_multicast_list(card->dev);
 		card->dev->flags |= IFF_UP;
+		netif_carrier_on(card->dev);
 		netif_wake_queue(card->dev);
 		card->state = DEV_STATE_UP;
 	} else {
@@ -2229,7 +2191,7 @@ out:
  * lcs_shutdown_device, called when setting the group device offline.
  */
 static int
-lcs_shutdown_device(struct ccwgroup_device *ccwgdev)
+__lcs_shutdown_device(struct ccwgroup_device *ccwgdev, int recovery_mode)
 {
 	struct lcs_card *card;
 	enum lcs_dev_states recover_state;
@@ -2239,9 +2201,11 @@ lcs_shutdown_device(struct ccwgroup_devi
 	card = (struct lcs_card *)ccwgdev->dev.driver_data;
 	if (!card)
 		return -ENODEV;
-	lcs_set_allowed_threads(card, 0);
-	if (lcs_wait_for_threads(card, LCS_SET_MC_THREAD))
-		return -ERESTARTSYS;
+	if (recovery_mode == 0) {
+		lcs_set_allowed_threads(card, 0);
+		if (lcs_wait_for_threads(card, LCS_SET_MC_THREAD))
+			return -ERESTARTSYS;
+	}
 	LCS_DBF_HEX(3, setup, &card, sizeof(void*));
 	recover_state = card->state;
 
@@ -2256,6 +2220,43 @@ lcs_shutdown_device(struct ccwgroup_devi
 	return 0;
 }
 
+static int
+lcs_shutdown_device(struct ccwgroup_device *ccwgdev)
+{
+	return __lcs_shutdown_device(ccwgdev, 0);
+}
+
+/**
+ * drive lcs recovery after startup and startlan initiated by Lan Gateway
+ */
+static int
+lcs_recovery(void *ptr)
+{
+	struct lcs_card *card;
+	struct ccwgroup_device *gdev;
+        int rc;
+
+	card = (struct lcs_card *) ptr;
+	daemonize("lcs_recover");
+
+	LCS_DBF_TEXT(4, trace, "recover1");
+	if (!lcs_do_run_thread(card, LCS_RECOVERY_THREAD))
+		return 0;
+	LCS_DBF_TEXT(4, trace, "recover2");
+	gdev = card->gdev;
+	PRINT_WARN("Recovery of device %s started...\n", gdev->dev.bus_id);
+	rc = __lcs_shutdown_device(gdev, 1);
+	rc = lcs_new_device(gdev);
+	if (!rc)
+		PRINT_INFO("Device %s successfully recovered!\n",
+				card->dev->name);
+	else
+		PRINT_INFO("Device %s could not be recovered!\n",
+				card->dev->name);
+	lcs_clear_thread_running_bit(card, LCS_RECOVERY_THREAD);
+	return 0;
+}
+
 /**
  * lcs_remove_device, free buffers and card
  */
-- 
1.2.4

