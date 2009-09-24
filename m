From: david choi <davidchoi.public@gmail.com>
Subject: [PATCH]ks8851_mll ethernet network driver
Date: Wed, 23 Sep 2009 17:05:41 -0700
Message-ID: <836b80350909231705x3ff170d7udc28d6c6e92fe36a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: greg@kroah.com, netdev@vger.kernel.org,
	Charles Li <charles.li@micrel.com>, choi@kroah.com,
	jgarzik@redhat.com, shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:38260 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbZIXANy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 20:13:54 -0400
Received: by pzk26 with SMTP id 26so959741pzk.4
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2009 17:13:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller,

Based on email_client.txt, I use add-on firefox extension of
ViewSourceWith to send this patch.
Hope to fix line-wrapping issue.

Subject         : [PATCH] ks8851_mll ethernet network driver
>From            : David J. Choi( david.choi@micrel.com )
Body of the explanation :
                Fix up issues as followings;
                -Remove the lines of "#define DEBUG", "#define MALLOC"
                -Remove the compile warnings.
                -Add to return IRQ_NONE when there is no IRQ
indication in hardware.
                -Remove mutex_lock/unlock() in ks_net_open() because
they are redundancy in the function.
Signed-off-by   : David J. Choi

Regards,
David J. Choi
------------------------------------
--- linux-2.6.31-rc3/drivers/net/ks8851_mll.c.orig	2009-09-17
10:18:56.000000000 -0700
+++ linux-2.6.31-rc3/drivers/net/ks8851_mll.c	2009-09-17
10:09:37.000000000 -0700
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
