From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: [PATCH] net: phy: leds: Add support for "link" trigger
Date: Sat, 28 Oct 2017 17:27:17 +0200
Message-ID: <65b5c84f-1222-bbc3-24f5-723e07bbb6ed@maciej.szmigiero.name>
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

Currently, we create a LED trigger for any link speed known to a PHY.
These triggers only fire when their exact link speed had been negotiated
(they aren't cumulative, that is, they don't fire for "their or any higher"
link speed).

What we are missing, however, is a trigger which will fire on any link
speed known to the PHY. Such trigger can then be used for implementing a
poor man's substitute of the "link" LED on boards that lack it.
Let's add it.

Signed-off-by: Maciej S. Szmigiero <mail@maciej.szmigiero.name>
---
 drivers/net/phy/Kconfig            |  7 +++++--
 drivers/net/phy/phy_led_triggers.c | 19 ++++++++++++++++---
 2 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cd931cf9dcc2..3bcc2107ad77 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -191,11 +191,14 @@ config LED_TRIGGER_PHY
 	  Adds support for a set of LED trigger events per-PHY.  Link
 	  state change will trigger the events, for consumption by an
 	  LED class driver.  There are triggers for each link speed currently
-	  supported by the phy, and are of the form:
+	  supported by the PHY and also a one common "link" trigger as a
+	  logical-or of all the link speed ones.
+	  All these triggers are named according to the following pattern:
 	      <mii bus id>:<phy>:<speed>
 
 	  Where speed is in the form:
-		<Speed in megabits>Mbps or <Speed in gigabits>Gbps
+		<Speed in megabits>Mbps OR <Speed in gigabits>Gbps OR link
+		for any speed known to the PHY.
 
 
 comment "MII PHY device drivers"
diff --git a/drivers/net/phy/phy_led_triggers.c b/drivers/net/phy/phy_led_triggers.c
index 94ca42e630bb..5b6f1876f514 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -20,7 +20,8 @@ static struct phy_led_trigger *phy_speed_to_led_trigger(struct phy_device *phy,
 {
 	unsigned int i;
 
-	for (i = 0; i < phy->phy_num_led_triggers; i++) {
+	/* the first (i = 0) trigger is for "any" speed */
+	for (i = 1; i < phy->phy_num_led_triggers; i++) {
 		if (phy->phy_led_triggers[i].speed == speed)
 			return &phy->phy_led_triggers[i];
 	}
@@ -46,6 +47,10 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 	}
 
 	if (plt != phy->last_triggered) {
+		if (!phy->last_triggered)
+			led_trigger_event(&phy->phy_led_triggers[0].trigger,
+					  LED_FULL);
+
 		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
 		led_trigger_event(&plt->trigger, LED_FULL);
 		phy->last_triggered = plt;
@@ -56,6 +61,8 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 	if (phy->last_triggered) {
 		led_trigger_event(&phy->last_triggered->trigger,
 				  LED_OFF);
+		led_trigger_event(&phy->phy_led_triggers[0].trigger,
+				  LED_OFF);
 		phy->last_triggered = NULL;
 	}
 }
@@ -69,7 +76,9 @@ static int phy_led_trigger_register(struct phy_device *phy,
 
 	plt->speed = speed;
 
-	if (speed < SPEED_1000)
+	if (speed == SPEED_UNKNOWN)
+		snprintf(name_suffix, sizeof(name_suffix), "link");
+	else if (speed < SPEED_1000)
 		snprintf(name_suffix, sizeof(name_suffix), "%dMbps", speed);
 	else if (speed == SPEED_2500)
 		snprintf(name_suffix, sizeof(name_suffix), "2.5Gbps");
@@ -99,6 +108,9 @@ int phy_led_triggers_register(struct phy_device *phy)
 	if (!phy->phy_num_led_triggers)
 		return 0;
 
+	/* include "any" speed */
+	phy->phy_num_led_triggers++;
+
 	phy->phy_led_triggers = devm_kzalloc(&phy->mdio.dev,
 					    sizeof(struct phy_led_trigger) *
 						   phy->phy_num_led_triggers,
@@ -110,7 +122,8 @@ int phy_led_triggers_register(struct phy_device *phy)
 
 	for (i = 0; i < phy->phy_num_led_triggers; i++) {
 		err = phy_led_trigger_register(phy, &phy->phy_led_triggers[i],
-					       speeds[i]);
+					       i == 0 ? SPEED_UNKNOWN :
+							speeds[i - 1]);
 		if (err)
 			goto out_unreg;
 	}
