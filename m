From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH 1/3] net: phy: Add ethernet PHY LED triggers
Date: Wed, 23 Mar 2016 18:51:38 +0100
Message-ID: <1458755500-15571-2-git-send-email-vishalthanki@gmail.com>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, ujhelyi.m@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:33513 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436AbcCWRvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:51:47 -0400
Received: by mail-wm0-f50.google.com with SMTP id l68so244002445wml.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:51:46 -0700 (PDT)
In-Reply-To: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the LED triggers for ethernet PHY link and activity
status. The triggers are set mainly based on the
PHY state machine.

Signed-off-by: Vishal Thanki <vishalthanki@gmail.com>
---
 drivers/net/phy/Kconfig      |  7 +++++
 drivers/net/phy/Makefile     |  1 +
 drivers/net/phy/phy.c        | 20 +++++++++++--
 drivers/net/phy/phy_device.c |  4 +++
 drivers/net/phy/phy_led.c    | 70 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy_led.h    | 37 +++++++++++++++++++++++
 include/linux/leds.h         |  1 +
 include/linux/phy.h          |  6 ++++
 8 files changed, 144 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/phy/phy_led.c
 create mode 100644 drivers/net/phy/phy_led.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6dad9a9..15712da 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -271,6 +271,13 @@ config MDIO_BCM_IPROC
 	  This module provides a driver for the MDIO busses found in the
 	  Broadcom iProc SoC's.
 
+config ETH_PHY_LED
+	bool "Ethernet PHY LED trigger support (Experimental)"
+	depends on LEDS_TRIGGERS
+	help
+	  This feature enables the Ethernet PHY LED triggers for PHY link
+	  and data transfer activities.
+
 endif # PHYLIB
 
 config MICREL_KS8995MA
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcdbb92..76ebd83 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -44,3 +44,4 @@ obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
 obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
 obj-$(CONFIG_MDIO_BCM_IPROC)	+= mdio-bcm-iproc.o
+obj-$(CONFIG_ETH_PHY_LED)	+= phy_led.o
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 5590b9c..e422ff6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -35,6 +35,7 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/atomic.h>
+#include "phy_led.h"
 
 #include <asm/irq.h>
 
@@ -831,15 +832,15 @@ void phy_state_machine(struct work_struct *work)
 
 	switch (phydev->state) {
 	case PHY_DOWN:
+		phy_trig_led_link(phydev, 0);
 	case PHY_STARTING:
 	case PHY_READY:
 	case PHY_PENDING:
 		break;
 	case PHY_UP:
 		needs_aneg = true;
-
 		phydev->link_timeout = PHY_AN_TIMEOUT;
-
+		phy_trig_led_link(phydev, 1);
 		break;
 	case PHY_AN:
 		err = phy_read_status(phydev);
@@ -849,6 +850,7 @@ void phy_state_machine(struct work_struct *work)
 		/* If the link is down, give up on negotiation for now */
 		if (!phydev->link) {
 			phydev->state = PHY_NOLINK;
+			phy_trig_led_link(phydev, 0);
 			netif_carrier_off(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
 			break;
@@ -862,6 +864,7 @@ void phy_state_machine(struct work_struct *work)
 		/* If AN is done, we're running */
 		if (err > 0) {
 			phydev->state = PHY_RUNNING;
+			phy_trig_led_act(phydev);
 			netif_carrier_on(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
 
@@ -889,6 +892,7 @@ void phy_state_machine(struct work_struct *work)
 				}
 			}
 			phydev->state = PHY_RUNNING;
+			phy_trig_led_act(phydev);
 			netif_carrier_on(phydev->attached_dev);
 			phydev->adjust_link(phydev->attached_dev);
 		}
@@ -900,6 +904,8 @@ void phy_state_machine(struct work_struct *work)
 
 		if (phydev->link) {
 			phydev->state = PHY_RUNNING;
+			phy_trig_led_act(phydev);
+			phy_trig_led_link(phydev, 1);
 			netif_carrier_on(phydev->attached_dev);
 		} else {
 			if (0 == phydev->link_timeout--)
@@ -929,9 +935,12 @@ void phy_state_machine(struct work_struct *work)
 
 		if (phydev->link) {
 			phydev->state = PHY_RUNNING;
+			phy_trig_led_act(phydev);
+			phy_trig_led_link(phydev, 1);
 			netif_carrier_on(phydev->attached_dev);
 		} else {
 			phydev->state = PHY_NOLINK;
+			phy_trig_led_link(phydev, 0);
 			netif_carrier_off(phydev->attached_dev);
 		}
 
@@ -948,6 +957,7 @@ void phy_state_machine(struct work_struct *work)
 			phydev->adjust_link(phydev->attached_dev);
 			do_suspend = true;
 		}
+		led_trigger_event(phydev->phy_act, LED_OFF);
 		break;
 	case PHY_RESUMING:
 		if (AUTONEG_ENABLE == phydev->autoneg) {
@@ -965,9 +975,12 @@ void phy_state_machine(struct work_struct *work)
 
 				if (phydev->link) {
 					phydev->state = PHY_RUNNING;
+					phy_trig_led_link(phydev, 1);
+					phy_trig_led_act(phydev);
 					netif_carrier_on(phydev->attached_dev);
 				} else	{
 					phydev->state = PHY_NOLINK;
+					phy_trig_led_link(phydev, 0);
 				}
 				phydev->adjust_link(phydev->attached_dev);
 			} else {
@@ -981,9 +994,12 @@ void phy_state_machine(struct work_struct *work)
 
 			if (phydev->link) {
 				phydev->state = PHY_RUNNING;
+				phy_trig_led_link(phydev, 1);
+				phy_trig_led_act(phydev);
 				netif_carrier_on(phydev->attached_dev);
 			} else	{
 				phydev->state = PHY_NOLINK;
+				phy_trig_led_link(phydev, 0);
 			}
 			phydev->adjust_link(phydev->attached_dev);
 		}
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e551f3a..fafcc3c 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -34,6 +34,7 @@
 #include <linux/io.h>
 #include <linux/uaccess.h>
 #include <linux/of.h>
+#include "phy_led.h"
 
 #include <asm/irq.h>
 
@@ -1592,6 +1593,8 @@ static int phy_probe(struct device *dev)
 	of_set_phy_supported(phydev);
 	phydev->advertising = phydev->supported;
 
+	phy_led_init(phydev);
+
 	/* Set the state to READY by default */
 	phydev->state = PHY_READY;
 
@@ -1608,6 +1611,7 @@ static int phy_remove(struct device *dev)
 	struct phy_device *phydev = to_phy_device(dev);
 
 	mutex_lock(&phydev->lock);
+	phy_led_cleanup(phydev);
 	phydev->state = PHY_DOWN;
 	mutex_unlock(&phydev->lock);
 
diff --git a/drivers/net/phy/phy_led.c b/drivers/net/phy/phy_led.c
new file mode 100644
index 0000000..240355a
--- /dev/null
+++ b/drivers/net/phy/phy_led.c
@@ -0,0 +1,70 @@
+#include <linux/phy.h>
+#include <linux/leds.h>
+
+static void phy_link_trig_activate(struct led_classdev *led)
+{
+	struct phy_device *phydev = led->trigger->data;
+	enum led_brightness value = LED_OFF;
+
+	if (phydev && phydev->state != PHY_DOWN)
+		value = LED_FULL;
+	led_set_brightness(led, value);
+}
+
+static void phy_act_trig_activate(struct led_classdev *led)
+{
+	struct phy_device *phydev = led->trigger->data;
+	unsigned long on = 0, off = 0;
+
+	if (phydev && (phydev->state == PHY_RUNNING ||
+		       phydev->state == PHY_CHANGELINK))
+		led_blink_set(led, &on, &off);
+}
+
+void phy_led_init(struct phy_device *phydev)
+{
+	phydev->phy_link = kzalloc(sizeof(*phydev->phy_link), GFP_KERNEL);
+	if (!phydev->phy_link)
+		return;
+
+	snprintf(phydev->phy_link_name, sizeof(phydev->phy_link_name),
+		 "%x-eth-phy-link", phydev->drv->phy_id);
+	phydev->phy_link->name = phydev->phy_link_name;
+	if (led_trigger_register(phydev->phy_link)) {
+		kfree(phydev->phy_link);
+		phydev->phy_link = NULL;
+	}
+	phydev->phy_link->data = phydev;
+	phydev->phy_link->activate = phy_link_trig_activate;
+
+	phydev->phy_act = kzalloc(sizeof(*phydev->phy_act), GFP_KERNEL);
+	if (!phydev->phy_act) {
+		led_trigger_unregister(phydev->phy_link);
+		kfree(phydev->phy_link);
+		return;
+	}
+	phydev->phy_act->data = phydev;
+	phydev->phy_act->activate = phy_act_trig_activate;
+
+	snprintf(phydev->phy_act_name, sizeof(phydev->phy_act_name),
+		 "%x-eth-phy-activity", phydev->drv->phy_id);
+	phydev->phy_act->name = phydev->phy_act_name;
+	if (led_trigger_register(phydev->phy_act)) {
+		kfree(phydev->phy_act);
+		phydev->phy_act = NULL;
+		return;
+	}
+}
+
+void phy_led_cleanup(struct phy_device *phydev)
+{
+	if (phydev->phy_link) {
+		led_trigger_unregister(phydev->phy_link);
+		kfree(phydev->phy_link);
+	}
+	if (phydev->phy_act) {
+		led_trigger_unregister(phydev->phy_act);
+		kfree(phydev->phy_act);
+	}
+}
+
diff --git a/drivers/net/phy/phy_led.h b/drivers/net/phy/phy_led.h
new file mode 100644
index 0000000..ff5bd98
--- /dev/null
+++ b/drivers/net/phy/phy_led.h
@@ -0,0 +1,37 @@
+#include <linux/leds.h>
+
+#ifdef CONFIG_ETH_PHY_LED
+static inline void phy_trig_led_act(struct phy_device *phydev)
+{
+	unsigned long on = 0, off = 0;
+
+	led_trigger_blink(phydev->phy_act, &on, &off);
+}
+
+static inline void phy_trig_led_link(struct phy_device *phydev, int on)
+{
+	enum led_brightness value = (on) ? LED_FULL : LED_OFF;
+
+	led_trigger_event(phydev->phy_link, value);
+}
+
+void phy_led_init(struct phy_device *phydev);
+void phy_led_cleanup(struct phy_device *phydev);
+#else
+static inline void phy_trig_led_act(struct phy_device *phydev)
+{
+}
+
+static inline void phy_trig_led_link(struct phy_device *phydev, int on)
+{
+}
+
+static inline void phy_led_init(struct phy_device *phydev)
+{
+}
+
+static inline void phy_led_cleanup(struct phy_device *phydev)
+{
+}
+#endif
+
diff --git a/include/linux/leds.h b/include/linux/leds.h
index f203a8f..11ec574 100644
--- a/include/linux/leds.h
+++ b/include/linux/leds.h
@@ -233,6 +233,7 @@ struct led_trigger {
 	const char	 *name;
 	void		(*activate)(struct led_classdev *led_cdev);
 	void		(*deactivate)(struct led_classdev *led_cdev);
+	void *data;
 
 	/* LEDs under control by this trigger (for simple triggers) */
 	rwlock_t	  leddev_list_lock;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 2abd791..94fee77 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -25,6 +25,7 @@
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/mod_devicetable.h>
+#include <linux/leds.h>
 
 #include <linux/atomic.h>
 
@@ -60,6 +61,7 @@
 #define PHY_HAS_INTERRUPT	0x00000001
 #define PHY_HAS_MAGICANEG	0x00000002
 #define PHY_IS_INTERNAL		0x00000004
+#define PHY_HAS_LED_CTRL	0x00000008
 #define MDIO_DEVICE_IS_PHY	0x80000000
 
 /* Interface Mode definitions */
@@ -424,6 +426,10 @@ struct phy_device {
 	u8 mdix;
 
 	void (*adjust_link)(struct net_device *dev);
+
+	struct led_trigger *phy_link, *phy_act;
+	char phy_link_name[32], phy_act_name[32];
+
 };
 #define to_phy_device(d) container_of(to_mdio_device(d), \
 				      struct phy_device, mdio)
-- 
2.4.3
