From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Wed, 19 Apr 2017 16:46:44 +0300
Message-ID: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The problem I fix related to SMSC LAN8710/LAN8720 PHY handled using
interrupts. During power-up cycle the PHY do auto-negotiation, generate
interrupt and set BMSR_ANEGCOMPLETE flag. Interrupt is handled by PHY
state machine but doesn't update link because PHY is in PHY_READY state.
After some time MAC bring up and connect with PHY. It start PHY using
phy_start(). During startup PHY change state to PHY_AN but doesn't
set BMCR_ANRESTART flag due to genphy_config_aneg() doesn't update MII_BMCR
because there no new to advertising. As a result, state machine wait for
interrupt from PHY and nether get "link is up". Because BMSR_ANEGCOMPLETE
already set the patch schedule check link without waiting interrupt.
In case genphy_config_aneg() update MII_BMCR and set BMCR_ANRESTART
flag, BMSR_ANEGCOMPLETE will be cleared and state machine will continue
on auto-negotiation interrupt.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
---
 drivers/net/phy/phy.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7cc1b7d..da8f03d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1169,6 +1169,18 @@ void phy_state_machine(struct work_struct *work)
 	if (phydev->irq == PHY_POLL)
 		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
 				   PHY_STATE_TIME * HZ);
+
+	/* Re-schedule a PHY state machine to check PHY status because
+	 * negotiation already done and aneg interrupt may not be generated.
+	 */
+	if (needs_aneg && (phydev->irq > 0) && (phydev->state == PHY_AN)) {
+		err = phy_aneg_done(phydev);
+		if (err > 0)
+			queue_delayed_work(system_power_efficient_wq,
+					   &phydev->state_queue, 0);
+		if (err < 0)
+			phy_error(phydev);
+	}
 }
 
 /**
-- 
1.7.9.5
