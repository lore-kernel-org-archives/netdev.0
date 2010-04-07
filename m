From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: [PATCH] [ath5k][leds] Ability to disable leds support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Wed, 7 Apr 2010 21:58:29 +0300
Message-ID: <4c056b50.0c3fdf0a.500b.44af@mx.google.com>
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dmytro Milinevskyy <milinevskyy@gmail.com>
To: ath5k-devel@lists.ath5k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50616 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754295Ab0FAUTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 16:19:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Here is the patch to disable ath5k leds support on build stage.
However if the leds support was enabled do not force selection of 802.11 leds layer.

I've applied suggestion given by Pavel Roskin.

Best regards,

--Dima

---
 drivers/net/wireless/ath/ath5k/Kconfig  |   10 +++++++---
 drivers/net/wireless/ath/ath5k/Makefile |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h  |   16 +++++++++++-----
 drivers/net/wireless/ath/ath5k/base.h   |   17 ++++++++++++-----
 drivers/net/wireless/ath/ath5k/gpio.c   |    2 ++
 drivers/net/wireless/ath/ath5k/led.c    |    9 +++++++++
 6 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index eb83b7b..6b5677e 100644
--- a/drivers/net/wireless/ath/ath5k/Kconfig
+++ b/drivers/net/wireless/ath/ath5k/Kconfig
@@ -1,9 +1,6 @@
 config ATH5K
 	tristate "Atheros 5xxx wireless cards support"
 	depends on PCI && MAC80211
-	select MAC80211_LEDS
-	select LEDS_CLASS
-	select NEW_LEDS
 	---help---
 	  This module adds support for wireless adapters based on
 	  Atheros 5xxx chipset.
@@ -18,6 +15,13 @@ config ATH5K
 	  If you choose to build a module, it'll be called ath5k. Say M if
 	  unsure.
 
+
+config ATH5K_LEDS
+	tristate "Atheros 5xxx wireless cards LEDs support"
+	depends on ATH5K
+	---help---
+	  Atheros 5xxx LED support.
+
 config ATH5K_DEBUG
 	bool "Atheros 5xxx debugging"
 	depends on ATH5K
diff --git a/drivers/net/wireless/ath/ath5k/Makefile b/drivers/net/wireless/ath/ath5k/Makefile
index cc09595..6d552dd 100644
--- a/drivers/net/wireless/ath/ath5k/Makefile
+++ b/drivers/net/wireless/ath/ath5k/Makefile
@@ -10,8 +10,8 @@ ath5k-y				+= phy.o
 ath5k-y				+= reset.o
 ath5k-y				+= attach.o
 ath5k-y				+= base.o
-ath5k-y				+= led.o
 ath5k-y				+= rfkill.o
 ath5k-y				+= ani.o
 ath5k-$(CONFIG_ATH5K_DEBUG)	+= debug.o
+ath5k-$(CONFIG_ATH5K_LEDS) += led.o
 obj-$(CONFIG_ATH5K)		+= ath5k.o
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 2785946..615b9ca 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -920,11 +920,6 @@ enum ath5k_power_mode {
 #define AR5K_LED_ASSOC	3 /*IEEE80211_S_ASSOC*/
 #define AR5K_LED_RUN	4 /*IEEE80211_S_RUN*/
 
-/* GPIO-controlled software LED */
-#define AR5K_SOFTLED_PIN	0
-#define AR5K_SOFTLED_ON		0
-#define AR5K_SOFTLED_OFF	1
-
 /*
  * Chipset capabilities -see ath5k_hw_get_capability-
  * get_capability function is not yet fully implemented
@@ -1148,11 +1143,18 @@ struct ath5k_hw {
 int ath5k_hw_attach(struct ath5k_softc *sc);
 void ath5k_hw_detach(struct ath5k_hw *ah);
 
+#ifdef CONFIG_ATH5K_LEDS
 /* LED functions */
 int ath5k_init_leds(struct ath5k_softc *sc);
 void ath5k_led_enable(struct ath5k_softc *sc);
 void ath5k_led_off(struct ath5k_softc *sc);
 void ath5k_unregister_leds(struct ath5k_softc *sc);
+#else
+#define ath5k_init_leds(sc) do {} while (0)
+#define ath5k_led_enable(sc) do {} while (0)
+#define ath5k_led_off(sc) do {} while (0)
+#define ath5k_unregister_leds(sc) do {} while (0)
+#endif
 
 /* Reset Functions */
 int ath5k_hw_nic_wakeup(struct ath5k_hw *ah, int flags, bool initial);
@@ -1233,7 +1235,11 @@ int ath5k_hw_set_slot_time(struct ath5k_hw *ah, unsigned int slot_time);
 int ath5k_hw_init_desc_functions(struct ath5k_hw *ah);
 
 /* GPIO Functions */
+#ifdef CONFIG_ATH5K_LEDS
 void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state);
+#else
+#define ath5k_hw_set_ledstate(ah, state) do {} while (0)
+#endif
 int ath5k_hw_set_gpio_input(struct ath5k_hw *ah, u32 gpio);
 int ath5k_hw_set_gpio_output(struct ath5k_hw *ah, u32 gpio);
 u32 ath5k_hw_get_gpio(struct ath5k_hw *ah, u32 gpio);
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index 56221bc..e493d34 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -86,15 +86,19 @@ struct ath5k_txq {
 
 #define ATH5K_LED_MAX_NAME_LEN 31
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * State for LED triggers
  */
 struct ath5k_led
 {
-	char name[ATH5K_LED_MAX_NAME_LEN + 1];	/* name of the LED in sysfs */
 	struct ath5k_softc *sc;			/* driver state */
+#ifdef CONFIG_LEDS_CLASS
+	char name[ATH5K_LED_MAX_NAME_LEN + 1];	/* name of the LED in sysfs */
 	struct led_classdev led_dev;		/* led classdev */
+#endif
 };
+#endif
 
 /* Rfkill */
 struct ath5k_rfkill {
@@ -186,9 +190,6 @@ struct ath5k_softc {
 
 	u8			bssidmask[ETH_ALEN];
 
-	unsigned int		led_pin,	/* GPIO pin for driving LED */
-				led_on;		/* pin setting for LED on */
-
 	struct tasklet_struct	restq;		/* reset tasklet */
 
 	unsigned int		rxbufsize;	/* rx size based on mtu */
@@ -196,7 +197,6 @@ struct ath5k_softc {
 	spinlock_t		rxbuflock;
 	u32			*rxlink;	/* link ptr in last RX desc */
 	struct tasklet_struct	rxtq;		/* rx intr tasklet */
-	struct ath5k_led	rx_led;		/* rx led */
 
 	struct list_head	txbuf;		/* transmit buffer */
 	spinlock_t		txbuflock;
@@ -204,7 +204,14 @@ struct ath5k_softc {
 	struct ath5k_txq	txqs[AR5K_NUM_TX_QUEUES];	/* tx queues */
 	struct ath5k_txq	*txq;		/* main tx queue */
 	struct tasklet_struct	txtq;		/* tx intr tasklet */
+
+
+#ifdef CONFIG_ATH5K_LEDS
+	unsigned int		led_pin,	/* GPIO pin for driving LED */
+				led_on;		/* pin setting for LED on */
+	struct ath5k_led	rx_led;		/* rx led */
 	struct ath5k_led	tx_led;		/* tx led */
+#endif
 
 	struct ath5k_rfkill	rf_kill;
 
diff --git a/drivers/net/wireless/ath/ath5k/gpio.c b/drivers/net/wireless/ath/ath5k/gpio.c
index 64a27e7..9e757b3 100644
--- a/drivers/net/wireless/ath/ath5k/gpio.c
+++ b/drivers/net/wireless/ath/ath5k/gpio.c
@@ -25,6 +25,7 @@
 #include "debug.h"
 #include "base.h"
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * Set led state
  */
@@ -76,6 +77,7 @@ void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state)
 	else
 		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, led_5210);
 }
+#endif
 
 /*
  * Set GPIO inputs
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index 67aa52e..df8e8d2 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -121,6 +121,7 @@ ath5k_led_brightness_set(struct led_classdev *led_dev,
 		ath5k_led_on(led->sc);
 }
 
+#ifdef CONFIG_LEDS_CLASS
 static int
 ath5k_register_led(struct ath5k_softc *sc, struct ath5k_led *led,
 		   const char *name, char *trigger)
@@ -140,13 +141,16 @@ ath5k_register_led(struct ath5k_softc *sc, struct ath5k_led *led,
 	}
 	return err;
 }
+#endif
 
 static void
 ath5k_unregister_led(struct ath5k_led *led)
 {
 	if (!led->sc)
 		return;
+#ifdef CONFIG_LEDS_CLASS
 	led_classdev_unregister(&led->led_dev);
+#endif
 	ath5k_led_off(led->sc);
 	led->sc = NULL;
 }
@@ -177,6 +181,7 @@ int ath5k_init_leds(struct ath5k_softc *sc)
 
 	ath5k_led_enable(sc);
 
+#ifdef CONFIG_LEDS_CLASS
 	snprintf(name, sizeof(name), "ath5k-%s::rx", wiphy_name(hw->wiphy));
 	ret = ath5k_register_led(sc, &sc->rx_led, name,
 		ieee80211_get_rx_led_name(hw));
@@ -186,6 +191,10 @@ int ath5k_init_leds(struct ath5k_softc *sc)
 	snprintf(name, sizeof(name), "ath5k-%s::tx", wiphy_name(hw->wiphy));
 	ret = ath5k_register_led(sc, &sc->tx_led, name,
 		ieee80211_get_tx_led_name(hw));
+#else
+    sc->rx_led.sc = sc;
+    sc->tx_led.sc = sc;
+#endif
 out:
 	return ret;
 }
-- 
1.7.1

