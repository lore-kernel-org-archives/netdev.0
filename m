From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/2] [PATCH] ctcm: rename READ/WRITE defines to avoid redefinitions
Date: Thu, 12 Aug 2010 13:58:28 +0200
Message-ID: <20100812120608.459636000@linux.vnet.ibm.com>
References: <20100812115826.983015000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:37946 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758868Ab0HLMGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 08:06:11 -0400
Content-Disposition: inline; filename=602-ctcm-rename.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

READ/WRITE seems to be a bit too generic for defines in a device
driver. Just rename them to CTCM_READ/CTCM_WRITE to avoid warnings.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_fsms.c  |   60 ++++++++++++++++---------------
 drivers/s390/net/ctcm_main.c  |   80 +++++++++++++++++++++---------------------
 drivers/s390/net/ctcm_main.h  |    4 +-
 drivers/s390/net/ctcm_mpc.c   |   64 +++++++++++++++++----------------
 drivers/s390/net/ctcm_sysfs.c |   20 +++++-----
 5 files changed, 118 insertions(+), 110 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/ctcm_fsms.c linux-2.6-patched/drivers/s390/net/ctcm_fsms.c
--- linux-2.6/drivers/s390/net/ctcm_fsms.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_fsms.c	2010-08-12 13:29:50.000000000 +0200
@@ -454,7 +454,7 @@ static void chx_firstio(fsm_instance *fi
 	if ((fsmstate == CTC_STATE_SETUPWAIT) &&
 	    (ch->protocol == CTCM_PROTO_OS390)) {
 		/* OS/390 resp. z/OS */
-		if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		if (CHANNEL_DIRECTION(ch->flags) == CTCM_READ) {
 			*((__u16 *)ch->trans_skb->data) = CTCM_INITIAL_BLOCKLEN;
 			fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC,
 				     CTC_EVENT_TIMER, ch);
@@ -472,14 +472,14 @@ static void chx_firstio(fsm_instance *fi
 	 * if in compatibility mode, since VM TCP delays the initial
 	 * frame until it has some data to send.
 	 */
-	if ((CHANNEL_DIRECTION(ch->flags) == WRITE) ||
+	if ((CHANNEL_DIRECTION(ch->flags) == CTCM_WRITE) ||
 	    (ch->protocol != CTCM_PROTO_S390))
 		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
 
 	*((__u16 *)ch->trans_skb->data) = CTCM_INITIAL_BLOCKLEN;
 	ch->ccw[1].count = 2;	/* Transfer only length */
 
-	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == READ)
+	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == CTCM_READ)
 		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
 	rc = ccw_device_start(ch->cdev, &ch->ccw[0],
 					(unsigned long)ch, 0xff, 0);
@@ -495,7 +495,7 @@ static void chx_firstio(fsm_instance *fi
 	 * reply from VM TCP which brings up the RX channel to it's
 	 * final state.
 	 */
-	if ((CHANNEL_DIRECTION(ch->flags) == READ) &&
+	if ((CHANNEL_DIRECTION(ch->flags) == CTCM_READ) &&
 	    (ch->protocol == CTCM_PROTO_S390)) {
 		struct net_device *dev = ch->netdev;
 		struct ctcm_priv *priv = dev->ml_priv;
@@ -600,15 +600,15 @@ static void ctcm_chx_start(fsm_instance 
 	int rc;
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s(%s): %s",
-			CTCM_FUNTAIL, ch->id,
-			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+		CTCM_FUNTAIL, ch->id,
+		(CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ? "RX" : "TX");
 
 	if (ch->trans_skb != NULL) {
 		clear_normalized_cda(&ch->ccw[1]);
 		dev_kfree_skb(ch->trans_skb);
 		ch->trans_skb = NULL;
 	}
-	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+	if (CHANNEL_DIRECTION(ch->flags) == CTCM_READ) {
 		ch->ccw[1].cmd_code = CCW_CMD_READ;
 		ch->ccw[1].flags = CCW_FLAG_SLI;
 		ch->ccw[1].count = 0;
@@ -622,7 +622,8 @@ static void ctcm_chx_start(fsm_instance 
 			"%s(%s): %s trans_skb alloc delayed "
 			"until first transfer",
 			CTCM_FUNTAIL, ch->id,
-			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+			(CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ?
+				"RX" : "TX");
 	}
 	ch->ccw[0].cmd_code = CCW_CMD_PREPARE;
 	ch->ccw[0].flags = CCW_FLAG_SLI | CCW_FLAG_CC;
@@ -720,7 +721,7 @@ static void ctcm_chx_cleanup(fsm_instanc
 
 	ch->th_seg = 0x00;
 	ch->th_seq_num = 0x00;
-	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+	if (CHANNEL_DIRECTION(ch->flags) == CTCM_READ) {
 		skb_queue_purge(&ch->io_queue);
 		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
 	} else {
@@ -799,7 +800,8 @@ static void ctcm_chx_setuperr(fsm_instan
 		fsm_newstate(fi, CTC_STATE_STARTRETRY);
 		fsm_deltimer(&ch->timer);
 		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
-		if (!IS_MPC(ch) && (CHANNEL_DIRECTION(ch->flags) == READ)) {
+		if (!IS_MPC(ch) &&
+		    (CHANNEL_DIRECTION(ch->flags) == CTCM_READ)) {
 			int rc = ccw_device_halt(ch->cdev, (unsigned long)ch);
 			if (rc != 0)
 				ctcm_ccw_check_rc(ch, rc,
@@ -811,10 +813,10 @@ static void ctcm_chx_setuperr(fsm_instan
 	CTCM_DBF_TEXT_(ERROR, CTC_DBF_CRIT,
 		"%s(%s) : %s error during %s channel setup state=%s\n",
 		CTCM_FUNTAIL, dev->name, ctc_ch_event_names[event],
-		(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX",
+		(CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ? "RX" : "TX",
 		fsm_getstate_str(fi));
 
-	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+	if (CHANNEL_DIRECTION(ch->flags) == CTCM_READ) {
 		fsm_newstate(fi, CTC_STATE_RXERR);
 		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
 	} else {
@@ -945,7 +947,7 @@ static void ctcm_chx_rxdisc(fsm_instance
 	fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
 
 	fsm_newstate(fi, CTC_STATE_DTERM);
-	ch2 = priv->channel[WRITE];
+	ch2 = priv->channel[CTCM_WRITE];
 	fsm_newstate(ch2->fsm, CTC_STATE_DTERM);
 
 	ccw_device_halt(ch->cdev, (unsigned long)ch);
@@ -1074,13 +1076,13 @@ static void ctcm_chx_iofatal(fsm_instanc
 	fsm_deltimer(&ch->timer);
 	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 		"%s: %s: %s unrecoverable channel error",
-			CTCM_FUNTAIL, ch->id, rd == READ ? "RX" : "TX");
+			CTCM_FUNTAIL, ch->id, rd == CTCM_READ ? "RX" : "TX");
 
 	if (IS_MPC(ch)) {
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
 	}
-	if (rd == READ) {
+	if (rd == CTCM_READ) {
 		fsm_newstate(fi, CTC_STATE_RXERR);
 		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
 	} else {
@@ -1503,7 +1505,7 @@ static void ctcmpc_chx_firstio(fsm_insta
 	switch (fsm_getstate(fi)) {
 	case CTC_STATE_STARTRETRY:
 	case CTC_STATE_SETUPWAIT:
-		if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		if (CHANNEL_DIRECTION(ch->flags) == CTCM_READ) {
 			ctcmpc_chx_rxidle(fi, event, arg);
 		} else {
 			fsm_newstate(fi, CTC_STATE_TXIDLE);
@@ -1514,7 +1516,7 @@ static void ctcmpc_chx_firstio(fsm_insta
 		break;
 	};
 
-	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == READ)
+	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == CTCM_READ)
 		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
 
 done:
@@ -1753,8 +1755,8 @@ static void ctcmpc_chx_send_sweep(fsm_in
 	struct net_device *dev = ach->netdev;
 	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
-	struct channel *wch = priv->channel[WRITE];
-	struct channel *rch = priv->channel[READ];
+	struct channel *wch = priv->channel[CTCM_WRITE];
+	struct channel *rch = priv->channel[CTCM_READ];
 	struct sk_buff *skb;
 	struct th_sweep *header;
 	int rc = 0;
@@ -2070,7 +2072,7 @@ static void dev_action_start(fsm_instanc
 	fsm_newstate(fi, DEV_STATE_STARTWAIT_RXTX);
 	if (IS_MPC(priv))
 		priv->mpcg->channels_terminating = 0;
-	for (direction = READ; direction <= WRITE; direction++) {
+	for (direction = CTCM_READ; direction <= CTCM_WRITE; direction++) {
 		struct channel *ch = priv->channel[direction];
 		fsm_event(ch->fsm, CTC_EVENT_START, ch);
 	}
@@ -2092,7 +2094,7 @@ static void dev_action_stop(fsm_instance
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
 
 	fsm_newstate(fi, DEV_STATE_STOPWAIT_RXTX);
-	for (direction = READ; direction <= WRITE; direction++) {
+	for (direction = CTCM_READ; direction <= CTCM_WRITE; direction++) {
 		struct channel *ch = priv->channel[direction];
 		fsm_event(ch->fsm, CTC_EVENT_STOP, ch);
 		ch->th_seq_num = 0x00;
@@ -2183,11 +2185,11 @@ static void dev_action_chup(fsm_instance
 
 	if (IS_MPC(priv)) {
 		if (event == DEV_EVENT_RXUP)
-			mpc_channel_action(priv->channel[READ],
-				READ, MPC_CHANNEL_ADD);
+			mpc_channel_action(priv->channel[CTCM_READ],
+				CTCM_READ, MPC_CHANNEL_ADD);
 		else
-			mpc_channel_action(priv->channel[WRITE],
-				WRITE, MPC_CHANNEL_ADD);
+			mpc_channel_action(priv->channel[CTCM_WRITE],
+				CTCM_WRITE, MPC_CHANNEL_ADD);
 	}
 }
 
@@ -2239,11 +2241,11 @@ static void dev_action_chdown(fsm_instan
 	}
 	if (IS_MPC(priv)) {
 		if (event == DEV_EVENT_RXDOWN)
-			mpc_channel_action(priv->channel[READ],
-				READ, MPC_CHANNEL_REMOVE);
+			mpc_channel_action(priv->channel[CTCM_READ],
+				CTCM_READ, MPC_CHANNEL_REMOVE);
 		else
-			mpc_channel_action(priv->channel[WRITE],
-				WRITE, MPC_CHANNEL_REMOVE);
+			mpc_channel_action(priv->channel[CTCM_WRITE],
+				CTCM_WRITE, MPC_CHANNEL_REMOVE);
 	}
 }
 
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.c linux-2.6-patched/drivers/s390/net/ctcm_main.c
--- linux-2.6/drivers/s390/net/ctcm_main.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.c	2010-08-12 13:29:50.000000000 +0200
@@ -267,7 +267,7 @@ static struct channel *channel_get(enum 
 		else {
 			ch->flags |= CHANNEL_FLAGS_INUSE;
 			ch->flags &= ~CHANNEL_FLAGS_RWMASK;
-			ch->flags |= (direction == WRITE)
+			ch->flags |= (direction == CTCM_WRITE)
 			    ? CHANNEL_FLAGS_WRITE : CHANNEL_FLAGS_READ;
 			fsm_newstate(ch->fsm, CTC_STATE_STOPPED);
 		}
@@ -388,7 +388,8 @@ int ctcm_ch_alloc_buffer(struct channel 
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 			"%s(%s): %s trans_skb allocation error",
 			CTCM_FUNTAIL, ch->id,
-			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+			(CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ?
+				"RX" : "TX");
 		return -ENOMEM;
 	}
 
@@ -399,7 +400,8 @@ int ctcm_ch_alloc_buffer(struct channel 
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 			"%s(%s): %s set norm_cda failed",
 			CTCM_FUNTAIL, ch->id,
-			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+			(CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ?
+				"RX" : "TX");
 		return -ENOMEM;
 	}
 
@@ -603,14 +605,14 @@ static void ctcmpc_send_sweep_req(struct
 
 	priv = dev->ml_priv;
 	grp = priv->mpcg;
-	ch = priv->channel[WRITE];
+	ch = priv->channel[CTCM_WRITE];
 
 	/* sweep processing is not complete until response and request */
 	/* has completed for all read channels in group		       */
 	if (grp->in_sweep == 0) {
 		grp->in_sweep = 1;
-		grp->sweep_rsp_pend_num = grp->active_channels[READ];
-		grp->sweep_req_pend_num = grp->active_channels[READ];
+		grp->sweep_rsp_pend_num = grp->active_channels[CTCM_READ];
+		grp->sweep_req_pend_num = grp->active_channels[CTCM_READ];
 	}
 
 	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC|GFP_DMA);
@@ -911,7 +913,7 @@ static int ctcm_tx(struct sk_buff *skb, 
 		return NETDEV_TX_BUSY;
 
 	dev->trans_start = jiffies;
-	if (ctcm_transmit_skb(priv->channel[WRITE], skb) != 0)
+	if (ctcm_transmit_skb(priv->channel[CTCM_WRITE], skb) != 0)
 		return NETDEV_TX_BUSY;
 	return NETDEV_TX_OK;
 }
@@ -994,7 +996,7 @@ static int ctcmpc_tx(struct sk_buff *skb
 	}
 
 	dev->trans_start = jiffies;
-	if (ctcmpc_transmit_skb(priv->channel[WRITE], skb) != 0) {
+	if (ctcmpc_transmit_skb(priv->channel[CTCM_WRITE], skb) != 0) {
 		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
 			"%s(%s): device error - dropped",
 					CTCM_FUNTAIL, dev->name);
@@ -1035,7 +1037,7 @@ static int ctcm_change_mtu(struct net_de
 		return -EINVAL;
 
 	priv = dev->ml_priv;
-	max_bufsize = priv->channel[READ]->max_bufsize;
+	max_bufsize = priv->channel[CTCM_READ]->max_bufsize;
 
 	if (IS_MPC(priv)) {
 		if (new_mtu > max_bufsize - TH_HEADER_LENGTH)
@@ -1226,10 +1228,10 @@ static void ctcm_irq_handler(struct ccw_
 	priv = dev_get_drvdata(&cgdev->dev);
 
 	/* Try to extract channel from driver data. */
-	if (priv->channel[READ]->cdev == cdev)
-		ch = priv->channel[READ];
-	else if (priv->channel[WRITE]->cdev == cdev)
-		ch = priv->channel[WRITE];
+	if (priv->channel[CTCM_READ]->cdev == cdev)
+		ch = priv->channel[CTCM_READ];
+	else if (priv->channel[CTCM_WRITE]->cdev == cdev)
+		ch = priv->channel[CTCM_WRITE];
 	else {
 		dev_err(&cdev->dev,
 			"%s: Internal error: Can't determine channel for "
@@ -1587,13 +1589,13 @@ static int ctcm_new_device(struct ccwgro
 		goto out_ccw2;
 	}
 
-	for (direction = READ; direction <= WRITE; direction++) {
+	for (direction = CTCM_READ; direction <= CTCM_WRITE; direction++) {
 		priv->channel[direction] =
-		    channel_get(type, direction == READ ? read_id : write_id,
-				direction);
+			channel_get(type, direction == CTCM_READ ?
+				read_id : write_id, direction);
 		if (priv->channel[direction] == NULL) {
-			if (direction == WRITE)
-				channel_free(priv->channel[READ]);
+			if (direction == CTCM_WRITE)
+				channel_free(priv->channel[CTCM_READ]);
 			goto out_dev;
 		}
 		priv->channel[direction]->netdev = dev;
@@ -1617,13 +1619,13 @@ static int ctcm_new_device(struct ccwgro
 
 	dev_info(&dev->dev,
 		"setup OK : r/w = %s/%s, protocol : %d\n",
-			priv->channel[READ]->id,
-			priv->channel[WRITE]->id, priv->protocol);
+			priv->channel[CTCM_READ]->id,
+			priv->channel[CTCM_WRITE]->id, priv->protocol);
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
 		"setup(%s) OK : r/w = %s/%s, protocol : %d", dev->name,
-			priv->channel[READ]->id,
-			priv->channel[WRITE]->id, priv->protocol);
+			priv->channel[CTCM_READ]->id,
+			priv->channel[CTCM_WRITE]->id, priv->protocol);
 
 	return 0;
 out_unregister:
@@ -1635,10 +1637,10 @@ out_ccw2:
 out_ccw1:
 	ccw_device_set_offline(cgdev->cdev[0]);
 out_remove_channel2:
-	readc = channel_get(type, read_id, READ);
+	readc = channel_get(type, read_id, CTCM_READ);
 	channel_remove(readc);
 out_remove_channel1:
-	writec = channel_get(type, write_id, WRITE);
+	writec = channel_get(type, write_id, CTCM_WRITE);
 	channel_remove(writec);
 out_err_result:
 	return result;
@@ -1660,19 +1662,19 @@ static int ctcm_shutdown_device(struct c
 	if (!priv)
 		return -ENODEV;
 
-	if (priv->channel[READ]) {
-		dev = priv->channel[READ]->netdev;
+	if (priv->channel[CTCM_READ]) {
+		dev = priv->channel[CTCM_READ]->netdev;
 		CTCM_DBF_DEV(SETUP, dev, "");
 		/* Close the device */
 		ctcm_close(dev);
 		dev->flags &= ~IFF_RUNNING;
 		ctcm_remove_attributes(&cgdev->dev);
-		channel_free(priv->channel[READ]);
+		channel_free(priv->channel[CTCM_READ]);
 	} else
 		dev = NULL;
 
-	if (priv->channel[WRITE])
-		channel_free(priv->channel[WRITE]);
+	if (priv->channel[CTCM_WRITE])
+		channel_free(priv->channel[CTCM_WRITE]);
 
 	if (dev) {
 		unregister_netdev(dev);
@@ -1685,11 +1687,11 @@ static int ctcm_shutdown_device(struct c
 	ccw_device_set_offline(cgdev->cdev[1]);
 	ccw_device_set_offline(cgdev->cdev[0]);
 
-	if (priv->channel[READ])
-		channel_remove(priv->channel[READ]);
-	if (priv->channel[WRITE])
-		channel_remove(priv->channel[WRITE]);
-	priv->channel[READ] = priv->channel[WRITE] = NULL;
+	if (priv->channel[CTCM_READ])
+		channel_remove(priv->channel[CTCM_READ]);
+	if (priv->channel[CTCM_WRITE])
+		channel_remove(priv->channel[CTCM_WRITE]);
+	priv->channel[CTCM_READ] = priv->channel[CTCM_WRITE] = NULL;
 
 	return 0;
 
@@ -1720,11 +1722,11 @@ static int ctcm_pm_suspend(struct ccwgro
 
 	if (gdev->state == CCWGROUP_OFFLINE)
 		return 0;
-	netif_device_detach(priv->channel[READ]->netdev);
-	ctcm_close(priv->channel[READ]->netdev);
+	netif_device_detach(priv->channel[CTCM_READ]->netdev);
+	ctcm_close(priv->channel[CTCM_READ]->netdev);
 	if (!wait_event_timeout(priv->fsm->wait_q,
 	    fsm_getstate(priv->fsm) == DEV_STATE_STOPPED, CTCM_TIME_5_SEC)) {
-		netif_device_attach(priv->channel[READ]->netdev);
+		netif_device_attach(priv->channel[CTCM_READ]->netdev);
 		return -EBUSY;
 	}
 	ccw_device_set_offline(gdev->cdev[1]);
@@ -1745,9 +1747,9 @@ static int ctcm_pm_resume(struct ccwgrou
 	rc = ccw_device_set_online(gdev->cdev[0]);
 	if (rc)
 		goto err_out;
-	ctcm_open(priv->channel[READ]->netdev);
+	ctcm_open(priv->channel[CTCM_READ]->netdev);
 err_out:
-	netif_device_attach(priv->channel[READ]->netdev);
+	netif_device_attach(priv->channel[CTCM_READ]->netdev);
 	return rc;
 }
 
diff -urpN linux-2.6/drivers/s390/net/ctcm_main.h linux-2.6-patched/drivers/s390/net/ctcm_main.h
--- linux-2.6/drivers/s390/net/ctcm_main.h	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_main.h	2010-08-12 13:29:50.000000000 +0200
@@ -111,8 +111,8 @@ enum ctcm_channel_types {
 
 #define CTCM_INITIAL_BLOCKLEN	2
 
-#define READ			0
-#define WRITE			1
+#define CTCM_READ		0
+#define CTCM_WRITE		1
 
 #define CTCM_ID_SIZE		20+3
 
diff -urpN linux-2.6/drivers/s390/net/ctcm_mpc.c linux-2.6-patched/drivers/s390/net/ctcm_mpc.c
--- linux-2.6/drivers/s390/net/ctcm_mpc.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_mpc.c	2010-08-12 13:29:50.000000000 +0200
@@ -419,8 +419,8 @@ void ctc_mpc_establish_connectivity(int 
 		return;
 	priv = dev->ml_priv;
 	grp = priv->mpcg;
-	rch = priv->channel[READ];
-	wch = priv->channel[WRITE];
+	rch = priv->channel[CTCM_READ];
+	wch = priv->channel[CTCM_WRITE];
 
 	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_INFO,
 			"%s(%s): state=%s",
@@ -578,7 +578,7 @@ void ctc_mpc_flow_control(int port_num, 
 			"%s: %s: flowc = %d",
 				CTCM_FUNTAIL, dev->name, flowc);
 
-	rch = priv->channel[READ];
+	rch = priv->channel[CTCM_READ];
 
 	mpcg_state = fsm_getstate(grp->fsm);
 	switch (flowc) {
@@ -622,7 +622,7 @@ static void mpc_rcvd_sweep_resp(struct m
 	struct net_device *dev = rch->netdev;
 	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group  *grp = priv->mpcg;
-	struct channel	  *ch = priv->channel[WRITE];
+	struct channel	  *ch = priv->channel[CTCM_WRITE];
 
 	CTCM_PR_DEBUG("%s: ch=0x%p id=%s\n", __func__, ch, ch->id);
 	CTCM_D3_DUMP((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
@@ -656,7 +656,7 @@ static void ctcmpc_send_sweep_resp(struc
 	int rc = 0;
 	struct th_sweep *header;
 	struct sk_buff *sweep_skb;
-	struct channel *ch  = priv->channel[WRITE];
+	struct channel *ch  = priv->channel[CTCM_WRITE];
 
 	CTCM_PR_DEBUG("%s: ch=0x%p id=%s\n", __func__, rch, rch->id);
 
@@ -712,7 +712,7 @@ static void mpc_rcvd_sweep_req(struct mp
 	struct net_device *dev     = rch->netdev;
 	struct ctcm_priv  *priv = dev->ml_priv;
 	struct mpc_group  *grp  = priv->mpcg;
-	struct channel	  *ch	   = priv->channel[WRITE];
+	struct channel	  *ch	   = priv->channel[CTCM_WRITE];
 
 	if (do_debug)
 		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
@@ -721,8 +721,8 @@ static void mpc_rcvd_sweep_req(struct mp
 	if (grp->in_sweep == 0) {
 		grp->in_sweep = 1;
 		ctcm_test_and_set_busy(dev);
-		grp->sweep_req_pend_num = grp->active_channels[READ];
-		grp->sweep_rsp_pend_num = grp->active_channels[READ];
+		grp->sweep_req_pend_num = grp->active_channels[CTCM_READ];
+		grp->sweep_rsp_pend_num = grp->active_channels[CTCM_READ];
 	}
 
 	CTCM_D3_DUMP((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
@@ -906,14 +906,14 @@ void mpc_group_ready(unsigned long adev)
 	fsm_newstate(grp->fsm, MPCG_STATE_READY);
 
 	/* Put up a read on the channel */
-	ch = priv->channel[READ];
+	ch = priv->channel[CTCM_READ];
 	ch->pdu_seq = 0;
 	CTCM_PR_DBGDATA("ctcmpc: %s() ToDCM_pdu_seq= %08x\n" ,
 			__func__, ch->pdu_seq);
 
 	ctcmpc_chx_rxidle(ch->fsm, CTC_EVENT_START, ch);
 	/* Put the write channel in idle state */
-	ch = priv->channel[WRITE];
+	ch = priv->channel[CTCM_WRITE];
 	if (ch->collect_len > 0) {
 		spin_lock(&ch->collect_lock);
 		ctcm_purge_skb_queue(&ch->collect_queue);
@@ -960,7 +960,8 @@ void mpc_channel_action(struct channel *
 		"%s: %i / Grp:%s total_channels=%i, active_channels: "
 		"read=%i, write=%i\n", __func__, action,
 		fsm_getstate_str(grp->fsm), grp->num_channel_paths,
-		grp->active_channels[READ], grp->active_channels[WRITE]);
+		grp->active_channels[CTCM_READ],
+		grp->active_channels[CTCM_WRITE]);
 
 	if ((action == MPC_CHANNEL_ADD) && (ch->in_mpcgroup == 0)) {
 		grp->num_channel_paths++;
@@ -994,10 +995,11 @@ void mpc_channel_action(struct channel *
 				grp->xid_skb->data,
 				grp->xid_skb->len);
 
-		ch->xid->xid2_dlc_type = ((CHANNEL_DIRECTION(ch->flags) == READ)
+		ch->xid->xid2_dlc_type =
+			((CHANNEL_DIRECTION(ch->flags) == CTCM_READ)
 				? XID2_READ_SIDE : XID2_WRITE_SIDE);
 
-		if (CHANNEL_DIRECTION(ch->flags) == WRITE)
+		if (CHANNEL_DIRECTION(ch->flags) == CTCM_WRITE)
 			ch->xid->xid2_buf_len = 0x00;
 
 		ch->xid_skb->data = ch->xid_skb_data;
@@ -1006,8 +1008,8 @@ void mpc_channel_action(struct channel *
 
 		fsm_newstate(ch->fsm, CH_XID0_PENDING);
 
-		if ((grp->active_channels[READ]  > 0) &&
-		    (grp->active_channels[WRITE] > 0) &&
+		if ((grp->active_channels[CTCM_READ] > 0) &&
+		    (grp->active_channels[CTCM_WRITE] > 0) &&
 			(fsm_getstate(grp->fsm) < MPCG_STATE_XID2INITW)) {
 			fsm_newstate(grp->fsm, MPCG_STATE_XID2INITW);
 			CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_NOTICE,
@@ -1027,10 +1029,10 @@ void mpc_channel_action(struct channel *
 		if (grp->channels_terminating)
 					goto done;
 
-		if (((grp->active_channels[READ] == 0) &&
-					(grp->active_channels[WRITE] > 0))
-			|| ((grp->active_channels[WRITE] == 0) &&
-					(grp->active_channels[READ] > 0)))
+		if (((grp->active_channels[CTCM_READ] == 0) &&
+					(grp->active_channels[CTCM_WRITE] > 0))
+			|| ((grp->active_channels[CTCM_WRITE] == 0) &&
+					(grp->active_channels[CTCM_READ] > 0)))
 			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 	}
 done:
@@ -1038,7 +1040,8 @@ done:
 		"exit %s: %i / Grp:%s total_channels=%i, active_channels: "
 		"read=%i, write=%i\n", __func__, action,
 		fsm_getstate_str(grp->fsm), grp->num_channel_paths,
-		grp->active_channels[READ], grp->active_channels[WRITE]);
+		grp->active_channels[CTCM_READ],
+		grp->active_channels[CTCM_WRITE]);
 
 	CTCM_PR_DEBUG("exit %s: ch=0x%p id=%s\n", __func__, ch, ch->id);
 }
@@ -1392,8 +1395,8 @@ static void mpc_action_go_inop(fsm_insta
 		(grp->port_persist == 0))
 		fsm_deltimer(&priv->restart_timer);
 
-	wch = priv->channel[WRITE];
-	rch = priv->channel[READ];
+	wch = priv->channel[CTCM_WRITE];
+	rch = priv->channel[CTCM_READ];
 
 	switch (grp->saved_state) {
 	case MPCG_STATE_RESET:
@@ -1480,8 +1483,8 @@ static void mpc_action_timeout(fsm_insta
 
 	priv = dev->ml_priv;
 	grp = priv->mpcg;
-	wch = priv->channel[WRITE];
-	rch = priv->channel[READ];
+	wch = priv->channel[CTCM_WRITE];
+	rch = priv->channel[CTCM_READ];
 
 	switch (fsm_getstate(grp->fsm)) {
 	case MPCG_STATE_XID2INITW:
@@ -1586,7 +1589,7 @@ static int mpc_validate_xid(struct mpcg_
 	CTCM_D3_DUMP((char *)xid, XID2_LENGTH);
 
 	/*the received direction should be the opposite of ours  */
-	if (((CHANNEL_DIRECTION(ch->flags) == READ) ? XID2_WRITE_SIDE :
+	if (((CHANNEL_DIRECTION(ch->flags) == CTCM_READ) ? XID2_WRITE_SIDE :
 				XID2_READ_SIDE) != xid->xid2_dlc_type) {
 		rc = 2;
 		/* XID REJECTED: r/w channel pairing mismatch */
@@ -1912,7 +1915,7 @@ static void mpc_action_doxid7(fsm_instan
 	if (grp == NULL)
 		return;
 
-	for (direction = READ; direction <= WRITE; direction++)	{
+	for (direction = CTCM_READ; direction <= CTCM_WRITE; direction++) {
 		struct channel *ch = priv->channel[direction];
 		struct xid2 *thisxid = ch->xid;
 		ch->xid_skb->data = ch->xid_skb_data;
@@ -2152,14 +2155,15 @@ static int mpc_send_qllc_discontact(stru
 			return -ENOMEM;
 		}
 
-		*((__u32 *)skb_push(skb, 4)) = priv->channel[READ]->pdu_seq;
-		priv->channel[READ]->pdu_seq++;
+		*((__u32 *)skb_push(skb, 4)) =
+			priv->channel[CTCM_READ]->pdu_seq;
+		priv->channel[CTCM_READ]->pdu_seq++;
 		CTCM_PR_DBGDATA("ctcmpc: %s ToDCM_pdu_seq= %08x\n",
-				__func__, priv->channel[READ]->pdu_seq);
+				__func__, priv->channel[CTCM_READ]->pdu_seq);
 
 		/* receipt of CC03 resets anticipated sequence number on
 		      receiving side */
-		priv->channel[READ]->pdu_seq = 0x00;
+		priv->channel[CTCM_READ]->pdu_seq = 0x00;
 		skb_reset_mac_header(skb);
 		skb->dev = dev;
 		skb->protocol = htons(ETH_P_SNAP);
diff -urpN linux-2.6/drivers/s390/net/ctcm_sysfs.c linux-2.6-patched/drivers/s390/net/ctcm_sysfs.c
--- linux-2.6/drivers/s390/net/ctcm_sysfs.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/ctcm_sysfs.c	2010-08-12 13:29:50.000000000 +0200
@@ -38,8 +38,8 @@ static ssize_t ctcm_buffer_write(struct 
 	int bs1;
 	struct ctcm_priv *priv = dev_get_drvdata(dev);
 
-	if (!(priv && priv->channel[READ] &&
-			(ndev = priv->channel[READ]->netdev))) {
+	ndev = priv->channel[CTCM_READ]->netdev;
+	if (!(priv && priv->channel[CTCM_READ] && ndev)) {
 		CTCM_DBF_TEXT(SETUP, CTC_DBF_ERROR, "bfnondev");
 		return -ENODEV;
 	}
@@ -55,12 +55,12 @@ static ssize_t ctcm_buffer_write(struct 
 	    (bs1 < (ndev->mtu + LL_HEADER_LENGTH + 2)))
 					goto einval;
 
-	priv->channel[READ]->max_bufsize = bs1;
-	priv->channel[WRITE]->max_bufsize = bs1;
+	priv->channel[CTCM_READ]->max_bufsize = bs1;
+	priv->channel[CTCM_WRITE]->max_bufsize = bs1;
 	if (!(ndev->flags & IFF_RUNNING))
 		ndev->mtu = bs1 - LL_HEADER_LENGTH - 2;
-	priv->channel[READ]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
-	priv->channel[WRITE]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
+	priv->channel[CTCM_READ]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
+	priv->channel[CTCM_WRITE]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
 
 	CTCM_DBF_DEV(SETUP, ndev, buf);
 	return count;
@@ -85,9 +85,9 @@ static void ctcm_print_statistics(struct
 	p += sprintf(p, "  Device FSM state: %s\n",
 		     fsm_getstate_str(priv->fsm));
 	p += sprintf(p, "  RX channel FSM state: %s\n",
-		     fsm_getstate_str(priv->channel[READ]->fsm));
+		     fsm_getstate_str(priv->channel[CTCM_READ]->fsm));
 	p += sprintf(p, "  TX channel FSM state: %s\n",
-		     fsm_getstate_str(priv->channel[WRITE]->fsm));
+		     fsm_getstate_str(priv->channel[CTCM_WRITE]->fsm));
 	p += sprintf(p, "  Max. TX buffer used: %ld\n",
 		     priv->channel[WRITE]->prof.maxmulti);
 	p += sprintf(p, "  Max. chained SKBs: %ld\n",
@@ -102,7 +102,7 @@ static void ctcm_print_statistics(struct
 		     priv->channel[WRITE]->prof.tx_time);
 
 	printk(KERN_INFO "Statistics for %s:\n%s",
-				priv->channel[WRITE]->netdev->name, sbuf);
+				priv->channel[CTCM_WRITE]->netdev->name, sbuf);
 	kfree(sbuf);
 	return;
 }
@@ -125,7 +125,7 @@ static ssize_t stats_write(struct device
 		return -ENODEV;
 	/* Reset statistics */
 	memset(&priv->channel[WRITE]->prof, 0,
-				sizeof(priv->channel[WRITE]->prof));
+				sizeof(priv->channel[CTCM_WRITE]->prof));
 	return count;
 }
 

