From: Joe Perches <joe@perches.com>
Subject: Re: Diagnostic Monitoring Interface Monitoring (DOM) PATCH 0/5 for
 net-next-2.6
Date: Wed, 25 Nov 2009 12:38:45 -0800
Message-ID: <1259181525.29779.69.camel@Joe-Laptop.home>
References: <19211.4244.135603.458550@gargle.gargle.HOWL>
	 <9929d2390911250018o777405ddk257605e7d0b16d17@mail.gmail.com>
	 <9929d2390911250119h3e67fb50u2e9d8d3825b0496d@mail.gmail.com>
	 <19213.23008.292298.804077@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: robert@herjulf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1178 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759764AbZKYUik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2009 15:38:40 -0500
In-Reply-To: <19213.23008.292298.804077@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-25 at 17:22 +0100, robert@herjulf.net wrote:
> Jeff Kirsher writes:
>  > FYI- This patch series is riddled with trailing whitespace, when I
>  > imported that patches into my tree, I cleaned up all the whitespace
>  > errors.  After some internal testing and review, 
>  > I can re-post the entire series which has been cleaned up.
>  Please do.

Here's another attempt as a complete patch.

Differences from Robert's original:

Whitespace cleanups
Changed presumed coding error from:
	if (type & DOM_TYPE_DOM & DOM_TYPE_ADDR_CHNGE) {
to:
	if (type & DOM_TYPE_ADDR_CHNGE)  {
Added read_phy_diag_u32 function
Refactored multiple sequential register reads to
for loop over struct array with register read

Functional difference from my original patch:
Fixed ARRAY_SIZE(basic) misuse

Reduces code size:

was:
$ size drivers/net/igb/igb_ethtool.o drivers/net/ixgbe/ixgbe_ethtool.o
   text    data     bss     dec     hex filename
  26466    1544    8584   36594    8ef2 drivers/net/igb/igb_ethtool.o
  31726    2980    9128   43834    ab3a drivers/net/ixgbe/ixgbe_ethtool.o

is:
$ size drivers/net/igb/igb_ethtool.o drivers/net/ixgbe/ixgbe_ethtool.o
   text	   data	    bss	    dec	    hex	filename
  24642	   1544	   8008	  34194	   8592	drivers/net/igb/igb_ethtool.o
  29922	   2980	   8560	  41462	   a1f6	drivers/net/ixgbe/ixgbe_ethtool.o

Signed-off-by: Joe Perches <joe@perches.com>

 Documentation/networking/dom.txt  |   41 ++++++++
 drivers/net/igb/igb_ethtool.c     |  191 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_ethtool.c |  171 +++++++++++++++++++++++++++++++++-
 include/linux/ethtool.h           |   49 ++++++++++
 include/net/dom.h                 |  109 +++++++++++++++++++++
 net/core/ethtool.c                |   18 ++++
 6 files changed, 578 insertions(+), 1 deletions(-)

diff --git a/Documentation/networking/dom.txt b/Documentation/networking/dom.txt
new file mode 100644
index 0000000..4bf24de
--- /dev/null
+++ b/Documentation/networking/dom.txt
@@ -0,0 +1,41 @@
+Diagnostic Monitoring Interface Monitoring also called DOM is a specification
+for optical transceivers to allow link and other diagnostics related to the
+transceiver's to standardized and communicated. For communication the I2C
+bus is used. The SFF specifications is available at ftp://ftp.seagate.com/
+Specification is generic and should work for many types of optical modules
+as GBIC, SFP, SFp+, XFP etc
+
+In short DOM spec adds a memory page where the diagnostics's is kept (address
+0xA2 bytes 66 to 105) but there are lot's of option's and variants. For example
+alarm and warnings are optional. See example below.
+
+Not all SFP's (SFP is for GIGE) have DOM support normally long range supports
+DOM. And of course your board and driver needs this support too.
+For SFP+ (10G) DOM is mandatory.
+
+Linux kernel support is via ethertool.
+
+include/net/dom.h        # Basic definitions
+net/core/ethtool.c       # adds ethtool_phy_diag()
+include/linux/ethtool.h  # adds ETHTOOL_GPHYDIAG
+
+And drivers hooks exists currently in igb and ixgbe driver
+
+Usage example: ethtool -D eth5
+
+Ext-Calbr: Avr RX-Power: Alarm & Warn: RX_LOS: 	Wavelength: 1310 nm
+Alarms, warnings in beginning of line, Ie. AH = Alarm High, WL == Warn Low etc
+	Temp:  35.9 C			Thresh: Lo: -12.0/-8.0   Hi: 103.0/110.0 C
+	Vcc:  3.33 V			Thresh: Lo:   3.0/3.0    Hi:   3.7/4.0   V
+	Tx-Bias:  13.4 mA		Thresh: Lo:   2.0/4.0    Hi:  70.0/84.0  mA
+ALWL	TX-pwr:  -5.9 dBm ( 0.26 mW)	Thresh: Lo:  -4.0/-2.0   Hi:   7.0/8.2   dBm
+AHWH	RX-pwr:  -5.0 dBm ( 0.31 mW) 	Thresh: Lo: -35.2/-28.0  Hi:  -8.2/-6.0  dBm
+
+
+First line shows the options supported by the module. As we see this module
+supports Alarms and warnings as a consequence thresholds are printed. As example
+RX-pwr: -35.2 < no_alarm < -6.0 dBm and -28.0 < no_warning < -8.2 dBm. (dBm yields
+1 mW == 0 dBm)
+
+In the example above we see both warnings for both TX-pwr (low) and RX-Pwr high.
+The Rx side would need some attenuation.
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ac9d527..63a297d 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -34,6 +34,7 @@
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/ethtool.h>
+#include <net/dom.h>
 #include <linux/sched.h>
 
 #include "igb.h"
@@ -2063,6 +2064,195 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	}
 }
 
+static s32 read_phy_diag(struct e1000_hw *hw, u8 page, u8 offset, u16 *data)
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
+	i2ccmd = (E1000_I2CCMD_OPCODE_READ) |
+		 (page << E1000_I2CCMD_PHY_ADDR_SHIFT) |
+		 (offset << E1000_I2CCMD_REG_ADDR_SHIFT);
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
+static s32 read_phy_diag_u32(struct e1000_hw *hw, u8 page, u8 offset, u32 *data)
+{
+	u16 p1;
+	u16 p2;
+	s32 res;
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
+int igb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	int res;
+	u8 type, eo;
+	int i;
+
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
+		goto out;
+
+	type = pd->type >> 8;
+
+	if ((~type & DOM_TYPE_DOM) || (type & DOM_TYPE_LEGAGY_DOM))
+		goto out;
+
+	if (type & DOM_TYPE_ADDR_CHNGE) {
+		hw_dbg("DOM module not supported (Address change)\n");
+		goto out;
+	}
+
+	eo = pd->type & 0xFF;
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength);
+	if (res)
+		goto out;
+
+	/* If supported. Read alarms and Warnings first*/
+	if (eo & DOM_EO_AW) {
+		res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm);
+		if (res)
+			goto out;
+		res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning);
+		if (res)
+			goto out;
+	}
+
+	/* Basic diag */
+
+	for (i = 0; i < ARRAY_SIZE(basic); i++) {
+		res = read_phy_diag(hw, 0x1, basic[i].reg,
+				    (u16 *)((char *)pd + basic[i].offset));
+		if (res)
+			goto out;
+	}
+
+	/* Power */
+
+	for (i = 0; i < ARRAY_SIZE(power); i++) {
+		res = read_phy_diag_u32(hw, 0x1, power[i].reg,
+					(u32 *)((char *)pd + power[i].offset));
+		if (res)
+			goto out;
+	}
+
+	/* Thresholds for Alarms and Warnings */
+
+	if (eo & DOM_EO_AW) {
+		for (i = 0; i < ARRAY_SIZE(aw); i++) {
+			res = read_phy_diag(hw, 0x1, aw[i].reg,
+					    (u16 *)((char *)pd + aw[i].offset));
+			if (res)
+				goto out;
+		}
+	}
+
+out:
+	return res;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings           = igb_get_settings,
 	.set_settings           = igb_set_settings,
@@ -2097,6 +2287,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ethtool_stats      = igb_get_ethtool_stats,
 	.get_coalesce           = igb_get_coalesce,
 	.set_coalesce           = igb_set_coalesce,
+	.get_phy_diag           = igb_get_phy_diag,
 };
 
 void igb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 84ab4db..8435cd7 100644
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
 
@@ -2106,6 +2108,172 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 }
 
+static s32 read_phy_diag(struct ixgbe_hw *hw, u8 page, u8 offset, u16 *data)
+{
+	s32 status;
+	u8 hi, lo;
+
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &hi);
+	if (status)
+		goto out;
+
+	status = ixgbe_read_i2c_byte_generic(hw, page, offset, &lo);
+	if (status)
+		goto out;
+
+	*data = (((u16)hi) << 8) | lo;
+
+out:
+	return status;
+}
+
+static s32 read_phy_diag_u32(struct ixgbe_hw *hw, u8 page, u8 offset, u32 *data)
+{
+	u16 p1;
+	u16 p2;
+	s32 res;
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
+int ixgb_get_phy_diag(struct net_device *netdev, struct ethtool_phy_diag *pd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int res;
+	u8 type, eo;
+	int i;
+
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
+		goto out;
+
+	type = pd->type >> 8;
+
+	if ((~type & DOM_TYPE_DOM) || (type & DOM_TYPE_LEGAGY_DOM))
+		goto out;
+
+	if (type & DOM_TYPE_ADDR_CHNGE)  {
+		hw_dbg(hw, "DOM module not supported (Address change)\n");
+		goto out;
+	}
+
+	eo = pd->type & 0xFF;
+
+	res = read_phy_diag(hw, 0x0, DOM_A0_WAVELENGTH, &pd->wavelength);
+	if (res)
+		goto out;
+
+	/* If supported. Read alarms and Warnings first*/
+	if (eo & DOM_EO_AW) {
+		res = read_phy_diag(hw, 0x1, DOM_A2_ALARM, &pd->alarm);
+		if (res)
+			goto out;
+
+		res = read_phy_diag(hw, 0x1, DOM_A2_WARNING, &pd->warning);
+		if (res)
+			goto out;
+	}
+
+	/* Basic diag */
+
+	for (i = 0; i < ARRAY_SIZE(basic); i++) {
+		res = read_phy_diag(hw, 0x1, basic[i].reg,
+				    (u16 *)((char *)pd + basic[i].offset));
+		if (res)
+			goto out;
+	}
+
+	/* Power */
+
+	for (i = 0; i < ARRAY_SIZE(power); i++) {
+		res = read_phy_diag_u32(hw, 0x1, power[i].reg,
+					(u32 *)((char *)pd + power[i].offset));
+		if (res)
+			goto out;
+	}
+
+	/* Thresholds for Alarms and Warnings */
+
+	if (eo & DOM_EO_AW) {
+		for (i = 0; i < ARRAY_SIZE(aw); i++) {
+			res = read_phy_diag(hw, 0x1, aw[i].reg,
+					    (u16 *)((char *)pd + aw[i].offset));
+			if (res)
+				goto out;
+		}
+	}
+
+out:
+	return res;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2141,6 +2309,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
 	.set_flags              = ixgbe_set_flags,
+	.get_phy_diag           = ixgb_get_phy_diag,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index edd03b7..4e45a94 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -272,6 +272,53 @@ struct ethtool_stats {
 	__u64	data[0];
 };
 
+/* Diagmostic Monitoring Interface Data -- DOM */
+struct ethtool_phy_diag {
+	__u32 cmd;
+	/* A0 page */
+	__u16 type;
+	__u16 wavelength;
+	/* A2 page */
+	__u16 alarm;
+	__u16 warning;
+	__s16 temp;
+	__u16 temp_slope;
+	__s16 temp_offset;
+	__u16 vcc;
+	__u16 vcc_slope;
+	__s16 vcc_offset;
+	__u16 tx_bias;
+	__u16 tx_bias_slope;
+	__s16 tx_bias_offset;
+	__u16 tx_pwr;
+	__u16 tx_pwr_slope;
+	__s16 tx_pwr_offset;
+	__u16 rx_pwr;
+	__u32 rx_pwr_cal[5];
+
+	/* Thresholds */
+	__s16 temp_alt;
+	__s16 temp_aht;
+	__s16 temp_wlt;
+	__s16 temp_wht;
+	__u16 vcc_alt;
+	__u16 vcc_aht;
+	__u16 vcc_wlt;
+	__u16 vcc_wht;
+	__u16 tx_bias_alt;
+	__u16 tx_bias_aht;
+	__u16 tx_bias_wlt;
+	__u16 tx_bias_wht;
+	__u16 tx_pwr_alt;
+	__u16 tx_pwr_aht;
+	__u16 tx_pwr_wlt;
+	__u16 tx_pwr_wht;
+	__u16 rx_pwr_alt;
+	__u16 rx_pwr_aht;
+	__u16 rx_pwr_wlt;
+	__u16 rx_pwr_wht;
+};
+
 struct ethtool_perm_addr {
 	__u32	cmd;		/* ETHTOOL_GPERMADDR */
 	__u32	size;
@@ -499,6 +546,7 @@ struct ethtool_ops {
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
 	int	(*reset)(struct net_device *, u32 *);
+	int     (*get_phy_diag)(struct net_device *, struct ethtool_phy_diag *);
 };
 #endif /* __KERNEL__ */
 
@@ -557,6 +605,7 @@ struct ethtool_ops {
 #define	ETHTOOL_SRXCLSRLINS	0x00000032 /* Insert RX classification rule */
 #define	ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define	ETHTOOL_RESET		0x00000034 /* Reset hardware */
+#define	ETHTOOL_GPHYDIAG	0x00000035 /* Get PHY diagnostics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
diff --git a/include/net/dom.h b/include/net/dom.h
new file mode 100644
index 0000000..61540c3
--- /dev/null
+++ b/include/net/dom.h
@@ -0,0 +1,109 @@
+#ifndef _LINUX_DOM_H
+#define _LINUX_DOM_H
+
+/*
+   Diagnostic Monitoring Interface for Optical Tranceivers
+   SFF-8472 v. 10.4 (Jan 2009)
+   ftp://ftp.seagate.com/sff/SFF-8472.PDF
+
+   Licensce GPL. Copyright Robert Olsson robert@herjulf.net
+*/
+
+#define  DOM_A0_IDENTIFIER  0
+#define  DOM_A0_WAVELENGTH 60
+#define  DOM_A0_CC_BASE    63
+#define  DOM_A0_DOM_TYPE   92
+
+/* DOM_TYPE codings in DOM_A0_DOM_TYPE */
+#define     DOM_TYPE_LEGAGY_DOM     (1<<7)
+#define     DOM_TYPE_DOM            (1<<6)  /* Has DOM support */
+#define     DOM_TYPE_INT_CAL        (1<<5)  /* Internally calibrated */
+#define     DOM_TYPE_EXT_CAL        (1<<4)  /* Externally calibrated */
+#define     DOM_TYPE_RX_PWR         (1<<3)  /* Received Power OMA=0,  1=average */
+#define     DOM_TYPE_ADDR_CHNGE     (1<<2)  /* Address change required */
+
+#define  DOM_A0_EO   93                     /* Enhanced options */
+#define     DOM_EO_AW               (1<<7)  /* Alarm & Warnings */
+#define     DOM_EO_TX_DISABLE       (1<<6)
+#define     DOM_EO_TX_FAULT         (1<<5)
+#define     DOM_EO_RX_LOS           (1<<4)
+#define     DOM_EO_RATE_SELECT_MON  (1<<3)
+#define     DOM_EO_APP_SELECT       (1<<2)
+#define     DOM_EO_RATE_SELECT      (1<<1)
+
+#define  DOM_A0_CC_EXT     95
+
+#define  DOM_A2_TEMP_AHT    0  /* Temp alarm high threshold */
+#define  DOM_A2_TEMP_ALT    2
+#define  DOM_A2_TEMP_WHT    4  /* Temp warning high threshold */
+#define  DOM_A2_TEMP_WLT    6
+
+#define  DOM_A2_VCC_AHT    8  /* VCC alarm high threshold */
+#define  DOM_A2_VCC_ALT   10
+#define  DOM_A2_VCC_WHT   12  /* VCC warning high threshold */
+#define  DOM_A2_VCC_WLT   14
+
+#define  DOM_A2_TX_BIAS_AHT   16  /* TX_BIAS alarm high threshold */
+#define  DOM_A2_TX_BIAS_ALT   18
+#define  DOM_A2_TX_BIAS_WHT   20  /* TX_BIAS warning high threshold */
+#define  DOM_A2_TX_BIAS_WLT   22
+
+#define  DOM_A2_TX_PWR_AHT   24  /* TX_PWR alarm high threshold */
+#define  DOM_A2_TX_PWR_ALT   26
+#define  DOM_A2_TX_PWR_WHT   28  /* TX_PWR warning high threshold */
+#define  DOM_A2_TX_PWR_WLT   30
+
+#define  DOM_A2_RX_PWR_AHT   32  /* RX_PWR alarm high threshold */
+#define  DOM_A2_RX_PWR_ALT   34
+#define  DOM_A2_RX_PWR_WHT   36  /* RX_PWR warning high threshold */
+#define  DOM_A2_RX_PWR_WLT   38
+
+#define  DOM_A2_RX_PWR_4   56  /* 4 bytes  Calibration constants*/
+#define  DOM_A2_RX_PWR_3   60  /* 4 bytes */
+#define  DOM_A2_RX_PWR_2   64  /* 4 bytes */
+#define  DOM_A2_RX_PWR_1   68  /* 4 bytes */
+#define  DOM_A2_RX_PWR_0   72  /* 4 bytes */
+
+#define  DOM_A2_TX_I_SLOPE   76  /* 2 bytes */
+#define  DOM_A2_TX_I_OFFSET  78  /* 2 bytes */
+#define  DOM_A2_TX_PWR_SLOPE   80  /* 2 bytes */
+#define  DOM_A2_TX_PWR_OFFSET  82  /* 2 bytes */
+#define  DOM_A2_TEMP_SLOPE   84  /* 2 bytes */
+#define  DOM_A2_TEMP_OFFSET  86  /* 2 bytes */
+#define  DOM_A2_VCC_SLOPE   88  /* 2 bytes */
+#define  DOM_A2_VCC_OFFSET  90  /* 2 bytes */
+
+#define  DOM_A2_CC_DMI    95
+#define  DOM_A2_TEMP      96   /* 2 bytes */
+#define  DOM_A2_VCC       98   /* 2 bytes */
+#define  DOM_A2_TX_BIAS  100   /* 2 bytes */
+#define  DOM_A2_TX_PWR   102   /* 2 bytes */
+#define  DOM_A2_RX_PWR   104   /* 2 bytes */
+
+#define  DOM_A2_ALARM    112   /* 2 bytes */
+#define     DOM_TYPE_TEMP_AH       (1<<7)  /* Temp alarm high */
+#define     DOM_TYPE_TEMP_AL       (1<<6)  /* low */
+#define     DOM_TYPE_VCC_AH        (1<<5)
+#define     DOM_TYPE_VCC_AL        (1<<4)
+#define     DOM_TYPE_TX_BIAS_AH    (1<<3)
+#define     DOM_TYPE_TX_BIAS_AL    (1<<2)
+#define     DOM_TYPE_TX_PWR_AH     (1<<1)
+#define     DOM_TYPE_TX_PWR_AL     (1<<0)
+/* Next byte 113 */
+#define     DOM_TYPE_RX_PWR_AH     (1<<7)
+#define     DOM_TYPE_RX_PWR_AL     (1<<6)
+
+#define  DOM_A2_WARNING  116   /* 2 bytes */
+#define     DOM_TYPE_TEMP_WH       (1<<7)  /* Temp warning high */
+#define     DOM_TYPE_TEMP_WL       (1<<6)  /* low */
+#define     DOM_TYPE_VCC_WH        (1<<5)
+#define     DOM_TYPE_VCC_WL        (1<<4)
+#define     DOM_TYPE_TX_BIAS_WH    (1<<3)
+#define     DOM_TYPE_TX_BIAS_WL    (1<<2)
+#define     DOM_TYPE_TX_PWR_WH     (1<<1)
+#define     DOM_TYPE_TX_PWR_WL     (1<<0)
+/* Next byte 117 */
+#define     DOM_TYPE_RX_PWR_WH     (1<<7)
+#define     DOM_TYPE_RX_PWR_WL     (1<<6)
+
+#endif /* _LINUX_DOM_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8aee58..756434a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -893,6 +893,21 @@ static int ethtool_flash_device(struct net_device *dev, char __user *useraddr)
 	return dev->ethtool_ops->flash_device(dev, &efl);
 }
 
+static int ethtool_phy_diag(struct net_device *dev, void __user *useraddr)
+{
+	struct ethtool_phy_diag pd;
+
+	if (!dev->ethtool_ops->get_phy_diag)
+		return -EOPNOTSUPP;
+
+	dev->ethtool_ops->get_phy_diag(dev, &pd); /* FIXME */
+
+	if (copy_to_user(useraddr, &pd, sizeof(pd)))
+		 return -EFAULT;
+
+	return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1112,6 +1127,9 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_RESET:
 		rc = ethtool_reset(dev, useraddr);
 		break;
+	case ETHTOOL_GPHYDIAG:
+		rc = ethtool_phy_diag(dev, useraddr);
+		break;
 	default:
 		rc = -EOPNOTSUPP;
 	}


