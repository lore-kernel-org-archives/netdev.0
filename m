From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 8/9] [PATCH] kmsg: convert claw printk messages to kmsg api.
Date: Tue, 24 Mar 2009 13:29:12 +0100
Message-ID: <20090324124336.351471000@linux.vnet.ibm.com>
References: <20090324122904.744942000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Andy Richter <richtera@us.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:43476 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758526AbZCXMnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 08:43:40 -0400
Content-Disposition: inline; filename=627-kmsg-claw.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Richter <richtera@us.ibm.com>

Signed-off-by: Andy Richter <richtera@us.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |  428 +++++++++++++++++++++++++-----------------------
 1 file changed, 231 insertions(+), 197 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/claw.c linux-2.6-patched/drivers/s390/net/claw.c
--- linux-2.6/drivers/s390/net/claw.c	2009-03-19 11:16:39.000000000 +0100
+++ linux-2.6-patched/drivers/s390/net/claw.c	2009-03-19 11:16:40.000000000 +0100
@@ -60,6 +60,9 @@
  *    1.25  Added Packing support
  *    1.5
  */
+
+#define KMSG_COMPONENT "claw"
+
 #include <asm/ccwdev.h>
 #include <asm/ccwgroup.h>
 #include <asm/debug.h>
@@ -94,7 +97,7 @@
    CLAW uses the s390dbf file system  see claw_trace and claw_setup
 */
 
-
+static char version[] __initdata = "CLAW driver";
 static char debug_buffer[255];
 /**
  * Debug Facility Stuff
@@ -206,20 +209,30 @@ static struct net_device_stats *claw_sta
 static int pages_to_order_of_mag(int num_of_pages);
 static struct sk_buff *claw_pack_skb(struct claw_privbk *privptr);
 /* sysfs Functions */
-static ssize_t claw_hname_show(struct device *dev, struct device_attribute *attr, char *buf);
-static ssize_t claw_hname_write(struct device *dev, struct device_attribute *attr,
+static ssize_t claw_hname_show(struct device *dev,
+	struct device_attribute *attr, char *buf);
+static ssize_t claw_hname_write(struct device *dev,
+	struct device_attribute *attr,
 	const char *buf, size_t count);
-static ssize_t claw_adname_show(struct device *dev, struct device_attribute *attr, char *buf);
-static ssize_t claw_adname_write(struct device *dev, struct device_attribute *attr,
+static ssize_t claw_adname_show(struct device *dev,
+	struct device_attribute *attr, char *buf);
+static ssize_t claw_adname_write(struct device *dev,
+	struct device_attribute *attr,
 	const char *buf, size_t count);
-static ssize_t claw_apname_show(struct device *dev, struct device_attribute *attr, char *buf);
-static ssize_t claw_apname_write(struct device *dev, struct device_attribute *attr,
+static ssize_t claw_apname_show(struct device *dev,
+	struct device_attribute *attr, char *buf);
+static ssize_t claw_apname_write(struct device *dev,
+	struct device_attribute *attr,
 	const char *buf, size_t count);
-static ssize_t claw_wbuff_show(struct device *dev, struct device_attribute *attr, char *buf);
-static ssize_t claw_wbuff_write(struct device *dev, struct device_attribute *attr,
+static ssize_t claw_wbuff_show(struct device *dev,
+	struct device_attribute *attr, char *buf);
+static ssize_t claw_wbuff_write(struct device *dev,
+	struct device_attribute *attr,
 	const char *buf, size_t count);
-static ssize_t claw_rbuff_show(struct device *dev, struct device_attribute *attr, char *buf);
-static ssize_t claw_rbuff_write(struct device *dev, struct device_attribute *attr,
+static ssize_t claw_rbuff_show(struct device *dev,
+	struct device_attribute *attr, char *buf);
+static ssize_t claw_rbuff_write(struct device *dev,
+	struct device_attribute *attr,
 	const char *buf, size_t count);
 static int claw_add_files(struct device *dev);
 static void claw_remove_files(struct device *dev);
@@ -298,8 +311,8 @@ claw_probe(struct ccwgroup_device *cgdev
 	if (rc) {
 		probe_error(cgdev);
 		put_device(&cgdev->dev);
-		printk(KERN_WARNING "add_files failed %s %s Exit Line %d \n",
-			dev_name(&cgdev->cdev[0]->dev), __func__, __LINE__);
+		dev_err(&cgdev->dev, "Creating the /proc files for a new"
+		" CLAW device failed\n");
 		CLAW_DBF_TEXT_(2, setup, "probex%d", rc);
 		return rc;
 	}
@@ -498,7 +511,8 @@ claw_open(struct net_device *dev)
            ~(DEV_STAT_CHN_END | DEV_STAT_DEV_END)) != 0x00) ||
            (((privptr->channel[READ].flag |
 	   	privptr->channel[WRITE].flag) & CLAW_TIMER) != 0x00)) {
-                printk(KERN_INFO "%s: remote side is not ready\n", dev->name);
+		dev_info(&privptr->channel[READ].cdev->dev,
+			"%s: remote side is not ready\n", dev->name);
 		CLAW_DBF_TEXT(2, trace, "notrdy");
 
                 for ( i = 0; i < 2;  i++) {
@@ -584,10 +598,9 @@ claw_irq_handler(struct ccw_device *cdev
 	CLAW_DBF_TEXT(4, trace, "clawirq");
         /* Bypass all 'unsolicited interrupts' */
 	if (!cdev->dev.driver_data) {
-                printk(KERN_WARNING "claw: unsolicited interrupt for device:"
-		 	"%s received c-%02x d-%02x\n",
-		       dev_name(&cdev->dev), irb->scsw.cmd.cstat,
-		       irb->scsw.cmd.dstat);
+		dev_warn(&cdev->dev, "An uninitialized CLAW device received an"
+			" IRQ, c-%02x d-%02x\n",
+			irb->scsw.cmd.cstat, irb->scsw.cmd.dstat);
 		CLAW_DBF_TEXT(2, trace, "badirq");
                 return;
         }
@@ -599,8 +612,7 @@ claw_irq_handler(struct ccw_device *cdev
 	else if (privptr->channel[WRITE].cdev == cdev)
 		p_ch = &privptr->channel[WRITE];
 	else {
-		printk(KERN_WARNING "claw: Can't determine channel for "
-			"interrupt, device %s\n", dev_name(&cdev->dev));
+		dev_warn(&cdev->dev, "The device is not a CLAW device\n");
 		CLAW_DBF_TEXT(2, trace, "badchan");
 		return;
 	}
@@ -614,7 +626,8 @@ claw_irq_handler(struct ccw_device *cdev
 
 	/* Check for good subchannel return code, otherwise info message */
 	if (irb->scsw.cmd.cstat && !(irb->scsw.cmd.cstat & SCHN_STAT_PCI)) {
-                printk(KERN_INFO "%s: subchannel check for device: %04x -"
+		dev_info(&cdev->dev,
+			"%s: subchannel check for device: %04x -"
 			" Sch Stat %02x  Dev Stat %02x CPA - %04x\n",
                         dev->name, p_ch->devno,
 			irb->scsw.cmd.cstat, irb->scsw.cmd.dstat,
@@ -661,10 +674,9 @@ claw_irq_handler(struct ccw_device *cdev
 				p_env->host_name,
 				p_env->adapter_name);
 		} else {
-			printk(KERN_WARNING "claw: unsolicited "
-				"interrupt for device:"
-				"%s received c-%02x d-%02x\n",
-				dev_name(&cdev->dev),
+			dev_warn(&cdev->dev, "The CLAW device received"
+				" an unexpected IRQ, "
+				"c-%02x d-%02x\n",
 				irb->scsw.cmd.cstat,
 				irb->scsw.cmd.dstat);
 			return;
@@ -679,8 +691,8 @@ claw_irq_handler(struct ccw_device *cdev
 			    (p_ch->irb->ecw[0] & 0x40) == 0x40 ||
 			    (p_ch->irb->ecw[0])        == 0) {
 				privptr->stats.rx_errors++;
-				printk(KERN_INFO "%s: Restart is "
-					"required after remote "
+				dev_info(&cdev->dev,
+					"%s: Restart is required after remote "
 					"side recovers \n",
 					dev->name);
 			}
@@ -715,11 +727,13 @@ claw_irq_handler(struct ccw_device *cdev
 		return;
 	case CLAW_START_WRITE:
 		if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
-			printk(KERN_INFO "%s: Unit Check Occured in "
+			dev_info(&cdev->dev,
+				"%s: Unit Check Occured in "
 				"write channel\n", dev->name);
 			clear_bit(0, (void *)&p_ch->IO_active);
 			if (p_ch->irb->ecw[0] & 0x80) {
-				printk(KERN_INFO "%s: Resetting Event "
+				dev_info(&cdev->dev,
+					"%s: Resetting Event "
 					"occurred:\n", dev->name);
 				init_timer(&p_ch->timer);
 				p_ch->timer.function =
@@ -727,7 +741,8 @@ claw_irq_handler(struct ccw_device *cdev
 				p_ch->timer.data = (unsigned long)p_ch;
 				p_ch->timer.expires = jiffies + 10*HZ;
 				add_timer(&p_ch->timer);
-				printk(KERN_INFO "%s: write connection "
+				dev_info(&cdev->dev,
+					"%s: write connection "
 					"restarting\n", dev->name);
 			}
 			CLAW_DBF_TEXT(4, trace, "rstrtwrt");
@@ -735,9 +750,10 @@ claw_irq_handler(struct ccw_device *cdev
 		}
 		if (p_ch->irb->scsw.cmd.dstat & DEV_STAT_UNIT_EXCEP) {
 			clear_bit(0, (void *)&p_ch->IO_active);
-			printk(KERN_INFO "%s: Unit Exception "
-			       "Occured in write channel\n",
-			       dev->name);
+			dev_info(&cdev->dev,
+				"%s: Unit Exception "
+				"occurred in write channel\n",
+				dev->name);
 		}
 		if (!((p_ch->irb->scsw.cmd.stctl & SCSW_STCTL_SEC_STATUS) ||
 		(p_ch->irb->scsw.cmd.stctl == SCSW_STCTL_STATUS_PEND) ||
@@ -759,8 +775,9 @@ claw_irq_handler(struct ccw_device *cdev
 		CLAW_DBF_TEXT(4, trace, "StWtExit");
 		return;
 	default:
-		printk(KERN_WARNING "%s: wrong selection code - irq "
-			"state=%d\n", dev->name, p_ch->claw_state);
+		dev_warn(&cdev->dev,
+			"The CLAW device for %s received an unexpected IRQ\n",
+			 dev->name, p_ch->claw_state);
 		CLAW_DBF_TEXT(2, trace, "badIRQ");
 		return;
         }
@@ -912,8 +929,10 @@ claw_release(struct net_device *dev)
         if (((privptr->channel[READ].last_dstat |
 		privptr->channel[WRITE].last_dstat) &
 		~(DEV_STAT_CHN_END | DEV_STAT_DEV_END)) != 0x00) {
-                printk(KERN_WARNING "%s: channel problems during close - "
-			"read: %02x -  write: %02x\n",
+		dev_warn(&privptr->channel[READ].cdev->dev,
+			"Deactivating %s completed with incorrect"
+			" subchannel status "
+			"(read %02x, write %02x)\n",
                 dev->name,
 		privptr->channel[READ].last_dstat,
 		privptr->channel[WRITE].last_dstat);
@@ -1078,8 +1097,8 @@ add_claw_reads(struct net_device *dev, s
         }
 
         if ( privptr-> p_read_active_first ==NULL ) {
-                privptr-> p_read_active_first= p_first;  /*    set new first */
-                privptr-> p_read_active_last = p_last;   /*    set new last  */
+		privptr-> p_read_active_first= p_first;  /*  set new first */
+		privptr-> p_read_active_last = p_last;	 /*  set new last  */
         }
         else {
 
@@ -1115,7 +1134,7 @@ add_claw_reads(struct net_device *dev, s
                         privptr->p_read_active_last->r_TIC_2.cda=
 				(__u32)__pa(&p_first->read);
                 }
-                /*      chain in new set of blocks                              */
+		/*	chain in new set of blocks			   */
                 privptr->p_read_active_last->next = p_first;
                 privptr->p_read_active_last=p_last;
         } /* end of if ( privptr-> p_read_active_first ==NULL)  */
@@ -1137,21 +1156,18 @@ ccw_check_return_code(struct ccw_device 
 		case -EBUSY: /* BUSY is a transient state no action needed */
 			break;
 		case -ENODEV:
-			printk(KERN_EMERG "%s: Missing device called "
-				"for IO ENODEV\n", dev_name(&cdev->dev));
-			break;
-		case -EIO:
-			printk(KERN_EMERG "%s: Status pending... EIO \n",
-				dev_name(&cdev->dev));
+			dev_err(&cdev->dev, "The remote channel adapter is not"
+				" available\n");
 			break;
 		case -EINVAL:
-			printk(KERN_EMERG "%s: Invalid Dev State EINVAL \n",
-				dev_name(&cdev->dev));
+			dev_err(&cdev->dev,
+				"The status of the remote channel adapter"
+				" is not valid\n");
 			break;
 		default:
-			printk(KERN_EMERG "%s: Unknown error in "
-				 "Do_IO %d\n", dev_name(&cdev->dev),
-			       return_code);
+			dev_err(&cdev->dev, "The common device layer"
+				" returned error code %d\n",
+				  return_code);
 		}
 	}
 	CLAW_DBF_TEXT(4, trace, "ccwret");
@@ -1165,40 +1181,41 @@ static void
 ccw_check_unit_check(struct chbk * p_ch, unsigned char sense )
 {
 	struct net_device *ndev = p_ch->ndev;
+	struct device *dev = &p_ch->cdev->dev;
 
 	CLAW_DBF_TEXT(4, trace, "unitchek");
-        printk(KERN_INFO "%s: Unit Check with sense byte:0x%04x\n",
-	       ndev->name, sense);
+	dev_warn(dev, "The communication peer of %s disconnected\n",
+		ndev->name);
 
         if (sense & 0x40) {
                 if (sense & 0x01) {
-                        printk(KERN_WARNING "%s: Interface disconnect or "
-				"Selective reset "
-				"occurred (remote side)\n", ndev->name);
-                }
-                else {
-                        printk(KERN_WARNING "%s: System reset occured"
-				" (remote side)\n", ndev->name);
+			dev_warn(dev, "The remote channel adapter for"
+				" %s has been reset\n",
+				ndev->name);
                 }
         }
         else if (sense & 0x20) {
                 if (sense & 0x04) {
-                        printk(KERN_WARNING "%s: Data-streaming "
-				"timeout)\n", ndev->name);
+			dev_warn(dev, "A data streaming timeout occurred"
+				" for %s\n",
+				ndev->name);
                 }
                 else  {
-                        printk(KERN_WARNING "%s: Data-transfer parity"
-				" error\n", ndev->name);
+			dev_warn(dev, "A data transfer parity error occurred"
+				" for %s\n",
+				ndev->name);
                 }
         }
         else if (sense & 0x10) {
                 if (sense & 0x20) {
-                        printk(KERN_WARNING "%s: Hardware malfunction "
-				"(remote side)\n", ndev->name);
+			dev_warn(dev, "The remote channel adapter for %s"
+				" is faulty\n",
+				ndev->name);
                 }
                 else {
-                        printk(KERN_WARNING "%s: read-data parity error "
-				"(remote side)\n", ndev->name);
+			dev_warn(dev, "A read data parity error occurred"
+				" for %s\n",
+				ndev->name);
                 }
         }
 
@@ -1303,7 +1320,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
                                 if (privptr->write_free_count==0) {
 					ch = &privptr->channel[WRITE];
 					atomic_inc(&skb->users);
-					skb_queue_tail(&ch->collect_queue, skb);
+					skb_queue_tail(&ch->collect_queue,skb);
                                 	goto Done;
                                 }
                                 else {
@@ -1377,7 +1394,7 @@ claw_hw_tx(struct sk_buff *skb, struct n
         */
 
         if (p_first_ccw!=NULL) {
-                /*      setup ending ccw sequence for this segment              */
+		/*	setup ending ccw sequence for this segment	     */
                 pEnd=privptr->p_end_ccw;
                 if (pEnd->write1) {
                         pEnd->write1=0x00;   /* second end ccw is now active */
@@ -1699,10 +1716,10 @@ init_ccw_bk(struct net_device *dev)
                         p_buf-> w_TIC_1.flags      = 0;
                         p_buf-> w_TIC_1.count      = 0;
 
-                        if (((unsigned long)p_buff+privptr->p_env->write_size) >=
+			if (((unsigned long)p_buff+privptr->p_env->write_size)>=
 			   ((unsigned long)(p_buff+2*
-				(privptr->p_env->write_size) -1) & PAGE_MASK)) {
-                        p_buff= p_buff+privptr->p_env->write_size;
+			    (privptr->p_env->write_size) -1) & PAGE_MASK)) {
+				p_buff= p_buff+privptr->p_env->write_size;
                         }
                 }
            }
@@ -1842,15 +1859,16 @@ init_ccw_bk(struct net_device *dev)
                         p_buf->header.opcode=0xff;
                         p_buf->header.flag=CLAW_PENDING;
 
-                        if (((unsigned long)p_buff+privptr->p_env->read_size) >=
-				((unsigned long)(p_buff+2*(privptr->p_env->read_size) -1)
-				 & PAGE_MASK) ) {
+			if (((unsigned long)p_buff+privptr->p_env->read_size)>=
+			  ((unsigned long)(p_buff+2*(privptr->p_env->read_size)
+				 -1)
+			   & PAGE_MASK) ) {
                                 p_buff= p_buff+privptr->p_env->read_size;
                         }
                         else {
                                 p_buff=
 				(void *)((unsigned long)
-					(p_buff+2*(privptr->p_env->read_size) -1)
+					(p_buff+2*(privptr->p_env->read_size)-1)
 					 & PAGE_MASK) ;
                         }
                 }   /* for read_buffers   */
@@ -1858,24 +1876,28 @@ init_ccw_bk(struct net_device *dev)
           else {  /* read Size >= PAGE_SIZE  */
                 for (i=0 ; i< privptr->p_env->read_buffers ; i++) {
                         p_buff = (void *)__get_free_pages(__GFP_DMA,
-				(int)pages_to_order_of_mag(privptr->p_buff_pages_perread) );
+				(int)pages_to_order_of_mag(
+					privptr->p_buff_pages_perread));
                         if (p_buff==NULL) {
                                 free_pages((unsigned long)privptr->p_buff_ccw,
-					(int)pages_to_order_of_mag(privptr->p_buff_ccw_num));
+					(int)pages_to_order_of_mag(privptr->
+					p_buff_ccw_num));
 				/* free the write pages  */
 	                        p_buf=privptr->p_buff_write;
                                 while (p_buf!=NULL) {
-                                        free_pages((unsigned long)p_buf->p_buffer,
-						(int)pages_to_order_of_mag(
-						privptr->p_buff_pages_perwrite ));
+					free_pages(
+					    (unsigned long)p_buf->p_buffer,
+					    (int)pages_to_order_of_mag(
+					    privptr->p_buff_pages_perwrite));
                                         p_buf=p_buf->next;
                                 }
 				/* free any read pages already alloc  */
 	                        p_buf=privptr->p_buff_read;
                                 while (p_buf!=NULL) {
-                                        free_pages((unsigned long)p_buf->p_buffer,
-						(int)pages_to_order_of_mag(
-						privptr->p_buff_pages_perread ));
+					free_pages(
+					    (unsigned long)p_buf->p_buffer,
+					    (int)pages_to_order_of_mag(
+					     privptr->p_buff_pages_perread ));
                                         p_buf=p_buf->next;
                                 }
                                 privptr->p_buff_ccw=NULL;
@@ -2005,7 +2027,7 @@ claw_process_control( struct net_device 
 	tdev = &privptr->channel[READ].cdev->dev;
 	memcpy( &temp_host_name, p_env->host_name, 8);
         memcpy( &temp_ws_name, p_env->adapter_name , 8);
-        printk(KERN_INFO "%s: CLAW device %.8s: "
+	dev_info(tdev, "%s: CLAW device %.8s: "
 		"Received Control Packet\n",
 		dev->name, temp_ws_name);
         if (privptr->release_pend==1) {
@@ -2024,32 +2046,31 @@ claw_process_control( struct net_device 
 		if (p_ctlbk->version != CLAW_VERSION_ID) {
 			claw_snd_sys_validate_rsp(dev, p_ctlbk,
 				CLAW_RC_WRONG_VERSION);
-			printk("%s: %d is wrong version id. "
-			       "Expected %d\n",
-			       dev->name, p_ctlbk->version,
-			       CLAW_VERSION_ID);
+			dev_warn(tdev, "The communication peer of %s"
+				" uses an incorrect API version %d\n",
+				dev->name, p_ctlbk->version,
+				CLAW_VERSION_ID);
 		}
 		p_sysval = (struct sysval *)&(p_ctlbk->data);
-		printk("%s: Recv Sys Validate Request: "
-		       "Vers=%d,link_id=%d,Corr=%d,WS name=%."
-		       "8s,Host name=%.8s\n",
-		       dev->name, p_ctlbk->version,
-		       p_ctlbk->linkid,
-		       p_ctlbk->correlator,
-		       p_sysval->WS_name,
-		       p_sysval->host_name);
+		dev_info(tdev, "%s: Recv Sys Validate Request: "
+			"Vers=%d,link_id=%d,Corr=%d,WS name=%.8s,"
+			"Host name=%.8s\n",
+			dev->name, p_ctlbk->version,
+			p_ctlbk->linkid,
+			p_ctlbk->correlator,
+			p_sysval->WS_name,
+			p_sysval->host_name);
 		if (memcmp(temp_host_name, p_sysval->host_name, 8)) {
 			claw_snd_sys_validate_rsp(dev, p_ctlbk,
 				CLAW_RC_NAME_MISMATCH);
 			CLAW_DBF_TEXT(2, setup, "HSTBAD");
 			CLAW_DBF_TEXT_(2, setup, "%s", p_sysval->host_name);
 			CLAW_DBF_TEXT_(2, setup, "%s", temp_host_name);
-			printk(KERN_INFO "%s:  Host name mismatch\n",
-				dev->name);
-			printk(KERN_INFO "%s: Received :%s: "
-				"expected :%s: \n",
-				dev->name,
+			dev_warn(tdev,
+				"Host name %s for %s does not match the"
+				" remote adapter name %s\n",
 				p_sysval->host_name,
+				dev->name,
 				temp_host_name);
 		}
 		if (memcmp(temp_ws_name, p_sysval->WS_name, 8)) {
@@ -2058,35 +2079,38 @@ claw_process_control( struct net_device 
 			CLAW_DBF_TEXT(2, setup, "WSNBAD");
 			CLAW_DBF_TEXT_(2, setup, "%s", p_sysval->WS_name);
 			CLAW_DBF_TEXT_(2, setup, "%s", temp_ws_name);
-			printk(KERN_INFO "%s: WS name mismatch\n",
-				dev->name);
-			printk(KERN_INFO "%s: Received :%s: "
-			       "expected :%s: \n",
-			       dev->name,
-			       p_sysval->WS_name,
-			       temp_ws_name);
+			dev_warn(tdev, "Adapter name %s for %s does not match"
+				" the remote host name %s\n",
+				p_sysval->WS_name,
+				dev->name,
+				temp_ws_name);
 		}
 		if ((p_sysval->write_frame_size < p_env->write_size) &&
 		    (p_env->packing == 0)) {
 			claw_snd_sys_validate_rsp(dev, p_ctlbk,
 				CLAW_RC_HOST_RCV_TOO_SMALL);
-			printk(KERN_INFO "%s: host write size is too "
-				"small\n", dev->name);
+			dev_warn(tdev,
+				"The local write buffer is smaller than the"
+				" remote read buffer\n");
 			CLAW_DBF_TEXT(2, setup, "wrtszbad");
 		}
 		if ((p_sysval->read_frame_size < p_env->read_size) &&
 		    (p_env->packing == 0)) {
 			claw_snd_sys_validate_rsp(dev, p_ctlbk,
 				CLAW_RC_HOST_RCV_TOO_SMALL);
-			printk(KERN_INFO "%s: host read size is too "
-				"small\n", dev->name);
+			dev_warn(tdev,
+				"The local read buffer is smaller than the"
+				" remote write buffer\n");
 			CLAW_DBF_TEXT(2, setup, "rdsizbad");
 		}
 		claw_snd_sys_validate_rsp(dev, p_ctlbk, 0);
-		printk(KERN_INFO "%s: CLAW device %.8s: System validate "
-			"completed.\n", dev->name, temp_ws_name);
-		printk("%s: sys Validate Rsize:%d Wsize:%d\n", dev->name,
-			p_sysval->read_frame_size, p_sysval->write_frame_size);
+		dev_info(tdev,
+			"CLAW device %.8s: System validate"
+			" completed.\n", temp_ws_name);
+		dev_info(tdev,
+			"%s: sys Validate Rsize:%d Wsize:%d\n",
+			dev->name, p_sysval->read_frame_size,
+			p_sysval->write_frame_size);
 		privptr->system_validate_comp = 1;
 		if (strncmp(p_env->api_type, WS_APPL_NAME_PACKED, 6) == 0)
 			p_env->packing = PACKING_ASK;
@@ -2094,9 +2118,10 @@ claw_process_control( struct net_device 
 		break;
 	case SYSTEM_VALIDATE_RESPONSE:
 		p_sysval = (struct sysval *)&(p_ctlbk->data);
-		printk("%s: Recv Sys Validate Resp: Vers=%d,Corr=%d,RC=%d,"
-			"WS name=%.8s,Host name=%.8s\n",
-			dev->name,
+		dev_info(tdev,
+			"Settings for %s validated (version=%d, "
+			"remote device=%d, rc=%d, adapter name=%.8s, "
+			"host name=%.8s)\n",
 			p_ctlbk->version,
 			p_ctlbk->correlator,
 			p_ctlbk->rc,
@@ -2104,41 +2129,39 @@ claw_process_control( struct net_device 
 			p_sysval->host_name);
 		switch (p_ctlbk->rc) {
 		case 0:
-			printk(KERN_INFO "%s: CLAW device "
-				"%.8s: System validate "
-				"completed.\n",
-			       dev->name, temp_ws_name);
+			dev_info(tdev, "%s: CLAW device "
+				"%.8s: System validate completed.\n",
+				dev->name, temp_ws_name);
 			if (privptr->system_validate_comp == 0)
 				claw_strt_conn_req(dev);
 			privptr->system_validate_comp = 1;
 			break;
 		case CLAW_RC_NAME_MISMATCH:
-			printk(KERN_INFO "%s: Sys Validate "
-				"Resp : Host, WS name is "
-				"mismatch\n",
-			       dev->name);
+			dev_warn(tdev, "Validating %s failed because of"
+				" a host or adapter name mismatch\n",
+				dev->name);
 			break;
 		case CLAW_RC_WRONG_VERSION:
-			printk(KERN_INFO "%s: Sys Validate "
-				"Resp : Wrong version\n",
+			dev_warn(tdev, "Validating %s failed because of a"
+				" version conflict\n",
 				dev->name);
 			break;
 		case CLAW_RC_HOST_RCV_TOO_SMALL:
-			printk(KERN_INFO "%s: Sys Validate "
-				"Resp : bad frame size\n",
+			dev_warn(tdev, "Validating %s failed because of a"
+				" frame size conflict\n",
 				dev->name);
 			break;
 		default:
-			printk(KERN_INFO "%s: Sys Validate "
-				"error code=%d \n",
-				 dev->name, p_ctlbk->rc);
+			dev_warn(tdev, "The communication peer of %s rejected"
+				" the connection\n",
+				 dev->name);
 			break;
 		}
 		break;
 
 	case CONNECTION_REQUEST:
 		p_connect = (struct conncmd *)&(p_ctlbk->data);
-		printk(KERN_INFO "%s: Recv Conn Req: Vers=%d,link_id=%d,"
+		dev_info(tdev, "%s: Recv Conn Req: Vers=%d,link_id=%d,"
 			"Corr=%d,HOST appl=%.8s,WS appl=%.8s\n",
 			dev->name,
 			p_ctlbk->version,
@@ -2148,21 +2171,21 @@ claw_process_control( struct net_device 
 			p_connect->WS_name);
 		if (privptr->active_link_ID != 0) {
 			claw_snd_disc(dev, p_ctlbk);
-			printk(KERN_INFO "%s: Conn Req error : "
-				"already logical link is active \n",
+			dev_info(tdev, "%s rejected a connection request"
+				" because it is already active\n",
 				dev->name);
 		}
 		if (p_ctlbk->linkid != 1) {
 			claw_snd_disc(dev, p_ctlbk);
-			printk(KERN_INFO "%s: Conn Req error : "
-				"req logical link id is not 1\n",
+			dev_info(tdev, "%s rejected a request to open multiple"
+				" connections\n",
 				dev->name);
 		}
 		rc = find_link(dev, p_connect->host_name, p_connect->WS_name);
 		if (rc != 0) {
 			claw_snd_disc(dev, p_ctlbk);
-			printk(KERN_INFO "%s: Conn Resp error: "
-				"req appl name does not match\n",
+			dev_info(tdev, "%s rejected a connection request"
+				" because of a type mismatch\n",
 				dev->name);
 		}
 		claw_send_control(dev,
@@ -2174,7 +2197,7 @@ claw_process_control( struct net_device 
 			p_env->packing = PACK_SEND;
 			claw_snd_conn_req(dev, 0);
 		}
-		printk(KERN_INFO "%s: CLAW device %.8s: Connection "
+		dev_info(tdev, "%s: CLAW device %.8s: Connection "
 			"completed link_id=%d.\n",
 			dev->name, temp_ws_name,
 			p_ctlbk->linkid);
@@ -2184,7 +2207,7 @@ claw_process_control( struct net_device 
 		break;
 	case CONNECTION_RESPONSE:
 		p_connect = (struct conncmd *)&(p_ctlbk->data);
-		printk(KERN_INFO "%s: Revc Conn Resp: Vers=%d,link_id=%d,"
+		dev_info(tdev, "%s: Recv Conn Resp: Vers=%d,link_id=%d,"
 			"Corr=%d,RC=%d,Host appl=%.8s, WS appl=%.8s\n",
 			dev->name,
 			p_ctlbk->version,
@@ -2195,16 +2218,18 @@ claw_process_control( struct net_device 
 			p_connect->WS_name);
 
 		if (p_ctlbk->rc != 0) {
-			printk(KERN_INFO "%s: Conn Resp error: rc=%d \n",
-				dev->name, p_ctlbk->rc);
+			dev_warn(tdev, "The communication peer of %s rejected"
+				" a connection request\n",
+				dev->name);
 			return 1;
 		}
 		rc = find_link(dev,
 			p_connect->host_name, p_connect->WS_name);
 		if (rc != 0) {
 			claw_snd_disc(dev, p_ctlbk);
-			printk(KERN_INFO "%s: Conn Resp error: "
-				"req appl name does not match\n",
+			dev_warn(tdev, "The communication peer of %s"
+				" rejected a connection "
+				"request because of a type mismatch\n",
 				 dev->name);
 		}
 		/* should be until CONNECTION_CONFIRM */
@@ -2212,7 +2237,8 @@ claw_process_control( struct net_device 
 		break;
 	case CONNECTION_CONFIRM:
 		p_connect = (struct conncmd *)&(p_ctlbk->data);
-		printk(KERN_INFO "%s: Recv Conn Confirm:Vers=%d,link_id=%d,"
+		dev_info(tdev,
+			"%s: Recv Conn Confirm:Vers=%d,link_id=%d,"
 			"Corr=%d,Host appl=%.8s,WS appl=%.8s\n",
 			dev->name,
 			p_ctlbk->version,
@@ -2223,21 +2249,21 @@ claw_process_control( struct net_device 
 		if (p_ctlbk->linkid == -(privptr->active_link_ID)) {
 			privptr->active_link_ID = p_ctlbk->linkid;
 			if (p_env->packing > PACKING_ASK) {
-				printk(KERN_INFO "%s: Confirmed Now packing\n",
-					dev->name);
+				dev_info(tdev,
+				"%s: Confirmed Now packing\n", dev->name);
 				p_env->packing = DO_PACKED;
 			}
 			p_ch = &privptr->channel[WRITE];
 			wake_up(&p_ch->wait);
 		} else {
-		       printk(KERN_INFO "%s: Conn confirm: "
-				"unexpected linkid=%d \n",
+			dev_warn(tdev, "Activating %s failed because of"
+				" an incorrect link ID=%d\n",
 				dev->name, p_ctlbk->linkid);
 			claw_snd_disc(dev, p_ctlbk);
 		}
 		break;
 	case DISCONNECT:
-		printk(KERN_INFO "%s: Disconnect: "
+		dev_info(tdev, "%s: Disconnect: "
 			"Vers=%d,link_id=%d,Corr=%d\n",
 			dev->name, p_ctlbk->version,
 			p_ctlbk->linkid, p_ctlbk->correlator);
@@ -2249,12 +2275,13 @@ claw_process_control( struct net_device 
 			privptr->active_link_ID = 0;
 		break;
 	case CLAW_ERROR:
-		printk(KERN_INFO "%s: CLAW ERROR detected\n",
+		dev_warn(tdev, "The communication peer of %s failed\n",
 			dev->name);
 		break;
 	default:
-		printk(KERN_INFO "%s:  Unexpected command code=%d \n",
-			dev->name,  p_ctlbk->command);
+		dev_warn(tdev, "The communication peer of %s sent"
+			" an unknown command code\n",
+			dev->name);
 		break;
         }
 
@@ -2296,12 +2323,14 @@ claw_send_control(struct net_device *dev
                         memcpy(&p_sysval->host_name, local_name, 8);
                         memcpy(&p_sysval->WS_name, remote_name, 8);
 			if (privptr->p_env->packing > 0) {
-                        	p_sysval->read_frame_size=DEF_PACK_BUFSIZE;
+				p_sysval->read_frame_size=DEF_PACK_BUFSIZE;
 	                        p_sysval->write_frame_size=DEF_PACK_BUFSIZE;
 			} else {
 				/* how big is the biggest group of packets */
-				p_sysval->read_frame_size=privptr->p_env->read_size;
-	                        p_sysval->write_frame_size=privptr->p_env->write_size;
+			   p_sysval->read_frame_size =
+				privptr->p_env->read_size;
+			   p_sysval->write_frame_size =
+				privptr->p_env->write_size;
 			}
                         memset(&p_sysval->reserved, 0x00, 4);
                         break;
@@ -2513,8 +2542,10 @@ unpack_read(struct net_device *dev )
                         mtc_this_frm=1;
                         if (p_this_ccw->header.length!=
 				privptr->p_env->read_size ) {
-                                printk(KERN_INFO " %s: Invalid frame detected "
-					"length is %02x\n" ,
+				dev_warn(p_dev,
+					"The communication peer of %s"
+					" sent a faulty"
+					" frame of length %02x\n",
                                         dev->name, p_this_ccw->header.length);
                         }
                 }
@@ -2546,7 +2577,7 @@ unpack_next:
 				goto NextFrame;
 			p_packd = p_this_ccw->p_buffer+pack_off;
 			p_packh = (struct clawph *) p_packd;
-			if ((p_packh->len == 0) || /* all done with this frame? */
+			if ((p_packh->len == 0) || /* done with this frame? */
 			    (p_packh->flag != 0))
 				goto NextFrame;
 			bytes_to_mov = p_packh->len;
@@ -2596,9 +2627,9 @@ unpack_next:
                                 netif_rx(skb);
                         }
                         else {
+				dev_info(p_dev, "Allocating a buffer for"
+					" incoming data failed\n");
                                 privptr->stats.rx_dropped++;
-                                printk(KERN_WARNING "%s: %s() low on memory\n",
-				dev->name,__func__);
                         }
                         privptr->mtc_offset=0;
                         privptr->mtc_logical_link=-1;
@@ -2722,7 +2753,7 @@ claw_strt_out_IO( struct net_device *dev
         if (test_and_set_bit(0, (void *)&p_ch->IO_active) == 0) {
                 parm = (unsigned long) p_ch;
 		CLAW_DBF_TEXT(2, trace, "StWrtIO");
-                rc = ccw_device_start (p_ch->cdev,&p_first_ccw->write, parm,
+		rc = ccw_device_start (p_ch->cdev,&p_first_ccw->write,parm,
 				       0xff, 0);
                 if (rc != 0) {
                         ccw_check_return_code(p_ch->cdev, rc);
@@ -2882,8 +2913,8 @@ claw_new_device(struct ccwgroup_device *
 	int ret;
 	struct ccw_dev_id dev_id;
 
-	printk(KERN_INFO "claw: add for %s\n",
-	       dev_name(&cgdev->cdev[READ]->dev));
+	dev_info(&cgdev->dev, "add for %s\n",
+		 dev_name(&cgdev->cdev[READ]->dev));
 	CLAW_DBF_TEXT(2, setup, "new_dev");
 	privptr = cgdev->dev.driver_data;
 	cgdev->cdev[READ]->dev.driver_data = privptr;
@@ -2899,29 +2930,28 @@ claw_new_device(struct ccwgroup_device *
 	if (ret == 0)
 		ret = add_channel(cgdev->cdev[1],1,privptr);
 	if (ret != 0) {
-		printk(KERN_WARNING
-			"add channel failed with ret = %d\n", ret);
+		dev_warn(&cgdev->dev, "Creating a CLAW group device"
+			" failed with error code %d\n", ret);
 		goto out;
 	}
 	ret = ccw_device_set_online(cgdev->cdev[READ]);
 	if (ret != 0) {
-		printk(KERN_WARNING
-			"claw: ccw_device_set_online %s READ failed "
-		       "with ret = %d\n", dev_name(&cgdev->cdev[READ]->dev),
-		       ret);
+		dev_warn(&cgdev->dev,
+			"Setting the read subchannel online"
+			" failed with error code %d\n", ret);
 		goto out;
 	}
 	ret = ccw_device_set_online(cgdev->cdev[WRITE]);
 	if (ret != 0) {
-		printk(KERN_WARNING
-			"claw: ccw_device_set_online %s WRITE failed "
-		       "with ret = %d\n", dev_name(&cgdev->cdev[WRITE]->dev),
-		       ret);
+		dev_warn(&cgdev->dev,
+			"Setting the write subchannel online "
+			"failed with error code %d\n", ret);
 		goto out;
 	}
 	dev = alloc_netdev(0,"claw%d",claw_init_netdevice);
 	if (!dev) {
-		printk(KERN_WARNING "%s:alloc_netdev failed\n",__func__);
+		dev_warn(&cgdev->dev,
+			"Activating the CLAW device failed\n");
 		goto out;
 	}
 	dev->ml_priv = privptr;
@@ -2949,13 +2979,13 @@ claw_new_device(struct ccwgroup_device *
 	privptr->channel[WRITE].ndev = dev;
 	privptr->p_env->ndev = dev;
 
-	printk(KERN_INFO "%s:readsize=%d  writesize=%d "
+	dev_info(&cgdev->dev, "%s:readsize=%d  writesize=%d "
 		"readbuffer=%d writebuffer=%d read=0x%04x write=0x%04x\n",
                 dev->name, p_env->read_size,
 		p_env->write_size, p_env->read_buffers,
                 p_env->write_buffers, p_env->devno[READ],
 		p_env->devno[WRITE]);
-        printk(KERN_INFO "%s:host_name:%.8s, adapter_name "
+	dev_info(&cgdev->dev, "%s:host_name:%.8s, adapter_name "
 		":%.8s api_type: %.8s\n",
                 dev->name, p_env->host_name,
 		p_env->adapter_name , p_env->api_type);
@@ -2999,8 +3029,8 @@ claw_shutdown_device(struct ccwgroup_dev
 	ndev = priv->channel[READ].ndev;
 	if (ndev) {
 		/* Close the device */
-		printk(KERN_INFO
-			"%s: shuting down \n",ndev->name);
+		dev_info(&cgdev->dev, "%s: shutting down \n",
+			ndev->name);
 		if (ndev->flags & IFF_RUNNING)
 			ret = claw_release(ndev);
 		ndev->flags &=~IFF_RUNNING;
@@ -3025,8 +3055,7 @@ claw_remove_device(struct ccwgroup_devic
 	CLAW_DBF_TEXT_(2, setup, "%s", dev_name(&cgdev->dev));
 	priv = cgdev->dev.driver_data;
 	BUG_ON(!priv);
-	printk(KERN_INFO "claw: %s() called %s will be removed.\n",
-			__func__, dev_name(&cgdev->cdev[0]->dev));
+	dev_info(&cgdev->dev, " will be removed.\n");
 	if (cgdev->state == CCWGROUP_ONLINE)
 		claw_shutdown_device(cgdev);
 	claw_remove_files(&cgdev->dev);
@@ -3065,7 +3094,8 @@ claw_hname_show(struct device *dev, stru
 }
 
 static ssize_t
-claw_hname_write(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+claw_hname_write(struct device *dev, struct device_attribute *attr,
+	 const char *buf, size_t count)
 {
 	struct claw_privbk *priv;
 	struct claw_env *  p_env;
@@ -3102,7 +3132,8 @@ claw_adname_show(struct device *dev, str
 }
 
 static ssize_t
-claw_adname_write(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+claw_adname_write(struct device *dev, struct device_attribute *attr,
+	 const char *buf, size_t count)
 {
 	struct claw_privbk *priv;
 	struct claw_env *  p_env;
@@ -3140,7 +3171,8 @@ claw_apname_show(struct device *dev, str
 }
 
 static ssize_t
-claw_apname_write(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+claw_apname_write(struct device *dev, struct device_attribute *attr,
+	const char *buf, size_t count)
 {
 	struct claw_privbk *priv;
 	struct claw_env *  p_env;
@@ -3187,7 +3219,8 @@ claw_wbuff_show(struct device *dev, stru
 }
 
 static ssize_t
-claw_wbuff_write(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+claw_wbuff_write(struct device *dev, struct device_attribute *attr,
+	const char *buf, size_t count)
 {
 	struct claw_privbk *priv;
 	struct claw_env *  p_env;
@@ -3228,7 +3261,8 @@ claw_rbuff_show(struct device *dev, stru
 }
 
 static ssize_t
-claw_rbuff_write(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
+claw_rbuff_write(struct device *dev, struct device_attribute *attr,
+	const char *buf, size_t count)
 {
 	struct claw_privbk *priv;
 	struct claw_env *p_env;
@@ -3291,7 +3325,7 @@ claw_cleanup(void)
 {
 	unregister_cu3088_discipline(&claw_group_driver);
 	claw_unregister_debug_facility();
-	printk(KERN_INFO "claw: Driver unloaded\n");
+	pr_info("Driver unloaded\n");
 
 }
 
@@ -3305,12 +3339,12 @@ static int __init
 claw_init(void)
 {
 	int ret = 0;
-	printk(KERN_INFO "claw: starting driver\n");
 
+	pr_info("Loading %s\n", version);
 	ret = claw_register_debug_facility();
 	if (ret) {
-		printk(KERN_WARNING "claw: %s() debug_register failed %d\n",
-			__func__,ret);
+		pr_err("Registering with the S/390 debug feature"
+			" failed with error code %d\n", ret);
 		return ret;
 	}
 	CLAW_DBF_TEXT(2, setup, "init_mod");
@@ -3318,8 +3352,8 @@ claw_init(void)
 	if (ret) {
 		CLAW_DBF_TEXT(2, setup, "init_bad");
 		claw_unregister_debug_facility();
-		printk(KERN_WARNING "claw; %s() cu3088 register failed %d\n",
-			__func__,ret);
+		pr_err("Registering with the cu3088 device driver failed "
+			   "with error code %d\n", ret);
 	}
 	return ret;
 }

