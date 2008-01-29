From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 2/3]  Add flexible wake filter support to e1000e
Date: Tue, 29 Jan 2008 13:02:13 -0800
Message-ID: <1201640533.11148.33.camel@strongmad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18854 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751885AbYA2VVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:21:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to e1000e for Wake-on-Lan flexible filters.  This feature is
supported by all hardware that the driver supports.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 6232c3e..3c18a09 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -65,6 +65,15 @@
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
 #define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
+/* Four Flexible Filters are supported */
+#define E1000_FLEXIBLE_FILTER_COUNT_MAX 4
+#define E1000_WUFC_ALL_FILTERS  0x000F00FF /* Mask for all wakeup filters */
+#define E1000_WUFC_FLX_OFFSET   16 /* Offset to the Flexible Filters bits */
+#define E1000_WUFC_FLX_FILTERS  0x000F0000 /* Mask for the 4 flexible filters */
+
+/* Each Flexible Filter is at most 128 (0x80) bytes in length */
+#define E1000_FLEXIBLE_FILTER_SIZE_MAX  128
+
 /* Extended Device Control */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Defineable Pin 7 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 8b88c22..da0538a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -267,6 +267,7 @@ struct e1000_adapter {
 	unsigned long led_status;
 
 	unsigned int flags;
+	u32 wol_filters;
 };
 
 struct e1000_info {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 9fab444..25b7b4f 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -1633,7 +1633,8 @@ static void e1000_get_wol(struct net_device *netdev,
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
 	                 WAKE_BCAST | WAKE_MAGIC |
-	                 WAKE_PHY | WAKE_ARP;
+	                 WAKE_PHY | WAKE_ARP |
+	                 WAKE_FILTER;
 
 	/* apply any specific unsupported masks here */
 	if (adapter->flags & FLAG_NO_WAKE_UCAST) {
@@ -1656,6 +1657,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		wol->wolopts |= WAKE_PHY;
 	if (adapter->wol & E1000_WUFC_ARP)
 		wol->wolopts |= WAKE_ARP;
+	if (adapter->wol & E1000_WUFC_FLX_FILTERS)
+		wol->wolopts |= WAKE_FILTER;
 }
 
 static int e1000_set_wol(struct net_device *netdev,
@@ -1684,6 +1687,95 @@ static int e1000_set_wol(struct net_device *netdev,
 		adapter->wol |= E1000_WUFC_LNKC;
 	if (wol->wolopts & WAKE_ARP)
 		adapter->wol |= E1000_WUFC_ARP;
+	if (wol->wolopts & WAKE_FILTER)
+		adapter->wol |= adapter->wol_filters;
+
+	return 0;
+}
+
+static int e1000_get_wol_filter(struct net_device *netdev,
+				struct ethtool_wol_filter *wolfilt,
+				u16 *mask_val)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 mask, mt_val, vt_val, fflt, shift;
+	int i;
+
+	if (wolfilt->cmd == ETHTOOL_GNUMWOLFILT) {
+		wolfilt->index = E1000_FLEXIBLE_FILTER_COUNT_MAX;
+		wolfilt->len = 0;
+		return 0;
+	}
+
+	if (wolfilt->index > E1000_FLEXIBLE_FILTER_COUNT_MAX)
+		return -EOPNOTSUPP;
+	
+	mask = 1 << wolfilt->index;
+	shift = wolfilt->index * 8;
+
+	fflt = E1000_READ_REG_ARRAY(hw, E1000_FFLT, wolfilt->index*2);
+	wolfilt->len = fflt & 0xff;
+	for (i = 0; i < wolfilt->len; i++) {
+		mt_val = E1000_READ_REG_ARRAY(hw, E1000_FFMT, i*2);
+		vt_val = E1000_READ_REG_ARRAY(hw, E1000_FFVT, i*2);
+		mt_val &= mask;
+		vt_val = (vt_val >> shift) & 0xff;
+		if (!mt_val)
+			mask_val[i] = WOL_FILTER_IGNORE_OCTET | vt_val;
+		else
+			mask_val[i] = vt_val;
+	}
+
+	return 0;
+}
+
+static int e1000_set_wol_filter(struct net_device *netdev,
+				struct ethtool_wol_filter *wolfilt,
+				u16 *mask_val)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int i, shift;
+	u32 mask, wufc, mt_val, vt_val, fflt;
+
+	if ((wolfilt->index > E1000_FLEXIBLE_FILTER_COUNT_MAX) ||
+	    (wolfilt->len > E1000_FLEXIBLE_FILTER_SIZE_MAX))
+		return -EOPNOTSUPP;
+	
+	wufc = er32(WUFC);
+	mask = 1 << wolfilt->index;
+	if (wolfilt->len) {
+		shift = wolfilt->index * 8;
+		/* first, disable all filters */
+		ew32(WUFC, (wufc & ~E1000_WUFC_FLX_FILTERS));
+		for (i = 0; i < wolfilt->len; i++) {
+			mt_val = E1000_READ_REG_ARRAY(hw, E1000_FFMT, i*2);
+			vt_val = E1000_READ_REG_ARRAY(hw, E1000_FFVT, i*2);
+			vt_val &= ~(0xffL << shift);
+			if (mask_val[i] & WOL_FILTER_IGNORE_OCTET)
+				mt_val &= ~mask;
+			else
+				mt_val |= mask;
+
+			vt_val |= ((mask_val[i] & 0xff) << shift);
+			E1000_WRITE_REG_ARRAY(hw, E1000_FFMT, i*2, mt_val);
+			E1000_WRITE_REG_ARRAY(hw, E1000_FFVT, i*2, vt_val);
+		}
+		adapter->wol_filters |= mask << E1000_WUFC_FLX_OFFSET;
+	} else {
+		/* account for zero-length filters */
+		adapter->wol_filters &= ~(mask << E1000_WUFC_FLX_OFFSET);
+		wufc &= ~(mask << E1000_WUFC_FLX_OFFSET);
+	}
+
+	fflt = E1000_READ_REG_ARRAY(hw, E1000_FFLT, wolfilt->index * 2);
+	fflt &= ~0xff;
+	fflt |= wolfilt->len;
+	E1000_WRITE_REG_ARRAY(hw, E1000_FFLT, wolfilt->index * 2, fflt);
+	/* restore active filter settings.  This filter will not be
+	   active until enabled with ETHTOOL_SWOL. */
+	ew32(WUFC, wufc);
 
 	return 0;
 }
@@ -1789,6 +1881,8 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_regs		= e1000_get_regs,
 	.get_wol		= e1000_get_wol,
 	.set_wol		= e1000_set_wol,
+	.get_wol_filter		= e1000_get_wol_filter,
+	.set_wol_filter		= e1000_set_wol_filter,
 	.get_msglevel		= e1000_get_msglevel,
 	.set_msglevel		= e1000_set_msglevel,
 	.nway_reset		= e1000_nway_reset,
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 3c5862f..3979ec0 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -203,6 +203,8 @@ enum e1e_registers {
 	E1000_SWSM      = 0x05B50, /* SW Semaphore */
 	E1000_FWSM      = 0x05B54, /* FW Semaphore */
 	E1000_HICR      = 0x08F00, /* Host Inteface Control */
+	E1000_FFMT      = 0x09000, /* Flexible Filter Mask Table - RW Array */
+	E1000_FFVT      = 0x09800, /* Flexible Filter Value Table - RW Array */
 };
 
 /* RSS registers */


