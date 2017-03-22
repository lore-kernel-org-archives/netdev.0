From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 1/2] net: phy: Fix PHY AN done state machine for interrupt driven PHYs
Date: Wed, 22 Mar 2017 13:02:03 +0200
Message-ID: <1490180524-28675-2-git-send-email-rogerq@ti.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <nsekhar@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>,
        "stable # v4 . 9+" <stable@vger.kernel.org>
To: <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490180524-28675-1-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

he ethernet link on an interrupt driven PHY was not coming up if the
ethernet cable was plugged before the ethernet interface was brought up.

The PHY state machine seems to be stuck from RUNNING to AN state
with no new interrupts from the PHY. So it doesn't know when the
PHY Auto-negotiation has been completed and doesn't transition to RUNNING
state with ANEG done thus netif_carrier_on() is never called.

NOTE: genphy_config_aneg() will not restart PHY Auto-negotiation of
advertisement parameters didn't change.

Fix this by scheduling the PHY state machine in phy_start_aneg().

Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
Cc: stable <stable@vger.kernel.org> # v4.9+
Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 drivers/net/phy/phy.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 1be69d8..49dedf8 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -630,6 +630,10 @@ int phy_start_aneg(struct phy_device *phydev)
 
 out_unlock:
 	mutex_unlock(&phydev->lock);
+	if (!err && phy_interrupt_is_valid(phydev))
+		queue_delayed_work(system_power_efficient_wq,
+				   &phydev->state_queue, HZ);
+
 	return err;
 }
 EXPORT_SYMBOL(phy_start_aneg);
-- 
2.7.4
