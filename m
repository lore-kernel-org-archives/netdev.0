From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rt2x00: improve calling conventions for register accessors
Date: Mon, 15 May 2017 15:46:55 +0200
Message-ID: <20170515134711.2770374-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Daniel Golle <daniel@makrotopia.org>,
        Mathias Kresin <dev@kresin.me>,
        Johannes Berg <johannes.berg@intel.com>,
        =?UTF-8?q?Tomislav=20Po=C5=BEega?= <pozega.tomislav@gmail.com>,
        Serge Vasilugin <vasilugin@yandex.ru>,
        Roman Yeryomin <roman@advem.lv>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
stack usage (with a private patch set I have to turn on this warning,
which I intend to get into the next kernel release):

wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]

The problem is that KASAN inserts a redzone around each local variable that
gets passed by reference, and the newly added function has a lot of them.
We can easily avoid that here by changing the calling convention to have
the output as the return value of the function. This should also results in
smaller object code, saving around 4KB in .text with KASAN, or 2KB without
KASAN.

Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
 1 file changed, 164 insertions(+), 155 deletions(-)

diff --git a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
index d11c7b210e81..cafcf43436b9 100644
--- a/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/ralink/rt2x00/rt2800lib.c
@@ -203,10 +203,11 @@ static void rt2800_rfcsr_write_dccal(struct rt2x00_dev *rt2x00dev,
 	rt2800_rfcsr_write_bank(rt2x00dev, 7, reg, value);
 }
 
-static void rt2800_rfcsr_read(struct rt2x00_dev *rt2x00dev,
-			      const unsigned int word, u8 *value)
+static u8 rt2800_rfcsr_read(struct rt2x00_dev *rt2x00dev,
+			      const unsigned int word)
 {
 	u32 reg;
+	u8 value;
 
 	mutex_lock(&rt2x00dev->csr_mutex);
 
@@ -232,7 +233,7 @@ static void rt2800_rfcsr_read(struct rt2x00_dev *rt2x00dev,
 			WAIT_FOR_RFCSR_MT7620(rt2x00dev, &reg);
 		}
 
-		*value = rt2x00_get_field32(reg, RF_CSR_CFG_DATA_MT7620);
+		value = rt2x00_get_field32(reg, RF_CSR_CFG_DATA_MT7620);
 		break;
 
 	default:
@@ -247,17 +248,19 @@ static void rt2800_rfcsr_read(struct rt2x00_dev *rt2x00dev,
 			WAIT_FOR_RFCSR(rt2x00dev, &reg);
 		}
 
-		*value = rt2x00_get_field32(reg, RF_CSR_CFG_DATA);
+		value = rt2x00_get_field32(reg, RF_CSR_CFG_DATA);
 		break;
 	}
 
 	mutex_unlock(&rt2x00dev->csr_mutex);
+
+	return value;
 }
 
-static void rt2800_rfcsr_read_bank(struct rt2x00_dev *rt2x00dev, const u8 bank,
-				   const unsigned int reg, u8 *value)
+static u8 rt2800_rfcsr_read_bank(struct rt2x00_dev *rt2x00dev, const u8 bank,
+				   const unsigned int reg)
 {
-	rt2800_rfcsr_read(rt2x00dev, (reg | (bank << 6)), value);
+	return rt2800_rfcsr_read(rt2x00dev, (reg | (bank << 6)));
 }
 
 static void rt2800_rf_write(struct rt2x00_dev *rt2x00dev,
@@ -1225,6 +1228,12 @@ void rt2800_clear_beacon(struct queue_entry *entry)
 EXPORT_SYMBOL_GPL(rt2800_clear_beacon);
 
 #ifdef CONFIG_RT2X00_LIB_DEBUGFS
+static void rt2800_rfcsr_readreg(struct rt2x00_dev *rt2x00dev,
+				 const unsigned int word, u8 *value)
+{
+	*value = rt2800_rfcsr_read(rt2x00dev, word);
+}
+
 const struct rt2x00debug rt2800_rt2x00debug = {
 	.owner	= THIS_MODULE,
 	.csr	= {
@@ -1260,7 +1269,7 @@ const struct rt2x00debug rt2800_rt2x00debug = {
 		.word_count	= RF_SIZE / sizeof(u32),
 	},
 	.rfcsr	= {
-		.read		= rt2800_rfcsr_read,
+		.read		= rt2800_rfcsr_readreg,
 		.write		= rt2800_rfcsr_write,
 		.word_base	= RFCSR_BASE,
 		.word_size	= sizeof(u8),
@@ -2072,7 +2081,7 @@ static void rt2800_freq_cal_mode1(struct rt2x00_dev *rt2x00dev)
 	freq_offset = rt2x00_get_field8(rt2x00dev->freq_offset, RFCSR17_CODE);
 	freq_offset = min_t(u8, freq_offset, FREQ_OFFSET_BOUND);
 
-	rt2800_rfcsr_read(rt2x00dev, 17, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 17);
 	prev_rfcsr = rfcsr;
 
 	rt2x00_set_field8(&rfcsr, RFCSR17_CODE, freq_offset);
@@ -2174,23 +2183,23 @@ static void rt2800_config_channel_rf3xxx(struct rt2x00_dev *rt2x00dev,
 
 	rt2800_rfcsr_write(rt2x00dev, 2, rf->rf1);
 
-	rt2800_rfcsr_read(rt2x00dev, 3, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 3);
 	rt2x00_set_field8(&rfcsr, RFCSR3_K, rf->rf3);
 	rt2800_rfcsr_write(rt2x00dev, 3, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 6, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 6);
 	rt2x00_set_field8(&rfcsr, RFCSR6_R1, rf->rf2);
 	rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 12, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 12);
 	rt2x00_set_field8(&rfcsr, RFCSR12_TX_POWER, info->default_power1);
 	rt2800_rfcsr_write(rt2x00dev, 12, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 13, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 13);
 	rt2x00_set_field8(&rfcsr, RFCSR13_TX_POWER, info->default_power2);
 	rt2800_rfcsr_write(rt2x00dev, 13, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX0_PD, 0);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX1_PD,
 			  rt2x00dev->default_ant.rx_chain_num <= 1);
@@ -2203,7 +2212,7 @@ static void rt2800_config_channel_rf3xxx(struct rt2x00_dev *rt2x00dev,
 			  rt2x00dev->default_ant.tx_chain_num <= 2);
 	rt2800_rfcsr_write(rt2x00dev, 1, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 23, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 23);
 	rt2x00_set_field8(&rfcsr, RFCSR23_FREQ_OFFSET, rt2x00dev->freq_offset);
 	rt2800_rfcsr_write(rt2x00dev, 23, rfcsr);
 
@@ -2220,19 +2229,19 @@ static void rt2800_config_channel_rf3xxx(struct rt2x00_dev *rt2x00dev,
 		}
 	}
 
-	rt2800_rfcsr_read(rt2x00dev, 24, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 24);
 	rt2x00_set_field8(&rfcsr, RFCSR24_TX_CALIB, calib_tx);
 	rt2800_rfcsr_write(rt2x00dev, 24, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 31, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 31);
 	rt2x00_set_field8(&rfcsr, RFCSR31_RX_CALIB, calib_rx);
 	rt2800_rfcsr_write(rt2x00dev, 31, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 7, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 7);
 	rt2x00_set_field8(&rfcsr, RFCSR7_RF_TUNING, 1);
 	rt2800_rfcsr_write(rt2x00dev, 7, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 30, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 30);
 	rt2x00_set_field8(&rfcsr, RFCSR30_RF_CALIBRATION, 1);
 	rt2800_rfcsr_write(rt2x00dev, 30, rfcsr);
 
@@ -2262,7 +2271,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 	rt2800_rfcsr_write(rt2x00dev, 2, rf->rf1);
 	rt2800_rfcsr_write(rt2x00dev, 3, rf->rf3);
 
-	rt2800_rfcsr_read(rt2x00dev, 6, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 6);
 	rt2x00_set_field8(&rfcsr, RFCSR6_R1, rf->rf2);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR6_TXDIV, 2);
@@ -2270,14 +2279,14 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field8(&rfcsr, RFCSR6_TXDIV, 1);
 	rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 5, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 5);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR5_R1, 1);
 	else
 		rt2x00_set_field8(&rfcsr, RFCSR5_R1, 2);
 	rt2800_rfcsr_write(rt2x00dev, 5, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 12, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 12);
 	if (rf->channel <= 14) {
 		rt2x00_set_field8(&rfcsr, RFCSR12_DR0, 3);
 		rt2x00_set_field8(&rfcsr, RFCSR12_TX_POWER,
@@ -2290,7 +2299,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 12, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 13, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 13);
 	if (rf->channel <= 14) {
 		rt2x00_set_field8(&rfcsr, RFCSR13_DR0, 3);
 		rt2x00_set_field8(&rfcsr, RFCSR13_TX_POWER,
@@ -2303,7 +2312,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 13, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX0_PD, 0);
 	rt2x00_set_field8(&rfcsr, RFCSR1_TX0_PD, 0);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX1_PD, 0);
@@ -2336,7 +2345,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 1, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 23, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 23);
 	rt2x00_set_field8(&rfcsr, RFCSR23_FREQ_OFFSET, rt2x00dev->freq_offset);
 	rt2800_rfcsr_write(rt2x00dev, 23, rfcsr);
 
@@ -2366,7 +2375,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 		rt2800_rfcsr_write(rt2x00dev, 27, 0x00);
 		rt2800_rfcsr_write(rt2x00dev, 29, 0x9b);
 	} else {
-		rt2800_rfcsr_read(rt2x00dev, 7, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 7);
 		rt2x00_set_field8(&rfcsr, RFCSR7_BIT2, 1);
 		rt2x00_set_field8(&rfcsr, RFCSR7_BIT3, 0);
 		rt2x00_set_field8(&rfcsr, RFCSR7_BIT4, 1);
@@ -2407,7 +2416,7 @@ static void rt2800_config_channel_rf3052(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field32(&reg, GPIO_CTRL_VAL7, 0);
 	rt2800_register_write(rt2x00dev, GPIO_CTRL, reg);
 
-	rt2800_rfcsr_read(rt2x00dev, 7, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 7);
 	rt2x00_set_field8(&rfcsr, RFCSR7_RF_TUNING, 1);
 	rt2800_rfcsr_write(rt2x00dev, 7, rfcsr);
 }
@@ -2450,11 +2459,11 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	rt2800_rfcsr_write(rt2x00dev, 8, rf->rf1);
 	rt2800_rfcsr_write(rt2x00dev, 9, rf->rf3 & 0xf);
 
-	rt2800_rfcsr_read(rt2x00dev, 11, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 11);
 	rt2x00_set_field8(&rfcsr, RFCSR11_R, (rf->rf2 & 0x3));
 	rt2800_rfcsr_write(rt2x00dev, 11, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 11, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 11);
 	rt2x00_set_field8(&rfcsr, RFCSR11_PLL_IDOH, 1);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR11_PLL_MOD, 1);
@@ -2462,7 +2471,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field8(&rfcsr, RFCSR11_PLL_MOD, 2);
 	rt2800_rfcsr_write(rt2x00dev, 11, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 53, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 53);
 	if (rf->channel <= 14) {
 		rfcsr = 0;
 		rt2x00_set_field8(&rfcsr, RFCSR53_TX_POWER,
@@ -2477,7 +2486,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 53, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 55, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 55);
 	if (rf->channel <= 14) {
 		rfcsr = 0;
 		rt2x00_set_field8(&rfcsr, RFCSR55_TX_POWER,
@@ -2492,7 +2501,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 55, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 54, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 54);
 	if (rf->channel <= 14) {
 		rfcsr = 0;
 		rt2x00_set_field8(&rfcsr, RFCSR54_TX_POWER,
@@ -2507,7 +2516,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 54, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX0_PD, 0);
 	rt2x00_set_field8(&rfcsr, RFCSR1_TX0_PD, 0);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX1_PD, 0);
@@ -2559,7 +2568,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	/* NOTE: the reference driver does not writes the new value
 	 * back to RFCSR 32
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 32, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 32);
 	rt2x00_set_field8(&rfcsr, RFCSR32_TX_AGC_FC, txrx_agc_fc);
 
 	if (rf->channel <= 14)
@@ -2568,34 +2577,34 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 		rfcsr = 0x80;
 	rt2800_rfcsr_write(rt2x00dev, 31, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 30, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 30);
 	rt2x00_set_field8(&rfcsr, RFCSR30_TX_H20M, txrx_h20m);
 	rt2x00_set_field8(&rfcsr, RFCSR30_RX_H20M, txrx_h20m);
 	rt2800_rfcsr_write(rt2x00dev, 30, rfcsr);
 
 	/* Band selection */
-	rt2800_rfcsr_read(rt2x00dev, 36, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 36);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR36_RF_BS, 1);
 	else
 		rt2x00_set_field8(&rfcsr, RFCSR36_RF_BS, 0);
 	rt2800_rfcsr_write(rt2x00dev, 36, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 34, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 34);
 	if (rf->channel <= 14)
 		rfcsr = 0x3c;
 	else
 		rfcsr = 0x20;
 	rt2800_rfcsr_write(rt2x00dev, 34, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 12, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 12);
 	if (rf->channel <= 14)
 		rfcsr = 0x1a;
 	else
 		rfcsr = 0x12;
 	rt2800_rfcsr_write(rt2x00dev, 12, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 6, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 6);
 	if (rf->channel >= 1 && rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR6_VCO_IC, 1);
 	else if (rf->channel >= 36 && rf->channel <= 64)
@@ -2606,7 +2615,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field8(&rfcsr, RFCSR6_VCO_IC, 1);
 	rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 30, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 30);
 	rt2x00_set_field8(&rfcsr, RFCSR30_RX_VCM, 2);
 	rt2800_rfcsr_write(rt2x00dev, 30, rfcsr);
 
@@ -2620,11 +2629,11 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 		rt2800_rfcsr_write(rt2x00dev, 13, 0x23);
 	}
 
-	rt2800_rfcsr_read(rt2x00dev, 51, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 51);
 	rt2x00_set_field8(&rfcsr, RFCSR51_BITS01, 1);
 	rt2800_rfcsr_write(rt2x00dev, 51, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 51, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 51);
 	if (rf->channel <= 14) {
 		rt2x00_set_field8(&rfcsr, RFCSR51_BITS24, 5);
 		rt2x00_set_field8(&rfcsr, RFCSR51_BITS57, 3);
@@ -2634,7 +2643,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	}
 	rt2800_rfcsr_write(rt2x00dev, 51, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 49, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 49);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR49_TX_LO1_IC, 3);
 	else
@@ -2645,11 +2654,11 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 
 	rt2800_rfcsr_write(rt2x00dev, 49, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 50, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 50);
 	rt2x00_set_field8(&rfcsr, RFCSR50_TX_LO1_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 50, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 57, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 57);
 	if (rf->channel <= 14)
 		rt2x00_set_field8(&rfcsr, RFCSR57_DRV_CC, 0x1b);
 	else
@@ -2665,7 +2674,7 @@ static void rt2800_config_channel_rf3053(struct rt2x00_dev *rt2x00dev,
 	}
 
 	/* Initiate VCO calibration */
-	rt2800_rfcsr_read(rt2x00dev, 3, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 3);
 	if (rf->channel <= 14) {
 		rt2x00_set_field8(&rfcsr, RFCSR3_VCOCAL_EN, 1);
 	} else {
@@ -2721,11 +2730,11 @@ static void rt2800_config_channel_rf3290(struct rt2x00_dev *rt2x00dev,
 
 	rt2800_rfcsr_write(rt2x00dev, 8, rf->rf1);
 	rt2800_rfcsr_write(rt2x00dev, 9, rf->rf3);
-	rt2800_rfcsr_read(rt2x00dev, 11, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 11);
 	rt2x00_set_field8(&rfcsr, RFCSR11_R, rf->rf2);
 	rt2800_rfcsr_write(rt2x00dev, 11, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 49, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 49);
 	if (info->default_power1 > POWER_BOUND)
 		rt2x00_set_field8(&rfcsr, RFCSR49_TX, POWER_BOUND);
 	else
@@ -2775,7 +2784,7 @@ static void rt2800_config_channel_rf3322(struct rt2x00_dev *rt2x00dev,
 
 	rt2800_freq_cal_mode1(rt2x00dev);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RX0_PD, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_TX0_PD, 1);
 
@@ -2806,11 +2815,11 @@ static void rt2800_config_channel_rf53xx(struct rt2x00_dev *rt2x00dev,
 
 	rt2800_rfcsr_write(rt2x00dev, 8, rf->rf1);
 	rt2800_rfcsr_write(rt2x00dev, 9, rf->rf3);
-	rt2800_rfcsr_read(rt2x00dev, 11, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 11);
 	rt2x00_set_field8(&rfcsr, RFCSR11_R, rf->rf2);
 	rt2800_rfcsr_write(rt2x00dev, 11, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 49, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 49);
 	if (info->default_power1 > POWER_BOUND)
 		rt2x00_set_field8(&rfcsr, RFCSR49_TX, POWER_BOUND);
 	else
@@ -2818,7 +2827,7 @@ static void rt2800_config_channel_rf53xx(struct rt2x00_dev *rt2x00dev,
 	rt2800_rfcsr_write(rt2x00dev, 49, rfcsr);
 
 	if (rt2x00_rt(rt2x00dev, RT5392)) {
-		rt2800_rfcsr_read(rt2x00dev, 50, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 50);
 		if (info->default_power2 > POWER_BOUND)
 			rt2x00_set_field8(&rfcsr, RFCSR50_TX, POWER_BOUND);
 		else
@@ -2827,7 +2836,7 @@ static void rt2800_config_channel_rf53xx(struct rt2x00_dev *rt2x00dev,
 		rt2800_rfcsr_write(rt2x00dev, 50, rfcsr);
 	}
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	if (rt2x00_rt(rt2x00dev, RT5392)) {
 		rt2x00_set_field8(&rfcsr, RFCSR1_RX1_PD, 1);
 		rt2x00_set_field8(&rfcsr, RFCSR1_TX1_PD, 1);
@@ -2919,13 +2928,13 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 	/* Order of values on rf_channel entry: N, K, mod, R */
 	rt2800_rfcsr_write(rt2x00dev, 8, rf->rf1 & 0xff);
 
-	rt2800_rfcsr_read(rt2x00dev,  9, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev,  9);
 	rt2x00_set_field8(&rfcsr, RFCSR9_K, rf->rf2 & 0xf);
 	rt2x00_set_field8(&rfcsr, RFCSR9_N, (rf->rf1 & 0x100) >> 8);
 	rt2x00_set_field8(&rfcsr, RFCSR9_MOD, ((rf->rf3 - 8) & 0x4) >> 2);
 	rt2800_rfcsr_write(rt2x00dev, 9, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 11, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 11);
 	rt2x00_set_field8(&rfcsr, RFCSR11_R, rf->rf4 - 1);
 	rt2x00_set_field8(&rfcsr, RFCSR11_MOD, (rf->rf3 - 8) & 0x3);
 	rt2800_rfcsr_write(rt2x00dev, 11, rfcsr);
@@ -3093,7 +3102,7 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 		ep_reg = 0x3;
 	}
 
-	rt2800_rfcsr_read(rt2x00dev, 49, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 49);
 	if (info->default_power1 > power_bound)
 		rt2x00_set_field8(&rfcsr, RFCSR49_TX, power_bound);
 	else
@@ -3102,7 +3111,7 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field8(&rfcsr, RFCSR49_EP, ep_reg);
 	rt2800_rfcsr_write(rt2x00dev, 49, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 50, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 50);
 	if (info->default_power2 > power_bound)
 		rt2x00_set_field8(&rfcsr, RFCSR50_TX, power_bound);
 	else
@@ -3111,7 +3120,7 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 		rt2x00_set_field8(&rfcsr, RFCSR50_EP, ep_reg);
 	rt2800_rfcsr_write(rt2x00dev, 50, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RF_BLOCK_EN, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_PLL_PD, 1);
 
@@ -3144,7 +3153,7 @@ static void rt2800_config_channel_rf55xx(struct rt2x00_dev *rt2x00dev,
 	rt2800_freq_cal_mode1(rt2x00dev);
 
 	/* TODO merge with others */
-	rt2800_rfcsr_read(rt2x00dev, 3, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 3);
 	rt2x00_set_field8(&rfcsr, RFCSR3_VCOCAL_EN, 1);
 	rt2800_rfcsr_write(rt2x00dev, 3, rfcsr);
 
@@ -3186,7 +3195,7 @@ static void rt2800_config_channel_rf7620(struct rt2x00_dev *rt2x00dev,
 	/* Rdiv setting (set 0x03 if Xtal==20)
 	 * R13[1:0]
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 13, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 13);
 	rt2x00_set_field8(&rfcsr, RFCSR13_RDIV_MT7620,
 			  rt2800_clk_is_20mhz(rt2x00dev) ? 3 : 0);
 	rt2800_rfcsr_write(rt2x00dev, 13, rfcsr);
@@ -3195,25 +3204,25 @@ static void rt2800_config_channel_rf7620(struct rt2x00_dev *rt2x00dev,
 	 * R20[7:0] in rf->rf1
 	 * R21[0] always 0
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 20, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 20);
 	rfcsr = (rf->rf1 & 0x00ff);
 	rt2800_rfcsr_write(rt2x00dev, 20, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 21, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 21);
 	rt2x00_set_field8(&rfcsr, RFCSR21_BIT1, 0);
 	rt2800_rfcsr_write(rt2x00dev, 21, rfcsr);
 
 	/* K setting (always 0)
 	 * R16[3:0] (RF PLL freq selection)
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 16, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 16);
 	rt2x00_set_field8(&rfcsr, RFCSR16_RF_PLL_FREQ_SEL_MT7620, 0);
 	rt2800_rfcsr_write(rt2x00dev, 16, rfcsr);
 
 	/* D setting (always 0)
 	 * R22[2:0] (D=15, R22[2:0]=<111>)
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 22, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 22);
 	rt2x00_set_field8(&rfcsr, RFCSR22_FREQPLAN_D_MT7620, 0);
 	rt2800_rfcsr_write(rt2x00dev, 22, rfcsr);
 
@@ -3222,40 +3231,40 @@ static void rt2800_config_channel_rf7620(struct rt2x00_dev *rt2x00dev,
 	 *      R18<7:0> in rf->rf3
 	 *      R19<1:0> in rf->rf4
 	 */
-	rt2800_rfcsr_read(rt2x00dev, 17, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 17);
 	rfcsr = rf->rf2;
 	rt2800_rfcsr_write(rt2x00dev, 17, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 18, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 18);
 	rfcsr = rf->rf3;
 	rt2800_rfcsr_write(rt2x00dev, 18, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 19, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 19);
 	rt2x00_set_field8(&rfcsr, RFCSR19_K, rf->rf4);
 	rt2800_rfcsr_write(rt2x00dev, 19, rfcsr);
 
 	/* Default: XO=20MHz , SDM mode */
-	rt2800_rfcsr_read(rt2x00dev, 16, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 16);
 	rt2x00_set_field8(&rfcsr, RFCSR16_SDM_MODE_MT7620, 0x80);
 	rt2800_rfcsr_write(rt2x00dev, 16, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 21, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 21);
 	rt2x00_set_field8(&rfcsr, RFCSR21_BIT8, 1);
 	rt2800_rfcsr_write(rt2x00dev, 21, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_TX2_EN_MT7620,
 			  rt2x00dev->default_ant.tx_chain_num != 1);
 	rt2800_rfcsr_write(rt2x00dev, 1, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 2, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 2);
 	rt2x00_set_field8(&rfcsr, RFCSR2_TX2_EN_MT7620,
 			  rt2x00dev->default_ant.tx_chain_num != 1);
 	rt2x00_set_field8(&rfcsr, RFCSR2_RX2_EN_MT7620,
 			  rt2x00dev->default_ant.rx_chain_num != 1);
 	rt2800_rfcsr_write(rt2x00dev, 2, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 42, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 42);
 	rt2x00_set_field8(&rfcsr, RFCSR42_TX2_EN_MT7620,
 			  rt2x00dev->default_ant.tx_chain_num != 1);
 	rt2800_rfcsr_write(rt2x00dev, 42, rfcsr);
@@ -3283,7 +3292,7 @@ static void rt2800_config_channel_rf7620(struct rt2x00_dev *rt2x00dev,
 		rt2800_rfcsr_write_dccal(rt2x00dev, 59, 0x28);
 	}
 
-	rt2800_rfcsr_read(rt2x00dev, 28, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 28);
 	rt2x00_set_field8(&rfcsr, RFCSR28_CH11_HT40,
 			  conf_is_ht40(conf) && (rf->channel == 11));
 	rt2800_rfcsr_write(rt2x00dev, 28, rfcsr);
@@ -3296,36 +3305,36 @@ static void rt2800_config_channel_rf7620(struct rt2x00_dev *rt2x00dev,
 			rx_agc_fc = drv_data->rx_calibration_bw20;
 			tx_agc_fc = drv_data->tx_calibration_bw20;
 		}
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 6, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 5, 6);
 		rfcsr &= (~0x3F);
 		rfcsr |= rx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 6, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 7, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 5, 7);
 		rfcsr &= (~0x3F);
 		rfcsr |= rx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 7, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 7, 6, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 7, 6);
 		rfcsr &= (~0x3F);
 		rfcsr |= rx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 7, 6, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 7, 7, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 7, 7);
 		rfcsr &= (~0x3F);
 		rfcsr |= rx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 7, 7, rfcsr);
 
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 58, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 5, 58);
 		rfcsr &= (~0x3F);
 		rfcsr |= tx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 58, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 59, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 5, 59);
 		rfcsr &= (~0x3F);
 		rfcsr |= tx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 59, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 7, 58, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 7, 58);
 		rfcsr &= (~0x3F);
 		rfcsr |= tx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 7, 58, rfcsr);
-		rt2800_rfcsr_read_bank(rt2x00dev, 7, 59, &rfcsr);
+		rfcsr = rt2800_rfcsr_read_bank(rt2x00dev, 7, 59);
 		rfcsr &= (~0x3F);
 		rfcsr |= tx_agc_fc;
 		rt2800_rfcsr_write_bank(rt2x00dev, 7, 59, rfcsr);
@@ -3597,7 +3606,7 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 	    rt2x00_rf(rt2x00dev, RF5372) ||
 	    rt2x00_rf(rt2x00dev, RF5390) ||
 	    rt2x00_rf(rt2x00dev, RF5392)) {
-		rt2800_rfcsr_read(rt2x00dev, 30, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 30);
 		if (rt2x00_rf(rt2x00dev, RF3322)) {
 			rt2x00_set_field8(&rfcsr, RF3322_RFCSR30_TX_H20M,
 					  conf_is_ht40(conf));
@@ -3611,7 +3620,7 @@ static void rt2800_config_channel(struct rt2x00_dev *rt2x00dev,
 		}
 		rt2800_rfcsr_write(rt2x00dev, 30, rfcsr);
 
-		rt2800_rfcsr_read(rt2x00dev, 3, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 3);
 		rt2x00_set_field8(&rfcsr, RFCSR3_VCOCAL_EN, 1);
 		rt2800_rfcsr_write(rt2x00dev, 3, rfcsr);
 	}
@@ -4864,7 +4873,7 @@ void rt2800_vco_calibration(struct rt2x00_dev *rt2x00dev)
 	case RF3022:
 	case RF3320:
 	case RF3052:
-		rt2800_rfcsr_read(rt2x00dev, 7, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 7);
 		rt2x00_set_field8(&rfcsr, RFCSR7_RF_TUNING, 1);
 		rt2800_rfcsr_write(rt2x00dev, 7, rfcsr);
 		break;
@@ -4879,7 +4888,7 @@ void rt2800_vco_calibration(struct rt2x00_dev *rt2x00dev)
 	case RF5390:
 	case RF5392:
 	case RF5592:
-		rt2800_rfcsr_read(rt2x00dev, 3, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 3);
 		rt2x00_set_field8(&rfcsr, RFCSR3_VCOCAL_EN, 1);
 		rt2800_rfcsr_write(rt2x00dev, 3, rfcsr);
 		min_sleep = 1000;
@@ -4887,7 +4896,7 @@ void rt2800_vco_calibration(struct rt2x00_dev *rt2x00dev)
 	case RF7620:
 		rt2800_rfcsr_write(rt2x00dev, 5, 0x40);
 		rt2800_rfcsr_write(rt2x00dev, 4, 0x0C);
-		rt2800_rfcsr_read(rt2x00dev, 4, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 4);
 		rt2x00_set_field8(&rfcsr, RFCSR4_VCOCAL_EN, 1);
 		rt2800_rfcsr_write(rt2x00dev, 4, rfcsr);
 		min_sleep = 2000;
@@ -6615,11 +6624,11 @@ static u8 rt2800_init_rx_filter(struct rt2x00_dev *rt2x00dev, bool bw40,
 	rt2x00_set_field8(&bbp, BBP4_BANDWIDTH, 2 * bw40);
 	rt2800_bbp_write(rt2x00dev, 4, bbp);
 
-	rt2800_rfcsr_read(rt2x00dev, 31, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 31);
 	rt2x00_set_field8(&rfcsr, RFCSR31_RX_H20M, bw40);
 	rt2800_rfcsr_write(rt2x00dev, 31, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 22, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 22);
 	rt2x00_set_field8(&rfcsr, RFCSR22_BASEBAND_LOOPBACK, 1);
 	rt2800_rfcsr_write(rt2x00dev, 22, rfcsr);
 
@@ -6668,7 +6677,7 @@ static void rt2800_rf_init_calibration(struct rt2x00_dev *rt2x00dev,
 {
 	u8 rfcsr;
 
-	rt2800_rfcsr_read(rt2x00dev, rf_reg, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, rf_reg);
 	rt2x00_set_field8(&rfcsr, FIELD8(0x80), 1);
 	rt2800_rfcsr_write(rt2x00dev, rf_reg, rfcsr);
 	msleep(1);
@@ -6710,7 +6719,7 @@ static void rt2800_rx_filter_calibration(struct rt2x00_dev *rt2x00dev)
 	 */
 	rt2800_bbp_write(rt2x00dev, 24, 0);
 
-	rt2800_rfcsr_read(rt2x00dev, 22, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 22);
 	rt2x00_set_field8(&rfcsr, RFCSR22_BASEBAND_LOOPBACK, 0);
 	rt2800_rfcsr_write(rt2x00dev, 22, rfcsr);
 
@@ -6728,7 +6737,7 @@ static void rt2800_normal_mode_setup_3xxx(struct rt2x00_dev *rt2x00dev)
 	u8 min_gain, rfcsr, bbp;
 	u16 eeprom;
 
-	rt2800_rfcsr_read(rt2x00dev, 17, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 17);
 
 	rt2x00_set_field8(&rfcsr, RFCSR17_TX_LO1_EN, 0);
 	if (rt2x00_rt(rt2x00dev, RT3070) ||
@@ -6759,7 +6768,7 @@ static void rt2800_normal_mode_setup_3xxx(struct rt2x00_dev *rt2x00dev)
 	}
 
 	if (rt2x00_rt(rt2x00dev, RT3070)) {
-		rt2800_rfcsr_read(rt2x00dev, 27, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 27);
 		if (rt2x00_rt_rev_lt(rt2x00dev, RT3070, REV_RT3070F))
 			rt2x00_set_field8(&rfcsr, RFCSR27_R1, 3);
 		else
@@ -6771,7 +6780,7 @@ static void rt2800_normal_mode_setup_3xxx(struct rt2x00_dev *rt2x00dev)
 	} else if (rt2x00_rt(rt2x00dev, RT3071) ||
 		   rt2x00_rt(rt2x00dev, RT3090) ||
 		   rt2x00_rt(rt2x00dev, RT3390)) {
-		rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 		rt2x00_set_field8(&rfcsr, RFCSR1_RF_BLOCK_EN, 1);
 		rt2x00_set_field8(&rfcsr, RFCSR1_RX0_PD, 0);
 		rt2x00_set_field8(&rfcsr, RFCSR1_TX0_PD, 0);
@@ -6779,15 +6788,15 @@ static void rt2800_normal_mode_setup_3xxx(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field8(&rfcsr, RFCSR1_TX1_PD, 1);
 		rt2800_rfcsr_write(rt2x00dev, 1, rfcsr);
 
-		rt2800_rfcsr_read(rt2x00dev, 15, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 15);
 		rt2x00_set_field8(&rfcsr, RFCSR15_TX_LO2_EN, 0);
 		rt2800_rfcsr_write(rt2x00dev, 15, rfcsr);
 
-		rt2800_rfcsr_read(rt2x00dev, 20, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 20);
 		rt2x00_set_field8(&rfcsr, RFCSR20_RX_LO1_EN, 0);
 		rt2800_rfcsr_write(rt2x00dev, 20, rfcsr);
 
-		rt2800_rfcsr_read(rt2x00dev, 21, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 21);
 		rt2x00_set_field8(&rfcsr, RFCSR21_RX_LO2_EN, 0);
 		rt2800_rfcsr_write(rt2x00dev, 21, rfcsr);
 	}
@@ -6799,30 +6808,30 @@ static void rt2800_normal_mode_setup_3593(struct rt2x00_dev *rt2x00dev)
 	u8 rfcsr;
 	u8 tx_gain;
 
-	rt2800_rfcsr_read(rt2x00dev, 50, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 50);
 	rt2x00_set_field8(&rfcsr, RFCSR50_TX_LO2_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 50, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 51, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 51);
 	tx_gain = rt2x00_get_field8(drv_data->txmixer_gain_24g,
 				    RFCSR17_TXMIXER_GAIN);
 	rt2x00_set_field8(&rfcsr, RFCSR51_BITS24, tx_gain);
 	rt2800_rfcsr_write(rt2x00dev, 51, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 38, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 38);
 	rt2x00_set_field8(&rfcsr, RFCSR38_RX_LO1_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 38, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 39, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 39);
 	rt2x00_set_field8(&rfcsr, RFCSR39_RX_LO2_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 39, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 1, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_RF_BLOCK_EN, 1);
 	rt2x00_set_field8(&rfcsr, RFCSR1_PLL_PD, 1);
 	rt2800_rfcsr_write(rt2x00dev, 1, rfcsr);
 
-	rt2800_rfcsr_read(rt2x00dev, 30, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 30);
 	rt2x00_set_field8(&rfcsr, RFCSR30_RX_VCM, 2);
 	rt2800_rfcsr_write(rt2x00dev, 30, rfcsr);
 
@@ -6843,17 +6852,17 @@ static void rt2800_normal_mode_setup_5xxx(struct rt2x00_dev *rt2x00dev)
 		rt2x00_set_field8(&reg, BBP138_TX_DAC1, 1);
 	rt2800_bbp_write(rt2x00dev, 138, reg);
 
-	rt2800_rfcsr_read(rt2x00dev, 38, &reg);
+	reg = rt2800_rfcsr_read(rt2x00dev, 38);
 	rt2x00_set_field8(&reg, RFCSR38_RX_LO1_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 38, reg);
 
-	rt2800_rfcsr_read(rt2x00dev, 39, &reg);
+	reg = rt2800_rfcsr_read(rt2x00dev, 39);
 	rt2x00_set_field8(&reg, RFCSR39_RX_LO2_EN, 0);
 	rt2800_rfcsr_write(rt2x00dev, 39, reg);
 
 	rt2800_bbp4_mac_if_ctrl(rt2x00dev);
 
-	rt2800_rfcsr_read(rt2x00dev, 30, &reg);
+	reg = rt2800_rfcsr_read(rt2x00dev, 30);
 	rt2x00_set_field8(&reg, RFCSR30_RX_VCM, 2);
 	rt2800_rfcsr_write(rt2x00dev, 30, reg);
 }
@@ -6934,7 +6943,7 @@ static void rt2800_init_rfcsr_30xx(struct rt2x00_dev *rt2x00dev)
 		   rt2x00_rt(rt2x00dev, RT3090)) {
 		rt2800_rfcsr_write(rt2x00dev, 31, 0x14);
 
-		rt2800_rfcsr_read(rt2x00dev, 6, &rfcsr);
+		rfcsr = rt2800_rfcsr_read(rt2x00dev, 6);
 		rt2x00_set_field8(&rfcsr, RFCSR6_R2, 1);
 		rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
@@ -7020,7 +7029,7 @@ static void rt2800_init_rfcsr_3290(struct rt2x00_dev *rt2x00dev)
 	rt2800_rfcsr_write(rt2x00dev, 60, 0x45);
 	rt2800_rfcsr_write(rt2x00dev, 61, 0xc1);
 
-	rt2800_rfcsr_read(rt2x00dev, 29, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 29);
 	rt2x00_set_field8(&rfcsr, RFCSR29_RSSI_GAIN, 3);
 	rt2800_rfcsr_write(rt2x00dev, 29, rfcsr);
 
@@ -7218,7 +7227,7 @@ static void rt2800_init_rfcsr_3572(struct rt2x00_dev *rt2x00dev)
 	rt2800_rfcsr_write(rt2x00dev, 30, 0x09);
 	rt2800_rfcsr_write(rt2x00dev, 31, 0x10);
 
-	rt2800_rfcsr_read(rt2x00dev, 6, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 6);
 	rt2x00_set_field8(&rfcsr, RFCSR6_R2, 1);
 	rt2800_rfcsr_write(rt2x00dev, 6, rfcsr);
 
@@ -7332,13 +7341,13 @@ static void rt2800_init_rfcsr_3593(struct rt2x00_dev *rt2x00dev)
 
 	/* Initiate calibration */
 	/* TODO: use rt2800_rf_init_calibration ? */
-	rt2800_rfcsr_read(rt2x00dev, 2, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 2);
 	rt2x00_set_field8(&rfcsr, RFCSR2_RESCAL_EN, 1);
 	rt2800_rfcsr_write(rt2x00dev, 2, rfcsr);
 
 	rt2800_freq_cal_mode1(rt2x00dev);
 
-	rt2800_rfcsr_read(rt2x00dev, 18, &rfcsr);
+	rfcsr = rt2800_rfcsr_read(rt2x00dev, 18);
 	rt2x00_set_field8(&rfcsr, RFCSR18_XO_TUNE_BYPASS, 1);
 	rt2800_rfcsr_write(rt2x00dev, 18, rfcsr);
 
@@ -7680,7 +7689,7 @@ static int rt2800_rf_lp_config(struct rt2x00_dev *rt2x00dev, bool btxcal)
 
 	rt2800_register_write(rt2x00dev, RF_BYPASS0, 0x06);
 
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 17, &rf_val);
+	rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 17);
 	rf_val |= 0x80;
 	rt2800_rfcsr_write_bank(rt2x00dev, 5, 17, rf_val);
 
@@ -7688,11 +7697,11 @@ static int rt2800_rf_lp_config(struct rt2x00_dev *rt2x00dev, bool btxcal)
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 18, 0xC1);
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 19, 0x20);
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 20, 0x02);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 3, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 3);
 		rf_val &= (~0x3F);
 		rf_val |= 0x3F;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 3, rf_val);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 4, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 4);
 		rf_val &= (~0x3F);
 		rf_val |= 0x3F;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 4, rf_val);
@@ -7701,11 +7710,11 @@ static int rt2800_rf_lp_config(struct rt2x00_dev *rt2x00dev, bool btxcal)
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 18, 0xF1);
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 19, 0x18);
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 20, 0x02);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 3, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 3);
 		rf_val &= (~0x3F);
 		rf_val |= 0x34;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 3, rf_val);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 4, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 4);
 		rf_val &= (~0x3F);
 		rf_val |= 0x34;
 		rt2800_rfcsr_write_bank(rt2x00dev, 5, 4, rf_val);
@@ -7771,51 +7780,51 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 	rt2800_bbp_dcoc_read(rt2x00dev, 2, &savebbp159r2);
 
 	/* Save RF registers */
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 0, &saverfb5r00);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 1, &saverfb5r01);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 3, &saverfb5r03);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 4, &saverfb5r04);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 5, &saverfb5r05);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 6, &saverfb5r06);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 7, &saverfb5r07);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 8, &saverfb5r08);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 17, &saverfb5r17);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 18, &saverfb5r18);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 19, &saverfb5r19);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 20, &saverfb5r20);
-
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 37, &saverfb5r37);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 38, &saverfb5r38);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 39, &saverfb5r39);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 40, &saverfb5r40);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 41, &saverfb5r41);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 42, &saverfb5r42);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 43, &saverfb5r43);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 44, &saverfb5r44);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 45, &saverfb5r45);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 46, &saverfb5r46);
-
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 58, &saverfb5r58);
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 59, &saverfb5r59);
-
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 0, &rf_val);
+	saverfb5r00 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 0);
+	saverfb5r01 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 1);
+	saverfb5r03 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 3);
+	saverfb5r04 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 4);
+	saverfb5r05 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 5);
+	saverfb5r06 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 6);
+	saverfb5r07 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 7);
+	saverfb5r08 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 8);
+	saverfb5r17 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 17);
+	saverfb5r18 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 18);
+	saverfb5r19 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 19);
+	saverfb5r20 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 20);
+
+	saverfb5r37 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 37);
+	saverfb5r38 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 38);
+	saverfb5r39 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 39);
+	saverfb5r40 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 40);
+	saverfb5r41 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 41);
+	saverfb5r42 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 42);
+	saverfb5r43 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 43);
+	saverfb5r44 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 44);
+	saverfb5r45 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 45);
+	saverfb5r46 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 46);
+
+	saverfb5r58 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 58);
+	saverfb5r59 = rt2800_rfcsr_read_bank(rt2x00dev, 5, 59);
+
+	rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 0);
 	rf_val |= 0x3;
 	rt2800_rfcsr_write_bank(rt2x00dev, 5, 0, rf_val);
 
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 1, &rf_val);
+	rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 1);
 	rf_val |= 0x1;
 	rt2800_rfcsr_write_bank(rt2x00dev, 5, 1, rf_val);
 
 	cnt = 0;
 	do {
 		usleep_range(500, 2000);
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 1, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 1);
 		if (((rf_val & 0x1) == 0x00) || (cnt == 40))
 			break;
 		cnt++;
 	} while (cnt < 40);
 
-	rt2800_rfcsr_read_bank(rt2x00dev, 5, 0, &rf_val);
+	rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 0);
 	rf_val &= (~0x3);
 	rf_val |= 0x1;
 	rt2800_rfcsr_write_bank(rt2x00dev, 5, 0, rf_val);
@@ -7844,7 +7853,7 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 				filter_target = rx_filter_target_40m;
 		}
 
-		rt2800_rfcsr_read_bank(rt2x00dev, 5, 8, &rf_val);
+		rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 8);
 		rf_val &= (~0x04);
 		if (loop == 1)
 			rf_val |= 0x4;
@@ -7856,18 +7865,18 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 		rt2800_rf_lp_config(rt2x00dev, btxcal);
 		if (btxcal) {
 			tx_agc_fc = 0;
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 58, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 58);
 			rf_val &= (~0x7F);
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 58, rf_val);
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 59, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 59);
 			rf_val &= (~0x7F);
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 59, rf_val);
 		} else {
 			rx_agc_fc = 0;
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 6, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 6);
 			rf_val &= (~0x7F);
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 6, rf_val);
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 7, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 7);
 			rf_val &= (~0x7F);
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 7, rf_val);
 		}
@@ -7887,20 +7896,20 @@ static void rt2800_bw_filter_calibration(struct rt2x00_dev *rt2x00dev,
 		rt2800_bbp_dcoc_write(rt2x00dev, 2, bbp_val);
 do_cal:
 		if (btxcal) {
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 58, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 58);
 			rf_val &= (~0x7F);
 			rf_val |= tx_agc_fc;
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 58, rf_val);
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 59, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 59);
 			rf_val &= (~0x7F);
 			rf_val |= tx_agc_fc;
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 59, rf_val);
 		} else {
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 6, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 6);
 			rf_val &= (~0x7F);
 			rf_val |= rx_agc_fc;
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 6, rf_val);
-			rt2800_rfcsr_read_bank(rt2x00dev, 5, 7, &rf_val);
+			rf_val = rt2800_rfcsr_read_bank(rt2x00dev, 5, 7);
 			rf_val &= (~0x7F);
 			rf_val |= rx_agc_fc;
 			rt2800_rfcsr_write_bank(rt2x00dev, 5, 7, rf_val);
-- 
2.9.0
