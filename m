From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH] PHYLIB: Fix an interrupt loop potential when halting
Date: Wed, 19 Sep 2007 16:09:47 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0709191548030.24627@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.ds.pg.gda.pl ([153.19.208.18]:43871 "EHLO
	cerber.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756465AbXISPJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:09:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Ensure the PHY_HALTED state is not entered with the IRQ asserted as it 
could lead to an interrupt loop.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 There is a small window in phy_stop(), where the state of the PHY machine 
indicates it has been halted, but its interrupt output might still be 
unmasked.  If an interrupt goes active right at this moment it will loop 
as the phy_interrupt() handler exits immediately with IRQ_NONE if the 
halted state is seen.  It is unsafe to extend the phydev spinlock to cover 
phy_interrupt().  It is safe to swap the order of the actions though as 
all the competing places to unmask the interrupt output of the PHY, which 
are phy_change() and phy_timer() are already covered with the lock as is 
the sequence in question.

 Checked with checkpatch.pl and at the run time.

 Please apply.

  Maciej
 
patch-mips-2.6.23-rc5-20070904-phy-halt-0
diff -up --recursive --new-file linux-mips-2.6.23-rc5-20070904.macro/drivers/net/phy/phy.c linux-mips-2.6.23-rc5-20070904/drivers/net/phy/phy.c
--- linux-mips-2.6.23-rc5-20070904.macro/drivers/net/phy/phy.c	2007-09-04 04:55:42.000000000 +0000
+++ linux-mips-2.6.23-rc5-20070904/drivers/net/phy/phy.c	2007-09-16 17:17:20.000000000 +0000
@@ -722,8 +722,6 @@ void phy_stop(struct phy_device *phydev)
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
 
-	phydev->state = PHY_HALTED;
-
 	if (phydev->irq != PHY_POLL) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
@@ -732,6 +730,8 @@ void phy_stop(struct phy_device *phydev)
 		phy_clear_interrupt(phydev);
 	}
 
+	phydev->state = PHY_HALTED;
+
 out_unlock:
 	spin_unlock(&phydev->lock);
 
