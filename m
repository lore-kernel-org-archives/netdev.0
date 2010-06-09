From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: [PATCH] [ath5k][leds] Ability to disable leds support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Wed, 09 Jun 2010 10:31:01 +0300
Message-ID: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ath5k-devel@lists.ath5k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Here is the patch to disable ath5k leds support on build stage.
However if the leds support was enabled do not force selection of 802.11 leds layer.
Depency on LEDS_CLASS is kept.

Suggestion given by Pavel Roskin and Bob Copeland applied.

Changes from the previos version of the patch:
 - Use bool directive in Kconfig for switching LEDs support
 - Move ath5k_hw_set_ledstate into led.c and change its semantic to align with other leds routines

Regards,

--Dima

Signed-off-by: Dmytro Milinevskyy <milinevskyy@gmail.com>
---
 drivers/net/wireless/ath/ath5k/Kconfig  |   12 +++++--
 drivers/net/wireless/ath/ath5k/Makefile |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h  |   21 +++++++++++-
 drivers/net/wireless/ath/ath5k/attach.c |    2 +-
 drivers/net/wireless/ath/ath5k/base.c   |    6 ++--
 drivers/net/wireless/ath/ath5k/base.h   |   11 ++++--
 drivers/net/wireless/ath/ath5k/gpio.c   |   52 ------------------------------
 drivers/net/wireless/ath/ath5k/led.c    |   53 +++++++++++++++++++++++++++++++
 8 files changed, 94 insertions(+), 65 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index eb83b7b..6b2a682 100644
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
@@ -18,6 +15,15 @@ config ATH5K
 	  If you choose to build a module, it'll be called ath5k. Say M if
 	  unsure.
 
+
+config ATH5K_LEDS
+	bool "Atheros 5xxx wireless cards LEDs support"
+	depends on ATH5K
+	select NEW_LEDS
+	select LEDS_CLASS
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
index 2785946..202d143 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1148,11 +1148,31 @@ struct ath5k_hw {
 int ath5k_hw_attach(struct ath5k_softc *sc);
 void ath5k_hw_detach(struct ath5k_hw *ah);
 
+#ifdef CONFIG_ATH5K_LEDS
 /* LED functions */
+void ath5k_hw_set_ledstate(struct ath5k_softc *sc, unsigned int state);
 int ath5k_init_leds(struct ath5k_softc *sc);
 void ath5k_led_enable(struct ath5k_softc *sc);
 void ath5k_led_off(struct ath5k_softc *sc);
 void ath5k_unregister_leds(struct ath5k_softc *sc);
+#else
+static inline void ath5k_hw_set_ledstate(struct ath5k_softc *sc, unsigned int state)
+{
+}
+static inline int ath5k_init_leds(struct ath5k_softc *sc)
+{
+	return 0;
+}
+static inline void ath5k_led_enable(struct ath5k_softc *sc)
+{
+}
+static inline void ath5k_led_off(struct ath5k_softc *sc)
+{
+}
+static inline void ath5k_unregister_leds(struct ath5k_softc *sc)
+{
+}
+#endif
 
 /* Reset Functions */
 int ath5k_hw_nic_wakeup(struct ath5k_hw *ah, int flags, bool initial);
@@ -1233,7 +1253,6 @@ int ath5k_hw_set_slot_time(struct ath5k_hw *ah, unsigned int slot_time);
 int ath5k_hw_init_desc_functions(struct ath5k_hw *ah);
 
 /* GPIO Functions */
-void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state);
 int ath5k_hw_set_gpio_input(struct ath5k_hw *ah, u32 gpio);
 int ath5k_hw_set_gpio_output(struct ath5k_hw *ah, u32 gpio);
 u32 ath5k_hw_get_gpio(struct ath5k_hw *ah, u32 gpio);
diff --git a/drivers/net/wireless/ath/ath5k/attach.c b/drivers/net/wireless/ath/ath5k/attach.c
index e0c244b..7930a39 100644
--- a/drivers/net/wireless/ath/ath5k/attach.c
+++ b/drivers/net/wireless/ath/ath5k/attach.c
@@ -336,7 +336,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	ath5k_hw_init_nfcal_hist(ah);
 
 	/* turn on HW LEDs */
-	ath5k_hw_set_ledstate(ah, AR5K_LED_INIT);
+	ath5k_hw_set_ledstate(sc, AR5K_LED_INIT);
 
 	return 0;
 err_free:
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 2978359..64ea83d 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -3411,7 +3411,7 @@ static void ath5k_bss_info_changed(struct ieee80211_hw *hw,
 		sc->assoc = bss_conf->assoc;
 		if (sc->opmode == NL80211_IFTYPE_STATION)
 			set_beacon_filter(hw, sc->assoc);
-		ath5k_hw_set_ledstate(sc->ah, sc->assoc ?
+		ath5k_hw_set_ledstate(sc, sc->assoc ?
 			AR5K_LED_ASSOC : AR5K_LED_INIT);
 		if (bss_conf->assoc) {
 			ATH5K_DBG(sc, ATH5K_DEBUG_ANY,
@@ -3444,13 +3444,13 @@ static void ath5k_sw_scan_start(struct ieee80211_hw *hw)
 {
 	struct ath5k_softc *sc = hw->priv;
 	if (!sc->assoc)
-		ath5k_hw_set_ledstate(sc->ah, AR5K_LED_SCAN);
+		ath5k_hw_set_ledstate(sc, AR5K_LED_SCAN);
 }
 
 static void ath5k_sw_scan_complete(struct ieee80211_hw *hw)
 {
 	struct ath5k_softc *sc = hw->priv;
-	ath5k_hw_set_ledstate(sc->ah, sc->assoc ?
+	ath5k_hw_set_ledstate(sc, sc->assoc ?
 		AR5K_LED_ASSOC : AR5K_LED_INIT);
 }
 
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index 56221bc..8d289a3 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -186,9 +186,6 @@ struct ath5k_softc {
 
 	u8			bssidmask[ETH_ALEN];
 
-	unsigned int		led_pin,	/* GPIO pin for driving LED */
-				led_on;		/* pin setting for LED on */
-
 	struct tasklet_struct	restq;		/* reset tasklet */
 
 	unsigned int		rxbufsize;	/* rx size based on mtu */
@@ -196,7 +193,6 @@ struct ath5k_softc {
 	spinlock_t		rxbuflock;
 	u32			*rxlink;	/* link ptr in last RX desc */
 	struct tasklet_struct	rxtq;		/* rx intr tasklet */
-	struct ath5k_led	rx_led;		/* rx led */
 
 	struct list_head	txbuf;		/* transmit buffer */
 	spinlock_t		txbuflock;
@@ -204,7 +200,14 @@ struct ath5k_softc {
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
index 64a27e7..1e8b145 100644
--- a/drivers/net/wireless/ath/ath5k/gpio.c
+++ b/drivers/net/wireless/ath/ath5k/gpio.c
@@ -26,58 +26,6 @@
 #include "base.h"
 
 /*
- * Set led state
- */
-void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state)
-{
-	u32 led;
-	/*5210 has different led mode handling*/
-	u32 led_5210;
-
-	ATH5K_TRACE(ah->ah_sc);
-
-	/*Reset led status*/
-	if (ah->ah_version != AR5K_AR5210)
-		AR5K_REG_DISABLE_BITS(ah, AR5K_PCICFG,
-			AR5K_PCICFG_LEDMODE |  AR5K_PCICFG_LED);
-	else
-		AR5K_REG_DISABLE_BITS(ah, AR5K_PCICFG, AR5K_PCICFG_LED);
-
-	/*
-	 * Some blinking values, define at your wish
-	 */
-	switch (state) {
-	case AR5K_LED_SCAN:
-	case AR5K_LED_AUTH:
-		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_PEND;
-		led_5210 = AR5K_PCICFG_LED_PEND | AR5K_PCICFG_LED_BCTL;
-		break;
-
-	case AR5K_LED_INIT:
-		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_NONE;
-		led_5210 = AR5K_PCICFG_LED_PEND;
-		break;
-
-	case AR5K_LED_ASSOC:
-	case AR5K_LED_RUN:
-		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_ASSOC;
-		led_5210 = AR5K_PCICFG_LED_ASSOC;
-		break;
-
-	default:
-		led = AR5K_PCICFG_LEDMODE_PROM | AR5K_PCICFG_LED_NONE;
-		led_5210 = AR5K_PCICFG_LED_PEND;
-		break;
-	}
-
-	/*Write new status to the register*/
-	if (ah->ah_version != AR5K_AR5210)
-		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, led);
-	else
-		AR5K_REG_ENABLE_BITS(ah, AR5K_PCICFG, led_5210);
-}
-
-/*
  * Set GPIO inputs
  */
 int ath5k_hw_set_gpio_input(struct ath5k_hw *ah, u32 gpio)
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index 67aa52e..9cff1cf 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -41,6 +41,7 @@
 
 #include <linux/pci.h>
 #include "ath5k.h"
+#include "reg.h"
 #include "base.h"
 
 #define ATH_SDEVICE(subv,subd) \
@@ -86,6 +87,58 @@ static const struct pci_device_id ath5k_led_devices[] = {
 	{ }
 };
 
+/*
+ * Set led state
+ */
+void ath5k_hw_set_ledstate(struct ath5k_softc *sc, unsigned int state)
+{
+	u32 led;
+	/*5210 has different led mode handling*/
+	u32 led_5210;
+
+	ATH5K_TRACE(sc);
+
+	/*Reset led status*/
+	if (sc->ah->ah_version != AR5K_AR5210)
+		AR5K_REG_DISABLE_BITS(sc->ah, AR5K_PCICFG,
+			AR5K_PCICFG_LEDMODE |  AR5K_PCICFG_LED);
+	else
+		AR5K_REG_DISABLE_BITS(sc->ah, AR5K_PCICFG, AR5K_PCICFG_LED);
+
+	/*
+	 * Some blinking values, define at your wish
+	 */
+	switch (state) {
+	case AR5K_LED_SCAN:
+	case AR5K_LED_AUTH:
+		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_PEND;
+		led_5210 = AR5K_PCICFG_LED_PEND | AR5K_PCICFG_LED_BCTL;
+		break;
+
+	case AR5K_LED_INIT:
+		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_NONE;
+		led_5210 = AR5K_PCICFG_LED_PEND;
+		break;
+
+	case AR5K_LED_ASSOC:
+	case AR5K_LED_RUN:
+		led = AR5K_PCICFG_LEDMODE_PROP | AR5K_PCICFG_LED_ASSOC;
+		led_5210 = AR5K_PCICFG_LED_ASSOC;
+		break;
+
+	default:
+		led = AR5K_PCICFG_LEDMODE_PROM | AR5K_PCICFG_LED_NONE;
+		led_5210 = AR5K_PCICFG_LED_PEND;
+		break;
+	}
+
+	/*Write new status to the register*/
+	if (sc->ah->ah_version != AR5K_AR5210)
+		AR5K_REG_ENABLE_BITS(sc->ah, AR5K_PCICFG, led);
+	else
+		AR5K_REG_ENABLE_BITS(sc->ah, AR5K_PCICFG, led_5210);
+}
+
 void ath5k_led_enable(struct ath5k_softc *sc)
 {
 	if (test_bit(ATH_STAT_LEDSOFT, sc->status)) {
-- 
1.7.1
