From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/2] [PATCH] claw: rename READ/WRITE defines to avoid redefinitions
Date: Thu, 12 Aug 2010 13:58:27 +0200
Message-ID: <20100812120608.313771000@linux.vnet.ibm.com>
References: <20100812115826.983015000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:50389 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758863Ab0HLMGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 08:06:11 -0400
Content-Disposition: inline; filename=601-claw-rename.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

READ/WRITE seems to be a bit too generic for defines in a device driver.
Just rename them to READ_CHANNEL/WRITE_CHANNEL which should suffice.

Fixes this:

In file included from drivers/s390/net/claw.c:93:
drivers/s390/net/claw.h:78:1: warning: "WRITE" redefined
In file included from /home2/heicarst/linux-2.6/arch/s390/include/asm/debug.h:12,
                 from drivers/s390/net/claw.c:68:
include/linux/fs.h:156:1: warning: this is the location of the previous definition

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |  118 ++++++++++++++++++++++++------------------------
 drivers/s390/net/claw.h |    4 -
 2 files changed, 61 insertions(+), 61 deletions(-)

--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -386,7 +386,7 @@ claw_tx(struct sk_buff *skb, struct net_
         struct chbk *p_ch;
 
 	CLAW_DBF_TEXT(4, trace, "claw_tx");
-        p_ch=&privptr->channel[WRITE];
+	p_ch = &privptr->channel[WRITE_CHANNEL];
         spin_lock_irqsave(get_ccwdev_lock(p_ch->cdev), saveflags);
         rc=claw_hw_tx( skb, dev, 1 );
         spin_unlock_irqrestore(get_ccwdev_lock(p_ch->cdev), saveflags);
@@ -407,7 +407,7 @@ static struct sk_buff *
 claw_pack_skb(struct claw_privbk *privptr)
 {
 	struct sk_buff *new_skb,*held_skb;
-	struct chbk *p_ch = &privptr->channel[WRITE];
+	struct chbk *p_ch = &privptr->channel[WRITE_CHANNEL];
 	struct claw_env  *p_env = privptr->p_env;
 	int	pkt_cnt,pk_ind,so_far;
 
@@ -515,15 +515,15 @@ claw_open(struct net_device *dev)
 		privptr->p_env->write_size=CLAW_FRAME_SIZE;
 	}
         claw_set_busy(dev);
-	tasklet_init(&privptr->channel[READ].tasklet, claw_irq_tasklet,
-        	(unsigned long) &privptr->channel[READ]);
+	tasklet_init(&privptr->channel[READ_CHANNEL].tasklet, claw_irq_tasklet,
+		(unsigned long) &privptr->channel[READ_CHANNEL]);
         for ( i = 0; i < 2;  i++) {
 		CLAW_DBF_TEXT_(2, trace, "opn_ch%d", i);
                 init_waitqueue_head(&privptr->channel[i].wait);
 		/* skb_queue_head_init(&p_ch->io_queue); */
-		if (i == WRITE)
+		if (i == WRITE_CHANNEL)
 			skb_queue_head_init(
-				&privptr->channel[WRITE].collect_queue);
+				&privptr->channel[WRITE_CHANNEL].collect_queue);
                 privptr->channel[i].flag_a = 0;
                 privptr->channel[i].IO_active = 0;
                 privptr->channel[i].flag  &= ~CLAW_TIMER;
@@ -551,12 +551,12 @@ claw_open(struct net_device *dev)
                 if((privptr->channel[i].flag & CLAW_TIMER) == 0x00)
                         del_timer(&timer);
         }
-        if ((((privptr->channel[READ].last_dstat |
-		privptr->channel[WRITE].last_dstat) &
+	if ((((privptr->channel[READ_CHANNEL].last_dstat |
+		privptr->channel[WRITE_CHANNEL].last_dstat) &
            ~(DEV_STAT_CHN_END | DEV_STAT_DEV_END)) != 0x00) ||
-           (((privptr->channel[READ].flag |
-	   	privptr->channel[WRITE].flag) & CLAW_TIMER) != 0x00)) {
-		dev_info(&privptr->channel[READ].cdev->dev,
+	   (((privptr->channel[READ_CHANNEL].flag |
+		privptr->channel[WRITE_CHANNEL].flag) & CLAW_TIMER) != 0x00)) {
+		dev_info(&privptr->channel[READ_CHANNEL].cdev->dev,
 			"%s: remote side is not ready\n", dev->name);
 		CLAW_DBF_TEXT(2, trace, "notrdy");
 
@@ -608,8 +608,8 @@ claw_open(struct net_device *dev)
                         }
                 }
 		privptr->buffs_alloc = 0;
-		privptr->channel[READ].flag= 0x00;
-		privptr->channel[WRITE].flag = 0x00;
+		privptr->channel[READ_CHANNEL].flag = 0x00;
+		privptr->channel[WRITE_CHANNEL].flag = 0x00;
                 privptr->p_buff_ccw=NULL;
                 privptr->p_buff_read=NULL;
                 privptr->p_buff_write=NULL;
@@ -652,10 +652,10 @@ claw_irq_handler(struct ccw_device *cdev
         }
 
 	/* Try to extract channel from driver data. */
-	if (privptr->channel[READ].cdev == cdev)
-		p_ch = &privptr->channel[READ];
-	else if (privptr->channel[WRITE].cdev == cdev)
-		p_ch = &privptr->channel[WRITE];
+	if (privptr->channel[READ_CHANNEL].cdev == cdev)
+		p_ch = &privptr->channel[READ_CHANNEL];
+	else if (privptr->channel[WRITE_CHANNEL].cdev == cdev)
+		p_ch = &privptr->channel[WRITE_CHANNEL];
 	else {
 		dev_warn(&cdev->dev, "The device is not a CLAW device\n");
 		CLAW_DBF_TEXT(2, trace, "badchan");
@@ -813,7 +813,7 @@ claw_irq_handler(struct ccw_device *cdev
 			claw_clearbit_busy(TB_TX, dev);
 			claw_clear_busy(dev);
 		}
-		p_ch_r = (struct chbk *)&privptr->channel[READ];
+		p_ch_r = (struct chbk *)&privptr->channel[READ_CHANNEL];
 		if (test_and_set_bit(CLAW_BH_ACTIVE,
 			(void *)&p_ch_r->flag_a) == 0)
 			tasklet_schedule(&p_ch_r->tasklet);
@@ -878,13 +878,13 @@ claw_release(struct net_device *dev)
         for ( i = 1; i >=0 ;  i--) {
                 spin_lock_irqsave(
 			get_ccwdev_lock(privptr->channel[i].cdev), saveflags);
-             /*   del_timer(&privptr->channel[READ].timer);  */
+	     /*   del_timer(&privptr->channel[READ_CHANNEL].timer);  */
  		privptr->channel[i].claw_state = CLAW_STOP;
                 privptr->channel[i].IO_active = 0;
                 parm = (unsigned long) &privptr->channel[i];
-		if (i == WRITE)
+		if (i == WRITE_CHANNEL)
 			claw_purge_skb_queue(
-				&privptr->channel[WRITE].collect_queue);
+				&privptr->channel[WRITE_CHANNEL].collect_queue);
                 rc = ccw_device_halt (privptr->channel[i].cdev, parm);
 	        if (privptr->system_validate_comp==0x00)  /* never opened? */
                    init_waitqueue_head(&privptr->channel[i].wait);
@@ -971,16 +971,16 @@ claw_release(struct net_device *dev)
         privptr->mtc_skipping = 1;
         privptr->mtc_offset=0;
 
-        if (((privptr->channel[READ].last_dstat |
-		privptr->channel[WRITE].last_dstat) &
+	if (((privptr->channel[READ_CHANNEL].last_dstat |
+		privptr->channel[WRITE_CHANNEL].last_dstat) &
 		~(DEV_STAT_CHN_END | DEV_STAT_DEV_END)) != 0x00) {
-		dev_warn(&privptr->channel[READ].cdev->dev,
+		dev_warn(&privptr->channel[READ_CHANNEL].cdev->dev,
 			"Deactivating %s completed with incorrect"
 			" subchannel status "
 			"(read %02x, write %02x)\n",
                 dev->name,
-		privptr->channel[READ].last_dstat,
-		privptr->channel[WRITE].last_dstat);
+		privptr->channel[READ_CHANNEL].last_dstat,
+		privptr->channel[WRITE_CHANNEL].last_dstat);
 		 CLAW_DBF_TEXT(2, trace, "badclose");
         }
 	CLAW_DBF_TEXT(4, trace, "rlsexit");
@@ -1324,7 +1324,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
 
 	CLAW_DBF_TEXT(4, trace, "hw_tx");
 	privptr = (struct claw_privbk *)(dev->ml_priv);
-        p_ch=(struct chbk *)&privptr->channel[WRITE];
+	p_ch = (struct chbk *)&privptr->channel[WRITE_CHANNEL];
 	p_env =privptr->p_env;
 	claw_free_wrt_buf(dev);	/* Clean up free chain if posible */
         /*  scan the write queue to free any completed write packets   */
@@ -1357,7 +1357,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
                                 claw_strt_out_IO(dev );
                                 claw_free_wrt_buf( dev );
                                 if (privptr->write_free_count==0) {
-					ch = &privptr->channel[WRITE];
+					ch = &privptr->channel[WRITE_CHANNEL];
 					atomic_inc(&skb->users);
 					skb_queue_tail(&ch->collect_queue, skb);
                                 	goto Done;
@@ -1369,7 +1369,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
                 }
                 /*  tx lock  */
                 if (claw_test_and_setbit_busy(TB_TX,dev)) { /* set to busy */
-			ch = &privptr->channel[WRITE];
+			ch = &privptr->channel[WRITE_CHANNEL];
 			atomic_inc(&skb->users);
 			skb_queue_tail(&ch->collect_queue, skb);
                         claw_strt_out_IO(dev );
@@ -1385,7 +1385,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
             privptr->p_write_free_chain == NULL ) {
 
                 claw_setbit_busy(TB_NOBUFFER,dev);
-		ch = &privptr->channel[WRITE];
+		ch = &privptr->channel[WRITE_CHANNEL];
 		atomic_inc(&skb->users);
 		skb_queue_tail(&ch->collect_queue, skb);
 		CLAW_DBF_TEXT(2, trace, "clawbusy");
@@ -1397,7 +1397,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
         while (len_of_data > 0) {
                 p_this_ccw=privptr->p_write_free_chain;  /* get a block */
 		if (p_this_ccw == NULL) { /* lost the race */
-			ch = &privptr->channel[WRITE];
+			ch = &privptr->channel[WRITE_CHANNEL];
 			atomic_inc(&skb->users);
 			skb_queue_tail(&ch->collect_queue, skb);
 			goto Done2;
@@ -2067,7 +2067,7 @@ claw_process_control( struct net_device 
 			*catch up to each other */
 	privptr = dev->ml_priv;
         p_env=privptr->p_env;
-	tdev = &privptr->channel[READ].cdev->dev;
+	tdev = &privptr->channel[READ_CHANNEL].cdev->dev;
 	memcpy( &temp_host_name, p_env->host_name, 8);
         memcpy( &temp_ws_name, p_env->adapter_name , 8);
 	dev_info(tdev, "%s: CLAW device %.8s: "
@@ -2245,7 +2245,7 @@ claw_process_control( struct net_device 
 			dev->name, temp_ws_name,
 			p_ctlbk->linkid);
 			privptr->active_link_ID = p_ctlbk->linkid;
-			p_ch = &privptr->channel[WRITE];
+			p_ch = &privptr->channel[WRITE_CHANNEL];
 			wake_up(&p_ch->wait);  /* wake up claw_open ( WRITE) */
 		break;
 	case CONNECTION_RESPONSE:
@@ -2296,7 +2296,7 @@ claw_process_control( struct net_device 
 				"%s: Confirmed Now packing\n", dev->name);
 				p_env->packing = DO_PACKED;
 			}
-			p_ch = &privptr->channel[WRITE];
+			p_ch = &privptr->channel[WRITE_CHANNEL];
 			wake_up(&p_ch->wait);
 		} else {
 			dev_warn(tdev, "Activating %s failed because of"
@@ -2556,7 +2556,7 @@ unpack_read(struct net_device *dev )
 	p_packd=NULL;
 	privptr = dev->ml_priv;
 
-	p_dev = &privptr->channel[READ].cdev->dev;
+	p_dev = &privptr->channel[READ_CHANNEL].cdev->dev;
 	p_env = privptr->p_env;
         p_this_ccw=privptr->p_read_active_first;
 	while (p_this_ccw!=NULL && p_this_ccw->header.flag!=CLAW_PENDING) {
@@ -2728,7 +2728,7 @@ claw_strt_read (struct net_device *dev, 
         struct ccwbk*p_ccwbk;
         struct chbk *p_ch;
         struct clawh *p_clawh;
-        p_ch=&privptr->channel[READ];
+	p_ch = &privptr->channel[READ_CHANNEL];
 
 	CLAW_DBF_TEXT(4, trace, "StRdNter");
         p_clawh=(struct clawh *)privptr->p_claw_signal_blk;
@@ -2782,7 +2782,7 @@ claw_strt_out_IO( struct net_device *dev
 		return;
 	}
 	privptr = (struct claw_privbk *)dev->ml_priv;
-        p_ch=&privptr->channel[WRITE];
+	p_ch = &privptr->channel[WRITE_CHANNEL];
 
 	CLAW_DBF_TEXT(4, trace, "strt_io");
         p_first_ccw=privptr->p_write_active_first;
@@ -2875,7 +2875,7 @@ claw_free_netdevice(struct net_device * 
 	if (dev->flags & IFF_RUNNING)
 		claw_release(dev);
 	if (privptr) {
-		privptr->channel[READ].ndev = NULL;  /* say it's free */
+		privptr->channel[READ_CHANNEL].ndev = NULL;  /* say it's free */
 	}
 	dev->ml_priv = NULL;
 #ifdef MODULE
@@ -2960,18 +2960,18 @@ claw_new_device(struct ccwgroup_device *
 	struct ccw_dev_id dev_id;
 
 	dev_info(&cgdev->dev, "add for %s\n",
-		 dev_name(&cgdev->cdev[READ]->dev));
+		 dev_name(&cgdev->cdev[READ_CHANNEL]->dev));
 	CLAW_DBF_TEXT(2, setup, "new_dev");
 	privptr = dev_get_drvdata(&cgdev->dev);
-	dev_set_drvdata(&cgdev->cdev[READ]->dev, privptr);
-	dev_set_drvdata(&cgdev->cdev[WRITE]->dev, privptr);
+	dev_set_drvdata(&cgdev->cdev[READ_CHANNEL]->dev, privptr);
+	dev_set_drvdata(&cgdev->cdev[WRITE_CHANNEL]->dev, privptr);
 	if (!privptr)
 		return -ENODEV;
 	p_env = privptr->p_env;
-	ccw_device_get_id(cgdev->cdev[READ], &dev_id);
-	p_env->devno[READ] = dev_id.devno;
-	ccw_device_get_id(cgdev->cdev[WRITE], &dev_id);
-	p_env->devno[WRITE] = dev_id.devno;
+	ccw_device_get_id(cgdev->cdev[READ_CHANNEL], &dev_id);
+	p_env->devno[READ_CHANNEL] = dev_id.devno;
+	ccw_device_get_id(cgdev->cdev[WRITE_CHANNEL], &dev_id);
+	p_env->devno[WRITE_CHANNEL] = dev_id.devno;
 	ret = add_channel(cgdev->cdev[0],0,privptr);
 	if (ret == 0)
 		ret = add_channel(cgdev->cdev[1],1,privptr);
@@ -2980,14 +2980,14 @@ claw_new_device(struct ccwgroup_device *
 			" failed with error code %d\n", ret);
 		goto out;
 	}
-	ret = ccw_device_set_online(cgdev->cdev[READ]);
+	ret = ccw_device_set_online(cgdev->cdev[READ_CHANNEL]);
 	if (ret != 0) {
 		dev_warn(&cgdev->dev,
 			"Setting the read subchannel online"
 			" failed with error code %d\n", ret);
 		goto out;
 	}
-	ret = ccw_device_set_online(cgdev->cdev[WRITE]);
+	ret = ccw_device_set_online(cgdev->cdev[WRITE_CHANNEL]);
 	if (ret != 0) {
 		dev_warn(&cgdev->dev,
 			"Setting the write subchannel online "
@@ -3002,8 +3002,8 @@ claw_new_device(struct ccwgroup_device *
 	}
 	dev->ml_priv = privptr;
 	dev_set_drvdata(&cgdev->dev, privptr);
-	dev_set_drvdata(&cgdev->cdev[READ]->dev, privptr);
-	dev_set_drvdata(&cgdev->cdev[WRITE]->dev, privptr);
+	dev_set_drvdata(&cgdev->cdev[READ_CHANNEL]->dev, privptr);
+	dev_set_drvdata(&cgdev->cdev[WRITE_CHANNEL]->dev, privptr);
 	/* sysfs magic */
         SET_NETDEV_DEV(dev, &cgdev->dev);
 	if (register_netdev(dev) != 0) {
@@ -3021,16 +3021,16 @@ claw_new_device(struct ccwgroup_device *
 			goto out;
 		}
 	}
-	privptr->channel[READ].ndev = dev;
-	privptr->channel[WRITE].ndev = dev;
+	privptr->channel[READ_CHANNEL].ndev = dev;
+	privptr->channel[WRITE_CHANNEL].ndev = dev;
 	privptr->p_env->ndev = dev;
 
 	dev_info(&cgdev->dev, "%s:readsize=%d  writesize=%d "
 		"readbuffer=%d writebuffer=%d read=0x%04x write=0x%04x\n",
                 dev->name, p_env->read_size,
 		p_env->write_size, p_env->read_buffers,
-                p_env->write_buffers, p_env->devno[READ],
-		p_env->devno[WRITE]);
+		p_env->write_buffers, p_env->devno[READ_CHANNEL],
+		p_env->devno[WRITE_CHANNEL]);
 	dev_info(&cgdev->dev, "%s:host_name:%.8s, adapter_name "
 		":%.8s api_type: %.8s\n",
                 dev->name, p_env->host_name,
@@ -3072,10 +3072,10 @@ claw_shutdown_device(struct ccwgroup_dev
 	priv = dev_get_drvdata(&cgdev->dev);
 	if (!priv)
 		return -ENODEV;
-	ndev = priv->channel[READ].ndev;
+	ndev = priv->channel[READ_CHANNEL].ndev;
 	if (ndev) {
 		/* Close the device */
-		dev_info(&cgdev->dev, "%s: shutting down \n",
+		dev_info(&cgdev->dev, "%s: shutting down\n",
 			ndev->name);
 		if (ndev->flags & IFF_RUNNING)
 			ret = claw_release(ndev);
@@ -3083,8 +3083,8 @@ claw_shutdown_device(struct ccwgroup_dev
 		unregister_netdev(ndev);
 		ndev->ml_priv = NULL;  /* cgdev data, not ndev's to free */
 		claw_free_netdevice(ndev, 1);
-		priv->channel[READ].ndev = NULL;
-		priv->channel[WRITE].ndev = NULL;
+		priv->channel[READ_CHANNEL].ndev = NULL;
+		priv->channel[WRITE_CHANNEL].ndev = NULL;
 		priv->p_env->ndev = NULL;
 	}
 	ccw_device_set_offline(cgdev->cdev[1]);
@@ -3115,8 +3115,8 @@ claw_remove_device(struct ccwgroup_devic
 	priv->channel[1].irb=NULL;
 	kfree(priv);
 	dev_set_drvdata(&cgdev->dev, NULL);
-	dev_set_drvdata(&cgdev->cdev[READ]->dev, NULL);
-	dev_set_drvdata(&cgdev->cdev[WRITE]->dev, NULL);
+	dev_set_drvdata(&cgdev->cdev[READ_CHANNEL]->dev, NULL);
+	dev_set_drvdata(&cgdev->cdev[WRITE_CHANNEL]->dev, NULL);
 	put_device(&cgdev->dev);
 
 	return;
--- a/drivers/s390/net/claw.h
+++ b/drivers/s390/net/claw.h
@@ -74,8 +74,8 @@
 #define MAX_ENVELOPE_SIZE       65536
 #define CLAW_DEFAULT_MTU_SIZE   4096
 #define DEF_PACK_BUFSIZE	32768
-#define READ                    0
-#define WRITE                   1
+#define READ_CHANNEL		0
+#define WRITE_CHANNEL		1
 
 #define TB_TX                   0          /* sk buffer handling in process  */
 #define TB_STOP                 1          /* network device stop in process */

