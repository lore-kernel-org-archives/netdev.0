From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/4] claw: netdev->priv vs. netdev->ml_priv
Date: Thu, 21 Aug 2008 17:10:23 +0200
Message-ID: <20080821151652.854940000@linux.vnet.ibm.com>
References: <20080821151021.069615000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:60216 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462AbYHUPRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:17:06 -0400
Content-Disposition: inline; filename=607-claw-mlpriv.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Use netdev->ml_priv instead of netdev->priv

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |   60 ++++++++++++++++++++++++------------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.c
+++ linux-2.6-uschi/drivers/s390/net/claw.c
@@ -133,14 +133,14 @@ claw_register_debug_facility(void)
 static inline void
 claw_set_busy(struct net_device *dev)
 {
- ((struct claw_privbk *) dev->priv)->tbusy=1;
+ ((struct claw_privbk *)dev->ml_priv)->tbusy = 1;
  eieio();
 }
 
 static inline void
 claw_clear_busy(struct net_device *dev)
 {
-	clear_bit(0, &(((struct claw_privbk *) dev->priv)->tbusy));
+	clear_bit(0, &(((struct claw_privbk *) dev->ml_priv)->tbusy));
 	netif_wake_queue(dev);
 	eieio();
 }
@@ -149,20 +149,20 @@ static inline int
 claw_check_busy(struct net_device *dev)
 {
 	eieio();
-	return ((struct claw_privbk *) dev->priv)->tbusy;
+	return ((struct claw_privbk *) dev->ml_priv)->tbusy;
 }
 
 static inline void
 claw_setbit_busy(int nr,struct net_device *dev)
 {
 	netif_stop_queue(dev);
- 	set_bit(nr, (void *)&(((struct claw_privbk *)dev->priv)->tbusy));
+	set_bit(nr, (void *)&(((struct claw_privbk *)dev->ml_priv)->tbusy));
 }
 
 static inline void
 claw_clearbit_busy(int nr,struct net_device *dev)
 {
- 	clear_bit(nr,(void *)&(((struct claw_privbk *)dev->priv)->tbusy));
+	clear_bit(nr, (void *)&(((struct claw_privbk *)dev->ml_priv)->tbusy));
 	netif_wake_queue(dev);
 }
 
@@ -171,7 +171,7 @@ claw_test_and_setbit_busy(int nr,struct 
 {
 	netif_stop_queue(dev);
 	return test_and_set_bit(nr,
- 		(void *)&(((struct claw_privbk *) dev->priv)->tbusy));
+		(void *)&(((struct claw_privbk *) dev->ml_priv)->tbusy));
 }
 
 
@@ -319,7 +319,7 @@ static int
 claw_tx(struct sk_buff *skb, struct net_device *dev)
 {
         int             rc;
-        struct claw_privbk *privptr=dev->priv;
+	struct claw_privbk *privptr = dev->ml_priv;
 	unsigned long saveflags;
         struct chbk *p_ch;
 
@@ -404,7 +404,7 @@ claw_pack_skb(struct claw_privbk *privpt
 static int
 claw_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct claw_privbk  *privptr=dev->priv;
+	struct claw_privbk *privptr = dev->ml_priv;
 	int buff_size;
 	CLAW_DBF_TEXT(4, trace, "setmtu");
 	buff_size = privptr->p_env->write_size;
@@ -434,7 +434,7 @@ claw_open(struct net_device *dev)
         struct ccwbk *p_buf;
 
 	CLAW_DBF_TEXT(4, trace, "open");
-	privptr = (struct claw_privbk *)dev->priv;
+	privptr = (struct claw_privbk *)dev->ml_priv;
         /*   allocate and initialize CCW blocks */
 	if (privptr->buffs_alloc == 0) {
 	        rc=init_ccw_bk(dev);
@@ -780,7 +780,7 @@ claw_irq_tasklet ( unsigned long data )
 	p_ch = (struct chbk *) data;
         dev = (struct net_device *)p_ch->ndev;
 	CLAW_DBF_TEXT(4, trace, "IRQtask");
-        privptr = (struct claw_privbk *) dev->priv;
+	privptr = (struct claw_privbk *)dev->ml_priv;
         unpack_read(dev);
         clear_bit(CLAW_BH_ACTIVE, (void *)&p_ch->flag_a);
 	CLAW_DBF_TEXT(4, trace, "TskletXt");
@@ -805,7 +805,7 @@ claw_release(struct net_device *dev)
 
 	if (!dev)
                 return 0;
-        privptr = (struct claw_privbk *) dev->priv;
+	privptr = (struct claw_privbk *)dev->ml_priv;
         if (!privptr)
                 return 0;
 	CLAW_DBF_TEXT(4, trace, "release");
@@ -960,7 +960,7 @@ claw_write_next ( struct chbk * p_ch )
         if (p_ch->claw_state == CLAW_STOP)
                 return;
         dev = (struct net_device *) p_ch->ndev;
-	privptr = (struct claw_privbk *) dev->priv;
+	privptr = (struct claw_privbk *) dev->ml_priv;
         claw_free_wrt_buf( dev );
 	if ((privptr->write_free_count > 0) &&
 	    !skb_queue_empty(&p_ch->collect_queue)) {
@@ -1042,7 +1042,7 @@ add_claw_reads(struct net_device *dev, s
         struct ccw1  temp_ccw;
         struct endccw * p_end;
 	CLAW_DBF_TEXT(4, trace, "addreads");
-        privptr = dev->priv;
+	privptr = dev->ml_priv;
         p_end = privptr->p_end_ccw;
 
         /* first CCW and last CCW contains a new set of read channel programs
@@ -1212,7 +1212,7 @@ find_link(struct net_device *dev, char *
 	int    rc=0;
 
 	CLAW_DBF_TEXT(2, setup, "findlink");
-        privptr=dev->priv;
+	privptr = dev->ml_priv;
         p_env=privptr->p_env;
 	switch (p_env->packing)
 	{
@@ -1264,7 +1264,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
 	struct chbk			*ch;
 
 	CLAW_DBF_TEXT(4, trace, "hw_tx");
-        privptr = (struct claw_privbk *) (dev->priv);
+	privptr = (struct claw_privbk *)(dev->ml_priv);
         p_ch=(struct chbk *)&privptr->channel[WRITE];
 	p_env =privptr->p_env;
 	claw_free_wrt_buf(dev);	/* Clean up free chain if posible */
@@ -1483,8 +1483,8 @@ init_ccw_bk(struct net_device *dev)
 	struct ccwbk*p_last_CCWB;
 	struct ccwbk*p_first_CCWB;
         struct endccw *p_endccw=NULL;
-        addr_t  real_address;
-        struct claw_privbk *privptr=dev->priv;
+	addr_t  real_address;
+	struct claw_privbk *privptr = dev->ml_priv;
         struct clawh *pClawH=NULL;
         addr_t   real_TIC_address;
         int i,j;
@@ -1997,7 +1997,7 @@ claw_process_control( struct net_device 
 	CLAW_DBF_TEXT(2, setup, "clw_cntl");
         udelay(1000);  /* Wait a ms for the control packets to
 			*catch up to each other */
-        privptr=dev->priv;
+	privptr = dev->ml_priv;
         p_env=privptr->p_env;
 	tdev = &privptr->channel[READ].cdev->dev;
 	memcpy( &temp_host_name, p_env->host_name, 8);
@@ -2275,7 +2275,7 @@ claw_send_control(struct net_device *dev
         struct sk_buff 			*skb;
 
 	CLAW_DBF_TEXT(2, setup, "sndcntl");
-        privptr=dev->priv;
+	privptr = dev->ml_priv;
         p_ctl=(struct clawctl *)&privptr->ctl_bk;
 
         p_ctl->command=type;
@@ -2345,7 +2345,7 @@ static int
 claw_snd_conn_req(struct net_device *dev, __u8 link)
 {
         int                rc;
-        struct claw_privbk *privptr=dev->priv;
+	struct claw_privbk *privptr = dev->ml_priv;
         struct clawctl 	   *p_ctl;
 
 	CLAW_DBF_TEXT(2, setup, "snd_conn");
@@ -2405,7 +2405,7 @@ claw_snd_sys_validate_rsp(struct net_dev
         int    rc;
 
 	CLAW_DBF_TEXT(2, setup, "chkresp");
-        privptr = dev->priv;
+	privptr = dev->ml_priv;
         p_env=privptr->p_env;
         rc=claw_send_control(dev, SYSTEM_VALIDATE_RESPONSE,
 		p_ctl->linkid,
@@ -2443,7 +2443,7 @@ net_device_stats *claw_stats(struct net_
         struct claw_privbk *privptr;
 
 	CLAW_DBF_TEXT(4, trace, "stats");
-        privptr = dev->priv;
+	privptr = dev->ml_priv;
         return &privptr->stats;
 }     /*   end of claw_stats   */
 
@@ -2479,7 +2479,7 @@ unpack_read(struct net_device *dev )
         p_last_ccw=NULL;
 	p_packh=NULL;
 	p_packd=NULL;
-        privptr=dev->priv;
+	privptr = dev->ml_priv;
 
 	p_dev = &privptr->channel[READ].cdev->dev;
 	p_env = privptr->p_env;
@@ -2648,7 +2648,7 @@ claw_strt_read (struct net_device *dev, 
         int        rc = 0;
         __u32      parm;
         unsigned long  saveflags = 0;
-        struct claw_privbk *privptr=dev->priv;
+	struct claw_privbk *privptr = dev->ml_priv;
         struct ccwbk*p_ccwbk;
         struct chbk *p_ch;
         struct clawh *p_clawh;
@@ -2705,7 +2705,7 @@ claw_strt_out_IO( struct net_device *dev
 	if (!dev) {
 		return;
 	}
-        privptr=(struct claw_privbk *)dev->priv;
+	privptr = (struct claw_privbk *)dev->ml_priv;
         p_ch=&privptr->channel[WRITE];
 
 	CLAW_DBF_TEXT(4, trace, "strt_io");
@@ -2738,7 +2738,7 @@ static void
 claw_free_wrt_buf( struct net_device *dev )
 {
 
-        struct claw_privbk *privptr=(struct claw_privbk *)dev->priv;
+	struct claw_privbk *privptr = (struct claw_privbk *)dev->ml_priv;
         struct ccwbk*p_first_ccw;
 	struct ccwbk*p_last_ccw;
 	struct ccwbk*p_this_ccw;
@@ -2795,13 +2795,13 @@ claw_free_netdevice(struct net_device * 
 	if (!dev)
 		return;
 	CLAW_DBF_TEXT_(2, setup, "%s", dev->name);
-	privptr = dev->priv;
+	privptr = dev->ml_priv;
 	if (dev->flags & IFF_RUNNING)
 		claw_release(dev);
 	if (privptr) {
 		privptr->channel[READ].ndev = NULL;  /* say it's free */
 	}
-	dev->priv=NULL;
+	dev->ml_priv = NULL;
 #ifdef MODULE
 	if (free_dev) {
 		free_netdev(dev);
@@ -2918,7 +2918,7 @@ claw_new_device(struct ccwgroup_device *
 		printk(KERN_WARNING "%s:alloc_netdev failed\n",__func__);
 		goto out;
 	}
-	dev->priv = privptr;
+	dev->ml_priv = privptr;
 	cgdev->dev.driver_data = privptr;
         cgdev->cdev[READ]->dev.driver_data = privptr;
         cgdev->cdev[WRITE]->dev.driver_data = privptr;
@@ -2999,7 +2999,7 @@ claw_shutdown_device(struct ccwgroup_dev
 			ret = claw_release(ndev);
 		ndev->flags &=~IFF_RUNNING;
 		unregister_netdev(ndev);
-		ndev->priv = NULL;  /* cgdev data, not ndev's to free */
+		ndev->ml_priv = NULL;  /* cgdev data, not ndev's to free */
 		claw_free_netdevice(ndev, 1);
 		priv->channel[READ].ndev = NULL;
 		priv->channel[WRITE].ndev = NULL;

-- 
