From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 14/21] e1000: M88 PHY workaround
Date: Wed, 21 Jun 2006 22:20:37 -0700
Message-ID: <20060622052036.25497.23966.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:57608 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932806AbWFVFOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:39 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


M88 rev 2 PHY needs a longer downshift to function properly. This adds
a much longer downshift counter for this specific device.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c |   46 ++++++++++++++++++++++++++----------------
 drivers/net/e1000/e1000_hw.h |   11 ++++++++++
 2 files changed, 40 insertions(+), 17 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 1c5b184..37eb351 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -1565,28 +1565,40 @@ e1000_copper_link_mgp_setup(struct e1000
     phy_data &= ~M88E1000_PSCR_POLARITY_REVERSAL;
     if(hw->disable_polarity_correction == 1)
         phy_data |= M88E1000_PSCR_POLARITY_REVERSAL;
-        ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
-        if(ret_val)
-            return ret_val;
-
-    /* Force TX_CLK in the Extended PHY Specific Control Register
-     * to 25MHz clock.
-     */
-    ret_val = e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
-    if(ret_val)
+    ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_data);
+    if (ret_val)
         return ret_val;
 
-    phy_data |= M88E1000_EPSCR_TX_CLK_25;
-
     if (hw->phy_revision < M88E1011_I_REV_4) {
-        /* Configure Master and Slave downshift values */
-        phy_data &= ~(M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK |
+        /* Force TX_CLK in the Extended PHY Specific Control Register
+         * to 25MHz clock.
+         */
+        ret_val = e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_data);
+        if (ret_val)
+            return ret_val;
+
+        phy_data |= M88E1000_EPSCR_TX_CLK_25;
+
+        if ((hw->phy_revision == E1000_REVISION_2) &&
+            (hw->phy_id == M88E1111_I_PHY_ID)) {
+            /* Vidalia Phy, set the downshift counter to 5x */
+            phy_data &= ~(M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK);
+            phy_data |= M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X;
+            ret_val = e1000_write_phy_reg(hw,
+                                        M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
+            if (ret_val)
+                return ret_val;
+        } else {
+            /* Configure Master and Slave downshift values */
+            phy_data &= ~(M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK |
                               M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK);
-        phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
+            phy_data |= (M88E1000_EPSCR_MASTER_DOWNSHIFT_1X |
                              M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X);
-        ret_val = e1000_write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
-        if(ret_val)
-            return ret_val;
+            ret_val = e1000_write_phy_reg(hw,
+                                        M88E1000_EXT_PHY_SPEC_CTRL, phy_data);
+            if (ret_val)
+               return ret_val;
+        }
     }
 
     /* SW Reset the PHY so all changes take effect */
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 376a2ef..bfbc7d8 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -2765,6 +2765,17 @@ struct e1000_host_command_info {
 #define M88E1000_EPSCR_TX_CLK_25      0x0070 /* 25  MHz TX_CLK */
 #define M88E1000_EPSCR_TX_CLK_0       0x0000 /* NO  TX_CLK */
 
+/* M88EC018 Rev 2 specific DownShift settings */
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_1X    0x0000
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_2X    0x0200
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_3X    0x0400
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_4X    0x0600
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_6X    0x0A00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_7X    0x0C00
+#define M88EC018_EPSCR_DOWNSHIFT_COUNTER_8X    0x0E00
+
 /* IGP01E1000 Specific Port Config Register - R/W */
 #define IGP01E1000_PSCFR_AUTO_MDIX_PAR_DETECT  0x0010
 #define IGP01E1000_PSCFR_PRE_EN                0x0020



--
Auke Kok <auke-jan.h.kok@intel.com>
