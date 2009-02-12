From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 13/41]bnx2x: GPIO accessories
Date: Thu, 12 Feb 2009 20:36:52 +0200
Message-ID: <1234463812.1863.145.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2676 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758142AbZBLShM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 13/41]bnx2x: GPIO accessories
A GPIO is used with the 8726 PHY. Adding the GPIO related functions in this

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    2 +
 drivers/net/bnx2x_main.c |   80 ++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/bnx2x_reg.h  |   29 ++++++++++++++++
 3 files changed, 109 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 2397a89..d66be72 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -982,7 +982,9 @@ struct bnx2x {
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 		      u32 len32);
+int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
+int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 9c40b02..95f8e58 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -626,8 +626,8 @@ static void bnx2x_int_enable(struct bnx2x *bp)
 		if (IS_E1HMF(bp)) {
 			val = (0xee0f | (1 << (BP_E1HVN(bp) + 4)));
 			if (bp->port.pmf)
-				/* enable nig attention */
-				val |= 0x0100;
+				/* enable nig and gpio3 attention */
+				val |= 0x1100;
 		} else
 			val = 0xffff;
 
@@ -1836,6 +1836,36 @@ static void bnx2x_release_phy_lock(struct bnx2x *bp)
 	mutex_unlock(&bp->port.phy_mutex);
 }
 
+int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port)
+{
+	/* The GPIO should be swapped if swap register is set and active */
+	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ port;
+	int gpio_shift = gpio_num +
+			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
+	u32 gpio_mask = (1 << gpio_shift);
+	u32 gpio_reg;
+	int value;
+
+	if (gpio_num > MISC_REGISTERS_GPIO_3) {
+		BNX2X_ERR("Invalid GPIO %d\n", gpio_num);
+		return -EINVAL;
+	}
+
+	/* read GPIO value */
+	gpio_reg = REG_RD(bp, MISC_REG_GPIO);
+
+	/* get the requested pin value */
+	if ((gpio_reg & gpio_mask) == gpio_mask)
+		value = 1;
+	else
+		value = 0;
+
+	DP(NETIF_MSG_LINK, "pin %d  value 0x%x\n", gpio_num, value);
+
+	return value;
+}
+
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port)
 {
 	/* The GPIO should be swapped if swap register is set and active */
@@ -1889,6 +1919,52 @@ int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port)
 	return 0;
 }
 
+int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port)
+{
+	/* The GPIO should be swapped if swap register is set and active */
+	int gpio_port = (REG_RD(bp, NIG_REG_PORT_SWAP) &&
+			 REG_RD(bp, NIG_REG_STRAP_OVERRIDE)) ^ port;
+	int gpio_shift = gpio_num +
+			(gpio_port ? MISC_REGISTERS_GPIO_PORT_SHIFT : 0);
+	u32 gpio_mask = (1 << gpio_shift);
+	u32 gpio_reg;
+
+	if (gpio_num > MISC_REGISTERS_GPIO_3) {
+		BNX2X_ERR("Invalid GPIO %d\n", gpio_num);
+		return -EINVAL;
+	}
+
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
+	/* read GPIO int */
+	gpio_reg = REG_RD(bp, MISC_REG_GPIO_INT);
+
+	switch (mode) {
+	case MISC_REGISTERS_GPIO_INT_OUTPUT_CLR:
+		DP(NETIF_MSG_LINK, "Clear GPIO INT %d (shift %d) -> "
+				   "output low\n", gpio_num, gpio_shift);
+		/* clear SET and set CLR */
+		gpio_reg &= ~(gpio_mask << MISC_REGISTERS_GPIO_INT_SET_POS);
+		gpio_reg |=  (gpio_mask << MISC_REGISTERS_GPIO_INT_CLR_POS);
+		break;
+
+	case MISC_REGISTERS_GPIO_INT_OUTPUT_SET:
+		DP(NETIF_MSG_LINK, "Set GPIO INT %d (shift %d) -> "
+				   "output high\n", gpio_num, gpio_shift);
+		/* clear CLR and set SET */
+		gpio_reg &= ~(gpio_mask << MISC_REGISTERS_GPIO_INT_CLR_POS);
+		gpio_reg |=  (gpio_mask << MISC_REGISTERS_GPIO_INT_SET_POS);
+		break;
+
+	default:
+		break;
+	}
+
+	REG_WR(bp, MISC_REG_GPIO_INT, gpio_reg);
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_GPIO);
+
+	return 0;
+}
+
 static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 {
 	u32 spio_mask = (1 << spio_num);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 713b5f9..6fc1d0d 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -1438,6 +1438,29 @@
    This is the result value of the pin; not the drive value. Writing these
    bits will have not effect. */
 #define MISC_REG_GPIO						 0xa490
+/* [RW 8] These bits enable the GPIO_INTs to signals event to the
+   IGU/MCP.according to the following map: [0] p0_gpio_0; [1] p0_gpio_1; [2]
+   p0_gpio_2; [3] p0_gpio_3; [4] p1_gpio_0; [5] p1_gpio_1; [6] p1_gpio_2;
+   [7] p1_gpio_3; */
+#define MISC_REG_GPIO_EVENT_EN					 0xa2bc
+/* [RW 32] GPIO INT. [31-28] OLD_CLR port1; [27-24] OLD_CLR port0; Writing a
+   '1' to these bit clears the corresponding bit in the #OLD_VALUE register.
+   This will acknowledge an interrupt on the falling edge of corresponding
+   GPIO input (reset value 0). [23-16] OLD_SET [23-16] port1; OLD_SET port0;
+   Writing a '1' to these bit sets the corresponding bit in the #OLD_VALUE
+   register. This will acknowledge an interrupt on the rising edge of
+   corresponding SPIO input (reset value 0). [15-12] OLD_VALUE [11-8] port1;
+   OLD_VALUE port0; RO; These bits indicate the old value of the GPIO input
+   value. When the ~INT_STATE bit is set; this bit indicates the OLD value
+   of the pin such that if ~INT_STATE is set and this bit is '0'; then the
+   interrupt is due to a low to high edge. If ~INT_STATE is set and this bit
+   is '1'; then the interrupt is due to a high to low edge (reset value 0).
+   [7-4] INT_STATE port1; [3-0] INT_STATE RO port0; These bits indicate the
+   current GPIO interrupt state for each GPIO pin. This bit is cleared when
+   the appropriate #OLD_SET or #OLD_CLR command bit is written. This bit is
+   set when the GPIO input does not match the current value in #OLD_VALUE
+   (reset value 0). */
+#define MISC_REG_GPIO_INT					 0xa494
 /* [R 28] this field hold the last information that caused reserved
    attention. bits [19:0] - address; [22:20] function; [23] reserved;
    [27:24] the master that caused the attention - according to the following
@@ -5162,6 +5185,10 @@
 #define MISC_REGISTERS_GPIO_FLOAT_POS				 24
 #define MISC_REGISTERS_GPIO_HIGH				 1
 #define MISC_REGISTERS_GPIO_INPUT_HI_Z				 2
+#define MISC_REGISTERS_GPIO_INT_CLR_POS 			 24
+#define MISC_REGISTERS_GPIO_INT_OUTPUT_CLR			 0
+#define MISC_REGISTERS_GPIO_INT_OUTPUT_SET			 1
+#define MISC_REGISTERS_GPIO_INT_SET_POS 			 16
 #define MISC_REGISTERS_GPIO_LOW 				 0
 #define MISC_REGISTERS_GPIO_OUTPUT_HIGH 			 1
 #define MISC_REGISTERS_GPIO_OUTPUT_LOW				 0
@@ -5220,6 +5247,8 @@
 #define AEU_INPUTS_ATTN_BITS_DMAE_HW_INTERRUPT		      (1<<11)
 #define AEU_INPUTS_ATTN_BITS_DOORBELLQ_HW_INTERRUPT	      (1<<13)
 #define AEU_INPUTS_ATTN_BITS_DOORBELLQ_PARITY_ERROR	      (1<<12)
+#define AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0		      (1<<5)
+#define AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1		      (1<<9)
 #define AEU_INPUTS_ATTN_BITS_IGU_PARITY_ERROR		      (1<<12)
 #define AEU_INPUTS_ATTN_BITS_MISC_HW_INTERRUPT		      (1<<15)
 #define AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR		      (1<<14)
-- 
1.5.4.3




