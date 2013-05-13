From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] ath5k: Remove AHB bus support.
Date: Mon, 13 May 2013 17:03:11 +0200
Message-ID: <1368457391.1350.67.camel@x61.thuisdomein>
References: <1320756113.14409.385.camel@x61.thuisdomein>
	 <20111108141647.GA3390@hash.lan>
	 <1342124352.22584.21.camel@x61.thuisdomein>
	 <20120712203837.GA3045@localhost> <4FFFBDD8.6020305@neratec.com>
	 <20120713124134.GA5567@localhost>
	 <1362999998.3137.60.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bob Copeland <me@bobcopeland.com>,
	Wojciech Dubowik <Wojciech.Dubowik@neratec.com>,
	nbd@openwrt.org, ath5k-devel@lists.ath5k.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362999998.3137.60.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AHB bus support was added in v2.6.38, through commit a0b907ee2a ("ath5k:
Add AHB bus support."). That code can only be build if the Kconfig
symbol ATHEROS_AR231X is set. But that symbol has never been added to
the tree. So AHB bus support has always been dead code.

Let's remove all code that depends on ATHEROS_AR231X. If that symbol
ever gets added to the tree the AHB bus support can be re-added too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) Compile tested (I do not think I have hardware that use the ath5k
driver).

1) I mentioned the missing ATHEROS_AR231X symbol three times before (in
August 2011, in July 2012 and in March 2103). Nobody stepped forward to
tell me they were actually working on adding that symbol somehow. So
let's see how people react when I submit a patch to remove the (dead)
AHB bus support.

 drivers/net/wireless/ath/ath5k/Kconfig  |  14 +-
 drivers/net/wireless/ath/ath5k/Makefile |   1 -
 drivers/net/wireless/ath/ath5k/ahb.c    | 239 --------------------------------
 drivers/net/wireless/ath/ath5k/ath5k.h  |  28 ----
 drivers/net/wireless/ath/ath5k/base.c   |  14 --
 drivers/net/wireless/ath/ath5k/led.c    |   6 -
 6 files changed, 3 insertions(+), 299 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath5k/ahb.c

diff --git a/drivers/net/wireless/ath/ath5k/Kconfig b/drivers/net/wireless/ath/ath5k/Kconfig
index c9f81a3..93caf8e68 100644
--- a/drivers/net/wireless/ath/ath5k/Kconfig
+++ b/drivers/net/wireless/ath/ath5k/Kconfig
@@ -1,13 +1,12 @@
 config ATH5K
 	tristate "Atheros 5xxx wireless cards support"
-	depends on (PCI || ATHEROS_AR231X) && MAC80211
+	depends on PCI && MAC80211
 	select ATH_COMMON
 	select MAC80211_LEDS
 	select LEDS_CLASS
 	select NEW_LEDS
 	select AVERAGE
-	select ATH5K_AHB if (ATHEROS_AR231X && !PCI)
-	select ATH5K_PCI if (!ATHEROS_AR231X && PCI)
+	select ATH5K_PCI
 	---help---
 	  This module adds support for wireless adapters based on
 	  Atheros 5xxx chipset.
@@ -52,16 +51,9 @@ config ATH5K_TRACER
 
 	  If unsure, say N.
 
-config ATH5K_AHB
-	bool "Atheros 5xxx AHB bus support"
-	depends on (ATHEROS_AR231X && !PCI)
-	---help---
-	  This adds support for WiSoC type chipsets of the 5xxx Atheros
-	  family.
-
 config ATH5K_PCI
 	bool "Atheros 5xxx PCI bus support"
-	depends on (!ATHEROS_AR231X && PCI)
+	depends on PCI
 	---help---
 	  This adds support for PCI type chipsets of the 5xxx Atheros
 	  family.
diff --git a/drivers/net/wireless/ath/ath5k/Makefile b/drivers/net/wireless/ath/ath5k/Makefile
index 1b3a34f..51e2d86 100644
--- a/drivers/net/wireless/ath/ath5k/Makefile
+++ b/drivers/net/wireless/ath/ath5k/Makefile
@@ -17,6 +17,5 @@ ath5k-y				+= ani.o
 ath5k-y				+= sysfs.o
 ath5k-y				+= mac80211-ops.o
 ath5k-$(CONFIG_ATH5K_DEBUG)	+= debug.o
-ath5k-$(CONFIG_ATH5K_AHB)	+= ahb.o
 ath5k-$(CONFIG_ATH5K_PCI)	+= pci.o
 obj-$(CONFIG_ATH5K)		+= ath5k.o
diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
deleted file mode 100644
index 8e8bcc7a..0000000
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ /dev/null
@@ -1,239 +0,0 @@
-/*
- * Copyright (c) 2008-2009 Atheros Communications Inc.
- * Copyright (c) 2009 Gabor Juhos <juhosg@openwrt.org>
- * Copyright (c) 2009 Imre Kaloz <kaloz@openwrt.org>
- *
- * Permission to use, copy, modify, and/or distribute this software for any
- * purpose with or without fee is hereby granted, provided that the above
- * copyright notice and this permission notice appear in all copies.
- *
- * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
- * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
- * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
- * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
- * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
- * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
- * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
- */
-
-#include <linux/nl80211.h>
-#include <linux/platform_device.h>
-#include <linux/etherdevice.h>
-#include <linux/export.h>
-#include <ar231x_platform.h>
-#include "ath5k.h"
-#include "debug.h"
-#include "base.h"
-#include "reg.h"
-
-/* return bus cachesize in 4B word units */
-static void ath5k_ahb_read_cachesize(struct ath_common *common, int *csz)
-{
-	*csz = L1_CACHE_BYTES >> 2;
-}
-
-static bool
-ath5k_ahb_eeprom_read(struct ath_common *common, u32 off, u16 *data)
-{
-	struct ath5k_hw *ah = common->priv;
-	struct platform_device *pdev = to_platform_device(ah->dev);
-	struct ar231x_board_config *bcfg = pdev->dev.platform_data;
-	u16 *eeprom, *eeprom_end;
-
-
-
-	bcfg = pdev->dev.platform_data;
-	eeprom = (u16 *) bcfg->radio;
-	eeprom_end = ((void *) bcfg->config) + BOARD_CONFIG_BUFSZ;
-
-	eeprom += off;
-	if (eeprom > eeprom_end)
-		return false;
-
-	*data = *eeprom;
-	return true;
-}
-
-int ath5k_hw_read_srev(struct ath5k_hw *ah)
-{
-	struct platform_device *pdev = to_platform_device(ah->dev);
-	struct ar231x_board_config *bcfg = pdev->dev.platform_data;
-	ah->ah_mac_srev = bcfg->devid;
-	return 0;
-}
-
-static int ath5k_ahb_eeprom_read_mac(struct ath5k_hw *ah, u8 *mac)
-{
-	struct platform_device *pdev = to_platform_device(ah->dev);
-	struct ar231x_board_config *bcfg = pdev->dev.platform_data;
-	u8 *cfg_mac;
-
-	if (to_platform_device(ah->dev)->id == 0)
-		cfg_mac = bcfg->config->wlan0_mac;
-	else
-		cfg_mac = bcfg->config->wlan1_mac;
-
-	memcpy(mac, cfg_mac, ETH_ALEN);
-	return 0;
-}
-
-static const struct ath_bus_ops ath_ahb_bus_ops = {
-	.ath_bus_type = ATH_AHB,
-	.read_cachesize = ath5k_ahb_read_cachesize,
-	.eeprom_read = ath5k_ahb_eeprom_read,
-	.eeprom_read_mac = ath5k_ahb_eeprom_read_mac,
-};
-
-/*Initialization*/
-static int ath_ahb_probe(struct platform_device *pdev)
-{
-	struct ar231x_board_config *bcfg = pdev->dev.platform_data;
-	struct ath5k_hw *ah;
-	struct ieee80211_hw *hw;
-	struct resource *res;
-	void __iomem *mem;
-	int irq;
-	int ret = 0;
-	u32 reg;
-
-	if (!pdev->dev.platform_data) {
-		dev_err(&pdev->dev, "no platform data specified\n");
-		ret = -EINVAL;
-		goto err_out;
-	}
-
-	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-	if (res == NULL) {
-		dev_err(&pdev->dev, "no memory resource found\n");
-		ret = -ENXIO;
-		goto err_out;
-	}
-
-	mem = ioremap_nocache(res->start, resource_size(res));
-	if (mem == NULL) {
-		dev_err(&pdev->dev, "ioremap failed\n");
-		ret = -ENOMEM;
-		goto err_out;
-	}
-
-	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-	if (res == NULL) {
-		dev_err(&pdev->dev, "no IRQ resource found\n");
-		ret = -ENXIO;
-		goto err_iounmap;
-	}
-
-	irq = res->start;
-
-	hw = ieee80211_alloc_hw(sizeof(struct ath5k_hw), &ath5k_hw_ops);
-	if (hw == NULL) {
-		dev_err(&pdev->dev, "no memory for ieee80211_hw\n");
-		ret = -ENOMEM;
-		goto err_iounmap;
-	}
-
-	ah = hw->priv;
-	ah->hw = hw;
-	ah->dev = &pdev->dev;
-	ah->iobase = mem;
-	ah->irq = irq;
-	ah->devid = bcfg->devid;
-
-	if (bcfg->devid >= AR5K_SREV_AR2315_R6) {
-		/* Enable WMAC AHB arbitration */
-		reg = ioread32((void __iomem *) AR5K_AR2315_AHB_ARB_CTL);
-		reg |= AR5K_AR2315_AHB_ARB_CTL_WLAN;
-		iowrite32(reg, (void __iomem *) AR5K_AR2315_AHB_ARB_CTL);
-
-		/* Enable global WMAC swapping */
-		reg = ioread32((void __iomem *) AR5K_AR2315_BYTESWAP);
-		reg |= AR5K_AR2315_BYTESWAP_WMAC;
-		iowrite32(reg, (void __iomem *) AR5K_AR2315_BYTESWAP);
-	} else {
-		/* Enable WMAC DMA access (assuming 5312 or 231x*/
-		/* TODO: check other platforms */
-		reg = ioread32((void __iomem *) AR5K_AR5312_ENABLE);
-		if (to_platform_device(ah->dev)->id == 0)
-			reg |= AR5K_AR5312_ENABLE_WLAN0;
-		else
-			reg |= AR5K_AR5312_ENABLE_WLAN1;
-		iowrite32(reg, (void __iomem *) AR5K_AR5312_ENABLE);
-
-		/*
-		 * On a dual-band AR5312, the multiband radio is only
-		 * used as pass-through. Disable 2 GHz support in the
-		 * driver for it
-		 */
-		if (to_platform_device(ah->dev)->id == 0 &&
-		    (bcfg->config->flags & (BD_WLAN0 | BD_WLAN1)) ==
-		     (BD_WLAN1 | BD_WLAN0))
-			ah->ah_capabilities.cap_needs_2GHz_ovr = true;
-		else
-			ah->ah_capabilities.cap_needs_2GHz_ovr = false;
-	}
-
-	ret = ath5k_init_ah(ah, &ath_ahb_bus_ops);
-	if (ret != 0) {
-		dev_err(&pdev->dev, "failed to attach device, err=%d\n", ret);
-		ret = -ENODEV;
-		goto err_free_hw;
-	}
-
-	platform_set_drvdata(pdev, hw);
-
-	return 0;
-
- err_free_hw:
-	ieee80211_free_hw(hw);
-	platform_set_drvdata(pdev, NULL);
- err_iounmap:
-        iounmap(mem);
- err_out:
-	return ret;
-}
-
-static int ath_ahb_remove(struct platform_device *pdev)
-{
-	struct ar231x_board_config *bcfg = pdev->dev.platform_data;
-	struct ieee80211_hw *hw = platform_get_drvdata(pdev);
-	struct ath5k_hw *ah;
-	u32 reg;
-
-	if (!hw)
-		return 0;
-
-	ah = hw->priv;
-
-	if (bcfg->devid >= AR5K_SREV_AR2315_R6) {
-		/* Disable WMAC AHB arbitration */
-		reg = ioread32((void __iomem *) AR5K_AR2315_AHB_ARB_CTL);
-		reg &= ~AR5K_AR2315_AHB_ARB_CTL_WLAN;
-		iowrite32(reg, (void __iomem *) AR5K_AR2315_AHB_ARB_CTL);
-	} else {
-		/*Stop DMA access */
-		reg = ioread32((void __iomem *) AR5K_AR5312_ENABLE);
-		if (to_platform_device(ah->dev)->id == 0)
-			reg &= ~AR5K_AR5312_ENABLE_WLAN0;
-		else
-			reg &= ~AR5K_AR5312_ENABLE_WLAN1;
-		iowrite32(reg, (void __iomem *) AR5K_AR5312_ENABLE);
-	}
-
-	ath5k_deinit_ah(ah);
-	iounmap(ah->iobase);
-	platform_set_drvdata(pdev, NULL);
-	ieee80211_free_hw(hw);
-
-	return 0;
-}
-
-static struct platform_driver ath_ahb_driver = {
-	.probe      = ath_ahb_probe,
-	.remove     = ath_ahb_remove,
-	.driver		= {
-		.name	= "ar231x-wmac",
-		.owner	= THIS_MODULE,
-	},
-};
-
-module_platform_driver(ath_ahb_driver);
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index 2d691b8..deaedb8 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -1645,32 +1645,6 @@ static inline struct ath_regulatory *ath5k_hw_regulatory(struct ath5k_hw *ah)
 	return &(ath5k_hw_common(ah)->regulatory);
 }
 
-#ifdef CONFIG_ATHEROS_AR231X
-#define AR5K_AR2315_PCI_BASE	((void __iomem *)0xb0100000)
-
-static inline void __iomem *ath5k_ahb_reg(struct ath5k_hw *ah, u16 reg)
-{
-	/* On AR2315 and AR2317 the PCI clock domain registers
-	 * are outside of the WMAC register space */
-	if (unlikely((reg >= 0x4000) && (reg < 0x5000) &&
-	    (ah->ah_mac_srev >= AR5K_SREV_AR2315_R6)))
-		return AR5K_AR2315_PCI_BASE + reg;
-
-	return ah->iobase + reg;
-}
-
-static inline u32 ath5k_hw_reg_read(struct ath5k_hw *ah, u16 reg)
-{
-	return ioread32(ath5k_ahb_reg(ah, reg));
-}
-
-static inline void ath5k_hw_reg_write(struct ath5k_hw *ah, u32 val, u16 reg)
-{
-	iowrite32(val, ath5k_ahb_reg(ah, reg));
-}
-
-#else
-
 static inline u32 ath5k_hw_reg_read(struct ath5k_hw *ah, u16 reg)
 {
 	return ioread32(ah->iobase + reg);
@@ -1681,8 +1655,6 @@ static inline void ath5k_hw_reg_write(struct ath5k_hw *ah, u32 val, u16 reg)
 	iowrite32(val, ah->iobase + reg);
 }
 
-#endif
-
 static inline enum ath_bus_type ath5k_get_bus_type(struct ath5k_hw *ah)
 {
 	return ath5k_hw_common(ah)->bus_ops->ath_bus_type;
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 9b20d9e..654cc3d 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -97,15 +97,6 @@ static int ath5k_reset(struct ath5k_hw *ah, struct ieee80211_channel *chan,
 
 /* Known SREVs */
 static const struct ath5k_srev_name srev_names[] = {
-#ifdef CONFIG_ATHEROS_AR231X
-	{ "5312",	AR5K_VERSION_MAC,	AR5K_SREV_AR5312_R2 },
-	{ "5312",	AR5K_VERSION_MAC,	AR5K_SREV_AR5312_R7 },
-	{ "2313",	AR5K_VERSION_MAC,	AR5K_SREV_AR2313_R8 },
-	{ "2315",	AR5K_VERSION_MAC,	AR5K_SREV_AR2315_R6 },
-	{ "2315",	AR5K_VERSION_MAC,	AR5K_SREV_AR2315_R7 },
-	{ "2317",	AR5K_VERSION_MAC,	AR5K_SREV_AR2317_R1 },
-	{ "2317",	AR5K_VERSION_MAC,	AR5K_SREV_AR2317_R2 },
-#else
 	{ "5210",	AR5K_VERSION_MAC,	AR5K_SREV_AR5210 },
 	{ "5311",	AR5K_VERSION_MAC,	AR5K_SREV_AR5311 },
 	{ "5311A",	AR5K_VERSION_MAC,	AR5K_SREV_AR5311A },
@@ -124,7 +115,6 @@ static const struct ath5k_srev_name srev_names[] = {
 	{ "5418",	AR5K_VERSION_MAC,	AR5K_SREV_AR5418 },
 	{ "2425",	AR5K_VERSION_MAC,	AR5K_SREV_AR2425 },
 	{ "2417",	AR5K_VERSION_MAC,	AR5K_SREV_AR2417 },
-#endif
 	{ "xxxxx",	AR5K_VERSION_MAC,	AR5K_SREV_UNKNOWN },
 	{ "5110",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5110 },
 	{ "5111",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5111 },
@@ -140,10 +130,6 @@ static const struct ath5k_srev_name srev_names[] = {
 	{ "5413",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5413 },
 	{ "5424",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5424 },
 	{ "5133",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_5133 },
-#ifdef CONFIG_ATHEROS_AR231X
-	{ "2316",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_2316 },
-	{ "2317",	AR5K_VERSION_RAD,	AR5K_SREV_RAD_2317 },
-#endif
 	{ "xxxxx",	AR5K_VERSION_RAD,	AR5K_SREV_UNKNOWN },
 };
 
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index f77ef36..dbf2483 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -162,20 +162,14 @@ int ath5k_init_leds(struct ath5k_hw *ah)
 {
 	int ret = 0;
 	struct ieee80211_hw *hw = ah->hw;
-#ifndef CONFIG_ATHEROS_AR231X
 	struct pci_dev *pdev = ah->pdev;
-#endif
 	char name[ATH5K_LED_MAX_NAME_LEN + 1];
 	const struct pci_device_id *match;
 
 	if (!ah->pdev)
 		return 0;
 
-#ifdef CONFIG_ATHEROS_AR231X
-	match = NULL;
-#else
 	match = pci_match_id(&ath5k_led_devices[0], pdev);
-#endif
 	if (match) {
 		__set_bit(ATH_STAT_LEDSOFT, ah->status);
 		ah->led_pin = ATH_PIN(match->driver_data);
-- 
1.7.11.7
