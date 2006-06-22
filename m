From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/21] e1000: add smart power down code
Date: Wed, 21 Jun 2006 22:20:18 -0700
Message-ID: <20060622052018.25497.43884.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:47368 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932799AbWFVFOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:20 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Smart Power Down is a power saving feature in newer e1000 hardware. We
disable it because it causes time to link to be long, but make it a
user choice.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h       |    1 +
 drivers/net/e1000/e1000_main.c  |   15 +++++++++++++++
 drivers/net/e1000/e1000_param.c |   25 +++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 2b96ad0..dbdaa33 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -338,6 +338,7 @@ struct e1000_adapter {
 #ifdef NETIF_F_TSO
 	boolean_t tso_force;
 #endif
+	boolean_t smart_power_down;	/* phy smart power down */
 	unsigned long flags;
 };
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 76e36a4..ea18f30 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -607,6 +607,21 @@ e1000_reset(struct e1000_adapter *adapte
 
 	e1000_reset_adaptive(&adapter->hw);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+
+	if (!adapter->smart_power_down &&
+	    (adapter->hw.mac_type == e1000_82571 ||
+	     adapter->hw.mac_type == e1000_82572)) {
+		uint16_t phy_data = 0;
+		/* speed up time to link by disabling smart power down, ignore
+		 * the return value of this function because there is nothing
+		 * different we would do if it failed */
+		e1000_read_phy_reg(&adapter->hw, IGP02E1000_PHY_POWER_MGMT,
+		                   &phy_data);
+		phy_data &= ~IGP02E1000_PM_SPD;
+		e1000_write_phy_reg(&adapter->hw, IGP02E1000_PHY_POWER_MGMT,
+		                    phy_data);
+	}
+
 	if (adapter->en_mng_pt) {
 		manc = E1000_READ_REG(&adapter->hw, MANC);
 		manc |= (E1000_MANC_ARP_EN | E1000_MANC_EN_MNG2HOST);
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e55f896..a8d9295 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -183,6 +183,15 @@ E1000_PARAM(RxAbsIntDelay, "Receive Abso
 
 E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
 
+/* Enable Smart Power Down of the PHY
+ *
+ * Valid Range: 0, 1
+ *
+ * Default Value: 0 (disabled)
+ */
+
+E1000_PARAM(SmartPowerDownEnable, "Enable PHY smart power down");
+
 #define AUTONEG_ADV_DEFAULT  0x2F
 #define AUTONEG_ADV_MASK     0x2F
 #define FLOW_CONTROL_DEFAULT FLOW_CONTROL_FULL
@@ -494,6 +503,22 @@ e1000_check_options(struct e1000_adapter
 			adapter->itr = opt.def;
 		}
 	}
+	{ /* Smart Power Down */
+		struct e1000_option opt = {
+			.type = enable_option,
+			.name = "PHY Smart Power Down",
+			.err  = "defaulting to Disabled",
+			.def  = OPTION_DISABLED
+		};
+
+		if (num_SmartPowerDownEnable > bd) {
+			int spd = SmartPowerDownEnable[bd];
+			e1000_validate_option(&spd, &opt, adapter);
+			adapter->smart_power_down = spd;
+		} else {
+			adapter->smart_power_down = opt.def;
+		}
+	}
 
 	switch (adapter->hw.media_type) {
 	case e1000_media_type_fiber:



--
Auke Kok <auke-jan.h.kok@intel.com>
