From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: Avoid deadlock during phy_error()
Date: Fri, 20 Jan 2017 15:31:52 -0800
Message-ID: <20170120233152.16244-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, kyle.roeschley@ni.com,
        rmk+kernel@armlinux.org.uk, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35984 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752474AbdATXcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 18:32:00 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so7913054pgf.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 15:32:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_error() is called in the PHY state machine workqueue context, and
calls phy_trigger_machine() which does a cancel_delayed_work_sync() of
the workqueue we execute from, causing a deadlock situation.

Augment phy_trigger_machine() machine with a sync boolean indicating
whether we should use cancel_*_sync() or just cancel_*_work().

Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
Reported-by: Russell King <rmk+kernel@armlinux.org.uk>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 48da6e93c3f7..e687a9cb4a37 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -649,14 +649,18 @@ void phy_start_machine(struct phy_device *phydev)
  * phy_trigger_machine - trigger the state machine to run
  *
  * @phydev: the phy_device struct
+ * @sync: indicate whether we should wait for the workqueue cancelation
  *
  * Description: There has been a change in state which requires that the
  *   state machine runs.
  */
 
-static void phy_trigger_machine(struct phy_device *phydev)
+static void phy_trigger_machine(struct phy_device *phydev, bool sync)
 {
-	cancel_delayed_work_sync(&phydev->state_queue);
+	if (sync)
+		cancel_delayed_work_sync(&phydev->state_queue);
+	else
+		cancel_delayed_work(&phydev->state_queue);
 	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
 }
 
@@ -693,7 +697,7 @@ static void phy_error(struct phy_device *phydev)
 	phydev->state = PHY_HALTED;
 	mutex_unlock(&phydev->lock);
 
-	phy_trigger_machine(phydev);
+	phy_trigger_machine(phydev, false);
 }
 
 /**
@@ -840,7 +844,7 @@ void phy_change(struct phy_device *phydev)
 	}
 
 	/* reschedule state queue work to run as soon as possible */
-	phy_trigger_machine(phydev);
+	phy_trigger_machine(phydev, true);
 	return;
 
 ignore:
@@ -942,7 +946,7 @@ void phy_start(struct phy_device *phydev)
 	if (do_resume)
 		phy_resume(phydev);
 
-	phy_trigger_machine(phydev);
+	phy_trigger_machine(phydev, true);
 }
 EXPORT_SYMBOL(phy_start);
 
-- 
2.11.0
