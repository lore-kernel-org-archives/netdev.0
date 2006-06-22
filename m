From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 12/21] e1000: fix adapter led blinking inconsistency
Date: Wed, 21 Jun 2006 22:20:32 -0700
Message-ID: <20060622052032.25497.4540.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:55048 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932806AbWFVFOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:34 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Several e1000 adapters were not blinking correctly or inconsistently. This
patch cleans this up and makes them all behave the same as far as possible.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   15 +--------------
 drivers/net/e1000/e1000_hw.c      |   38 +++++++++++++++++++++++++++++++++++++
 drivers/net/e1000/e1000_hw.h      |    1 +
 3 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index cf5c5f4..0609155 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1786,21 +1786,8 @@ e1000_phys_id(struct net_device *netdev,
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
 		del_timer_sync(&adapter->blink_timer);
-	} else if (adapter->hw.mac_type < e1000_82573) {
-		E1000_WRITE_REG(&adapter->hw, LEDCTL,
-			(E1000_LEDCTL_LED2_BLINK_RATE |
-			 E1000_LEDCTL_LED0_BLINK | E1000_LEDCTL_LED2_BLINK |
-			 (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED2_MODE_SHIFT) |
-			 (E1000_LEDCTL_MODE_LINK_ACTIVITY << E1000_LEDCTL_LED0_MODE_SHIFT) |
-			 (E1000_LEDCTL_MODE_LED_OFF << E1000_LEDCTL_LED1_MODE_SHIFT)));
-		msleep_interruptible(data * 1000);
 	} else {
-		E1000_WRITE_REG(&adapter->hw, LEDCTL,
-			(E1000_LEDCTL_LED2_BLINK_RATE |
-			 E1000_LEDCTL_LED1_BLINK | E1000_LEDCTL_LED2_BLINK |
-			 (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED2_MODE_SHIFT) |
-			 (E1000_LEDCTL_MODE_LINK_ACTIVITY << E1000_LEDCTL_LED1_MODE_SHIFT) |
-			 (E1000_LEDCTL_MODE_LED_OFF << E1000_LEDCTL_LED0_MODE_SHIFT)));
+		e1000_blink_led_start(&adapter->hw);
 		msleep_interruptible(data * 1000);
 	}
 
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 749d621..1c5b184 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -5537,6 +5537,44 @@ e1000_setup_led(struct e1000_hw *hw)
 }
 
 /******************************************************************************
+ * Used on 82571 and later Si that has LED blink bits.
+ * Callers must use their own timer and should have already called
+ * e1000_id_led_init()
+ * Call e1000_cleanup led() to stop blinking
+ *
+ * hw - Struct containing variables accessed by shared code
+ *****************************************************************************/
+int32_t
+e1000_blink_led_start(struct e1000_hw *hw)
+{
+    int16_t  i;
+    uint32_t ledctl_blink = 0;
+
+    DEBUGFUNC("e1000_id_led_blink_on");
+
+    if (hw->mac_type < e1000_82571) {
+        /* Nothing to do */
+        return E1000_SUCCESS;
+    }
+    if (hw->media_type == e1000_media_type_fiber) {
+        /* always blink LED0 for PCI-E fiber */
+        ledctl_blink = E1000_LEDCTL_LED0_BLINK |
+                     (E1000_LEDCTL_MODE_LED_ON << E1000_LEDCTL_LED0_MODE_SHIFT);
+    } else {
+        /* set the blink bit for each LED that's "on" (0x0E) in ledctl_mode2 */
+        ledctl_blink = hw->ledctl_mode2;
+        for (i=0; i < 4; i++)
+            if (((hw->ledctl_mode2 >> (i * 8)) & 0xFF) ==
+                E1000_LEDCTL_MODE_LED_ON)
+                ledctl_blink |= (E1000_LEDCTL_LED0_BLINK << (i * 8));
+    }
+
+    E1000_WRITE_REG(hw, LEDCTL, ledctl_blink);
+
+    return E1000_SUCCESS;
+}
+
+/******************************************************************************
  * Restores the saved state of the SW controlable LED.
  *
  * hw - Struct containing variables accessed by shared code
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 467c9ed..941b47d 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -401,6 +401,7 @@ int32_t e1000_setup_led(struct e1000_hw 
 int32_t e1000_cleanup_led(struct e1000_hw *hw);
 int32_t e1000_led_on(struct e1000_hw *hw);
 int32_t e1000_led_off(struct e1000_hw *hw);
+int32_t e1000_blink_led_start(struct e1000_hw *hw);
 
 /* Adaptive IFS Functions */
 



--
Auke Kok <auke-jan.h.kok@intel.com>
