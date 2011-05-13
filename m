From: frank.blaschka@de.ibm.com
Subject: [patch 4/9] [PATCH] claw: remove unused return code handling
Date: Fri, 13 May 2011 06:45:04 +0200
Message-ID: <20110513044547.751474558@de.ibm.com>
References: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:33209 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab1EMEpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:51 -0400
Content-Disposition: inline; filename=603-claw-unused-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Remove unused return code handling. The claw driver is mostly dead, so
just make sure it keeps compiling without warnings.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/claw.c |   22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)
diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2011-05-10 09:14:06.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/claw.c	2011-05-10 09:14:25.000000000 +0200
@@ -845,12 +845,10 @@ claw_irq_tasklet ( unsigned long data )
 {
 	struct chbk * p_ch;
         struct net_device  *dev;
-        struct claw_privbk *       privptr;
 
 	p_ch = (struct chbk *) data;
         dev = (struct net_device *)p_ch->ndev;
 	CLAW_DBF_TEXT(4, trace, "IRQtask");
-	privptr = (struct claw_privbk *)dev->ml_priv;
         unpack_read(dev);
         clear_bit(CLAW_BH_ACTIVE, (void *)&p_ch->flag_a);
 	CLAW_DBF_TEXT(4, trace, "TskletXt");
@@ -1026,7 +1024,6 @@ claw_write_next ( struct chbk * p_ch )
         struct net_device  *dev;
         struct claw_privbk *privptr=NULL;
 	struct sk_buff *pk_skb;
-	int	rc;
 
 	CLAW_DBF_TEXT(4, trace, "claw_wrt");
         if (p_ch->claw_state == CLAW_STOP)
@@ -1038,7 +1035,7 @@ claw_write_next ( struct chbk * p_ch )
 	    !skb_queue_empty(&p_ch->collect_queue)) {
 	  	pk_skb = claw_pack_skb(privptr);
 		while (pk_skb != NULL) {
-			rc = claw_hw_tx( pk_skb, dev,1);
+			claw_hw_tx(pk_skb, dev, 1);
 			if (privptr->write_free_count > 0) {
 	   			pk_skb = claw_pack_skb(privptr);
 			} else
@@ -1322,15 +1319,12 @@ claw_hw_tx(struct sk_buff *skb, struct n
         unsigned char                   *pDataAddress;
         struct endccw                   *pEnd;
         struct ccw1                     tempCCW;
-        struct chbk                     *p_ch;
 	struct claw_env			*p_env;
-        int                             lock;
 	struct clawph			*pk_head;
 	struct chbk			*ch;
 
 	CLAW_DBF_TEXT(4, trace, "hw_tx");
 	privptr = (struct claw_privbk *)(dev->ml_priv);
-	p_ch = (struct chbk *)&privptr->channel[WRITE_CHANNEL];
 	p_env =privptr->p_env;
 	claw_free_wrt_buf(dev);	/* Clean up free chain if posible */
         /*  scan the write queue to free any completed write packets   */
@@ -1511,12 +1505,6 @@ claw_hw_tx(struct sk_buff *skb, struct n
 
         } /* endif (p_first_ccw!=NULL)  */
         dev_kfree_skb_any(skb);
-	if (linkid==0) {
-        	lock=LOCK_NO;
-        }
-        else  {
-                lock=LOCK_YES;
-        }
         claw_strt_out_IO(dev );
         /*      if write free count is zero , set NOBUFFER       */
 	if (privptr->write_free_count==0) {
@@ -2821,15 +2809,11 @@ claw_free_wrt_buf( struct net_device *de
 {
 
 	struct claw_privbk *privptr = (struct claw_privbk *)dev->ml_priv;
-        struct ccwbk*p_first_ccw;
-	struct ccwbk*p_last_ccw;
 	struct ccwbk*p_this_ccw;
 	struct ccwbk*p_next_ccw;
 
 	CLAW_DBF_TEXT(4, trace, "freewrtb");
         /*  scan the write queue to free any completed write packets   */
-        p_first_ccw=NULL;
-        p_last_ccw=NULL;
         p_this_ccw=privptr->p_write_active_first;
         while ( (p_this_ccw!=NULL) && (p_this_ccw->header.flag!=CLAW_PENDING))
         {
@@ -3072,7 +3056,7 @@ claw_shutdown_device(struct ccwgroup_dev
 {
 	struct claw_privbk *priv;
 	struct net_device *ndev;
-	int	ret;
+	int ret = 0;
 
 	CLAW_DBF_TEXT_(2, setup, "%s", dev_name(&cgdev->dev));
 	priv = dev_get_drvdata(&cgdev->dev);
@@ -3095,7 +3079,7 @@ claw_shutdown_device(struct ccwgroup_dev
 	}
 	ccw_device_set_offline(cgdev->cdev[1]);
 	ccw_device_set_offline(cgdev->cdev[0]);
-	return 0;
+	return ret;
 }
 
 static void

