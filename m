From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/12) skge: interrupt coalecsing related fixes
Date: Thu, 3 Mar 2005 11:41:47 -0800
Message-ID: <20050303114147.1bc9ca1b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Avoid overflows (and 64 bit) in tha math for computing interrupt
coalesce values.  Turn on transmit coalescing by default.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-03 10:22:43.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 10:26:58.000000000 -0800
@@ -553,14 +553,27 @@
 	return 0;
 }
 
-static inline u32 skge_freq(const struct skge_hw *hw)
+/* Chip internal frequency for clock calculations */
+static inline u32 hwkhz(const struct skge_hw *hw)
 {
 	if (hw->chip_id == CHIP_ID_GENESIS)
-		return 53215000; /* or:  53.125 MHz */
+		return 53215; /* or:  53.125 MHz */
 	else if (hw->chip_id == CHIP_ID_YUKON_EC)
-		return 125000000; /* or: 125.000 MHz */
+		return 125000; /* or: 125.000 MHz */
 	else
-		return 78215000; /* or:  78.125 MHz */
+		return 78215; /* or:  78.125 MHz */
+}
+
+/* Chip hz to microseconds */
+static inline u32 skge_clk2usec(const struct skge_hw *hw, u32 ticks)
+{
+	return (ticks * 1000) / hwkhz(hw);
+}
+
+/* Microseconds to chip hz */
+static inline u32 skge_usecs2clk(const struct skge_hw *hw, u32 usec)
+{
+	return hwkhz(hw) * usec / 1000;
 }
 
 static int skge_get_coalesce(struct net_device *dev,
@@ -574,14 +587,8 @@
 	ecmd->tx_coalesce_usecs = 0;
 
 	if (skge_read32(hw, B2_IRQM_CTRL) & TIM_START) {
-		u32 msk;
-		u64 delay = skge_read32(hw, B2_IRQM_INI);
-
-		pr_debug("irqm = %lld\n", delay);
-		delay *=  USEC_PER_SEC;
-
-		do_div(delay, skge_freq(hw));
-		msk = skge_read32(hw, B2_IRQM_MSK);
+		u32 delay = skge_clk2usec(hw, skge_read32(hw, B2_IRQM_INI));
+		u32 msk = skge_read32(hw, B2_IRQM_MSK);
 
 		if (msk & rxirqmask[port])
 			ecmd->rx_coalesce_usecs = delay;
@@ -626,10 +633,7 @@
 	if (msk == 0)
 		skge_write32(hw, B2_IRQM_CTRL, TIM_STOP);
 	else {
-		u64 ticks = (u64) delay * skge_freq(hw);
-		pr_debug("ticks * 10^6=%lld\n", ticks);
-		do_div(ticks, USEC_PER_SEC);
-		skge_write32(hw, B2_IRQM_INI, ticks);
+		skge_write32(hw, B2_IRQM_INI, skge_usecs2clk(hw, delay));
 		skge_write32(hw, B2_IRQM_CTRL, TIM_START);
 	}
 	return 0;
@@ -3025,6 +3029,13 @@
 
 	skge_write32(hw, B0_HWE_IMSK, IS_ERR_MSK);
 
+	/* Set interrupt moderation for Transmit only
+	 * Receive interrupts avoided by NAPI
+	 */
+	skge_write32(hw, B2_IRQM_MSK, IS_XA1_F|IS_XA2_F);
+	skge_write32(hw, B2_IRQM_INI, skge_usecs2clk(hw, 100));
+	skge_write32(hw, B2_IRQM_CTRL, TIM_START);
+
 	hw->intr_mask = IS_HW_ERR | IS_EXT_REG | IS_PORT_1;
 	if (isdualport(hw))
 		hw->intr_mask |= IS_PORT_2;
