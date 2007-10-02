From: akpm@linux-foundation.org
Subject: [patch 11/13] PHYLIB: fix an interrupt loop potential when halting
Date: Tue, 02 Oct 2007 14:11:43 -0700
Message-ID: <200710022111.l92LBhl5022507@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	macro@linux-mips.org, afleming@freescale.com, jgarzik@pobox.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33089 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755424AbXJBVVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Maciej W. Rozycki" <macro@linux-mips.org>

Ensure the PHY_HALTED state is not entered with the IRQ asserted as it
could lead to an interrupt loop.

There is a small window in phy_stop(), where the state of the PHY machine
indicates it has been halted, but its interrupt output might still be
unmasked.  If an interrupt goes active right at this moment it will loop as
the phy_interrupt() handler exits immediately with IRQ_NONE if the halted
state is seen.  It is unsafe to extend the phydev spinlock to cover
phy_interrupt().  It is safe to swap the order of the actions though as all
the competing places to unmask the interrupt output of the PHY, which are
phy_change() and phy_timer() are already covered with the lock as is the
sequence in question.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
Cc: Andy Fleming <afleming@freescale.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/phy/phy.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/phy/phy.c~phylib-fix-an-interrupt-loop-potential-when-halting drivers/net/phy/phy.c
--- a/drivers/net/phy/phy.c~phylib-fix-an-interrupt-loop-potential-when-halting
+++ a/drivers/net/phy/phy.c
@@ -737,8 +737,6 @@ void phy_stop(struct phy_device *phydev)
 	if (PHY_HALTED == phydev->state)
 		goto out_unlock;
 
-	phydev->state = PHY_HALTED;
-
 	if (phydev->irq != PHY_POLL) {
 		/* Disable PHY Interrupts */
 		phy_config_interrupt(phydev, PHY_INTERRUPT_DISABLED);
@@ -747,6 +745,8 @@ void phy_stop(struct phy_device *phydev)
 		phy_clear_interrupt(phydev);
 	}
 
+	phydev->state = PHY_HALTED;
+
 out_unlock:
 	spin_unlock_bh(&phydev->lock);
 
_
