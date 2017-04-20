From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: [PATCH v1] net: phy: fix auto-negotiation stall due to unavailable interrupt
Date: Thu, 20 Apr 2017 14:00:04 +0300
Message-ID: <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com>
Cc: Alexander Kochetkov <al.kochet@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Roger Quadros <rogerq@ti.com>,
        Madalin Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492686004-30527-1-git-send-email-al.kochet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Ethernet link on an interrupt driven PHY was not coming up if the Ethernet
cable was plugged before the Ethernet interface was brought up.

The patch trigger PHY state machine to update link state if PHY was requested to
do auto-negotiation and auto-negotiation complete flag already set.

During power-up cycle the PHY do auto-negotiation, generate interrupt and set
auto-negotiation complete flag. Interrupt is handled by PHY state machine but
doesn't update link state because PHY is in PHY_READY state. After some time
MAC bring up, start and request PHY to do auto-negotiation. If there are no new
settings to advertise genphy_config_aneg() doesn't start PHY auto-negotiation.
PHY continue to stay in auto-negotiation complete state and doesn't fire
interrupt. At the same time PHY state machine expect that PHY started
auto-negotiation and is waiting for interrupt from PHY and it won't get it.

Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
Cc: stable <stable@vger.kernel.org> # v4.9+
---
 drivers/net/phy/phy.c |   40 ++++++++++++++++++++++++++++++++++++----
 include/linux/phy.h   |    1 +
 2 files changed, 37 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7cc1b7d..2d9975b 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -591,16 +591,18 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd)
 EXPORT_SYMBOL(phy_mii_ioctl);
 
 /**
- * phy_start_aneg - start auto-negotiation for this PHY device
+ * phy_start_aneg_priv - start auto-negotiation for this PHY device
  * @phydev: the phy_device struct
+ * @sync: indicate whether we should wait for the workqueue cancelation
  *
  * Description: Sanitizes the settings (if we're not autonegotiating
  *   them), and then calls the driver's config_aneg function.
  *   If the PHYCONTROL Layer is operating, we change the state to
  *   reflect the beginning of Auto-negotiation or forcing.
  */
-int phy_start_aneg(struct phy_device *phydev)
+static int phy_start_aneg_priv(struct phy_device *phydev, bool sync)
 {
+	bool trigger = 0;
 	int err;
 
 	mutex_lock(&phydev->lock);
@@ -625,10 +627,40 @@ int phy_start_aneg(struct phy_device *phydev)
 		}
 	}
 
+	/* Re-schedule a PHY state machine to check PHY status because
+	 * negotiation may already be done and aneg interrupt may not be
+	 * generated.
+	 */
+	if (phy_interrupt_is_valid(phydev) && (phydev->state == PHY_AN)) {
+		err = phy_aneg_done(phydev);
+		if (err > 0) {
+			trigger = true;
+			err = 0;
+		}
+	}
+
 out_unlock:
 	mutex_unlock(&phydev->lock);
+
+	if (trigger)
+		phy_trigger_machine(phydev, sync);
+
 	return err;
 }
+
+/**
+ * phy_start_aneg - start auto-negotiation for this PHY device
+ * @phydev: the phy_device struct
+ *
+ * Description: Sanitizes the settings (if we're not autonegotiating
+ *   them), and then calls the driver's config_aneg function.
+ *   If the PHYCONTROL Layer is operating, we change the state to
+ *   reflect the beginning of Auto-negotiation or forcing.
+ */
+int phy_start_aneg(struct phy_device *phydev)
+{
+	return phy_start_aneg_priv(phydev, true);
+}
 EXPORT_SYMBOL(phy_start_aneg);
 
 /**
@@ -656,7 +688,7 @@ void phy_start_machine(struct phy_device *phydev)
  *   state machine runs.
  */
 
-static void phy_trigger_machine(struct phy_device *phydev, bool sync)
+void phy_trigger_machine(struct phy_device *phydev, bool sync)
 {
 	if (sync)
 		cancel_delayed_work_sync(&phydev->state_queue);
@@ -1151,7 +1183,7 @@ void phy_state_machine(struct work_struct *work)
 	mutex_unlock(&phydev->lock);
 
 	if (needs_aneg)
-		err = phy_start_aneg(phydev);
+		err = phy_start_aneg_priv(phydev, false);
 	else if (do_suspend)
 		phy_suspend(phydev);
 
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 7fc1105..b19ae66 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -840,6 +840,7 @@ int phy_drivers_register(struct phy_driver *new_driver, int n,
 void phy_mac_interrupt(struct phy_device *phydev, int new_link);
 void phy_start_machine(struct phy_device *phydev);
 void phy_stop_machine(struct phy_device *phydev);
+void phy_trigger_machine(struct phy_device *phydev, bool sync);
 int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
 int phy_ethtool_ksettings_get(struct phy_device *phydev,
-- 
1.7.9.5
