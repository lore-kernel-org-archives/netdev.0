From: bora.sahin@ttnet.net.tr
Subject: [PATCH 12/12] smc911x: afc_cfg calculation is wrong at case 5
Date: Wed, 13 Sep 2006 21:37:47 +0300
Message-ID: <200609132137.47905.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:12670 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751067AbWIMSf1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:27 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


BACKDUR  calculation is wrong at case 5. Also some cosmetic around
smc911x_probe...

AFC_HI is about ((Rx Data Fifo Size)*2/3)/64
AFC_LO is AFC_HI/2
BACK_DUR is about 5uS*(AFC_LO) rounded down

Rx Data Fifo Size = 10560 
AFC_HI = 110
AFC_LO = 55
BACK_DUR = 55 * 5 = 275

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -1884,7 +1882,7 @@
 }
 
 /*
- * Function: smc911x_probe(unsigned long ioaddr)
+ * Function: smc911x_probe(struct net_device *dev, unsigned long ioaddr)
  *
  * Purpose:
  *	 Tests to see if a given ioaddr points to an SMC911x chip.
@@ -1917,7 +1915,7 @@
 
 	/* First, see if the endian word is recognized */
 	val = SMC_GET_BYTE_TEST();
-	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%04x\n", CARDNAME, val);
+	DBG(SMC_DEBUG_MISC, "%s: endian probe returned 0x%08x\n", CARDNAME, val);
 	if (val != 0x87654321) {
 		printk(KERN_ERR "Invalid chip endian 0x08%x\n",val);
 		retval = -ENODEV;
@@ -1977,7 +1975,7 @@
 		case 4:/* 11520 Rx Data Fifo Size */
 			lp->afc_cfg=0x00783C9F;break;
 		case 5:/* 10560 Rx Data Fifo Size */
-			lp->afc_cfg=0x006E374F;break;
+			lp->afc_cfg=0x006E378F;break;
 		case 6:/* 9600 Rx Data Fifo Size */
 			lp->afc_cfg=0x0064328F;break;
 		case 7:/* 8640 Rx Data Fifo Size */
@@ -2039,8 +2037,7 @@
 		}
 	}
 	if (dev->irq == 0) {
-		printk("%s: Couldn't autodetect your IRQ. Use irq=xx.\n",
-			dev->name);
+		printk("%s: Couldn't autodetect your IRQ\n", dev->name);
 		retval = -ENODEV;
 		goto err_out;
 	}
