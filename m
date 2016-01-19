From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: phy: Fix phy_mac_interrupt()
Date: Mon, 18 Jan 2016 19:33:07 -0800
Message-ID: <1453174388-26752-3-git-send-email-f.fainelli@gmail.com>
References: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com, Woojung.Huh@microchip.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34539 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439AbcASDd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 22:33:57 -0500
Received: by mail-pa0-f48.google.com with SMTP id uo6so429767871pac.1
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 19:33:57 -0800 (PST)
In-Reply-To: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5ea94e7686a3 ("phy: add phy_mac_interrupt()") to use with
PHY_IGNORE_INTERRUPT added a cancel_work_sync() into phy_mac_interrupt()
which is allowed to sleep, whereas phy_mac_interrupt() is expected to be
callable from interrupt context.

Now that we have fixed how the PHY state machine treats
PHY_IGNORE_INTERRUPT with respect to state changes, we can just set the
new link state, and queue the PHY state machine for execution so it is
going to read the new link state.

For that to work properly, we need to update phy_change() not to try to
invoke any interrupt callbacks if we have configured the PHY device for
PHY_IGNORE_INTERRUPT, because that PHY device and its driver are not
required to implement those.

Fixes: 5ea94e7686a3 ("phy: add phy_mac_interrupt() to use with PHY_IGNORE_INTERRUPT")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 42b4c1eb7a90..5590b9c182c9 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -692,25 +692,29 @@ void phy_change(struct work_struct *work)
 	struct phy_device *phydev =
 		container_of(work, struct phy_device, phy_queue);
 
-	if (phydev->drv->did_interrupt &&
-	    !phydev->drv->did_interrupt(phydev))
-		goto ignore;
+	if (phy_interrupt_is_valid(phydev)) {
+		if (phydev->drv->did_interrupt &&
+		    !phydev->drv->did_interrupt(phydev))
+			goto ignore;
 
-	if (phy_disable_interrupts(phydev))
-		goto phy_err;
+		if (phy_disable_interrupts(phydev))
+			goto phy_err;
+	}
 
 	mutex_lock(&phydev->lock);
 	if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
 		phydev->state = PHY_CHANGELINK;
 	mutex_unlock(&phydev->lock);
 
-	atomic_dec(&phydev->irq_disable);
-	enable_irq(phydev->irq);
+	if (phy_interrupt_is_valid(phydev)) {
+		atomic_dec(&phydev->irq_disable);
+		enable_irq(phydev->irq);
 
-	/* Reenable interrupts */
-	if (PHY_HALTED != phydev->state &&
-	    phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED))
-		goto irq_enable_err;
+		/* Reenable interrupts */
+		if (PHY_HALTED != phydev->state &&
+		    phy_config_interrupt(phydev, PHY_INTERRUPT_ENABLED))
+			goto irq_enable_err;
+	}
 
 	/* reschedule state queue work to run as soon as possible */
 	cancel_delayed_work_sync(&phydev->state_queue);
@@ -1011,9 +1015,10 @@ void phy_state_machine(struct work_struct *work)
 
 void phy_mac_interrupt(struct phy_device *phydev, int new_link)
 {
-	cancel_work_sync(&phydev->phy_queue);
 	phydev->link = new_link;
-	schedule_work(&phydev->phy_queue);
+
+	/* Trigger a state machine change */
+	queue_work(system_power_efficient_wq, &phydev->phy_queue);
 }
 EXPORT_SYMBOL(phy_mac_interrupt);
 
-- 
2.1.0
