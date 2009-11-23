From: Robert Olsson <robert@herjulf.net>
Subject: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 3/5 for net-next-2.6
Date: Mon, 23 Nov 2009 23:52:52 +0100
Message-ID: <19211.4676.197562.655999@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from av9-1-sn3.vrr.skanova.net ([81.228.9.185]:34320 "EHLO
	av9-1-sn3.vrr.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872AbZKWWw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:52:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ac9d527..5d190ad 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -34,6 +34,7 @@
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/ethtool.h>
+#include <net/dom.h>
 #include <linux/sched.h>
 
 #include "igb.h"
@@ -2063,6 +2064,234 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static s32 read_phy_diag(struct e1000_hw *hw, u8 page, u8 offset,
+					  u16 *data)
+{
+	u32 i, i2ccmd = 0;
+	
+	if (offset > E1000_MAX_SGMII_PHY_REG_ADDR) {
+		hw_dbg("DOM Register Address %u is out of range\n", offset);
+		return -E1000_ERR_PARAM;
+	}
+
+	/*
+	 * Set up Op-code, Phy Address, and register address in the I2CCMD
+	 * register.  The MAC will take care of interfacing with the
+	 * PHY to retrieve the desired data.
+	 */
+
+	i2ccmd = (E1000_I2CCMD_OPCODE_READ) | (page << E1000_I2CCMD_PHY_ADDR_SHIFT) | 
+	  ( offset <<  E1000_I2CCMD_REG_ADDR_SHIFT);
+
+	wr32(E1000_I2CCMD, i2ccmd);
+
+	/* Poll the ready bit to see if the I2C read completed */
+	for (i = 0; i < E1000_I2CCMD_PHY_TIMEOUT; i++) {
+		udelay(50);
+		i2ccmd = rd32(E1000_I2CCMD);
+		//printk("DATA i2ccmd=0x%x\n", i2ccmd);
+		if (i2ccmd & E1000_I2CCMD_READY)
+			break;
+	}
+	if (!(i2ccmd & E1000_I2CCMD_READY)) {
+		hw_dbg("I2CCMD Read did not complete\n");
+		return -E1000_ERR_PHY;
+	}
+	if (i2ccmd & E1000_I2CCMD_ERROR) {
+		hw_dbg("I2CCMD Error bit set\n");
+		return -E1000_ERR_PHY;
+	}
+
+	/* Need to byte-swap the 16-bit value. */
+	*data = ((i2ccmd >> 8) & 0x00FF) | ((i2ccmd << 8) & 0xFF00);
+	return 0;
+}
+
+int igb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
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
+		hw_dbg("DOM module not supported (Address change)\n");
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
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2097,6 +2326,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+	.get_phy_diag           = igb_get_phy_diag,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
