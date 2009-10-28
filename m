From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 03/23] igb: misc cleanups within igb_ethtool.c
Date: Wed, 28 Oct 2009 02:46:20 -0700
Message-ID: <20091028094619.13156.19282.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:39734
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbZJ1JuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:50:03 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch just goes thorugh and does several cleanups on igb_ethtool.c.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |  105 +++++++++++++++++++++++------------------
 1 files changed, 60 insertions(+), 45 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 84fe25a..d24b902 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -101,24 +101,25 @@ static const struct igb_stats igb_gstrings_stats[] = {
 };
 
 #define IGB_QUEUE_STATS_LEN \
-	(((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues)* \
+	((((struct igb_adapter *)netdev_priv(netdev))->num_rx_queues * \
 	  (sizeof(struct igb_rx_queue_stats) / sizeof(u64))) + \
-	 ((((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues) * \
+	 (((struct igb_adapter *)netdev_priv(netdev))->num_tx_queues * \
 	  (sizeof(struct igb_tx_queue_stats) / sizeof(u64))))
 #define IGB_GLOBAL_STATS_LEN	\
-	sizeof(igb_gstrings_stats) / sizeof(struct igb_stats)
+	(sizeof(igb_gstrings_stats) / sizeof(struct igb_stats))
 #define IGB_STATS_LEN (IGB_GLOBAL_STATS_LEN + IGB_QUEUE_STATS_LEN)
 static const char igb_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register test  (offline)", "Eeprom test    (offline)",
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
-#define IGB_TEST_LEN sizeof(igb_gstrings_test) / ETH_GSTRING_LEN
+#define IGB_TEST_LEN (sizeof(igb_gstrings_test) / ETH_GSTRING_LEN)
 
 static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
 
 	if (hw->phy.media_type == e1000_media_type_copper) {
 
@@ -153,17 +154,20 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	ecmd->transceiver = XCVR_INTERNAL;
 
-	if (rd32(E1000_STATUS) & E1000_STATUS_LU) {
+	status = rd32(E1000_STATUS);
 
-		adapter->hw.mac.ops.get_speed_and_duplex(hw,
-					&adapter->link_speed,
-					&adapter->link_duplex);
-		ecmd->speed = adapter->link_speed;
+	if (status & E1000_STATUS_LU) {
 
-		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
-		 *          and HALF_DUPLEX != DUPLEX_HALF */
+		if ((status & E1000_STATUS_SPEED_1000) ||
+		    hw->phy.media_type != e1000_media_type_copper)
+			ecmd->speed = SPEED_1000;
+		else if (status & E1000_STATUS_SPEED_100)
+			ecmd->speed = SPEED_100;
+		else
+			ecmd->speed = SPEED_10;
 
-		if (adapter->link_duplex == FULL_DUPLEX)
+		if ((status & E1000_STATUS_FD) ||
+		    hw->phy.media_type != e1000_media_type_copper)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
@@ -254,8 +258,9 @@ static int igb_set_pauseparam(struct net_device *netdev,
 		if (netif_running(adapter->netdev)) {
 			igb_down(adapter);
 			igb_up(adapter);
-		} else
+		} else {
 			igb_reset(adapter);
+		}
 	} else {
 		if (pause->rx_pause && pause->tx_pause)
 			hw->fc.requested_mode = e1000_fc_full;
@@ -308,7 +313,7 @@ static int igb_set_tx_csum(struct net_device *netdev, u32 data)
 
 	if (data) {
 		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type == e1000_82576)
+		if (adapter->hw.mac.type >= e1000_82576)
 			netdev->features |= NETIF_F_SCTP_CSUM;
 	} else {
 		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
@@ -735,12 +740,12 @@ static int igb_set_ringparam(struct net_device *netdev,
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	new_rx_count = max(ring->rx_pending, (u32)IGB_MIN_RXD);
-	new_rx_count = min(new_rx_count, (u32)IGB_MAX_RXD);
+	new_rx_count = min(ring->rx_pending, (u32)IGB_MAX_RXD);
+	new_rx_count = max(new_rx_count, (u16)IGB_MIN_RXD);
 	new_rx_count = ALIGN(new_rx_count, REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	new_tx_count = max(ring->tx_pending, (u32)IGB_MIN_TXD);
-	new_tx_count = min(new_tx_count, (u32)IGB_MAX_TXD);
+	new_tx_count = min(ring->tx_pending, (u32)IGB_MAX_TXD);
+	new_tx_count = max(new_tx_count, (u16)IGB_MIN_TXD);
 	new_tx_count = ALIGN(new_tx_count, REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if ((new_tx_count == adapter->tx_ring_count) &&
@@ -941,7 +946,7 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 pat, val;
-	u32 _test[] =
+	static const u32 _test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {
 		wr32(reg, (_test[pat] & write));
@@ -954,6 +959,7 @@ static bool reg_pattern_test(struct igb_adapter *adapter, u64 *data,
 			return 1;
 		}
 	}
+
 	return 0;
 }
 
@@ -971,6 +977,7 @@ static bool reg_set_and_check(struct igb_adapter *adapter, u64 *data,
 		*data = reg;
 		return 1;
 	}
+
 	return 0;
 }
 
@@ -993,14 +1000,14 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 	u32 value, before, after;
 	u32 i, toggle;
 
-	toggle = 0x7FFFF3FF;
-
 	switch (adapter->hw.mac.type) {
 	case e1000_82576:
 		test = reg_test_82576;
+		toggle = 0x7FFFF3FF;
 		break;
 	default:
 		test = reg_test_82575;
+		toggle = 0x7FFFF3FF;
 		break;
 	}
 
@@ -1078,8 +1085,7 @@ static int igb_eeprom_test(struct igb_adapter *adapter, u64 *data)
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
 	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
-		if ((adapter->hw.nvm.ops.read(&adapter->hw, i, 1, &temp))
-		    < 0) {
+		if ((adapter->hw.nvm.ops.read(&adapter->hw, i, 1, &temp)) < 0) {
 			*data = 1;
 			break;
 		}
@@ -1095,8 +1101,7 @@ static int igb_eeprom_test(struct igb_adapter *adapter, u64 *data)
 
 static irqreturn_t igb_test_intr(int irq, void *data)
 {
-	struct net_device *netdev = (struct net_device *) data;
-	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct igb_adapter *adapter = (struct igb_adapter *) data;
 	struct e1000_hw *hw = &adapter->hw;
 
 	adapter->test_icr |= rd32(E1000_ICR);
@@ -1120,7 +1125,6 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 			*data = 1;
 			return -1;
 		}
-
 	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int = false;
 		if (request_irq(irq,
@@ -1138,6 +1142,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	}
 	dev_info(&adapter->pdev->dev, "testing %s interrupt\n",
 		(shared_int ? "shared" : "unshared"));
+
 	/* Disable all the interrupts */
 	wr32(E1000_IMC, ~0);
 	msleep(10);
@@ -1363,7 +1368,10 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 reg;
 
-	if (hw->phy.media_type == e1000_media_type_internal_serdes) {
+	reg = rd32(E1000_CTRL_EXT);
+
+	/* use CTRL_EXT to identify link type as SGMII can appear as copper */
+	if (reg & E1000_CTRL_EXT_LINK_MODE_MASK) {
 		reg = rd32(E1000_RCTL);
 		reg |= E1000_RCTL_LBM_TCVR;
 		wr32(E1000_RCTL, reg);
@@ -1394,11 +1402,9 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 		wr32(E1000_PCS_LCTL, reg);
 
 		return 0;
-	} else if (hw->phy.media_type == e1000_media_type_copper) {
-		return igb_set_phy_loopback(adapter);
 	}
 
-	return 7;
+	return igb_set_phy_loopback(adapter);
 }
 
 static void igb_loopback_cleanup(struct igb_adapter *adapter)
@@ -1424,19 +1430,21 @@ static void igb_create_lbtest_frame(struct sk_buff *skb,
 				    unsigned int frame_size)
 {
 	memset(skb->data, 0xFF, frame_size);
-	frame_size &= ~1;
-	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
-	memset(&skb->data[frame_size / 2 + 10], 0xBE, 1);
-	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
+	frame_size /= 2;
+	memset(&skb->data[frame_size], 0xAA, frame_size - 1);
+	memset(&skb->data[frame_size + 10], 0xBE, 1);
+	memset(&skb->data[frame_size + 12], 0xAF, 1);
 }
 
 static int igb_check_lbtest_frame(struct sk_buff *skb, unsigned int frame_size)
 {
-	frame_size &= ~1;
-	if (*(skb->data + 3) == 0xFF)
-		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
-		   (*(skb->data + frame_size / 2 + 12) == 0xAF))
+	frame_size /= 2;
+	if (*(skb->data + 3) == 0xFF) {
+		if ((*(skb->data + frame_size + 10) == 0xBE) &&
+		   (*(skb->data + frame_size + 12) == 0xAF)) {
 			return 0;
+		}
+	}
 	return 13;
 }
 
@@ -1513,7 +1521,8 @@ static int igb_run_loopback_test(struct igb_adapter *adapter)
 	igb_create_lbtest_frame(skb, size);
 	skb_put(skb, size);
 
-	/* Calculate the loop count based on the largest descriptor ring
+	/*
+	 * Calculate the loop count based on the largest descriptor ring
 	 * The idea is to wrap the largest ring a number of times using 64
 	 * send/receive pairs during each loop
 	 */
@@ -1605,8 +1614,7 @@ static int igb_link_test(struct igb_adapter *adapter, u64 *data)
 		if (hw->mac.autoneg)
 			msleep(4000);
 
-		if (!(rd32(E1000_STATUS) &
-		      E1000_STATUS_LU))
+		if (!(rd32(E1000_STATUS) & E1000_STATUS_LU))
 			*data = 1;
 	}
 	return *data;
@@ -1788,7 +1796,6 @@ static int igb_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 		adapter->wol |= E1000_WUFC_BC;
 	if (wol->wolopts & WAKE_MAGIC)
 		adapter->wol |= E1000_WUFC_MAG;
-
 	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
 
 	return 0;
@@ -1801,12 +1808,19 @@ static int igb_phys_id(struct net_device *netdev, u32 data)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long timeout;
 
-	if (!data || data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ))
-		data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
+	timeout = data * 1000;
+
+	/*
+	 *  msleep_interruptable only accepts unsigned int so we are limited
+	 * in how long a duration we can wait
+	 */
+	if (!timeout || timeout > UINT_MAX)
+		timeout = UINT_MAX;
 
 	igb_blink_led(hw);
-	msleep_interruptible(data * 1000);
+	msleep_interruptible(timeout);
 
 	igb_led_off(hw);
 	clear_bit(IGB_LED_ON, &adapter->led_status);
@@ -1916,6 +1930,7 @@ static void igb_get_ethtool_stats(struct net_device *netdev,
 	char *p = NULL;
 
 	igb_update_stats(adapter);
+
 	for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
 		switch (igb_gstrings_stats[i].type) {
 		case NETDEV_STATS:

