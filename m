From: Christiaan Welvaart <cjw@daneel.dyndns.org>
Subject: [PATCH] drivers/net/b44.c: fix regressions in error recovery
Date: Sun, 29 Mar 2009 15:25:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0903291509460.8069@zem.cjw.nep>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.sshunet.nl ([145.97.192.42]:41218 "EHLO
	pollux.sshunet.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757705AbZC2Nqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 09:46:45 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by pollux.sshunet.nl (Postfix) with ESMTP id F406758000D
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 15:25:17 +0200 (CEST)
Received: from pollux.sshunet.nl ([127.0.0.1])
	by localhost (pollux.sshunet.nl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id vyoyPPLtJW-X for <netdev@vger.kernel.org>;
	Sun, 29 Mar 2009 15:25:17 +0200 (CEST)
Received: from zem.cjw.nep (213pc220.sshunet.nl [145.97.220.213])
	by pollux.sshunet.nl (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 15:25:17 +0200 (CEST)
Received: from zem.cjw.nep (me@localhost.localdomain [127.0.0.1])
	by zem.cjw.nep (8.14.3/8.14.3) with ESMTP id n2TDPHZS008306
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 15:25:17 +0200
Received: from localhost (cjw@localhost)
	by zem.cjw.nep (8.14.3/8.14.3/Submit) with ESMTP id n2TDPGAM008303
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 15:25:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

When I max out a b44 device using NFS and then add http traffic (both 
inbound), the device resets every few minutes. This causes huge delays due 
to the PHY reset which was introduced by commit 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=fedb0eefe286a6409aa2c6c6f2353c595e68d33d
It changes b44_halt() to disable the PHY but this function 
gets called in 2 error recovery situations and some configuration changes. IMHO 
disabling the PHY in those cases is a total waste of time. This patch reverts 
those cases to the old behavior.

(please CC: me on replies as I'm not subscribed to the list)


Signed-off-by: Christiaan Welvaart <cjw@daneel.dyndns.org>

diff -pruN a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2009-03-28 14:12:30.087884295 +0100
+++ b/drivers/net/b44.c	2009-03-28 14:11:57.293902007 +0100
@@ -124,6 +124,7 @@ MODULE_DEVICE_TABLE(ssb, b44_ssb_tbl);

   static void b44_halt(struct b44 *);
   static void b44_init_rings(struct b44 *);
+static void b44_chip_reset(struct b44 *bp, int reset_kind);

   #define B44_FULL_RESET		1
   #define B44_FULL_RESET_SKIP_PHY	2
@@ -865,7 +866,8 @@ static int b44_poll(struct napi_struct *
  		 unsigned long flags;

  		spin_lock_irqsave(&bp->lock, flags);
-		b44_halt(bp);
+		b44_disable_ints(bp);
+		b44_chip_reset(bp, B44_CHIP_RESET_FULL);
  		 b44_init_rings(bp);
  		 b44_init_hw(bp, B44_FULL_RESET_SKIP_PHY);
  		 netif_wake_queue(bp->dev);
@@ -935,7 +937,8 @@ static void b44_tx_timeout(struct net_de

  	spin_lock_irq(&bp->lock);

-	b44_halt(bp);
+	b44_disable_ints(bp);
+	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
  	 b44_init_rings(bp);
  	 b44_init_hw(bp, B44_FULL_RESET);

@@ -1052,7 +1055,8 @@ static int b44_change_mtu(struct net_dev
  	 }

  	spin_lock_irq(&bp->lock);
-	b44_halt(bp);
+	b44_disable_ints(bp);
+	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
  	 dev->mtu = new_mtu;
  	 b44_init_rings(bp);
  	 b44_init_hw(bp, B44_FULL_RESET);
@@ -1917,7 +1921,8 @@ static int b44_set_ringparam(struct net_
  	 bp->rx_pending = ering->rx_pending;
  	 bp->tx_pending = ering->tx_pending;

-	b44_halt(bp);
+	b44_disable_ints(bp);
+	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
  	 b44_init_rings(bp);
  	 b44_init_hw(bp, B44_FULL_RESET);
  	 netif_wake_queue(bp->dev);
@@ -1960,7 +1965,8 @@ static int b44_set_pauseparam(struct net
  	 else
  	 	bp->flags &= ~B44_FLAG_TX_PAUSE;
  	if (bp->flags & B44_FLAG_PAUSE_AUTO) {
-		b44_halt(bp);
+		b44_disable_ints(bp);
+		b44_chip_reset(bp, B44_CHIP_RESET_FULL);
  		 b44_init_rings(bp);
  		 b44_init_hw(bp, B44_FULL_RESET);
  	 } else {
