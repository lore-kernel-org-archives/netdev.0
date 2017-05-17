From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 06/10] rt2x00: convert rt2800_register_read return type
Date: Wed, 17 May 2017 16:46:58 +0200
Message-ID: <20170517144702.1381136-7-arnd@arndb.de>
References: <20170517144702.1381136-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        David Miller <davem@davemloft.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jes Sorensen <jes.sorensen@gmail.com>,
        Tom Psyborg <pozega.tomislav@gmail.com>
To: linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:59055 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754697AbdEQOr6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 10:47:58 -0400
In-Reply-To: <20170517144702.1381136-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a semi-automated conversion to change rt2800_register_read
to return the register contents instead of passing them by value,
resulting in much better object code. The majority of the patch
was done using:

sed -i 's:\(rt2800_register_read(.*, .*\), &\(.*\));:\2 = \1);:' \
       's:\(rt2800_register_read_lock(.*, .*\), &\(.*\));:\2 = \1);:' \
	drivers/net/wireless/ralink/rt2x00/rt2800lib.c

The function itself was modified manually along with the one remaining
multi-line caller that was not covered automatically and the indirect
reference.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 291 ++++++++++++-------------
 drivers/net/wireless/ralink/rt2x00/rt2800lib.h |  22 +-
 2 files changed, 151 insertions(+), 162 deletions(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
index fef53d6a888a..541e2692766a 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
@@ -442,7 +442,7 @@ static int rt2800_enable_wlan_rt3290(struct rt2x00_dev *rt2x00dev)
 	u32 reg;
 	int i, count;
 
-	rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL);
 	rt2x00_set_field32(&reg, WLAN_GPIO_OUT_OE_BIT_ALL, 0xff);
 	rt2x00_set_field32(&reg, FRC_WL_ANT_SET, 1);
 	rt2x00_set_field32(&reg, WLAN_CLK_EN, 0);
@@ -457,7 +457,7 @@ static int rt2800_enable_wlan_rt3290(struct rt2x00_dev *rt2x00dev)
 		 * Check PLL_LD & XTAL_RDY.
 		 */
 		for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-			rt2800_register_read(rt2x00dev, CMB_CTRL, &reg);
+			reg = rt2800_register_read(rt2x00dev, CMB_CTRL);
 			if (rt2x00_get_field32(reg, PLL_LD) &&
 			    rt2x00_get_field32(reg, XTAL_RDY))
 				break;
@@ -480,7 +480,7 @@ static int rt2800_enable_wlan_rt3290(struct rt2x00_dev *rt2x00dev)
 			count = 0;
 		}
 
-		rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL);
 		rt2x00_set_field32(&reg, PCIE_APP0_CLK_REQ, 0);
 		rt2x00_set_field32(&reg, WLAN_CLK_EN, 1);
 		rt2x00_set_field32(&reg, WLAN_RESET, 1);
@@ -535,7 +535,7 @@ int rt2800_wait_csr_ready(struct rt2x00_dev *rt2x00dev)
 	u32 reg;
 
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2800_register_read(rt2x00dev, MAC_CSR0, &reg);
+		reg = rt2800_register_read(rt2x00dev, MAC_CSR0);
 		if (reg && reg != ~0)
 			return 0;
 		msleep(1);
@@ -556,7 +556,7 @@ int rt2800_wait_wpdma_ready(struct rt2x00_dev *rt2x00dev)
 	 * before timing out.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG);
 		if (!rt2x00_get_field32(reg, WPDMA_GLO_CFG_TX_DMA_BUSY) &&
 		    !rt2x00_get_field32(reg, WPDMA_GLO_CFG_RX_DMA_BUSY))
 			return 0;
@@ -573,7 +573,7 @@ void rt2800_disable_wpdma(struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 
-	rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_TX_DMA, 0);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_TX_DMA_BUSY, 0);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_RX_DMA, 0);
@@ -723,7 +723,7 @@ int rt2800_load_firmware(struct rt2x00_dev *rt2x00dev,
 		    rt2x00_rt(rt2x00dev, RT3572) ||
 		    rt2x00_rt(rt2x00dev, RT5390) ||
 		    rt2x00_rt(rt2x00dev, RT5392)) {
-			rt2800_register_read(rt2x00dev, AUX_CTRL, &reg);
+			reg = rt2800_register_read(rt2x00dev, AUX_CTRL);
 			rt2x00_set_field32(&reg, AUX_CTRL_FORCE_PCIE_CLK, 1);
 			rt2x00_set_field32(&reg, AUX_CTRL_WAKE_PCIE_EN, 1);
 			rt2800_register_write(rt2x00dev, AUX_CTRL, reg);
@@ -742,7 +742,7 @@ int rt2800_load_firmware(struct rt2x00_dev *rt2x00dev,
 	 * Wait for device to stabilize.
 	 */
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2800_register_read(rt2x00dev, PBF_SYS_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, PBF_SYS_CTRL);
 		if (rt2x00_get_field32(reg, PBF_SYS_CTRL_READY))
 			break;
 		msleep(1);
@@ -1096,7 +1096,7 @@ static void rt2800_update_beacons_setup(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * H/W sends up to MAC_BSSID_DW1_BSS_BCN_NUM + 1 consecutive beacons.
 	 */
-	rt2800_register_read(rt2x00dev, MAC_BSSID_DW1, &bssid_dw1);
+	bssid_dw1 = rt2800_register_read(rt2x00dev, MAC_BSSID_DW1);
 	rt2x00_set_field32(&bssid_dw1, MAC_BSSID_DW1_BSS_BCN_NUM,
 			   bcn_num > 0 ? bcn_num - 1 : 0);
 	rt2800_register_write(rt2x00dev, MAC_BSSID_DW1, bssid_dw1);
@@ -1115,7 +1115,7 @@ void rt2800_write_beacon(struct queue_entry *entry, struct txentry_desc *txdesc)
 	 * Disable beaconing while we are reloading the beacon data,
 	 * otherwise we might be sending out invalid data.
 	 */
-	rt2800_register_read(rt2x00dev, BCN_TIME_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, BCN_TIME_CFG);
 	orig_reg = reg;
 	rt2x00_set_field32(&reg, BCN_TIME_CFG_BEACON_GEN, 0);
 	rt2800_register_write(rt2x00dev, BCN_TIME_CFG, reg);
@@ -1205,7 +1205,7 @@ void rt2800_clear_beacon(struct queue_entry *entry)
 	 * Disable beaconing while we are reloading the beacon data,
 	 * otherwise we might be sending out invalid data.
 	 */
-	rt2800_register_read(rt2x00dev, BCN_TIME_CFG, &orig_reg);
+	orig_reg = rt2800_register_read(rt2x00dev, BCN_TIME_CFG);
 	reg = orig_reg;
 	rt2x00_set_field32(&reg, BCN_TIME_CFG_BEACON_GEN, 0);
 	rt2800_register_write(rt2x00dev, BCN_TIME_CFG, reg);
@@ -1240,7 +1240,7 @@ static u8 _rt2800_bbp_read(struct rt2x00_dev *rt2x00dev, const unsigned int word
 const struct rt2x00debug rt2800_rt2x00debug = {
 	.owner	= THIS_MODULE,
 	.csr	= {
-		.read		= _rt2800_register_read,
+		.read		= rt2800_register_read,
 		.write		= rt2800_register_write,
 		.flags		= RT2X00DEBUGFS_OFFSET,
 		.word_base	= CSR_REG_BASE,
@@ -1287,10 +1287,10 @@ int rt2800_rfkill_poll(struct rt2x00_dev *rt2x00dev)
 	u32 reg;
 
 	if (rt2x00_rt(rt2x00dev, RT3290)) {
-		rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL);
 		return rt2x00_get_field32(reg, WLAN_GPIO_IN_BIT0);
 	} else {
-		rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 		return rt2x00_get_field32(reg, GPIO_CTRL_VAL2);
 	}
 }
@@ -1315,7 +1315,7 @@ static void rt2800_brightness_set(struct led_classdev *led_cdev,
 
 	/* Check for SoC (SOC devices don't support MCU requests) */
 	if (rt2x00_is_soc(led->rt2x00dev)) {
-		rt2800_register_read(led->rt2x00dev, LED_CFG, &reg);
+		reg = rt2800_register_read(led->rt2x00dev, LED_CFG);
 
 		/* Set LED Polarity */
 		rt2x00_set_field32(&reg, LED_CFG_LED_POLAR, polarity);
@@ -1404,7 +1404,7 @@ static void rt2800_config_wcid_attr_bssidx(struct rt2x00_dev *rt2x00dev,
 	 * The BSS Idx numbers is split in a main value of 3 bits,
 	 * and a extended field for adding one additional bit to the value.
 	 */
-	rt2800_register_read(rt2x00dev, offset, &reg);
+	reg = rt2800_register_read(rt2x00dev, offset);
 	rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_BSS_IDX, (bssidx & 0x7));
 	rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_BSS_IDX_EXT,
 			   (bssidx & 0x8) >> 3);
@@ -1422,7 +1422,7 @@ static void rt2800_config_wcid_attr_cipher(struct rt2x00_dev *rt2x00dev,
 	offset = MAC_WCID_ATTR_ENTRY(key->hw_key_idx);
 
 	if (crypto->cmd == SET_KEY) {
-		rt2800_register_read(rt2x00dev, offset, &reg);
+		reg = rt2800_register_read(rt2x00dev, offset);
 		rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_KEYTAB,
 				   !!(key->flags & IEEE80211_KEY_FLAG_PAIRWISE));
 		/*
@@ -1438,7 +1438,7 @@ static void rt2800_config_wcid_attr_cipher(struct rt2x00_dev *rt2x00dev,
 		rt2800_register_write(rt2x00dev, offset, reg);
 	} else {
 		/* Delete the cipher without touching the bssidx */
-		rt2800_register_read(rt2x00dev, offset, &reg);
+		reg = rt2800_register_read(rt2x00dev, offset);
 		rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_KEYTAB, 0);
 		rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_CIPHER, 0);
 		rt2x00_set_field32(&reg, MAC_WCID_ATTRIBUTE_CIPHER_EXT, 0);
@@ -1494,7 +1494,7 @@ int rt2800_config_shared_key(struct rt2x00_dev *rt2x00dev,
 
 	offset = SHARED_KEY_MODE_ENTRY(key->hw_key_idx / 8);
 
-	rt2800_register_read(rt2x00dev, offset, &reg);
+	reg = rt2800_register_read(rt2x00dev, offset);
 	rt2x00_set_field32(&reg, field,
 			   (crypto->cmd == SET_KEY) * crypto->cipher);
 	rt2800_register_write(rt2x00dev, offset, reg);
@@ -1560,7 +1560,7 @@ static void rt2800_set_max_psdu_len(struct rt2x00_dev *rt2x00dev)
 
 	max_psdu = min(drv_data->max_psdu, i);
 
-	rt2800_register_read(rt2x00dev, MAX_LEN_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MAX_LEN_CFG);
 	rt2x00_set_field32(&reg, MAX_LEN_CFG_MAX_PSDU, max_psdu);
 	rt2800_register_write(rt2x00dev, MAX_LEN_CFG, reg);
 }
@@ -1652,7 +1652,7 @@ void rt2800_config_filter(struct rt2x00_dev *rt2x00dev,
 	 * and broadcast frames will always be accepted since
 	 * there is no filter for it at this time.
 	 */
-	rt2800_register_read(rt2x00dev, RX_FILTER_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, RX_FILTER_CFG);
 	rt2x00_set_field32(&reg, RX_FILTER_CFG_DROP_CRC_ERROR,
 			   !(filter_flags & FIF_FCSFAIL));
 	rt2x00_set_field32(&reg, RX_FILTER_CFG_DROP_PHY_ERROR,
@@ -1696,7 +1696,7 @@ void rt2800_config_intf(struct rt2x00_dev *rt2x00dev, struct rt2x00_intf *intf,
 		/*
 		 * Enable synchronisation.
 		 */
-		rt2800_register_read(rt2x00dev, BCN_TIME_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, BCN_TIME_CFG);
 		rt2x00_set_field32(&reg, BCN_TIME_CFG_TSF_SYNC, conf->sync);
 		rt2800_register_write(rt2x00dev, BCN_TIME_CFG, reg);
 
@@ -1704,14 +1704,14 @@ void rt2800_config_intf(struct rt2x00_dev *rt2x00dev, struct rt2x00_intf *intf,
 			/*
 			 * Tune beacon queue transmit parameters for AP mode
 			 */
-			rt2800_register_read(rt2x00dev, TBTT_SYNC_CFG, &reg);
+			reg = rt2800_register_read(rt2x00dev, TBTT_SYNC_CFG);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_CWMIN, 0);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_AIFSN, 1);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_EXP_WIN, 32);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_TBTT_ADJUST, 0);
 			rt2800_register_write(rt2x00dev, TBTT_SYNC_CFG, reg);
 		} else {
-			rt2800_register_read(rt2x00dev, TBTT_SYNC_CFG, &reg);
+			reg = rt2800_register_read(rt2x00dev, TBTT_SYNC_CFG);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_CWMIN, 4);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_AIFSN, 2);
 			rt2x00_set_field32(&reg, TBTT_SYNC_CFG_BCN_EXP_WIN, 32);
@@ -1830,22 +1830,22 @@ static void rt2800_config_ht_opmode(struct rt2x00_dev *rt2x00dev,
 		gf20_mode = gf40_mode = 1;
 
 	/* Update HT protection config */
-	rt2800_register_read(rt2x00dev, MM20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM20_PROT_CFG);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_PROTECT_RATE, mm20_rate);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_PROTECT_CTRL, mm20_mode);
 	rt2800_register_write(rt2x00dev, MM20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MM40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM40_PROT_CFG);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_PROTECT_RATE, mm40_rate);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_PROTECT_CTRL, mm40_mode);
 	rt2800_register_write(rt2x00dev, MM40_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF20_PROT_CFG);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_PROTECT_RATE, gf20_rate);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_PROTECT_CTRL, gf20_mode);
 	rt2800_register_write(rt2x00dev, GF20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF40_PROT_CFG);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_PROTECT_RATE, gf40_rate);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_PROTECT_CTRL, gf40_mode);
 	rt2800_register_write(rt2x00dev, GF40_PROT_CFG, reg);
@@ -1857,14 +1857,14 @@ void rt2800_config_erp(struct rt2x00_dev *rt2x00dev, struct rt2x00lib_erp *erp,
 	u32 reg;
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
-		rt2800_register_read(rt2x00dev, AUTO_RSP_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, AUTO_RSP_CFG);
 		rt2x00_set_field32(&reg, AUTO_RSP_CFG_AR_PREAMBLE,
 				   !!erp->short_preamble);
 		rt2800_register_write(rt2x00dev, AUTO_RSP_CFG, reg);
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
-		rt2800_register_read(rt2x00dev, OFDM_PROT_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, OFDM_PROT_CFG);
 		rt2x00_set_field32(&reg, OFDM_PROT_CFG_PROTECT_CTRL,
 				   erp->cts_protection ? 2 : 0);
 		rt2800_register_write(rt2x00dev, OFDM_PROT_CFG, reg);
@@ -1877,18 +1877,18 @@ void rt2800_config_erp(struct rt2x00_dev *rt2x00dev, struct rt2x00lib_erp *erp,
 	}
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
-		rt2800_register_read(rt2x00dev, BKOFF_SLOT_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, BKOFF_SLOT_CFG);
 		rt2x00_set_field32(&reg, BKOFF_SLOT_CFG_SLOT_TIME,
 				   erp->slot_time);
 		rt2800_register_write(rt2x00dev, BKOFF_SLOT_CFG, reg);
 
-		rt2800_register_read(rt2x00dev, XIFS_TIME_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, XIFS_TIME_CFG);
 		rt2x00_set_field32(&reg, XIFS_TIME_CFG_EIFS, erp->eifs);
 		rt2800_register_write(rt2x00dev, XIFS_TIME_CFG, reg);
 	}
 
 	if (changed & BSS_CHANGED_BEACON_INT) {
-		rt2800_register_read(rt2x00dev, BCN_TIME_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, BCN_TIME_CFG);
 		rt2x00_set_field32(&reg, BCN_TIME_CFG_BEACON_INTERVAL,
 				   erp->beacon_int * 16);
 		rt2800_register_write(rt2x00dev, BCN_TIME_CFG, reg);
@@ -1905,7 +1905,7 @@ static void rt2800_config_3572bt_ant(struct rt2x00_dev *rt2x00dev)
 	u16 eeprom;
 	u8 led_ctrl, led_g_mode, led_r_mode;
 
-	rt2800_register_read(rt2x00dev, GPIO_SWITCH, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_SWITCH);
 	if (rt2x00dev->curr_band == NL80211_BAND_5GHZ) {
 		rt2x00_set_field32(&reg, GPIO_SWITCH_0, 1);
 		rt2x00_set_field32(&reg, GPIO_SWITCH_1, 1);
@@ -1915,7 +1915,7 @@ static void rt2800_config_3572bt_ant(struct rt2x00_dev *rt2x00dev)
 	}
 	rt2800_register_write(rt2x00dev, GPIO_SWITCH, reg);
 
-	rt2800_register_read(rt2x00dev, LED_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, LED_CFG);
 	led_g_mode = rt2x00_get_field32(reg, LED_CFG_LED_POLAR) ? 3 : 0;
 	led_r_mode = rt2x00_get_field32(reg, LED_CFG_LED_POLAR) ? 0 : 3;
 	if (led_g_mode != rt2x00_get_field32(reg, LED_CFG_G_LED_MODE) ||
@@ -1941,14 +1941,14 @@ static void rt2800_set_ant_diversity(struct rt2x00_dev *rt2x00dev,
 	u8 gpio_bit3 = (ant == ANTENNA_A) ? 0 : 1;
 
 	if (rt2x00_is_pci(rt2x00dev)) {
-		rt2800_register_read(rt2x00dev, E2PROM_CSR, &reg);
+		reg = rt2800_register_read(rt2x00dev, E2PROM_CSR);
 		rt2x00_set_field32(&reg, E2PROM_CSR_DATA_CLOCK, eesk_pin);
 		rt2800_register_write(rt2x00dev, E2PROM_CSR, reg);
 	} else if (rt2x00_is_usb(rt2x00dev))
 		rt2800_mcu_request(rt2x00dev, MCU_ANT_SELECT, 0xff,
 				   eesk_pin, 0);
 
-	rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 	rt2x00_set_field32(&reg, GPIO_CTRL_DIR3, 0);
 	rt2x00_set_field32(&reg, GPIO_CTRL_VAL3, gpio_bit3);
 	rt2800_register_write(rt2x00dev, GPIO_CTRL, reg);
@@ -2411,7 +2411,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 		rt2800_rfcsr_write(rt2x00dev, 29, 0x9f);
 	}
 
-	rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 	rt2x00_set_field32(&reg, GPIO_CTRL_DIR7, 0);
 	if (rf->channel <= 14)
 		rt2x00_set_field32(&reg, GPIO_CTRL_VAL7, 1);
@@ -2923,7 +2923,7 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 	const bool is_11b = false;
 	const bool is_type_ep = false;
 
-	rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 	rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL,
 			   (rf->channel > 14 || conf_is_ht40(conf)) ? 5 : 0);
 	rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
@@ -3362,7 +3362,7 @@ static void rt2800_config_alc(struct rt2x00_dev *rt2x00dev,
 	if (max_power > 0x2f)
 		max_power = 0x2f;
 
-	rt2800_register_read(rt2x00dev, TX_ALC_CFG_0, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_ALC_CFG_0);
 	rt2x00_set_field32(&reg, TX_ALC_CFG_0_CH_INIT_0, power_level);
 	rt2x00_set_field32(&reg, TX_ALC_CFG_0_CH_INIT_1, power_level);
 	rt2x00_set_field32(&reg, TX_ALC_CFG_0_LIMIT_0, max_power);
@@ -3378,18 +3378,17 @@ static void rt2800_config_alc(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_register_write(rt2x00dev, TX_ALC_CFG_0, reg);
 
-	rt2800_register_read(rt2x00dev, TX_ALC_CFG_1, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_ALC_CFG_1);
 	rt2x00_set_field32(&reg, TX_ALC_CFG_1_TX_TEMP_COMP, 0);
 	rt2800_register_write(rt2x00dev, TX_ALC_CFG_1, reg);
 
 	/* Save MAC SYS CTRL registers */
-	rt2800_register_read(rt2x00dev, MAC_SYS_CTRL, &mac_sys_ctrl);
+	mac_sys_ctrl = rt2800_register_read(rt2x00dev, MAC_SYS_CTRL);
 	/* Disable Tx/Rx */
 	rt2800_register_write(rt2x00dev, MAC_SYS_CTRL, 0);
 	/* Check MAC Tx/Rx idle */
 	for (i = 0; i < 10000; i++) {
-		rt2800_register_read(rt2x00dev, MAC_STATUS_CFG,
-				     &mac_status);
+		mac_status = rt2800_register_read(rt2x00dev, MAC_STATUS_CFG);
 		if (mac_status & 0x3)
 			usleep_range(50, 200);
 		else
@@ -3702,7 +3701,7 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 			rt2800_bbp_write(rt2x00dev, 75, 0x50);
 	}
 
-	rt2800_register_read(rt2x00dev, TX_BAND_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_BAND_CFG);
 	rt2x00_set_field32(&reg, TX_BAND_CFG_HT40_MINUS, conf_is_ht40_minus(conf));
 	rt2x00_set_field32(&reg, TX_BAND_CFG_A, rf->channel > 14);
 	rt2x00_set_field32(&reg, TX_BAND_CFG_BG, rf->channel <= 14);
@@ -3711,7 +3710,7 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 	if (rt2x00_rt(rt2x00dev, RT3572))
 		rt2800_rfcsr_write(rt2x00dev, 8, 0);
 
-	rt2800_register_read(rt2x00dev, TX_PIN_CFG, &tx_pin);
+	tx_pin = rt2800_register_read(rt2x00dev, TX_PIN_CFG);
 
 	switch (rt2x00dev->default_ant.tx_chain_num) {
 	case 3:
@@ -3777,7 +3776,7 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 	}
 
 	if (rt2x00_rt(rt2x00dev, RT3593)) {
-		rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 
 		/* Band selection */
 		if (rt2x00_is_usb(rt2x00dev) ||
@@ -3869,9 +3868,9 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 	/*
 	 * Clear channel statistic counters
 	 */
-	rt2800_register_read(rt2x00dev, CH_IDLE_STA, &reg);
-	rt2800_register_read(rt2x00dev, CH_BUSY_STA, &reg);
-	rt2800_register_read(rt2x00dev, CH_BUSY_STA_SEC, &reg);
+	reg = rt2800_register_read(rt2x00dev, CH_IDLE_STA);
+	reg = rt2800_register_read(rt2x00dev, CH_BUSY_STA);
+	reg = rt2800_register_read(rt2x00dev, CH_BUSY_STA_SEC);
 
 	/*
 	 * Clear update flag
@@ -4613,26 +4612,26 @@ static void rt2800_config_txpower_rt6352(struct rt2x00_dev *rt2x00dev,
 
 	/* For OFDM 54MBS use value from OFDM 48MBS */
 	pwreg = 0;
-	rt2800_register_read(rt2x00dev, TX_PWR_CFG_1, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_PWR_CFG_1);
 	t = rt2x00_get_field32(reg, TX_PWR_CFG_1B_48MBS);
 	rt2x00_set_field32(&pwreg, TX_PWR_CFG_7B_54MBS, t);
 
 	/* For MCS 7 use value from MCS 6 */
-	rt2800_register_read(rt2x00dev, TX_PWR_CFG_2, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_PWR_CFG_2);
 	t = rt2x00_get_field32(reg, TX_PWR_CFG_2B_MCS6_MCS7);
 	rt2x00_set_field32(&pwreg, TX_PWR_CFG_7B_MCS7, t);
 	rt2800_register_write(rt2x00dev, TX_PWR_CFG_7, pwreg);
 
 	/* For MCS 15 use value from MCS 14 */
 	pwreg = 0;
-	rt2800_register_read(rt2x00dev, TX_PWR_CFG_3, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_PWR_CFG_3);
 	t = rt2x00_get_field32(reg, TX_PWR_CFG_3B_MCS14);
 	rt2x00_set_field32(&pwreg, TX_PWR_CFG_8B_MCS15, t);
 	rt2800_register_write(rt2x00dev, TX_PWR_CFG_8, pwreg);
 
 	/* For STBC MCS 7 use value from STBC MCS 6 */
 	pwreg = 0;
-	rt2800_register_read(rt2x00dev, TX_PWR_CFG_4, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_PWR_CFG_4);
 	t = rt2x00_get_field32(reg, TX_PWR_CFG_4B_STBC_MCS6);
 	rt2x00_set_field32(&pwreg, TX_PWR_CFG_9B_STBC_MCS7, t);
 	rt2800_register_write(rt2x00dev, TX_PWR_CFG_9, pwreg);
@@ -4725,7 +4724,7 @@ static void rt2800_config_txpower_rt28xx(struct rt2x00_dev *rt2x00dev,
 		if (offset > TX_PWR_CFG_4)
 			break;
 
-		rt2800_register_read(rt2x00dev, offset, &reg);
+		reg = rt2800_register_read(rt2x00dev, offset);
 
 		/* read the next four txpower values */
 		rt2800_eeprom_read_from_array(rt2x00dev, EEPROM_TXPOWER_BYRATE,
@@ -4865,7 +4864,7 @@ void rt2800_vco_calibration(struct rt2x00_dev *rt2x00dev)
 	 * periodically to adjust the frequency to be precision.
 	*/
 
-	rt2800_register_read(rt2x00dev, TX_PIN_CFG, &tx_pin);
+	tx_pin = rt2800_register_read(rt2x00dev, TX_PIN_CFG);
 	tx_pin &= TX_PIN_CFG_PA_PE_DISABLE;
 	rt2800_register_write(rt2x00dev, TX_PIN_CFG, tx_pin);
 
@@ -4913,7 +4912,7 @@ void rt2800_vco_calibration(struct rt2x00_dev *rt2x00dev)
 	if (min_sleep > 0)
 		usleep_range(min_sleep, min_sleep * 2);
 
-	rt2800_register_read(rt2x00dev, TX_PIN_CFG, &tx_pin);
+	tx_pin = rt2800_register_read(rt2x00dev, TX_PIN_CFG);
 	if (rt2x00dev->rf_channel <= 14) {
 		switch (rt2x00dev->default_ant.tx_chain_num) {
 		case 3:
@@ -4987,7 +4986,7 @@ static void rt2800_config_retry_limit(struct rt2x00_dev *rt2x00dev,
 {
 	u32 reg;
 
-	rt2800_register_read(rt2x00dev, TX_RTY_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_RTY_CFG);
 	rt2x00_set_field32(&reg, TX_RTY_CFG_SHORT_RTY_LIMIT,
 			   libconf->conf->short_frame_max_tx_count);
 	rt2x00_set_field32(&reg, TX_RTY_CFG_LONG_RTY_LIMIT,
@@ -5006,7 +5005,7 @@ static void rt2800_config_ps(struct rt2x00_dev *rt2x00dev,
 	if (state == STATE_SLEEP) {
 		rt2800_register_write(rt2x00dev, AUTOWAKEUP_CFG, 0);
 
-		rt2800_register_read(rt2x00dev, AUTOWAKEUP_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, AUTOWAKEUP_CFG);
 		rt2x00_set_field32(&reg, AUTOWAKEUP_CFG_AUTO_LEAD_TIME, 5);
 		rt2x00_set_field32(&reg, AUTOWAKEUP_CFG_TBCN_BEFORE_WAKE,
 				   libconf->conf->listen_interval - 1);
@@ -5015,7 +5014,7 @@ static void rt2800_config_ps(struct rt2x00_dev *rt2x00dev,
 
 		rt2x00dev->ops->lib->set_device_state(rt2x00dev, state);
 	} else {
-		rt2800_register_read(rt2x00dev, AUTOWAKEUP_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, AUTOWAKEUP_CFG);
 		rt2x00_set_field32(&reg, AUTOWAKEUP_CFG_AUTO_LEAD_TIME, 0);
 		rt2x00_set_field32(&reg, AUTOWAKEUP_CFG_TBCN_BEFORE_WAKE, 0);
 		rt2x00_set_field32(&reg, AUTOWAKEUP_CFG_AUTOWAKE, 0);
@@ -5058,7 +5057,7 @@ void rt2800_link_stats(struct rt2x00_dev *rt2x00dev, struct link_qual *qual)
 	/*
 	 * Update FCS error count from register.
 	 */
-	rt2800_register_read(rt2x00dev, RX_STA_CNT0, &reg);
+	reg = rt2800_register_read(rt2x00dev, RX_STA_CNT0);
 	qual->rx_failed = rt2x00_get_field32(reg, RX_STA_CNT0_CRC_ERR);
 }
 EXPORT_SYMBOL_GPL(rt2800_link_stats);
@@ -5187,7 +5186,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 
 	rt2800_register_write(rt2x00dev, MAC_SYS_CTRL, 0x00000000);
 
-	rt2800_register_read(rt2x00dev, BCN_TIME_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, BCN_TIME_CFG);
 	rt2x00_set_field32(&reg, BCN_TIME_CFG_BEACON_INTERVAL, 1600);
 	rt2x00_set_field32(&reg, BCN_TIME_CFG_TSF_TICKING, 0);
 	rt2x00_set_field32(&reg, BCN_TIME_CFG_TSF_SYNC, 0);
@@ -5198,43 +5197,43 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 
 	rt2800_config_filter(rt2x00dev, FIF_ALLMULTI);
 
-	rt2800_register_read(rt2x00dev, BKOFF_SLOT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, BKOFF_SLOT_CFG);
 	rt2x00_set_field32(&reg, BKOFF_SLOT_CFG_SLOT_TIME, 9);
 	rt2x00_set_field32(&reg, BKOFF_SLOT_CFG_CC_DELAY_TIME, 2);
 	rt2800_register_write(rt2x00dev, BKOFF_SLOT_CFG, reg);
 
 	if (rt2x00_rt(rt2x00dev, RT3290)) {
-		rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, WLAN_FUN_CTRL);
 		if (rt2x00_get_field32(reg, WLAN_EN) == 1) {
 			rt2x00_set_field32(&reg, PCIE_APP0_CLK_REQ, 1);
 			rt2800_register_write(rt2x00dev, WLAN_FUN_CTRL, reg);
 		}
 
-		rt2800_register_read(rt2x00dev, CMB_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, CMB_CTRL);
 		if (!(rt2x00_get_field32(reg, LDO0_EN) == 1)) {
 			rt2x00_set_field32(&reg, LDO0_EN, 1);
 			rt2x00_set_field32(&reg, LDO_BGSEL, 3);
 			rt2800_register_write(rt2x00dev, CMB_CTRL, reg);
 		}
 
-		rt2800_register_read(rt2x00dev, OSC_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, OSC_CTRL);
 		rt2x00_set_field32(&reg, OSC_ROSC_EN, 1);
 		rt2x00_set_field32(&reg, OSC_CAL_REQ, 1);
 		rt2x00_set_field32(&reg, OSC_REF_CYCLE, 0x27);
 		rt2800_register_write(rt2x00dev, OSC_CTRL, reg);
 
-		rt2800_register_read(rt2x00dev, COEX_CFG0, &reg);
+		reg = rt2800_register_read(rt2x00dev, COEX_CFG0);
 		rt2x00_set_field32(&reg, COEX_CFG_ANT, 0x5e);
 		rt2800_register_write(rt2x00dev, COEX_CFG0, reg);
 
-		rt2800_register_read(rt2x00dev, COEX_CFG2, &reg);
+		reg = rt2800_register_read(rt2x00dev, COEX_CFG2);
 		rt2x00_set_field32(&reg, BT_COEX_CFG1, 0x00);
 		rt2x00_set_field32(&reg, BT_COEX_CFG0, 0x17);
 		rt2x00_set_field32(&reg, WL_COEX_CFG1, 0x93);
 		rt2x00_set_field32(&reg, WL_COEX_CFG0, 0x7f);
 		rt2800_register_write(rt2x00dev, COEX_CFG2, reg);
 
-		rt2800_register_read(rt2x00dev, PLL_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, PLL_CTRL);
 		rt2x00_set_field32(&reg, PLL_CONTROL, 1);
 		rt2800_register_write(rt2x00dev, PLL_CTRL, reg);
 	}
@@ -5331,7 +5330,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 				      0x3630363A);
 		rt2800_register_write(rt2x00dev, TX1_RF_GAIN_CORRECT,
 				      0x3630363A);
-		rt2800_register_read(rt2x00dev, TX_ALC_CFG_1, &reg);
+		reg = rt2800_register_read(rt2x00dev, TX_ALC_CFG_1);
 		rt2x00_set_field32(&reg, TX_ALC_CFG_1_ROS_BUSY_EN, 0);
 		rt2800_register_write(rt2x00dev, TX_ALC_CFG_1, reg);
 	} else {
@@ -5339,7 +5338,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 		rt2800_register_write(rt2x00dev, TX_SW_CFG1, 0x00080606);
 	}
 
-	rt2800_register_read(rt2x00dev, TX_LINK_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_LINK_CFG);
 	rt2x00_set_field32(&reg, TX_LINK_CFG_REMOTE_MFB_LIFETIME, 32);
 	rt2x00_set_field32(&reg, TX_LINK_CFG_MFB_ENABLE, 0);
 	rt2x00_set_field32(&reg, TX_LINK_CFG_REMOTE_UMFS_ENABLE, 0);
@@ -5350,13 +5349,13 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, TX_LINK_CFG_REMOTE_MFS, 0);
 	rt2800_register_write(rt2x00dev, TX_LINK_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, TX_TIMEOUT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_TIMEOUT_CFG);
 	rt2x00_set_field32(&reg, TX_TIMEOUT_CFG_MPDU_LIFETIME, 9);
 	rt2x00_set_field32(&reg, TX_TIMEOUT_CFG_RX_ACK_TIMEOUT, 32);
 	rt2x00_set_field32(&reg, TX_TIMEOUT_CFG_TX_OP_TIMEOUT, 10);
 	rt2800_register_write(rt2x00dev, TX_TIMEOUT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MAX_LEN_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MAX_LEN_CFG);
 	rt2x00_set_field32(&reg, MAX_LEN_CFG_MAX_MPDU, AGGREGATION_SIZE);
 	if (rt2x00_is_usb(rt2x00dev)) {
 		drv_data->max_psdu = 3;
@@ -5372,7 +5371,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, MAX_LEN_CFG_MIN_MPDU, 10);
 	rt2800_register_write(rt2x00dev, MAX_LEN_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, LED_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, LED_CFG);
 	rt2x00_set_field32(&reg, LED_CFG_ON_PERIOD, 70);
 	rt2x00_set_field32(&reg, LED_CFG_OFF_PERIOD, 30);
 	rt2x00_set_field32(&reg, LED_CFG_SLOW_BLINK_PERIOD, 3);
@@ -5384,7 +5383,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 
 	rt2800_register_write(rt2x00dev, PBF_MAX_PCNT, 0x1f3fbf9f);
 
-	rt2800_register_read(rt2x00dev, TX_RTY_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_RTY_CFG);
 	rt2x00_set_field32(&reg, TX_RTY_CFG_SHORT_RTY_LIMIT, 2);
 	rt2x00_set_field32(&reg, TX_RTY_CFG_LONG_RTY_LIMIT, 2);
 	rt2x00_set_field32(&reg, TX_RTY_CFG_LONG_RTY_THRE, 2000);
@@ -5393,7 +5392,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, TX_RTY_CFG_TX_AUTO_FB_ENABLE, 1);
 	rt2800_register_write(rt2x00dev, TX_RTY_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, AUTO_RSP_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, AUTO_RSP_CFG);
 	rt2x00_set_field32(&reg, AUTO_RSP_CFG_AUTORESPONDER, 1);
 	rt2x00_set_field32(&reg, AUTO_RSP_CFG_BAC_ACK_POLICY, 1);
 	rt2x00_set_field32(&reg, AUTO_RSP_CFG_CTS_40_MMODE, 1);
@@ -5403,7 +5402,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, AUTO_RSP_CFG_ACK_CTS_PSM_BIT, 0);
 	rt2800_register_write(rt2x00dev, AUTO_RSP_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, CCK_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, CCK_PROT_CFG);
 	rt2x00_set_field32(&reg, CCK_PROT_CFG_PROTECT_RATE, 3);
 	rt2x00_set_field32(&reg, CCK_PROT_CFG_PROTECT_CTRL, 0);
 	rt2x00_set_field32(&reg, CCK_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5416,7 +5415,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, CCK_PROT_CFG_RTS_TH_EN, 1);
 	rt2800_register_write(rt2x00dev, CCK_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, OFDM_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, OFDM_PROT_CFG);
 	rt2x00_set_field32(&reg, OFDM_PROT_CFG_PROTECT_RATE, 3);
 	rt2x00_set_field32(&reg, OFDM_PROT_CFG_PROTECT_CTRL, 0);
 	rt2x00_set_field32(&reg, OFDM_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5429,7 +5428,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, OFDM_PROT_CFG_RTS_TH_EN, 1);
 	rt2800_register_write(rt2x00dev, OFDM_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MM20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM20_PROT_CFG);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_PROTECT_RATE, 0x4004);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_PROTECT_CTRL, 1);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5442,7 +5441,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_RTS_TH_EN, 0);
 	rt2800_register_write(rt2x00dev, MM20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MM40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM40_PROT_CFG);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_PROTECT_RATE, 0x4084);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_PROTECT_CTRL, 1);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5455,7 +5454,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_RTS_TH_EN, 0);
 	rt2800_register_write(rt2x00dev, MM40_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF20_PROT_CFG);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_PROTECT_RATE, 0x4004);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_PROTECT_CTRL, 1);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5468,7 +5467,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_RTS_TH_EN, 0);
 	rt2800_register_write(rt2x00dev, GF20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF40_PROT_CFG);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_PROTECT_RATE, 0x4084);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_PROTECT_CTRL, 1);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_PROTECT_NAV_SHORT, 1);
@@ -5484,7 +5483,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	if (rt2x00_is_usb(rt2x00dev)) {
 		rt2800_register_write(rt2x00dev, PBF_CFG, 0xf40006);
 
-		rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG);
 		rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_TX_DMA, 0);
 		rt2x00_set_field32(&reg, WPDMA_GLO_CFG_TX_DMA_BUSY, 0);
 		rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_RX_DMA, 0);
@@ -5501,7 +5500,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	 * The legacy driver also sets TXOP_CTRL_CFG_RESERVED_TRUN_EN to 1
 	 * although it is reserved.
 	 */
-	rt2800_register_read(rt2x00dev, TXOP_CTRL_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TXOP_CTRL_CFG);
 	rt2x00_set_field32(&reg, TXOP_CTRL_CFG_TIMEOUT_TRUN_EN, 1);
 	rt2x00_set_field32(&reg, TXOP_CTRL_CFG_AC_TRUN_EN, 1);
 	rt2x00_set_field32(&reg, TXOP_CTRL_CFG_TXRATEGRP_TRUN_EN, 1);
@@ -5517,7 +5516,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	reg = rt2x00_rt(rt2x00dev, RT5592) ? 0x00000082 : 0x00000002;
 	rt2800_register_write(rt2x00dev, TXOP_HLDR_ET, reg);
 
-	rt2800_register_read(rt2x00dev, TX_RTS_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_RTS_CFG);
 	rt2x00_set_field32(&reg, TX_RTS_CFG_AUTO_RTS_RETRY_LIMIT, 7);
 	rt2x00_set_field32(&reg, TX_RTS_CFG_RTS_THRES,
 			   IEEE80211_MAX_RTS_THRESHOLD);
@@ -5533,7 +5532,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	 * connection problems with 11g + CTS protection. Hence, use the same
 	 * defaults as the Ralink driver: 16 for both, CCK and OFDM SIFS.
 	 */
-	rt2800_register_read(rt2x00dev, XIFS_TIME_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, XIFS_TIME_CFG);
 	rt2x00_set_field32(&reg, XIFS_TIME_CFG_CCKM_SIFS_TIME, 16);
 	rt2x00_set_field32(&reg, XIFS_TIME_CFG_OFDM_SIFS_TIME, 16);
 	rt2x00_set_field32(&reg, XIFS_TIME_CFG_OFDM_XIFS_TIME, 4);
@@ -5563,16 +5562,16 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 		rt2800_clear_beacon_register(rt2x00dev, i);
 
 	if (rt2x00_is_usb(rt2x00dev)) {
-		rt2800_register_read(rt2x00dev, US_CYC_CNT, &reg);
+		reg = rt2800_register_read(rt2x00dev, US_CYC_CNT);
 		rt2x00_set_field32(&reg, US_CYC_CNT_CLOCK_CYCLE, 30);
 		rt2800_register_write(rt2x00dev, US_CYC_CNT, reg);
 	} else if (rt2x00_is_pcie(rt2x00dev)) {
-		rt2800_register_read(rt2x00dev, US_CYC_CNT, &reg);
+		reg = rt2800_register_read(rt2x00dev, US_CYC_CNT);
 		rt2x00_set_field32(&reg, US_CYC_CNT_CLOCK_CYCLE, 125);
 		rt2800_register_write(rt2x00dev, US_CYC_CNT, reg);
 	}
 
-	rt2800_register_read(rt2x00dev, HT_FBK_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, HT_FBK_CFG0);
 	rt2x00_set_field32(&reg, HT_FBK_CFG0_HTMCS0FBK, 0);
 	rt2x00_set_field32(&reg, HT_FBK_CFG0_HTMCS1FBK, 0);
 	rt2x00_set_field32(&reg, HT_FBK_CFG0_HTMCS2FBK, 1);
@@ -5583,7 +5582,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, HT_FBK_CFG0_HTMCS7FBK, 6);
 	rt2800_register_write(rt2x00dev, HT_FBK_CFG0, reg);
 
-	rt2800_register_read(rt2x00dev, HT_FBK_CFG1, &reg);
+	reg = rt2800_register_read(rt2x00dev, HT_FBK_CFG1);
 	rt2x00_set_field32(&reg, HT_FBK_CFG1_HTMCS8FBK, 8);
 	rt2x00_set_field32(&reg, HT_FBK_CFG1_HTMCS9FBK, 8);
 	rt2x00_set_field32(&reg, HT_FBK_CFG1_HTMCS10FBK, 9);
@@ -5594,7 +5593,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, HT_FBK_CFG1_HTMCS15FBK, 14);
 	rt2800_register_write(rt2x00dev, HT_FBK_CFG1, reg);
 
-	rt2800_register_read(rt2x00dev, LG_FBK_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LG_FBK_CFG0);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_OFDMMCS0FBK, 8);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_OFDMMCS1FBK, 8);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_OFDMMCS2FBK, 9);
@@ -5605,7 +5604,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_OFDMMCS7FBK, 14);
 	rt2800_register_write(rt2x00dev, LG_FBK_CFG0, reg);
 
-	rt2800_register_read(rt2x00dev, LG_FBK_CFG1, &reg);
+	reg = rt2800_register_read(rt2x00dev, LG_FBK_CFG1);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_CCKMCS0FBK, 0);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_CCKMCS1FBK, 0);
 	rt2x00_set_field32(&reg, LG_FBK_CFG0_CCKMCS2FBK, 1);
@@ -5615,7 +5614,7 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Do not force the BA window size, we use the TXWI to set it
 	 */
-	rt2800_register_read(rt2x00dev, AMPDU_BA_WINSIZE, &reg);
+	reg = rt2800_register_read(rt2x00dev, AMPDU_BA_WINSIZE);
 	rt2x00_set_field32(&reg, AMPDU_BA_WINSIZE_FORCE_WINSIZE_ENABLE, 0);
 	rt2x00_set_field32(&reg, AMPDU_BA_WINSIZE_FORCE_WINSIZE, 0);
 	rt2800_register_write(rt2x00dev, AMPDU_BA_WINSIZE, reg);
@@ -5625,24 +5624,24 @@ static int rt2800_init_registers(struct rt2x00_dev *rt2x00dev)
 	 * These registers are cleared on read,
 	 * so we may pass a useless variable to store the value.
 	 */
-	rt2800_register_read(rt2x00dev, RX_STA_CNT0, &reg);
-	rt2800_register_read(rt2x00dev, RX_STA_CNT1, &reg);
-	rt2800_register_read(rt2x00dev, RX_STA_CNT2, &reg);
-	rt2800_register_read(rt2x00dev, TX_STA_CNT0, &reg);
-	rt2800_register_read(rt2x00dev, TX_STA_CNT1, &reg);
-	rt2800_register_read(rt2x00dev, TX_STA_CNT2, &reg);
+	reg = rt2800_register_read(rt2x00dev, RX_STA_CNT0);
+	reg = rt2800_register_read(rt2x00dev, RX_STA_CNT1);
+	reg = rt2800_register_read(rt2x00dev, RX_STA_CNT2);
+	reg = rt2800_register_read(rt2x00dev, TX_STA_CNT0);
+	reg = rt2800_register_read(rt2x00dev, TX_STA_CNT1);
+	reg = rt2800_register_read(rt2x00dev, TX_STA_CNT2);
 
 	/*
 	 * Setup leadtime for pre tbtt interrupt to 6ms
 	 */
-	rt2800_register_read(rt2x00dev, INT_TIMER_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, INT_TIMER_CFG);
 	rt2x00_set_field32(&reg, INT_TIMER_CFG_PRE_TBTT_TIMER, 6 << 4);
 	rt2800_register_write(rt2x00dev, INT_TIMER_CFG, reg);
 
 	/*
 	 * Set up channel statistics timer
 	 */
-	rt2800_register_read(rt2x00dev, CH_TIME_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, CH_TIME_CFG);
 	rt2x00_set_field32(&reg, CH_TIME_CFG_EIFS_BUSY, 1);
 	rt2x00_set_field32(&reg, CH_TIME_CFG_NAV_BUSY, 1);
 	rt2x00_set_field32(&reg, CH_TIME_CFG_RX_BUSY, 1);
@@ -5659,7 +5658,7 @@ static int rt2800_wait_bbp_rf_ready(struct rt2x00_dev *rt2x00dev)
 	u32 reg;
 
 	for (i = 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2800_register_read(rt2x00dev, MAC_STATUS_CFG, &reg);
+		reg = rt2800_register_read(rt2x00dev, MAC_STATUS_CFG);
 		if (!rt2x00_get_field32(reg, MAC_STATUS_CFG_BBP_RF_BUSY))
 			return 0;
 
@@ -6212,7 +6211,7 @@ static void rt2800_init_bbp_53xx(struct rt2x00_dev *rt2x00dev)
 	if (rt2x00_has_cap_bt_coexist(rt2x00dev)) {
 		u32 reg;
 
-		rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+		reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 		rt2x00_set_field32(&reg, GPIO_CTRL_DIR3, 0);
 		rt2x00_set_field32(&reg, GPIO_CTRL_DIR6, 0);
 		rt2x00_set_field32(&reg, GPIO_CTRL_VAL3, 0);
@@ -6605,7 +6604,7 @@ static void rt2800_led_open_drain_enable(struct rt2x00_dev *rt2x00dev)
 {
 	u32 reg;
 
-	rt2800_register_read(rt2x00dev, OPT_14_CSR, &reg);
+	reg = rt2800_register_read(rt2x00dev, OPT_14_CSR);
 	rt2x00_set_field32(&reg, OPT_14_CSR_BIT0, 1);
 	rt2800_register_write(rt2x00dev, OPT_14_CSR, reg);
 }
@@ -6938,7 +6937,7 @@ static void rt2800_init_rfcsr_30xx(struct rt2x00_dev *rt2x00dev)
 	rt2800_rfcsr_write(rt2x00dev, 29, 0x1f);
 
 	if (rt2x00_rt_rev_lt(rt2x00dev, RT3070, REV_RT3070F)) {
-		rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+		reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 		rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 		rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 3);
 		rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
@@ -6950,7 +6949,7 @@ static void rt2800_init_rfcsr_30xx(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field8(&rfcsr, RFCSR6_R2, 1);
 		rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
-		rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+		reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 		rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 		if (rt2x00_rt_rev_lt(rt2x00dev, RT3071, REV_RT3071E) ||
 		    rt2x00_rt_rev_lt(rt2x00dev, RT3090, REV_RT3090E)) {
@@ -6963,7 +6962,7 @@ static void rt2800_init_rfcsr_30xx(struct rt2x00_dev *rt2x00dev)
 		}
 		rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 
-		rt2800_register_read(rt2x00dev, GPIO_SWITCH, &reg);
+		reg = rt2800_register_read(rt2x00dev, GPIO_SWITCH);
 		rt2x00_set_field32(&reg, GPIO_SWITCH_5, 0);
 		rt2800_register_write(rt2x00dev, GPIO_SWITCH, reg);
 	}
@@ -7178,7 +7177,7 @@ static void rt2800_init_rfcsr_3390(struct rt2x00_dev *rt2x00dev)
 	rt2800_rfcsr_write(rt2x00dev, 30, 0x20);
 	rt2800_rfcsr_write(rt2x00dev, 31, 0x0f);
 
-	rt2800_register_read(rt2x00dev, GPIO_SWITCH, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_SWITCH);
 	rt2x00_set_field32(&reg, GPIO_SWITCH_5, 0);
 	rt2800_register_write(rt2x00dev, GPIO_SWITCH, reg);
 
@@ -7234,12 +7233,12 @@ static void rt2800_init_rfcsr_3572(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field8(&rfcsr, RFCSR6_R2, 1);
 	rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
-	rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 	rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 3);
 	rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 	rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 	msleep(1);
-	rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 	rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 0);
 	rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 	rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
@@ -7303,7 +7302,7 @@ static void rt2800_init_rfcsr_3593(struct rt2x00_dev *rt2x00dev)
 	u8 rfcsr;
 
 	/* Disable GPIO #4 and #7 function for LAN PE control */
-	rt2800_register_read(rt2x00dev, GPIO_SWITCH, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_SWITCH);
 	rt2x00_set_field32(&reg, GPIO_SWITCH_4, 0);
 	rt2x00_set_field32(&reg, GPIO_SWITCH_7, 0);
 	rt2800_register_write(rt2x00dev, GPIO_SWITCH, reg);
@@ -7354,12 +7353,12 @@ static void rt2800_init_rfcsr_3593(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field8(&rfcsr, RFCSR18_XO_TUNE_BYPASS, 1);
 	rt2800_rfcsr_write(rt2x00dev, 18, rfcsr);
 
-	rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 	rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 3);
 	rt2x00_set_field32(&reg, LDO_CFG0_BGSEL, 1);
 	rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 	usleep_range(1000, 1500);
-	rt2800_register_read(rt2x00dev, LDO_CFG0, &reg);
+	reg = rt2800_register_read(rt2x00dev, LDO_CFG0);
 	rt2x00_set_field32(&reg, LDO_CFG0_LDO_CORE_VLEVEL, 0);
 	rt2800_register_write(rt2x00dev, LDO_CFG0, reg);
 
@@ -7773,8 +7772,8 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 	u32 MAC_RF_CONTROL0, MAC_RF_BYPASS0;
 
 	/* Save MAC registers */
-	rt2800_register_read(rt2x00dev, RF_CONTROL0, &MAC_RF_CONTROL0);
-	rt2800_register_read(rt2x00dev, RF_BYPASS0, &MAC_RF_BYPASS0);
+	MAC_RF_CONTROL0 = rt2800_register_read(rt2x00dev, RF_CONTROL0);
+	MAC_RF_BYPASS0 = rt2800_register_read(rt2x00dev, RF_BYPASS0);
 
 	/* save BBP registers */
 	rt2800_bbp_read(rt2x00dev, 23, &savebbpr23);
@@ -8367,20 +8366,20 @@ int rt2800_enable_radio(struct rt2x00_dev *rt2x00dev)
 	/*
 	 * Enable RX.
 	 */
-	rt2800_register_read(rt2x00dev, MAC_SYS_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, MAC_SYS_CTRL);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_TX, 1);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_RX, 0);
 	rt2800_register_write(rt2x00dev, MAC_SYS_CTRL, reg);
 
 	udelay(50);
 
-	rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, WPDMA_GLO_CFG);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_TX_DMA, 1);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_ENABLE_RX_DMA, 1);
 	rt2x00_set_field32(&reg, WPDMA_GLO_CFG_TX_WRITEBACK_DONE, 1);
 	rt2800_register_write(rt2x00dev, WPDMA_GLO_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MAC_SYS_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, MAC_SYS_CTRL);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_TX, 1);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_RX, 1);
 	rt2800_register_write(rt2x00dev, MAC_SYS_CTRL, reg);
@@ -8413,7 +8412,7 @@ void rt2800_disable_radio(struct rt2x00_dev *rt2x00dev)
 	/* Wait for DMA, ignore error */
 	rt2800_wait_wpdma_ready(rt2x00dev);
 
-	rt2800_register_read(rt2x00dev, MAC_SYS_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, MAC_SYS_CTRL);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_TX, 0);
 	rt2x00_set_field32(&reg, MAC_SYS_CTRL_ENABLE_RX, 0);
 	rt2800_register_write(rt2x00dev, MAC_SYS_CTRL, reg);
@@ -8430,7 +8429,7 @@ int rt2800_efuse_detect(struct rt2x00_dev *rt2x00dev)
 	else
 		efuse_ctrl_reg = EFUSE_CTRL;
 
-	rt2800_register_read(rt2x00dev, efuse_ctrl_reg, &reg);
+	reg = rt2800_register_read(rt2x00dev, efuse_ctrl_reg);
 	return rt2x00_get_field32(reg, EFUSE_CTRL_PRESENT);
 }
 EXPORT_SYMBOL_GPL(rt2800_efuse_detect);
@@ -8459,7 +8458,7 @@ static void rt2800_efuse_read(struct rt2x00_dev *rt2x00dev, unsigned int i)
 	}
 	mutex_lock(&rt2x00dev->csr_mutex);
 
-	rt2800_register_read_lock(rt2x00dev, efuse_ctrl_reg, &reg);
+	reg = rt2800_register_read_lock(rt2x00dev, efuse_ctrl_reg);
 	rt2x00_set_field32(&reg, EFUSE_CTRL_ADDRESS_IN, i);
 	rt2x00_set_field32(&reg, EFUSE_CTRL_MODE, 0);
 	rt2x00_set_field32(&reg, EFUSE_CTRL_KICK, 1);
@@ -8468,14 +8467,14 @@ static void rt2800_efuse_read(struct rt2x00_dev *rt2x00dev, unsigned int i)
 	/* Wait until the EEPROM has been loaded */
 	rt2800_regbusy_read(rt2x00dev, efuse_ctrl_reg, EFUSE_CTRL_KICK, &reg);
 	/* Apparently the data is read from end to start */
-	rt2800_register_read_lock(rt2x00dev, efuse_data3_reg, &reg);
+	reg = rt2800_register_read_lock(rt2x00dev, efuse_data3_reg);
 	/* The returned value is in CPU order, but eeprom is le */
 	*(u32 *)&rt2x00dev->eeprom[i] = cpu_to_le32(reg);
-	rt2800_register_read_lock(rt2x00dev, efuse_data2_reg, &reg);
+	reg = rt2800_register_read_lock(rt2x00dev, efuse_data2_reg);
 	*(u32 *)&rt2x00dev->eeprom[i + 2] = cpu_to_le32(reg);
-	rt2800_register_read_lock(rt2x00dev, efuse_data1_reg, &reg);
+	reg = rt2800_register_read_lock(rt2x00dev, efuse_data1_reg);
 	*(u32 *)&rt2x00dev->eeprom[i + 4] = cpu_to_le32(reg);
-	rt2800_register_read_lock(rt2x00dev, efuse_data0_reg, &reg);
+	reg = rt2800_register_read_lock(rt2x00dev, efuse_data0_reg);
 	*(u32 *)&rt2x00dev->eeprom[i + 6] = cpu_to_le32(reg);
 
 	mutex_unlock(&rt2x00dev->csr_mutex);
@@ -9251,7 +9250,7 @@ static int rt2800_probe_hw_mode(struct rt2x00_dev *rt2x00dev)
 		break;
 
 	case RF5592:
-		rt2800_register_read(rt2x00dev, MAC_DEBUG_INDEX, &reg);
+		reg = rt2800_register_read(rt2x00dev, MAC_DEBUG_INDEX);
 		if (rt2x00_get_field32(reg, MAC_DEBUG_INDEX_XTAL)) {
 			spec->num_channels = ARRAY_SIZE(rf_vals_5592_xtal40);
 			spec->channels = rf_vals_5592_xtal40;
@@ -9390,9 +9389,9 @@ static int rt2800_probe_rt(struct rt2x00_dev *rt2x00dev)
 	u32 rev;
 
 	if (rt2x00_rt(rt2x00dev, RT3290))
-		rt2800_register_read(rt2x00dev, MAC_CSR0_3290, &reg);
+		reg = rt2800_register_read(rt2x00dev, MAC_CSR0_3290);
 	else
-		rt2800_register_read(rt2x00dev, MAC_CSR0, &reg);
+		reg = rt2800_register_read(rt2x00dev, MAC_CSR0);
 
 	rt = rt2x00_get_field32(reg, MAC_CSR0_CHIPSET);
 	rev = rt2x00_get_field32(reg, MAC_CSR0_REVISION);
@@ -9452,7 +9451,7 @@ int rt2800_probe_hw(struct rt2x00_dev *rt2x00dev)
 	 * Enable rfkill polling by setting GPIO direction of the
 	 * rfkill switch GPIO pin correctly.
 	 */
-	rt2800_register_read(rt2x00dev, GPIO_CTRL, &reg);
+	reg = rt2800_register_read(rt2x00dev, GPIO_CTRL);
 	rt2x00_set_field32(&reg, GPIO_CTRL_DIR2, 1);
 	rt2800_register_write(rt2x00dev, GPIO_CTRL, reg);
 
@@ -9527,31 +9526,31 @@ int rt2800_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 	u32 reg;
 	bool enabled = (value < IEEE80211_MAX_RTS_THRESHOLD);
 
-	rt2800_register_read(rt2x00dev, TX_RTS_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, TX_RTS_CFG);
 	rt2x00_set_field32(&reg, TX_RTS_CFG_RTS_THRES, value);
 	rt2800_register_write(rt2x00dev, TX_RTS_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, CCK_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, CCK_PROT_CFG);
 	rt2x00_set_field32(&reg, CCK_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, CCK_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, OFDM_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, OFDM_PROT_CFG);
 	rt2x00_set_field32(&reg, OFDM_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, OFDM_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MM20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM20_PROT_CFG);
 	rt2x00_set_field32(&reg, MM20_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, MM20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, MM40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, MM40_PROT_CFG);
 	rt2x00_set_field32(&reg, MM40_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, MM40_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF20_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF20_PROT_CFG);
 	rt2x00_set_field32(&reg, GF20_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, GF20_PROT_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, GF40_PROT_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, GF40_PROT_CFG);
 	rt2x00_set_field32(&reg, GF40_PROT_CFG_RTS_TH_EN, enabled);
 	rt2800_register_write(rt2x00dev, GF40_PROT_CFG, reg);
 
@@ -9594,7 +9593,7 @@ int rt2800_conf_tx(struct ieee80211_hw *hw,
 	field.bit_offset = (queue_idx & 1) * 16;
 	field.bit_mask = 0xffff << field.bit_offset;
 
-	rt2800_register_read(rt2x00dev, offset, &reg);
+	reg = rt2800_register_read(rt2x00dev, offset);
 	rt2x00_set_field32(&reg, field, queue->txop);
 	rt2800_register_write(rt2x00dev, offset, reg);
 
@@ -9602,22 +9601,22 @@ int rt2800_conf_tx(struct ieee80211_hw *hw,
 	field.bit_offset = queue_idx * 4;
 	field.bit_mask = 0xf << field.bit_offset;
 
-	rt2800_register_read(rt2x00dev, WMM_AIFSN_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, WMM_AIFSN_CFG);
 	rt2x00_set_field32(&reg, field, queue->aifs);
 	rt2800_register_write(rt2x00dev, WMM_AIFSN_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, WMM_CWMIN_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, WMM_CWMIN_CFG);
 	rt2x00_set_field32(&reg, field, queue->cw_min);
 	rt2800_register_write(rt2x00dev, WMM_CWMIN_CFG, reg);
 
-	rt2800_register_read(rt2x00dev, WMM_CWMAX_CFG, &reg);
+	reg = rt2800_register_read(rt2x00dev, WMM_CWMAX_CFG);
 	rt2x00_set_field32(&reg, field, queue->cw_max);
 	rt2800_register_write(rt2x00dev, WMM_CWMAX_CFG, reg);
 
 	/* Update EDCA registers */
 	offset = EDCA_AC0_CFG + (sizeof(u32) * queue_idx);
 
-	rt2800_register_read(rt2x00dev, offset, &reg);
+	reg = rt2800_register_read(rt2x00dev, offset);
 	rt2x00_set_field32(&reg, EDCA_AC0_CFG_TX_OP, queue->txop);
 	rt2x00_set_field32(&reg, EDCA_AC0_CFG_AIFSN, queue->aifs);
 	rt2x00_set_field32(&reg, EDCA_AC0_CFG_CWMIN, queue->cw_min);
@@ -9634,9 +9633,9 @@ u64 rt2800_get_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 	u64 tsf;
 	u32 reg;
 
-	rt2800_register_read(rt2x00dev, TSF_TIMER_DW1, &reg);
+	reg = rt2800_register_read(rt2x00dev, TSF_TIMER_DW1);
 	tsf = (u64) rt2x00_get_field32(reg, TSF_TIMER_DW1_HIGH_WORD) << 32;
-	rt2800_register_read(rt2x00dev, TSF_TIMER_DW0, &reg);
+	reg = rt2800_register_read(rt2x00dev, TSF_TIMER_DW0);
 	tsf |= rt2x00_get_field32(reg, TSF_TIMER_DW0_LOW_WORD);
 
 	return tsf;
@@ -9703,9 +9702,9 @@ int rt2800_get_survey(struct ieee80211_hw *hw, int idx,
 
 	survey->channel = conf->chandef.chan;
 
-	rt2800_register_read(rt2x00dev, CH_IDLE_STA, &idle);
-	rt2800_register_read(rt2x00dev, CH_BUSY_STA, &busy);
-	rt2800_register_read(rt2x00dev, CH_BUSY_STA_SEC, &busy_ext);
+	idle = rt2800_register_read(rt2x00dev, CH_IDLE_STA);
+	busy = rt2800_register_read(rt2x00dev, CH_BUSY_STA);
+	busy_ext = rt2800_register_read(rt2x00dev, CH_BUSY_STA_SEC);
 
 	if (idle || busy) {
 		survey->filled = SURVEY_INFO_TIME |
diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800lib.h b/drivers/net/wireless/ralink/rt2x00/rt2800lib.h
index 6bed0d5e930e..275e3969abdd 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800lib.h
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800lib.h
@@ -78,30 +78,20 @@ struct rt2800_ops {
 	__le32 *(*drv_get_txwi)(struct queue_entry *entry);
 };
 
-static inline void rt2800_register_read(struct rt2x00_dev *rt2x00dev,
-					const unsigned int offset,
-					u32 *value)
+static inline u32 rt2800_register_read(struct rt2x00_dev *rt2x00dev,
+				       const unsigned int offset)
 {
 	const struct rt2800_ops *rt2800ops = rt2x00dev->ops->drv;
 
-	*value = rt2800ops->register_read(rt2x00dev, offset);
-}
-
-static inline void rt2800_register_read_lock(struct rt2x00_dev *rt2x00dev,
-					     const unsigned int offset,
-					     u32 *value)
-{
-	const struct rt2800_ops *rt2800ops = rt2x00dev->ops->drv;
-
-	*value = rt2800ops->register_read_lock(rt2x00dev, offset);
+	return rt2800ops->register_read(rt2x00dev, offset);
 }
 
-static inline u32 _rt2800_register_read(struct rt2x00_dev *rt2x00dev,
-					const unsigned int offset)
+static inline u32 rt2800_register_read_lock(struct rt2x00_dev *rt2x00dev,
+					    const unsigned int offset)
 {
 	const struct rt2800_ops *rt2800ops = rt2x00dev->ops->drv;
 
-	return rt2800ops->register_read(rt2x00dev, offset);
+	return rt2800ops->register_read_lock(rt2x00dev, offset);
 }
 
 static inline void rt2800_register_write(struct rt2x00_dev *rt2x00dev,
-- 
2.9.0
