From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next-2.6] igb and ixgbe: DOM support cleanups
Date: Tue, 24 Nov 2009 19:57:34 -0800
Message-ID: <1259121454.29779.17.camel@Joe-Laptop.home>
References: <19211.4849.284727.703717@gargle.gargle.HOWL>
	 <1259017659.16503.138.camel@Joe-Laptop.home>
	 <19212.8726.367568.937773@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1166 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933840AbZKYD53 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 22:57:29 -0500
In-Reply-To: <19212.8726.367568.937773@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 19:12 +0100, robert@herjulf.net wrote:
> Joe Perches writes: 
>  > Can you run ./scripts/checkpatch.pl on your patches please?
>  Yes there were many objections... but my linux quantum is for over for now
>  > > +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
>  > > +		goto out;
>  > [etc...]
>  > > +	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
>  > > +		goto out;
>  > 
>  > perhaps this is clearer as:
>  > 
>  > 	if (read_phy_diag(hw, 0x1, reg, loc) ||
>  > 	    read_phy_diag(hw, 0x1, reg2, loc2) ||
>  > 	...
>  > 	    read_phy_diag(hw, 0x1, regN, locN))
>  > 		goto out;
>  Feel free to attack it...

Checkpatch cleanup and make code smaller after
git apply --whitespace=fix <your original patches 1-4>

was:
$ size drivers/net/igb/igb_ethtool.o drivers/net/ixgbe/ixgbe_ethtool.o
   text	   data	    bss	    dec	    hex	filename
  26466	   1544	   8584	  36594	   8ef2	drivers/net/igb/igb_ethtool.o
  31726	   2980	   9128	  43834	   ab3a	drivers/net/ixgbe/ixgbe_ethtool.o

is:
$ size drivers/net/igb/igb_ethtool.o drivers/net/ixgbe/ixgbe_ethtool.o
   text	   data	    bss	    dec	    hex	filename
  24606	   1544	   8000	  34150	   8566	drivers/net/igb/igb_ethtool.o
  29886	   2980	   8552	  41418	   a1ca	drivers/net/ixgbe/ixgbe_ethtool.o

Signed-off-by: Joe Perches <joe@perches.com>

 drivers/net/igb/igb_ethtool.c     |  264 +++++++++++++++--------------------
 drivers/net/ixgbe/ixgbe_ethtool.c |  280 ++++++++++++++++---------------------
 include/linux/ethtool.h           |    4 +-
 3 files changed, 238 insertions(+), 310 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 8fa7b98..b96661a 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -2080,8 +2080,9 @@ static s32 read_phy_diag(struct e1000_hw *hw, u8 page, u8 offset,
 	 * PHY to retrieve the desired data.
 	 */
 
-	i2ccmd = (E1000_I2CCMD_OPCODE_READ) | (page << E1000_I2CCMD_PHY_ADDR_SHIFT) |
-	  ( offset <<  E1000_I2CCMD_REG_ADDR_SHIFT);
+	i2ccmd = (E1000_I2CCMD_OPCODE_READ) |
+		 (page << E1000_I2CCMD_PHY_ADDR_SHIFT) |
+		 (offset <<  E1000_I2CCMD_REG_ADDR_SHIFT);
 
 	wr32(E1000_I2CCMD, i2ccmd);
 
@@ -2107,186 +2108,147 @@ static s32 read_phy_diag(struct e1000_hw *hw, u8 page, u8 offset,
 	return 0;
 }
 
+static s32 read_phy_diag_u32(struct e1000_hw *hw, u8 page, u8 offset, u32 *data)
+{
+	u16 p1;
+	u16 p2;
+	u32 res;
+
+	res = read_phy_diag(hw, page, offset, &p1);
+	if (res)
+		goto out;
+
+	res = read_phy_diag(hw, page, offset + 2, &p2);
+	if (res)
+		goto out;
+
+	*data = ((u32)p1) << 16 | p2;
+
+out:
+	return res;
+}
+
+struct reg_offset {
+	int reg;
+	size_t offset;
+};
+
+#define REG_OFFSET(a, b) \
+	{ .reg = a, .offset = offsetof(struct ethtool_phy_diag, b) }
+
 int igb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u16  p1, p2;
 	int res;
 	u8 type, eo;
+	int i;
 
-	if((res = read_phy_diag(hw, 0x0, DOM_A0_DOM_TYPE, &pd->type)))
+	static const struct reg_offset basic[] = {
+		REG_OFFSET(DOM_A2_TEMP, temp),
+		REG_OFFSET(DOM_A2_TEMP_SLOPE, temp_slope),
+		REG_OFFSET(DOM_A2_TEMP_OFFSET, temp_offset),
+		REG_OFFSET(DOM_A2_VCC, vcc),
+		REG_OFFSET(DOM_A2_VCC_SLOPE, vcc_slope),
+		REG_OFFSET(DOM_A2_VCC_OFFSET, vcc_offset),
+		REG_OFFSET(DOM_A2_TX_BIAS, tx_bias),
+		REG_OFFSET(DOM_A2_TX_I_SLOPE, tx_bias_slope),
+		REG_OFFSET(DOM_A2_TX_I_OFFSET, tx_bias_offset),
+		REG_OFFSET(DOM_A2_TX_PWR, tx_pwr),
+		REG_OFFSET(DOM_A2_TX_PWR_SLOPE, tx_pwr_slope),
+		REG_OFFSET(DOM_A2_TX_PWR_OFFSET, tx_pwr_offset),
+		REG_OFFSET(DOM_A2_RX_PWR, rx_pwr),
+	};
+
+	static const struct reg_offset power[] = {
+		REG_OFFSET(DOM_A2_RX_PWR_0, rx_pwr_cal[0]),
+		REG_OFFSET(DOM_A2_RX_PWR_1, rx_pwr_cal[1]),
+		REG_OFFSET(DOM_A2_RX_PWR_2, rx_pwr_cal[2]),
+		REG_OFFSET(DOM_A2_RX_PWR_3, rx_pwr_cal[3]),
+		REG_OFFSET(DOM_A2_RX_PWR_4, rx_pwr_cal[4]),
+	};
+
+	static const struct reg_offset aw[] = {
+		REG_OFFSET(DOM_A2_TEMP_AHT, temp_aht),
+		REG_OFFSET(DOM_A2_TEMP_ALT, temp_alt),
+		REG_OFFSET(DOM_A2_TEMP_WHT, temp_wht),
+		REG_OFFSET(DOM_A2_TEMP_WLT, temp_wlt),
+		REG_OFFSET(DOM_A2_VCC_AHT, vcc_aht),
+		REG_OFFSET(DOM_A2_VCC_ALT, vcc_alt),
+		REG_OFFSET(DOM_A2_VCC_WHT, vcc_wht),
+		REG_OFFSET(DOM_A2_VCC_WLT, vcc_wlt),
+		REG_OFFSET(DOM_A2_TX_BIAS_AHT, tx_bias_aht),
+		REG_OFFSET(DOM_A2_TX_BIAS_ALT, tx_bias_alt),
+		REG_OFFSET(DOM_A2_TX_BIAS_WHT, tx_bias_wht),
+		REG_OFFSET(DOM_A2_TX_BIAS_WLT, tx_bias_wlt),
+		REG_OFFSET(DOM_A2_TX_PWR_AHT, tx_pwr_aht),
+		REG_OFFSET(DOM_A2_TX_PWR_ALT, tx_pwr_alt),
+		REG_OFFSET(DOM_A2_TX_PWR_WHT, tx_pwr_wht),
+		REG_OFFSET(DOM_A2_TX_PWR_WLT, tx_pwr_wlt),
+		REG_OFFSET(DOM_A2_RX_PWR_AHT, rx_pwr_aht),
+		REG_OFFSET(DOM_A2_RX_PWR_ALT, rx_pwr_alt),
+		REG_OFFSET(DOM_A2_RX_PWR_WHT, rx_pwr_wht),
+		REG_OFFSET(DOM_A2_RX_PWR_WLT, rx_pwr_wlt),
+	};
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_DOM_TYPE, &pd->type);
+	if (res)
 		goto out;
 
-	type =  pd->type >> 8;
+	type = pd->type >> 8;
 
-	if( ~(type) & DOM_TYPE_DOM || type & DOM_TYPE_LEGAGY_DOM)
+	if ((~(type) & DOM_TYPE_DOM) || (type & DOM_TYPE_LEGAGY_DOM))
 		goto out;
 
-	if( type& DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE)  {
+	if (type & DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE) {
 		hw_dbg("DOM module not supported (Address change)\n");
 		goto out;
 	}
 
 	eo = pd->type & 0xFF;
-	if((res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength)))
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength);
+	if (res)
 		goto out;
 
 	/* If supported. Read alarms and Warnings first*/
-	if( eo &  DOM_EO_AW) {
-
-		if((res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm)))
+	if (eo & DOM_EO_AW) {
+		res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm);
+		if (res)
 			goto out;
-
-		if((res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning)))
+		res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning);
+		if (res)
 			goto out;
 	}
 
 	/* Basic diag */
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP, &pd->temp)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_OFFSET, &pd->temp_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC, &pd->vcc)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_SLOPE, &pd->vcc_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_OFFSET, &pd->vcc_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS, &pd->tx_bias)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_SLOPE, &pd->tx_bias_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR, &pd->tx_pwr)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_SLOPE, &pd->tx_pwr_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_OFFSET, &pd->tx_pwr_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR, &pd->rx_pwr)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[0] = (p1<<16) + p2;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[1] = (p1<<16) + p2;
-
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[2] = (p1<<16) + p2;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[3] = (p1<<16) + p2;
 
+	for (i = 0; i < ARRAY_SIZE(basic); i++) {
+		res = read_phy_diag(hw, 0x1, basic[i].reg,
+				    (u16 *)((char *)pd + basic[i].offset));
+		if (res)
+			goto out;
+	}
 
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4, &p1)))
-		goto out;
+	/* Power */
 
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[4] = (p1<<16) + p2;
+	for (i = 0; i < ARRAY_SIZE(power); i++) {
+		res = read_phy_diag_u32(hw, 0x1, power[i].reg,
+					(u32 *)((char *)pd + power[i].offset));
+		if (res)
+			goto out;
+	}
 
 	/* Thresholds for Alarms and Warnings */
-	if( !(eo &  DOM_EO_AW))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_AHT, &pd->temp_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_ALT, &pd->temp_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WHT, &pd->temp_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WLT, &pd->temp_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_AHT, &pd->vcc_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_ALT, &pd->vcc_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WHT, &pd->vcc_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WLT, &pd->vcc_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_AHT, &pd->tx_bias_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_ALT, &pd->tx_bias_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WHT, &pd->tx_bias_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WLT, &pd->tx_bias_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_AHT, &pd->tx_pwr_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_ALT, &pd->tx_pwr_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WHT, &pd->tx_pwr_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WLT, &pd->tx_pwr_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_AHT, &pd->rx_pwr_aht)))
-		goto out;
 
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_ALT, &pd->rx_pwr_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WHT, &pd->rx_pwr_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WLT, &pd->rx_pwr_wlt)))
-		goto out;
+	if (eo & DOM_EO_AW) {
+		for (i = 0; i < ARRAY_SIZE(basic); i++) {
+			res = read_phy_diag(hw, 0x1, aw[i].reg,
+					    (u16 *)((char *)pd + aw[i].offset));
+			if (res)
+				goto out;
+		}
+	}
 
 out:
 	return res;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 6276e17..322b613 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2108,201 +2108,167 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 }
 
-static s32 read_phy_diag(struct ixgbe_hw *hw, u8 page, u8 offset,
-					  u16 *data)
+static s32 read_phy_diag(struct ixgbe_hw *hw, u8 page, u8 offset, u16 *data)
 {
-	s32 status = 0;
-	u8 tmp [2];
+	s32 status;
+	u8 hi, lo;
 
-	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &tmp[0]);
-	if(status != 0)
-		goto err;
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &hi);
+	if (status)
+		goto out;
+
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &lo);
+	if (status)
+		goto out;
+
+	*data = (((u16)hi) << 8) | lo;
 
-	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &tmp[1]);
-	*data = (tmp[0]<<8) | tmp[1];
-err:
+out:
 	return status;
 }
 
+static s32 read_phy_diag_u32(struct ixgbe_hw *hw, u8 page, u8 offset, u32 *data)
+{
+	u16 p1;
+	u16 p2;
+	u32 res;
+
+	res = read_phy_diag(hw, page, offset, &p1);
+	if (res)
+		goto out;
+
+	res = read_phy_diag(hw, page, offset + 2, &p2);
+	if (res)
+		goto out;
+
+	*data = ((u32)p1) << 16 | p2;
+
+out:
+	return res;
+}
+
+struct reg_offset {
+	int reg;
+	size_t offset;
+};
+
+#define REG_OFFSET(a, b) \
+	{ .reg = a, .offset = offsetof(struct ethtool_phy_diag, b) }
+
 int ixgb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	u16  p1, p2;
 	int res;
 	u8 type, eo;
+	int i;
 
-	if((res = read_phy_diag(hw, 0x0, DOM_A0_DOM_TYPE, &pd->type)))
+	static const struct reg_offset basic[] = {
+		REG_OFFSET(DOM_A2_TEMP, temp),
+		REG_OFFSET(DOM_A2_TEMP_SLOPE, temp_slope),
+		REG_OFFSET(DOM_A2_TEMP_OFFSET, temp_offset),
+		REG_OFFSET(DOM_A2_VCC, vcc),
+		REG_OFFSET(DOM_A2_VCC_SLOPE, vcc_slope),
+		REG_OFFSET(DOM_A2_VCC_OFFSET, vcc_offset),
+		REG_OFFSET(DOM_A2_TX_BIAS, tx_bias),
+		REG_OFFSET(DOM_A2_TX_I_SLOPE, tx_bias_slope),
+		REG_OFFSET(DOM_A2_TX_I_OFFSET, tx_bias_offset),
+		REG_OFFSET(DOM_A2_TX_PWR, tx_pwr),
+		REG_OFFSET(DOM_A2_TX_PWR_SLOPE, tx_pwr_slope),
+		REG_OFFSET(DOM_A2_TX_PWR_OFFSET, tx_pwr_offset),
+		REG_OFFSET(DOM_A2_RX_PWR, rx_pwr),
+	};
+
+	static const struct reg_offset power[] = {
+		REG_OFFSET(DOM_A2_RX_PWR_0, rx_pwr_cal[0]),
+		REG_OFFSET(DOM_A2_RX_PWR_1, rx_pwr_cal[1]),
+		REG_OFFSET(DOM_A2_RX_PWR_2, rx_pwr_cal[2]),
+		REG_OFFSET(DOM_A2_RX_PWR_3, rx_pwr_cal[3]),
+		REG_OFFSET(DOM_A2_RX_PWR_4, rx_pwr_cal[4]),
+	};
+
+	static const struct reg_offset aw[] = {
+		REG_OFFSET(DOM_A2_TEMP_AHT, temp_aht),
+		REG_OFFSET(DOM_A2_TEMP_ALT, temp_alt),
+		REG_OFFSET(DOM_A2_TEMP_WHT, temp_wht),
+		REG_OFFSET(DOM_A2_TEMP_WLT, temp_wlt),
+		REG_OFFSET(DOM_A2_VCC_AHT, vcc_aht),
+		REG_OFFSET(DOM_A2_VCC_ALT, vcc_alt),
+		REG_OFFSET(DOM_A2_VCC_WHT, vcc_wht),
+		REG_OFFSET(DOM_A2_VCC_WLT, vcc_wlt),
+		REG_OFFSET(DOM_A2_TX_BIAS_AHT, tx_bias_aht),
+		REG_OFFSET(DOM_A2_TX_BIAS_ALT, tx_bias_alt),
+		REG_OFFSET(DOM_A2_TX_BIAS_WHT, tx_bias_wht),
+		REG_OFFSET(DOM_A2_TX_BIAS_WLT, tx_bias_wlt),
+		REG_OFFSET(DOM_A2_TX_PWR_AHT, tx_pwr_aht),
+		REG_OFFSET(DOM_A2_TX_PWR_ALT, tx_pwr_alt),
+		REG_OFFSET(DOM_A2_TX_PWR_WHT, tx_pwr_wht),
+		REG_OFFSET(DOM_A2_TX_PWR_WLT, tx_pwr_wlt),
+		REG_OFFSET(DOM_A2_RX_PWR_AHT, rx_pwr_aht),
+		REG_OFFSET(DOM_A2_RX_PWR_ALT, rx_pwr_alt),
+		REG_OFFSET(DOM_A2_RX_PWR_WHT, rx_pwr_wht),
+		REG_OFFSET(DOM_A2_RX_PWR_WLT, rx_pwr_wlt),
+	};
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_DOM_TYPE, &pd->type);
+	if (res)
 		goto out;
 
-	type =  pd->type >> 8;
+	type = pd->type >> 8;
 
-	if( ~(type) & DOM_TYPE_DOM || type & DOM_TYPE_LEGAGY_DOM)
+	if ((~(type) & DOM_TYPE_DOM) || (type & DOM_TYPE_LEGAGY_DOM))
 		goto out;
 
-	if( type& DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE)  {
+	if (type & DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE)  {
 		hw_dbg(hw, "DOM module not supported (Address change)\n");
 		goto out;
 	}
 
 	eo = pd->type & 0xFF;
-	if((res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength)))
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength);
+	if (res)
 		goto out;
 
 	/* If supported. Read alarms and Warnings first*/
-	if( eo &  DOM_EO_AW) {
-
-		if((res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm)))
+	if (eo & DOM_EO_AW) {
+		res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm);
+		if (res)
 			goto out;
 
-		if((res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning)))
+		res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning);
+		if (res)
 			goto out;
 	}
 
 	/* Basic diag */
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP, &pd->temp)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_SLOPE, &pd->temp_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_OFFSET, &pd->temp_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC, &pd->vcc)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_SLOPE, &pd->vcc_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_OFFSET, &pd->vcc_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS, &pd->tx_bias)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_SLOPE, &pd->tx_bias_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_I_OFFSET, &pd->tx_bias_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR, &pd->tx_pwr)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_SLOPE, &pd->tx_pwr_slope)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_OFFSET, &pd->tx_pwr_offset)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR, &pd->rx_pwr)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_0+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[0] = (p1<<16) + p2;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_1+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[1] = (p1<<16) + p2;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_2+2, &p2)))
-		goto out;
-
-	pd->rx_pwr_cal[2] = (p1<<16) + p2;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3, &p1)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_3+2, &p2)))
-		goto out;
 
-	pd->rx_pwr_cal[3] = (p1<<16) + p2;
-
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4, &p1)))
-		goto out;
+	for (i = 0; i < ARRAY_SIZE(basic); i++) {
+		res = read_phy_diag(hw, 0x1, basic[i].reg,
+				    (u16 *)((char *)pd + basic[i].offset));
+		if (res)
+			goto out;
+	}
 
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_4+2, &p2)))
-		goto out;
+	/* Power */
 
-	pd->rx_pwr_cal[4] = (p1<<16) + p2;
+	for (i = 0; i < ARRAY_SIZE(power); i++) {
+		res = read_phy_diag_u32(hw, 0x1, power[i].reg,
+					(u32 *)((char *)pd + power[i].offset));
+		if (res)
+			goto out;
+	}
 
 	/* Thresholds for Alarms and Warnings */
-	if( !(eo &  DOM_EO_AW))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_AHT, &pd->temp_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_ALT, &pd->temp_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WHT, &pd->temp_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TEMP_WLT, &pd->temp_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_AHT, &pd->vcc_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_ALT, &pd->vcc_alt)))
-		goto out;
 
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WHT, &pd->vcc_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_VCC_WLT, &pd->vcc_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_AHT, &pd->tx_bias_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_ALT, &pd->tx_bias_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WHT, &pd->tx_bias_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_BIAS_WLT, &pd->tx_bias_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_AHT, &pd->tx_pwr_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_ALT, &pd->tx_pwr_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WHT, &pd->tx_pwr_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_TX_PWR_WLT, &pd->tx_pwr_wlt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_AHT, &pd->rx_pwr_aht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_ALT, &pd->rx_pwr_alt)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WHT, &pd->rx_pwr_wht)))
-		goto out;
-
-	if((res = read_phy_diag(hw, 0x1, DOM_A2_RX_PWR_WLT, &pd->rx_pwr_wlt)))
-		goto out;
+	if (eo & DOM_EO_AW) {
+		for (i = 0; i < ARRAY_SIZE(basic); i++) {
+			res = read_phy_diag(hw, 0x1, aw[i].reg,
+					    (u16 *)((char *)pd + aw[i].offset));
+			if (res)
+				goto out;
+		}
+	}
 
 out:
 	return res;
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9c2f06a..4e45a94 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -546,7 +546,7 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
-	int     (*get_phy_diag)(struct net_device *, struct ethtool_phy_diag*);
+	int     (*get_phy_diag)(struct net_device *, struct ethtool_phy_diag *);
 };
 #endif /* __KERNEL__ */
 
@@ -605,7 +605,7 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
-#define ETHTOOL_GPHYDIAG        0x00000035 /* Get PHY diagnostics */
+#define	ETHTOOL_GPHYDIAG	0x00000035 /* Get PHY diagnostics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET


