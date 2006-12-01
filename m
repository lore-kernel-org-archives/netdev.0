From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC] rt2400: fix breakage from API changes
Date: Fri, 1 Dec 2006 16:53:26 -0500
Message-ID: <20061201215318.GC3370@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivdoorn@gmail.com, johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:39944 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1162069AbWLAWMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 17:12:15 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's my whack at fixing-up the rt2400pci driver to compile, since
the recent API changes broke it.  This only covers that one driver,
so lots more (albeit similar) work needs to be done to cover the
other rt2x00 family drivers.

Ivo and Johannes, please take a quick look to see if I'm obviously
missing something or handling something incorrectly.  I don't have
the hardware in questions, so this is completely untested. :-)

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/wireless/d80211/rt2x00/rt2400pci.c |  308 ++++++++-----------------
 drivers/net/wireless/d80211/rt2x00/rt2400pci.h |   32 +-
 drivers/net/wireless/d80211/rt2x00/rt2x00.h    |    3 
 3 files changed, 125 insertions(+), 218 deletions(-)

diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index d3efc11..dba5cf0 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -35,7 +35,6 @@ #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/wireless.h>
-#include <linux/ethtool.h>
 
 #include <net/iw_handler.h>
 #include <net/d80211.h>
@@ -343,81 +342,6 @@ static void rt2x00_eeprom_multiread(cons
 }
 
 /*
- * Ethtool handlers.
- */
-static void rt2400pci_get_drvinfo(struct net_device *net_dev,
-	struct ethtool_drvinfo *drvinfo)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->version, DRV_VERSION);
-	strcpy(drvinfo->fw_version, "N/A");
-	strcpy(drvinfo->bus_info, pci_name(rt2x00dev_pci(rt2x00dev)));
-	drvinfo->eedump_len = EEPROM_SIZE;
-	drvinfo->regdump_len = CSR_REG_SIZE;
-}
-
-static int rt2400pci_get_regs_len(struct net_device *net_dev)
-{
-	return CSR_REG_SIZE;
-}
-
-static void rt2400pci_get_regs(struct net_device *net_dev,
-	struct ethtool_regs *regs, void *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	rt2x00_register_multiread(rt2x00dev, CSR_REG_BASE, data, CSR_REG_SIZE);
-	regs->version = rt2x00_rev(&rt2x00dev->chip);
-	regs->len = CSR_REG_SIZE;
-}
-
-#ifdef CONFIG_RT2400PCI_DEBUG
-static u32 rt2400pci_get_msglevel(struct net_device *net_dev)
-{
-	return rt2x00_debug_level;
-}
-
-static void rt2400pci_set_msglevel(struct net_device *net_dev, u32 msg)
-{
-	rt2x00_debug_level = !!msg;
-}
-#endif /* CONFIG_RT2400PCI_DEBUG */
-
-static int rt2400pci_get_eeprom_len(struct net_device *net_dev)
-{
-	return EEPROM_SIZE;
-}
-
-static int rt2400pci_get_eeprom(struct net_device *net_dev,
-	struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
-
-	eeprom->magic = 0xbad;
-
-	rt2x00_eeprom_multiread(rt2x00dev,
-		eeprom->offset / sizeof(u16), (void*)data, eeprom->len);
-
-	return 0;
-}
-
-static struct ethtool_ops rt2400pci_ethtool_ops = {
-	.get_drvinfo	= rt2400pci_get_drvinfo,
-	.get_regs_len	= rt2400pci_get_regs_len,
-	.get_regs	= rt2400pci_get_regs,
-#ifdef CONFIG_RT2400PCI_DEBUG
-	.get_msglevel	= rt2400pci_get_msglevel,
-	.set_msglevel	= rt2400pci_set_msglevel,
-#endif /* CONFIG_RT2400PCI_DEBUG */
-	.get_link	= ethtool_op_get_link,
-	.get_eeprom_len	= rt2400pci_get_eeprom_len,
-	.get_eeprom	= rt2400pci_get_eeprom,
-	.get_perm_addr	= ethtool_op_get_perm_addr,
-};
-
-/*
  * Configuration handlers.
  */
 static void rt2400pci_config_bssid(struct rt2x00_dev *rt2x00dev, u8 *bssid)
@@ -722,8 +646,7 @@ static void rt2400pci_config_duration(st
 
 static void rt2400pci_config_rate(struct rt2x00_dev *rt2x00dev, const int rate)
 {
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
-		pci_get_drvdata(rt2x00dev_pci(rt2x00dev)));
+	struct ieee80211_conf *conf = &rt2x00dev->hw.conf;
 	u32 reg[4];
 	u32 value;
 	u32 preamble;
@@ -1389,7 +1312,6 @@ static void rt2400pci_uninitialize(struc
  */
 static int rt2400pci_enable_radio(struct rt2x00_dev *rt2x00dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	/*
@@ -1444,22 +1366,21 @@ static int rt2400pci_enable_radio(struct
 
 	SET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO);
 
-	ieee80211_start_queues(net_dev);
-	ieee80211_netif_oper(net_dev, NETIF_WAKE);
+	ieee80211_start_queues(&rt2x00dev->hw);
+	ieee80211_netif_oper(&rt2x00dev->hw, NETIF_WAKE);
 
 	return 0;
 }
 
 static void rt2400pci_disable_radio(struct rt2x00_dev *rt2x00dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	u32 reg;
 
 	if (!GET_FLAG(rt2x00dev, DEVICE_ENABLED_RADIO))
 		return;
 
-	ieee80211_netif_oper(net_dev, NETIF_STOP);
-	ieee80211_stop_queues(net_dev);
+	ieee80211_netif_oper(&rt2x00dev->hw, NETIF_STOP);
+	ieee80211_stop_queues(&rt2x00dev->hw);
 
 	/*
 	 * Disable LED
@@ -1646,17 +1567,17 @@ static void rt2400pci_write_tx_desc(stru
 static void rt2400pci_beacondone(void *data)
 {
 	struct data_ring *ring = data;
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct rt2x00_dev *rt2x00dev = ring->hw->priv;
 	struct data_entry *entry = rt2x00_get_data_entry(
 		&rt2x00dev->ring[RING_BEACON]);
 	struct sk_buff *skb;
 
-	skb = ieee80211_beacon_get(ring->net_dev,
+	skb = ieee80211_beacon_get(ring->hw,
 		rt2x00dev->interface.id, &entry->tx_status.control);
 	if (!skb)
 		return;
 
-	rt2400pci_beacon_update(ring->net_dev, skb, &entry->tx_status.control);
+	rt2400pci_beacon_update(ring->hw, skb, &entry->tx_status.control);
 
 	dev_kfree_skb_any(skb);
 }
@@ -1664,7 +1585,7 @@ static void rt2400pci_beacondone(void *d
 static void rt2400pci_rxdone(void *data)
 {
 	struct data_ring *ring = data;
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct rt2x00_dev *rt2x00dev = ring->hw->priv;
 	struct data_entry *entry;
 	struct sk_buff *skb;
 	struct rxd *rxd;
@@ -1705,7 +1626,7 @@ static void rt2400pci_rxdone(void *data)
 			rt2x00dev->rx_params.signal =
 				rt2x00dev->rx_params.ssi - RT2X00_RX_MAX_SSI; /* FIXME */
 
-			__ieee80211_rx(ring->net_dev,
+			__ieee80211_rx(ring->hw,
 				skb, &rt2x00dev->rx_params);
 		}
 
@@ -1728,7 +1649,7 @@ static void rt2400pci_rxdone(void *data)
 static void rt2400pci_txdone(void *data)
 {
 	struct data_ring *ring = data;
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(ring->net_dev);
+	struct rt2x00_dev *rt2x00dev = ring->hw->priv;
 	struct data_entry *entry;
 	struct txd *txd;
 	int tx_status;
@@ -1782,7 +1703,7 @@ static void rt2400pci_txdone(void *data)
 			txd->word0, TXD_W0_RETRY_COUNT);
 
 		if (!GET_FLAG(entry, ENTRY_RTS_FRAME))
-			ieee80211_tx_status(ring->net_dev,
+			ieee80211_tx_status(ring->hw,
 				entry->skb, &entry->tx_status);
 
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
@@ -1809,7 +1730,7 @@ static void rt2400pci_txdone(void *data)
 	 */
 	entry = ring->entry;
 	if (ring_full && !rt2x00_ring_full(ring))
-		ieee80211_wake_queue(ring->net_dev,
+		ieee80211_wake_queue(ring->hw,
 			entry->tx_status.control.queue);
 }
 
@@ -1881,10 +1802,10 @@ static irqreturn_t rt2400pci_interrupt(i
 /*
  * IEEE80211 stack callback functions.
  */
-static int rt2400pci_tx(struct net_device *net_dev, struct sk_buff *skb,
+static int rt2400pci_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	struct ieee80211_tx_control *control)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct ieee80211_hdr *ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 	struct data_ring *ring;
 	struct data_entry *entry;
@@ -1907,7 +1828,7 @@ static int rt2400pci_tx(struct net_devic
 	}
 
 	if (rt2x00_ring_full(ring)) {
-		ieee80211_stop_queue(net_dev, control->queue);
+		ieee80211_stop_queue(hw, control->queue);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1925,7 +1846,7 @@ static int rt2400pci_tx(struct net_devic
 			return NETDEV_TX_BUSY;
 		}
 
-		res = rt2400pci_tx(net_dev, skb_rts, control);
+		res = rt2400pci_tx(hw, skb_rts, control);
 		if (res) {
 			WARNING("Failed to send RTS frame.\n");
 			return res;
@@ -1940,7 +1861,7 @@ static int rt2400pci_tx(struct net_devic
 		ERROR("Arrived at non-free entry in the non-full queue %d.\n"
 			"Please file bug report to %s.\n",
 			control->queue, DRV_PROJECT);
-		ieee80211_stop_queue(net_dev, control->queue);
+		ieee80211_stop_queue(hw, control->queue);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1960,7 +1881,7 @@ static int rt2400pci_tx(struct net_devic
 	rt2x00_ring_index_inc(ring);
 
 	if (rt2x00_ring_full(ring))
-		ieee80211_stop_queue(net_dev, control->queue);
+		ieee80211_stop_queue(hw, control->queue);
 
 	rt2x00_register_read(rt2x00dev, TXCSR0, &reg);
 	if (control->queue == IEEE80211_TX_QUEUE_DATA0)
@@ -1974,18 +1895,18 @@ static int rt2400pci_tx(struct net_devic
 	return NETDEV_TX_OK;
 }
 
-static int rt2400pci_reset(struct net_device *net_dev)
+static int rt2400pci_reset(struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	rt2400pci_disable_radio(rt2x00dev);
 	return rt2400pci_enable_radio(rt2x00dev);
 }
 
-static int rt2400pci_add_interface(struct net_device *net_dev,
+static int rt2400pci_add_interface(struct ieee80211_hw *hw,
 	struct ieee80211_if_init_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	/*
 	 * We only support 1 non-monitor interface.
@@ -2031,10 +1952,10 @@ static int rt2400pci_add_interface(struc
 	return 0;
 }
 
-static void rt2400pci_remove_interface(struct net_device *net_dev,
+static void rt2400pci_remove_interface(struct ieee80211_hw *hw,
 	struct ieee80211_if_init_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	/*
 	 * We only support 1 non-monitor interface.
@@ -2065,10 +1986,10 @@ static void rt2400pci_remove_interface(s
 		rt2400pci_disable_radio(rt2x00dev);
 }
 
-static int rt2400pci_config(struct net_device *net_dev,
+static int rt2400pci_config(struct ieee80211_hw *hw,
 	struct ieee80211_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u32 reg;
 
 	/*
@@ -2106,10 +2027,10 @@ static int rt2400pci_config(struct net_d
 	return 0;
 }
 
-static int rt2400pci_config_interface(struct net_device *net_dev, int if_id,
+static int rt2400pci_config_interface(struct ieee80211_hw *hw, int if_id,
 	struct ieee80211_if_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	/*
 	 * When configuring monitor mode, we are done now.
@@ -2129,10 +2050,10 @@ static int rt2400pci_config_interface(st
 	return 0;
 }
 
-static void rt2400pci_set_multicast_list(struct net_device *net_dev,
+static void rt2400pci_set_multicast_list(struct ieee80211_hw *hw,
 	unsigned short flags, int mc_count)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	int update = 0;
 
 	if (GET_FLAG(rt2x00dev, INTERFACE_ENABLED_PROMISC)) {
@@ -2203,10 +2124,10 @@ exit:
 	rt2x00dev->scan = NULL;
 }
 
-static int rt2400pci_passive_scan(struct net_device *net_dev,
+static int rt2400pci_passive_scan(struct ieee80211_hw *hw,
 	int state, struct ieee80211_scan_conf *conf)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	/*
 	 * Check if we are not busy with the previous
@@ -2233,7 +2154,7 @@ static int rt2400pci_passive_scan(struct
 	 * channel switch.
 	 */
 	if (conf->skb) {
-		if (rt2400pci_tx(net_dev, conf->skb, conf->tx_control))
+		if (rt2400pci_tx(hw, conf->skb, conf->tx_control))
 			goto exit;
 	}
 
@@ -2258,10 +2179,10 @@ exit:
 	return -EIO;
 }
 
-static int rt2400pci_get_stats(struct net_device *net_dev,
+static int rt2400pci_get_stats(struct ieee80211_hw *hw,
 	struct ieee80211_low_level_stats *stats)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u32 reg;
 
 	/*
@@ -2280,10 +2201,10 @@ static int rt2400pci_get_stats(struct ne
 	return 0;
 }
 
-static int rt2400pci_set_retry_limit(struct net_device *net_dev,
+static int rt2400pci_set_retry_limit(struct ieee80211_hw *hw,
 	u32 short_retry, u32 long_retry)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u32 reg;
 
 	rt2x00_register_read(rt2x00dev, CSR11, &reg);
@@ -2294,10 +2215,10 @@ static int rt2400pci_set_retry_limit(str
 	return 0;
 }
 
-static int rt2400pci_conf_tx(struct net_device *net_dev,
+static int rt2400pci_conf_tx(struct ieee80211_hw *hw,
 	int queue, const struct ieee80211_tx_queue_params *params)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct data_ring *ring = &rt2x00dev->ring[RING_TX];
 
 	/*
@@ -2334,10 +2255,10 @@ static int rt2400pci_conf_tx(struct net_
 	return 0;
 }
 
-static int rt2400pci_get_tx_stats(struct net_device *net_dev,
+static int rt2400pci_get_tx_stats(struct ieee80211_hw *hw,
 	struct ieee80211_tx_queue_stats *stats)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	memcpy(&stats->data[IEEE80211_TX_QUEUE_DATA0],
 		&rt2x00dev->ring[RING_PRIO].stats,
@@ -2349,9 +2270,9 @@ static int rt2400pci_get_tx_stats(struct
 	return 0;
 }
 
-static u64 rt2400pci_get_tsf(struct net_device *net_dev)
+static u64 rt2400pci_get_tsf(struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u64 tsf;
 	u32 reg;
 
@@ -2363,19 +2284,19 @@ static u64 rt2400pci_get_tsf(struct net_
 	return tsf;
 }
 
-static void rt2400pci_reset_tsf(struct net_device *net_dev)
+static void rt2400pci_reset_tsf(struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u32 reg = 0;
 
 	rt2x00_register_write(rt2x00dev, CSR16, reg);
 	rt2x00_register_write(rt2x00dev, CSR17, reg);
 }
 
-static int rt2400pci_beacon_update(struct net_device *net_dev,
+static int rt2400pci_beacon_update(struct ieee80211_hw *hw,
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	struct data_entry *entry;
 
 	entry = rt2x00_get_data_entry(&rt2x00dev->ring[RING_BEACON]);
@@ -2399,9 +2320,9 @@ static int rt2400pci_beacon_update(struc
 	return 0;
 }
 
-static int rt2400pci_tx_last_beacon(struct net_device *net_dev)
+static int rt2400pci_tx_last_beacon(struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	u32 reg;
 
 	rt2x00_register_read(rt2x00dev, CSR15, &reg);
@@ -2428,8 +2349,7 @@ static int rt2400pci_alloc_rings(struct 
 		/*
 		 *Set device structure.
 		 */
-		rt2x00dev->ring[i].net_dev =
-			pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
+		rt2x00dev->ring[i].hw = &rt2x00dev->hw;
 
 		/*
 		 * Initialize ring parameters.
@@ -2445,8 +2365,7 @@ static int rt2400pci_alloc_rings(struct 
 
 static int rt2400pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
 {
-	struct ieee80211_conf *conf = ieee80211_get_hw_conf(
-		pci_get_drvdata(rt2x00dev_pci(rt2x00dev)));
+	struct ieee80211_conf *conf = &rt2x00dev->hw.conf;
 	u32 reg;
 	u16 value;
 	u16 eeprom;
@@ -2512,36 +2431,29 @@ static int rt2400pci_init_eeprom(struct 
 
 static int rt2400pci_init_mac(struct rt2x00_dev *rt2x00dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
+	struct ieee80211_hw *hw = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC))
 		return 0;
 
-	memset(&net_dev->perm_addr[0], 0, sizeof(net_dev->perm_addr));
+	memset(&hw->perm_addr[0], 0, sizeof(hw->perm_addr));
 
 	/*
 	 * Read MAC address from EEPROM.
 	 */
 	rt2x00_eeprom_multiread(rt2x00dev, EEPROM_MAC_ADDR_0,
-		(u16*)&net_dev->perm_addr[0], 6);
+		(u16*)&hw->perm_addr[0], 6);
 
 	/*
 	 * Check if a valid MAC address has been read.
 	 */
-	if (!is_valid_ether_addr(&net_dev->perm_addr[0]))
+	if (!is_valid_ether_addr(&hw->perm_addr[0]))
 		return -EINVAL;
 
 	/*
-	 * Copy to perm_addr to dev_addr structure.
-	 */
-	memcpy(&net_dev->dev_addr[0], &net_dev->perm_addr[0],
-		sizeof(net_dev->perm_addr));
-	net_dev->addr_len = 6;
-
-	/*
 	 * Write MAC address to register.
 	 */
-	rt2400pci_config_mac_address(rt2x00dev, &net_dev->perm_addr[0]);
+	rt2400pci_config_mac_address(rt2x00dev, &hw->perm_addr[0]);
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_MAC);
 	return 0;
@@ -2549,37 +2461,14 @@ static int rt2400pci_init_mac(struct rt2
 
 static int rt2400pci_init_hw(struct rt2x00_dev *rt2x00dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	struct ieee80211_hw *hw = &rt2x00dev->hw;
 
 	if (GET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW))
 		return 0;
 
 	/*
-	 * IEEE80211 Function callbacks.
-	 */
-	hw->tx			= rt2400pci_tx;
-	hw->reset		= rt2400pci_reset;
-	hw->add_interface	= rt2400pci_add_interface;
-	hw->remove_interface	= rt2400pci_remove_interface;
-	hw->config		= rt2400pci_config;
-	hw->config_interface	= rt2400pci_config_interface;
-	hw->set_multicast_list	= rt2400pci_set_multicast_list;
-	hw->passive_scan	= rt2400pci_passive_scan;
-	hw->get_stats		= rt2400pci_get_stats;
-	hw->set_retry_limit	= rt2400pci_set_retry_limit;
-	hw->conf_tx		= rt2400pci_conf_tx;
-	hw->get_tx_stats	= rt2400pci_get_tx_stats;
-	hw->get_tsf		= rt2400pci_get_tsf;
-	hw->reset_tsf		= rt2400pci_reset_tsf;
-	hw->beacon_update	= rt2400pci_beacon_update;
-	hw->tx_last_beacon	= rt2400pci_tx_last_beacon;
-
-	/*
 	 * IEEE80211 Variables.
 	 */
-	hw->version = IEEE80211_VERSION;
-	hw->name = DRV_NAME;
 	hw->extra_tx_headroom = 0;
  	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
 		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
@@ -2597,8 +2486,9 @@ static int rt2400pci_init_hw(struct rt2x
 	 * will have support for high priority TX frames.
 	 */
 	hw->queues = RING_NUM_TX;
+	hw->dev = rt2x00dev->dev;
 
-	if (ieee80211_register_hw(net_dev, hw))
+	if (ieee80211_register_hw(hw))
 		return -EIO;
 
 	SET_FLAG(rt2x00dev, DEVICE_INITIALIZED_HW);
@@ -2677,7 +2567,6 @@ static void rt2400pci_init_hw_rates(stru
 
 static int rt2400pci_init_hw_modes(struct rt2x00_dev *rt2x00dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(rt2x00dev_pci(rt2x00dev));
 	struct ieee80211_hw *hw = &rt2x00dev->hw;
 
 	/*
@@ -2710,7 +2599,7 @@ static int rt2400pci_init_hw_modes(struc
 	rt2400pci_init_hw_channels(rt2x00dev, hw->modes->channels);
 	rt2400pci_init_hw_rates(rt2x00dev, hw->modes->rates);
 
-	return ieee80211_update_hw(net_dev, hw);
+	return ieee80211_update_hw(hw);
 
 exit_free_channels:
 	kfree(hw->modes->channels);
@@ -2725,9 +2614,9 @@ exit:
 	return -ENOMEM;
 }
 
-static void rt2400pci_free_dev(struct net_device *net_dev)
+static void rt2400pci_free_dev(struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	/*
 	 * Free ring structures.
@@ -2768,9 +2657,9 @@ static void rt2400pci_free_dev(struct ne
 }
 
 static int rt2400pci_alloc_dev(struct pci_dev *pci_dev,
-	struct net_device *net_dev)
+	struct ieee80211_hw *hw)
 {
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	rt2x00dev->dev = pci_dev;
 
@@ -2816,18 +2705,40 @@ static int rt2400pci_alloc_dev(struct pc
 	return 0;
 
 exit:
-	rt2400pci_free_dev(net_dev);
+	rt2400pci_free_dev(hw);
 
 	return -ENODEV;
 }
 
 /*
+ * IEEE80211 Function callbacks.
+ */
+static struct ieee80211_ops rt2400_hw_ops = {
+	.tx			= rt2400pci_tx,
+	.reset			= rt2400pci_reset,
+	.add_interface		= rt2400pci_add_interface,
+	.remove_interface	= rt2400pci_remove_interface,
+	.config			= rt2400pci_config,
+	.config_interface	= rt2400pci_config_interface,
+	.set_multicast_list	= rt2400pci_set_multicast_list,
+	.passive_scan		= rt2400pci_passive_scan,
+	.get_stats		= rt2400pci_get_stats,
+	.set_retry_limit	= rt2400pci_set_retry_limit,
+	.conf_tx		= rt2400pci_conf_tx,
+	.get_tx_stats		= rt2400pci_get_tx_stats,
+	.get_tsf		= rt2400pci_get_tsf,
+	.reset_tsf		= rt2400pci_reset_tsf,
+	.beacon_update		= rt2400pci_beacon_update,
+	.tx_last_beacon		= rt2400pci_tx_last_beacon,
+};
+
+/*
  * PCI driver handlers.
  */
 static int rt2400pci_probe(struct pci_dev *pci_dev,
 	const struct pci_device_id *id)
 {
-	struct net_device *net_dev;
+	struct ieee80211_hw *hw;
 	int status;
 
 	status = pci_request_regions(pci_dev, pci_name(pci_dev));
@@ -2854,30 +2765,27 @@ static int rt2400pci_probe(struct pci_de
 		goto exit_disable_device;
 	}
 
-	net_dev = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), NULL);
-	if (!net_dev) {
+	hw = ieee80211_alloc_hw(sizeof(struct rt2x00_dev), &rt2400_hw_ops);
+	if (!hw) {
 		ERROR("Failed to allocate hardware.\n");
 		status = -ENOMEM;
 		goto exit_disable_device;
 	}
 
-	SET_ETHTOOL_OPS(net_dev, &rt2400pci_ethtool_ops);
-	SET_NETDEV_DEV(net_dev, &pci_dev->dev);
-
-	pci_set_drvdata(pci_dev, net_dev);
+	pci_set_drvdata(pci_dev, hw);
 
-	status = rt2400pci_alloc_dev(pci_dev, net_dev);
+	status = rt2400pci_alloc_dev(pci_dev, hw);
 	if (status) {
 		ERROR("Failed to allocate device.\n");
 		goto exit_free_device;
 	}
 
-	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	ieee80211_netif_oper(hw, NETIF_ATTACH);
 
 	return 0;
 
 exit_free_device:
-	ieee80211_free_hw(net_dev);
+	ieee80211_free_hw(hw);
 
 exit_disable_device:
 	if (status != -EBUSY)
@@ -2893,20 +2801,20 @@ exit_release_regions:
 
 static void rt2400pci_remove(struct pci_dev *pci_dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hw *hw = pci_get_drvdata(pci_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 
 	rt2400pci_disable_radio(rt2x00dev);
 
-	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+	ieee80211_netif_oper(hw, NETIF_DETACH);
 
 	rt2400pci_uninitialize(rt2x00dev);
 
-	rt2400pci_free_dev(net_dev);
+	rt2400pci_free_dev(hw);
 
-	ieee80211_unregister_hw(net_dev);
+	ieee80211_unregister_hw(hw);
 
-	ieee80211_free_hw(net_dev);
+	ieee80211_free_hw(hw);
 
 	pci_set_drvdata(pci_dev, NULL);
 
@@ -2918,8 +2826,8 @@ static void rt2400pci_remove(struct pci_
 #ifdef CONFIG_PM
 static int rt2400pci_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
-	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hw *hw = pci_get_drvdata(pci_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	int status;
 
 	NOTICE("Going to sleep.\n");
@@ -2928,7 +2836,7 @@ static int rt2400pci_suspend(struct pci_
 	 * Disable the radio.
 	 */
 	rt2400pci_disable_radio(rt2x00dev);
-	ieee80211_netif_oper(net_dev, NETIF_DETACH);
+	ieee80211_netif_oper(hw, NETIF_DETACH);
 
 	/*
 	 * Set device mode to sleep for power management.
@@ -2945,7 +2853,7 @@ static int rt2400pci_suspend(struct pci_
 	/*
 	 * Uninitialize hardware.
 	 */
-	rt2400pci_free_dev(net_dev);
+	rt2400pci_free_dev(hw);
 
 	/*
 	 * Disable PCI.
@@ -2957,8 +2865,8 @@ static int rt2400pci_suspend(struct pci_
 
 static int rt2400pci_resume(struct pci_dev *pci_dev)
 {
-	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct rt2x00_dev *rt2x00dev = ieee80211_dev_hw_data(net_dev);
+	struct ieee80211_hw *hw = pci_get_drvdata(pci_dev);
+	struct rt2x00_dev *rt2x00dev = hw->priv;
 	int status;
 
 	NOTICE("Waking up.\n");
@@ -2976,7 +2884,7 @@ static int rt2400pci_resume(struct pci_d
 	/*
 	 * Initialize hardware.
 	 */
-	status = rt2400pci_alloc_dev(pci_dev, net_dev);
+	status = rt2400pci_alloc_dev(pci_dev, hw);
 	if (status) {
 		ERROR("Failed to allocate device.\n");
 		return status;
@@ -2989,7 +2897,7 @@ static int rt2400pci_resume(struct pci_d
 	if (status)
 		return status;
 
-	ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	ieee80211_netif_oper(hw, NETIF_ATTACH);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
index c120a4f..831b27f 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.h
@@ -902,34 +902,34 @@ #define TXPOWER_TO_DEV(__txpower) \
 /*
  * IEEE stack callback functions declarations.
  */
-static int rt2400pci_tx(struct net_device *net_dev,
+static int rt2400pci_tx(struct ieee80211_hw *hw,
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
-static int rt2400pci_reset(struct net_device *net_dev);
-static int rt2400pci_add_interface(struct net_device *net_dev,
+static int rt2400pci_reset(struct ieee80211_hw *hw);
+static int rt2400pci_add_interface(struct ieee80211_hw *hw,
 	struct ieee80211_if_init_conf *conf);
-static void rt2400pci_remove_interface(struct net_device *net_dev,
+static void rt2400pci_remove_interface(struct ieee80211_hw *hw,
 	struct ieee80211_if_init_conf *conf);
-static int rt2400pci_config(struct net_device *net_dev,
+static int rt2400pci_config(struct ieee80211_hw *hw,
 	struct ieee80211_conf *conf);
-static int rt2400pci_config_interface(struct net_device *net_dev, int if_id,
+static int rt2400pci_config_interface(struct ieee80211_hw *hw, int if_id,
 	struct ieee80211_if_conf *conf);
-static void rt2400pci_set_multicast_list(struct net_device *net_dev,
+static void rt2400pci_set_multicast_list(struct ieee80211_hw *hw,
 	unsigned short flags, int mc_count);
-static int rt2400pci_passive_scan(struct net_device *net_dev,
+static int rt2400pci_passive_scan(struct ieee80211_hw *hw,
 	int state, struct ieee80211_scan_conf *conf);
-static int rt2400pci_get_stats(struct net_device *net_dev,
+static int rt2400pci_get_stats(struct ieee80211_hw *hw,
 	struct ieee80211_low_level_stats *stats);
-static int rt2400pci_set_retry_limit(struct net_device *net_dev,
+static int rt2400pci_set_retry_limit(struct ieee80211_hw *hw,
 	u32 short_retry, u32 long_retry);
-static int rt2400pci_conf_tx(struct net_device *net_dev,
+static int rt2400pci_conf_tx(struct ieee80211_hw *hw,
 	int queue, const struct ieee80211_tx_queue_params *params);
-static int rt2400pci_get_tx_stats(struct net_device *net_dev,
+static int rt2400pci_get_tx_stats(struct ieee80211_hw *hw,
 	struct ieee80211_tx_queue_stats *stats);
-static u64 rt2400pci_get_tsf(struct net_device *net_dev);
-static void rt2400pci_reset_tsf(struct net_device *net_dev);
-static int rt2400pci_beacon_update(struct net_device *net_dev,
+static u64 rt2400pci_get_tsf(struct ieee80211_hw *hw);
+static void rt2400pci_reset_tsf(struct ieee80211_hw *hw);
+static int rt2400pci_beacon_update(struct ieee80211_hw *hw,
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
-static int rt2400pci_tx_last_beacon(struct net_device *net_dev);
+static int rt2400pci_tx_last_beacon(struct ieee80211_hw *hw);
 
 /*
  * Radio control functions.
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2x00.h b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
index 0d2739b..38985f0 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/d80211/rt2x00/rt2x00.h
@@ -537,7 +537,7 @@ struct data_ring {
 	/*
 	 * net_device where this ring belongs to.
 	 */
-	struct net_device *net_dev;
+	struct ieee80211_hw *hw;
 
 	/*
 	 * Work structure for bottom half interrupt handling.
-- 
John W. Linville
linville@tuxdriver.com
