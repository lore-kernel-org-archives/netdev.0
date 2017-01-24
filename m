From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH 2/2] net: phy: leds: Fix truncated LED trigger names
Date: Tue, 24 Jan 2017 16:41:10 +0100
Message-ID: <1485272470-3497-3-git-send-email-geert+renesas@glider.be>
References: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
Cc: Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485272470-3497-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 4567d686f5c6d955 ("phy: increase size of MII_BUS_ID_SIZE and
bus_id") increased the size of MII bus IDs, but forgot to update the
private definition in <linux/phy_led_triggers.h>.
This may cause:
  1. Truncation of LED trigger names,
  2. Duplicate LED trigger names,
  3. Failures registering LED triggers,
  4. Crashes due to bad error handling in the LED trigger failure path.

To fix this, and prevent the definitions going out of sync again in the
future, let the PHY LED trigger code use the existing MII_BUS_ID_SIZE
definition. Note that this requires moving the #include down, after the
definition of MII_BUS_ID_SIZE.

Example:
  - Before I had triggers "ee700000.etherne:01:100Mbps" and
    "ee700000.etherne:01:10Mbps",
  - After the increase of MII_BUS_ID_SIZE, both became
    "ee700000.ethernet-ffffffff:01:" => FAIL,
  - Now, the triggers are "ee700000.ethernet-ffffffff:01:100Mbps" and
    "ee700000.ethernet-ffffffff:01:10Mbps", which are unique again.

Fixes: 4567d686f5c6d955 ("phy: increase size of MII_BUS_ID_SIZE and bus_id")
Fixes: 2e0bc452f4721520 ("net: phy: leds: add support for led triggers on phy link state change")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 include/linux/phy.h              | 3 ++-
 include/linux/phy_led_triggers.h | 3 +--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 5c9d2529685fe215..f6ab919528ab3627 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,7 +25,6 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
-#include <linux/phy_led_triggers.h>
 
 #include <linux/atomic.h>
 
@@ -339,6 +338,8 @@ struct phy_c45_device_ids {
 	u32 device_ids[8];
 };
 
+#include <linux/phy_led_triggers.h>
+
 /* phy_device: An instance of a PHY
  *
  * drv: Pointer to the driver for this PHY instance
diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
index a2daea0a37d2ae14..69dffb4fc5a294e9 100644
--- a/include/linux/phy_led_triggers.h
+++ b/include/linux/phy_led_triggers.h
@@ -20,9 +20,8 @@
 #include <linux/leds.h>
 
 #define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	10
-#define PHY_MII_BUS_ID_SIZE	(20 - 3)
 
-#define PHY_LINK_LED_TRIGGER_NAME_SIZE (PHY_MII_BUS_ID_SIZE + \
+#define PHY_LINK_LED_TRIGGER_NAME_SIZE (MII_BUS_ID_SIZE + \
 				       FIELD_SIZEOF(struct mdio_device, addr)+\
 				       PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE)
 
-- 
1.9.1
