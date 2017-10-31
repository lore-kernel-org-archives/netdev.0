From: "Maciej S. Szmigiero" <mail@maciej.szmigiero.name>
Subject: [PATCH v2] net: phy: leds: Add support for "link" trigger
Date: Tue, 31 Oct 2017 12:56:24 +0100
Message-ID: <52ce25a6-8d6b-039d-ca08-90595eb9ee72@maciej.szmigiero.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps-vb.mhejs.net ([37.28.154.113]:44356 "EHLO vps-vb.mhejs.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751024AbdJaL41 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 07:56:27 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
Changes from v1: Don't keep the "link" trigger together with link speed
triggers in one array so we don't have to overload a SPEED_UNKNOWN speed
to mean the "link" trigger.

 drivers/net/phy/Kconfig            |  7 +++++--
 drivers/net/phy/phy_led_triggers.c | 43 +++++++++++++++++++++++++++++++++++---
 include/linux/phy.h                |  2 ++
 3 files changed, 47 insertions(+), 5 deletions(-)

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
index 94ca42e630bb..dba937f0c61c 100644
--- a/drivers/net/phy/phy_led_triggers.c
+++ b/drivers/net/phy/phy_led_triggers.c
@@ -46,6 +46,10 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 	}
 
 	if (plt != phy->last_triggered) {
+		if (!phy->last_triggered)
+			led_trigger_event(&phy->led_link_trigger->trigger,
+					  LED_FULL);
+
 		led_trigger_event(&phy->last_triggered->trigger, LED_OFF);
 		led_trigger_event(&plt->trigger, LED_FULL);
 		phy->last_triggered = plt;
@@ -56,11 +60,20 @@ void phy_led_trigger_change_speed(struct phy_device *phy)
 	if (phy->last_triggered) {
 		led_trigger_event(&phy->last_triggered->trigger,
 				  LED_OFF);
+		led_trigger_event(&phy->led_link_trigger->trigger,
+				  LED_OFF);
 		phy->last_triggered = NULL;
 	}
 }
 EXPORT_SYMBOL_GPL(phy_led_trigger_change_speed);
 
+static void phy_led_trigger_format_name(struct phy_device *phy, char *buf,
+					size_t size, char *suffix)
+{
+	snprintf(buf, size, PHY_ID_FMT ":%s",
+		 phy->mdio.bus->id, phy->mdio.addr, suffix);
+}
+
 static int phy_led_trigger_register(struct phy_device *phy,
 				    struct phy_led_trigger *plt,
 				    unsigned int speed)
@@ -77,8 +90,8 @@ static int phy_led_trigger_register(struct phy_device *phy,
 		snprintf(name_suffix, sizeof(name_suffix), "%dGbps",
 			 DIV_ROUND_CLOSEST(speed, 1000));
 
-	snprintf(plt->name, sizeof(plt->name), PHY_ID_FMT ":%s",
-		 phy->mdio.bus->id, phy->mdio.addr, name_suffix);
+	phy_led_trigger_format_name(phy, plt->name, sizeof(plt->name),
+				    name_suffix);
 	plt->trigger.name = plt->name;
 
 	return led_trigger_register(&plt->trigger);
@@ -99,13 +112,30 @@ int phy_led_triggers_register(struct phy_device *phy)
 	if (!phy->phy_num_led_triggers)
 		return 0;
 
+	phy->led_link_trigger = devm_kzalloc(&phy->mdio.dev,
+					     sizeof(*phy->led_link_trigger),
+					     GFP_KERNEL);
+	if (!phy->led_link_trigger) {
+		err = -ENOMEM;
+		goto out_clear;
+	}
+
+	phy_led_trigger_format_name(phy, phy->led_link_trigger->name,
+				    sizeof(phy->led_link_trigger->name),
+				    "link");
+	phy->led_link_trigger->trigger.name = phy->led_link_trigger->name;
+
+	err = led_trigger_register(&phy->led_link_trigger->trigger);
+	if (err)
+		goto out_free_link;
+
 	phy->phy_led_triggers = devm_kzalloc(&phy->mdio.dev,
 					    sizeof(struct phy_led_trigger) *
 						   phy->phy_num_led_triggers,
 					    GFP_KERNEL);
 	if (!phy->phy_led_triggers) {
 		err = -ENOMEM;
-		goto out_clear;
+		goto out_unreg_link;
 	}
 
 	for (i = 0; i < phy->phy_num_led_triggers; i++) {
@@ -123,6 +153,10 @@ int phy_led_triggers_register(struct phy_device *phy)
 	while (i--)
 		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
 	devm_kfree(&phy->mdio.dev, phy->phy_led_triggers);
+out_unreg_link:
+	phy_led_trigger_unregister(phy->led_link_trigger);
+out_free_link:
+	devm_kfree(&phy->mdio.dev, phy->led_link_trigger);
 out_clear:
 	phy->phy_num_led_triggers = 0;
 	return err;
@@ -135,5 +169,8 @@ void phy_led_triggers_unregister(struct phy_device *phy)
 
 	for (i = 0; i < phy->phy_num_led_triggers; i++)
 		phy_led_trigger_unregister(&phy->phy_led_triggers[i]);
+
+	if (phy->led_link_trigger)
+		phy_led_trigger_unregister(phy->led_link_trigger);
 }
 EXPORT_SYMBOL_GPL(phy_led_triggers_unregister);
diff --git a/include/linux/phy.h b/include/linux/phy.h
index d78cd01ea513..dc82a07cb4fd 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -451,6 +451,8 @@ struct phy_device {
 	struct phy_led_trigger *phy_led_triggers;
 	unsigned int phy_num_led_triggers;
 	struct phy_led_trigger *last_triggered;
+
+	struct phy_led_trigger *led_link_trigger;
 #endif
 
 	/*
