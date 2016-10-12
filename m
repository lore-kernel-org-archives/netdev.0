From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next] net: phy: Trigger state machine on state change and not polling.
Date: Wed, 12 Oct 2016 22:14:53 +0200
Message-ID: <1476303294-14944-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Kyle Roeschley <kyle.roeschley@ni.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44287 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932574AbcJLUPo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Oct 2016 16:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy_start() is used to indicate the PHY is now ready to do its
work. The state is changed, normally to PHY_UP which means that both
the MAC and the PHY are ready.

If the phy driver is using polling, when the next poll happens, the
state machine notices the PHY is now in PHY_UP, and kicks off
auto-negotiation, if needed.

If however, the PHY is using interrupts, there is no polling. The phy
is stuck in PHY_UP until the next interrupt comes along. And there is
no reason for the PHY to interrupt.

Have phy_start() schedule the state machine to run, which both speeds
up the polling use case, and makes the interrupt use case actually
work.

This problems exists whenever there is a state change which will not
cause an interrupt. Trigger the state machine in these cases,
e.g. phy_error().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Cc: Kyle Roeschley <kyle.roeschley@ni.com>
---

This should be applied to stable, but i've no idea what fixes: tag to
use. It could be phylib has been broken since interrupts were added?

 drivers/net/phy/phy.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index c6f66832a1a6..f424b867f73e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -608,6 +608,21 @@ void phy_start_machine(struct phy_device *phydev)
 }
 
 /**
+ * phy_trigger_machine - trigger the state machine to run
+ *
+ * @phydev: the phy_device struct
+ *
+ * Description: There has been a change in state which requires that the
+ *   state machine runs.
+ */
+
+static void phy_trigger_machine(struct phy_device *phydev)
+{
+	cancel_delayed_work_sync(&phydev->state_queue);
+	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
+}
+
+/**
  * phy_stop_machine - stop the PHY state machine tracking
  * @phydev: target phy_device struct
  *
@@ -639,6 +654,8 @@ static void phy_error(struct phy_device *phydev)
 	mutex_lock(&phydev->lock);
 	phydev->state = PHY_HALTED;
 	mutex_unlock(&phydev->lock);
+
+	phy_trigger_machine(phydev);
 }
 
 /**
@@ -800,8 +817,7 @@ void phy_change(struct work_struct *work)
 	}
 
 	/* reschedule state queue work to run as soon as possible */
-	cancel_delayed_work_sync(&phydev->state_queue);
-	queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, 0);
+	phy_trigger_machine(phydev);
 	return;
 
 ignore:
@@ -890,6 +906,8 @@ void phy_start(struct phy_device *phydev)
 	/* if phy was suspended, bring the physical link up again */
 	if (do_resume)
 		phy_resume(phydev);
+
+	phy_trigger_machine(phydev);
 }
 EXPORT_SYMBOL(phy_start);
 
-- 
2.9.3
