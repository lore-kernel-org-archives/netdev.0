From: Robert Olsson <robert@herjulf.net>
Subject: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 4/5 for net-next-2.6
Date: Mon, 23 Nov 2009 23:55:45 +0100
Message-ID: <19211.4849.284727.703717@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-2-sn3.vrr.skanova.net ([81.228.9.186]:34576 "EHLO
	av9-2-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756565AbZKWWzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:55:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Untested.

					--ro


diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 026e94a..a5bdd65 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -34,9 +34,11 @@
 #include <linux/ethtool.h>
 #include <linux/vmalloc.h>
 #include <linux/uaccess.h>
+#include <net/dom.h>
 
 #include "ixgbe.h"
-
+#include "ixgbe_phy.h"
+#include "ixgbe_common.h"
 
 #define IXGBE_ALL_RAR_ENTRIES 16
 
@@ -2031,6 +2033,206 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 }
 
+static s32 read_phy_diag(struct ixgbe_hw *hw, u8 page, u8 offset,
+					  u16 *data)
+{
+	s32 status = 0; 
+	u8 tmp [2];
+
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &tmp[0]); 
+	if(status != 0) 
+		goto err;
+
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &tmp[1]);
+	*data = (tmp[0]<<8) | tmp[1];
+err:
+	return status;
+}
+
+int ixgb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u16  p1, p2; 
+	int res;
+	u8 type, eo; 
+
+	if((res = read_phy_diag(hw, 0x0, DOM_A0_DOM_TYPE, &pd->type)))
+		goto out;
+
+	type =  pd->type >> 8;
+
+	if( ~(type) & DOM_TYPE_DOM || type & DOM_TYPE_LEGAGY_DOM)
+		goto out;
+
+	if( type& DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE)  {
+		hw_dbg(hw, "DOM module not supported (Address change)\n");
+		goto out;
+	}
+	
+	eo = pd->type & 0xFF;
+	if((res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength)))
+		goto out;
+
+	/* If supported. Read alarms and Warnings first*/
+	if( eo &  DOM_EO_AW) {
+
+		if((res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm)))
+			goto out;
+		
+		if((res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning)))
+			goto out;
+	}
+
+	/* Basic diag */
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP, &pd->temp)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_OFFSET, &pd->temp_offset)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC, &pd->vcc)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_SLOPE, &pd->vcc_slope)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_OFFSET, &pd->vcc_offset)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS, &pd->tx_bias)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_SLOPE, &pd->tx_bias_slope)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR, &pd->tx_pwr))) 
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_SLOPE, &pd->tx_pwr_slope))) 
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_OFFSET, &pd->tx_pwr_offset))) 
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR, &pd->rx_pwr)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0, &p1)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0+2, &p2)))
+		goto out;
+	
+	pd->rx_pwr_cal[0] = (p1<<16) + p2;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1, &p1)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1+2, &p2)))
+		goto out;
+	
+	pd->rx_pwr_cal[1] = (p1<<16) + p2;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2, &p1)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2+2, &p2)))
+		goto out;
+	
+	pd->rx_pwr_cal[2] = (p1<<16) + p2;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3, &p1)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3+2, &p2)))
+		goto out;
+	
+	pd->rx_pwr_cal[3] = (p1<<16) + p2;
+
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4, &p1)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4+2, &p2)))
+		goto out;
+		
+	pd->rx_pwr_cal[4] = (p1<<16) + p2;
+
+	/* Thresholds for Alarms and Warnings */
+	if( !(eo &  DOM_EO_AW)) 
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_AHT, &pd->temp_aht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_ALT, &pd->temp_alt)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WHT, &pd->temp_wht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WLT, &pd->temp_wlt)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_AHT, &pd->vcc_aht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_ALT, &pd->vcc_alt)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WHT, &pd->vcc_wht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WLT, &pd->vcc_wlt)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_AHT, &pd->tx_bias_aht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_ALT, &pd->tx_bias_alt)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WHT, &pd->tx_bias_wht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WLT, &pd->tx_bias_wlt)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_AHT, &pd->tx_pwr_aht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_ALT, &pd->tx_pwr_alt)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WHT, &pd->tx_pwr_wht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WLT, &pd->tx_pwr_wlt)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_AHT, &pd->rx_pwr_aht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_ALT, &pd->rx_pwr_alt)))
+		goto out;
+
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WHT, &pd->rx_pwr_wht)))
+		goto out;
+	
+	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WLT, &pd->rx_pwr_wlt)))
+		goto out;
+
+out:
+	return res;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2066,5 +2268,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.get_phy_diag           = ixgb_get_phy_diag,
 };
 

