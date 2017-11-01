From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: [PATCH v3 1/2] net: phy: leds: Refactor "no link" handler into a
 separate function
Date: Thu, 2 Nov 2017 00:48:45 +0100
Message-ID: <2c037f1c-ad1a-ebd9-2307-eb902cbb2c99@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, phy_led_trigger_change_speed() is handling a "no link" condition
like it was some kind of an error (using "goto" to a code at the function
end).

However, having no link at PHY is an ordinary operational state, so let's
handle it in an appropriately named separate function so it is more obvious
what the code is doing.

Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
---
 drivers/net/phy/phy_led_triggers.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index 94ca42e630bb..c736f29b3b2a 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -27,12 +27,20 @@ static struct phy_led_trigger *phy_speed_to_led_trigger(struct phy_device *phy,
 	return NULL;
 }
 
+static void phy_led_trigger_no_link(struct phy_device *phy)
+{
+	if (phy->last_triggered) {
+		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
+		phy->last_triggered = NULL;
+	}
+}
+
 void phy_led_trigger_change_speed(struct phy_device *phy)
 {
 	struct phy_led_trigger *plt;
 
 	if (!phy->link)
-		goto out_change_speed;
+		return phy_led_trigger_no_link(phy);
 
 	if (phy->speed == 0)
 		return;
@@ -42,7 +50,7 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 		netdev_alert(phy->attached_dev,
 			     "No phy led trigger registered for speed(%d)\n",
 			     phy->speed);
-		goto out_change_speed;
+		return phy_led_trigger_no_link(phy);
 	}
 
 	if (plt != phy->last_triggered) {
@@ -50,14 +58,6 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 		led_trigger_event(&plt->trigger, LED_FULL);
 		phy->last_triggered = plt;
 	}
-	return;
-
-out_change_speed:
-	if (phy->last_triggered) {
-		led_trigger_event(&phy->last_triggered->trigger,
-				  LED_OFF);
-		phy->last_triggered = NULL;
-	}
 }
 EXPORT_SYMBOL_GPL(phy_led_trigger_change_speed);
 
