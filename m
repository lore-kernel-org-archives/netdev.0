From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] sis190: fix cable detect via link status poll
Date: Mon, 1 Mar 2010 15:40:09 -0500
Message-ID: <20100301204009.GA15782@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47387 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab0CAUkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Mar 2010 15:40:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some sis190 devices don't report LinkChange, so do polling for
link status.

Fixes http://bugzilla.kernel.org/show_bug.cgi?id=11926

Signed-off-by: Herton Ronaldo Krzesinski <herton@mandriva.com.br>
---
Alan Cox found this change languishing in bugzilla -- a problem with a
patch verified to fix the problem.

I updated the patch to apply to the most recent net-next kernel, but
have not received confirmation that my updated patch still fixes the
problem.		-jgarzik

 drivers/net/sis190.c |   23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 80af4a4..760d9e8 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -285,6 +285,11 @@ struct sis190_private {
 	struct list_head first_phy;
 	u32 features;
 	u32 negotiated_lpa;
+	enum {
+		LNK_OFF,
+		LNK_ON,
+		LNK_AUTONEG,
+	} link_status;
 };
 
 struct sis190_phy {
@@ -750,6 +755,7 @@ static irqreturn_t sis190_interrupt(int irq, void *__dev)
 
 	if (status & LinkChange) {
 		netif_info(tp, intr, dev, "link change\n");
+		del_timer(&tp->timer);
 		schedule_work(&tp->phy_task);
 	}
 
@@ -922,12 +928,15 @@ static void sis190_phy_task(struct work_struct *work)
 	if (val & BMCR_RESET) {
 		// FIXME: needlessly high ?  -- FR 02/07/2005
 		mod_timer(&tp->timer, jiffies + HZ/10);
-	} else if (!(mdio_read_latched(ioaddr, phy_id, MII_BMSR) &
-		     BMSR_ANEGCOMPLETE)) {
+		goto out_unlock;
+	}
+
+	val = mdio_read_latched(ioaddr, phy_id, MII_BMSR);
+	if (!(val & BMSR_ANEGCOMPLETE) && tp->link_status != LNK_AUTONEG) {
 		netif_carrier_off(dev);
 		netif_warn(tp, link, dev, "auto-negotiating...\n");
-		mod_timer(&tp->timer, jiffies + SIS190_PHY_TIMEOUT);
-	} else {
+		tp->link_status = LNK_AUTONEG;
+	} else if ((val & BMSR_LSTATUS) && tp->link_status != LNK_ON) {
 		/* Rejoice ! */
 		struct {
 			int val;
@@ -1000,7 +1009,10 @@ static void sis190_phy_task(struct work_struct *work)
 
 		netif_info(tp, link, dev, "link on %s mode\n", p->msg);
 		netif_carrier_on(dev);
-	}
+		tp->link_status = LNK_ON;
+	} else if (!(val & BMSR_LSTATUS) && tp->link_status != LNK_AUTONEG)
+		tp->link_status = LNK_OFF;
+	mod_timer(&tp->timer, jiffies + SIS190_PHY_TIMEOUT);
 
 out_unlock:
 	rtnl_unlock();
@@ -1513,6 +1525,7 @@ static struct net_device * __devinit sis190_init_board(struct pci_dev *pdev)
 
 	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
+	tp->link_status = LNK_OFF;
 
 	sis190_irq_mask_and_ack(ioaddr);
 
