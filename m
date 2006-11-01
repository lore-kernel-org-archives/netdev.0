From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/18] e1000: fix VR powerdown code
Date: Wed, 01 Nov 2006 09:51:42 -0800
Message-ID: <20061101175142.2356.85600.stgit@gitlost.site>
References: <20061101175043.2356.13659.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:17424 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1946959AbWKARof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:44:35 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20061101175043.2356.13659.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On ich systems during PHY power down to D3, the voltage regulators
were left on.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_hw.c |    9 +++++----
 drivers/net/e1000/e1000_hw.h |    1 +
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index a0a3c7e..a45685c 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -3942,14 +3942,15 @@ e1000_phy_powerdown_workaround(struct e1
         E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
                         E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 
-        /* Write VR power-down enable */
+        /* Write VR power-down enable - bits 9:8 should be 10b */
         e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
-        e1000_write_phy_reg(hw, IGP3_VR_CTRL, phy_data |
-                            IGP3_VR_CTRL_MODE_SHUT);
+        phy_data |= (1 << 9);
+        phy_data &= ~(1 << 8);
+        e1000_write_phy_reg(hw, IGP3_VR_CTRL, phy_data);
 
         /* Read it back and test */
         e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
-        if ((phy_data & IGP3_VR_CTRL_MODE_SHUT) || retry)
+        if (((phy_data & IGP3_VR_CTRL_MODE_MASK) == IGP3_VR_CTRL_MODE_SHUT) || retry)
             break;
 
         /* Issue PHY reset and repeat at most one more time */
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index b32a0c3..31bea32 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -3173,6 +3173,7 @@ struct e1000_host_command_info {
 #define IGP3_VR_CTRL \
         PHY_REG(776, 18) /* Voltage regulator control register */
 #define IGP3_VR_CTRL_MODE_SHUT       0x0200 /* Enter powerdown, shutdown VRs */
+#define IGP3_VR_CTRL_MODE_MASK       0x0300 /* Shutdown VR Mask */
 
 #define IGP3_CAPABILITY \
         PHY_REG(776, 19) /* IGP3 Capability Register */



---
Auke Kok <auke-jan.h.kok@intel.com>
