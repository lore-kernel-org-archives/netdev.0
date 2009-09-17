From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 12:30:27 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0DE8A1@MELANITE.micrel.com>
References: <20090916.204801.190052862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Li, Charles" <Charles.Li@Micrel.Com>,
	<Choi@kroah.com>, <jgarzik@redhat.com>, <shemminger@vyatta.com>
To: "David Miller" <davem@davemloft.net>, <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o144.mxlogic.net ([208.65.145.67]:56003 "EHLO
	p01c12o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbZIQTbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 15:31:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090916.204801.190052862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David Miller,

Sorry to resend it. In my previous e-mail, I included a part of patch,
not a complete patch.

My fix ups are as followings;
	-Remove DEBUG definition
	-Remove MALLOC definition
	-Intent to fix compile warnings, which I can not reproduce
	 in my test environment(linux-2.6.31-rc3 source tree and
gcc4.2.1.)
	 If you have still warnings with my fix ups, give me brief
description 
	 To reproduce the warnings.

===================
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

@@ -1515,12 +1510,13 @@ void ks_enable(struct ks_net *ks)
 
 static int ks_hw_init(struct ks_net *ks)
 {
+#define	MHEADER_SIZE	(sizeof(struct type_frame_head) *
MAX_RECV_FRAMES)
 	ks->promiscuous = 0;
 	ks->all_mcast = 0;
 	ks->mcast_lst_size = 0;
 
 	ks->frame_head_info = (struct type_frame_head *) \
-		MALLOC(sizeof(struct type_frame_head) *
MAX_RECV_FRAMES);
+		kmalloc(MHEADER_SIZE, GFP_KERNEL);
 	if (!ks->frame_head_info) {
 		printk(KERN_ERR "Error: Fail to allocate frame
memory\n");
 		return false;



Regards,
David J. Choi



-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, September 16, 2009 8:48 PM
To: greg@kroah.com
Cc: netdev@vger.kernel.org; Li, Charles; Choi@kroah.com; Choi, David;
jgarzik@redhat.com; shemminger@vyatta.com
Subject: Re: [PATCH] ks8851_ml ethernet network driver

From: Greg KH <greg@kroah.com>
Date: Wed, 16 Sep 2009 19:38:36 -0700

> From: Choi, David <David.Choi@Micrel.Com>
> 
> This is a network driver for the ks8851 16bit MLL ethernet device.
> 
> Signed-off-by: David J. Choi <david.choi@micrel.com>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

This doesn't even build cleanly:

drivers/net/ks8851_mll.c: In function 'ks_inblk':
drivers/net/ks8851_mll.c:555: warning: cast from pointer to integer of
different size
drivers/net/ks8851_mll.c:558: warning: passing argument 1 of '_readw'
makes pointer from integer without a cast
drivers/net/ks8851_mll.c: In function 'ks_outblk':
drivers/net/ks8851_mll.c:571: warning: cast from pointer to integer of
different size
drivers/net/ks8851_mll.c:574: warning: passing argument 2 of '_writew'
makes pointer from integer without a cast

It also has a big "#define DEBUG" at the beginning of the driver.

And it also has stuff like:

+#define MALLOC(x)		kmalloc(x, GFP_KERNEL)

which actually decreases the readability of this driver.

Please fix this up.
