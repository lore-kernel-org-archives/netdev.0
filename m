From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-02-20
Date: Wed, 20 Feb 2008 21:11:32 -0500
Message-ID: <20080221021132.GF3825@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

Here are some fixes intended for 2.6.25.  These are mostly small things:
a couple of USB IDs, some sparse warnings, and an ath5k warning you
should recognize.  :-)  There are also a number of SSB bus fixes --
Michael has been hacking on a new AP...

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit da12f7356da1dfb97f1c6c418f828b7ce442fef9:
  Denis V. Lunev (1):
        [NETNS]: Namespace leak in pneigh_lookup.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

David Miller (1):
      ath5k: Fix build warnings on some 64-bit platforms.

Ivo Couckuyt (1):
      p54usb: add USB ID for Phillips CPWUA054

Jiri Slaby (2):
      WDEV: ath5k, fix lock imbalance
      WDEV, ath5k, don't return int from bool function

Johannes Berg (2):
      rtl818x: fix sparse warnings
      zd1211rw: fix sparse warnings

John W. Linville (1):
      p54usb: add USB ID for Linksys WUSB54G ver 2

Michael Buesch (6):
      ssb: Fix serial console on new bcm47xx devices
      ssb: Fix watchdog access for devices without a chipcommon
      ssb: Fix the GPIO API
      ssb: Make the GPIO API reentrancy safe
      ssb: Fix pcicore cardbus mode
      ssb: Fix support for PCI devices behind a SSB->PCI bridge

 drivers/net/wireless/ath5k/ath5k.h        |    2 +-
 drivers/net/wireless/ath5k/base.c         |   20 +++--
 drivers/net/wireless/ath5k/hw.c           |    8 +-
 drivers/net/wireless/p54usb.c             |    2 +
 drivers/net/wireless/rtl8180_dev.c        |    4 +-
 drivers/net/wireless/rtl8187_dev.c        |    4 +-
 drivers/net/wireless/zd1211rw/zd_mac.c    |   12 ++-
 drivers/ssb/Kconfig                       |    6 ++
 drivers/ssb/Makefile                      |    1 +
 drivers/ssb/driver_chipcommon.c           |   65 ++++++++++++---
 drivers/ssb/driver_extif.c                |   25 +++++-
 drivers/ssb/driver_pcicore.c              |   45 ++++++++--
 drivers/ssb/embedded.c                    |  132 +++++++++++++++++++++++++++++
 drivers/ssb/main.c                        |    4 +
 include/linux/ssb/ssb.h                   |   12 +++
 include/linux/ssb/ssb_driver_chipcommon.h |   18 +++-
 include/linux/ssb/ssb_driver_extif.h      |   18 +++-
 include/linux/ssb/ssb_driver_pci.h        |    5 +
 include/linux/ssb/ssb_embedded.h          |   18 ++++
 19 files changed, 354 insertions(+), 47 deletions(-)
 create mode 100644 drivers/ssb/embedded.c
 create mode 100644 include/linux/ssb/ssb_embedded.h

diff --git a/drivers/net/wireless/ath5k/ath5k.h b/drivers/net/wireless/ath5k/ath5k.h
index c79066b..69dea33 100644
--- a/drivers/net/wireless/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath5k/ath5k.h
@@ -1035,7 +1035,7 @@ struct ath5k_hw {
 		unsigned int, unsigned int, enum ath5k_pkt_type, unsigned int,
 		unsigned int, unsigned int, unsigned int, unsigned int,
 		unsigned int, unsigned int, unsigned int);
-	bool (*ah_setup_xtx_desc)(struct ath5k_hw *, struct ath5k_desc *,
+	int (*ah_setup_xtx_desc)(struct ath5k_hw *, struct ath5k_desc *,
 		unsigned int, unsigned int, unsigned int, unsigned int,
 		unsigned int, unsigned int);
 	int (*ah_proc_tx_desc)(struct ath5k_hw *, struct ath5k_desc *);
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index dfdaec0..bef967c 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -668,7 +668,10 @@ ath5k_attach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 	 * return false w/o doing anything.  MAC's that do
 	 * support it will return true w/o doing anything.
 	 */
-	if (ah->ah_setup_xtx_desc(ah, NULL, 0, 0, 0, 0, 0, 0))
+	ret = ah->ah_setup_xtx_desc(ah, NULL, 0, 0, 0, 0, 0, 0);
+	if (ret < 0)
+		goto err;
+	if (ret > 0)
 		__set_bit(ATH_STAT_MRRETRY, sc->status);
 
 	/*
@@ -1715,6 +1718,7 @@ ath5k_tasklet_rx(unsigned long data)
 			break;
 		else if (unlikely(ret)) {
 			ATH5K_ERR(sc, "error in processing rx descriptor\n");
+			spin_unlock(&sc->rxbuflock);
 			return;
 		}
 
@@ -2126,8 +2130,9 @@ ath5k_beacon_update_timers(struct ath5k_softc *sc, u64 bc_tsf)
 			"updated timers based on beacon TSF\n");
 
 	ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON,
-		"bc_tsf %llx hw_tsf %llx bc_tu %u hw_tu %u nexttbtt %u\n",
-		bc_tsf, hw_tsf, bc_tu, hw_tu, nexttbtt);
+			  "bc_tsf %llx hw_tsf %llx bc_tu %u hw_tu %u nexttbtt %u\n",
+			  (unsigned long long) bc_tsf,
+			  (unsigned long long) hw_tsf, bc_tu, hw_tu, nexttbtt);
 	ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON, "intval %u %s %s\n",
 		intval & AR5K_BEACON_PERIOD,
 		intval & AR5K_BEACON_ENA ? "AR5K_BEACON_ENA" : "",
@@ -2385,10 +2390,11 @@ ath5k_intr(int irq, void *dev_id)
 					u64 tsf = ath5k_hw_get_tsf64(ah);
 					sc->nexttbtt += sc->bintval;
 					ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
-						"SWBA nexttbtt: %x hw_tu: %x "
-						"TSF: %llx\n",
-						sc->nexttbtt,
-						TSF_TO_TU(tsf), tsf);
+						  "SWBA nexttbtt: %x hw_tu: %x "
+						  "TSF: %llx\n",
+						  sc->nexttbtt,
+						  TSF_TO_TU(tsf),
+						  (unsigned long long) tsf);
 				} else {
 					ath5k_beacon_send(sc);
 				}
diff --git a/drivers/net/wireless/ath5k/hw.c b/drivers/net/wireless/ath5k/hw.c
index 1ab57aa..c2de2d9 100644
--- a/drivers/net/wireless/ath5k/hw.c
+++ b/drivers/net/wireless/ath5k/hw.c
@@ -45,7 +45,7 @@ static int ath5k_hw_setup_4word_tx_desc(struct ath5k_hw *, struct ath5k_desc *,
 	unsigned int, unsigned int, enum ath5k_pkt_type, unsigned int,
 	unsigned int, unsigned int, unsigned int, unsigned int, unsigned int,
 	unsigned int, unsigned int);
-static bool ath5k_hw_setup_xr_tx_desc(struct ath5k_hw *, struct ath5k_desc *,
+static int ath5k_hw_setup_xr_tx_desc(struct ath5k_hw *, struct ath5k_desc *,
 	unsigned int, unsigned int, unsigned int, unsigned int, unsigned int,
 	unsigned int);
 static int ath5k_hw_proc_4word_tx_status(struct ath5k_hw *, struct ath5k_desc *);
@@ -3743,7 +3743,7 @@ static int ath5k_hw_setup_4word_tx_desc(struct ath5k_hw *ah,
 /*
  * Initialize a 4-word multirate tx descriptor on 5212
  */
-static bool
+static int
 ath5k_hw_setup_xr_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
 	unsigned int tx_rate1, u_int tx_tries1, u_int tx_rate2, u_int tx_tries2,
 	unsigned int tx_rate3, u_int tx_tries3)
@@ -3783,10 +3783,10 @@ ath5k_hw_setup_xr_tx_desc(struct ath5k_hw *ah, struct ath5k_desc *desc,
 
 #undef _XTX_TRIES
 
-		return true;
+		return 1;
 	}
 
-	return false;
+	return 0;
 }
 
 /*
diff --git a/drivers/net/wireless/p54usb.c b/drivers/net/wireless/p54usb.c
index 60d286e..e7d4aee 100644
--- a/drivers/net/wireless/p54usb.c
+++ b/drivers/net/wireless/p54usb.c
@@ -35,6 +35,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0707, 0xee06)},	/* SMC 2862W-G */
 	{USB_DEVICE(0x083a, 0x4501)},	/* Accton 802.11g WN4501 USB */
 	{USB_DEVICE(0x083a, 0x4502)},	/* Siemens Gigaset USB Adapter */
+	{USB_DEVICE(0x083a, 0x5501)},	/* Phillips CPWUA054 */
 	{USB_DEVICE(0x0846, 0x4200)},	/* Netgear WG121 */
 	{USB_DEVICE(0x0846, 0x4210)},	/* Netgear WG121 the second ? */
 	{USB_DEVICE(0x0846, 0x4220)},	/* Netgear WG111 */
@@ -62,6 +63,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0cde, 0x0008)},	/* Sagem XG703A */
 	{USB_DEVICE(0x0d8e, 0x3762)},	/* DLink DWL-G120 Cohiba */
 	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
+	{USB_DEVICE(0x13b1, 0x000a)},	/* Linksys WUSB54G ver 2 */
 	{USB_DEVICE(0x13B1, 0x000C)},	/* Linksys WUSB54AG */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
diff --git a/drivers/net/wireless/rtl8180_dev.c b/drivers/net/wireless/rtl8180_dev.c
index 27ebd68..5e9a8ac 100644
--- a/drivers/net/wireless/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl8180_dev.c
@@ -135,13 +135,15 @@ static void rtl8180_handle_tx(struct ieee80211_hw *dev, unsigned int prio)
 	while (skb_queue_len(&ring->queue)) {
 		struct rtl8180_tx_desc *entry = &ring->desc[ring->idx];
 		struct sk_buff *skb;
-		struct ieee80211_tx_status status = { {0} };
+		struct ieee80211_tx_status status;
 		struct ieee80211_tx_control *control;
 		u32 flags = le32_to_cpu(entry->flags);
 
 		if (flags & RTL8180_TX_DESC_FLAG_OWN)
 			return;
 
+		memset(&status, 0, sizeof(status));
+
 		ring->idx = (ring->idx + 1) % ring->entries;
 		skb = __skb_dequeue(&ring->queue);
 		pci_unmap_single(priv->pdev, le32_to_cpu(entry->tx_buf),
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 0d71716..f445059 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -113,10 +113,12 @@ void rtl8187_write_phy(struct ieee80211_hw *dev, u8 addr, u32 data)
 
 static void rtl8187_tx_cb(struct urb *urb)
 {
-	struct ieee80211_tx_status status = { {0} };
+	struct ieee80211_tx_status status;
 	struct sk_buff *skb = (struct sk_buff *)urb->context;
 	struct rtl8187_tx_info *info = (struct rtl8187_tx_info *)skb->cb;
 
+	memset(&status, 0, sizeof(status));
+
 	usb_free_urb(info->urb);
 	if (info->control)
 		memcpy(&status.control, info->control, sizeof(status.control));
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 49127e4..76ef2d8 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -360,11 +360,14 @@ void zd_mac_tx_failed(struct ieee80211_hw *hw)
 {
 	struct sk_buff_head *q = &zd_hw_mac(hw)->ack_wait_queue;
 	struct sk_buff *skb;
-	struct ieee80211_tx_status status = {{0}};
+	struct ieee80211_tx_status status;
 
 	skb = skb_dequeue(q);
 	if (skb == NULL)
 		return;
+
+	memset(&status, 0, sizeof(status));
+
 	tx_status(hw, skb, &status, 0);
 }
 
@@ -389,7 +392,8 @@ void zd_mac_tx_to_dev(struct sk_buff *skb, int error)
 		if (unlikely(error ||
 		    (cb->control->flags & IEEE80211_TXCTL_NO_ACK)))
 		{
-			struct ieee80211_tx_status status = {{0}};
+			struct ieee80211_tx_status status;
+			memset(&status, 0, sizeof(status));
 			tx_status(hw, skb, &status, !error);
 		} else {
 			struct sk_buff_head *q =
@@ -603,7 +607,9 @@ static int filter_ack(struct ieee80211_hw *hw, struct ieee80211_hdr *rx_hdr,
 		tx_hdr = (struct ieee80211_hdr *)skb->data;
 		if (likely(!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1)))
 		{
-			struct ieee80211_tx_status status = {{0}};
+			struct ieee80211_tx_status status;
+
+			memset(&status, 0, sizeof(status));
 			status.flags = IEEE80211_TX_STATUS_ACK;
 			status.ack_signal = stats->ssi;
 			__skb_unlink(skb, q);
diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index d976660..78fd331 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -105,6 +105,12 @@ config SSB_DRIVER_MIPS
 
 	  If unsure, say N
 
+# Assumption: We are on embedded, if we compile the MIPS core.
+config SSB_EMBEDDED
+	bool
+	depends on SSB_DRIVER_MIPS
+	default y
+
 config SSB_DRIVER_EXTIF
 	bool "SSB Broadcom EXTIF core driver (EXPERIMENTAL)"
 	depends on SSB_DRIVER_MIPS && EXPERIMENTAL
diff --git a/drivers/ssb/Makefile b/drivers/ssb/Makefile
index 7be3975..e235144 100644
--- a/drivers/ssb/Makefile
+++ b/drivers/ssb/Makefile
@@ -1,5 +1,6 @@
 # core
 ssb-y					+= main.o scan.o
+ssb-$(CONFIG_SSB_EMBEDDED)		+= embedded.o
 
 # host support
 ssb-$(CONFIG_SSB_PCIHOST)		+= pci.o pcihost_wrapper.o
diff --git a/drivers/ssb/driver_chipcommon.c b/drivers/ssb/driver_chipcommon.c
index 6fbf1c5..e586321 100644
--- a/drivers/ssb/driver_chipcommon.c
+++ b/drivers/ssb/driver_chipcommon.c
@@ -39,12 +39,14 @@ static inline void chipco_write32(struct ssb_chipcommon *cc,
 	ssb_write32(cc->dev, offset, value);
 }
 
-static inline void chipco_write32_masked(struct ssb_chipcommon *cc, u16 offset,
-					 u32 mask, u32 value)
+static inline u32 chipco_write32_masked(struct ssb_chipcommon *cc, u16 offset,
+					u32 mask, u32 value)
 {
 	value &= mask;
 	value |= chipco_read32(cc, offset) & ~mask;
 	chipco_write32(cc, offset, value);
+
+	return value;
 }
 
 void ssb_chipco_set_clockmode(struct ssb_chipcommon *cc,
@@ -356,14 +358,29 @@ u32 ssb_chipco_gpio_in(struct ssb_chipcommon *cc, u32 mask)
 	return chipco_read32(cc, SSB_CHIPCO_GPIOIN) & mask;
 }
 
-void ssb_chipco_gpio_out(struct ssb_chipcommon *cc, u32 mask, u32 value)
+u32 ssb_chipco_gpio_out(struct ssb_chipcommon *cc, u32 mask, u32 value)
+{
+	return chipco_write32_masked(cc, SSB_CHIPCO_GPIOOUT, mask, value);
+}
+
+u32 ssb_chipco_gpio_outen(struct ssb_chipcommon *cc, u32 mask, u32 value)
+{
+	return chipco_write32_masked(cc, SSB_CHIPCO_GPIOOUTEN, mask, value);
+}
+
+u32 ssb_chipco_gpio_control(struct ssb_chipcommon *cc, u32 mask, u32 value)
+{
+	return chipco_write32_masked(cc, SSB_CHIPCO_GPIOCTL, mask, value);
+}
+
+u32 ssb_chipco_gpio_intmask(struct ssb_chipcommon *cc, u32 mask, u32 value)
 {
-	chipco_write32_masked(cc, SSB_CHIPCO_GPIOOUT, mask, value);
+	return chipco_write32_masked(cc, SSB_CHIPCO_GPIOIRQ, mask, value);
 }
 
-void ssb_chipco_gpio_outen(struct ssb_chipcommon *cc, u32 mask, u32 value)
+u32 ssb_chipco_gpio_polarity(struct ssb_chipcommon *cc, u32 mask, u32 value)
 {
-	chipco_write32_masked(cc, SSB_CHIPCO_GPIOOUTEN, mask, value);
+	return chipco_write32_masked(cc, SSB_CHIPCO_GPIOPOL, mask, value);
 }
 
 #ifdef CONFIG_SSB_SERIAL
@@ -376,6 +393,7 @@ int ssb_chipco_serial_init(struct ssb_chipcommon *cc,
 	unsigned int irq;
 	u32 baud_base, div;
 	u32 i, n;
+	unsigned int ccrev = cc->dev->id.revision;
 
 	plltype = (cc->capabilities & SSB_CHIPCO_CAP_PLLT);
 	irq = ssb_mips_irq(cc->dev);
@@ -387,14 +405,39 @@ int ssb_chipco_serial_init(struct ssb_chipcommon *cc,
 						chipco_read32(cc, SSB_CHIPCO_CLOCK_M2));
 		div = 1;
 	} else {
-		if (cc->dev->id.revision >= 11) {
+		if (ccrev == 20) {
+			/* BCM5354 uses constant 25MHz clock */
+			baud_base = 25000000;
+			div = 48;
+			/* Set the override bit so we don't divide it */
+			chipco_write32(cc, SSB_CHIPCO_CORECTL,
+				       chipco_read32(cc, SSB_CHIPCO_CORECTL)
+				       | SSB_CHIPCO_CORECTL_UARTCLK0);
+		} else if ((ccrev >= 11) && (ccrev != 15)) {
 			/* Fixed ALP clock */
 			baud_base = 20000000;
+			if (cc->capabilities & SSB_CHIPCO_CAP_PMU) {
+				/* FIXME: baud_base is different for devices with a PMU */
+				SSB_WARN_ON(1);
+			}
 			div = 1;
+			if (ccrev >= 21) {
+				/* Turn off UART clock before switching clocksource. */
+				chipco_write32(cc, SSB_CHIPCO_CORECTL,
+					       chipco_read32(cc, SSB_CHIPCO_CORECTL)
+					       & ~SSB_CHIPCO_CORECTL_UARTCLKEN);
+			}
 			/* Set the override bit so we don't divide it */
 			chipco_write32(cc, SSB_CHIPCO_CORECTL,
-				       SSB_CHIPCO_CORECTL_UARTCLK0);
-		} else if (cc->dev->id.revision >= 3) {
+				       chipco_read32(cc, SSB_CHIPCO_CORECTL)
+				       | SSB_CHIPCO_CORECTL_UARTCLK0);
+			if (ccrev >= 21) {
+				/* Re-enable the UART clock. */
+				chipco_write32(cc, SSB_CHIPCO_CORECTL,
+					       chipco_read32(cc, SSB_CHIPCO_CORECTL)
+					       | SSB_CHIPCO_CORECTL_UARTCLKEN);
+			}
+		} else if (ccrev >= 3) {
 			/* Internal backplane clock */
 			baud_base = ssb_clockspeed(bus);
 			div = chipco_read32(cc, SSB_CHIPCO_CLKDIV)
@@ -406,7 +449,7 @@ int ssb_chipco_serial_init(struct ssb_chipcommon *cc,
 		}
 
 		/* Clock source depends on strapping if UartClkOverride is unset */
-		if ((cc->dev->id.revision > 0) &&
+		if ((ccrev > 0) &&
 		    !(chipco_read32(cc, SSB_CHIPCO_CORECTL) & SSB_CHIPCO_CORECTL_UARTCLK0)) {
 			if ((cc->capabilities & SSB_CHIPCO_CAP_UARTCLK) ==
 			    SSB_CHIPCO_CAP_UARTCLK_INT) {
@@ -428,7 +471,7 @@ int ssb_chipco_serial_init(struct ssb_chipcommon *cc,
 		cc_mmio = cc->dev->bus->mmio + (cc->dev->core_index * SSB_CORE_SIZE);
 		uart_regs = cc_mmio + SSB_CHIPCO_UART0_DATA;
 		/* Offset changed at after rev 0 */
-		if (cc->dev->id.revision == 0)
+		if (ccrev == 0)
 			uart_regs += (i * 8);
 		else
 			uart_regs += (i * 256);
diff --git a/drivers/ssb/driver_extif.c b/drivers/ssb/driver_extif.c
index fe55eb8..c3e1d3e 100644
--- a/drivers/ssb/driver_extif.c
+++ b/drivers/ssb/driver_extif.c
@@ -27,12 +27,14 @@ static inline void extif_write32(struct ssb_extif *extif, u16 offset, u32 value)
 	ssb_write32(extif->dev, offset, value);
 }
 
-static inline void extif_write32_masked(struct ssb_extif *extif, u16 offset,
-					u32 mask, u32 value)
+static inline u32 extif_write32_masked(struct ssb_extif *extif, u16 offset,
+				       u32 mask, u32 value)
 {
 	value &= mask;
 	value |= extif_read32(extif, offset) & ~mask;
 	extif_write32(extif, offset, value);
+
+	return value;
 }
 
 #ifdef CONFIG_SSB_SERIAL
@@ -110,20 +112,35 @@ void ssb_extif_get_clockcontrol(struct ssb_extif *extif,
 	*m = extif_read32(extif, SSB_EXTIF_CLOCK_SB);
 }
 
+void ssb_extif_watchdog_timer_set(struct ssb_extif *extif,
+				  u32 ticks)
+{
+	extif_write32(extif, SSB_EXTIF_WATCHDOG, ticks);
+}
+
 u32 ssb_extif_gpio_in(struct ssb_extif *extif, u32 mask)
 {
 	return extif_read32(extif, SSB_EXTIF_GPIO_IN) & mask;
 }
 
-void ssb_extif_gpio_out(struct ssb_extif *extif, u32 mask, u32 value)
+u32 ssb_extif_gpio_out(struct ssb_extif *extif, u32 mask, u32 value)
 {
 	return extif_write32_masked(extif, SSB_EXTIF_GPIO_OUT(0),
 				   mask, value);
 }
 
-void ssb_extif_gpio_outen(struct ssb_extif *extif, u32 mask, u32 value)
+u32 ssb_extif_gpio_outen(struct ssb_extif *extif, u32 mask, u32 value)
 {
 	return extif_write32_masked(extif, SSB_EXTIF_GPIO_OUTEN(0),
 				   mask, value);
 }
 
+u32 ssb_extif_gpio_polarity(struct ssb_extif *extif, u32 mask, u32 value)
+{
+	return extif_write32_masked(extif, SSB_EXTIF_GPIO_INTPOL, mask, value);
+}
+
+u32 ssb_extif_gpio_intmask(struct ssb_extif *extif, u32 mask, u32 value)
+{
+	return extif_write32_masked(extif, SSB_EXTIF_GPIO_INTMASK, mask, value);
+}
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 2faaa90..6d99a98 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -11,6 +11,7 @@
 #include <linux/ssb/ssb.h>
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include <linux/ssb/ssb_embedded.h>
 
 #include "ssb_private.h"
 
@@ -27,6 +28,18 @@ void pcicore_write32(struct ssb_pcicore *pc, u16 offset, u32 value)
 	ssb_write32(pc->dev, offset, value);
 }
 
+static inline
+u16 pcicore_read16(struct ssb_pcicore *pc, u16 offset)
+{
+	return ssb_read16(pc->dev, offset);
+}
+
+static inline
+void pcicore_write16(struct ssb_pcicore *pc, u16 offset, u16 value)
+{
+	ssb_write16(pc->dev, offset, value);
+}
+
 /**************************************************
  * Code for hostmode operation.
  **************************************************/
@@ -66,6 +79,7 @@ int pcibios_plat_dev_init(struct pci_dev *d)
 			base = &ssb_pcicore_pcibus_iobase;
 		else
 			base = &ssb_pcicore_pcibus_membase;
+		res->flags |= IORESOURCE_PCI_FIXED;
 		if (res->end) {
 			size = res->end - res->start + 1;
 			if (*base & (size - 1))
@@ -88,10 +102,12 @@ int pcibios_plat_dev_init(struct pci_dev *d)
 
 static void __init ssb_fixup_pcibridge(struct pci_dev *dev)
 {
+	u8 lat;
+
 	if (dev->bus->number != 0 || PCI_SLOT(dev->devfn) != 0)
 		return;
 
-	ssb_printk(KERN_INFO "PCI: fixing up bridge\n");
+	ssb_printk(KERN_INFO "PCI: Fixing up bridge %s\n", pci_name(dev));
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
@@ -101,7 +117,10 @@ static void __init ssb_fixup_pcibridge(struct pci_dev *dev)
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
 
 	/* Make sure our latency is high enough to handle the devices behind us */
-	pci_write_config_byte(dev, PCI_LATENCY_TIMER, 0xa8);
+	lat = 168;
+	ssb_printk(KERN_INFO "PCI: Fixing latency timer of device %s to %u\n",
+		   pci_name(dev), lat);
+	pci_write_config_byte(dev, PCI_LATENCY_TIMER, lat);
 }
 DECLARE_PCI_FIXUP_EARLY(PCI_ANY_ID, PCI_ANY_ID, ssb_fixup_pcibridge);
 
@@ -117,8 +136,10 @@ static u32 get_cfgspace_addr(struct ssb_pcicore *pc,
 	u32 addr = 0;
 	u32 tmp;
 
-	if (unlikely(pc->cardbusmode && dev > 1))
+	/* We do only have one cardbus device behind the bridge. */
+	if (pc->cardbusmode && (dev >= 1))
 		goto out;
+
 	if (bus == 0) {
 		/* Type 0 transaction */
 		if (unlikely(dev >= SSB_PCI_SLOT_MAX))
@@ -279,14 +300,14 @@ static struct resource ssb_pcicore_mem_resource = {
 	.name	= "SSB PCIcore external memory",
 	.start	= SSB_PCI_DMA,
 	.end	= SSB_PCI_DMA + SSB_PCI_DMA_SZ - 1,
-	.flags	= IORESOURCE_MEM,
+	.flags	= IORESOURCE_MEM | IORESOURCE_PCI_FIXED,
 };
 
 static struct resource ssb_pcicore_io_resource = {
 	.name	= "SSB PCIcore external I/O",
 	.start	= 0x100,
 	.end	= 0x7FF,
-	.flags	= IORESOURCE_IO,
+	.flags	= IORESOURCE_IO | IORESOURCE_PCI_FIXED,
 };
 
 static struct pci_controller ssb_pcicore_controller = {
@@ -318,7 +339,16 @@ static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 	pcicore_write32(pc, SSB_PCICORE_ARBCTL, val);
 	udelay(1); /* Assertion time demanded by the PCI standard */
 
-	/*TODO cardbus mode */
+	if (pc->dev->bus->has_cardbus_slot) {
+		ssb_dprintk(KERN_INFO PFX "CardBus slot detected\n");
+		pc->cardbusmode = 1;
+		/* GPIO 1 resets the bridge */
+		ssb_gpio_out(pc->dev->bus, 1, 1);
+		ssb_gpio_outen(pc->dev->bus, 1, 1);
+		pcicore_write16(pc, SSB_PCICORE_SPROM(0),
+				pcicore_read16(pc, SSB_PCICORE_SPROM(0))
+				| 0x0400);
+	}
 
 	/* 64MB I/O window */
 	pcicore_write32(pc, SSB_PCICORE_SBTOPCI0,
@@ -344,7 +374,8 @@ static void ssb_pcicore_init_hostmode(struct ssb_pcicore *pc)
 	/* Ok, ready to run, register it to the system.
 	 * The following needs change, if we want to port hostmode
 	 * to non-MIPS platform. */
-	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x04000000));
+	ssb_pcicore_controller.io_map_base = (unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x04000000);
+	set_io_port_base(ssb_pcicore_controller.io_map_base);
 	/* Give some time to the PCI controller to configure itself with the new
 	 * values. Not waiting at this point causes crashes of the machine. */
 	mdelay(10);
diff --git a/drivers/ssb/embedded.c b/drivers/ssb/embedded.c
new file mode 100644
index 0000000..d3ade82
--- /dev/null
+++ b/drivers/ssb/embedded.c
@@ -0,0 +1,132 @@
+/*
+ * Sonics Silicon Backplane
+ * Embedded systems support code
+ *
+ * Copyright 2005-2008, Broadcom Corporation
+ * Copyright 2006-2008, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
+ *
+ * Licensed under the GNU/GPL. See COPYING for details.
+ */
+
+#include <linux/ssb/ssb.h>
+#include <linux/ssb/ssb_embedded.h>
+
+#include "ssb_private.h"
+
+
+int ssb_watchdog_timer_set(struct ssb_bus *bus, u32 ticks)
+{
+	if (ssb_chipco_available(&bus->chipco)) {
+		ssb_chipco_watchdog_timer_set(&bus->chipco, ticks);
+		return 0;
+	}
+	if (ssb_extif_available(&bus->extif)) {
+		ssb_extif_watchdog_timer_set(&bus->extif, ticks);
+		return 0;
+	}
+	return -ENODEV;
+}
+
+u32 ssb_gpio_in(struct ssb_bus *bus, u32 mask)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_in(&bus->chipco, mask);
+	else if (ssb_extif_available(&bus->extif))
+		res = ssb_extif_gpio_in(&bus->extif, mask);
+	else
+		SSB_WARN_ON(1);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_in);
+
+u32 ssb_gpio_out(struct ssb_bus *bus, u32 mask, u32 value)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_out(&bus->chipco, mask, value);
+	else if (ssb_extif_available(&bus->extif))
+		res = ssb_extif_gpio_out(&bus->extif, mask, value);
+	else
+		SSB_WARN_ON(1);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_out);
+
+u32 ssb_gpio_outen(struct ssb_bus *bus, u32 mask, u32 value)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_outen(&bus->chipco, mask, value);
+	else if (ssb_extif_available(&bus->extif))
+		res = ssb_extif_gpio_outen(&bus->extif, mask, value);
+	else
+		SSB_WARN_ON(1);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_outen);
+
+u32 ssb_gpio_control(struct ssb_bus *bus, u32 mask, u32 value)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_control(&bus->chipco, mask, value);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_control);
+
+u32 ssb_gpio_intmask(struct ssb_bus *bus, u32 mask, u32 value)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_intmask(&bus->chipco, mask, value);
+	else if (ssb_extif_available(&bus->extif))
+		res = ssb_extif_gpio_intmask(&bus->extif, mask, value);
+	else
+		SSB_WARN_ON(1);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_intmask);
+
+u32 ssb_gpio_polarity(struct ssb_bus *bus, u32 mask, u32 value)
+{
+	unsigned long flags;
+	u32 res = 0;
+
+	spin_lock_irqsave(&bus->gpio_lock, flags);
+	if (ssb_chipco_available(&bus->chipco))
+		res = ssb_chipco_gpio_polarity(&bus->chipco, mask, value);
+	else if (ssb_extif_available(&bus->extif))
+		res = ssb_extif_gpio_polarity(&bus->extif, mask, value);
+	else
+		SSB_WARN_ON(1);
+	spin_unlock_irqrestore(&bus->gpio_lock, flags);
+
+	return res;
+}
+EXPORT_SYMBOL(ssb_gpio_polarity);
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index 9028ed5..bedb2b4 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -557,6 +557,7 @@ static int ssb_fetch_invariants(struct ssb_bus *bus,
 		goto out;
 	memcpy(&bus->boardinfo, &iv.boardinfo, sizeof(iv.boardinfo));
 	memcpy(&bus->sprom, &iv.sprom, sizeof(iv.sprom));
+	bus->has_cardbus_slot = iv.has_cardbus_slot;
 out:
 	return err;
 }
@@ -569,6 +570,9 @@ static int ssb_bus_register(struct ssb_bus *bus,
 
 	spin_lock_init(&bus->bar_lock);
 	INIT_LIST_HEAD(&bus->list);
+#ifdef CONFIG_SSB_EMBEDDED
+	spin_lock_init(&bus->gpio_lock);
+#endif
 
 	/* Powerup the bus */
 	err = ssb_pci_xtal(bus, SSB_GPIO_XTAL | SSB_GPIO_PLL, 1);
diff --git a/include/linux/ssb/ssb.h b/include/linux/ssb/ssb.h
index 9d5da8b..20add65 100644
--- a/include/linux/ssb/ssb.h
+++ b/include/linux/ssb/ssb.h
@@ -282,6 +282,13 @@ struct ssb_bus {
 	struct ssb_boardinfo boardinfo;
 	/* Contents of the SPROM. */
 	struct ssb_sprom sprom;
+	/* If the board has a cardbus slot, this is set to true. */
+	bool has_cardbus_slot;
+
+#ifdef CONFIG_SSB_EMBEDDED
+	/* Lock for GPIO register access. */
+	spinlock_t gpio_lock;
+#endif /* EMBEDDED */
 
 	/* Internal-only stuff follows. Do not touch. */
 	struct list_head list;
@@ -294,8 +301,13 @@ struct ssb_bus {
 
 /* The initialization-invariants. */
 struct ssb_init_invariants {
+	/* Versioning information about the PCB. */
 	struct ssb_boardinfo boardinfo;
+	/* The SPROM information. That's either stored in an
+	 * EEPROM or NVRAM on the board. */
 	struct ssb_sprom sprom;
+	/* If the board has a cardbus slot, this is set to true. */
+	bool has_cardbus_slot;
 };
 /* Type of function to fetch the invariants. */
 typedef int (*ssb_invariants_func_t)(struct ssb_bus *bus,
diff --git a/include/linux/ssb/ssb_driver_chipcommon.h b/include/linux/ssb/ssb_driver_chipcommon.h
index 4cb9954..536851b 100644
--- a/include/linux/ssb/ssb_driver_chipcommon.h
+++ b/include/linux/ssb/ssb_driver_chipcommon.h
@@ -51,9 +51,12 @@
 #define  SSB_CHIPCO_CAP_JTAGM		0x00400000	/* JTAG master present */
 #define  SSB_CHIPCO_CAP_BROM		0x00800000	/* Internal boot ROM active */
 #define  SSB_CHIPCO_CAP_64BIT		0x08000000	/* 64-bit Backplane */
+#define  SSB_CHIPCO_CAP_PMU		0x10000000	/* PMU available (rev >= 20) */
+#define  SSB_CHIPCO_CAP_ECI		0x20000000	/* ECI available (rev >= 20) */
 #define SSB_CHIPCO_CORECTL		0x0008
 #define  SSB_CHIPCO_CORECTL_UARTCLK0	0x00000001	/* Drive UART with internal clock */
 #define	 SSB_CHIPCO_CORECTL_SE		0x00000002	/* sync clk out enable (corerev >= 3) */
+#define  SSB_CHIPCO_CORECTL_UARTCLKEN	0x00000008	/* UART clock enable (rev >= 21) */
 #define SSB_CHIPCO_BIST			0x000C
 #define SSB_CHIPCO_OTPS			0x0010		/* OTP status */
 #define	 SSB_CHIPCO_OTPS_PROGFAIL	0x80000000
@@ -357,6 +360,11 @@ struct ssb_chipcommon {
 	u16 fast_pwrup_delay;
 };
 
+static inline bool ssb_chipco_available(struct ssb_chipcommon *cc)
+{
+	return (cc->dev != NULL);
+}
+
 extern void ssb_chipcommon_init(struct ssb_chipcommon *cc);
 
 #include <linux/pm.h>
@@ -382,11 +390,13 @@ extern void ssb_chipco_set_clockmode(struct ssb_chipcommon *cc,
 extern void ssb_chipco_watchdog_timer_set(struct ssb_chipcommon *cc,
 					  u32 ticks);
 
+/* Chipcommon GPIO pin access. */
 u32 ssb_chipco_gpio_in(struct ssb_chipcommon *cc, u32 mask);
-
-void ssb_chipco_gpio_out(struct ssb_chipcommon *cc, u32 mask, u32 value);
-
-void ssb_chipco_gpio_outen(struct ssb_chipcommon *cc, u32 mask, u32 value);
+u32 ssb_chipco_gpio_out(struct ssb_chipcommon *cc, u32 mask, u32 value);
+u32 ssb_chipco_gpio_outen(struct ssb_chipcommon *cc, u32 mask, u32 value);
+u32 ssb_chipco_gpio_control(struct ssb_chipcommon *cc, u32 mask, u32 value);
+u32 ssb_chipco_gpio_intmask(struct ssb_chipcommon *cc, u32 mask, u32 value);
+u32 ssb_chipco_gpio_polarity(struct ssb_chipcommon *cc, u32 mask, u32 value);
 
 #ifdef CONFIG_SSB_SERIAL
 extern int ssb_chipco_serial_init(struct ssb_chipcommon *cc,
diff --git a/include/linux/ssb/ssb_driver_extif.h b/include/linux/ssb/ssb_driver_extif.h
index a916435..91161f0 100644
--- a/include/linux/ssb/ssb_driver_extif.h
+++ b/include/linux/ssb/ssb_driver_extif.h
@@ -171,11 +171,15 @@ extern void ssb_extif_get_clockcontrol(struct ssb_extif *extif,
 extern void ssb_extif_timing_init(struct ssb_extif *extif,
 				  unsigned long ns);
 
-u32 ssb_extif_gpio_in(struct ssb_extif *extif, u32 mask);
-
-void ssb_extif_gpio_out(struct ssb_extif *extif, u32 mask, u32 value);
+extern void ssb_extif_watchdog_timer_set(struct ssb_extif *extif,
+					 u32 ticks);
 
-void ssb_extif_gpio_outen(struct ssb_extif *extif, u32 mask, u32 value);
+/* Extif GPIO pin access */
+u32 ssb_extif_gpio_in(struct ssb_extif *extif, u32 mask);
+u32 ssb_extif_gpio_out(struct ssb_extif *extif, u32 mask, u32 value);
+u32 ssb_extif_gpio_outen(struct ssb_extif *extif, u32 mask, u32 value);
+u32 ssb_extif_gpio_polarity(struct ssb_extif *extif, u32 mask, u32 value);
+u32 ssb_extif_gpio_intmask(struct ssb_extif *extif, u32 mask, u32 value);
 
 #ifdef CONFIG_SSB_SERIAL
 extern int ssb_extif_serial_init(struct ssb_extif *extif,
@@ -200,5 +204,11 @@ void ssb_extif_get_clockcontrol(struct ssb_extif *extif,
 {
 }
 
+static inline
+void ssb_extif_watchdog_timer_set(struct ssb_extif *extif,
+				  u32 ticks)
+{
+}
+
 #endif /* CONFIG_SSB_DRIVER_EXTIF */
 #endif /* LINUX_SSB_EXTIFCORE_H_ */
diff --git a/include/linux/ssb/ssb_driver_pci.h b/include/linux/ssb/ssb_driver_pci.h
index 9cfffb7..5e25bac 100644
--- a/include/linux/ssb/ssb_driver_pci.h
+++ b/include/linux/ssb/ssb_driver_pci.h
@@ -51,6 +51,11 @@
 #define  SSB_PCICORE_SBTOPCI1_MASK	0xFC000000
 #define SSB_PCICORE_SBTOPCI2		0x0108	/* Backplane to PCI translation 2 (sbtopci2) */
 #define  SSB_PCICORE_SBTOPCI2_MASK	0xC0000000
+#define SSB_PCICORE_PCICFG0		0x0400	/* PCI config space 0 (rev >= 8) */
+#define SSB_PCICORE_PCICFG1		0x0500	/* PCI config space 1 (rev >= 8) */
+#define SSB_PCICORE_PCICFG2		0x0600	/* PCI config space 2 (rev >= 8) */
+#define SSB_PCICORE_PCICFG3		0x0700	/* PCI config space 3 (rev >= 8) */
+#define SSB_PCICORE_SPROM(wordoffset)	(0x0800 + ((wordoffset) * 2)) /* SPROM shadow area (72 bytes) */
 
 /* SBtoPCIx */
 #define SSB_PCICORE_SBTOPCI_MEM		0x00000000
diff --git a/include/linux/ssb/ssb_embedded.h b/include/linux/ssb/ssb_embedded.h
new file mode 100644
index 0000000..8d8dedf
--- /dev/null
+++ b/include/linux/ssb/ssb_embedded.h
@@ -0,0 +1,18 @@
+#ifndef LINUX_SSB_EMBEDDED_H_
+#define LINUX_SSB_EMBEDDED_H_
+
+#include <linux/types.h>
+#include <linux/ssb/ssb.h>
+
+
+extern int ssb_watchdog_timer_set(struct ssb_bus *bus, u32 ticks);
+
+/* Generic GPIO API */
+u32 ssb_gpio_in(struct ssb_bus *bus, u32 mask);
+u32 ssb_gpio_out(struct ssb_bus *bus, u32 mask, u32 value);
+u32 ssb_gpio_outen(struct ssb_bus *bus, u32 mask, u32 value);
+u32 ssb_gpio_control(struct ssb_bus *bus, u32 mask, u32 value);
+u32 ssb_gpio_intmask(struct ssb_bus *bus, u32 mask, u32 value);
+u32 ssb_gpio_polarity(struct ssb_bus *bus, u32 mask, u32 value);
+
+#endif /* LINUX_SSB_EMBEDDED_H_ */
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
