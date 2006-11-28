From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull from 'upstream' branch of wireless-2.6
Date: Tue, 28 Nov 2006 14:42:34 -0500
Message-ID: <20061128194234.GF16533@tuxdriver.com>
References: <20061128194016.GE16533@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:5390 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S936072AbWK1TnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 14:43:11 -0500
To: jeff@garzik.org
Content-Disposition: inline
In-Reply-To: <20061128194016.GE16533@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 6c025cfcd2904990ba9acda820fda1fe02ee267f:
  John W. Linville:
        Merge branch 'upstream-fixes' into upstream

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Arnaldo Carvalho de Melo:
      Check ieee80211softmac_auth_resp kmalloc result

Daniel Drake:
      zd1211rw: Add ID for Planex GW-US54Mini
      zd1211rw: Add ID for Belkin F5D7050 v4000
      zd1211rw: Remove IW_FREQ_AUTO support
      zd1211rw: Allow channels 1-13 in Japan
      zd1211rw: Rename cs_rate to zd_rate
      zd1211rw: Use softmac ERP handling functionality
      ieee80211: Provide generic get_stats implementation

John W. Linville:
      prism54: correct overly aggressive check of return from pci_set_mwi

Larry Finger:
      bcm43xx: correct "Move IV/ICV stripping into ieee80211_rx"
      softmac: reduce scan debug output

Ulrich Kunitz:
      zd1211rw: cleanups
      zd1211rw: Optimized handling of zero length entries in length info

 drivers/net/wireless/bcm43xx/bcm43xx_main.c   |    6 
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c   |    1 
 drivers/net/wireless/ipw2100.c                |   14 -
 drivers/net/wireless/prism54/islpci_hotplug.c |    4 
 drivers/net/wireless/zd1211rw/zd_chip.c       |   38 ++
 drivers/net/wireless/zd1211rw/zd_chip.h       |  104 ++++--
 drivers/net/wireless/zd1211rw/zd_def.h        |    1 
 drivers/net/wireless/zd1211rw/zd_ieee80211.c  |   10 -
 drivers/net/wireless/zd1211rw/zd_ieee80211.h  |    1 
 drivers/net/wireless/zd1211rw/zd_mac.c        |  402 +++++++++++++++----------
 drivers/net/wireless/zd1211rw/zd_mac.h        |   34 ++
 drivers/net/wireless/zd1211rw/zd_netdev.c     |   13 -
 drivers/net/wireless/zd1211rw/zd_usb.c        |   15 +
 net/ieee80211/ieee80211_module.c              |   16 +
 net/ieee80211/ieee80211_rx.c                  |    7 
 net/ieee80211/softmac/ieee80211softmac_auth.c |   14 +
 net/ieee80211/softmac/ieee80211softmac_scan.c |    5 
 17 files changed, 413 insertions(+), 272 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 60a9745..5b3c273 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -4013,11 +4013,6 @@ static int bcm43xx_ieee80211_hard_start_
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats * bcm43xx_net_get_stats(struct net_device *net_dev)
-{
-	return &(bcm43xx_priv(net_dev)->ieee->stats);
-}
-
 static void bcm43xx_net_tx_timeout(struct net_device *net_dev)
 {
 	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
@@ -4131,7 +4126,6 @@ #endif
 
 	net_dev->open = bcm43xx_net_open;
 	net_dev->stop = bcm43xx_net_stop;
-	net_dev->get_stats = bcm43xx_net_get_stats;
 	net_dev->tx_timeout = bcm43xx_net_tx_timeout;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	net_dev->poll_controller = bcm43xx_net_poll_controller;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index a957bc8..3e24626 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
 		break;
 	}
 
+	frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
 	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
 	case IEEE80211_FTYPE_MGMT:
 		ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 2324e06..a576a81 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -5827,19 +5827,6 @@ #endif
 	schedule_reset(priv);
 }
 
-/*
- * TODO: reimplement it so that it reads statistics
- *       from the adapter using ordinal tables
- *       instead of/in addition to collecting them
- *       in the driver
- */
-static struct net_device_stats *ipw2100_stats(struct net_device *dev)
-{
-	struct ipw2100_priv *priv = ieee80211_priv(dev);
-
-	return &priv->ieee->stats;
-}
-
 static int ipw2100_wpa_enable(struct ipw2100_priv *priv, int value)
 {
 	/* This is called when wpa_supplicant loads and closes the driver
@@ -6022,7 +6009,6 @@ static struct net_device *ipw2100_alloc_
 	dev->open = ipw2100_open;
 	dev->stop = ipw2100_close;
 	dev->init = ipw2100_net_init;
-	dev->get_stats = ipw2100_stats;
 	dev->ethtool_ops = &ipw2100_ethtool_ops;
 	dev->tx_timeout = ipw2100_tx_timeout;
 	dev->wireless_handlers = &ipw2100_wx_handler_def;
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index e0bca3a..58257b4 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -170,8 +170,8 @@ #endif
 	pci_set_master(pdev);
 
 	/* enable MWI */
-	if (pci_set_mwi(pdev))
-		goto do_pci_release_regions;
+	if (!pci_set_mwi(pdev))
+		printk(KERN_INFO "%s: pci_set_mwi(pdev) succeeded\n", DRV_NAME);
 
 	/* setup the network device interface and its structure */
 	if (!(ndev = islpci_setup(pdev))) {
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index aa661b2..8be99eb 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1076,6 +1076,31 @@ static int set_mandatory_rates(struct zd
 	return zd_iowrite32_locked(chip, rates, CR_MANDATORY_RATE_TBL);
 }
 
+int zd_chip_set_rts_cts_rate_locked(struct zd_chip *chip,
+	u8 rts_rate, int preamble)
+{
+	int rts_mod = ZD_RX_CCK;
+	u32 value = 0;
+
+	/* Modulation bit */
+	if (ZD_CS_TYPE(rts_rate) == ZD_CS_OFDM)
+		rts_mod = ZD_RX_OFDM;
+
+	dev_dbg_f(zd_chip_dev(chip), "rts_rate=%x preamble=%x\n",
+		rts_rate, preamble);
+
+	value |= rts_rate << RTSCTS_SH_RTS_RATE;
+	value |= rts_mod << RTSCTS_SH_RTS_MOD_TYPE;
+	value |= preamble << RTSCTS_SH_RTS_PMB_TYPE;
+	value |= preamble << RTSCTS_SH_CTS_PMB_TYPE;
+
+	/* We always send 11M self-CTS messages, like the vendor driver. */
+	value |= ZD_CCK_RATE_11M << RTSCTS_SH_CTS_RATE;
+	value |= ZD_RX_CCK << RTSCTS_SH_CTS_MOD_TYPE;
+
+	return zd_iowrite32_locked(chip, value, CR_RTS_CTS_RATE);
+}
+
 int zd_chip_enable_hwint(struct zd_chip *chip)
 {
 	int r;
@@ -1355,17 +1380,12 @@ out:
 	return r;
 }
 
-int zd_chip_set_basic_rates(struct zd_chip *chip, u16 cr_rates)
+int zd_chip_set_basic_rates_locked(struct zd_chip *chip, u16 cr_rates)
 {
-	int r;
-
-	if (cr_rates & ~(CR_RATES_80211B|CR_RATES_80211G))
-		return -EINVAL;
+	ZD_ASSERT((cr_rates & ~(CR_RATES_80211B | CR_RATES_80211G)) == 0);
+	dev_dbg_f(zd_chip_dev(chip), "%x\n", cr_rates);
 
-	mutex_lock(&chip->mutex);
-	r = zd_iowrite32_locked(chip, cr_rates, CR_BASIC_RATE_TBL);
-	mutex_unlock(&chip->mutex);
-	return r;
+	return zd_iowrite32_locked(chip, cr_rates, CR_BASIC_RATE_TBL);
 }
 
 static int ofdm_qual_db(u8 status_quality, u8 rate, unsigned int size)
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index ae59597..ca892b9 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -337,24 +337,24 @@ #define CR_ADDA_MBIAS_WARMTIME		CTL_REG(
 #define CR_MAC_PS_STATE			CTL_REG(0x050C)
 
 #define CR_INTERRUPT			CTL_REG(0x0510)
-#define INT_TX_COMPLETE			0x00000001
-#define INT_RX_COMPLETE			0x00000002
-#define INT_RETRY_FAIL			0x00000004
-#define INT_WAKEUP			0x00000008
-#define INT_DTIM_NOTIFY			0x00000020
-#define INT_CFG_NEXT_BCN		0x00000040
-#define INT_BUS_ABORT			0x00000080
-#define INT_TX_FIFO_READY		0x00000100
-#define INT_UART			0x00000200
-#define INT_TX_COMPLETE_EN		0x00010000
-#define INT_RX_COMPLETE_EN		0x00020000
-#define INT_RETRY_FAIL_EN		0x00040000
-#define INT_WAKEUP_EN			0x00080000
-#define INT_DTIM_NOTIFY_EN		0x00200000
-#define INT_CFG_NEXT_BCN_EN		0x00400000
-#define INT_BUS_ABORT_EN		0x00800000
-#define INT_TX_FIFO_READY_EN		0x01000000
-#define INT_UART_EN			0x02000000
+#define INT_TX_COMPLETE			(1 <<  0)
+#define INT_RX_COMPLETE			(1 <<  1)
+#define INT_RETRY_FAIL			(1 <<  2)
+#define INT_WAKEUP			(1 <<  3)
+#define INT_DTIM_NOTIFY			(1 <<  5)
+#define INT_CFG_NEXT_BCN		(1 <<  6)
+#define INT_BUS_ABORT			(1 <<  7)
+#define INT_TX_FIFO_READY		(1 <<  8)
+#define INT_UART			(1 <<  9)
+#define INT_TX_COMPLETE_EN		(1 << 16)
+#define INT_RX_COMPLETE_EN		(1 << 17)
+#define INT_RETRY_FAIL_EN		(1 << 18)
+#define INT_WAKEUP_EN			(1 << 19)
+#define INT_DTIM_NOTIFY_EN		(1 << 21)
+#define INT_CFG_NEXT_BCN_EN		(1 << 22)
+#define INT_BUS_ABORT_EN		(1 << 23)
+#define INT_TX_FIFO_READY_EN		(1 << 24)
+#define INT_UART_EN			(1 << 25)
 
 #define CR_TSF_LOW_PART			CTL_REG(0x0514)
 #define CR_TSF_HIGH_PART		CTL_REG(0x0518)
@@ -398,18 +398,18 @@ #define CR_RX_TIMEOUT			CTL_REG(0x062C)
  * device will use a rate in this table that is less than or equal to the rate
  * of the incoming frame which prompted the response */
 #define CR_BASIC_RATE_TBL		CTL_REG(0x0630)
-#define CR_RATE_1M	0x0001	/* 802.11b */
-#define CR_RATE_2M	0x0002	/* 802.11b */
-#define CR_RATE_5_5M	0x0004	/* 802.11b */
-#define CR_RATE_11M	0x0008	/* 802.11b */
-#define CR_RATE_6M      0x0100	/* 802.11g */
-#define CR_RATE_9M      0x0200	/* 802.11g */
-#define CR_RATE_12M	0x0400	/* 802.11g */
-#define CR_RATE_18M	0x0800	/* 802.11g */
-#define CR_RATE_24M     0x1000	/* 802.11g */
-#define CR_RATE_36M     0x2000	/* 802.11g */
-#define CR_RATE_48M     0x4000	/* 802.11g */
-#define CR_RATE_54M     0x8000	/* 802.11g */
+#define CR_RATE_1M	(1 <<  0)	/* 802.11b */
+#define CR_RATE_2M	(1 <<  1)	/* 802.11b */
+#define CR_RATE_5_5M	(1 <<  2)	/* 802.11b */
+#define CR_RATE_11M	(1 <<  3)	/* 802.11b */
+#define CR_RATE_6M      (1 <<  8)	/* 802.11g */
+#define CR_RATE_9M      (1 <<  9)	/* 802.11g */
+#define CR_RATE_12M	(1 << 10)	/* 802.11g */
+#define CR_RATE_18M	(1 << 11)	/* 802.11g */
+#define CR_RATE_24M     (1 << 12)	/* 802.11g */
+#define CR_RATE_36M     (1 << 13)	/* 802.11g */
+#define CR_RATE_48M     (1 << 14)	/* 802.11g */
+#define CR_RATE_54M     (1 << 15)	/* 802.11g */
 #define CR_RATES_80211G	0xff00
 #define CR_RATES_80211B	0x000f
 
@@ -420,15 +420,24 @@ #define CR_RATES_80211B	0x000f
 #define CR_MANDATORY_RATE_TBL		CTL_REG(0x0634)
 #define CR_RTS_CTS_RATE			CTL_REG(0x0638)
 
+/* These are all bit indexes in CR_RTS_CTS_RATE, so remember to shift. */
+#define RTSCTS_SH_RTS_RATE		0
+#define RTSCTS_SH_EXP_CTS_RATE		4
+#define RTSCTS_SH_RTS_MOD_TYPE		8
+#define RTSCTS_SH_RTS_PMB_TYPE		9
+#define RTSCTS_SH_CTS_RATE		16
+#define RTSCTS_SH_CTS_MOD_TYPE		24
+#define RTSCTS_SH_CTS_PMB_TYPE		25
+
 #define CR_WEP_PROTECT			CTL_REG(0x063C)
 #define CR_RX_THRESHOLD			CTL_REG(0x0640)
 
 /* register for controlling the LEDS */
 #define CR_LED				CTL_REG(0x0644)
 /* masks for controlling LEDs */
-#define LED1				0x0100
-#define LED2				0x0200
-#define LED_SW				0x0400
+#define LED1				(1 <<  8)
+#define LED2				(1 <<  9)
+#define LED_SW				(1 << 10)
 
 /* Seems to indicate that the configuration is over.
  */
@@ -455,18 +464,18 @@ #define CR_REG1				CTL_REG(0x0680)
  * registers, so one could argue it is a LOCK bit. But calling it
  * LOCK_PHY_REGS makes it confusing.
  */
-#define UNLOCK_PHY_REGS			0x0080
+#define UNLOCK_PHY_REGS			(1 << 7)
 
 #define CR_DEVICE_STATE			CTL_REG(0x0684)
 #define CR_UNDERRUN_CNT			CTL_REG(0x0688)
 
 #define CR_RX_FILTER			CTL_REG(0x068c)
-#define RX_FILTER_ASSOC_RESPONSE	0x0002
-#define RX_FILTER_REASSOC_RESPONSE	0x0008
-#define RX_FILTER_PROBE_RESPONSE	0x0020
-#define RX_FILTER_BEACON		0x0100
-#define RX_FILTER_DISASSOC		0x0400
-#define RX_FILTER_AUTH			0x0800
+#define RX_FILTER_ASSOC_RESPONSE	(1 <<  1)
+#define RX_FILTER_REASSOC_RESPONSE	(1 <<  3)
+#define RX_FILTER_PROBE_RESPONSE	(1 <<  5)
+#define RX_FILTER_BEACON		(1 <<  8)
+#define RX_FILTER_DISASSOC		(1 << 10)
+#define RX_FILTER_AUTH			(1 << 11)
 #define AP_RX_FILTER			0x0400feff
 #define STA_RX_FILTER			0x0000ffff
 
@@ -794,6 +803,9 @@ void zd_chip_disable_rx(struct zd_chip *
 int zd_chip_enable_hwint(struct zd_chip *chip);
 int zd_chip_disable_hwint(struct zd_chip *chip);
 
+int zd_chip_set_rts_cts_rate_locked(struct zd_chip *chip,
+	u8 rts_rate, int preamble);
+
 static inline int zd_get_encryption_type(struct zd_chip *chip, u32 *type)
 {
 	return zd_ioread32(chip, CR_ENCRYPTION_TYPE, type);
@@ -809,7 +821,17 @@ static inline int zd_chip_get_basic_rate
 	return zd_ioread16(chip, CR_BASIC_RATE_TBL, cr_rates);
 }
 
-int zd_chip_set_basic_rates(struct zd_chip *chip, u16 cr_rates);
+int zd_chip_set_basic_rates_locked(struct zd_chip *chip, u16 cr_rates);
+
+static inline int zd_chip_set_basic_rates(struct zd_chip *chip, u16 cr_rates)
+{
+	int r;
+
+	mutex_lock(&chip->mutex);
+	r = zd_chip_set_basic_rates_locked(chip, cr_rates);
+	mutex_unlock(&chip->mutex);
+	return r;
+}
 
 static inline int zd_chip_set_rx_filter(struct zd_chip *chip, u32 filter)
 {
diff --git a/drivers/net/wireless/zd1211rw/zd_def.h b/drivers/net/wireless/zd1211rw/zd_def.h
index a13ec72..fb22f62 100644
--- a/drivers/net/wireless/zd1211rw/zd_def.h
+++ b/drivers/net/wireless/zd1211rw/zd_def.h
@@ -39,6 +39,7 @@ do { \
 	if (!(x)) { \
 		pr_debug("%s:%d ASSERT %s VIOLATED!\n", \
 			__FILE__, __LINE__, __stringify(x)); \
+		dump_stack(); \
 	} \
 } while (0)
 #else
diff --git a/drivers/net/wireless/zd1211rw/zd_ieee80211.c b/drivers/net/wireless/zd1211rw/zd_ieee80211.c
index 66905f7..189160e 100644
--- a/drivers/net/wireless/zd1211rw/zd_ieee80211.c
+++ b/drivers/net/wireless/zd1211rw/zd_ieee80211.c
@@ -37,7 +37,12 @@ static const struct channel_range channe
 	[ZD_REGDOMAIN_JAPAN]	 = { 1, 14},
 	[ZD_REGDOMAIN_SPAIN]	 = { 1, 14},
 	[ZD_REGDOMAIN_FRANCE]	 = { 1, 14},
-	[ZD_REGDOMAIN_JAPAN_ADD] = {14, 15},
+
+	/* Japan originally only had channel 14 available (see CHNL_ID 0x40 in
+	 * 802.11). However, in 2001 the range was extended to include channels
+	 * 1-13. The ZyDAS devices still use the old region code but are
+	 * designed to allow the extra channel access in Japan. */
+	[ZD_REGDOMAIN_JAPAN_ADD] = { 1, 15},
 };
 
 const struct channel_range *zd_channel_range(u8 regdomain)
@@ -133,9 +138,6 @@ int zd_find_channel(u8 *channel, const s
 	int i, r;
 	u32 mhz;
 
-	if (!(freq->flags & IW_FREQ_FIXED))
-		return 0;
-
 	if (freq->m < 1000) {
 		if (freq->m  > NUM_CHANNELS || freq->m == 0)
 			return -EINVAL;
diff --git a/drivers/net/wireless/zd1211rw/zd_ieee80211.h b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
index 3632989..26b8298 100644
--- a/drivers/net/wireless/zd1211rw/zd_ieee80211.h
+++ b/drivers/net/wireless/zd1211rw/zd_ieee80211.h
@@ -50,6 +50,7 @@ static inline u8 zd_ofdm_plcp_header_rat
 	return header->prefix[0] & 0xf;
 }
 
+/* These are referred to as zd_rates */
 #define ZD_OFDM_RATE_6M		0xb
 #define ZD_OFDM_RATE_9M		0xf
 #define ZD_OFDM_RATE_12M	0xa
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index e5fedf9..2696f95 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -32,6 +32,8 @@ #include "zd_util.h"
 
 static void ieee_init(struct ieee80211_device *ieee);
 static void softmac_init(struct ieee80211softmac_device *sm);
+static void set_rts_cts_work(void *d);
+static void set_basic_rates_work(void *d);
 
 static void housekeeping_init(struct zd_mac *mac);
 static void housekeeping_enable(struct zd_mac *mac);
@@ -46,6 +48,8 @@ int zd_mac_init(struct zd_mac *mac,
 	memset(mac, 0, sizeof(*mac));
 	spin_lock_init(&mac->lock);
 	mac->netdev = netdev;
+	INIT_WORK(&mac->set_rts_cts_work, set_rts_cts_work, mac);
+	INIT_WORK(&mac->set_basic_rates_work, set_basic_rates_work, mac);
 
 	ieee_init(ieee);
 	softmac_init(ieee80211_priv(netdev));
@@ -213,6 +217,13 @@ int zd_mac_stop(struct net_device *netde
 	housekeeping_disable(mac);
 	ieee80211softmac_stop(netdev);
 
+	/* Ensure no work items are running or queued from this point */
+	cancel_delayed_work(&mac->set_rts_cts_work);
+	cancel_delayed_work(&mac->set_basic_rates_work);
+	flush_workqueue(zd_workqueue);
+	mac->updating_rts_rate = 0;
+	mac->updating_basic_rates = 0;
+
 	zd_chip_disable_hwint(chip);
 	zd_chip_switch_radio_off(chip);
 	zd_chip_disable_int(chip);
@@ -286,6 +297,186 @@ u8 zd_mac_get_regdomain(struct zd_mac *m
 	return regdomain;
 }
 
+/* Fallback to lowest rate, if rate is unknown. */
+static u8 rate_to_zd_rate(u8 rate)
+{
+	switch (rate) {
+	case IEEE80211_CCK_RATE_2MB:
+		return ZD_CCK_RATE_2M;
+	case IEEE80211_CCK_RATE_5MB:
+		return ZD_CCK_RATE_5_5M;
+	case IEEE80211_CCK_RATE_11MB:
+		return ZD_CCK_RATE_11M;
+	case IEEE80211_OFDM_RATE_6MB:
+		return ZD_OFDM_RATE_6M;
+	case IEEE80211_OFDM_RATE_9MB:
+		return ZD_OFDM_RATE_9M;
+	case IEEE80211_OFDM_RATE_12MB:
+		return ZD_OFDM_RATE_12M;
+	case IEEE80211_OFDM_RATE_18MB:
+		return ZD_OFDM_RATE_18M;
+	case IEEE80211_OFDM_RATE_24MB:
+		return ZD_OFDM_RATE_24M;
+	case IEEE80211_OFDM_RATE_36MB:
+		return ZD_OFDM_RATE_36M;
+	case IEEE80211_OFDM_RATE_48MB:
+		return ZD_OFDM_RATE_48M;
+	case IEEE80211_OFDM_RATE_54MB:
+		return ZD_OFDM_RATE_54M;
+	}
+	return ZD_CCK_RATE_1M;
+}
+
+static u16 rate_to_cr_rate(u8 rate)
+{
+	switch (rate) {
+	case IEEE80211_CCK_RATE_2MB:
+		return CR_RATE_1M;
+	case IEEE80211_CCK_RATE_5MB:
+		return CR_RATE_5_5M;
+	case IEEE80211_CCK_RATE_11MB:
+		return CR_RATE_11M;
+	case IEEE80211_OFDM_RATE_6MB:
+		return CR_RATE_6M;
+	case IEEE80211_OFDM_RATE_9MB:
+		return CR_RATE_9M;
+	case IEEE80211_OFDM_RATE_12MB:
+		return CR_RATE_12M;
+	case IEEE80211_OFDM_RATE_18MB:
+		return CR_RATE_18M;
+	case IEEE80211_OFDM_RATE_24MB:
+		return CR_RATE_24M;
+	case IEEE80211_OFDM_RATE_36MB:
+		return CR_RATE_36M;
+	case IEEE80211_OFDM_RATE_48MB:
+		return CR_RATE_48M;
+	case IEEE80211_OFDM_RATE_54MB:
+		return CR_RATE_54M;
+	}
+	return CR_RATE_1M;
+}
+
+static void try_enable_tx(struct zd_mac *mac)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (mac->updating_rts_rate == 0 && mac->updating_basic_rates == 0)
+		netif_wake_queue(mac->netdev);
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
+static void set_rts_cts_work(void *d)
+{
+	struct zd_mac *mac = d;
+	unsigned long flags;
+	u8 rts_rate;
+	unsigned int short_preamble;
+
+	mutex_lock(&mac->chip.mutex);
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->updating_rts_rate = 0;
+	rts_rate = mac->rts_rate;
+	short_preamble = mac->short_preamble;
+	spin_unlock_irqrestore(&mac->lock, flags);
+
+	zd_chip_set_rts_cts_rate_locked(&mac->chip, rts_rate, short_preamble);
+	mutex_unlock(&mac->chip.mutex);
+
+	try_enable_tx(mac);
+}
+
+static void set_basic_rates_work(void *d)
+{
+	struct zd_mac *mac = d;
+	unsigned long flags;
+	u16 basic_rates;
+
+	mutex_lock(&mac->chip.mutex);
+
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->updating_basic_rates = 0;
+	basic_rates = mac->basic_rates;
+	spin_unlock_irqrestore(&mac->lock, flags);
+
+	zd_chip_set_basic_rates_locked(&mac->chip, basic_rates);
+	mutex_unlock(&mac->chip.mutex);
+
+	try_enable_tx(mac);
+}
+
+static void bssinfo_change(struct net_device *netdev, u32 changes)
+{
+	struct zd_mac *mac = zd_netdev_mac(netdev);
+	struct ieee80211softmac_device *softmac = ieee80211_priv(netdev);
+	struct ieee80211softmac_bss_info *bssinfo = &softmac->bssinfo;
+	int need_set_rts_cts = 0;
+	int need_set_rates = 0;
+	u16 basic_rates;
+	unsigned long flags;
+
+	dev_dbg_f(zd_mac_dev(mac), "changes: %x\n", changes);
+
+	if (changes & IEEE80211SOFTMAC_BSSINFOCHG_SHORT_PREAMBLE) {
+		spin_lock_irqsave(&mac->lock, flags);
+		mac->short_preamble = bssinfo->short_preamble;
+		spin_unlock_irqrestore(&mac->lock, flags);
+		need_set_rts_cts = 1;
+	}
+
+	if (changes & IEEE80211SOFTMAC_BSSINFOCHG_RATES) {
+		/* Set RTS rate to highest available basic rate */
+		u8 rate = ieee80211softmac_highest_supported_rate(softmac,
+			&bssinfo->supported_rates, 1);
+		rate = rate_to_zd_rate(rate);
+
+		spin_lock_irqsave(&mac->lock, flags);
+		if (rate != mac->rts_rate) {
+			mac->rts_rate = rate;
+			need_set_rts_cts = 1;
+		}
+		spin_unlock_irqrestore(&mac->lock, flags);
+
+		/* Set basic rates */
+		need_set_rates = 1;
+		if (bssinfo->supported_rates.count == 0) {
+			/* Allow the device to be flexible */
+			basic_rates = CR_RATES_80211B | CR_RATES_80211G;
+		} else {
+			int i = 0;
+			basic_rates = 0;
+
+			for (i = 0; i < bssinfo->supported_rates.count; i++) {
+				u16 rate = bssinfo->supported_rates.rates[i];
+				if ((rate & IEEE80211_BASIC_RATE_MASK) == 0)
+					continue;
+
+				rate &= ~IEEE80211_BASIC_RATE_MASK;
+				basic_rates |= rate_to_cr_rate(rate);
+			}
+		}
+		spin_lock_irqsave(&mac->lock, flags);
+		mac->basic_rates = basic_rates;
+		spin_unlock_irqrestore(&mac->lock, flags);
+	}
+
+	/* Schedule any changes we made above */
+
+	spin_lock_irqsave(&mac->lock, flags);
+	if (need_set_rts_cts && !mac->updating_rts_rate) {
+		mac->updating_rts_rate = 1;
+		netif_stop_queue(mac->netdev);
+		queue_work(zd_workqueue, &mac->set_rts_cts_work);
+	}
+	if (need_set_rates && !mac->updating_basic_rates) {
+		mac->updating_basic_rates = 1;
+		netif_stop_queue(mac->netdev);
+		queue_work(zd_workqueue, &mac->set_basic_rates_work);
+	}
+	spin_unlock_irqrestore(&mac->lock, flags);
+}
+
 static void set_channel(struct net_device *netdev, u8 channel)
 {
 	struct zd_mac *mac = zd_netdev_mac(netdev);
@@ -295,7 +486,6 @@ static void set_channel(struct net_devic
 	zd_chip_set_channel(&mac->chip, channel);
 }
 
-/* TODO: Should not work in Managed mode. */
 int zd_mac_request_channel(struct zd_mac *mac, u8 channel)
 {
 	unsigned long lock_flags;
@@ -317,31 +507,22 @@ int zd_mac_request_channel(struct zd_mac
 		return 0;
 }
 
-int zd_mac_get_channel(struct zd_mac *mac, u8 *channel, u8 *flags)
+u8 zd_mac_get_channel(struct zd_mac *mac)
 {
-	struct ieee80211_device *ieee = zd_mac_to_ieee80211(mac);
+	u8 channel = zd_chip_get_channel(&mac->chip);
 
-	*channel = zd_chip_get_channel(&mac->chip);
-	if (ieee->iw_mode != IW_MODE_INFRA) {
-		spin_lock_irq(&mac->lock);
-		*flags = *channel == mac->requested_channel ?
-			MAC_FIXED_CHANNEL : 0;
-		spin_unlock(&mac->lock);
-	} else {
-		*flags = 0;
-	}
-	dev_dbg_f(zd_mac_dev(mac), "channel %u flags %u\n", *channel, *flags);
-	return 0;
+	dev_dbg_f(zd_mac_dev(mac), "channel %u\n", channel);
+	return channel;
 }
 
 /* If wrong rate is given, we are falling back to the slowest rate: 1MBit/s */
-static u8 cs_typed_rate(u8 cs_rate)
+static u8 zd_rate_typed(u8 zd_rate)
 {
 	static const u8 typed_rates[16] = {
-		[ZD_CS_CCK_RATE_1M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_1M,
-		[ZD_CS_CCK_RATE_2M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_2M,
-		[ZD_CS_CCK_RATE_5_5M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_5_5M,
-		[ZD_CS_CCK_RATE_11M]	= ZD_CS_CCK|ZD_CS_CCK_RATE_11M,
+		[ZD_CCK_RATE_1M]	= ZD_CS_CCK|ZD_CCK_RATE_1M,
+		[ZD_CCK_RATE_2M]	= ZD_CS_CCK|ZD_CCK_RATE_2M,
+		[ZD_CCK_RATE_5_5M]	= ZD_CS_CCK|ZD_CCK_RATE_5_5M,
+		[ZD_CCK_RATE_11M]	= ZD_CS_CCK|ZD_CCK_RATE_11M,
 		[ZD_OFDM_RATE_6M]	= ZD_CS_OFDM|ZD_OFDM_RATE_6M,
 		[ZD_OFDM_RATE_9M]	= ZD_CS_OFDM|ZD_OFDM_RATE_9M,
 		[ZD_OFDM_RATE_12M]	= ZD_CS_OFDM|ZD_OFDM_RATE_12M,
@@ -353,37 +534,7 @@ static u8 cs_typed_rate(u8 cs_rate)
 	};
 
 	ZD_ASSERT(ZD_CS_RATE_MASK == 0x0f);
-	return typed_rates[cs_rate & ZD_CS_RATE_MASK];
-}
-
-/* Fallback to lowest rate, if rate is unknown. */
-static u8 rate_to_cs_rate(u8 rate)
-{
-	switch (rate) {
-	case IEEE80211_CCK_RATE_2MB:
-		return ZD_CS_CCK_RATE_2M;
-	case IEEE80211_CCK_RATE_5MB:
-		return ZD_CS_CCK_RATE_5_5M;
-	case IEEE80211_CCK_RATE_11MB:
-		return ZD_CS_CCK_RATE_11M;
-	case IEEE80211_OFDM_RATE_6MB:
-		return ZD_OFDM_RATE_6M;
-	case IEEE80211_OFDM_RATE_9MB:
-		return ZD_OFDM_RATE_9M;
-	case IEEE80211_OFDM_RATE_12MB:
-		return ZD_OFDM_RATE_12M;
-	case IEEE80211_OFDM_RATE_18MB:
-		return ZD_OFDM_RATE_18M;
-	case IEEE80211_OFDM_RATE_24MB:
-		return ZD_OFDM_RATE_24M;
-	case IEEE80211_OFDM_RATE_36MB:
-		return ZD_OFDM_RATE_36M;
-	case IEEE80211_OFDM_RATE_48MB:
-		return ZD_OFDM_RATE_48M;
-	case IEEE80211_OFDM_RATE_54MB:
-		return ZD_OFDM_RATE_54M;
-	}
-	return ZD_CS_CCK_RATE_1M;
+	return typed_rates[zd_rate & ZD_CS_RATE_MASK];
 }
 
 int zd_mac_set_mode(struct zd_mac *mac, u32 mode)
@@ -484,13 +635,13 @@ int zd_mac_get_range(struct zd_mac *mac,
 	return 0;
 }
 
-static int zd_calc_tx_length_us(u8 *service, u8 cs_rate, u16 tx_length)
+static int zd_calc_tx_length_us(u8 *service, u8 zd_rate, u16 tx_length)
 {
 	static const u8 rate_divisor[] = {
-		[ZD_CS_CCK_RATE_1M]	=  1,
-		[ZD_CS_CCK_RATE_2M]	=  2,
-		[ZD_CS_CCK_RATE_5_5M]	= 11, /* bits must be doubled */
-		[ZD_CS_CCK_RATE_11M]	= 11,
+		[ZD_CCK_RATE_1M]	=  1,
+		[ZD_CCK_RATE_2M]	=  2,
+		[ZD_CCK_RATE_5_5M]	= 11, /* bits must be doubled */
+		[ZD_CCK_RATE_11M]	= 11,
 		[ZD_OFDM_RATE_6M]	=  6,
 		[ZD_OFDM_RATE_9M]	=  9,
 		[ZD_OFDM_RATE_12M]	= 12,
@@ -504,15 +655,15 @@ static int zd_calc_tx_length_us(u8 *serv
 	u32 bits = (u32)tx_length * 8;
 	u32 divisor;
 
-	divisor = rate_divisor[cs_rate];
+	divisor = rate_divisor[zd_rate];
 	if (divisor == 0)
 		return -EINVAL;
 
-	switch (cs_rate) {
-	case ZD_CS_CCK_RATE_5_5M:
+	switch (zd_rate) {
+	case ZD_CCK_RATE_5_5M:
 		bits = (2*bits) + 10; /* round up to the next integer */
 		break;
-	case ZD_CS_CCK_RATE_11M:
+	case ZD_CCK_RATE_11M:
 		if (service) {
 			u32 t = bits % 11;
 			*service &= ~ZD_PLCP_SERVICE_LENGTH_EXTENSION;
@@ -532,16 +683,16 @@ enum {
 	R2M_11A		   = 0x02,
 };
 
-static u8 cs_rate_to_modulation(u8 cs_rate, int flags)
+static u8 zd_rate_to_modulation(u8 zd_rate, int flags)
 {
 	u8 modulation;
 
-	modulation = cs_typed_rate(cs_rate);
+	modulation = zd_rate_typed(zd_rate);
 	if (flags & R2M_SHORT_PREAMBLE) {
 		switch (ZD_CS_RATE(modulation)) {
-		case ZD_CS_CCK_RATE_2M:
-		case ZD_CS_CCK_RATE_5_5M:
-		case ZD_CS_CCK_RATE_11M:
+		case ZD_CCK_RATE_2M:
+		case ZD_CCK_RATE_5_5M:
+		case ZD_CCK_RATE_11M:
 			modulation |= ZD_CS_CCK_PREA_SHORT;
 			return modulation;
 		}
@@ -558,39 +709,36 @@ static void cs_set_modulation(struct zd_
 {
 	struct ieee80211softmac_device *softmac = ieee80211_priv(mac->netdev);
 	u16 ftype = WLAN_FC_GET_TYPE(le16_to_cpu(hdr->frame_ctl));
-	u8 rate, cs_rate;
+	u8 rate, zd_rate;
 	int is_mgt = (ftype == IEEE80211_FTYPE_MGMT) != 0;
+	int is_multicast = is_multicast_ether_addr(hdr->addr1);
+	int short_preamble = ieee80211softmac_short_preamble_ok(softmac,
+		is_multicast, is_mgt);
+	int flags = 0;
+
+	/* FIXME: 802.11a? */
+	rate = ieee80211softmac_suggest_txrate(softmac, is_multicast, is_mgt);
 
-	/* FIXME: 802.11a? short preamble? */
-	rate = ieee80211softmac_suggest_txrate(softmac,
-		is_multicast_ether_addr(hdr->addr1), is_mgt);
+	if (short_preamble)
+		flags |= R2M_SHORT_PREAMBLE;
 
-	cs_rate = rate_to_cs_rate(rate);
-	cs->modulation = cs_rate_to_modulation(cs_rate, 0);
+	zd_rate = rate_to_zd_rate(rate);
+	cs->modulation = zd_rate_to_modulation(zd_rate, flags);
 }
 
 static void cs_set_control(struct zd_mac *mac, struct zd_ctrlset *cs,
 	                   struct ieee80211_hdr_4addr *header)
 {
+	struct ieee80211softmac_device *softmac = ieee80211_priv(mac->netdev);
 	unsigned int tx_length = le16_to_cpu(cs->tx_length);
 	u16 fctl = le16_to_cpu(header->frame_ctl);
 	u16 ftype = WLAN_FC_GET_TYPE(fctl);
 	u16 stype = WLAN_FC_GET_STYPE(fctl);
 
 	/*
-	 * CONTROL:
-	 * - start at 0x00
-	 * - if fragment 0, enable bit 0
+	 * CONTROL TODO:
 	 * - if backoff needed, enable bit 0
 	 * - if burst (backoff not needed) disable bit 0
-	 * - if multicast, enable bit 1
-	 * - if PS-POLL frame, enable bit 2
-	 * - if in INDEPENDENT_BSS mode and zd1205_DestPowerSave, then enable
-	 *   bit 4 (FIXME: wtf)
-	 * - if frag_len > RTS threshold, set bit 5 as long if it isnt
-	 *   multicast or mgt
-	 * - if bit 5 is set, and we are in OFDM mode, unset bit 5 and set bit
-	 *   7
 	 */
 
 	cs->control = 0;
@@ -607,17 +755,18 @@ static void cs_set_control(struct zd_mac
 	if (stype == IEEE80211_STYPE_PSPOLL)
 		cs->control |= ZD_CS_PS_POLL_FRAME;
 
+	/* Unicast data frames over the threshold should have RTS */
 	if (!is_multicast_ether_addr(header->addr1) &&
-	    ftype != IEEE80211_FTYPE_MGMT &&
-	    tx_length > zd_netdev_ieee80211(mac->netdev)->rts)
-	{
-		/* FIXME: check the logic */
-		if (ZD_CS_TYPE(cs->modulation) == ZD_CS_OFDM) {
-			/* 802.11g */
-			cs->control |= ZD_CS_SELF_CTS;
-		} else { /* 802.11b */
-			cs->control |= ZD_CS_RTS;
-		}
+	    	ftype != IEEE80211_FTYPE_MGMT &&
+		    tx_length > zd_netdev_ieee80211(mac->netdev)->rts)
+		cs->control |= ZD_CS_RTS;
+
+	/* Use CTS-to-self protection if required */
+	if (ZD_CS_TYPE(cs->modulation) == ZD_CS_OFDM &&
+			ieee80211softmac_protection_needed(softmac)) {
+		/* FIXME: avoid sending RTS *and* self-CTS, is that correct? */
+		cs->control &= ~ZD_CS_RTS;
+		cs->control |= ZD_CS_SELF_CTS;
 	}
 
 	/* FIXME: Management frame? */
@@ -782,9 +931,11 @@ static int is_data_packet_for_us(struct 
 	       (netdev->flags & IFF_PROMISC);
 }
 
-/* Filters receiving packets. If it returns 1 send it to ieee80211_rx, if 0
- * return. If an error is detected -EINVAL is returned. ieee80211_rx_mgt() is
- * called here.
+/* Filters received packets. The function returns 1 if the packet should be
+ * forwarded to ieee80211_rx(). If the packet should be ignored the function
+ * returns 0. If an invalid packet is found the function returns -EINVAL.
+ *
+ * The function calls ieee80211_rx_mgt() directly.
  *
  * It has been based on ieee80211_rx_any.
  */
@@ -810,9 +961,9 @@ static int filter_rx(struct ieee80211_de
 		ieee80211_rx_mgt(ieee, hdr, stats);
 		return 0;
 	case IEEE80211_FTYPE_CTL:
-		/* Ignore invalid short buffers */
 		return 0;
 	case IEEE80211_FTYPE_DATA:
+		/* Ignore invalid short buffers */
 		if (length < sizeof(struct ieee80211_hdr_3addr))
 			return -EINVAL;
 		return is_data_packet_for_us(ieee, hdr);
@@ -993,6 +1144,7 @@ static void ieee_init(struct ieee80211_d
 static void softmac_init(struct ieee80211softmac_device *sm)
 {
 	sm->set_channel = set_channel;
+	sm->bssinfo_change = bssinfo_change;
 }
 
 struct iw_statistics *zd_mac_get_wireless_stats(struct net_device *ndev)
@@ -1028,66 +1180,6 @@ struct iw_statistics *zd_mac_get_wireles
 	return iw_stats;
 }
 
-#ifdef DEBUG
-static const char* decryption_types[] = {
-	[ZD_RX_NO_WEP] = "none",
-	[ZD_RX_WEP64] = "WEP64",
-	[ZD_RX_TKIP] = "TKIP",
-	[ZD_RX_AES] = "AES",
-	[ZD_RX_WEP128] = "WEP128",
-	[ZD_RX_WEP256] = "WEP256",
-};
-
-static const char *decryption_type_string(u8 type)
-{
-	const char *s;
-
-	if (type < ARRAY_SIZE(decryption_types)) {
-		s = decryption_types[type];
-	} else {
-		s = NULL;
-	}
-	return s ? s : "unknown";
-}
-
-static int is_ofdm(u8 frame_status)
-{
-	return (frame_status & ZD_RX_OFDM);
-}
-
-void zd_dump_rx_status(const struct rx_status *status)
-{
-	const char* modulation;
-	u8 quality;
-
-	if (is_ofdm(status->frame_status)) {
-		modulation = "ofdm";
-		quality = status->signal_quality_ofdm;
-	} else {
-		modulation = "cck";
-		quality = status->signal_quality_cck;
-	}
-	pr_debug("rx status %s strength %#04x qual %#04x decryption %s\n",
-		modulation, status->signal_strength, quality,
-		decryption_type_string(status->decryption_type));
-	if (status->frame_status & ZD_RX_ERROR) {
-		pr_debug("rx error %s%s%s%s%s%s\n",
-			(status->frame_status & ZD_RX_TIMEOUT_ERROR) ?
-				"timeout " : "",
-			(status->frame_status & ZD_RX_FIFO_OVERRUN_ERROR) ?
-				"fifo " : "",
-			(status->frame_status & ZD_RX_DECRYPTION_ERROR) ?
-				"decryption " : "",
-			(status->frame_status & ZD_RX_CRC32_ERROR) ?
-				"crc32 " : "",
-			(status->frame_status & ZD_RX_NO_ADDR1_MATCH_ERROR) ?
-				"addr1 " : "",
-			(status->frame_status & ZD_RX_CRC16_ERROR) ?
-				"crc16" : "");
-	}
-}
-#endif /* DEBUG */
-
 #define LINK_LED_WORK_DELAY HZ
 
 static void link_led_handler(void *p)
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index e4dd40a..5dcfb25 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -20,6 +20,7 @@ #define _ZD_MAC_H
 
 #include <linux/wireless.h>
 #include <linux/kernel.h>
+#include <linux/workqueue.h>
 #include <net/ieee80211.h>
 #include <net/ieee80211softmac.h>
 
@@ -48,10 +49,11 @@ #define ZD_CS_TYPE(modulation) ((modulat
 #define ZD_CS_CCK		0x00
 #define ZD_CS_OFDM		0x10
 
-#define ZD_CS_CCK_RATE_1M	0x00
-#define ZD_CS_CCK_RATE_2M	0x01
-#define ZD_CS_CCK_RATE_5_5M	0x02
-#define ZD_CS_CCK_RATE_11M	0x03
+/* These are referred to as zd_rates */
+#define ZD_CCK_RATE_1M	0x00
+#define ZD_CCK_RATE_2M	0x01
+#define ZD_CCK_RATE_5_5M	0x02
+#define ZD_CCK_RATE_11M	0x03
 /* The rates for OFDM are encoded as in the PLCP header. Use ZD_OFDM_RATE_*.
  */
 
@@ -116,10 +118,6 @@ #define ZD_RX_NO_ADDR1_MATCH_ERROR	0x20
 #define ZD_RX_CRC16_ERROR		0x40
 #define ZD_RX_ERROR			0x80
 
-enum mac_flags {
-	MAC_FIXED_CHANNEL = 0x01,
-};
-
 struct housekeeping {
 	struct work_struct link_led_work;
 };
@@ -130,15 +128,33 @@ struct zd_mac {
 	struct zd_chip chip;
 	spinlock_t lock;
 	struct net_device *netdev;
+
 	/* Unlocked reading possible */
 	struct iw_statistics iw_stats;
+
 	struct housekeeping housekeeping;
+	struct work_struct set_rts_cts_work;
+	struct work_struct set_basic_rates_work;
+
 	unsigned int stats_count;
 	u8 qual_buffer[ZD_MAC_STATS_BUFFER_SIZE];
 	u8 rssi_buffer[ZD_MAC_STATS_BUFFER_SIZE];
 	u8 regdomain;
 	u8 default_regdomain;
 	u8 requested_channel;
+
+	/* A bitpattern of cr_rates */
+	u16 basic_rates;
+
+	/* A zd_rate */
+	u8 rts_rate;
+
+	/* Short preamble (used for RTS/CTS) */
+	unsigned int short_preamble:1;
+
+	/* flags to indicate update in progress */
+	unsigned int updating_rts_rate:1;
+	unsigned int updating_basic_rates:1;
 };
 
 static inline struct ieee80211_device *zd_mac_to_ieee80211(struct zd_mac *mac)
@@ -180,7 +196,7 @@ int zd_mac_set_regdomain(struct zd_mac *
 u8 zd_mac_get_regdomain(struct zd_mac *zd_mac);
 
 int zd_mac_request_channel(struct zd_mac *mac, u8 channel);
-int zd_mac_get_channel(struct zd_mac *mac, u8 *channel, u8 *flags);
+u8 zd_mac_get_channel(struct zd_mac *mac);
 
 int zd_mac_set_mode(struct zd_mac *mac, u32 mode);
 int zd_mac_get_mode(struct zd_mac *mac, u32 *mode);
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index af3a7b3..60f1b0f 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -107,21 +107,10 @@ static int iw_get_freq(struct net_device
 	           struct iw_request_info *info,
 		   union iwreq_data *req, char *extra)
 {
-	int r;
 	struct zd_mac *mac = zd_netdev_mac(netdev);
 	struct iw_freq *freq = &req->freq;
-	u8 channel;
-	u8 flags;
-
-	r = zd_mac_get_channel(mac, &channel, &flags);
-	if (r)
-		return r;
 
-	freq->flags = (flags & MAC_FIXED_CHANNEL) ?
-		      IW_FREQ_FIXED : IW_FREQ_AUTO;
-	dev_dbg_f(zd_mac_dev(mac), "channel %s\n",
-		  (flags & MAC_FIXED_CHANNEL) ? "fixed" : "auto");
-	return zd_channel_to_freq(freq, channel);
+	return zd_channel_to_freq(freq, zd_mac_get_channel(mac));
 }
 
 static int iw_set_mode(struct net_device *netdev,
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 7917153..aa782e8 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -51,11 +51,13 @@ static struct usb_device_id usb_ids[] = 
 	{ USB_DEVICE(0x0586, 0x3409), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0b3b, 0x1630), .driver_info = DEVICE_ZD1211 },
 	{ USB_DEVICE(0x0586, 0x3401), .driver_info = DEVICE_ZD1211 },
+	{ USB_DEVICE(0x14ea, 0xab13), .driver_info = DEVICE_ZD1211 },
 	/* ZD1211B */
 	{ USB_DEVICE(0x0ace, 0x1215), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x157e, 0x300d), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{}
@@ -591,6 +593,8 @@ static void handle_rx_packet(struct zd_u
 		unsigned int l, k, n;
 		for (i = 0, l = 0;; i++) {
 			k = le16_to_cpu(get_unaligned(&length_info->length[i]));
+			if (k == 0)
+				return;
 			n = l+k;
 			if (n > length)
 				return;
@@ -1114,27 +1118,28 @@ static int __init usb_init(void)
 {
 	int r;
 
-	pr_debug("usb_init()\n");
+	pr_debug("%s usb_init()\n", driver.name);
 
 	zd_workqueue = create_singlethread_workqueue(driver.name);
 	if (zd_workqueue == NULL) {
-		printk(KERN_ERR "%s: couldn't create workqueue\n", driver.name);
+		printk(KERN_ERR "%s couldn't create workqueue\n", driver.name);
 		return -ENOMEM;
 	}
 
 	r = usb_register(&driver);
 	if (r) {
-		printk(KERN_ERR "usb_register() failed. Error number %d\n", r);
+		printk(KERN_ERR "%s usb_register() failed. Error number %d\n",
+		       driver.name, r);
 		return r;
 	}
 
-	pr_debug("zd1211rw initialized\n");
+	pr_debug("%s initialized\n", driver.name);
 	return 0;
 }
 
 static void __exit usb_exit(void)
 {
-	pr_debug("usb_exit()\n");
+	pr_debug("%s usb_exit()\n", driver.name);
 	usb_deregister(&driver);
 	destroy_workqueue(zd_workqueue);
 }
diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
index 2b14c2f..b1c6d1f 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -67,7 +67,7 @@ static int ieee80211_networks_allocate(s
 		return 0;
 
 	ieee->networks =
-	    kmalloc(MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
+	    kzalloc(MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
 		    GFP_KERNEL);
 	if (!ieee->networks) {
 		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
@@ -75,9 +75,6 @@ static int ieee80211_networks_allocate(s
 		return -ENOMEM;
 	}
 
-	memset(ieee->networks, 0,
-	       MAX_NETWORK_COUNT * sizeof(struct ieee80211_network));
-
 	return 0;
 }
 
@@ -126,6 +123,13 @@ static int ieee80211_change_mtu(struct n
 	return 0;
 }
 
+static struct net_device_stats *ieee80211_generic_get_stats(
+	struct net_device *dev)
+{
+	struct ieee80211_device *ieee = netdev_priv(dev);
+	return &ieee->stats;
+}
+
 struct net_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct ieee80211_device *ieee;
@@ -143,6 +147,10 @@ struct net_device *alloc_ieee80211(int s
 	dev->hard_start_xmit = ieee80211_xmit;
 	dev->change_mtu = ieee80211_change_mtu;
 
+	/* Drivers are free to override this if the generic implementation
+	 * does not meet their needs. */
+	dev->get_stats = ieee80211_generic_get_stats;
+
 	ieee->dev = dev;
 
 	err = ieee80211_networks_allocate(ieee);
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index ce28d57..d97e541 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -1304,12 +1304,11 @@ #endif
 		case MFIE_TYPE_IBSS_DFS:
 			if (network->ibss_dfs)
 				break;
-			network->ibss_dfs =
-			    kmalloc(info_element->len, GFP_ATOMIC);
+			network->ibss_dfs = kmemdup(info_element->data,
+						    info_element->len,
+						    GFP_ATOMIC);
 			if (!network->ibss_dfs)
 				return 1;
-			memcpy(network->ibss_dfs, info_element->data,
-			       info_element->len);
 			network->flags |= NETWORK_HAS_IBSS_DFS;
 			break;
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 95e5287..0612015 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -216,10 +216,16 @@ ieee80211softmac_auth_resp(struct net_de
 			net->challenge_len = *data++; 	
 			if (net->challenge_len > WLAN_AUTH_CHALLENGE_LEN)
 				net->challenge_len = WLAN_AUTH_CHALLENGE_LEN;
-			if (net->challenge != NULL)
-				kfree(net->challenge);
-			net->challenge = kmalloc(net->challenge_len, GFP_ATOMIC);
-			memcpy(net->challenge, data, net->challenge_len);
+			kfree(net->challenge);
+			net->challenge = kmemdup(data, net->challenge_len,
+						 GFP_ATOMIC);
+			if (net->challenge == NULL) {
+				printkl(KERN_NOTICE PFX "Shared Key "
+					"Authentication failed due to "
+					"memory shortage.\n");
+				spin_unlock_irqrestore(&mac->lock, flags);
+				break;
+			}
 			aq->state = IEEE80211SOFTMAC_AUTH_SHARED_RESPONSE; 
 
 			/* We reuse the work struct from the auth request here.
diff --git a/net/ieee80211/softmac/ieee80211softmac_scan.c b/net/ieee80211/softmac/ieee80211softmac_scan.c
index ad67368..5507fea 100644
--- a/net/ieee80211/softmac/ieee80211softmac_scan.c
+++ b/net/ieee80211/softmac/ieee80211softmac_scan.c
@@ -134,7 +134,8 @@ void ieee80211softmac_scan(void *d)
 	si->started = 0;
 	spin_unlock_irqrestore(&sm->lock, flags);
 
-	dprintk(PFX "Scanning finished\n");
+	dprintk(PFX "Scanning finished: scanned %d channels starting with channel %d\n",
+		     sm->scaninfo->number_channels, sm->scaninfo->channels[0].channel);
 	ieee80211softmac_scan_finished(sm);
 	complete_all(&sm->scaninfo->finished);
 }
@@ -182,8 +183,6 @@ int ieee80211softmac_start_scan_implemen
 		sm->scaninfo->channels = sm->ieee->geo.bg;
 		sm->scaninfo->number_channels = sm->ieee->geo.bg_channels;
 	}
-	dprintk(PFX "Start scanning with channel: %d\n", sm->scaninfo->channels[0].channel);
-	dprintk(PFX "Scanning %d channels\n", sm->scaninfo->number_channels);
 	sm->scaninfo->current_channel_idx = 0;
 	sm->scaninfo->started = 1;
 	sm->scaninfo->stop = 0;
-- 
John W. Linville
linville@tuxdriver.com
