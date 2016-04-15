From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Subject: [PATCH] net: phy: Ensure the state machine is called when phy is UP
Date: Fri, 15 Apr 2016 21:56:12 +0200
Message-ID: <1460750172-7796-1-git-send-email-alexandre.belloni@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit d5c3d84657db ("net: phy: Avoid polling PHY with
PHY_IGNORE_INTERRUPTS") removed the last polling done on the phy. Since
then, the last actual poll done on the phy happens PHY_STATE_TIME seconds
(that is actually one second) after registering the phy. If the interface
is not UP by that time, any previous IRQ indicating the link is up is
ignored. Moreover, nothing will start the autonegociation so the phy will
simply change from READY to UP and never actually go to RUNNING.

The one second delay explains why the issue is not seen when booting from
NFS or when the interface is configured at boot time.

To solve that, ensure the state machine is called as soon as the state
changes from READY to UP.

Fixes: d5c3d84657db ("net: phy: Avoid polling PHY with PHY_IGNORE_INTERRUPTS")
Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>
---
 drivers/net/phy/phy.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5590b9c182c9..25f6bfd1c8fd 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -787,6 +787,9 @@ void phy_start(struct phy_device *phydev)
 		break;
 	case PHY_READY:
 		phydev->state = PHY_UP;
+		cancel_delayed_work_sync(&phydev->state_queue);
+		queue_delayed_work(system_power_efficient_wq,
+				   &phydev->state_queue, 0);
 		break;
 	case PHY_HALTED:
 		/* make sure interrupts are re-enabled for the PHY */
-- 
2.8.0.rc3
