From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Re: rtl8169 problem and 2.4.23
Date: Sat, 21 Feb 2004 14:43:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040221144304.A3230@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        Daniel Egger <degger@fhm.edu>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Jeff,

  can you push the attached patch directly to both 2.6.x and 2.4.x ?
It will exhibit an offset of 3 lines against 2.4.x but it works the same
on 2.4.x and on 2.6.x. The fix already exists in -mm/-netdev serie.

Daniel Egger <degger@fhm.edu> confirmed I did not manage to add a giant
typo in a 4 lines patch. When hit, this bug is more or less a killer.

Daniel, I have no clear idea for the performance issues. Actually I am more
concerned with the stability side of this driver, especially in the new,
shamelessly hacked, branch of the driver. I'll probably regenerate a set
of patches and spam^W reach the testers to have a new data point.

--
Ueimor

--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-tx-desc-overflow.patch"

Assume tp->dirty_tx = NUM_TX_DESC/2, tp->cur_tx = NUM_TX_DESC - 1,
watch "entry" go beyond NUM_TX_DESC. This bug was copied from the 
(2.6.x only) sis190 driver where it is now fixed.
Stats are fixed as an extra bonus.


diff -Nrup drivers/net/r8169.c.orig drivers/net/r8169.c
--- drivers/net/r8169.c.orig	Thu Dec 18 03:58:50 2003
+++ drivers/net/r8169.c	Sat Feb 21 14:11:31 2004
@@ -871,7 +871,6 @@ rtl8169_tx_interrupt(struct net_device *
 		     void *ioaddr)
 {
 	unsigned long dirty_tx, tx_left = 0;
-	int entry = tp->cur_tx % NUM_TX_DESC;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -881,14 +880,18 @@ rtl8169_tx_interrupt(struct net_device *
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
+		int entry = dirty_tx % NUM_TX_DESC;
+
 		if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
-			dev_kfree_skb_irq(tp->
-					  Tx_skbuff[dirty_tx % NUM_TX_DESC]);
-			tp->Tx_skbuff[dirty_tx % NUM_TX_DESC] = NULL;
+			struct sk_buff *skb = tp->Tx_skbuff[entry];
+
+			tp->stats.tx_bytes += skb->len >= ETH_ZLEN ?
+					      skb->len : ETH_ZLEN;
 			tp->stats.tx_packets++;
+			dev_kfree_skb_irq(skb);
+			tp->Tx_skbuff[entry] = NULL;
 			dirty_tx++;
 			tx_left--;
-			entry++;
 		}
 	}
 

--7AUc2qLy4jB3hD7Z--
