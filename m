From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH] ks8851_ml ethernet network driver - FIXED LINE-WRAPPING ISSUE
Date: Thu, 24 Sep 2009 16:02:15 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D02127B@MELANITE.micrel.com>
References: <20090916.204801.190052862.davem@davemloft.net><C43529A246480145B0A6D0234BDB0F0DE8A1@MELANITE.micrel.com> <20090917.164952.33104590.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <greg@kroah.com>, <netdev@vger.kernel.org>,
	"Li, Charles" <Charles.Li@Micrel.Com>, <Choi@kroah.com>,
	<jgarzik@redhat.com>, <shemminger@vyatta.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o144.mxlogic.net ([208.65.144.67]:46617 "EHLO
	p01c11o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbZIXXCV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 19:02:21 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller,

It has taken pretty long time to figure it out to submitting the patch in my environment.
Now I am almost sure I find a workaround solution to submit the patch in my environment.
Anyway I am sorry for making mistakes in submitting the patch and causes to waste your valuable time. 

This patch fixes up as followings;
   .Remove "#define DEBUG" and "#define MALLOC".
   .Remove the compile warning messages from ks_inblk() and ks_outblk().
   .add "return IRQ_NONE" when there is no hardware IRQ indication in ks_irq().
   .remove mutex_lock/unlock from ks_net_open because they are redundancy.

I will appreciate if you send back any comments on my patch.

-------------------------------
--- linux-2.6.31-rc3/drivers/net/ks8851_mll.c.orig	2009-09-17 10:18:56.000000000 -0700
+++ linux-2.6.31-rc3/drivers/net/ks8851_mll.c	2009-09-17 10:09:37.000000000 -0700
@@ -21,8 +21,6 @@
  * KS8851 16bit MLL chip from Micrel Inc.
  */
 
-#define DEBUG
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
@@ -419,7 +417,6 @@ union ks_tx_hdr {
  * or one of the work queues.
  *
  */
-#define MALLOC(x)		kmalloc(x, GFP_KERNEL)
 
 /* Receive multiplex framer header info */
 struct type_frame_head {
@@ -552,11 +549,9 @@ static void ks_wrreg16(struct ks_net *ks
  */
 static inline void ks_inblk(struct ks_net *ks, u16 *wptr, u32 len)
 {
-	u32 data_port = (u32)ks->hw_addr;
 	len >>= 1;
-	do {
-		*wptr++ = (u16)ioread16(data_port);
-	} while (--len);
+	while (len--)
+		*wptr++ = (u16)ioread16(ks->hw_addr);
 }
 
 /**
@@ -568,11 +563,9 @@ static inline void ks_inblk(struct ks_ne
  */
 static inline void ks_outblk(struct ks_net *ks, u16 *wptr, u32 len)
 {
-	u32 data_port = (u32)ks->hw_addr;
 	len >>= 1;
-	do {
-		iowrite16(*wptr++, data_port);
-	} while (--len);
+	while (len--)
+		iowrite16(*wptr++, ks->hw_addr);
 }
 
 /**
@@ -818,6 +811,11 @@ static irqreturn_t ks_irq(int irq, void 
 	ks_save_cmd_reg(ks);
 
 	status = ks_rdreg16(ks, KS_ISR);
+	if (unlikely(!status)) {
+		ks_restore_cmd_reg(ks);
+		return IRQ_NONE;
+	}
+
 	ks_wrreg16(ks, KS_ISR, status);
 
 	if (likely(status & IRQ_RXI))
@@ -858,7 +856,6 @@ static int ks_net_open(struct net_device
 	/* lock the card, even if we may not actually do anything
 	 * else at the moment.
 	 */
-	mutex_lock(&ks->lock);
 
 	if (netif_msg_ifup(ks))
 		ks_dbg(ks, "%s - entry\n", __func__);
@@ -875,8 +872,6 @@ static int ks_net_open(struct net_device
 	if (netif_msg_ifup(ks))
 		ks_dbg(ks, "network device %s up\n", netdev->name);
 
-	mutex_unlock(&ks->lock);
-
 	return 0;
 }
 
@@ -1515,12 +1510,13 @@ void ks_enable(struct ks_net *ks)
 
 static int ks_hw_init(struct ks_net *ks)
 {
+#define	MHEADER_SIZE	(sizeof(struct type_frame_head) * MAX_RECV_FRAMES)
 	ks->promiscuous = 0;
 	ks->all_mcast = 0;
 	ks->mcast_lst_size = 0;
 
 	ks->frame_head_info = (struct type_frame_head *) \
-		MALLOC(sizeof(struct type_frame_head) * MAX_RECV_FRAMES);
+		kmalloc(MHEADER_SIZE, GFP_KERNEL);
 	if (!ks->frame_head_info) {
 		printk(KERN_ERR "Error: Fail to allocate frame memory\n");
 		return false;

-------------------------------

Regards,
David J. Choi




-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Thu 9/17/2009 4:49 PM
To: Choi, David
Cc: greg@kroah.com; netdev@vger.kernel.org; Li, Charles; Choi@kroah.com; jgarzik@redhat.com; shemminger@vyatta.com
Subject: Re: [PATCH] ks8851_ml ethernet network driver
 
From: "Choi, David" <David.Choi@Micrel.Com>
Date: Thu, 17 Sep 2009 12:30:27 -0700

> --- linux-2.6.31-rc3/drivers/net/ks8851_mll.c.orig	2009-09-17
> 10:18:56.000000000 -0700
> +++ linux-2.6.31-rc3/drivers/net/ks8851_mll.c	2009-09-17
> 10:09:37.000000000 -0700
> @@ -21,8 +21,6 @@
>   * KS8851 16bit MLL chip from Micrel Inc.

I can't use this patch or even test it, as your email client
has corrupted it by, for example, breaking up long lines.

