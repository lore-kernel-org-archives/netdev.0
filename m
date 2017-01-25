From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 3/3] net: phy: leds: Fix truncated LED trigger names
Date: Wed, 25 Jan 2017 11:39:50 +0100
Message-ID: <1485340790-10785-4-git-send-email-geert+renesas@glider.be>
References: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
Cc: Andrew Lunn <andrew@lunn.ch>,
        =?UTF-8?q?Magnus=20=C3=96berg?= <magnus.oberg@westermo.se>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Zach Brown <zach.brown@ni.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485340790-10785-1-git-send-email-geert+renesas@glider.be>
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
definition.

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
v2:
  - Drop moving the include of <linux/phy_led_triggers.h>, as
    <linux/phy.h> no longer includes it,
  - #include <linux/phy.h> from <linux/phy_led_triggers.h>.
---
 include/linux/phy_led_triggers.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/phy_led_triggers.h b/include/linux/phy_led_triggers.h
index a2daea0a37d2ae14..b37b05bfd1a6dd8a 100644
--- a/include/linux/phy_led_triggers.h
+++ b/include/linux/phy_led_triggers.h
@@ -18,11 +18,11 @@
 #ifdef CONFIG_LED_TRIGGER_PHY
 
 #include <linux/leds.h>
+#include <linux/phy.h>
 
 #define PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE	10
-#define PHY_MII_BUS_ID_SIZE	(20 - 3)
 
-#define PHY_LINK_LED_TRIGGER_NAME_SIZE (PHY_MII_BUS_ID_SIZE + \
+#define PHY_LINK_LED_TRIGGER_NAME_SIZE (MII_BUS_ID_SIZE + \
 				       FIELD_SIZEOF(struct mdio_device, addr)+\
 				       PHY_LED_TRIGGER_SPEED_SUFFIX_SIZE)
 
-- 
1.9.1
