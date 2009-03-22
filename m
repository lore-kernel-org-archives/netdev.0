From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.29-rc8] dm9000 locking bugfix
Date: Sun, 22 Mar 2009 16:12:12 -0700
Message-ID: <200903221612.13055.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from n6.bullet.mud.yahoo.com ([216.252.100.57]:36757 "HELO
	n6.bullet.mud.yahoo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756371AbZCVXTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 19:19:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

This fixes a locking bug in the dm9000 driver.  It calls
request_irq() without setting IRQF_DISABLED ... which is
correct for handlers that support IRQ sharing, since that
behavior is not guaranteed for shared IRQs.  However, its
IRQ handler then wrongly assumes that IRQs are blocked.
So the fix just uses the right spinlock primitives in the
IRQ handler.

NOTE:  this is a classic example of the type of bug which
lockdep currently masks by forcibly setting IRQF_DISABLED
on IRQ handlers that did not request that flag.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
The annoying "watchdog timeouts" seem unrelated to this.
But on at least one problem, enabling lockdep makes them
go away ... good fun, eh?

 drivers/net/dm9000.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -930,13 +930,15 @@ static irqreturn_t dm9000_interrupt(int 
 	struct net_device *dev = dev_id;
 	board_info_t *db = netdev_priv(dev);
 	int int_status;
+	unsigned long flags;
 	u8 reg_save;
 
 	dm9000_dbg(db, 3, "entering %s\n", __func__);
 
 	/* A real interrupt coming */
 
-	spin_lock(&db->lock);
+	/* holders of db->lock must always block IRQs */
+	spin_lock_irqsave(&db->lock, flags);
 
 	/* Save previous register address */
 	reg_save = readb(db->io_addr);
@@ -972,7 +974,7 @@ static irqreturn_t dm9000_interrupt(int 
 	/* Restore previous register address */
 	writeb(reg_save, db->io_addr);
 
-	spin_unlock(&db->lock);
+	spin_unlock_irqrestore(&db->lock, flags);
 
 	return IRQ_HANDLED;
 }

