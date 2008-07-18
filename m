From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/3] Cleanup claw printk messages.
Date: Fri, 18 Jul 2008 15:24:56 +0200
Message-ID: <20080718133554.596094000@linux.vnet.ibm.com>
References: <20080718132455.214854000@linux.vnet.ibm.com>
Cc: Martin Schwidefsky <schwidefska@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andy Richter <richtera@us.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:9894 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757082AbYGRNgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:36:13 -0400
Content-Disposition: inline; filename=607-claw.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Richter <richtera@us.ibm.com>

Cc: Martin Schwidefsky <schwidefska@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Andy Richter <richtera@us.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c | 2141 +++++++++++-------------------------------------
 1 file changed, 520 insertions(+), 1621 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.c
+++ linux-2.6-uschi/drivers/s390/net/claw.c
@@ -58,13 +58,13 @@
  *    1.10  Changes for Buffer allocation
  *    1.15  Changed for 2.6 Kernel  No longer compiles on 2.4 or lower
  *    1.25  Added Packing support
+ *    1.5
  */
 #include <asm/ccwdev.h>
 #include <asm/ccwgroup.h>
 #include <asm/debug.h>
 #include <asm/idals.h>
 #include <asm/io.h>
-
 #include <linux/bitops.h>
 #include <linux/ctype.h>
 #include <linux/delay.h>
@@ -90,36 +90,10 @@
 #include "cu3088.h"
 #include "claw.h"
 
-MODULE_AUTHOR("Andy Richter <richtera@us.ibm.com>");
-MODULE_DESCRIPTION("Linux for zSeries CLAW Driver\n" \
-			"Copyright 2000,2005 IBM Corporation\n");
-MODULE_LICENSE("GPL");
-
-/* Debugging is based on DEBUGMSG, IOTRACE, or FUNCTRACE  options:
-   DEBUGMSG  - Enables output of various debug messages in the code
-   IOTRACE   - Enables output of CCW and other IO related traces
-   FUNCTRACE - Enables output of function entry/exit trace
-   Define any combination of above options to enable tracing
-
-   CLAW also uses the s390dbf file system  see claw_trace and claw_setup
+/*
+   CLAW uses the s390dbf file system  see claw_trace and claw_setup
 */
 
-/* following enables tracing */
-//#define DEBUGMSG
-//#define IOTRACE
-//#define FUNCTRACE
-
-#ifdef DEBUGMSG
-#define DEBUG
-#endif
-
-#ifdef IOTRACE
-#define DEBUG
-#endif
-
-#ifdef FUNCTRACE
-#define DEBUG
-#endif
 
 static char debug_buffer[255];
 /**
@@ -146,7 +120,6 @@ claw_register_debug_facility(void)
 	claw_dbf_setup = debug_register("claw_setup", 2, 1, 8);
 	claw_dbf_trace = debug_register("claw_trace", 2, 2, 8);
 	if (claw_dbf_setup == NULL || claw_dbf_trace == NULL) {
-		printk(KERN_WARNING "Not enough memory for debug facility.\n");
 		claw_unregister_debug_facility();
 		return -ENOMEM;
 	}
@@ -232,9 +205,6 @@ static void probe_error( struct ccwgroup
 static struct net_device_stats *claw_stats(struct net_device *dev);
 static int pages_to_order_of_mag(int num_of_pages);
 static struct sk_buff *claw_pack_skb(struct claw_privbk *privptr);
-#ifdef DEBUG
-static void dumpit (char *buf, int len);
-#endif
 /* sysfs Functions */
 static ssize_t claw_hname_show(struct device *dev, struct device_attribute *attr, char *buf);
 static ssize_t claw_hname_write(struct device *dev, struct device_attribute *attr,
@@ -263,12 +233,12 @@ static int claw_snd_disc(struct net_devi
 static int claw_snd_sys_validate_rsp(struct net_device *dev,
         struct clawctl * p_ctl, __u32 return_code);
 static int claw_strt_conn_req(struct net_device *dev );
-static void claw_strt_read ( struct net_device *dev, int lock );
-static void claw_strt_out_IO( struct net_device *dev );
-static void claw_free_wrt_buf( struct net_device *dev );
+static void claw_strt_read(struct net_device *dev, int lock);
+static void claw_strt_out_IO(struct net_device *dev);
+static void claw_free_wrt_buf(struct net_device *dev);
 
 /* Functions for unpack reads   */
-static void unpack_read (struct net_device *dev );
+static void unpack_read(struct net_device *dev);
 
 /* ccwgroup table  */
 
@@ -284,7 +254,6 @@ static struct ccwgroup_driver claw_group
 };
 
 /*
-*
 *       Key functions
 */
 
@@ -298,23 +267,14 @@ claw_probe(struct ccwgroup_device *cgdev
 	int  		rc;
 	struct claw_privbk *privptr=NULL;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s Enter\n",__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"probe");
+	CLAW_DBF_TEXT(2, setup, "probe");
 	if (!get_device(&cgdev->dev))
 		return -ENODEV;
-#ifdef DEBUGMSG
-        printk(KERN_INFO "claw: variable cgdev =\n");
-        dumpit((char *)cgdev, sizeof(struct ccwgroup_device));
-#endif
 	privptr = kzalloc(sizeof(struct claw_privbk), GFP_KERNEL);
 	if (privptr == NULL) {
 		probe_error(cgdev);
 		put_device(&cgdev->dev);
-		printk(KERN_WARNING "Out of memory %s %s Exit Line %d \n",
-			cgdev->cdev[0]->dev.bus_id,__func__,__LINE__);
-		CLAW_DBF_TEXT_(2,setup,"probex%d",-ENOMEM);
+		CLAW_DBF_TEXT_(2, setup, "probex%d", -ENOMEM);
 		return -ENOMEM;
 	}
 	privptr->p_mtc_envelope= kzalloc( MAX_ENVELOPE_SIZE, GFP_KERNEL);
@@ -322,9 +282,7 @@ claw_probe(struct ccwgroup_device *cgdev
         if ((privptr->p_mtc_envelope==NULL) || (privptr->p_env==NULL)) {
                 probe_error(cgdev);
 		put_device(&cgdev->dev);
-		printk(KERN_WARNING "Out of memory %s %s Exit Line %d \n",
-			cgdev->cdev[0]->dev.bus_id,__func__,__LINE__);
-		CLAW_DBF_TEXT_(2,setup,"probex%d",-ENOMEM);
+		CLAW_DBF_TEXT_(2, setup, "probex%d", -ENOMEM);
                 return -ENOMEM;
         }
 	memcpy(privptr->p_env->adapter_name,WS_NAME_NOT_DEF,8);
@@ -341,19 +299,14 @@ claw_probe(struct ccwgroup_device *cgdev
 		put_device(&cgdev->dev);
 		printk(KERN_WARNING "add_files failed %s %s Exit Line %d \n",
 			cgdev->cdev[0]->dev.bus_id,__func__,__LINE__);
-		CLAW_DBF_TEXT_(2,setup,"probex%d",rc);
+		CLAW_DBF_TEXT_(2, setup, "probex%d", rc);
 		return rc;
 	}
-	printk(KERN_INFO "claw: sysfs files added for %s\n",cgdev->cdev[0]->dev.bus_id);
 	privptr->p_env->p_priv = privptr;
         cgdev->cdev[0]->handler = claw_irq_handler;
 	cgdev->cdev[1]->handler = claw_irq_handler;
 	cgdev->dev.driver_data = privptr;
-#ifdef FUNCTRACE
-        printk(KERN_INFO "claw:%s exit on line %d, "
-		"rc = 0\n",__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"prbext 0");
+	CLAW_DBF_TEXT(2, setup, "prbext 0");
 
         return 0;
 }  /*  end of claw_probe       */
@@ -370,37 +323,18 @@ claw_tx(struct sk_buff *skb, struct net_
 	unsigned long saveflags;
         struct chbk *p_ch;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"claw_tx");
+	CLAW_DBF_TEXT(4, trace, "claw_tx");
         p_ch=&privptr->channel[WRITE];
         if (skb == NULL) {
-                printk(KERN_WARNING "%s: null pointer passed as sk_buffer\n",
-			dev->name);
                 privptr->stats.tx_dropped++;
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s: %s() exit on line %d, rc = EIO\n",
-			dev->name,__func__, __LINE__);
-#endif
-		CLAW_DBF_TEXT_(2,trace,"clawtx%d",-EIO);
+		privptr->stats.tx_errors++;
+		CLAW_DBF_TEXT_(2, trace, "clawtx%d", -EIO);
                 return -EIO;
         }
-
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: variable sk_buff=\n",dev->name);
-        dumpit((char *) skb, sizeof(struct sk_buff));
-        printk(KERN_INFO "%s: variable dev=\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-#endif
         spin_lock_irqsave(get_ccwdev_lock(p_ch->cdev), saveflags);
         rc=claw_hw_tx( skb, dev, 1 );
         spin_unlock_irqrestore(get_ccwdev_lock(p_ch->cdev), saveflags);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s exit on line %d, rc = %d\n",
-		dev->name, __func__, __LINE__, rc);
-#endif
-	CLAW_DBF_TEXT_(4,trace,"clawtx%d",rc);
+	CLAW_DBF_TEXT_(4, trace, "clawtx%d", rc);
         return rc;
 }   /*  end of claw_tx */
 
@@ -419,7 +353,7 @@ claw_pack_skb(struct claw_privbk *privpt
 
 	new_skb = NULL;		/* assume no dice */
 	pkt_cnt = 0;
-	CLAW_DBF_TEXT(4,trace,"PackSKBe");
+	CLAW_DBF_TEXT(4, trace, "PackSKBe");
 	if (!skb_queue_empty(&p_ch->collect_queue)) {
 	/* some data */
 		held_skb = skb_dequeue(&p_ch->collect_queue);
@@ -457,13 +391,8 @@ claw_pack_skb(struct claw_privbk *privpt
 				skb_queue_head(&p_ch->collect_queue,held_skb);
 			}
 		}
-#ifdef IOTRACE
-		printk(KERN_INFO "%s: %s() Packed %d len %d\n",
-			p_env->ndev->name,
-			__func__,pkt_cnt,new_skb->len);
-#endif
 	}
-	CLAW_DBF_TEXT(4,trace,"PackSKBx");
+	CLAW_DBF_TEXT(4, trace, "PackSKBx");
 	return new_skb;
 }
 
@@ -477,29 +406,12 @@ claw_change_mtu(struct net_device *dev, 
 {
 	struct claw_privbk  *privptr=dev->priv;
 	int buff_size;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-#ifdef DEBUGMSG
-        printk(KERN_INFO "variable dev =\n");
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "variable new_mtu = %d\n", new_mtu);
-#endif
-	CLAW_DBF_TEXT(4,trace,"setmtu");
+	CLAW_DBF_TEXT(4, trace, "setmtu");
 	buff_size = privptr->p_env->write_size;
         if ((new_mtu < 60) || (new_mtu > buff_size)) {
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s:%s Exit on line %d, rc=EINVAL\n",
-		dev->name,
-		__func__, __LINE__);
-#endif
                 return -EINVAL;
         }
         dev->mtu = new_mtu;
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d\n",dev->name,
-	__func__, __LINE__);
-#endif
         return 0;
 }  /*   end of claw_change_mtu */
 
@@ -521,24 +433,13 @@ claw_open(struct net_device *dev)
         struct timer_list  timer;
         struct ccwbk *p_buf;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"open");
-	if (!dev || (dev->name[0] == 0x00)) {
-		CLAW_DBF_TEXT(2,trace,"BadDev");
-	 	printk(KERN_WARNING "claw: Bad device at open failing \n");
-		return -ENODEV;
-	}
+	CLAW_DBF_TEXT(4, trace, "open");
 	privptr = (struct claw_privbk *)dev->priv;
         /*   allocate and initialize CCW blocks */
 	if (privptr->buffs_alloc == 0) {
 	        rc=init_ccw_bk(dev);
         	if (rc) {
-                	printk(KERN_INFO "%s:%s Exit on line %d, rc=ENOMEM\n",
-			dev->name,
-			__func__, __LINE__);
-			CLAW_DBF_TEXT(2,trace,"openmem");
+			CLAW_DBF_TEXT(2, trace, "openmem");
                 	return -ENOMEM;
         	}
 	}
@@ -557,7 +458,7 @@ claw_open(struct net_device *dev)
 	tasklet_init(&privptr->channel[READ].tasklet, claw_irq_tasklet,
         	(unsigned long) &privptr->channel[READ]);
         for ( i = 0; i < 2;  i++) {
-		CLAW_DBF_TEXT_(2,trace,"opn_ch%d",i);
+		CLAW_DBF_TEXT_(2, trace, "opn_ch%d", i);
                 init_waitqueue_head(&privptr->channel[i].wait);
 		/* skb_queue_head_init(&p_ch->io_queue); */
 		if (i == WRITE)
@@ -595,15 +496,8 @@ claw_open(struct net_device *dev)
            ~(DEV_STAT_CHN_END | DEV_STAT_DEV_END)) != 0x00) ||
            (((privptr->channel[READ].flag |
 	   	privptr->channel[WRITE].flag) & CLAW_TIMER) != 0x00)) {
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: channel problems during open - read:"
-			" %02x -  write: %02x\n",
-                        dev->name,
-			privptr->channel[READ].last_dstat,
-			privptr->channel[WRITE].last_dstat);
-#endif
                 printk(KERN_INFO "%s: remote side is not ready\n", dev->name);
-		CLAW_DBF_TEXT(2,trace,"notrdy");
+		CLAW_DBF_TEXT(2, trace, "notrdy");
 
                 for ( i = 0; i < 2;  i++) {
                         spin_lock_irqsave(
@@ -659,23 +553,14 @@ claw_open(struct net_device *dev)
                 privptr->p_buff_read=NULL;
                 privptr->p_buff_write=NULL;
                 claw_clear_busy(dev);
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s:%s Exit on line %d, rc=EIO\n",
-		dev->name,__func__,__LINE__);
-#endif
-		CLAW_DBF_TEXT(2,trace,"open EIO");
+		CLAW_DBF_TEXT(2, trace, "open EIO");
                 return -EIO;
         }
 
         /*   Send SystemValidate command */
 
         claw_clear_busy(dev);
-
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d, rc=0\n",
-		dev->name,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"openok");
+	CLAW_DBF_TEXT(4, trace, "openok");
         return 0;
 }    /*     end of claw_open    */
 
@@ -694,22 +579,14 @@ claw_irq_handler(struct ccw_device *cdev
         struct claw_env  *p_env;
         struct chbk *p_ch_r=NULL;
 
-
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s enter  \n",__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"clawirq");
+	CLAW_DBF_TEXT(4, trace, "clawirq");
         /* Bypass all 'unsolicited interrupts' */
 	if (!cdev->dev.driver_data) {
                 printk(KERN_WARNING "claw: unsolicited interrupt for device:"
 		 	"%s received c-%02x d-%02x\n",
 		       cdev->dev.bus_id, irb->scsw.cmd.cstat,
 		       irb->scsw.cmd.dstat);
-#ifdef FUNCTRACE
-                printk(KERN_INFO "claw: %s() "
-			"exit on line %d\n",__func__,__LINE__);
-#endif
-		CLAW_DBF_TEXT(2,trace,"badirq");
+		CLAW_DBF_TEXT(2, trace, "badirq");
                 return;
         }
 	privptr = (struct claw_privbk *)cdev->dev.driver_data;
@@ -722,41 +599,25 @@ claw_irq_handler(struct ccw_device *cdev
 	else {
 		printk(KERN_WARNING "claw: Can't determine channel for "
 			"interrupt, device %s\n", cdev->dev.bus_id);
-		CLAW_DBF_TEXT(2,trace,"badchan");
+		CLAW_DBF_TEXT(2, trace, "badchan");
 		return;
 	}
-	CLAW_DBF_TEXT_(4,trace,"IRQCH=%d",p_ch->flag);
+	CLAW_DBF_TEXT_(4, trace, "IRQCH=%d", p_ch->flag);
 
 	dev = (struct net_device *) (p_ch->ndev);
         p_env=privptr->p_env;
 
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: interrupt for device: %04x "
-		"received c-%02x d-%02x state-%02x\n",
-	       dev->name, p_ch->devno, irb->scsw.cmd.cstat,
-	       irb->scsw.cmd.dstat, p_ch->claw_state);
-#endif
-
 	/* Copy interruption response block. */
 	memcpy(p_ch->irb, irb, sizeof(struct irb));
 
-        /* Check for good subchannel return code, otherwise error message */
+	/* Check for good subchannel return code, otherwise info message */
 	if (irb->scsw.cmd.cstat && !(irb->scsw.cmd.cstat & SCHN_STAT_PCI)) {
                 printk(KERN_INFO "%s: subchannel check for device: %04x -"
 			" Sch Stat %02x  Dev Stat %02x CPA - %04x\n",
                         dev->name, p_ch->devno,
 			irb->scsw.cmd.cstat, irb->scsw.cmd.dstat,
 			irb->scsw.cmd.cpa);
-#ifdef IOTRACE
-		dumpit((char *)irb,sizeof(struct irb));
-		dumpit((char *)(unsigned long)irb->scsw.cmd.cpa,
-			sizeof(struct ccw1));
-#endif
-#ifdef FUNCTRACE
-		printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-		CLAW_DBF_TEXT(2,trace,"chanchk");
+		CLAW_DBF_TEXT(2, trace, "chanchk");
                 /* return; */
         }
 
@@ -768,233 +629,138 @@ claw_irq_handler(struct ccw_device *cdev
 	p_ch->last_dstat = irb->scsw.cmd.dstat;
 
         switch (p_ch->claw_state) {
-                case CLAW_STOP:/* HALT_IO by claw_release (halt sequence) */
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: CLAW_STOP enter\n", dev->name);
-#endif
-			if (!((p_ch->irb->scsw.cmd.stctl &
-			       SCSW_STCTL_SEC_STATUS) ||
-			    (p_ch->irb->scsw.cmd.stctl ==
-				SCSW_STCTL_STATUS_PEND) ||
-			    (p_ch->irb->scsw.cmd.stctl ==
-				(SCSW_STCTL_ALERT_STATUS |
-				 SCSW_STCTL_STATUS_PEND)))) {
-#ifdef FUNCTRACE
-                                printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-                                return;
-                        }
-                        wake_up(&p_ch->wait);   /* wake up claw_release */
-
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: CLAW_STOP exit\n", dev->name);
-#endif
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s:%s Exit on line %d\n",
-				dev->name,__func__,__LINE__);
-#endif
-			CLAW_DBF_TEXT(4,trace,"stop");
-                        return;
-
-                case CLAW_START_HALT_IO: /* HALT_IO issued by claw_open  */
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: process CLAW_STAT_HALT_IO\n",
-				dev->name);
-#endif
-			if (!((p_ch->irb->scsw.cmd.stctl &
-			       SCSW_STCTL_SEC_STATUS) ||
-			    (p_ch->irb->scsw.cmd.stctl ==
-			     SCSW_STCTL_STATUS_PEND) ||
-			    (p_ch->irb->scsw.cmd.stctl ==
-			     (SCSW_STCTL_ALERT_STATUS |
-			      SCSW_STCTL_STATUS_PEND)))) {
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-				CLAW_DBF_TEXT(4,trace,"haltio");
-                                return;
-                        }
-                        if (p_ch->flag == CLAW_READ) {
-                                p_ch->claw_state = CLAW_START_READ;
-                                wake_up(&p_ch->wait); /* wake claw_open (READ)*/
-                        }
+	case CLAW_STOP:/* HALT_IO by claw_release (halt sequence) */
+		if (!((p_ch->irb->scsw.cmd.stctl & SCSW_STCTL_SEC_STATUS) ||
+		(p_ch->irb->scsw.cmd.stctl == SCSW_STCTL_STATUS_PEND) ||
+		(p_ch->irb->scsw.cmd.stctl ==
+		(SCSW_STCTL_ALERT_STATUS | SCSW_STCTL_STATUS_PEND))))
+			return;
+		wake_up(&p_ch->wait);   /* wake up claw_release */
+		CLAW_DBF_TEXT(4, trace, "stop");
+		return;
+	case CLAW_START_HALT_IO: /* HALT_IO issued by claw_open  */
+		if (!((p_ch->irb->scsw.cmd.stctl & SCSW_STCTL_SEC_STATUS) ||
+		(p_ch->irb->scsw.cmd.stctl == SCSW_STCTL_STATUS_PEND) ||
+		(p_ch->irb->scsw.cmd.stctl ==
+		(SCSW_STCTL_ALERT_STATUS | SCSW_STCTL_STATUS_PEND)))) {
+			CLAW_DBF_TEXT(4, trace, "haltio");
+			return;
+		}
+		if (p_ch->flag == CLAW_READ) {
+			p_ch->claw_state = CLAW_START_READ;
+			wake_up(&p_ch->wait); /* wake claw_open (READ)*/
+		} else if (p_ch->flag == CLAW_WRITE) {
+			p_ch->claw_state = CLAW_START_WRITE;
+			/*	send SYSTEM_VALIDATE			*/
+			claw_strt_read(dev, LOCK_NO);
+			claw_send_control(dev,
+				SYSTEM_VALIDATE_REQUEST,
+				0, 0, 0,
+				p_env->host_name,
+				p_env->adapter_name);
+		} else {
+			printk(KERN_WARNING "claw: unsolicited "
+				"interrupt for device:"
+				"%s received c-%02x d-%02x\n",
+				cdev->dev.bus_id,
+				irb->scsw.cmd.cstat,
+				irb->scsw.cmd.dstat);
+			return;
+			}
+		CLAW_DBF_TEXT(4, trace, "haltio");
+		return;
+	case CLAW_START_READ:
+		CLAW_DBF_TEXT(4, trace, "ReadIRQ");
+		if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
+			clear_bit(0, (void *)&p_ch->IO_active);
+			if ((p_ch->irb->ecw[0] & 0x41) == 0x41 ||
+			    (p_ch->irb->ecw[0] & 0x40) == 0x40 ||
+			    (p_ch->irb->ecw[0])        == 0) {
+				privptr->stats.rx_errors++;
+				printk(KERN_INFO "%s: Restart is "
+					"required after remote "
+					"side recovers \n",
+					dev->name);
+			}
+			CLAW_DBF_TEXT(4, trace, "notrdy");
+			return;
+		}
+		if ((p_ch->irb->scsw.cmd.cstat & SCHN_STAT_PCI) &&
+			(p_ch->irb->scsw.cmd.dstat == 0)) {
+			if (test_and_set_bit(CLAW_BH_ACTIVE,
+				(void *)&p_ch->flag_a) == 0)
+				tasklet_schedule(&p_ch->tasklet);
 			else
-			   if (p_ch->flag == CLAW_WRITE) {
-                                p_ch->claw_state = CLAW_START_WRITE;
-                                /*      send SYSTEM_VALIDATE                    */
-                                claw_strt_read(dev, LOCK_NO);
-                               	claw_send_control(dev,
-					SYSTEM_VALIDATE_REQUEST,
-					0, 0, 0,
-					p_env->host_name,
-					p_env->adapter_name );
-                        } else {
-				printk(KERN_WARNING "claw: unsolicited "
-					"interrupt for device:"
-				 	"%s received c-%02x d-%02x\n",
-                		        cdev->dev.bus_id,
-					irb->scsw.cmd.cstat,
-					irb->scsw.cmd.dstat);
-				return;
-				}
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: process CLAW_STAT_HALT_IO exit\n",
-				dev->name);
-#endif
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s:%s Exit on line %d\n",
-				dev->name,__func__,__LINE__);
-#endif
-			CLAW_DBF_TEXT(4,trace,"haltio");
-                        return;
-                case CLAW_START_READ:
-			CLAW_DBF_TEXT(4,trace,"ReadIRQ");
-			if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
-                                clear_bit(0, (void *)&p_ch->IO_active);
-                                if ((p_ch->irb->ecw[0] & 0x41) == 0x41 ||
-                                    (p_ch->irb->ecw[0] & 0x40) == 0x40 ||
-                                    (p_ch->irb->ecw[0])        == 0)
-                                {
-                                        privptr->stats.rx_errors++;
-                                        printk(KERN_INFO "%s: Restart is "
-						"required after remote "
-						"side recovers \n",
-						dev->name);
-                                }
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-					CLAW_DBF_TEXT(4,trace,"notrdy");
-                                        return;
-                        }
-			if ((p_ch->irb->scsw.cmd.cstat & SCHN_STAT_PCI) &&
-			    (p_ch->irb->scsw.cmd.dstat == 0)) {
-                                if (test_and_set_bit(CLAW_BH_ACTIVE,
-					(void *)&p_ch->flag_a) == 0) {
-					tasklet_schedule(&p_ch->tasklet);
-                                }
-				else {
-					CLAW_DBF_TEXT(4,trace,"PCINoBH");
-				}
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-				CLAW_DBF_TEXT(4,trace,"PCI_read");
-                                return;
-                        }
-			if (!((p_ch->irb->scsw.cmd.stctl &
-			       SCSW_STCTL_SEC_STATUS) ||
-			     (p_ch->irb->scsw.cmd.stctl ==
-			      SCSW_STCTL_STATUS_PEND) ||
-			     (p_ch->irb->scsw.cmd.stctl ==
-			      (SCSW_STCTL_ALERT_STATUS |
-			       SCSW_STCTL_STATUS_PEND)))) {
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-				CLAW_DBF_TEXT(4,trace,"SPend_rd");
-                                return;
-                        }
-                        clear_bit(0, (void *)&p_ch->IO_active);
-                        claw_clearbit_busy(TB_RETRY,dev);
-                        if (test_and_set_bit(CLAW_BH_ACTIVE,
-    				(void *)&p_ch->flag_a) == 0) {
-    				tasklet_schedule(&p_ch->tasklet);
-                         }
-    			else {
-    				CLAW_DBF_TEXT(4,trace,"RdBHAct");
-    			}
-
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: process CLAW_START_READ exit\n",
-				dev->name);
-#endif
-#ifdef FUNCTRACE
-			printk(KERN_INFO "%s:%s Exit on line %d\n",
-				dev->name,__func__,__LINE__);
-#endif
-			CLAW_DBF_TEXT(4,trace,"RdIRQXit");
-                        return;
-                case CLAW_START_WRITE:
-			if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
-                                printk(KERN_INFO "%s: Unit Check Occured in "
-					"write channel\n",dev->name);
-                                clear_bit(0, (void *)&p_ch->IO_active);
-                                if (p_ch->irb->ecw[0] & 0x80 ) {
-                                        printk(KERN_INFO "%s: Resetting Event "
-						"occurred:\n",dev->name);
-                                        init_timer(&p_ch->timer);
-                                        p_ch->timer.function =
-						(void *)claw_write_retry;
-                                        p_ch->timer.data = (unsigned long)p_ch;
-                                        p_ch->timer.expires = jiffies + 10*HZ;
-                                        add_timer(&p_ch->timer);
-                                        printk(KERN_INFO "%s: write connection "
-						"restarting\n",dev->name);
-                                }
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-				CLAW_DBF_TEXT(4,trace,"rstrtwrt");
-                                return;
-                        }
-			if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_EXCEP) {
-                                        clear_bit(0, (void *)&p_ch->IO_active);
-                                        printk(KERN_INFO "%s: Unit Exception "
-						"Occured in write channel\n",
-						dev->name);
-                        }
-			if (!((p_ch->irb->scsw.cmd.stctl &
-			       SCSW_STCTL_SEC_STATUS) ||
-			     (p_ch->irb->scsw.cmd.stctl ==
-			      SCSW_STCTL_STATUS_PEND) ||
-			     (p_ch->irb->scsw.cmd.stctl ==
-			      (SCSW_STCTL_ALERT_STATUS |
-			       SCSW_STCTL_STATUS_PEND)))) {
-#ifdef FUNCTRACE
-				printk(KERN_INFO "%s:%s Exit on line %d\n",
-					dev->name,__func__,__LINE__);
-#endif
-				CLAW_DBF_TEXT(4,trace,"writeUE");
-                                return;
-                        }
-                        clear_bit(0, (void *)&p_ch->IO_active);
-                        if (claw_test_and_setbit_busy(TB_TX,dev)==0) {
-                                claw_write_next(p_ch);
-                                claw_clearbit_busy(TB_TX,dev);
-                                claw_clear_busy(dev);
-                        }
-                        p_ch_r=(struct chbk *)&privptr->channel[READ];
-                        if (test_and_set_bit(CLAW_BH_ACTIVE,
- 					(void *)&p_ch_r->flag_a) == 0) {
-			 	tasklet_schedule(&p_ch_r->tasklet);
-                        }
-
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: process CLAW_START_WRITE exit\n",
-				 dev->name);
-#endif
-#ifdef FUNCTRACE
-			printk(KERN_INFO "%s:%s Exit on line %d\n",
-				dev->name,__func__,__LINE__);
-#endif
-			CLAW_DBF_TEXT(4,trace,"StWtExit");
-                        return;
-                default:
-                        printk(KERN_WARNING "%s: wrong selection code - irq "
-				"state=%d\n",dev->name,p_ch->claw_state);
-#ifdef FUNCTRACE
-			printk(KERN_INFO "%s:%s Exit on line %d\n",
-				dev->name,__func__,__LINE__);
-#endif
-			CLAW_DBF_TEXT(2,trace,"badIRQ");
-                        return;
+				CLAW_DBF_TEXT(4, trace, "PCINoBH");
+			CLAW_DBF_TEXT(4, trace, "PCI_read");
+			return;
+		}
+		if (!((p_ch->irb->scsw.cmd.stctl & SCSW_STCTL_SEC_STATUS) ||
+		 (p_ch->irb->scsw.cmd.stctl == SCSW_STCTL_STATUS_PEND) ||
+		 (p_ch->irb->scsw.cmd.stctl ==
+		 (SCSW_STCTL_ALERT_STATUS | SCSW_STCTL_STATUS_PEND)))) {
+			CLAW_DBF_TEXT(4, trace, "SPend_rd");
+			return;
+		}
+		clear_bit(0, (void *)&p_ch->IO_active);
+		claw_clearbit_busy(TB_RETRY, dev);
+		if (test_and_set_bit(CLAW_BH_ACTIVE,
+			(void *)&p_ch->flag_a) == 0)
+			tasklet_schedule(&p_ch->tasklet);
+		else
+			CLAW_DBF_TEXT(4, trace, "RdBHAct");
+		CLAW_DBF_TEXT(4, trace, "RdIRQXit");
+		return;
+	case CLAW_START_WRITE:
+		if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
+			printk(KERN_INFO "%s: Unit Check Occured in "
+				"write channel\n", dev->name);
+			clear_bit(0, (void *)&p_ch->IO_active);
+			if (p_ch->irb->ecw[0] & 0x80) {
+				printk(KERN_INFO "%s: Resetting Event "
+					"occurred:\n", dev->name);
+				init_timer(&p_ch->timer);
+				p_ch->timer.function =
+					(void *)claw_write_retry;
+				p_ch->timer.data = (unsigned long)p_ch;
+				p_ch->timer.expires = jiffies + 10*HZ;
+				add_timer(&p_ch->timer);
+				printk(KERN_INFO "%s: write connection "
+					"restarting\n", dev->name);
+			}
+			CLAW_DBF_TEXT(4, trace, "rstrtwrt");
+			return;
+		}
+		if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_EXCEP) {
+			clear_bit(0, (void *)&p_ch->IO_active);
+			printk(KERN_INFO "%s: Unit Exception "
+			       "Occured in write channel\n",
+			       dev->name);
+		}
+		if (!((p_ch->irb->scsw.cmd.stctl & SCSW_STCTL_SEC_STATUS) ||
+		(p_ch->irb->scsw.cmd.stctl == SCSW_STCTL_STATUS_PEND) ||
+		(p_ch->irb->scsw.cmd.stctl ==
+		(SCSW_STCTL_ALERT_STATUS | SCSW_STCTL_STATUS_PEND)))) {
+			CLAW_DBF_TEXT(4, trace, "writeUE");
+			return;
+		}
+		clear_bit(0, (void *)&p_ch->IO_active);
+		if (claw_test_and_setbit_busy(TB_TX, dev) == 0) {
+			claw_write_next(p_ch);
+			claw_clearbit_busy(TB_TX, dev);
+			claw_clear_busy(dev);
+		}
+		p_ch_r = (struct chbk *)&privptr->channel[READ];
+		if (test_and_set_bit(CLAW_BH_ACTIVE,
+			(void *)&p_ch_r->flag_a) == 0)
+			tasklet_schedule(&p_ch_r->tasklet);
+		CLAW_DBF_TEXT(4, trace, "StWtExit");
+		return;
+	default:
+		printk(KERN_WARNING "%s: wrong selection code - irq "
+			"state=%d\n", dev->name, p_ch->claw_state);
+		CLAW_DBF_TEXT(2, trace, "badIRQ");
+		return;
         }
 
 }       /*   end of claw_irq_handler    */
@@ -1013,29 +779,11 @@ claw_irq_tasklet ( unsigned long data )
 
 	p_ch = (struct chbk *) data;
         dev = (struct net_device *)p_ch->ndev;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable p_ch =\n",dev->name);
-        dumpit((char *) p_ch, sizeof(struct chbk));
-#endif
-	CLAW_DBF_TEXT(4,trace,"IRQtask");
-
+	CLAW_DBF_TEXT(4, trace, "IRQtask");
         privptr = (struct claw_privbk *) dev->priv;
-
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: bh routine - state-%02x\n" ,
-		dev->name, p_ch->claw_state);
-#endif
-
         unpack_read(dev);
         clear_bit(CLAW_BH_ACTIVE, (void *)&p_ch->flag_a);
-	CLAW_DBF_TEXT(4,trace,"TskletXt");
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
+	CLAW_DBF_TEXT(4, trace, "TskletXt");
         return;
 }       /*    end of claw_irq_bh    */
 
@@ -1060,16 +808,7 @@ claw_release(struct net_device *dev)
         privptr = (struct claw_privbk *) dev->priv;
         if (!privptr)
                 return 0;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"release");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-	printk(KERN_INFO "Priv Buffalloc %d\n",privptr->buffs_alloc);
-	printk(KERN_INFO "Priv p_buff_ccw = %p\n",&privptr->p_buff_ccw);
-#endif
+	CLAW_DBF_TEXT(4, trace, "release");
         privptr->release_pend=1;
         claw_setbit_busy(TB_STOP,dev);
         for ( i = 1; i >=0 ;  i--) {
@@ -1101,19 +840,15 @@ claw_release(struct net_device *dev)
 		privptr->pk_skb = NULL;
 	}
 	if(privptr->buffs_alloc != 1) {
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-		CLAW_DBF_TEXT(4,trace,"none2fre");
+		CLAW_DBF_TEXT(4, trace, "none2fre");
 		return 0;
 	}
-	CLAW_DBF_TEXT(4,trace,"freebufs");
+	CLAW_DBF_TEXT(4, trace, "freebufs");
 	if (privptr->p_buff_ccw != NULL) {
         	free_pages((unsigned long)privptr->p_buff_ccw,
 	        	(int)pages_to_order_of_mag(privptr->p_buff_ccw_num));
 	}
-	CLAW_DBF_TEXT(4,trace,"freeread");
+	CLAW_DBF_TEXT(4, trace, "freeread");
         if (privptr->p_env->read_size < PAGE_SIZE) {
 	    if (privptr->p_buff_read != NULL) {
                 free_pages((unsigned long)privptr->p_buff_read,
@@ -1129,7 +864,7 @@ claw_release(struct net_device *dev)
                         p_buf=p_buf->next;
                 }
         }
-	 CLAW_DBF_TEXT(4,trace,"freewrit");
+	 CLAW_DBF_TEXT(4, trace, "freewrit");
         if (privptr->p_env->write_size < PAGE_SIZE ) {
                 free_pages((unsigned long)privptr->p_buff_write,
 		      (int)pages_to_order_of_mag(privptr->p_buff_write_num));
@@ -1143,7 +878,7 @@ claw_release(struct net_device *dev)
                         p_buf=p_buf->next;
                 }
         }
-	 CLAW_DBF_TEXT(4,trace,"clearptr");
+	 CLAW_DBF_TEXT(4, trace, "clearptr");
 	privptr->buffs_alloc = 0;
         privptr->p_buff_ccw=NULL;
         privptr->p_buff_read=NULL;
@@ -1180,18 +915,12 @@ claw_release(struct net_device *dev)
                 dev->name,
 		privptr->channel[READ].last_dstat,
 		privptr->channel[WRITE].last_dstat);
-		 CLAW_DBF_TEXT(2,trace,"badclose");
+		 CLAW_DBF_TEXT(2, trace, "badclose");
         }
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"rlsexit");
+	CLAW_DBF_TEXT(4, trace, "rlsexit");
         return 0;
 }      /* end of claw_release     */
 
-
-
 /*-------------------------------------------------------------------*
 *       claw_write_retry                                             *
 *                                                                    *
@@ -1203,32 +932,12 @@ claw_write_retry ( struct chbk *p_ch )
 
         struct net_device  *dev=p_ch->ndev;
 
-
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-        printk(KERN_INFO "claw: variable p_ch =\n");
-        dumpit((char *) p_ch, sizeof(struct chbk));
-#endif
-	CLAW_DBF_TEXT(4,trace,"w_retry");
+	CLAW_DBF_TEXT(4, trace, "w_retry");
         if (p_ch->claw_state == CLAW_STOP) {
-#ifdef FUNCTRACE
-		printk(KERN_INFO "%s:%s Exit on line %d\n",
-			dev->name,__func__,__LINE__);
-#endif
         	return;
         }
-#ifdef DEBUGMSG
-        printk( KERN_INFO "%s:%s  state-%02x\n" ,
-		dev->name,
-		__func__,
-		p_ch->claw_state);
-#endif
 	claw_strt_out_IO( dev );
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"rtry_xit");
+	CLAW_DBF_TEXT(4, trace, "rtry_xit");
         return;
 }      /* end of claw_write_retry      */
 
@@ -1247,12 +956,7 @@ claw_write_next ( struct chbk * p_ch )
 	struct sk_buff *pk_skb;
 	int	rc;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",p_ch->ndev->name,__func__);
-        printk(KERN_INFO "%s: variable p_ch =\n",p_ch->ndev->name);
-        dumpit((char *) p_ch, sizeof(struct chbk));
-#endif
-	CLAW_DBF_TEXT(4,trace,"claw_wrt");
+	CLAW_DBF_TEXT(4, trace, "claw_wrt");
         if (p_ch->claw_state == CLAW_STOP)
                 return;
         dev = (struct net_device *) p_ch->ndev;
@@ -1272,11 +976,6 @@ claw_write_next ( struct chbk * p_ch )
         if (privptr->p_write_active_first!=NULL) {
                 claw_strt_out_IO(dev);
         }
-
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
         return;
 }      /* end of claw_write_next      */
 
@@ -1288,22 +987,12 @@ claw_write_next ( struct chbk * p_ch )
 static void
 claw_timer ( struct chbk * p_ch )
 {
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Entry\n",p_ch->ndev->name,__func__);
-        printk(KERN_INFO "%s: variable p_ch =\n",p_ch->ndev->name);
-        dumpit((char *) p_ch, sizeof(struct chbk));
-#endif
-	CLAW_DBF_TEXT(4,trace,"timer");
+	CLAW_DBF_TEXT(4, trace, "timer");
         p_ch->flag |= CLAW_TIMER;
         wake_up(&p_ch->wait);
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		p_ch->ndev->name,__func__,__LINE__);
-#endif
         return;
 }      /* end of claw_timer  */
 
-
 /*
 *
 *       functions
@@ -1324,10 +1013,8 @@ pages_to_order_of_mag(int num_of_pages)
 {
 	int	order_of_mag=1;		/* assume 2 pages */
 	int	nump=2;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s Enter pages = %d \n",__func__,num_of_pages);
-#endif
-	CLAW_DBF_TEXT_(5,trace,"pages%d",num_of_pages);
+
+	CLAW_DBF_TEXT_(5, trace, "pages%d", num_of_pages);
 	if (num_of_pages == 1)   {return 0; }  /* magnitude of 0 = 1 page */
 	/* 512 pages = 2Meg on 4k page systems */
 	if (num_of_pages >= 512) {return 9; }
@@ -1338,11 +1025,7 @@ pages_to_order_of_mag(int num_of_pages)
 	  order_of_mag +=1;
 	}
 	if (order_of_mag > 9) { order_of_mag = 9; }  /* I know it's paranoid */
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s Exit on line %d, order = %d\n",
-	__func__,__LINE__, order_of_mag);
-#endif
-	CLAW_DBF_TEXT_(5,trace,"mag%d",order_of_mag);
+	CLAW_DBF_TEXT_(5, trace, "mag%d", order_of_mag);
 	return order_of_mag;
 }
 
@@ -1358,21 +1041,7 @@ add_claw_reads(struct net_device *dev, s
         struct claw_privbk *privptr;
         struct ccw1  temp_ccw;
         struct endccw * p_end;
-#ifdef IOTRACE
-        struct ccwbk*  p_buf;
-#endif
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-#ifdef DEBUGMSG
-        printk(KERN_INFO "dev\n");
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "p_first\n");
-        dumpit((char *) p_first, sizeof(struct ccwbk));
-        printk(KERN_INFO "p_last\n");
-        dumpit((char *) p_last, sizeof(struct ccwbk));
-#endif
-	CLAW_DBF_TEXT(4,trace,"addreads");
+	CLAW_DBF_TEXT(4, trace, "addreads");
         privptr = dev->priv;
         p_end = privptr->p_end_ccw;
 
@@ -1380,11 +1049,7 @@ add_claw_reads(struct net_device *dev, s
         *       to apend the running channel programs
         */
         if ( p_first==NULL) {
-#ifdef FUNCTRACE
-		printk(KERN_INFO "%s:%s Exit on line %d\n",
-			dev->name,__func__,__LINE__);
-#endif
-		CLAW_DBF_TEXT(4,trace,"addexit");
+		CLAW_DBF_TEXT(4, trace, "addexit");
                 return 0;
         }
 
@@ -1411,21 +1076,11 @@ add_claw_reads(struct net_device *dev, s
         }
 
         if ( privptr-> p_read_active_first ==NULL ) {
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s:%s p_read_active_first == NULL \n",
-			dev->name,__func__);
-                printk(KERN_INFO "%s:%s Read active first/last changed \n",
-			dev->name,__func__);
-#endif
                 privptr-> p_read_active_first= p_first;  /*    set new first */
                 privptr-> p_read_active_last = p_last;   /*    set new last  */
         }
         else {
 
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s:%s Read in progress \n",
-		dev->name,__func__);
-#endif
                 /* set up TIC ccw  */
                 temp_ccw.cda= (__u32)__pa(&p_first->read);
                 temp_ccw.count=0;
@@ -1462,27 +1117,7 @@ add_claw_reads(struct net_device *dev, s
                 privptr->p_read_active_last->next = p_first;
                 privptr->p_read_active_last=p_last;
         } /* end of if ( privptr-> p_read_active_first ==NULL)  */
-#ifdef IOTRACE
-	printk(KERN_INFO "%s:%s  dump p_last CCW BK \n",dev->name,__func__);
-        dumpit((char *)p_last, sizeof(struct ccwbk));
-	printk(KERN_INFO "%s:%s  dump p_end CCW BK \n",dev->name,__func__);
-        dumpit((char *)p_end, sizeof(struct endccw));
-
-	printk(KERN_INFO "%s:%s dump p_first CCW BK \n",dev->name,__func__);
-        dumpit((char *)p_first, sizeof(struct ccwbk));
-        printk(KERN_INFO "%s:%s Dump Active CCW chain \n",
-		dev->name,__func__);
-        p_buf=privptr->p_read_active_first;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-#endif
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"addexit");
+	CLAW_DBF_TEXT(4, trace, "addexit");
         return 0;
 }    /*     end of add_claw_reads   */
 
@@ -1494,44 +1129,29 @@ add_claw_reads(struct net_device *dev, s
 static void
 ccw_check_return_code(struct ccw_device *cdev, int return_code)
 {
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() > enter  \n",
-		cdev->dev.bus_id,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"ccwret");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "variable cdev =\n");
-        dumpit((char *) cdev, sizeof(struct ccw_device));
-        printk(KERN_INFO "variable return_code = %d\n",return_code);
-#endif
+	CLAW_DBF_TEXT(4, trace, "ccwret");
         if (return_code != 0) {
                 switch (return_code) {
-                        case -EBUSY:
-                                printk(KERN_INFO "%s: Busy !\n",
-					cdev->dev.bus_id);
-                                break;
-                        case -ENODEV:
-                                printk(KERN_EMERG "%s: Missing device called "
-					"for IO ENODEV\n", cdev->dev.bus_id);
-                                break;
-                        case -EIO:
-                                printk(KERN_EMERG "%s: Status pending... EIO \n",
-					cdev->dev.bus_id);
-                                break;
-			case -EINVAL:
-                                printk(KERN_EMERG "%s: Invalid Dev State EINVAL \n",
-					cdev->dev.bus_id);
-                                break;
-                        default:
-                                printk(KERN_EMERG "%s: Unknown error in "
+		case -EBUSY: /* BUSY is a transient state no action needed */
+			break;
+		case -ENODEV:
+			printk(KERN_EMERG "%s: Missing device called "
+				"for IO ENODEV\n", cdev->dev.bus_id);
+			break;
+		case -EIO:
+			printk(KERN_EMERG "%s: Status pending... EIO \n",
+				cdev->dev.bus_id);
+			break;
+		case -EINVAL:
+			printk(KERN_EMERG "%s: Invalid Dev State EINVAL \n",
+				cdev->dev.bus_id);
+			break;
+		default:
+			printk(KERN_EMERG "%s: Unknown error in "
 				 "Do_IO %d\n",cdev->dev.bus_id, return_code);
-                }
-        }
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() > exit on line %d\n",
-		cdev->dev.bus_id,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"ccwret");
+		}
+	}
+	CLAW_DBF_TEXT(4, trace, "ccwret");
 }    /*    end of ccw_check_return_code   */
 
 /*-------------------------------------------------------------------*
@@ -1541,173 +1161,46 @@ ccw_check_return_code(struct ccw_device 
 static void
 ccw_check_unit_check(struct chbk * p_ch, unsigned char sense )
 {
-	struct net_device *dev = p_ch->ndev;
-
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s: %s() > enter\n",dev->name,__func__);
-#endif
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *)dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable sense =\n",dev->name);
-        dumpit((char *)&sense, 2);
-#endif
-	CLAW_DBF_TEXT(4,trace,"unitchek");
+	struct net_device *ndev = p_ch->ndev;
 
+	CLAW_DBF_TEXT(4, trace, "unitchek");
         printk(KERN_INFO "%s: Unit Check with sense byte:0x%04x\n",
-                dev->name, sense);
+	       ndev->name, sense);
 
         if (sense & 0x40) {
                 if (sense & 0x01) {
                         printk(KERN_WARNING "%s: Interface disconnect or "
 				"Selective reset "
-			       	"occurred (remote side)\n", dev->name);
+				"occurred (remote side)\n", ndev->name);
                 }
                 else {
                         printk(KERN_WARNING "%s: System reset occured"
-				" (remote side)\n", dev->name);
+				" (remote side)\n", ndev->name);
                 }
         }
         else if (sense & 0x20) {
                 if (sense & 0x04) {
                         printk(KERN_WARNING "%s: Data-streaming "
-				"timeout)\n", dev->name);
+				"timeout)\n", ndev->name);
                 }
                 else  {
                         printk(KERN_WARNING "%s: Data-transfer parity"
-				" error\n", dev->name);
+				" error\n", ndev->name);
                 }
         }
         else if (sense & 0x10) {
                 if (sense & 0x20) {
                         printk(KERN_WARNING "%s: Hardware malfunction "
-				"(remote side)\n", dev->name);
+				"(remote side)\n", ndev->name);
                 }
                 else {
                         printk(KERN_WARNING "%s: read-data parity error "
-				"(remote side)\n", dev->name);
+				"(remote side)\n", ndev->name);
                 }
         }
 
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
 }   /*    end of ccw_check_unit_check    */
 
-
-
-/*-------------------------------------------------------------------*
-* Dump buffer format                                                 *
-*                                                                    *
-*--------------------------------------------------------------------*/
-#ifdef DEBUG
-static void
-dumpit(char* buf, int len)
-{
-
-        __u32      ct, sw, rm, dup;
-        char       *ptr, *rptr;
-        char       tbuf[82], tdup[82];
-#if (CONFIG_64BIT)
-        char       addr[22];
-#else
-        char       addr[12];
-#endif
-        char       boff[12];
-        char       bhex[82], duphex[82];
-        char       basc[40];
-
-        sw  = 0;
-        rptr =ptr=buf;
-        rm  = 16;
-        duphex[0]  = 0x00;
-        dup = 0;
-        for ( ct=0; ct < len; ct++, ptr++, rptr++ )  {
-                if (sw == 0) {
-#if (CONFIG_64BIT)
-                        sprintf(addr, "%16.16lX",(unsigned long)rptr);
-#else
-                        sprintf(addr, "%8.8X",(__u32)rptr);
-#endif
-                        sprintf(boff, "%4.4X", (__u32)ct);
-                        bhex[0] = '\0';
-                        basc[0] = '\0';
-                }
-                if ((sw == 4) || (sw == 12)) {
-                        strcat(bhex, " ");
-                }
-                if (sw == 8) {
-                        strcat(bhex, "  ");
-                }
-#if (CONFIG_64BIT)
-                sprintf(tbuf,"%2.2lX", (unsigned long)*ptr);
-#else
-                sprintf(tbuf,"%2.2X", (__u32)*ptr);
-#endif
-                tbuf[2] = '\0';
-                strcat(bhex, tbuf);
-                if ((0!=isprint(*ptr)) && (*ptr >= 0x20)) {
-                        basc[sw] = *ptr;
-                }
-                else {
-                        basc[sw] = '.';
-                }
-                basc[sw+1] = '\0';
-                sw++;
-                rm--;
-                if (sw==16) {
-                        if ((strcmp(duphex, bhex)) !=0) {
-                                if (dup !=0) {
-					sprintf(tdup,"Duplicate as above to"
-						" %s", addr);
-                                        printk( KERN_INFO "                 "
-						"   --- %s ---\n",tdup);
-                                }
-                                printk( KERN_INFO "   %s (+%s) : %s  [%s]\n",
-					 addr, boff, bhex, basc);
-                                dup = 0;
-                                strcpy(duphex, bhex);
-                        }
-                        else {
-                                dup++;
-                        }
-                        sw = 0;
-                        rm = 16;
-                }
-        }  /* endfor */
-
-        if (sw != 0) {
-                for ( ; rm > 0; rm--, sw++ ) {
-                        if ((sw==4) || (sw==12)) strcat(bhex, " ");
-                        if (sw==8)               strcat(bhex, "  ");
-                        strcat(bhex, "  ");
-                        strcat(basc, " ");
-                }
-                if (dup !=0) {
-                        sprintf(tdup,"Duplicate as above to %s", addr);
-                        printk( KERN_INFO "                    --- %s ---\n",
-				tdup);
-                }
-                printk( KERN_INFO "   %s (+%s) : %s  [%s]\n",
-			addr, boff, bhex, basc);
-        }
-        else {
-                if (dup >=1) {
-                        sprintf(tdup,"Duplicate as above to %s", addr);
-                        printk( KERN_INFO "                    --- %s ---\n",
-				tdup);
-                }
-                if (dup !=0) {
-                        printk( KERN_INFO "   %s (+%s) : %s  [%s]\n",
-				addr, boff, bhex, basc);
-                }
-        }
-        return;
-
-}   /*   end of dumpit  */
-#endif
-
 /*-------------------------------------------------------------------*
 *               find_link                                            *
 *--------------------------------------------------------------------*/
@@ -1718,16 +1211,7 @@ find_link(struct net_device *dev, char *
 	struct claw_env *p_env;
 	int    rc=0;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s > enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"findlink");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev = \n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable host_name = %s\n",dev->name, host_name);
-        printk(KERN_INFO "%s: variable ws_name = %s\n",dev->name, ws_name);
-#endif
+	CLAW_DBF_TEXT(2, setup, "findlink");
         privptr=dev->priv;
         p_env=privptr->p_env;
 	switch (p_env->packing)
@@ -1750,10 +1234,6 @@ find_link(struct net_device *dev, char *
 			break;
 	}
 
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
         return 0;
 }    /*    end of find_link    */
 
@@ -1782,27 +1262,11 @@ claw_hw_tx(struct sk_buff *skb, struct n
         int                             lock;
 	struct clawph			*pk_head;
 	struct chbk			*ch;
-#ifdef IOTRACE
-        struct ccwbk                   *p_buf;
-#endif
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s: %s() > enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"hw_tx");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev skb =\n",dev->name);
-        dumpit((char *) skb, sizeof(struct sk_buff));
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable linkid = %ld\n",dev->name,linkid);
-#endif
+
+	CLAW_DBF_TEXT(4, trace, "hw_tx");
         privptr = (struct claw_privbk *) (dev->priv);
         p_ch=(struct chbk *)&privptr->channel[WRITE];
 	p_env =privptr->p_env;
-#ifdef IOTRACE
-	printk(KERN_INFO "%s: %s() dump sk_buff  \n",dev->name,__func__);
-        dumpit((char *)skb ,sizeof(struct sk_buff));
-#endif
 	claw_free_wrt_buf(dev);	/* Clean up free chain if posible */
         /*  scan the write queue to free any completed write packets   */
         p_first_ccw=NULL;
@@ -1834,11 +1298,6 @@ claw_hw_tx(struct sk_buff *skb, struct n
                                 claw_strt_out_IO(dev );
                                 claw_free_wrt_buf( dev );
                                 if (privptr->write_free_count==0) {
-#ifdef IOTRACE
-                                	printk(KERN_INFO "%s: "
-					   "(claw_check_busy) no free write "
-					   "buffers\n", dev->name);
-#endif
 					ch = &privptr->channel[WRITE];
 					atomic_inc(&skb->users);
 					skb_queue_tail(&ch->collect_queue, skb);
@@ -1851,10 +1310,6 @@ claw_hw_tx(struct sk_buff *skb, struct n
                 }
                 /*  tx lock  */
                 if (claw_test_and_setbit_busy(TB_TX,dev)) { /* set to busy */
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s:  busy  (claw_test_and_setbit_"
-				"busy)\n", dev->name);
-#endif
 			ch = &privptr->channel[WRITE];
 			atomic_inc(&skb->users);
 			skb_queue_tail(&ch->collect_queue, skb);
@@ -1871,28 +1326,16 @@ claw_hw_tx(struct sk_buff *skb, struct n
             privptr->p_write_free_chain == NULL ) {
 
                 claw_setbit_busy(TB_NOBUFFER,dev);
-
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s:  busy  (claw_setbit_busy"
-			"(TB_NOBUFFER))\n", dev->name);
-                printk(KERN_INFO "       free_count: %d, numBuffers : %d\n",
-			(int)privptr->write_free_count,(int) numBuffers );
-#endif
 		ch = &privptr->channel[WRITE];
 		atomic_inc(&skb->users);
 		skb_queue_tail(&ch->collect_queue, skb);
-		CLAW_DBF_TEXT(2,trace,"clawbusy");
+		CLAW_DBF_TEXT(2, trace, "clawbusy");
                 goto Done2;
         }
         pDataAddress=skb->data;
         len_of_data=skb->len;
 
         while (len_of_data > 0) {
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: %s() length-of-data is %ld \n",
-			dev->name ,__func__,len_of_data);
-                dumpit((char *)pDataAddress ,64);
-#endif
                 p_this_ccw=privptr->p_write_free_chain;  /* get a block */
 		if (p_this_ccw == NULL) { /* lost the race */
 			ch = &privptr->channel[WRITE];
@@ -1924,12 +1367,6 @@ claw_hw_tx(struct sk_buff *skb, struct n
 				(__u32)__pa(&p_this_ccw->write);
                 }
                 p_last_ccw=p_this_ccw;      /* save new last block */
-#ifdef IOTRACE
-		printk(KERN_INFO "%s: %s() > CCW and Buffer %ld bytes long \n",
-			dev->name,__func__,bytesInThisBuffer);
-                dumpit((char *)p_this_ccw, sizeof(struct ccwbk));
-                dumpit((char *)p_this_ccw->p_buffer, 64);
-#endif
         }
 
         /*      FirstCCW and LastCCW now contain a new set of write channel
@@ -1962,13 +1399,11 @@ claw_hw_tx(struct sk_buff *skb, struct n
                         pEnd->write1_nop2.count=1;
                 }  /* end if if (pEnd->write1) */
 
-
                 if (privptr->p_write_active_first==NULL ) {
                         privptr->p_write_active_first=p_first_ccw;
                         privptr->p_write_active_last=p_last_ccw;
                 }
                 else {
-
                         /*      set up Tic CCWs         */
 
                         tempCCW.cda=(__u32)__pa(&p_first_ccw->write);
@@ -2007,19 +1442,6 @@ claw_hw_tx(struct sk_buff *skb, struct n
                 }
 
         } /* endif (p_first_ccw!=NULL)  */
-
-
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: %s() >  Dump Active CCW chain \n",
-		dev->name,__func__);
-        p_buf=privptr->p_write_active_first;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-        p_buf=(struct ccwbk*)privptr->p_end_ccw;
-        dumpit((char *)p_buf, sizeof(struct endccw));
-#endif
         dev_kfree_skb_any(skb);
 	if (linkid==0) {
         	lock=LOCK_NO;
@@ -2029,21 +1451,12 @@ claw_hw_tx(struct sk_buff *skb, struct n
         }
         claw_strt_out_IO(dev );
         /*      if write free count is zero , set NOBUFFER       */
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() > free_count is %d\n",
-		dev->name,__func__,
-		(int) privptr->write_free_count );
-#endif
 	if (privptr->write_free_count==0) {
 		claw_setbit_busy(TB_NOBUFFER,dev);
         }
 Done2:
 	claw_clearbit_busy(TB_TX,dev);
 Done:
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() > exit on line %d, rc = %d \n",
-		dev->name,__func__,__LINE__, rc);
-#endif
 	return(rc);
 }    /*    end of claw_hw_tx    */
 
@@ -2075,14 +1488,7 @@ init_ccw_bk(struct net_device *dev)
         struct clawh *pClawH=NULL;
         addr_t   real_TIC_address;
         int i,j;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s: %s() enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"init_ccw");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-#endif
+	CLAW_DBF_TEXT(4, trace, "init_ccw");
 
         /*  initialize  statistics field */
         privptr->active_link_ID=0;
@@ -2107,20 +1513,6 @@ init_ccw_bk(struct net_device *dev)
         */
         ccw_blocks_required =
 		privptr->p_env->read_buffers+privptr->p_env->write_buffers+1;
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() "
-		"ccw_blocks_required=%d\n",
-		dev->name,__func__,
-		ccw_blocks_required);
-        printk(KERN_INFO "%s: %s() "
-		"PAGE_SIZE=0x%x\n",
-		dev->name,__func__,
-		(unsigned int)PAGE_SIZE);
-        printk(KERN_INFO "%s: %s() > "
-		"PAGE_MASK=0x%x\n",
-		dev->name,__func__,
-		(unsigned int)PAGE_MASK);
-#endif
         /*
         * compute number of CCW blocks that will fit in a page
         */
@@ -2128,14 +1520,6 @@ init_ccw_bk(struct net_device *dev)
         ccw_pages_required=
 		DIV_ROUND_UP(ccw_blocks_required, ccw_blocks_perpage);
 
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() > ccw_blocks_perpage=%d\n",
-		dev->name,__func__,
-		ccw_blocks_perpage);
-        printk(KERN_INFO "%s: %s() > ccw_pages_required=%d\n",
-		dev->name,__func__,
-		ccw_pages_required);
-#endif
         /*
          *  read and write sizes are set by 2 constants in claw.h
 	 *  4k and 32k.  Unpacked values other than 4k are not going to
@@ -2166,36 +1550,6 @@ init_ccw_bk(struct net_device *dev)
 		claw_write_pages = privptr->p_env->write_buffers *
 					privptr->p_buff_pages_perwrite;
         }
-#ifdef DEBUGMSG
-        if (privptr->p_env->read_size < PAGE_SIZE) {
-            printk(KERN_INFO "%s: %s() reads_perpage=%d\n",
-		dev->name,__func__,
-		claw_reads_perpage);
-        }
-        else {
-            printk(KERN_INFO "%s: %s() pages_perread=%d\n",
-		dev->name,__func__,
-		privptr->p_buff_pages_perread);
-        }
-        printk(KERN_INFO "%s: %s() read_pages=%d\n",
-		dev->name,__func__,
-		claw_read_pages);
-        if (privptr->p_env->write_size < PAGE_SIZE) {
-            printk(KERN_INFO "%s: %s() writes_perpage=%d\n",
-		dev->name,__func__,
-		claw_writes_perpage);
-        }
-        else {
-            printk(KERN_INFO "%s: %s() pages_perwrite=%d\n",
-		dev->name,__func__,
-		privptr->p_buff_pages_perwrite);
-        }
-        printk(KERN_INFO "%s: %s() write_pages=%d\n",
-		dev->name,__func__,
-		claw_write_pages);
-#endif
-
-
         /*
         *               allocate ccw_pages_required
         */
@@ -2204,17 +1558,6 @@ init_ccw_bk(struct net_device *dev)
 			(void *)__get_free_pages(__GFP_DMA,
 		        (int)pages_to_order_of_mag(ccw_pages_required ));
                 if (privptr->p_buff_ccw==NULL) {
-                        printk(KERN_INFO "%s: %s()  "
-				"__get_free_pages for CCWs failed : "
-				"pages is %d\n",
-				dev->name,__func__,
-				ccw_pages_required );
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s: %s() > "
-				"exit on line %d, rc = ENOMEM\n",
-				dev->name,__func__,
-				 __LINE__);
-#endif
                         return -ENOMEM;
                 }
                 privptr->p_buff_ccw_num=ccw_pages_required;
@@ -2229,11 +1572,6 @@ init_ccw_bk(struct net_device *dev)
         privptr->p_end_ccw = (struct endccw *)&privptr->end_ccw;
         real_address  = (__u32)__pa(privptr->p_end_ccw);
         /*                              Initialize ending CCW block       */
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() begin initialize ending CCW blocks\n",
-		dev->name,__func__);
-#endif
-
         p_endccw=privptr->p_end_ccw;
         p_endccw->real=real_address;
         p_endccw->write1=0x00;
@@ -2287,21 +1625,10 @@ init_ccw_bk(struct net_device *dev)
         p_endccw->read2_nop2.count        = 1;
         p_endccw->read2_nop2.cda          = 0;
 
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: %s() dump claw ending CCW BK \n",
-		dev->name,__func__);
-        dumpit((char *)p_endccw, sizeof(struct endccw));
-#endif
-
         /*
         *                               Build a chain of CCWs
         *
         */
-
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s()  Begin build a chain of CCW buffer \n",
-		dev->name,__func__);
-#endif
         p_buff=privptr->p_buff_ccw;
 
         p_free_chain=NULL;
@@ -2316,26 +1643,10 @@ init_ccw_bk(struct net_device *dev)
                 }
                 p_buff+=PAGE_SIZE;
         }
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() "
-		"End build a chain of CCW buffer \n",
-			dev->name,__func__);
-        p_buf=p_free_chain;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-#endif
-
         /*
         *                               Initialize ClawSignalBlock
         *
         */
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() "
-		"Begin initialize ClawSignalBlock \n",
-		dev->name,__func__);
-#endif
         if (privptr->p_claw_signal_blk==NULL) {
                 privptr->p_claw_signal_blk=p_free_chain;
                 p_free_chain=p_free_chain->next;
@@ -2344,12 +1655,6 @@ init_ccw_bk(struct net_device *dev)
                 pClawH->opcode=0xff;
                 pClawH->flag=CLAW_BUSY;
         }
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() >  End initialize "
-	 	"ClawSignalBlock\n",
-		dev->name,__func__);
-        dumpit((char *)privptr->p_claw_signal_blk, sizeof(struct ccwbk));
-#endif
 
         /*
         *               allocate write_pages_required and add to free chain
@@ -2360,17 +1665,7 @@ init_ccw_bk(struct net_device *dev)
 			(void *)__get_free_pages(__GFP_DMA,
 			(int)pages_to_order_of_mag(claw_write_pages ));
                 if (privptr->p_buff_write==NULL) {
-                        printk(KERN_INFO "%s: %s() __get_free_pages for write"
-				" bufs failed : get is for %d pages\n",
-				dev->name,__func__,claw_write_pages );
-                        free_pages((unsigned long)privptr->p_buff_ccw,
-			   (int)pages_to_order_of_mag(privptr->p_buff_ccw_num));
                         privptr->p_buff_ccw=NULL;
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s: %s() > exit on line %d,"
-			 	"rc = ENOMEM\n",
-				dev->name,__func__,__LINE__);
-#endif
                         return -ENOMEM;
                 }
                 /*
@@ -2380,10 +1675,6 @@ init_ccw_bk(struct net_device *dev)
 
                 memset(privptr->p_buff_write, 0x00,
 			ccw_pages_required * PAGE_SIZE);
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: %s() Begin build claw write free "
-			"chain \n",dev->name,__func__);
-#endif
                 privptr->p_write_free_chain=NULL;
 
                 p_buff=privptr->p_buff_write;
@@ -2419,18 +1710,7 @@ init_ccw_bk(struct net_device *dev)
                    p_buff=(void *)__get_free_pages(__GFP_DMA,
 		        (int)pages_to_order_of_mag(
 			privptr->p_buff_pages_perwrite) );
-#ifdef IOTRACE
-                   printk(KERN_INFO "%s:%s __get_free_pages "
-		    "for writes buf: get for %d pages\n",
-		    dev->name,__func__,
-		    privptr->p_buff_pages_perwrite);
-#endif
                    if (p_buff==NULL) {
-			printk(KERN_INFO "%s:%s __get_free_pages "
-			 	"for writes buf failed : get is for %d pages\n",
-				dev->name,
-				__func__,
-				privptr->p_buff_pages_perwrite );
                         free_pages((unsigned long)privptr->p_buff_ccw,
 			      (int)pages_to_order_of_mag(
 			      		privptr->p_buff_ccw_num));
@@ -2443,12 +1723,6 @@ init_ccw_bk(struct net_device *dev)
 					privptr->p_buff_pages_perwrite));
                                 p_buf=p_buf->next;
                         }
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s: %s exit on line %d, rc = ENOMEM\n",
-			dev->name,
-			__func__,
-			__LINE__);
-#endif
                         return -ENOMEM;
                    }  /* Error on get_pages   */
                    memset(p_buff, 0x00, privptr->p_env->write_size );
@@ -2477,15 +1751,6 @@ init_ccw_bk(struct net_device *dev)
         privptr->write_free_count=privptr->p_env->write_buffers;
 
 
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s:%s  End build claw write free chain \n",
-	dev->name,__func__);
-        p_buf=privptr->p_write_free_chain;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-#endif
         /*
         *               allocate read_pages_required and chain to free chain
         */
@@ -2495,10 +1760,6 @@ init_ccw_bk(struct net_device *dev)
 			(void *)__get_free_pages(__GFP_DMA,
 			(int)pages_to_order_of_mag(claw_read_pages) );
                 if (privptr->p_buff_read==NULL) {
-                        printk(KERN_INFO "%s: %s() "
-			 	"__get_free_pages for read buf failed : "
-			 	"get is for %d pages\n",
-				dev->name,__func__,claw_read_pages );
                         free_pages((unsigned long)privptr->p_buff_ccw,
 				(int)pages_to_order_of_mag(
 					privptr->p_buff_ccw_num));
@@ -2508,10 +1769,6 @@ init_ccw_bk(struct net_device *dev)
 				privptr->p_buff_write_num));
                         privptr->p_buff_ccw=NULL;
                         privptr->p_buff_write=NULL;
-#ifdef FUNCTRACE
-                        printk(KERN_INFO "%s: %s() > exit on line %d, rc ="
-				" ENOMEM\n",dev->name,__func__,__LINE__);
-#endif
                         return -ENOMEM;
                 }
                 memset(privptr->p_buff_read, 0x00, claw_read_pages * PAGE_SIZE);
@@ -2520,10 +1777,6 @@ init_ccw_bk(struct net_device *dev)
                 *                               Build CLAW read free chain
                 *
                 */
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: %s() Begin build claw read free chain \n",
-			dev->name,__func__);
-#endif
                 p_buff=privptr->p_buff_read;
                 for (i=0 ; i< privptr->p_env->read_buffers ; i++) {
                         p_buf        = p_free_chain;
@@ -2600,19 +1853,10 @@ init_ccw_bk(struct net_device *dev)
                 }   /* for read_buffers   */
           }         /* read_size < PAGE_SIZE  */
           else {  /* read Size >= PAGE_SIZE  */
-
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() Begin build claw read free chain \n",
-		dev->name,__func__);
-#endif
                 for (i=0 ; i< privptr->p_env->read_buffers ; i++) {
                         p_buff = (void *)__get_free_pages(__GFP_DMA,
 				(int)pages_to_order_of_mag(privptr->p_buff_pages_perread) );
                         if (p_buff==NULL) {
-                                printk(KERN_INFO "%s: %s() __get_free_pages for read "
-					"buf failed : get is for %d pages\n",
-					dev->name,__func__,
-                                        privptr->p_buff_pages_perread );
                                 free_pages((unsigned long)privptr->p_buff_ccw,
 					(int)pages_to_order_of_mag(privptr->p_buff_ccw_num));
 				/* free the write pages  */
@@ -2633,11 +1877,6 @@ init_ccw_bk(struct net_device *dev)
                                 }
                                 privptr->p_buff_ccw=NULL;
                                 privptr->p_buff_write=NULL;
-#ifdef FUNCTRACE
-                                printk(KERN_INFO "%s: %s() exit on line %d, rc = ENOMEM\n",
-					dev->name,__func__,
-					__LINE__);
-#endif
                                 return -ENOMEM;
                         }
                         memset(p_buff, 0x00, privptr->p_env->read_size);
@@ -2706,22 +1945,9 @@ init_ccw_bk(struct net_device *dev)
                 }    /* For read_buffers   */
           }     /*  read_size >= PAGE_SIZE   */
         }       /*  pBuffread = NULL */
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: %s() >  End build claw read free chain \n",
-		dev->name,__func__);
-        p_buf=p_first_CCWB;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-
-#endif
         add_claw_reads( dev  ,p_first_CCWB , p_last_CCWB);
 	privptr->buffs_alloc = 1;
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
+
         return 0;
 }    /*    end of init_ccw_bk */
 
@@ -2735,14 +1961,8 @@ static void
 probe_error( struct ccwgroup_device *cgdev)
 {
   struct claw_privbk *privptr;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s enter  \n",__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"proberr");
-#ifdef DEBUGMSG
-	printk(KERN_INFO "%s variable cgdev =\n",__func__);
-        dumpit((char *) cgdev, sizeof(struct ccwgroup_device));
-#endif
+
+	CLAW_DBF_TEXT(4, trace, "proberr");
         privptr=(struct claw_privbk *)cgdev->dev.driver_data;
 	if (privptr!=NULL) {
 		kfree(privptr->p_env);
@@ -2752,16 +1972,9 @@ probe_error( struct ccwgroup_device *cgd
                 kfree(privptr);
                 privptr=NULL;
         }
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s > exit on line %d\n",
-		 __func__,__LINE__);
-#endif
-
         return;
 }    /*    probe_error    */
 
-
-
 /*-------------------------------------------------------------------*
 *    claw_process_control                                            *
 *                                                                    *
@@ -2783,32 +1996,19 @@ claw_process_control( struct net_device 
         struct conncmd *p_connect=NULL;
         int rc;
         struct chbk *p_ch = NULL;
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() > enter  \n",
-		dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"clw_cntl");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable p_ccw =\n",dev->name);
-        dumpit((char *) p_ccw, sizeof(struct ccwbk *));
-#endif
+	struct device *tdev;
+	CLAW_DBF_TEXT(2, setup, "clw_cntl");
         udelay(1000);  /* Wait a ms for the control packets to
 			*catch up to each other */
         privptr=dev->priv;
         p_env=privptr->p_env;
+	tdev = &privptr->channel[READ].cdev->dev;
 	memcpy( &temp_host_name, p_env->host_name, 8);
         memcpy( &temp_ws_name, p_env->adapter_name , 8);
         printk(KERN_INFO "%s: CLAW device %.8s: "
 		"Received Control Packet\n",
 		dev->name, temp_ws_name);
         if (privptr->release_pend==1) {
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s: %s() > "
-			"exit on line %d, rc=0\n",
-			dev->name,__func__,__LINE__);
-#endif
                 return 0;
         }
         p_buf=p_ccw->p_buffer;
@@ -2818,261 +2018,246 @@ claw_process_control( struct net_device 
 	} else {
 		memcpy(p_ctlbk, p_buf, sizeof(struct clawctl));
 	}
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: dump claw control data inbound\n",dev->name);
-        dumpit((char *)p_ctlbk, sizeof(struct clawctl));
-#endif
         switch (p_ctlbk->command)
         {
-                case SYSTEM_VALIDATE_REQUEST:
-                        if (p_ctlbk->version!=CLAW_VERSION_ID) {
-                                claw_snd_sys_validate_rsp(dev, p_ctlbk,
-					CLAW_RC_WRONG_VERSION );
-                                printk("%s: %d is wrong version id. "
-					"Expected %d\n",
-					dev->name, p_ctlbk->version,
-                                        CLAW_VERSION_ID);
-                        }
-                        p_sysval=(struct sysval *)&(p_ctlbk->data);
-			printk( "%s: Recv Sys Validate Request: "
-				"Vers=%d,link_id=%d,Corr=%d,WS name=%."
-				"8s,Host name=%.8s\n",
-                                dev->name, p_ctlbk->version,
-				p_ctlbk->linkid,
-				p_ctlbk->correlator,
-				p_sysval->WS_name,
-                                p_sysval->host_name);
-                        if (0!=memcmp(temp_host_name,p_sysval->host_name,8)) {
-                                claw_snd_sys_validate_rsp(dev, p_ctlbk,
-					CLAW_RC_NAME_MISMATCH );
-				CLAW_DBF_TEXT(2,setup,"HSTBAD");
-				CLAW_DBF_TEXT_(2,setup,"%s",p_sysval->host_name);
-				CLAW_DBF_TEXT_(2,setup,"%s",temp_host_name);
-                                printk(KERN_INFO "%s:  Host name mismatch\n",
-					dev->name);
-				printk(KERN_INFO "%s: Received :%s: "
-					"expected :%s: \n",
-					dev->name,
-					p_sysval->host_name,
-					temp_host_name);
-                        }
-                        if (0!=memcmp(temp_ws_name,p_sysval->WS_name,8)) {
-                                claw_snd_sys_validate_rsp(dev, p_ctlbk,
-					CLAW_RC_NAME_MISMATCH );
-				CLAW_DBF_TEXT(2,setup,"WSNBAD");
-                                CLAW_DBF_TEXT_(2,setup,"%s",p_sysval->WS_name);
-                                CLAW_DBF_TEXT_(2,setup,"%s",temp_ws_name);
-                                printk(KERN_INFO "%s: WS name mismatch\n",
-					dev->name);
-				 printk(KERN_INFO "%s: Received :%s: "
-                                        "expected :%s: \n",
-                                        dev->name,
-                                        p_sysval->WS_name,
-					temp_ws_name);
-                        }
-                        if (( p_sysval->write_frame_size < p_env->write_size) &&
-			   ( p_env->packing == 0)) {
-                                claw_snd_sys_validate_rsp(dev, p_ctlbk,
-					CLAW_RC_HOST_RCV_TOO_SMALL );
-                                printk(KERN_INFO "%s: host write size is too "
-					"small\n", dev->name);
-				CLAW_DBF_TEXT(2,setup,"wrtszbad");
-                        }
-                        if (( p_sysval->read_frame_size < p_env->read_size) &&
-			   ( p_env->packing == 0)) {
-                                claw_snd_sys_validate_rsp(dev, p_ctlbk,
-					CLAW_RC_HOST_RCV_TOO_SMALL );
-                                printk(KERN_INFO "%s: host read size is too "
-					"small\n", dev->name);
-				CLAW_DBF_TEXT(2,setup,"rdsizbad");
-                        }
-                        claw_snd_sys_validate_rsp(dev, p_ctlbk, 0 );
-                        printk("%s: CLAW device %.8s: System validate"
-				" completed.\n",dev->name, temp_ws_name);
-			printk("%s: sys Validate Rsize:%d Wsize:%d\n",dev->name,
-				p_sysval->read_frame_size,p_sysval->write_frame_size);
-                        privptr->system_validate_comp=1;
-                	if(strncmp(p_env->api_type,WS_APPL_NAME_PACKED,6) == 0) {
-				p_env->packing = PACKING_ASK;
-			}
-                        claw_strt_conn_req(dev);
-                        break;
-
-                case SYSTEM_VALIDATE_RESPONSE:
-			p_sysval=(struct sysval *)&(p_ctlbk->data);
-			printk("%s: Recv Sys Validate Resp: Vers=%d,Corr=%d,RC=%d,"
-				"WS name=%.8s,Host name=%.8s\n",
-                        	dev->name,
-                        	p_ctlbk->version,
-                        	p_ctlbk->correlator,
-                        	p_ctlbk->rc,
-                        	p_sysval->WS_name,
-                        	p_sysval->host_name);
-                        switch (p_ctlbk->rc)
-                        {
-                                case 0:
-                                        printk(KERN_INFO "%s: CLAW device "
-						"%.8s: System validate "
-						"completed.\n",
-                                                dev->name, temp_ws_name);
-					if (privptr->system_validate_comp == 0)
-	                                        claw_strt_conn_req(dev);
-					privptr->system_validate_comp=1;
-                                        break;
-                                case CLAW_RC_NAME_MISMATCH:
-                                        printk(KERN_INFO "%s: Sys Validate "
-						"Resp : Host, WS name is "
-						"mismatch\n",
-                                                dev->name);
-                                        break;
-                                case CLAW_RC_WRONG_VERSION:
-                                        printk(KERN_INFO "%s: Sys Validate "
-						"Resp : Wrong version\n",
-						dev->name);
-                                        break;
-                                case CLAW_RC_HOST_RCV_TOO_SMALL:
-                                        printk(KERN_INFO "%s: Sys Validate "
-						"Resp : bad frame size\n",
-						dev->name);
-                                        break;
-                                default:
-                                        printk(KERN_INFO "%s: Sys Validate "
-						"error code=%d \n",
-						 dev->name, p_ctlbk->rc );
-                                        break;
-                        }
-                        break;
+	case SYSTEM_VALIDATE_REQUEST:
+		if (p_ctlbk->version != CLAW_VERSION_ID) {
+			claw_snd_sys_validate_rsp(dev, p_ctlbk,
+				CLAW_RC_WRONG_VERSION);
+			printk("%s: %d is wrong version id. "
+			       "Expected %d\n",
+			       dev->name, p_ctlbk->version,
+			       CLAW_VERSION_ID);
+		}
+		p_sysval = (struct sysval *)&(p_ctlbk->data);
+		printk("%s: Recv Sys Validate Request: "
+		       "Vers=%d,link_id=%d,Corr=%d,WS name=%."
+		       "8s,Host name=%.8s\n",
+		       dev->name, p_ctlbk->version,
+		       p_ctlbk->linkid,
+		       p_ctlbk->correlator,
+		       p_sysval->WS_name,
+		       p_sysval->host_name);
+		if (memcmp(temp_host_name, p_sysval->host_name, 8)) {
+			claw_snd_sys_validate_rsp(dev, p_ctlbk,
+				CLAW_RC_NAME_MISMATCH);
+			CLAW_DBF_TEXT(2, setup, "HSTBAD");
+			CLAW_DBF_TEXT_(2, setup, "%s", p_sysval->host_name);
+			CLAW_DBF_TEXT_(2, setup, "%s", temp_host_name);
+			printk(KERN_INFO "%s:  Host name mismatch\n",
+				dev->name);
+			printk(KERN_INFO "%s: Received :%s: "
+				"expected :%s: \n",
+				dev->name,
+				p_sysval->host_name,
+				temp_host_name);
+		}
+		if (memcmp(temp_ws_name, p_sysval->WS_name, 8)) {
+			claw_snd_sys_validate_rsp(dev, p_ctlbk,
+				CLAW_RC_NAME_MISMATCH);
+			CLAW_DBF_TEXT(2, setup, "WSNBAD");
+			CLAW_DBF_TEXT_(2, setup, "%s", p_sysval->WS_name);
+			CLAW_DBF_TEXT_(2, setup, "%s", temp_ws_name);
+			printk(KERN_INFO "%s: WS name mismatch\n",
+				dev->name);
+			printk(KERN_INFO "%s: Received :%s: "
+			       "expected :%s: \n",
+			       dev->name,
+			       p_sysval->WS_name,
+			       temp_ws_name);
+		}
+		if ((p_sysval->write_frame_size < p_env->write_size) &&
+		    (p_env->packing == 0)) {
+			claw_snd_sys_validate_rsp(dev, p_ctlbk,
+				CLAW_RC_HOST_RCV_TOO_SMALL);
+			printk(KERN_INFO "%s: host write size is too "
+				"small\n", dev->name);
+			CLAW_DBF_TEXT(2, setup, "wrtszbad");
+		}
+		if ((p_sysval->read_frame_size < p_env->read_size) &&
+		    (p_env->packing == 0)) {
+			claw_snd_sys_validate_rsp(dev, p_ctlbk,
+				CLAW_RC_HOST_RCV_TOO_SMALL);
+			printk(KERN_INFO "%s: host read size is too "
+				"small\n", dev->name);
+			CLAW_DBF_TEXT(2, setup, "rdsizbad");
+		}
+		claw_snd_sys_validate_rsp(dev, p_ctlbk, 0);
+		printk(KERN_INFO "%s: CLAW device %.8s: System validate "
+			"completed.\n", dev->name, temp_ws_name);
+		printk("%s: sys Validate Rsize:%d Wsize:%d\n", dev->name,
+			p_sysval->read_frame_size, p_sysval->write_frame_size);
+		privptr->system_validate_comp = 1;
+		if (strncmp(p_env->api_type, WS_APPL_NAME_PACKED, 6) == 0)
+			p_env->packing = PACKING_ASK;
+		claw_strt_conn_req(dev);
+		break;
+	case SYSTEM_VALIDATE_RESPONSE:
+		p_sysval = (struct sysval *)&(p_ctlbk->data);
+		printk("%s: Recv Sys Validate Resp: Vers=%d,Corr=%d,RC=%d,"
+			"WS name=%.8s,Host name=%.8s\n",
+			dev->name,
+			p_ctlbk->version,
+			p_ctlbk->correlator,
+			p_ctlbk->rc,
+			p_sysval->WS_name,
+			p_sysval->host_name);
+		switch (p_ctlbk->rc) {
+		case 0:
+			printk(KERN_INFO "%s: CLAW device "
+				"%.8s: System validate "
+				"completed.\n",
+			       dev->name, temp_ws_name);
+			if (privptr->system_validate_comp == 0)
+				claw_strt_conn_req(dev);
+			privptr->system_validate_comp = 1;
+			break;
+		case CLAW_RC_NAME_MISMATCH:
+			printk(KERN_INFO "%s: Sys Validate "
+				"Resp : Host, WS name is "
+				"mismatch\n",
+			       dev->name);
+			break;
+		case CLAW_RC_WRONG_VERSION:
+			printk(KERN_INFO "%s: Sys Validate "
+				"Resp : Wrong version\n",
+				dev->name);
+			break;
+		case CLAW_RC_HOST_RCV_TOO_SMALL:
+			printk(KERN_INFO "%s: Sys Validate "
+				"Resp : bad frame size\n",
+				dev->name);
+			break;
+		default:
+			printk(KERN_INFO "%s: Sys Validate "
+				"error code=%d \n",
+				 dev->name, p_ctlbk->rc);
+			break;
+		}
+		break;
 
-                case CONNECTION_REQUEST:
-                        p_connect=(struct conncmd *)&(p_ctlbk->data);
-                        printk(KERN_INFO "%s: Recv Conn Req: Vers=%d,link_id=%d,"
-				"Corr=%d,HOST appl=%.8s,WS appl=%.8s\n",
-                        	dev->name,
-	                        p_ctlbk->version,
-        	                p_ctlbk->linkid,
-                	        p_ctlbk->correlator,
-                        	p_connect->host_name,
-                      		p_connect->WS_name);
-                        if (privptr->active_link_ID!=0 ) {
-                                claw_snd_disc(dev, p_ctlbk);
-                                printk(KERN_INFO "%s: Conn Req error : "
-					"already logical link is active \n",
-					dev->name);
-                        }
-                        if (p_ctlbk->linkid!=1 ) {
-                                claw_snd_disc(dev, p_ctlbk);
-                                printk(KERN_INFO "%s: Conn Req error : "
-					"req logical link id is not 1\n",
+	case CONNECTION_REQUEST:
+		p_connect = (struct conncmd *)&(p_ctlbk->data);
+		printk(KERN_INFO "%s: Recv Conn Req: Vers=%d,link_id=%d,"
+			"Corr=%d,HOST appl=%.8s,WS appl=%.8s\n",
+			dev->name,
+			p_ctlbk->version,
+			p_ctlbk->linkid,
+			p_ctlbk->correlator,
+			p_connect->host_name,
+			p_connect->WS_name);
+		if (privptr->active_link_ID != 0) {
+			claw_snd_disc(dev, p_ctlbk);
+			printk(KERN_INFO "%s: Conn Req error : "
+				"already logical link is active \n",
+				dev->name);
+		}
+		if (p_ctlbk->linkid != 1) {
+			claw_snd_disc(dev, p_ctlbk);
+			printk(KERN_INFO "%s: Conn Req error : "
+				"req logical link id is not 1\n",
+				dev->name);
+		}
+		rc = find_link(dev, p_connect->host_name, p_connect->WS_name);
+		if (rc != 0) {
+			claw_snd_disc(dev, p_ctlbk);
+			printk(KERN_INFO "%s: Conn Resp error: "
+				"req appl name does not match\n",
+				dev->name);
+		}
+		claw_send_control(dev,
+			CONNECTION_CONFIRM, p_ctlbk->linkid,
+			p_ctlbk->correlator,
+			0, p_connect->host_name,
+			p_connect->WS_name);
+		if (p_env->packing == PACKING_ASK) {
+			p_env->packing = PACK_SEND;
+			claw_snd_conn_req(dev, 0);
+		}
+		printk(KERN_INFO "%s: CLAW device %.8s: Connection "
+			"completed link_id=%d.\n",
+			dev->name, temp_ws_name,
+			p_ctlbk->linkid);
+			privptr->active_link_ID = p_ctlbk->linkid;
+			p_ch = &privptr->channel[WRITE];
+			wake_up(&p_ch->wait);  /* wake up claw_open ( WRITE) */
+		break;
+	case CONNECTION_RESPONSE:
+		p_connect = (struct conncmd *)&(p_ctlbk->data);
+		printk(KERN_INFO "%s: Revc Conn Resp: Vers=%d,link_id=%d,"
+			"Corr=%d,RC=%d,Host appl=%.8s, WS appl=%.8s\n",
+			dev->name,
+			p_ctlbk->version,
+			p_ctlbk->linkid,
+			p_ctlbk->correlator,
+			p_ctlbk->rc,
+			p_connect->host_name,
+			p_connect->WS_name);
+
+		if (p_ctlbk->rc != 0) {
+			printk(KERN_INFO "%s: Conn Resp error: rc=%d \n",
+				dev->name, p_ctlbk->rc);
+			return 1;
+		}
+		rc = find_link(dev,
+			p_connect->host_name, p_connect->WS_name);
+		if (rc != 0) {
+			claw_snd_disc(dev, p_ctlbk);
+			printk(KERN_INFO "%s: Conn Resp error: "
+				"req appl name does not match\n",
+				 dev->name);
+		}
+		/* should be until CONNECTION_CONFIRM */
+		privptr->active_link_ID = -(p_ctlbk->linkid);
+		break;
+	case CONNECTION_CONFIRM:
+		p_connect = (struct conncmd *)&(p_ctlbk->data);
+		printk(KERN_INFO "%s: Recv Conn Confirm:Vers=%d,link_id=%d,"
+			"Corr=%d,Host appl=%.8s,WS appl=%.8s\n",
+			dev->name,
+			p_ctlbk->version,
+			p_ctlbk->linkid,
+			p_ctlbk->correlator,
+			p_connect->host_name,
+			p_connect->WS_name);
+		if (p_ctlbk->linkid == -(privptr->active_link_ID)) {
+			privptr->active_link_ID = p_ctlbk->linkid;
+			if (p_env->packing > PACKING_ASK) {
+				printk(KERN_INFO "%s: Confirmed Now packing\n",
 					dev->name);
-                        }
-                        rc=find_link(dev,
-				p_connect->host_name, p_connect->WS_name);
-                        if (rc!=0) {
-                                claw_snd_disc(dev, p_ctlbk);
-                                printk(KERN_INFO "%s: Conn Req error : "
-					"req appl name does not match\n",
-					 dev->name);
-                        }
-                        claw_send_control(dev,
-				CONNECTION_CONFIRM, p_ctlbk->linkid,
-				p_ctlbk->correlator,
-				0, p_connect->host_name,
-                                p_connect->WS_name);
-			if (p_env->packing == PACKING_ASK) {
-				printk("%s: Now Pack ask\n",dev->name);
-				p_env->packing = PACK_SEND;
-				claw_snd_conn_req(dev,0);
-			}
-                        printk(KERN_INFO "%s: CLAW device %.8s: Connection "
-				"completed link_id=%d.\n",
-				dev->name, temp_ws_name,
-                                p_ctlbk->linkid);
-                        privptr->active_link_ID=p_ctlbk->linkid;
-                        p_ch=&privptr->channel[WRITE];
-                        wake_up(&p_ch->wait);  /* wake up claw_open ( WRITE) */
-                        break;
-                case CONNECTION_RESPONSE:
-                        p_connect=(struct conncmd *)&(p_ctlbk->data);
-                        printk(KERN_INFO "%s: Revc Conn Resp: Vers=%d,link_id=%d,"
-				"Corr=%d,RC=%d,Host appl=%.8s, WS appl=%.8s\n",
-                                dev->name,
-				p_ctlbk->version,
-				p_ctlbk->linkid,
-				p_ctlbk->correlator,
-				p_ctlbk->rc,
-				p_connect->host_name,
-                                p_connect->WS_name);
-
-                        if (p_ctlbk->rc !=0 ) {
-                                printk(KERN_INFO "%s: Conn Resp error: rc=%d \n",
-					dev->name, p_ctlbk->rc);
-                                return 1;
-                        }
-                        rc=find_link(dev,
-				p_connect->host_name, p_connect->WS_name);
-                        if (rc!=0) {
-                                claw_snd_disc(dev, p_ctlbk);
-                                printk(KERN_INFO "%s: Conn Resp error: "
-					"req appl name does not match\n",
-					 dev->name);
-                        }
-			/* should be until CONNECTION_CONFIRM */
-                        privptr->active_link_ID =  - (p_ctlbk->linkid);
-                        break;
-                case CONNECTION_CONFIRM:
-                        p_connect=(struct conncmd *)&(p_ctlbk->data);
-                        printk(KERN_INFO "%s: Recv Conn Confirm:Vers=%d,link_id=%d,"
-				"Corr=%d,Host appl=%.8s,WS appl=%.8s\n",
-                        dev->name,
-                        p_ctlbk->version,
-                        p_ctlbk->linkid,
-                        p_ctlbk->correlator,
-                        p_connect->host_name,
-                        p_connect->WS_name);
-                        if (p_ctlbk->linkid== -(privptr->active_link_ID)) {
-                                privptr->active_link_ID=p_ctlbk->linkid;
-				if (p_env->packing > PACKING_ASK) {
-					printk(KERN_INFO "%s: Confirmed Now packing\n",dev->name);
-					p_env->packing = DO_PACKED;
-					}
-				p_ch=&privptr->channel[WRITE];
-                                wake_up(&p_ch->wait);
-                        }
-                        else {
-                                printk(KERN_INFO "%s: Conn confirm: "
-					"unexpected linkid=%d \n",
-					dev->name, p_ctlbk->linkid);
-                                claw_snd_disc(dev, p_ctlbk);
-                        }
-                        break;
-                case DISCONNECT:
-                        printk(KERN_INFO "%s: Disconnect: "
-				"Vers=%d,link_id=%d,Corr=%d\n",
-				dev->name, p_ctlbk->version,
-                                p_ctlbk->linkid, p_ctlbk->correlator);
-			if ((p_ctlbk->linkid == 2) &&
-			    (p_env->packing == PACK_SEND)) {
-				privptr->active_link_ID = 1;
 				p_env->packing = DO_PACKED;
 			}
-			else
-	                        privptr->active_link_ID=0;
-                        break;
-                case CLAW_ERROR:
-                        printk(KERN_INFO "%s: CLAW ERROR detected\n",
-				dev->name);
-                        break;
-                default:
-                        printk(KERN_INFO "%s:  Unexpected command code=%d \n",
-				dev->name,  p_ctlbk->command);
-                        break;
+			p_ch = &privptr->channel[WRITE];
+			wake_up(&p_ch->wait);
+		} else {
+		       printk(KERN_INFO "%s: Conn confirm: "
+				"unexpected linkid=%d \n",
+				dev->name, p_ctlbk->linkid);
+			claw_snd_disc(dev, p_ctlbk);
+		}
+		break;
+	case DISCONNECT:
+		printk(KERN_INFO "%s: Disconnect: "
+			"Vers=%d,link_id=%d,Corr=%d\n",
+			dev->name, p_ctlbk->version,
+			p_ctlbk->linkid, p_ctlbk->correlator);
+		if ((p_ctlbk->linkid == 2) &&
+		    (p_env->packing == PACK_SEND)) {
+			privptr->active_link_ID = 1;
+			p_env->packing = DO_PACKED;
+		} else
+			privptr->active_link_ID = 0;
+		break;
+	case CLAW_ERROR:
+		printk(KERN_INFO "%s: CLAW ERROR detected\n",
+			dev->name);
+		break;
+	default:
+		printk(KERN_INFO "%s:  Unexpected command code=%d \n",
+			dev->name,  p_ctlbk->command);
+		break;
         }
 
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s() exit on line %d, rc = 0\n",
-		dev->name,__func__,__LINE__);
-#endif
-
         return 0;
 }   /*    end of claw_process_control    */
 
@@ -3092,18 +2277,7 @@ claw_send_control(struct net_device *dev
         struct conncmd                  *p_connect;
         struct sk_buff 			*skb;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s > enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"sndcntl");
-#ifdef DEBUGMSG
-	printk(KERN_INFO "%s: Sending Control Packet \n",dev->name);
-        printk(KERN_INFO "%s: variable type = 0x%X, link = "
-		"%d, correlator = %d, rc = %d\n",
-                dev->name,type, link, correlator, rc);
-        printk(KERN_INFO "%s: variable local_name = %s, "
-		"remote_name = %s\n",dev->name, local_name, remote_name);
-#endif
+	CLAW_DBF_TEXT(2, setup, "sndcntl");
         privptr=dev->priv;
         p_ctl=(struct clawctl *)&privptr->ctl_bk;
 
@@ -3125,7 +2299,7 @@ claw_send_control(struct net_device *dev
                         	p_sysval->read_frame_size=DEF_PACK_BUFSIZE;
 	                        p_sysval->write_frame_size=DEF_PACK_BUFSIZE;
 			} else {
-				/* how big is the piggest group of packets */
+				/* how big is the biggest group of packets */
 				p_sysval->read_frame_size=privptr->p_env->read_size;
 	                        p_sysval->write_frame_size=privptr->p_env->write_size;
 			}
@@ -3155,29 +2329,14 @@ claw_send_control(struct net_device *dev
 
         skb = dev_alloc_skb(sizeof(struct clawctl));
         if (!skb) {
-                printk(  "%s:%s low on mem, returning...\n",
-			dev->name,__func__);
-#ifdef DEBUG
-                printk(KERN_INFO "%s:%s Exit, rc = ENOMEM\n",
-			dev->name,__func__);
-#endif
                 return -ENOMEM;
         }
 	memcpy(skb_put(skb, sizeof(struct clawctl)),
 		p_ctl, sizeof(struct clawctl));
-#ifdef IOTRACE
-	 printk(KERN_INFO "%s: outbnd claw cntl data \n",dev->name);
-        dumpit((char *)p_ctl,sizeof(struct clawctl));
-#endif
 	if (privptr->p_env->packing >= PACK_SEND)
 		claw_hw_tx(skb, dev, 1);
 	else
         	claw_hw_tx(skb, dev, 0);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-
         return 0;
 }  /*   end of claw_send_control  */
 
@@ -3192,22 +2351,11 @@ claw_snd_conn_req(struct net_device *dev
         struct claw_privbk *privptr=dev->priv;
         struct clawctl 	   *p_ctl;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"snd_conn");
-#ifdef  DEBUGMSG
-        printk(KERN_INFO "%s: variable link = %X, dev =\n",dev->name, link);
-        dumpit((char *) dev, sizeof(struct net_device));
-#endif
+	CLAW_DBF_TEXT(2, setup, "snd_conn");
 	rc = 1;
         p_ctl=(struct clawctl *)&privptr->ctl_bk;
 	p_ctl->linkid = link;
         if ( privptr->system_validate_comp==0x00 ) {
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s:%s Exit on line %d, rc = 1\n",
-			dev->name,__func__,__LINE__);
-#endif
                 return rc;
         }
 	if (privptr->p_env->packing == PACKING_ASK )
@@ -3220,10 +2368,6 @@ claw_snd_conn_req(struct net_device *dev
 	if (privptr->p_env->packing == 0)
         	rc=claw_send_control(dev, CONNECTION_REQUEST,0,0,0,
        			HOST_APPL_NAME, privptr->p_env->api_type);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d, rc = %d\n",
-		dev->name,__func__,__LINE__, rc);
-#endif
         return rc;
 
 }  /*  end of claw_snd_conn_req */
@@ -3240,25 +2384,12 @@ claw_snd_disc(struct net_device *dev, st
         int rc;
         struct conncmd *  p_connect;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"snd_dsc");
-#ifdef  DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable p_ctl",dev->name);
-        dumpit((char *) p_ctl, sizeof(struct clawctl));
-#endif
+	CLAW_DBF_TEXT(2, setup, "snd_dsc");
         p_connect=(struct conncmd *)&p_ctl->data;
 
         rc=claw_send_control(dev, DISCONNECT, p_ctl->linkid,
 		p_ctl->correlator, 0,
                 p_connect->host_name, p_connect->WS_name);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d, rc = %d\n",
-		dev->name,__func__, __LINE__, rc);
-#endif
         return rc;
 }     /*   end of claw_snd_disc    */
 
@@ -3276,18 +2407,7 @@ claw_snd_sys_validate_rsp(struct net_dev
         struct claw_privbk *privptr;
         int    rc;
 
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Enter\n",
-		dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"chkresp");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable return_code = %d, dev =\n",
-		dev->name, return_code);
-        dumpit((char *) dev, sizeof(struct net_device));
-        printk(KERN_INFO "%s: variable p_ctl =\n",dev->name);
-        dumpit((char *) p_ctl, sizeof(struct clawctl));
-#endif
+	CLAW_DBF_TEXT(2, setup, "chkresp");
         privptr = dev->priv;
         p_env=privptr->p_env;
         rc=claw_send_control(dev, SYSTEM_VALIDATE_RESPONSE,
@@ -3296,10 +2416,6 @@ claw_snd_sys_validate_rsp(struct net_dev
                 return_code,
 		p_env->host_name,
 		p_env->adapter_name  );
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d, rc = %d\n",
-		dev->name,__func__,__LINE__, rc);
-#endif
         return rc;
 }     /*    end of claw_snd_sys_validate_rsp    */
 
@@ -3313,19 +2429,8 @@ claw_strt_conn_req(struct net_device *de
 {
         int rc;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"conn_req");
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s: variable dev =\n",dev->name);
-        dumpit((char *) dev, sizeof(struct net_device));
-#endif
+	CLAW_DBF_TEXT(2, setup, "conn_req");
         rc=claw_snd_conn_req(dev, 1);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d, rc = %d\n",
-		dev->name,__func__,__LINE__, rc);
-#endif
         return rc;
 }    /*   end of claw_strt_conn_req   */
 
@@ -3339,15 +2444,9 @@ static struct
 net_device_stats *claw_stats(struct net_device *dev)
 {
         struct claw_privbk *privptr;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"stats");
+
+	CLAW_DBF_TEXT(4, trace, "stats");
         privptr = dev->priv;
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
         return &privptr->stats;
 }     /*   end of claw_stats   */
 
@@ -3368,36 +2467,28 @@ unpack_read(struct net_device *dev )
 	struct clawph 	*p_packh;
 	void		*p_packd;
 	struct clawctl 	*p_ctlrec=NULL;
+	struct device	*p_dev;
 
         __u32	len_of_data;
 	__u32	pack_off;
         __u8	link_num;
         __u8 	mtc_this_frm=0;
         __u32	bytes_to_mov;
-        struct chbk *p_ch = NULL;
         int	i=0;
 	int     p=0;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s enter  \n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"unpkread");
+	CLAW_DBF_TEXT(4, trace, "unpkread");
         p_first_ccw=NULL;
         p_last_ccw=NULL;
 	p_packh=NULL;
 	p_packd=NULL;
         privptr=dev->priv;
+
+	p_dev = &privptr->channel[READ].cdev->dev;
 	p_env = privptr->p_env;
         p_this_ccw=privptr->p_read_active_first;
         i=0;
 	while (p_this_ccw!=NULL && p_this_ccw->header.flag!=CLAW_PENDING) {
-#ifdef IOTRACE
-		printk(KERN_INFO "%s p_this_ccw \n",dev->name);
-                dumpit((char*)p_this_ccw, sizeof(struct ccwbk));
-                printk(KERN_INFO "%s Inbound p_this_ccw->p_buffer(64)"
-			" pk=%d \n",dev->name,p_env->packing);
-                dumpit((char *)p_this_ccw->p_buffer, 64 );
-#endif
 		pack_off = 0;
 		p = 0;
 		p_this_ccw->header.flag=CLAW_PENDING;
@@ -3419,10 +2510,6 @@ unpack_read(struct net_device *dev )
 		else
 	                link_num=p_this_ccw->header.opcode / 8;
                 if ((p_this_ccw->header.opcode & MORE_to_COME_FLAG)!=0) {
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: %s > More_to_come is ON\n",
-			dev->name,__func__);
-#endif
                         mtc_this_frm=1;
                         if (p_this_ccw->header.length!=
 				privptr->p_env->read_size ) {
@@ -3445,22 +2532,12 @@ unpack_read(struct net_device *dev )
                                 privptr->mtc_skipping=0; /* Ok, the end */
                                 privptr->mtc_logical_link=-1;
                         }
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s:%s goto next "
-				"frame from MoretoComeSkip \n",
-				dev->name,__func__);
-#endif
                         goto NextFrame;
                 }
 
                 if (link_num==0) {
                         claw_process_control(dev, p_this_ccw);
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s:%s goto next "
-				"frame from claw_process_control \n",
-				dev->name,__func__);
-#endif
-			CLAW_DBF_TEXT(4,trace,"UnpkCntl");
+			CLAW_DBF_TEXT(4, trace, "UnpkCntl");
                         goto NextFrame;
                 }
 unpack_next:
@@ -3479,10 +2556,6 @@ unpack_next:
                 	bytes_to_mov=p_this_ccw->header.length;
 		}
                 if (privptr->mtc_logical_link<0) {
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: %s mtc_logical_link < 0  \n",
-			dev->name,__func__);
-#endif
 
                 /*
                 *  if More-To-Come is set in this frame then we don't know
@@ -3496,15 +2569,6 @@ unpack_next:
 
                 if (bytes_to_mov > (MAX_ENVELOPE_SIZE- privptr->mtc_offset) ) {
                         /*      error     */
-#ifdef DEBUGMSG
-                        printk(KERN_INFO "%s: %s > goto next "
-				"frame from MoretoComeSkip \n",
-				dev->name,
-				__func__);
-                        printk(KERN_INFO "      bytes_to_mov %d > (MAX_ENVELOPE_"
-				"SIZE-privptr->mtc_offset %d)\n",
-				bytes_to_mov,(MAX_ENVELOPE_SIZE- privptr->mtc_offset));
-#endif
                         privptr->stats.rx_frame_errors++;
                         goto NextFrame;
                 }
@@ -3516,16 +2580,6 @@ unpack_next:
                 	memcpy( privptr->p_mtc_envelope+ privptr->mtc_offset,
                         	p_this_ccw->p_buffer, bytes_to_mov);
 		}
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: %s() received data \n",
-			dev->name,__func__);
-		if (p_env->packing == DO_PACKED)
-			dumpit((char *)p_packd+sizeof(struct clawph),32);
-		else
-	                dumpit((char *)p_this_ccw->p_buffer, 32);
-		printk(KERN_INFO "%s: %s() bytelength %d \n",
-			dev->name,__func__,bytes_to_mov);
-#endif
                 if (mtc_this_frm==0) {
                         len_of_data=privptr->mtc_offset+bytes_to_mov;
                         skb=dev_alloc_skb(len_of_data);
@@ -3540,11 +2594,6 @@ unpack_next:
                                 privptr->stats.rx_packets++;
 				privptr->stats.rx_bytes+=len_of_data;
                                 netif_rx(skb);
-#ifdef DEBUGMSG
-                                printk(KERN_INFO "%s: %s() netif_"
-					"rx(skb) completed \n",
-					dev->name,__func__);
-#endif
                         }
                         else {
                                 privptr->stats.rx_dropped++;
@@ -3581,28 +2630,14 @@ NextFrame:
                 *       chain to next block on active read queue
                 */
                 p_this_ccw = privptr->p_read_active_first;
-		CLAW_DBF_TEXT_(4,trace,"rxpkt %d",p);
+		CLAW_DBF_TEXT_(4, trace, "rxpkt %d", p);
         } /* end of while */
 
         /*      check validity                  */
 
-#ifdef IOTRACE
-        printk(KERN_INFO "%s:%s processed frame is %d \n",
-		dev->name,__func__,i);
-        printk(KERN_INFO "%s:%s  F:%lx L:%lx\n",
-		dev->name,
-		__func__,
-		(unsigned long)p_first_ccw,
-		(unsigned long)p_last_ccw);
-#endif
-	CLAW_DBF_TEXT_(4,trace,"rxfrm %d",i);
+	CLAW_DBF_TEXT_(4, trace, "rxfrm %d", i);
         add_claw_reads(dev, p_first_ccw, p_last_ccw);
-        p_ch=&privptr->channel[READ];
         claw_strt_read(dev, LOCK_YES);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s: %s exit on line %d\n",
-		dev->name, __func__, __LINE__);
-#endif
         return;
 }     /*  end of unpack_read   */
 
@@ -3622,12 +2657,7 @@ claw_strt_read (struct net_device *dev, 
         struct clawh *p_clawh;
         p_ch=&privptr->channel[READ];
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter  \n",dev->name,__func__);
-        printk(KERN_INFO "%s: variable lock = %d, dev =\n",dev->name, lock);
-        dumpit((char *) dev, sizeof(struct net_device));
-#endif
-	CLAW_DBF_TEXT(4,trace,"StRdNter");
+	CLAW_DBF_TEXT(4, trace, "StRdNter");
         p_clawh=(struct clawh *)privptr->p_claw_signal_blk;
         p_clawh->flag=CLAW_IDLE;    /* 0x00 */
 
@@ -3637,21 +2667,11 @@ claw_strt_read (struct net_device *dev, 
              privptr->p_read_active_first->header.flag!=CLAW_PENDING )) {
                 p_clawh->flag=CLAW_BUSY;    /* 0xff */
         }
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s:%s state-%02x\n" ,
-		dev->name,__func__, p_ch->claw_state);
-#endif
         if (lock==LOCK_YES) {
                 spin_lock_irqsave(get_ccwdev_lock(p_ch->cdev), saveflags);
         }
         if (test_and_set_bit(0, (void *)&p_ch->IO_active) == 0) {
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s: HOT READ started in %s\n" ,
-			dev->name,__func__);
-                p_clawh=(struct clawh *)privptr->p_claw_signal_blk;
-                dumpit((char *)&p_clawh->flag , 1);
-#endif
-		CLAW_DBF_TEXT(4,trace,"HotRead");
+		CLAW_DBF_TEXT(4, trace, "HotRead");
                 p_ccwbk=privptr->p_read_active_first;
                 parm = (unsigned long) p_ch;
                 rc = ccw_device_start (p_ch->cdev, &p_ccwbk->read, parm,
@@ -3661,21 +2681,13 @@ claw_strt_read (struct net_device *dev, 
                 }
         }
 	else {
-#ifdef DEBUGMSG
-		printk(KERN_INFO "%s: No READ started by %s() In progress\n" ,
-			dev->name,__func__);
-#endif
-		CLAW_DBF_TEXT(2,trace,"ReadAct");
+		CLAW_DBF_TEXT(2, trace, "ReadAct");
 	}
 
         if (lock==LOCK_YES) {
                 spin_unlock_irqrestore(get_ccwdev_lock(p_ch->cdev), saveflags);
         }
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-	CLAW_DBF_TEXT(4,trace,"StRdExit");
+	CLAW_DBF_TEXT(4, trace, "StRdExit");
         return;
 }       /*    end of claw_strt_read    */
 
@@ -3693,38 +2705,23 @@ claw_strt_out_IO( struct net_device *dev
         struct chbk     	*p_ch;
         struct ccwbk   	*p_first_ccw;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
 	if (!dev) {
 		return;
 	}
         privptr=(struct claw_privbk *)dev->priv;
         p_ch=&privptr->channel[WRITE];
 
-#ifdef DEBUGMSG
-        printk(KERN_INFO "%s:%s state-%02x\n" ,
-		dev->name,__func__,p_ch->claw_state);
-#endif
-        CLAW_DBF_TEXT(4,trace,"strt_io");
+	CLAW_DBF_TEXT(4, trace, "strt_io");
         p_first_ccw=privptr->p_write_active_first;
 
         if (p_ch->claw_state == CLAW_STOP)
                 return;
         if (p_first_ccw == NULL) {
-#ifdef FUNCTRACE
-                printk(KERN_INFO "%s:%s Exit on line %d\n",
-			dev->name,__func__,__LINE__);
-#endif
                 return;
         }
         if (test_and_set_bit(0, (void *)&p_ch->IO_active) == 0) {
                 parm = (unsigned long) p_ch;
-#ifdef DEBUGMSG
-		printk(KERN_INFO "%s:%s do_io \n" ,dev->name,__func__);
-                dumpit((char *)p_first_ccw, sizeof(struct ccwbk));
-#endif
-		CLAW_DBF_TEXT(2,trace,"StWrtIO");
+		CLAW_DBF_TEXT(2, trace, "StWrtIO");
                 rc = ccw_device_start (p_ch->cdev,&p_first_ccw->write, parm,
 				       0xff, 0);
                 if (rc != 0) {
@@ -3732,11 +2729,6 @@ claw_strt_out_IO( struct net_device *dev
                 }
         }
         dev->trans_start = jiffies;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit on line %d\n",
-		dev->name,__func__,__LINE__);
-#endif
-
         return;
 }       /*    end of claw_strt_out_IO    */
 
@@ -3754,32 +2746,11 @@ claw_free_wrt_buf( struct net_device *de
 	struct ccwbk*p_last_ccw;
 	struct ccwbk*p_this_ccw;
 	struct ccwbk*p_next_ccw;
-#ifdef IOTRACE
-        struct ccwbk*p_buf;
-#endif
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-        printk(KERN_INFO "%s: free count = %d  variable dev =\n",
-		dev->name,privptr->write_free_count);
-#endif
-	CLAW_DBF_TEXT(4,trace,"freewrtb");
+
+	CLAW_DBF_TEXT(4, trace, "freewrtb");
         /*  scan the write queue to free any completed write packets   */
         p_first_ccw=NULL;
         p_last_ccw=NULL;
-#ifdef IOTRACE
-        printk(KERN_INFO "%s:  Dump current CCW chain \n",dev->name  );
-        p_buf=privptr->p_write_active_first;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-        if (p_buf==NULL) {
-                printk(KERN_INFO "%s: privptr->p_write_"
-			"active_first==NULL\n",dev->name  );
-        }
-        p_buf=(struct ccwbk*)privptr->p_end_ccw;
-        dumpit((char *)p_buf, sizeof(struct endccw));
-#endif
         p_this_ccw=privptr->p_write_active_first;
         while ( (p_this_ccw!=NULL) && (p_this_ccw->header.flag!=CLAW_PENDING))
         {
@@ -3809,31 +2780,8 @@ claw_free_wrt_buf( struct net_device *de
         /*   whole chain removed?   */
         if (privptr->p_write_active_first==NULL) {
                 privptr->p_write_active_last=NULL;
-#ifdef DEBUGMSG
-                printk(KERN_INFO "%s:%s p_write_"
-			"active_first==NULL\n",dev->name,__func__);
-#endif
-        }
-#ifdef IOTRACE
-        printk(KERN_INFO "%s: Dump arranged CCW chain \n",dev->name  );
-        p_buf=privptr->p_write_active_first;
-        while (p_buf!=NULL) {
-                dumpit((char *)p_buf, sizeof(struct ccwbk));
-                p_buf=p_buf->next;
-        }
-        if (p_buf==NULL) {
-                printk(KERN_INFO "%s: privptr->p_write_active_"
-			"first==NULL\n",dev->name  );
         }
-        p_buf=(struct ccwbk*)privptr->p_end_ccw;
-        dumpit((char *)p_buf, sizeof(struct endccw));
-#endif
-
-	CLAW_DBF_TEXT_(4,trace,"FWC=%d",privptr->write_free_count);
-#ifdef FUNCTRACE
-        printk(KERN_INFO "%s:%s Exit on line %d free_count =%d\n",
-		dev->name,__func__, __LINE__,privptr->write_free_count);
-#endif
+	CLAW_DBF_TEXT_(4, trace, "FWC=%d", privptr->write_free_count);
         return;
 }
 
@@ -3845,14 +2793,11 @@ static void
 claw_free_netdevice(struct net_device * dev, int free_dev)
 {
 	struct claw_privbk *privptr;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"free_dev");
 
+	CLAW_DBF_TEXT(2, setup, "free_dev");
 	if (!dev)
 		return;
-	CLAW_DBF_TEXT_(2,setup,"%s",dev->name);
+	CLAW_DBF_TEXT_(2, setup, "%s", dev->name);
 	privptr = dev->priv;
 	if (dev->flags & IFF_RUNNING)
 		claw_release(dev);
@@ -3865,10 +2810,7 @@ claw_free_netdevice(struct net_device * 
 		free_netdev(dev);
 	}
 #endif
-	CLAW_DBF_TEXT(2,setup,"feee_ok");
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit\n",dev->name,__func__);
-#endif
+	CLAW_DBF_TEXT(2, setup, "free_ok");
 }
 
 /**
@@ -3879,17 +2821,8 @@ claw_free_netdevice(struct net_device * 
 static void
 claw_init_netdevice(struct net_device * dev)
 {
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"init_dev");
-	CLAW_DBF_TEXT_(2,setup,"%s",dev->name);
-	if (!dev) {
-        printk(KERN_WARNING "claw:%s BAD Device exit line %d\n",
-		__func__,__LINE__);
-		CLAW_DBF_TEXT(2,setup,"baddev");
-		return;
-	}
+	CLAW_DBF_TEXT(2, setup, "init_dev");
+	CLAW_DBF_TEXT_(2, setup, "%s", dev->name);
 	dev->mtu = CLAW_DEFAULT_MTU_SIZE;
 	dev->hard_start_xmit = claw_tx;
 	dev->open = claw_open;
@@ -3901,10 +2834,7 @@ claw_init_netdevice(struct net_device * 
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 1300;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Exit\n",dev->name,__func__);
-#endif
-	CLAW_DBF_TEXT(2,setup,"initok");
+	CLAW_DBF_TEXT(2, setup, "initok");
 	return;
 }
 
@@ -3921,10 +2851,7 @@ add_channel(struct ccw_device *cdev,int 
 	struct chbk *p_ch;
 	struct ccw_dev_id dev_id;
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "%s:%s Enter\n",cdev->dev.bus_id,__func__);
-#endif
-	CLAW_DBF_TEXT_(2,setup,"%s",cdev->dev.bus_id);
+	CLAW_DBF_TEXT_(2, setup, "%s", cdev->dev.bus_id);
 	privptr->channel[i].flag  = i+1;   /* Read is 1 Write is 2 */
 	p_ch = &privptr->channel[i];
 	p_ch->cdev = cdev;
@@ -3932,18 +2859,8 @@ add_channel(struct ccw_device *cdev,int 
 	ccw_device_get_id(cdev, &dev_id);
 	p_ch->devno = dev_id.devno;
 	if ((p_ch->irb = kzalloc(sizeof (struct irb),GFP_KERNEL)) == NULL) {
-		printk(KERN_WARNING "%s Out of memory in %s for irb\n",
-			p_ch->id,__func__);
-#ifdef FUNCTRACE
-        	printk(KERN_INFO "%s:%s Exit on line %d\n",
-			p_ch->id,__func__,__LINE__);
-#endif
 		return -ENOMEM;
 	}
-#ifdef FUNCTRACE
-        	printk(KERN_INFO "%s:%s Exit on line %d\n",
-			cdev->dev.bus_id,__func__,__LINE__);
-#endif
 	return 0;
 }
 
@@ -3965,9 +2882,8 @@ claw_new_device(struct ccwgroup_device *
 	int ret;
 	struct ccw_dev_id dev_id;
 
-	pr_debug("%s() called\n", __func__);
 	printk(KERN_INFO "claw: add for %s\n",cgdev->cdev[READ]->dev.bus_id);
-	CLAW_DBF_TEXT(2,setup,"new_dev");
+	CLAW_DBF_TEXT(2, setup, "new_dev");
 	privptr = cgdev->dev.driver_data;
 	cgdev->cdev[READ]->dev.driver_data = privptr;
 	cgdev->cdev[WRITE]->dev.driver_data = privptr;
@@ -3982,22 +2898,21 @@ claw_new_device(struct ccwgroup_device *
 	if (ret == 0)
 		ret = add_channel(cgdev->cdev[1],1,privptr);
 	if (ret != 0) {
-			printk(KERN_WARNING
-		 	"add channel failed "
-				"with ret = %d\n", ret);
-			goto out;
+		printk(KERN_WARNING
+			"add channel failed with ret = %d\n", ret);
+		goto out;
 	}
 	ret = ccw_device_set_online(cgdev->cdev[READ]);
 	if (ret != 0) {
 		printk(KERN_WARNING
-		 "claw: ccw_device_set_online %s READ failed "
+			"claw: ccw_device_set_online %s READ failed "
 			"with ret = %d\n",cgdev->cdev[READ]->dev.bus_id,ret);
 		goto out;
 	}
 	ret = ccw_device_set_online(cgdev->cdev[WRITE]);
 	if (ret != 0) {
 		printk(KERN_WARNING
-		 "claw: ccw_device_set_online %s WRITE failed "
+			"claw: ccw_device_set_online %s WRITE failed "
 			"with ret = %d\n",cgdev->cdev[WRITE]->dev.bus_id, ret);
 		goto out;
 	}
@@ -4014,18 +2929,16 @@ claw_new_device(struct ccwgroup_device *
         SET_NETDEV_DEV(dev, &cgdev->dev);
 	if (register_netdev(dev) != 0) {
 		claw_free_netdevice(dev, 1);
-		CLAW_DBF_TEXT(2,trace,"regfail");
+		CLAW_DBF_TEXT(2, trace, "regfail");
 		goto out;
 	}
 	dev->flags &=~IFF_RUNNING;
 	if (privptr->buffs_alloc == 0) {
 	        ret=init_ccw_bk(dev);
 		if (ret !=0) {
-			printk(KERN_WARNING
-			 "claw: init_ccw_bk failed with ret=%d\n", ret);
 			unregister_netdev(dev);
 			claw_free_netdevice(dev,1);
-			CLAW_DBF_TEXT(2,trace,"ccwmem");
+			CLAW_DBF_TEXT(2, trace, "ccwmem");
 			goto out;
 		}
 	}
@@ -4047,7 +2960,6 @@ claw_new_device(struct ccwgroup_device *
 out:
 	ccw_device_set_offline(cgdev->cdev[1]);
 	ccw_device_set_offline(cgdev->cdev[0]);
-
 	return -ENODEV;
 }
 
@@ -4056,8 +2968,7 @@ claw_purge_skb_queue(struct sk_buff_head
 {
         struct sk_buff *skb;
 
-        CLAW_DBF_TEXT(4,trace,"purgque");
-
+	CLAW_DBF_TEXT(4, trace, "purgque");
         while ((skb = skb_dequeue(q))) {
                 atomic_dec(&skb->users);
                 dev_kfree_skb_any(skb);
@@ -4078,8 +2989,7 @@ claw_shutdown_device(struct ccwgroup_dev
 	struct net_device *ndev;
 	int	ret;
 
-	pr_debug("%s() called\n", __func__);
-	CLAW_DBF_TEXT_(2,setup,"%s",cgdev->dev.bus_id);
+	CLAW_DBF_TEXT_(2, setup, "%s", cgdev->dev.bus_id);
 	priv = cgdev->dev.driver_data;
 	if (!priv)
 		return -ENODEV;
@@ -4108,13 +3018,10 @@ claw_remove_device(struct ccwgroup_devic
 {
 	struct claw_privbk *priv;
 
-	pr_debug("%s() called\n", __func__);
-	CLAW_DBF_TEXT_(2,setup,"%s",cgdev->dev.bus_id);
+	BUG_ON(!cgdev);
+	CLAW_DBF_TEXT_(2, setup, "%s", cgdev->dev.bus_id);
 	priv = cgdev->dev.driver_data;
-	if (!priv) {
-		printk(KERN_WARNING "claw: %s() no Priv exiting\n",__func__);
-		return;
-	}
+	BUG_ON(!priv);
 	printk(KERN_INFO "claw: %s() called %s will be removed.\n",
 			__func__,cgdev->cdev[0]->dev.bus_id);
 	if (cgdev->state == CCWGROUP_ONLINE)
@@ -4133,6 +3040,8 @@ claw_remove_device(struct ccwgroup_devic
 	cgdev->cdev[READ]->dev.driver_data = NULL;
 	cgdev->cdev[WRITE]->dev.driver_data = NULL;
 	put_device(&cgdev->dev);
+
+	return;
 }
 
 
@@ -4168,8 +3077,8 @@ claw_hname_write(struct device *dev, str
 	strncpy(p_env->host_name,buf, count);
 	p_env->host_name[count-1] = 0x20;  /* clear extra 0x0a */
 	p_env->host_name[MAX_NAME_LEN] = 0x00;
-	CLAW_DBF_TEXT(2,setup,"HstnSet");
-        CLAW_DBF_TEXT_(2,setup,"%s",p_env->host_name);
+	CLAW_DBF_TEXT(2, setup, "HstnSet");
+	CLAW_DBF_TEXT_(2, setup, "%s", p_env->host_name);
 
 	return count;
 }
@@ -4186,7 +3095,7 @@ claw_adname_show(struct device *dev, str
 	if (!priv)
 		return -ENODEV;
 	p_env = priv->p_env;
-	return sprintf(buf, "%s\n",p_env->adapter_name);
+	return sprintf(buf, "%s\n", p_env->adapter_name);
 }
 
 static ssize_t
@@ -4205,8 +3114,8 @@ claw_adname_write(struct device *dev, st
 	strncpy(p_env->adapter_name,buf, count);
 	p_env->adapter_name[count-1] = 0x20; /* clear extra 0x0a */
 	p_env->adapter_name[MAX_NAME_LEN] = 0x00;
-	CLAW_DBF_TEXT(2,setup,"AdnSet");
-	CLAW_DBF_TEXT_(2,setup,"%s",p_env->adapter_name);
+	CLAW_DBF_TEXT(2, setup, "AdnSet");
+	CLAW_DBF_TEXT_(2, setup, "%s", p_env->adapter_name);
 
 	return count;
 }
@@ -4247,15 +3156,15 @@ claw_apname_write(struct device *dev, st
 		p_env->read_size=DEF_PACK_BUFSIZE;
 		p_env->write_size=DEF_PACK_BUFSIZE;
 		p_env->packing=PACKING_ASK;
-		CLAW_DBF_TEXT(2,setup,"PACKING");
+		CLAW_DBF_TEXT(2, setup, "PACKING");
 	}
 	else {
 		p_env->packing=0;
 		p_env->read_size=CLAW_FRAME_SIZE;
 		p_env->write_size=CLAW_FRAME_SIZE;
-		CLAW_DBF_TEXT(2,setup,"ApiSet");
+		CLAW_DBF_TEXT(2, setup, "ApiSet");
 	}
-	CLAW_DBF_TEXT_(2,setup,"%s",p_env->api_type);
+	CLAW_DBF_TEXT_(2, setup, "%s", p_env->api_type);
 	return count;
 }
 
@@ -4295,8 +3204,8 @@ claw_wbuff_write(struct device *dev, str
 	if ((nnn > max ) || (nnn < 2))
 		return -EINVAL;
 	p_env->write_buffers = nnn;
-	CLAW_DBF_TEXT(2,setup,"Wbufset");
-        CLAW_DBF_TEXT_(2,setup,"WB=%d",p_env->write_buffers);
+	CLAW_DBF_TEXT(2, setup, "Wbufset");
+	CLAW_DBF_TEXT_(2, setup, "WB=%d", p_env->write_buffers);
 	return count;
 }
 
@@ -4336,8 +3245,8 @@ claw_rbuff_write(struct device *dev, str
 	if ((nnn > max ) || (nnn < 2))
 		return -EINVAL;
 	p_env->read_buffers = nnn;
-	CLAW_DBF_TEXT(2,setup,"Rbufset");
-	CLAW_DBF_TEXT_(2,setup,"RB=%d",p_env->read_buffers);
+	CLAW_DBF_TEXT(2, setup, "Rbufset");
+	CLAW_DBF_TEXT_(2, setup, "RB=%d", p_env->read_buffers);
 	return count;
 }
 
@@ -4359,16 +3268,14 @@ static struct attribute_group claw_attr_
 static int
 claw_add_files(struct device *dev)
 {
-	pr_debug("%s() called\n", __func__);
-	CLAW_DBF_TEXT(2,setup,"add_file");
+	CLAW_DBF_TEXT(2, setup, "add_file");
 	return sysfs_create_group(&dev->kobj, &claw_attr_group);
 }
 
 static void
 claw_remove_files(struct device *dev)
 {
-	pr_debug("%s() called\n", __func__);
-	CLAW_DBF_TEXT(2,setup,"rem_file");
+	CLAW_DBF_TEXT(2, setup, "rem_file");
 	sysfs_remove_group(&dev->kobj, &claw_attr_group);
 }
 
@@ -4397,35 +3304,27 @@ claw_init(void)
 	int ret = 0;
 	printk(KERN_INFO "claw: starting driver\n");
 
-#ifdef FUNCTRACE
-	printk(KERN_INFO "claw: %s() enter \n",__func__);
-#endif
 	ret = claw_register_debug_facility();
 	if (ret) {
 		printk(KERN_WARNING "claw: %s() debug_register failed %d\n",
 			__func__,ret);
 		return ret;
 	}
-	CLAW_DBF_TEXT(2,setup,"init_mod");
+	CLAW_DBF_TEXT(2, setup, "init_mod");
 	ret = register_cu3088_discipline(&claw_group_driver);
 	if (ret) {
+		CLAW_DBF_TEXT(2, setup, "init_bad");
 		claw_unregister_debug_facility();
 		printk(KERN_WARNING "claw; %s() cu3088 register failed %d\n",
 			__func__,ret);
 	}
-#ifdef FUNCTRACE
-	printk(KERN_INFO "claw: %s() exit \n",__func__);
-#endif
 	return ret;
 }
 
 module_init(claw_init);
 module_exit(claw_cleanup);
 
-
-
-/*--------------------------------------------------------------------*
-*    End of File                                                      *
-*---------------------------------------------------------------------*/
-
-
+MODULE_AUTHOR("Andy Richter <richtera@us.ibm.com>");
+MODULE_DESCRIPTION("Linux for System z CLAW Driver\n" \
+			"Copyright 2000,2008 IBM Corporation\n");
+MODULE_LICENSE("GPL");

-- 
