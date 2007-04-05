From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] 8139too: harden against TX ring overflow
Date: Thu, 5 Apr 2007 23:50:59 +0400
Message-ID: <200704052350.59464.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com,
	kgdb-bugreport@lists.sourceforge.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.155]:53758 "EHLO
	imap.sh.mvista.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1767273AbXDETuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 15:50:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver's 4-packet deep TX queue is too sensible to the "careless" callers
ignoring its state (like netpoll in trapped mode), so add "queue full" check at
the start of the hard_start_xmit() method (only under #ifndef RTL8139_NDEBUG,
otherwise the queue will get stuck once dirty pointer gets out of sync); switch
to using appropriate mnemonics for the return values while at it.
Also, the out-of-sync dirty pointer check is misplaced in rtl8139_tx_interrupt()
which causes TX descriptors to be inspected more than once in case the pointer
really gets out-of-sync (and incrementing the dirty pointer always by 4 is just
not enough, e.g. KGDBoE managed to stuff 20+ extra buffers into the queue) --
place it before the loop and limit the loop to only look through 4 descriptors
at most, so that already overwritten descriptors are just not counted.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

---

 drivers/net/8139too.c |   31 ++++++++++++++++++++-----------
 1 files changed, 20 insertions(+), 11 deletions(-)

Index: linux-2.6/drivers/net/8139too.c
===================================================================
--- linux-2.6.orig/drivers/net/8139too.c
+++ linux-2.6/drivers/net/8139too.c
@@ -90,7 +90,7 @@
 */
 
 #define DRV_NAME	"8139too"
-#define DRV_VERSION	"0.9.28"
+#define DRV_VERSION	"0.9.31"
 
 
 #include <linux/module.h>
@@ -1708,6 +1708,13 @@ static int rtl8139_start_xmit (struct sk
 	unsigned int len = skb->len;
 	unsigned long flags;
 
+#ifndef RTL8139_NDEBUG
+	if (unlikely((tp->cur_tx - tp->dirty_tx) >= NUM_TX_DESC)) {
+		printk(KERN_ERR "%s: TX queue full!\n", dev->name);
+		return NETDEV_TX_BUSY;
+	}
+#endif
+
 	/* Calculate the next Tx descriptor entry. */
 	entry = tp->cur_tx % NUM_TX_DESC;
 
@@ -1720,7 +1727,7 @@ static int rtl8139_start_xmit (struct sk
 	} else {
 		dev_kfree_skb(skb);
 		tp->stats.tx_dropped++;
-		return 0;
+		return NETDEV_TX_OK;
 	}
 
 	spin_lock_irqsave(&tp->lock, flags);
@@ -1740,7 +1747,7 @@ static int rtl8139_start_xmit (struct sk
 		printk (KERN_DEBUG "%s: Queued Tx packet size %u to slot %d.\n",
 			dev->name, len, entry);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 
@@ -1755,6 +1762,16 @@ static void rtl8139_tx_interrupt (struct
 
 	dirty_tx = tp->dirty_tx;
 	tx_left = tp->cur_tx - dirty_tx;
+
+#ifndef RTL8139_NDEBUG
+	if (unlikely(tx_left > NUM_TX_DESC)) {
+		printk(KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
+		       dev->name, dirty_tx, tp->cur_tx);
+		tx_left  = NUM_TX_DESC;
+		dirty_tx = tp->cur_tx - NUM_TX_DESC;
+	}
+#endif /* RTL8139_NDEBUG */
+
 	while (tx_left > 0) {
 		int entry = dirty_tx % NUM_TX_DESC;
 		int txstatus;
@@ -1797,14 +1814,6 @@ static void rtl8139_tx_interrupt (struct
 		tx_left--;
 	}
 
-#ifndef RTL8139_NDEBUG
-	if (tp->cur_tx - dirty_tx > NUM_TX_DESC) {
-		printk (KERN_ERR "%s: Out-of-sync dirty pointer, %ld vs. %ld.\n",
-		        dev->name, dirty_tx, tp->cur_tx);
-		dirty_tx += NUM_TX_DESC;
-	}
-#endif /* RTL8139_NDEBUG */
-
 	/* only wake the queue if we did work, and the queue is stopped */
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;

