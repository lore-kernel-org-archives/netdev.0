From: Dmytro Milinevskyy <milinevskyy@gmail.com>
Subject: [PATCH] [ath5k][leds] Ability to disable leds support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Thu, 03 Jun 2010 22:39:30 +0300
Message-ID: <4c0804e2.0c3ddf0a.2771.10f7@mx.google.com>
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
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Here is the patch to disable ath5k leds support on build stage.
However if the leds support was enabled do not force selection of 802.11 leds layer.
Depency on LEDS_CLASS is kept.

Suggestion given by Pavel Roskin and Bob Copeland applied.

Regards,

--Dima

---
 drivers/net/wireless/ath/ath5k/Kconfig  |   12 +++++++++---
 drivers/net/wireless/ath/ath5k/Makefile |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h  |   22 ++++++++++++++++++++++
 drivers/net/wireless/ath/ath5k/base.h   |   13 +++++++++----
 drivers/net/wireless/ath/ath5k/gpio.c   |    2 ++
 5 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index eb83b7b..29f4572 100644
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
+	tristate "Atheros 5xxx wireless cards LEDs support"
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
index 2785946..bb7e09a 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1148,11 +1148,27 @@ struct ath5k_hw {
 int ath5k_hw_attach(struct ath5k_softc *sc);
 void ath5k_hw_detach(struct ath5k_hw *ah);
 
+#ifdef CONFIG_ATH5K_LEDS
 /* LED functions */
 int ath5k_init_leds(struct ath5k_softc *sc);
 void ath5k_led_enable(struct ath5k_softc *sc);
 void ath5k_led_off(struct ath5k_softc *sc);
 void ath5k_unregister_leds(struct ath5k_softc *sc);
+#else
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
@@ -1233,7 +1249,13 @@ int ath5k_hw_set_slot_time(struct ath5k_hw *ah, unsigned int slot_time);
 int ath5k_hw_init_desc_functions(struct ath5k_hw *ah);
 
 /* GPIO Functions */
+#ifdef CONFIG_ATH5K_LEDS
 void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state);
+#else
+static inline void ath5k_hw_set_ledstate(struct ath5k_hw *ah, unsigned int state)
+{
+}
+#endif
 int ath5k_hw_set_gpio_input(struct ath5k_hw *ah, u32 gpio);
 int ath5k_hw_set_gpio_output(struct ath5k_hw *ah, u32 gpio);
 u32 ath5k_hw_get_gpio(struct ath5k_hw *ah, u32 gpio);
diff --git a/drivers/net/wireless/ath/ath5k/base.h b/drivers/net/wireless/ath/ath5k/base.h
index 56221bc..97b26c1 100644
--- a/drivers/net/wireless/ath/ath5k/base.h
+++ b/drivers/net/wireless/ath/ath5k/base.h
@@ -86,6 +86,7 @@ struct ath5k_txq {
 
 #define ATH5K_LED_MAX_NAME_LEN 31
 
+#ifdef CONFIG_ATH5K_LEDS
 /*
  * State for LED triggers
  */
@@ -95,6 +96,7 @@ struct ath5k_led
 	struct ath5k_softc *sc;			/* driver state */
 	struct led_classdev led_dev;		/* led classdev */
 };
+#endif
 
 /* Rfkill */
 struct ath5k_rfkill {
@@ -186,9 +188,6 @@ struct ath5k_softc {
 
 	u8			bssidmask[ETH_ALEN];
 
-	unsigned int		led_pin,	/* GPIO pin for driving LED */
-				led_on;		/* pin setting for LED on */
-
 	struct tasklet_struct	restq;		/* reset tasklet */
 
 	unsigned int		rxbufsize;	/* rx size based on mtu */
@@ -196,7 +195,6 @@ struct ath5k_softc {
 	spinlock_t		rxbuflock;
 	u32			*rxlink;	/* link ptr in last RX desc */
 	struct tasklet_struct	rxtq;		/* rx intr tasklet */
-	struct ath5k_led	rx_led;		/* rx led */
 
 	struct list_head	txbuf;		/* transmit buffer */
 	spinlock_t		txbuflock;
@@ -204,7 +202,14 @@ struct ath5k_softc {
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
-- 
1.7.1
