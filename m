From: jon@ringle.org
Subject: [PATCH net-next v3 2/2] net: Microchip encx24j600 driver
Date: Thu,  1 Oct 2015 12:38:08 -0400
Message-ID: <1443717488-16533-2-git-send-email-jon@ringle.org>
References: <1443717488-16533-1-git-send-email-jon@ringle.org>
Cc: Jon Ringle <jringle@gridpoint.com>
To: broonie@kernel.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34727 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966AbbJAQiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 12:38:20 -0400
In-Reply-To: <1443717488-16533-1-git-send-email-jon@ringle.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Ringle <jringle@gridpoint.com>

This ethernet driver supports the Micorchip enc424j600/626j600 Ethernet
controller over a SPI bus interface. This driver makes use of the regmap API to
optimize access to registers by caching registers where possible.

Datasheet:
http://ww1.microchip.com/downloads/en/DeviceDoc/39935b.pdf

Signed-off-by: Jon Ringle <jringle@gridpoint.com>
---

Fixed several issues reported by kbuild bots and simplified the implementation
of regmap_encx24j600_reg_update_bits() based on changes to _regmap_update_bits

Jon

 drivers/net/ethernet/microchip/Kconfig             |    9 +
 drivers/net/ethernet/microchip/Makefile            |    1 +
 drivers/net/ethernet/microchip/encx24j600-regmap.c |  513 +++++++++
 drivers/net/ethernet/microchip/encx24j600.c        | 1124 ++++++++++++++++++++
 drivers/net/ethernet/microchip/encx24j600_hw.h     |  437 ++++++++
 5 files changed, 2084 insertions(+)
 create mode 100644 drivers/net/ethernet/microchip/encx24j600-regmap.c
 create mode 100644 drivers/net/ethernet/microchip/encx24j600.c
 create mode 100644 drivers/net/ethernet/microchip/encx24j600_hw.h

diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
index afaf0c0..b45b28a 100644
--- a/drivers/net/ethernet/microchip/Kconfig
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -35,4 +35,13 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
+config ENCX24J600
+    tristate "ENCX24J600 support"
+    depends on SPI
+    ---help---
+      Support for the Microchip ENC424J600 ethernet chip.
+
+      To compile this driver as a module, choose M here. The module will be
+      called enc424j600.
+
 endif # NET_VENDOR_MICROCHIP
diff --git a/drivers/net/ethernet/microchip/Makefile b/drivers/net/ethernet/microchip/Makefile
index 573d429..ff78f62 100644
--- a/drivers/net/ethernet/microchip/Makefile
+++ b/drivers/net/ethernet/microchip/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_ENC28J60) += enc28j60.o
+obj-$(CONFIG_ENCX24J600) += encx24j600.o encx24j600-regmap.o
diff --git a/drivers/net/ethernet/microchip/encx24j600-regmap.c b/drivers/net/ethernet/microchip/encx24j600-regmap.c
new file mode 100644
index 0000000..f3bb905
--- /dev/null
+++ b/drivers/net/ethernet/microchip/encx24j600-regmap.c
@@ -0,0 +1,513 @@
+/**
+ * Register map access API - ENCX24J600 support
+ *
+ * Copyright 2015 Gridpoint
+ *
+ * Author: Jon Ringle <jringle@gridpoint.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/regmap.h>
+#include <linux/spi/spi.h>
+
+#include "encx24j600_hw.h"
+
+static inline bool is_bits_set(int value, int mask)
+{
+	return (value & mask) == mask;
+}
+
+static int encx24j600_switch_bank(struct encx24j600_context *ctx,
+					 int bank)
+{
+	int ret = 0;
+
+	int bank_opcode = BANK_SELECT(bank);
+	ret = spi_write(ctx->spi, &bank_opcode, 1);
+	if (ret == 0)
+		ctx->bank = bank;
+
+	return ret;
+}
+
+static int encx24j600_cmdn(struct encx24j600_context *ctx, u8 opcode,
+			    const void *buf, size_t len)
+{
+	struct spi_message m;
+	struct spi_transfer t[2] = { { .tx_buf = &opcode, .len = 1, },
+				     { .tx_buf = buf, .len = len }, };
+	spi_message_init(&m);
+	spi_message_add_tail(&t[0], &m);
+	spi_message_add_tail(&t[1], &m);
+
+	return spi_sync(ctx->spi, &m);
+}
+
+static void regmap_lock_mutex(void *context)
+{
+	struct encx24j600_context *ctx = context;
+	mutex_lock(&ctx->mutex);
+}
+
+static void regmap_unlock_mutex(void *context)
+{
+	struct encx24j600_context *ctx = context;
+	mutex_unlock(&ctx->mutex);
+}
+
+static int regmap_encx24j600_sfr_read(void *context, u8 reg, u8 *val,
+				      size_t len)
+{
+	struct encx24j600_context *ctx = context;
+	u8 banked_reg = reg & ADDR_MASK;
+	u8 bank = ((reg & BANK_MASK) >> BANK_SHIFT);
+	u8 cmd = RCRU;
+	int ret = 0;
+	int i = 0;
+	u8 tx_buf[2];
+
+	if (reg < 0x80) {
+		cmd = RCRCODE | banked_reg;
+		if ((banked_reg < 0x16) && (ctx->bank != bank))
+			ret = encx24j600_switch_bank(ctx, bank);
+		if (unlikely(ret))
+			return ret;
+	} else {
+		/* Translate registers that are more effecient using
+		 * 3-byte SPI commands
+		 */
+		switch (reg) {
+		case EGPRDPT:
+			cmd = RGPRDPT; break;
+		case EGPWRPT:
+			cmd = RGPWRPT; break;
+		case ERXRDPT:
+			cmd = RRXRDPT; break;
+		case ERXWRPT:
+			cmd = RRXWRPT; break;
+		case EUDARDPT:
+			cmd = RUDARDPT; break;
+		case EUDAWRPT:
+			cmd = RUDAWRPT; break;
+		case EGPDATA:
+		case ERXDATA:
+		case EUDADATA:
+		default:
+			return -EINVAL;
+		}
+	}
+
+	tx_buf[i++] = cmd;
+	if (cmd == RCRU)
+		tx_buf[i++] = reg;
+
+	ret = spi_write_then_read(ctx->spi, tx_buf, i, val, len);
+
+	return ret;
+}
+
+static int regmap_encx24j600_sfr_update(struct encx24j600_context *ctx,
+					u8 reg, u8 *val, size_t len,
+					u8 unbanked_cmd, u8 banked_code)
+{
+	u8 banked_reg = reg & ADDR_MASK;
+	u8 bank = ((reg & BANK_MASK) >> BANK_SHIFT);
+	u8 cmd = unbanked_cmd;
+	struct spi_message m;
+	struct spi_transfer t[3] = { { .tx_buf = &cmd, .len = sizeof(cmd), },
+				     { .tx_buf = &reg, .len = sizeof(reg), },
+				     { .tx_buf = val, .len = len }, };
+
+	if (reg < 0x80) {
+		int ret = 0;
+		cmd = banked_code | banked_reg;
+		if ((banked_reg < 0x16) && (ctx->bank != bank))
+			ret = encx24j600_switch_bank(ctx, bank);
+		if (unlikely(ret))
+			return ret;
+	} else {
+		/* Translate registers that are more effecient using
+		 * 3-byte SPI commands
+		 */
+		switch (reg) {
+		case EGPRDPT:
+			cmd = WGPRDPT; break;
+		case EGPWRPT:
+			cmd = WGPWRPT; break;
+		case ERXRDPT:
+			cmd = WRXRDPT; break;
+		case ERXWRPT:
+			cmd = WRXWRPT; break;
+		case EUDARDPT:
+			cmd = WUDARDPT; break;
+		case EUDAWRPT:
+			cmd = WUDAWRPT; break;
+		case EGPDATA:
+		case ERXDATA:
+		case EUDADATA:
+		default:
+			return -EINVAL;
+		}
+	}
+
+	spi_message_init(&m);
+	spi_message_add_tail(&t[0], &m);
+
+	if (cmd == unbanked_cmd) {
+		t[1].tx_buf = &reg;
+		spi_message_add_tail(&t[1], &m);
+	}
+
+	spi_message_add_tail(&t[2], &m);
+	return spi_sync(ctx->spi, &m);
+}
+
+static int regmap_encx24j600_sfr_write(void *context, u8 reg, u8 *val,
+				       size_t len)
+{
+	struct encx24j600_context *ctx = context;
+	return regmap_encx24j600_sfr_update(ctx, reg, val, len, WCRU, WCRCODE);
+}
+
+static int regmap_encx24j600_sfr_set_bits(struct encx24j600_context *ctx,
+					  u8 reg, u8 val)
+{
+	return regmap_encx24j600_sfr_update(ctx, reg, &val, 1, BFSU, BFSCODE);
+}
+
+static int regmap_encx24j600_sfr_clr_bits(struct encx24j600_context *ctx,
+					  u8 reg, u8 val)
+{
+	return regmap_encx24j600_sfr_update(ctx, reg, &val, 1, BFCU, BFCCODE);
+}
+
+static int regmap_encx24j600_reg_update_bits(void *context, unsigned int reg,
+					     unsigned int mask,
+					     unsigned int val)
+{
+	struct encx24j600_context *ctx = context;
+
+	int ret = 0;
+	unsigned int set_mask = mask & val;
+	unsigned int clr_mask = mask & ~val;
+
+	if ((reg >= 0x40 && reg < 0x6c) || reg >= 0x80)
+		return -EINVAL;
+
+	if (set_mask & 0xff)
+		ret = regmap_encx24j600_sfr_set_bits(ctx, reg, set_mask);
+
+	set_mask = (set_mask & 0xff00) >> 8;
+
+	if ((set_mask & 0xff) && (ret == 0))
+		ret = regmap_encx24j600_sfr_set_bits(ctx, reg + 1, set_mask);
+
+	if ((clr_mask & 0xff) && (ret == 0))
+		ret = regmap_encx24j600_sfr_clr_bits(ctx, reg, clr_mask);
+
+	clr_mask = (clr_mask & 0xff00) >> 8;
+
+	if ((clr_mask & 0xff) && (ret == 0))
+		ret = regmap_encx24j600_sfr_clr_bits(ctx, reg + 1, clr_mask);
+
+	return ret;
+}
+
+int regmap_encx24j600_spi_write(void *context, u8 reg, const u8 *data,
+				size_t count)
+{
+	struct encx24j600_context *ctx = context;
+
+	if (reg < 0xc0)
+		return encx24j600_cmdn(ctx, reg, data, count);
+	else
+		/* SPI 1-byte command. Ignore data */
+		return spi_write(ctx->spi, &reg, 1);
+}
+EXPORT_SYMBOL_GPL(regmap_encx24j600_spi_write);
+
+int regmap_encx24j600_spi_read(void *context, u8 reg, u8 *data, size_t count)
+{
+	struct encx24j600_context *ctx = context;
+
+	if (reg == RBSEL && count > 1)
+		count = 1;
+
+	return spi_write_then_read(ctx->spi, &reg, sizeof(reg), data, count);
+}
+EXPORT_SYMBOL_GPL(regmap_encx24j600_spi_read);
+
+static int regmap_encx24j600_write(void *context, const void *data,
+				   size_t len)
+{
+	u8 *dout = (u8 *)data;
+	u8 reg = dout[0];
+	++dout;
+	--len;
+
+	if (reg > 0xa0)
+		return regmap_encx24j600_spi_write(context, reg, dout, len);
+
+	if (len > 2)
+		return -EINVAL;
+
+	return regmap_encx24j600_sfr_write(context, reg, dout, len);
+}
+
+static int regmap_encx24j600_read(void *context,
+				  const void *reg_buf, size_t reg_size,
+				  void *val, size_t val_size)
+{
+	u8 reg = *(const u8 *)reg_buf;
+
+	if (reg_size != 1) {
+		pr_err("%s: reg=%02x reg_size=%zu\n", __func__, reg, reg_size);
+		return -EINVAL;
+	}
+
+	if (reg > 0xa0)
+		return regmap_encx24j600_spi_read(context, reg, val, val_size);
+
+	if (val_size > 2) {
+		pr_err("%s: reg=%02x val_size=%zu\n", __func__, reg, val_size);
+		return -EINVAL;
+	}
+
+	return regmap_encx24j600_sfr_read(context, reg, val, val_size);
+}
+
+static bool encx24j600_regmap_readable(struct device *dev, unsigned int reg)
+{
+	if ((reg < 0x36) ||
+	    ((reg >= 0x40) && (reg < 0x4c)) ||
+	    ((reg >= 0x52) && (reg < 0x56)) ||
+	    ((reg >= 0x60) && (reg < 0x66)) ||
+	    ((reg >= 0x68) && (reg < 0x80)) ||
+	    ((reg >= 0x86) && (reg < 0x92)) ||
+	    (reg == 0xc8))
+		return true;
+	else
+		return false;
+}
+
+static bool encx24j600_regmap_writeable(struct device *dev, unsigned int reg)
+{
+	if ((reg < 0x12) ||
+	    ((reg >= 0x14) && (reg < 0x1a)) ||
+	    ((reg >= 0x1c) && (reg < 0x36)) ||
+	    ((reg >= 0x40) && (reg < 0x4c)) ||
+	    ((reg >= 0x52) && (reg < 0x56)) ||
+	    ((reg >= 0x60) && (reg < 0x68)) ||
+	    ((reg >= 0x6c) && (reg < 0x80)) ||
+	    ((reg >= 0x86) && (reg < 0x92)) ||
+	    ((reg >= 0xc0) && (reg < 0xc8)) ||
+	    ((reg >= 0xca) && (reg < 0xf0)))
+		return true;
+	else
+		return false;
+}
+
+static bool encx24j600_regmap_volatile(struct device *dev, unsigned int reg)
+{
+	switch (reg) {
+	case ERXHEAD:
+	case EDMACS:
+	case ETXSTAT:
+	case ETXWIRE:
+	case ECON1:	/* Can be modified via single byte cmds */
+	case ECON2:	/* Can be modified via single byte cmds */
+	case ESTAT:
+	case EIR:	/* Can be modified via single byte cmds */
+	case MIRD:
+	case MISTAT:
+		return true;
+	default:
+		break;
+	}
+
+	return false;
+}
+
+static bool encx24j600_regmap_precious(struct device *dev, unsigned int reg)
+{
+	/* single byte cmds are precious */
+	if (((reg >= 0xc0) && (reg < 0xc8)) ||
+	    ((reg >= 0xca) && (reg < 0xf0)))
+		return true;
+	else
+		return false;
+}
+
+static int regmap_encx24j600_phy_reg_read(void *context, unsigned int reg,
+					  unsigned int *val)
+{
+	struct encx24j600_context *ctx = context;
+	int ret;
+	unsigned int mistat;
+
+	reg = MIREGADR_VAL | (reg & PHREG_MASK);
+	ret = regmap_write(ctx->regmap, MIREGADR, reg);
+	if (unlikely(ret))
+		goto err_out;
+
+	ret = regmap_write(ctx->regmap, MICMD, MIIRD);
+	if (unlikely(ret))
+		goto err_out;
+
+	usleep_range(26, 100);
+	while ((ret = regmap_read(ctx->regmap, MISTAT, &mistat) != 0) &&
+	       (mistat & BUSY))
+		cpu_relax();
+
+	if (unlikely(ret))
+		goto err_out;
+
+	ret = regmap_write(ctx->regmap, MICMD, 0);
+	if (unlikely(ret))
+		goto err_out;
+
+	ret = regmap_read(ctx->regmap, MIRD, val);
+
+err_out:
+	if (ret)
+		pr_err("%s: error %d reading reg %02x\n", __func__, ret,
+		       reg & PHREG_MASK);
+
+	return ret;
+}
+
+static int regmap_encx24j600_phy_reg_write(void *context, unsigned int reg,
+					   unsigned int val)
+{
+	struct encx24j600_context *ctx = context;
+	int ret;
+	unsigned int mistat;
+
+	reg = MIREGADR_VAL | (reg & PHREG_MASK);
+	ret = regmap_write(ctx->regmap, MIREGADR, reg);
+	if (unlikely(ret))
+		goto err_out;
+
+	ret = regmap_write(ctx->regmap, MIWR, val);
+	if (unlikely(ret))
+		goto err_out;
+
+	usleep_range(26, 100);
+	while ((ret = regmap_read(ctx->regmap, MISTAT, &mistat) != 0) &&
+	       (mistat & BUSY))
+		cpu_relax();
+
+err_out:
+	if (ret)
+		pr_err("%s: error %d writing reg %02x=%04x\n", __func__, ret,
+		       reg & PHREG_MASK, val);
+
+	return ret;
+}
+
+static bool encx24j600_phymap_readable(struct device *dev, unsigned int reg)
+{
+	switch (reg) {
+	case PHCON1:
+	case PHSTAT1:
+	case PHANA:
+	case PHANLPA:
+	case PHANE:
+	case PHCON2:
+	case PHSTAT2:
+	case PHSTAT3:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool encx24j600_phymap_writeable(struct device *dev, unsigned int reg)
+{
+	switch (reg) {
+	case PHCON1:
+	case PHCON2:
+	case PHANA:
+		return true;
+	case PHSTAT1:
+	case PHSTAT2:
+	case PHSTAT3:
+	case PHANLPA:
+	case PHANE:
+	default:
+		return false;
+	}
+}
+
+static bool encx24j600_phymap_volatile(struct device *dev, unsigned int reg)
+{
+	switch (reg) {
+	case PHSTAT1:
+	case PHSTAT2:
+	case PHSTAT3:
+	case PHANLPA:
+	case PHANE:
+	case PHCON2:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static struct regmap_config regcfg = {
+	.name = "reg",
+	.reg_bits = 8,
+	.val_bits = 16,
+	.max_register = 0xee,
+	.reg_stride = 2,
+	.cache_type = REGCACHE_RBTREE,
+	.val_format_endian = REGMAP_ENDIAN_LITTLE,
+	.readable_reg = encx24j600_regmap_readable,
+	.writeable_reg = encx24j600_regmap_writeable,
+	.volatile_reg = encx24j600_regmap_volatile,
+	.precious_reg = encx24j600_regmap_precious,
+	.lock = regmap_lock_mutex,
+	.unlock = regmap_unlock_mutex,
+};
+
+static struct regmap_bus regmap_encx24j600 = {
+	.write = regmap_encx24j600_write,
+	.read = regmap_encx24j600_read,
+	.reg_update_bits = regmap_encx24j600_reg_update_bits,
+};
+
+static struct regmap_config phycfg = {
+	.name = "phy",
+	.reg_bits = 8,
+	.val_bits = 16,
+	.max_register = 0x1f,
+	.cache_type = REGCACHE_RBTREE,
+	.val_format_endian = REGMAP_ENDIAN_LITTLE,
+	.readable_reg = encx24j600_phymap_readable,
+	.writeable_reg = encx24j600_phymap_writeable,
+	.volatile_reg = encx24j600_phymap_volatile,
+};
+static struct regmap_bus phymap_encx24j600 = {
+	.reg_write = regmap_encx24j600_phy_reg_write,
+	.reg_read = regmap_encx24j600_phy_reg_read,
+};
+
+void devm_regmap_init_encx24j600(struct device *dev,
+				 struct encx24j600_context *ctx)
+{
+	mutex_init(&ctx->mutex);
+	regcfg.lock_arg = ctx;
+	ctx->regmap = devm_regmap_init(dev, &regmap_encx24j600, ctx, &regcfg);
+	ctx->phymap = devm_regmap_init(dev, &phymap_encx24j600, ctx, &phycfg);
+}
+EXPORT_SYMBOL_GPL(devm_regmap_init_encx24j600);
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/microchip/encx24j600.c b/drivers/net/ethernet/microchip/encx24j600.c
new file mode 100644
index 0000000..afc008a
--- /dev/null
+++ b/drivers/net/ethernet/microchip/encx24j600.c
@@ -0,0 +1,1124 @@
+/**
+ * Microchip ENCX24J600 ethernet driver
+ *
+ * Copyright (C) 2015 Gridpoint
+ * Author: Jon Ringle <jringle@gridpoint.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ */
+
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/interrupt.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/regmap.h>
+#include <linux/skbuff.h>
+#include <linux/spi/spi.h>
+
+#include "encx24j600_hw.h"
+
+#define DRV_NAME	"encx24j600"
+#define DRV_VERSION	"1.0"
+
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
+/* SRAM memory layout:
+ *
+ * 0x0000-0x05ff TX buffers  1.5KB  (1*1536) reside in the GP area in SRAM
+ * 0x0600-0x5fff RX buffers 22.5KB (15*1536) reside in the RX area in SRAM
+ */
+#define ENC_TX_BUF_START 0x0000U
+#define ENC_RX_BUF_START 0x0600U
+#define ENC_RX_BUF_END   0x5fffU
+#define ENC_SRAM_SIZE    0x6000U
+
+enum {
+	RXFILTER_NORMAL,
+	RXFILTER_MULTI,
+	RXFILTER_PROMISC
+};
+
+struct encx24j600_priv {
+	struct net_device        *ndev;
+	struct mutex              lock; /* device access lock */
+	struct encx24j600_context ctx;
+	struct sk_buff           *tx_skb;
+	struct task_struct       *kworker_task;
+	struct kthread_worker     kworker;
+	struct kthread_work       tx_work;
+	struct kthread_work       setrx_work;
+	u16                       next_packet;
+	bool                      hw_enabled;
+	bool                      full_duplex;
+	bool                      autoneg;
+	u16                       speed;
+	int                       rxfilter;
+	u32                       msg_enable;
+};
+
+static void dump_packet(const char *msg, int len, const char *data)
+{
+	pr_debug(DRV_NAME ": %s - packet len:%d\n", msg, len);
+	print_hex_dump_bytes("pk data: ", DUMP_PREFIX_OFFSET, data, len);
+}
+
+static void encx24j600_dump_rsv(struct encx24j600_priv *priv, const char *msg,
+				struct rsv *rsv)
+{
+	struct net_device *dev = priv->ndev;
+
+	netdev_info(dev, "RX packet Len:%d\n", rsv->len);
+	netdev_dbg(dev, "%s - NextPk: 0x%04x\n", msg,
+		   rsv->next_packet);
+	netdev_dbg(dev, "RxOK: %d, DribbleNibble: %d\n",
+		   RSV_GETBIT(rsv->rxstat, RSV_RXOK),
+		   RSV_GETBIT(rsv->rxstat, RSV_DRIBBLENIBBLE));
+	netdev_dbg(dev, "CRCErr:%d, LenChkErr: %d, LenOutOfRange: %d\n",
+		   RSV_GETBIT(rsv->rxstat, RSV_CRCERROR),
+		   RSV_GETBIT(rsv->rxstat, RSV_LENCHECKERR),
+		   RSV_GETBIT(rsv->rxstat, RSV_LENOUTOFRANGE));
+	netdev_dbg(dev, "Multicast: %d, Broadcast: %d, LongDropEvent: %d, CarrierEvent: %d\n",
+		   RSV_GETBIT(rsv->rxstat, RSV_RXMULTICAST),
+		   RSV_GETBIT(rsv->rxstat, RSV_RXBROADCAST),
+		   RSV_GETBIT(rsv->rxstat, RSV_RXLONGEVDROPEV),
+		   RSV_GETBIT(rsv->rxstat, RSV_CARRIEREV));
+	netdev_dbg(dev, "ControlFrame: %d, PauseFrame: %d, UnknownOp: %d, VLanTagFrame: %d\n",
+		   RSV_GETBIT(rsv->rxstat, RSV_RXCONTROLFRAME),
+		   RSV_GETBIT(rsv->rxstat, RSV_RXPAUSEFRAME),
+		   RSV_GETBIT(rsv->rxstat, RSV_RXUNKNOWNOPCODE),
+		   RSV_GETBIT(rsv->rxstat, RSV_RXTYPEVLAN));
+}
+
+static u16 encx24j600_read_reg(struct encx24j600_priv *priv, u8 reg)
+{
+	struct net_device *dev = priv->ndev;
+	unsigned int val = 0;
+	int ret = regmap_read(priv->ctx.regmap, reg, &val);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d reading reg %02x\n",
+			  __func__, ret, reg);
+	return val;
+}
+
+static void encx24j600_write_reg(struct encx24j600_priv *priv, u8 reg, u16 val)
+{
+	struct net_device *dev = priv->ndev;
+	int ret = regmap_write(priv->ctx.regmap, reg, val);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d writing reg %02x=%04x\n",
+			  __func__, ret, reg, val);
+}
+
+static void encx24j600_update_reg(struct encx24j600_priv *priv, u8 reg,
+				  u16 mask, u16 val)
+{
+	struct net_device *dev = priv->ndev;
+	int ret = regmap_update_bits(priv->ctx.regmap, reg, mask, val);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d updating reg %02x=%04x~%04x\n",
+			  __func__, ret, reg, val, mask);
+}
+
+static u16 encx24j600_read_phy(struct encx24j600_priv *priv, u8 reg)
+{
+	struct net_device *dev = priv->ndev;
+	unsigned int val = 0;
+	int ret = regmap_read(priv->ctx.phymap, reg, &val);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d reading %02x\n",
+			  __func__, ret, reg);
+	return val;
+}
+
+static void encx24j600_write_phy(struct encx24j600_priv *priv, u8 reg, u16 val)
+{
+	struct net_device *dev = priv->ndev;
+	int ret = regmap_write(priv->ctx.phymap, reg, val);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d writing reg %02x=%04x\n",
+			  __func__, ret, reg, val);
+}
+
+static void encx24j600_clr_bits(struct encx24j600_priv *priv, u8 reg, u16 mask)
+{
+	encx24j600_update_reg(priv, reg, mask, 0);
+}
+
+static void encx24j600_set_bits(struct encx24j600_priv *priv, u8 reg, u16 mask)
+{
+	encx24j600_update_reg(priv, reg, mask, mask);
+}
+
+static void encx24j600_cmd(struct encx24j600_priv *priv, u8 cmd)
+{
+	struct net_device *dev = priv->ndev;
+	int ret = regmap_write(priv->ctx.regmap, cmd, 0);
+	if (unlikely(ret))
+		netif_err(priv, drv, dev, "%s: error %d with cmd %02x\n",
+			  __func__, ret, cmd);
+}
+
+static int encx24j600_raw_read(struct encx24j600_priv *priv, u8 reg, u8 *data,
+			       size_t count)
+{
+	int ret;
+	mutex_lock(&priv->ctx.mutex);
+	ret = regmap_encx24j600_spi_read(&priv->ctx, reg, data, count);
+	mutex_unlock(&priv->ctx.mutex);
+
+	return ret;
+}
+
+static int encx24j600_raw_write(struct encx24j600_priv *priv, u8 reg,
+				const u8 *data, size_t count)
+{
+	int ret;
+	mutex_lock(&priv->ctx.mutex);
+	ret = regmap_encx24j600_spi_write(&priv->ctx, reg, data, count);
+	mutex_unlock(&priv->ctx.mutex);
+
+	return ret;
+}
+
+static void encx24j600_update_phcon1(struct encx24j600_priv *priv)
+{
+	u16 phcon1 = encx24j600_read_phy(priv, PHCON1);
+	if (priv->autoneg == AUTONEG_ENABLE) {
+		phcon1 |= ANEN | RENEG;
+	} else {
+		phcon1 &= ~ANEN;
+		if (priv->speed == SPEED_100)
+			phcon1 |= SPD100;
+		else
+			phcon1 &= ~SPD100;
+
+		if (priv->full_duplex)
+			phcon1 |= PFULDPX;
+		else
+			phcon1 &= ~PFULDPX;
+	}
+	encx24j600_write_phy(priv, PHCON1, phcon1);
+}
+
+/* Waits for autonegotiation to complete. */
+static int encx24j600_wait_for_autoneg(struct encx24j600_priv *priv)
+{
+	struct net_device *dev = priv->ndev;
+	unsigned long timeout = jiffies + msecs_to_jiffies(2000);
+	u16 phstat1;
+	u16 estat;
+	int ret = 0;
+
+	phstat1 = encx24j600_read_phy(priv, PHSTAT1);
+	while ((phstat1 & ANDONE) == 0) {
+		if (time_after(jiffies, timeout)) {
+			u16 phstat3;
+
+			netif_notice(priv, drv, dev, "timeout waiting for autoneg done\n");
+
+			priv->autoneg = AUTONEG_DISABLE;
+			phstat3 = encx24j600_read_phy(priv, PHSTAT3);
+			priv->speed = (phstat3 & PHY3SPD100)
+				      ? SPEED_100 : SPEED_10;
+			priv->full_duplex = (phstat3 & PHY3DPX) ? 1 : 0;
+			encx24j600_update_phcon1(priv);
+			netif_notice(priv, drv, dev, "Using parallel detection: %s/%s",
+				     priv->speed == SPEED_100 ? "100" : "10",
+				     priv->full_duplex ? "Full" : "Half");
+
+			return -ETIMEDOUT;
+		}
+		cpu_relax();
+		phstat1 = encx24j600_read_phy(priv, PHSTAT1);
+	}
+
+	estat = encx24j600_read_reg(priv, ESTAT);
+	if (estat & PHYDPX) {
+		encx24j600_set_bits(priv, MACON2, FULDPX);
+		encx24j600_write_reg(priv, MABBIPG, 0x15);
+	} else {
+		encx24j600_clr_bits(priv, MACON2, FULDPX);
+		encx24j600_write_reg(priv, MABBIPG, 0x12);
+		/* Max retransmittions attempt  */
+		encx24j600_write_reg(priv, MACLCON, 0x370f);
+	}
+
+	return ret;
+}
+
+/* Access the PHY to determine link status */
+static void encx24j600_check_link_status(struct encx24j600_priv *priv)
+{
+	struct net_device *dev = priv->ndev;
+	u16 estat;
+
+	estat = encx24j600_read_reg(priv, ESTAT);
+
+	if (estat & PHYLNK) {
+		if (priv->autoneg == AUTONEG_ENABLE)
+			encx24j600_wait_for_autoneg(priv);
+
+		netif_carrier_on(dev);
+		netif_info(priv, ifup, dev, "link up\n");
+	} else {
+		netif_info(priv, ifdown, dev, "link down\n");
+
+		/* Re-enable autoneg since we won't know what we might be
+		 * connected to when the link is brought back up again.
+		 */
+		priv->autoneg  = AUTONEG_ENABLE;
+		priv->full_duplex = true;
+		priv->speed = SPEED_100;
+		netif_carrier_off(dev);
+	}
+}
+
+static void encx24j600_int_link_handler(struct encx24j600_priv *priv)
+{
+	struct net_device *dev = priv->ndev;
+
+	netif_dbg(priv, intr, dev, "%s", __func__);
+	encx24j600_check_link_status(priv);
+	encx24j600_clr_bits(priv, EIR, LINKIF);
+}
+
+static void encx24j600_tx_complete(struct encx24j600_priv *priv, bool err)
+{
+	struct net_device *dev = priv->ndev;
+
+	mutex_lock(&priv->lock);
+
+	if (err)
+		dev->stats.tx_errors++;
+	else
+		dev->stats.tx_packets++;
+
+	dev->stats.tx_bytes += priv->tx_skb->len;
+
+	encx24j600_clr_bits(priv, EIR, TXIF | TXABTIF);
+
+	netif_dbg(priv, tx_done, dev, "TX Done%s\n", err ? ": Err" : "");
+
+	if (priv->tx_skb) {
+		dev_kfree_skb(priv->tx_skb);
+		priv->tx_skb = NULL;
+	}
+
+	netif_wake_queue(dev);
+
+	mutex_unlock(&priv->lock);
+}
+
+static int encx24j600_receive_packet(struct encx24j600_priv *priv,
+				     struct rsv *rsv)
+{
+	struct net_device *dev = priv->ndev;
+	struct sk_buff *skb = netdev_alloc_skb(dev, rsv->len + NET_IP_ALIGN);
+	if (!skb) {
+		pr_err_ratelimited("RX: OOM: packet dropped\n");
+		dev->stats.rx_dropped++;
+		return -ENOMEM;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+	encx24j600_raw_read(priv, RRXDATA, skb_put(skb, rsv->len), rsv->len);
+
+	if (netif_msg_pktdata(priv))
+		dump_packet("RX", skb->len, skb->data);
+
+	skb->dev = dev;
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->ip_summed = CHECKSUM_COMPLETE;
+
+	/* Maintain stats */
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += rsv->len;
+	priv->next_packet = rsv->next_packet;
+
+	netif_rx(skb);
+
+	return 0;
+}
+
+static void encx24j600_rx_packets(struct encx24j600_priv *priv, u8 packet_count)
+{
+	struct net_device *dev = priv->ndev;
+
+	while (packet_count--) {
+		struct rsv rsv;
+		u16 newrxtail;
+
+		encx24j600_write_reg(priv, ERXRDPT, priv->next_packet);
+		encx24j600_raw_read(priv, RRXDATA, (u8 *)&rsv, sizeof(rsv));
+
+		if (netif_msg_rx_status(priv))
+			encx24j600_dump_rsv(priv, __func__, &rsv);
+
+		if (!RSV_GETBIT(rsv.rxstat, RSV_RXOK) ||
+		    (rsv.len > MAX_FRAMELEN)) {
+			netif_err(priv, rx_err, dev, "RX Error %04x\n",
+				  rsv.rxstat);
+			dev->stats.rx_errors++;
+
+			if (RSV_GETBIT(rsv.rxstat, RSV_CRCERROR))
+				dev->stats.rx_crc_errors++;
+			if (RSV_GETBIT(rsv.rxstat, RSV_LENCHECKERR))
+				dev->stats.rx_frame_errors++;
+			if (rsv.len > MAX_FRAMELEN)
+				dev->stats.rx_over_errors++;
+		} else {
+			encx24j600_receive_packet(priv, &rsv);
+		}
+
+		newrxtail = priv->next_packet - 2;
+		if (newrxtail == ENC_RX_BUF_START)
+			newrxtail = SRAM_SIZE - 2;
+
+		encx24j600_cmd(priv, SETPKTDEC);
+		encx24j600_write_reg(priv, ERXTAIL, newrxtail);
+	}
+}
+
+static irqreturn_t encx24j600_isr(int irq, void *dev_id)
+{
+	struct encx24j600_priv *priv = dev_id;
+	struct net_device *dev = priv->ndev;
+	int eir;
+
+	/* Clear interrupts */
+	encx24j600_cmd(priv, CLREIE);
+
+	eir = encx24j600_read_reg(priv, EIR);
+
+	if (eir & LINKIF)
+		encx24j600_int_link_handler(priv);
+
+	if (eir & TXIF)
+		encx24j600_tx_complete(priv, false);
+
+	if (eir & TXABTIF)
+		encx24j600_tx_complete(priv, true);
+
+	if (eir & RXABTIF) {
+		if (eir & PCFULIF) {
+			/* Packet counter is full */
+			netif_err(priv, rx_err, dev, "Packet counter full\n");
+		}
+		dev->stats.rx_dropped++;
+		encx24j600_clr_bits(priv, EIR, RXABTIF);
+	}
+
+	if (eir & PKTIF) {
+		u8 packet_count;
+
+		mutex_lock(&priv->lock);
+
+		packet_count = encx24j600_read_reg(priv, ESTAT) & 0xff;
+		while (packet_count) {
+			encx24j600_rx_packets(priv, packet_count);
+			packet_count = encx24j600_read_reg(priv, ESTAT) & 0xff;
+		}
+
+		mutex_unlock(&priv->lock);
+	}
+
+	/* Enable interrupts */
+	encx24j600_cmd(priv, SETEIE);
+
+	return IRQ_HANDLED;
+}
+
+static int encx24j600_soft_reset(struct encx24j600_priv *priv)
+{
+	int ret = 0;
+	int timeout;
+	u16 eudast;
+
+	/* Write and verify a test value to EUDAST */
+	regcache_cache_bypass(priv->ctx.regmap, true);
+	timeout = 10;
+	do {
+		encx24j600_write_reg(priv, EUDAST, EUDAST_TEST_VAL);
+		eudast = encx24j600_read_reg(priv, EUDAST);
+		usleep_range(25, 100);
+	} while ((eudast != EUDAST_TEST_VAL) && --timeout);
+	regcache_cache_bypass(priv->ctx.regmap, false);
+
+	if (timeout == 0) {
+		ret = -ETIMEDOUT;
+		goto err_out;
+	}
+
+	/* Wait for CLKRDY to become set */
+	timeout = 10;
+	while (!(encx24j600_read_reg(priv, ESTAT) & CLKRDY) && --timeout)
+		usleep_range(25, 100);
+
+	if (timeout == 0) {
+		ret = -ETIMEDOUT;
+		goto err_out;
+	}
+
+	/* Issue a System Reset command */
+	encx24j600_cmd(priv, SETETHRST);
+	usleep_range(25, 100);
+
+	/* Confirm that EUDAST has 0000h after system reset */
+	if (encx24j600_read_reg(priv, EUDAST) != 0) {
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	/* Wait for PHY register and status bits to become available */
+	usleep_range(256, 1000);
+
+err_out:
+	return ret;
+}
+
+static int encx24j600_hw_reset(struct encx24j600_priv *priv)
+{
+	int ret;
+
+	mutex_lock(&priv->lock);
+	ret = encx24j600_soft_reset(priv);
+	mutex_unlock(&priv->lock);
+
+	return ret;
+}
+
+static void encx24j600_reset_hw_tx(struct encx24j600_priv *priv)
+{
+	encx24j600_set_bits(priv, ECON2, TXRST);
+	encx24j600_clr_bits(priv, ECON2, TXRST);
+}
+
+static void encx24j600_hw_init_tx(struct encx24j600_priv *priv)
+{
+	/* Reset TX */
+	encx24j600_reset_hw_tx(priv);
+
+	/* Clear the TXIF flag if were previously set */
+	encx24j600_clr_bits(priv, EIR, TXIF | TXABTIF);
+
+	/* Write the Tx Buffer pointer */
+	encx24j600_write_reg(priv, EGPWRPT, ENC_TX_BUF_START);
+}
+
+static void encx24j600_hw_init_rx(struct encx24j600_priv *priv)
+{
+	encx24j600_cmd(priv, DISABLERX);
+
+	/* Set up RX packet start address in the SRAM */
+	encx24j600_write_reg(priv, ERXST, ENC_RX_BUF_START);
+
+	/* Preload the RX Data pointer to the beginning of the RX area */
+	encx24j600_write_reg(priv, ERXRDPT, ENC_RX_BUF_START);
+
+	priv->next_packet = ENC_RX_BUF_START;
+
+	/* Set up RX end address in the SRAM */
+	encx24j600_write_reg(priv, ERXTAIL, ENC_SRAM_SIZE - 2);
+
+	/* Reset the  user data pointers    */
+	encx24j600_write_reg(priv, EUDAST, ENC_SRAM_SIZE);
+	encx24j600_write_reg(priv, EUDAND, ENC_SRAM_SIZE + 1);
+
+	/* Set Max Frame length */
+	encx24j600_write_reg(priv, MAMXFL, MAX_FRAMELEN);
+}
+
+static void encx24j600_dump_config(struct encx24j600_priv *priv,
+				   const char *msg)
+{
+	pr_info(DRV_NAME ": %s\n", msg);
+
+	/* CHIP configuration */
+	pr_info(DRV_NAME " ECON1:   %04X\n", encx24j600_read_reg(priv, ECON1));
+	pr_info(DRV_NAME " ECON2:   %04X\n", encx24j600_read_reg(priv, ECON2));
+	pr_info(DRV_NAME " ERXFCON: %04X\n", encx24j600_read_reg(priv,
+								 ERXFCON));
+	pr_info(DRV_NAME " ESTAT:   %04X\n", encx24j600_read_reg(priv, ESTAT));
+	pr_info(DRV_NAME " EIR:     %04X\n", encx24j600_read_reg(priv, EIR));
+	pr_info(DRV_NAME " EIDLED:  %04X\n", encx24j600_read_reg(priv, EIDLED));
+
+	/* MAC layer configuration */
+	pr_info(DRV_NAME " MACON1:  %04X\n", encx24j600_read_reg(priv, MACON1));
+	pr_info(DRV_NAME " MACON2:  %04X\n", encx24j600_read_reg(priv, MACON2));
+	pr_info(DRV_NAME " MAIPG:   %04X\n", encx24j600_read_reg(priv, MAIPG));
+	pr_info(DRV_NAME " MACLCON: %04X\n", encx24j600_read_reg(priv,
+								 MACLCON));
+	pr_info(DRV_NAME " MABBIPG: %04X\n", encx24j600_read_reg(priv,
+								 MABBIPG));
+
+	/* PHY configuation */
+	pr_info(DRV_NAME " PHCON1:  %04X\n", encx24j600_read_phy(priv, PHCON1));
+	pr_info(DRV_NAME " PHCON2:  %04X\n", encx24j600_read_phy(priv, PHCON2));
+	pr_info(DRV_NAME " PHANA:   %04X\n", encx24j600_read_phy(priv, PHANA));
+	pr_info(DRV_NAME " PHANLPA: %04X\n", encx24j600_read_phy(priv,
+								 PHANLPA));
+	pr_info(DRV_NAME " PHANE:   %04X\n", encx24j600_read_phy(priv, PHANE));
+	pr_info(DRV_NAME " PHSTAT1: %04X\n", encx24j600_read_phy(priv,
+								 PHSTAT1));
+	pr_info(DRV_NAME " PHSTAT2: %04X\n", encx24j600_read_phy(priv,
+								 PHSTAT2));
+	pr_info(DRV_NAME " PHSTAT3: %04X\n", encx24j600_read_phy(priv,
+								 PHSTAT3));
+}
+
+static void encx24j600_set_rxfilter_mode(struct encx24j600_priv *priv)
+{
+	switch (priv->rxfilter) {
+	case RXFILTER_PROMISC:
+		encx24j600_set_bits(priv, MACON1, PASSALL);
+		encx24j600_write_reg(priv, ERXFCON, UCEN | MCEN | NOTMEEN);
+		break;
+	case RXFILTER_MULTI:
+		encx24j600_clr_bits(priv, MACON1, PASSALL);
+		encx24j600_write_reg(priv, ERXFCON, UCEN | CRCEN | BCEN | MCEN);
+		break;
+	case RXFILTER_NORMAL:
+	default:
+		encx24j600_clr_bits(priv, MACON1, PASSALL);
+		encx24j600_write_reg(priv, ERXFCON, UCEN | CRCEN | BCEN);
+		break;
+	}
+}
+
+static int encx24j600_hw_init(struct encx24j600_priv *priv)
+{
+	struct net_device *dev = priv->ndev;
+	int ret = 0;
+	u16 eidled;
+	u16 macon2;
+
+	priv->hw_enabled = false;
+
+	eidled = encx24j600_read_reg(priv, EIDLED);
+	if (((eidled & DEVID_MASK) >> DEVID_SHIFT) != ENCX24J600_DEV_ID) {
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	netif_info(priv, drv, dev, "Silicon rev ID: 0x%02x\n",
+		   (eidled & REVID_MASK) >> REVID_SHIFT);
+
+	/* PHY Leds: link status,
+	 * LEDA: Link + transmit/receive events
+	 * LEDB: Link State + colision events
+	 */
+	encx24j600_update_reg(priv, EIDLED, 0xbc00, 0xbc00);
+
+	/* Loopback disabled */
+	encx24j600_write_reg(priv, MACON1, 0x9);
+
+	/* interpacket gap value */
+	encx24j600_write_reg(priv, MAIPG, 0x0c12);
+
+	/* Write the auto negotiation pattern */
+	encx24j600_write_phy(priv, PHANA, PHANA_DEFAULT);
+
+	encx24j600_update_phcon1(priv);
+	encx24j600_check_link_status(priv);
+
+	macon2 = MACON2_RSV1 | TXCRCEN | PADCFG0 | PADCFG2 | MACON2_DEFER;
+	if ((priv->autoneg == AUTONEG_DISABLE) && priv->full_duplex)
+		macon2 |= FULDPX;
+
+	encx24j600_set_bits(priv, MACON2, macon2);
+
+	priv->rxfilter = RXFILTER_NORMAL;
+	encx24j600_set_rxfilter_mode(priv);
+
+	/* Program the Maximum frame length */
+	encx24j600_write_reg(priv, MAMXFL, MAX_FRAMELEN);
+
+	/* Init Tx pointers */
+	encx24j600_hw_init_tx(priv);
+
+	/* Init Rx pointers */
+	encx24j600_hw_init_rx(priv);
+
+	if (netif_msg_hw(priv))
+		encx24j600_dump_config(priv, "Hw is initialized");
+
+err_out:
+	return ret;
+}
+
+static void encx24j600_hw_enable(struct encx24j600_priv *priv)
+{
+	/* Clear the interrupt flags in case was set */
+	encx24j600_clr_bits(priv, EIR, (PCFULIF | RXABTIF | TXABTIF | TXIF |
+					PKTIF | LINKIF));
+
+	/* Enable the interrupts */
+	encx24j600_write_reg(priv, EIE, (PCFULIE | RXABTIE | TXABTIE | TXIE |
+					 PKTIE | LINKIE | INTIE));
+
+	/* Enable RX */
+	encx24j600_cmd(priv, ENABLERX);
+
+	priv->hw_enabled = true;
+}
+
+static void encx24j600_hw_disable(struct encx24j600_priv *priv)
+{
+	/* Disable all interrupts */
+	encx24j600_write_reg(priv, EIE, 0);
+
+	/* Disable RX */
+	encx24j600_cmd(priv, DISABLERX);
+
+	priv->hw_enabled = false;
+}
+
+static int encx24j600_setlink(struct net_device *dev, u8 autoneg, u16 speed,
+			      u8 duplex)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+	int ret = 0;
+
+	if (!priv->hw_enabled) {
+		/* link is in low power mode now; duplex setting
+		 * will take effect on next encx24j600_hw_init()
+		 */
+		if (speed == SPEED_10 || speed == SPEED_100) {
+			priv->autoneg = (autoneg == AUTONEG_ENABLE);
+			priv->full_duplex = (duplex == DUPLEX_FULL);
+			priv->speed = (speed == SPEED_100);
+		} else {
+			netif_warn(priv, link, dev, "unsupported link speed setting\n");
+			/*speeds other than SPEED_10 and SPEED_100 */
+			/*are not supported by chip */
+			ret = -EOPNOTSUPP;
+		}
+	} else {
+		netif_warn(priv, link, dev, "Warning: hw must be disabled to set link mode\n");
+		ret = -EBUSY;
+	}
+	return ret;
+}
+
+static void encx24j600_hw_get_macaddr(struct encx24j600_priv *priv,
+				      unsigned char *ethaddr)
+{
+	unsigned short val;
+
+	val = encx24j600_read_reg(priv, MAADR1);
+
+	ethaddr[0] = val & 0x00ff;
+	ethaddr[1] = (val & 0xff00) >> 8;
+
+	val = encx24j600_read_reg(priv, MAADR2);
+
+	ethaddr[2] = val & 0x00ffU;
+	ethaddr[3] = (val & 0xff00U) >> 8;
+
+	val = encx24j600_read_reg(priv, MAADR3);
+
+	ethaddr[4] = val & 0x00ffU;
+	ethaddr[5] = (val & 0xff00U) >> 8;
+}
+
+/* Program the hardware MAC address from dev->dev_addr.*/
+static int encx24j600_set_hw_macaddr(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	if (priv->hw_enabled) {
+		netif_info(priv, drv, dev, "Hardware must be disabled to set Mac address\n");
+		return -EBUSY;
+	}
+
+	mutex_lock(&priv->lock);
+
+	netif_info(priv, drv, dev, "%s: Setting MAC address to %pM\n",
+		   dev->name, dev->dev_addr);
+
+	encx24j600_write_reg(priv, MAADR3, (dev->dev_addr[4] |
+			     dev->dev_addr[5] << 8));
+	encx24j600_write_reg(priv, MAADR2, (dev->dev_addr[2] |
+			     dev->dev_addr[3] << 8));
+	encx24j600_write_reg(priv, MAADR1, (dev->dev_addr[0] |
+			     dev->dev_addr[1] << 8));
+
+	mutex_unlock(&priv->lock);
+
+	return 0;
+}
+
+/* Store the new hardware address in dev->dev_addr, and update the MAC.*/
+static int encx24j600_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *address = addr;
+
+	if (netif_running(dev))
+		return -EBUSY;
+	if (!is_valid_ether_addr(address->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, address->sa_data, dev->addr_len);
+	return encx24j600_set_hw_macaddr(dev);
+}
+
+static int encx24j600_open(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	int ret = request_threaded_irq(priv->ctx.spi->irq, NULL, encx24j600_isr,
+				       IRQF_TRIGGER_FALLING | IRQF_ONESHOT,
+				       DRV_NAME, priv);
+	if (unlikely(ret < 0)) {
+		netdev_err(dev, "request irq %d failed (ret = %d)\n",
+			   priv->ctx.spi->irq, ret);
+		return ret;
+	}
+
+	encx24j600_hw_disable(priv);
+	encx24j600_hw_init(priv);
+	encx24j600_hw_enable(priv);
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static int encx24j600_stop(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+	free_irq(priv->ctx.spi->irq, priv);
+	return 0;
+}
+
+static void encx24j600_setrx_proc(struct kthread_work *ws)
+{
+	struct encx24j600_priv *priv =
+			container_of(ws, struct encx24j600_priv, setrx_work);
+
+	mutex_lock(&priv->lock);
+	encx24j600_set_rxfilter_mode(priv);
+	mutex_unlock(&priv->lock);
+}
+
+static void encx24j600_set_multicast_list(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+	int oldfilter = priv->rxfilter;
+
+	if (dev->flags & IFF_PROMISC) {
+		netif_dbg(priv, link, dev, "promiscuous mode\n");
+		priv->rxfilter = RXFILTER_PROMISC;
+	} else if ((dev->flags & IFF_ALLMULTI) || !netdev_mc_empty(dev)) {
+		netif_dbg(priv, link, dev, "%smulticast mode\n",
+			  (dev->flags & IFF_ALLMULTI) ? "all-" : "");
+		priv->rxfilter = RXFILTER_MULTI;
+	} else {
+		netif_dbg(priv, link, dev, "normal mode\n");
+		priv->rxfilter = RXFILTER_NORMAL;
+	}
+
+	if (oldfilter != priv->rxfilter)
+		queue_kthread_work(&priv->kworker, &priv->setrx_work);
+}
+
+static void encx24j600_hw_tx(struct encx24j600_priv *priv)
+{
+	struct net_device *dev = priv->ndev;
+	netif_info(priv, tx_queued, dev, "TX Packet Len:%d\n",
+		   priv->tx_skb->len);
+
+	if (netif_msg_pktdata(priv))
+		dump_packet("TX", priv->tx_skb->len, priv->tx_skb->data);
+
+	if (encx24j600_read_reg(priv, EIR) & TXABTIF)
+		/* Last transmition aborted due to error. Reset TX interface */
+		encx24j600_reset_hw_tx(priv);
+
+	/* Clear the TXIF flag if were previously set */
+	encx24j600_clr_bits(priv, EIR, TXIF);
+
+	/* Set the data pointer to the TX buffer address in the SRAM */
+	encx24j600_write_reg(priv, EGPWRPT, ENC_TX_BUF_START);
+
+	/* Copy the packet into the SRAM */
+	encx24j600_raw_write(priv, WGPDATA, (u8 *)priv->tx_skb->data,
+			     priv->tx_skb->len);
+
+	/* Program the Tx buffer start pointer */
+	encx24j600_write_reg(priv, ETXST, ENC_TX_BUF_START);
+
+	/* Program the packet length */
+	encx24j600_write_reg(priv, ETXLEN, priv->tx_skb->len);
+
+	/* Start the transmission */
+	encx24j600_cmd(priv, SETTXRTS);
+}
+
+static void encx24j600_tx_proc(struct kthread_work *ws)
+{
+	struct encx24j600_priv *priv =
+			container_of(ws, struct encx24j600_priv, tx_work);
+
+	mutex_lock(&priv->lock);
+	encx24j600_hw_tx(priv);
+	mutex_unlock(&priv->lock);
+}
+
+static netdev_tx_t encx24j600_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+
+	/* save the timestamp */
+	dev->trans_start = jiffies;
+
+	/* Remember the skb for deferred processing */
+	priv->tx_skb = skb;
+
+	queue_kthread_work(&priv->kworker, &priv->tx_work);
+
+	return NETDEV_TX_OK;
+}
+
+/* Deal with a transmit timeout */
+static void encx24j600_tx_timeout(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	netif_err(priv, tx_err, dev, "TX timeout at %ld, latency %ld\n",
+		  jiffies, jiffies - dev->trans_start);
+
+	dev->stats.tx_errors++;
+	netif_wake_queue(dev);
+	return;
+}
+
+static int encx24j600_get_regs_len(struct net_device *dev)
+{
+	return SFR_REG_COUNT;
+}
+
+static void encx24j600_get_regs(struct net_device *dev,
+				struct ethtool_regs *regs, void *p)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+	u16 *buff = p;
+	u8 reg;
+
+	regs->version = 1;
+	mutex_lock(&priv->lock);
+	for (reg = 0; reg < SFR_REG_COUNT; reg += 2) {
+		unsigned int val = 0;
+		/* ignore errors for unreadable registers */
+		regmap_read(priv->ctx.regmap, reg, &val);
+		buff[reg] = val & 0xffff;
+	}
+	mutex_unlock(&priv->lock);
+}
+
+static void encx24j600_get_drvinfo(struct net_device *dev,
+				   struct ethtool_drvinfo *info)
+{
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, dev_name(dev->dev.parent),
+		sizeof(info->bus_info));
+}
+
+static int encx24j600_get_settings(struct net_device *dev,
+				   struct ethtool_cmd *cmd)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->supported = SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
+			 SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
+			 SUPPORTED_Autoneg | SUPPORTED_TP;
+
+	ethtool_cmd_speed_set(cmd, priv->speed);
+	cmd->duplex = priv->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
+	cmd->port = PORT_TP;
+	cmd->autoneg = priv->autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static int encx24j600_set_settings(struct net_device *dev,
+				   struct ethtool_cmd *cmd)
+{
+	return encx24j600_setlink(dev, cmd->autoneg,
+				  ethtool_cmd_speed(cmd), cmd->duplex);
+}
+
+static u32 encx24j600_get_msglevel(struct net_device *dev)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+	return priv->msg_enable;
+}
+
+static void encx24j600_set_msglevel(struct net_device *dev, u32 val)
+{
+	struct encx24j600_priv *priv = netdev_priv(dev);
+	priv->msg_enable = val;
+}
+
+static const struct ethtool_ops encx24j600_ethtool_ops = {
+	.get_settings = encx24j600_get_settings,
+	.set_settings = encx24j600_set_settings,
+	.get_drvinfo = encx24j600_get_drvinfo,
+	.get_msglevel = encx24j600_get_msglevel,
+	.set_msglevel = encx24j600_set_msglevel,
+	.get_regs_len = encx24j600_get_regs_len,
+	.get_regs = encx24j600_get_regs,
+};
+
+static const struct net_device_ops encx24j600_netdev_ops = {
+	.ndo_open = encx24j600_open,
+	.ndo_stop = encx24j600_stop,
+	.ndo_start_xmit = encx24j600_tx,
+	.ndo_set_rx_mode = encx24j600_set_multicast_list,
+	.ndo_set_mac_address = encx24j600_set_mac_address,
+	.ndo_tx_timeout = encx24j600_tx_timeout,
+	.ndo_validate_addr = eth_validate_addr,
+};
+
+static int encx24j600_spi_probe(struct spi_device *spi)
+{
+	int ret;
+
+	struct net_device *ndev;
+	struct encx24j600_priv *priv;
+
+	ndev = alloc_etherdev(sizeof(struct encx24j600_priv));
+
+	if (!ndev) {
+		ret = -ENOMEM;
+		goto error_out;
+	}
+
+	priv = netdev_priv(ndev);
+	spi_set_drvdata(spi, priv);
+	dev_set_drvdata(&spi->dev, priv);
+	SET_NETDEV_DEV(ndev, &spi->dev);
+
+	priv->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+	priv->ndev = ndev;
+
+	/* Default configuration PHY configuration */
+	priv->full_duplex = true;
+	priv->autoneg = AUTONEG_ENABLE;
+	priv->speed = SPEED_100;
+
+	priv->ctx.spi = spi;
+	devm_regmap_init_encx24j600(&spi->dev, &priv->ctx);
+	ndev->irq = spi->irq;
+	ndev->netdev_ops = &encx24j600_netdev_ops;
+
+	mutex_init(&priv->lock);
+
+	/* Reset device and check if it is connected */
+	if (encx24j600_hw_reset(priv)) {
+		netif_err(priv, probe, ndev,
+			  DRV_NAME ": Chip is not detected\n");
+		ret = -EIO;
+		goto out_free;
+	}
+
+	/* Initialize the device HW to the consistent state */
+	if (encx24j600_hw_init(priv)) {
+		netif_err(priv, probe, ndev,
+			  DRV_NAME ": HW initialization error\n");
+		ret = -EIO;
+		goto out_free;
+	}
+
+	init_kthread_worker(&priv->kworker);
+	init_kthread_work(&priv->tx_work, encx24j600_tx_proc);
+	init_kthread_work(&priv->setrx_work, encx24j600_setrx_proc);
+
+	priv->kworker_task = kthread_run(kthread_worker_fn, &priv->kworker,
+					 "encx24j600");
+
+	if (IS_ERR(priv->kworker_task)) {
+		ret = PTR_ERR(priv->kworker_task);
+		goto out_free;
+	}
+
+	/* Get the MAC address from the chip */
+	encx24j600_hw_get_macaddr(priv, ndev->dev_addr);
+
+	ndev->ethtool_ops = &encx24j600_ethtool_ops;
+
+	ret = register_netdev(ndev);
+	if (unlikely(ret)) {
+		netif_err(priv, probe, ndev, "Error %d initializing card encx24j600 card\n",
+			  ret);
+		goto out_free;
+	}
+
+	netif_info(priv, drv, priv->ndev, "MAC address %pM\n", ndev->dev_addr);
+
+	return ret;
+
+out_free:
+	free_netdev(ndev);
+
+error_out:
+	return ret;
+}
+
+static int encx24j600_spi_remove(struct spi_device *spi)
+{
+	struct encx24j600_priv *priv = dev_get_drvdata(&spi->dev);
+
+	unregister_netdev(priv->ndev);
+
+	free_netdev(priv->ndev);
+
+	return 0;
+}
+
+static const struct spi_device_id encx24j600_spi_id_table = {
+	.name = "encx24j600"
+};
+
+static struct spi_driver encx24j600_spi_net_driver = {
+	.driver = {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+		.bus	= &spi_bus_type,
+	},
+	.probe		= encx24j600_spi_probe,
+	.remove		= encx24j600_spi_remove,
+	.id_table	= &encx24j600_spi_id_table,
+};
+
+static int __init encx24j600_init(void)
+{
+	return spi_register_driver(&encx24j600_spi_net_driver);
+}
+module_init(encx24j600_init);
+
+static void encx24j600_exit(void)
+{
+	spi_unregister_driver(&encx24j600_spi_net_driver);
+}
+module_exit(encx24j600_exit);
+
+MODULE_DESCRIPTION(DRV_NAME " ethernet driver");
+MODULE_AUTHOR("Jon Ringle <jringle@gridpoint.com>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("spi:" DRV_NAME);
diff --git a/drivers/net/ethernet/microchip/encx24j600_hw.h b/drivers/net/ethernet/microchip/encx24j600_hw.h
new file mode 100644
index 0000000..4be73d5
--- /dev/null
+++ b/drivers/net/ethernet/microchip/encx24j600_hw.h
@@ -0,0 +1,437 @@
+/**
+ * encx24j600_hw.h: Register definitions
+ *
+ */
+
+#ifndef _ENCX24J600_HW_H
+#define _ENCX24J600_HW_H
+
+struct encx24j600_context {
+	struct spi_device *spi;
+	struct regmap *regmap;
+	struct regmap *phymap;
+	struct mutex mutex; /* mutex to protect access to regmap */
+	int bank;
+};
+
+void devm_regmap_init_encx24j600(struct device *dev,
+				 struct encx24j600_context *ctx);
+
+/* Single-byte instructions */
+#define BANK_SELECT(bank) (0xC0 | ((bank & (BANK_MASK >> BANK_SHIFT)) << 1))
+#define B0SEL 0xC0		/* Bank 0 Select */
+#define B1SEL 0xC2		/* Bank 1 Select */
+#define B2SEL 0xC4		/* Bank 2 Select */
+#define B3SEL 0xC6		/* Bank 3 Select */
+#define SETETHRST 0xCA		/* System Reset */
+#define FCDISABLE 0xE0		/* Flow Control Disable */
+#define FCSINGLE 0xE2		/* Flow Control Single */
+#define FCMULTIPLE 0xE4		/* Flow Control Multiple */
+#define FCCLEAR 0xE6		/* Flow Control Clear */
+#define SETPKTDEC 0xCC		/* Decrement Packet Counter */
+#define DMASTOP 0xD2		/* DMA Stop */
+#define DMACKSUM 0xD8		/* DMA Start Checksum */
+#define DMACKSUMS 0xDA		/* DMA Start Checksum with Seed */
+#define DMACOPY 0xDC		/* DMA Start Copy */
+#define DMACOPYS 0xDE		/* DMA Start Copy and Checksum with Seed */
+#define SETTXRTS 0xD4		/* Request Packet Transmission */
+#define ENABLERX 0xE8		/* Enable RX */
+#define DISABLERX 0xEA		/* Disable RX */
+#define SETEIE 0xEC		/* Enable Interrupts */
+#define CLREIE 0xEE		/* Disable Interrupts */
+
+/* Two byte instructions */
+#define RBSEL 0xC8		/* Read Bank Select */
+
+/* Three byte instructions */
+#define WGPRDPT 0x60		/* Write EGPRDPT */
+#define RGPRDPT 0x62		/* Read EGPRDPT */
+#define WRXRDPT 0x64		/* Write ERXRDPT */
+#define RRXRDPT 0x66		/* Read ERXRDPT */
+#define WUDARDPT 0x68		/* Write EUDARDPT */
+#define RUDARDPT 0x6A		/* Read EUDARDPT */
+#define WGPWRPT 0x6C		/* Write EGPWRPT */
+#define RGPWRPT 0x6E		/* Read EGPWRPT */
+#define WRXWRPT 0x70		/* Write ERXWRPT */
+#define RRXWRPT 0x72		/* Read ERXWRPT */
+#define WUDAWRPT 0x74		/* Write EUDAWRPT */
+#define RUDAWRPT 0x76		/* Read EUDAWRPT */
+
+/* n byte instructions */
+#define RCRCODE 0x00
+#define WCRCODE 0x40
+#define BFSCODE 0x80
+#define BFCCODE 0xA0
+#define RCR(addr) (RCRCODE | (addr & ADDR_MASK)) /* Read Control Register */
+#define WCR(addr) (WCRCODE | (addr & ADDR_MASK)) /* Write Control Register */
+#define RCRU 0x20		/* Read Control Register Unbanked */
+#define WCRU 0x22		/* Write Control Register Unbanked */
+#define BFS(addr) (BFSCODE | (addr & ADDR_MASK)) /* Bit Field Set */
+#define BFC(addr) (BFCCODE | (addr & ADDR_MASK)) /* Bit Field Clear */
+#define BFSU 0x24		/* Bit Field Set Unbanked */
+#define BFCU 0x26		/* Bit Field Clear Unbanked */
+#define RGPDATA 0x28		/* Read EGPDATA */
+#define WGPDATA 0x2A		/* Write EGPDATA */
+#define RRXDATA 0x2C		/* Read ERXDATA */
+#define WRXDATA 0x2E		/* Write ERXDATA */
+#define RUDADATA 0x30		/* Read EUDADATA */
+#define WUDADATA 0x32		/* Write EUDADATA */
+
+#define SFR_REG_COUNT	0xA0
+
+/* ENC424J600 Control Registers
+ * Control register definitions are a combination of address
+ * and bank number
+ * - Register address (bits 0-4)
+ * - Bank number (bits 5-6)
+ */
+#define ADDR_MASK 0x1F
+#define BANK_MASK 0x60
+#define BANK_SHIFT 5
+
+/* All-bank registers */
+#define EUDAST 0x16
+#define EUDAND 0x18
+#define ESTAT 0x1A
+#define EIR 0x1C
+#define ECON1 0x1E
+
+/* Bank 0 registers */
+#define ETXST (0x00 | 0x00)
+#define ETXLEN (0x02 | 0x00)
+#define ERXST (0x04 | 0x00)
+#define ERXTAIL (0x06 | 0x00)
+#define ERXHEAD (0x08 | 0x00)
+#define EDMAST (0x0A | 0x00)
+#define EDMALEN (0x0C | 0x00)
+#define EDMADST (0x0E | 0x00)
+#define EDMACS (0x10 | 0x00)
+#define ETXSTAT (0x12 | 0x00)
+#define ETXWIRE (0x14 | 0x00)
+
+/* Bank 1 registers */
+#define EHT1 (0x00 | 0x20)
+#define EHT2 (0x02 | 0x20)
+#define EHT3 (0x04 | 0x20)
+#define EHT4 (0x06 | 0x20)
+#define EPMM1 (0x08 | 0x20)
+#define EPMM2 (0x0A | 0x20)
+#define EPMM3 (0x0C | 0x20)
+#define EPMM4 (0x0E | 0x20)
+#define EPMCS (0x10 | 0x20)
+#define EPMO (0x12 | 0x20)
+#define ERXFCON (0x14 | 0x20)
+
+/* Bank 2 registers */
+#define MACON1 (0x00 | 0x40)
+#define MACON2 (0x02 | 0x40)
+#define MABBIPG (0x04 | 0x40)
+#define MAIPG (0x06 | 0x40)
+#define MACLCON (0x08 | 0x40)
+#define MAMXFL (0x0A | 0x40)
+#define MICMD (0x12 | 0x40)
+#define MIREGADR (0x14 | 0x40)
+
+/* Bank 3 registers */
+#define MAADR3 (0x00 | 0x60)
+#define MAADR2 (0x02 | 0x60)
+#define MAADR1 (0x04 | 0x60)
+#define MIWR (0x06 | 0x60)
+#define MIRD (0x08 | 0x60)
+#define MISTAT (0x0A | 0x60)
+#define EPAUS (0x0C | 0x60)
+#define ECON2 (0x0E | 0x60)
+#define ERXWM (0x10 | 0x60)
+#define EIE (0x12 | 0x60)
+#define EIDLED (0x14 | 0x60)
+
+/* Unbanked registers */
+#define EGPDATA (0x00 | 0x80)
+#define ERXDATA (0x02 | 0x80)
+#define EUDADATA (0x04 | 0x80)
+#define EGPRDPT (0x06 | 0x80)
+#define EGPWRPT (0x08 | 0x80)
+#define ERXRDPT (0x0A | 0x80)
+#define ERXWRPT (0x0C | 0x80)
+#define EUDARDPT (0x0E | 0x80)
+#define EUDAWRPT (0x10 | 0x80)
+
+
+/* Register bit definitions */
+/* ESTAT */
+#define INT (1 << 15)
+#define FCIDLE (1 << 14)
+#define RXBUSY (1 << 13)
+#define CLKRDY (1 << 12)
+#define PHYDPX (1 << 10)
+#define PHYLNK (1 << 8)
+
+/* EIR */
+#define CRYPTEN (1 << 15)
+#define MODEXIF (1 << 14)
+#define HASHIF (1 << 13)
+#define AESIF (1 << 12)
+#define LINKIF (1 << 11)
+#define PKTIF (1 << 6)
+#define DMAIF (1 << 5)
+#define TXIF (1 << 3)
+#define TXABTIF (1 << 2)
+#define RXABTIF (1 << 1)
+#define PCFULIF (1 << 0)
+
+/* ECON1 */
+#define MODEXST (1 << 15)
+#define HASHEN (1 << 14)
+#define HASHOP (1 << 13)
+#define HASHLST (1 << 12)
+#define AESST (1 << 11)
+#define AESOP1 (1 << 10)
+#define AESOP0 (1 << 9)
+#define PKTDEC (1 << 8)
+#define FCOP1 (1 << 7)
+#define FCOP0 (1 << 6)
+#define DMAST (1 << 5)
+#define DMACPY (1 << 4)
+#define DMACSSD (1 << 3)
+#define DMANOCS (1 << 2)
+#define TXRTS (1 << 1)
+#define RXEN (1 << 0)
+
+/* ETXSTAT */
+#define LATECOL (1 << 10)
+#define MAXCOL (1 << 9)
+#define EXDEFER (1 << 8)
+#define ETXSTATL_DEFER (1 << 7)
+#define CRCBAD (1 << 4)
+#define COLCNT_MASK 0xF
+
+/* ERXFCON */
+#define HTEN (1 << 15)
+#define MPEN (1 << 14)
+#define NOTPM (1 << 12)
+#define PMEN3 (1 << 11)
+#define PMEN2 (1 << 10)
+#define PMEN1 (1 << 9)
+#define PMEN0 (1 << 8)
+#define CRCEEN (1 << 7)
+#define CRCEN (1 << 6)
+#define RUNTEEN (1 << 5)
+#define RUNTEN (1 << 4)
+#define UCEN (1 << 3)
+#define NOTMEEN (1 << 2)
+#define MCEN (1 << 1)
+#define BCEN (1 << 0)
+
+/* MACON1 */
+#define LOOPBK (1 << 4)
+#define RXPAUS (1 << 2)
+#define PASSALL (1 << 1)
+
+/* MACON2 */
+#define MACON2_DEFER (1 << 14)
+#define BPEN (1 << 13)
+#define NOBKOFF (1 << 12)
+#define PADCFG2 (1 << 7)
+#define PADCFG1 (1 << 6)
+#define PADCFG0 (1 << 5)
+#define TXCRCEN (1 << 4)
+#define PHDREN (1 << 3)
+#define HFRMEN (1 << 2)
+#define MACON2_RSV1 (1 << 1)
+#define FULDPX (1 << 0)
+
+/* MAIPG */
+/* value of the high byte is given by the reserved bits,
+ * value of the low byte is recomended setting of the
+ * IPG parameter.
+ */
+#define MAIPGH_VAL 0x0C
+#define MAIPGL_VAL 0x12
+
+/* MIREGADRH */
+#define MIREGADR_VAL (1 << 8)
+
+/* MIREGADRL */
+#define PHREG_MASK 0x1F
+
+/* MICMD */
+#define MIISCAN (1 << 1)
+#define MIIRD (1 << 0)
+
+/* MISTAT */
+#define NVALID (1 << 2)
+#define SCAN (1 << 1)
+#define BUSY (1 << 0)
+
+/* ECON2 */
+#define ETHEN (1 << 15)
+#define STRCH (1 << 14)
+#define TXMAC (1 << 13)
+#define SHA1MD5 (1 << 12)
+#define COCON3 (1 << 11)
+#define COCON2 (1 << 10)
+#define COCON1 (1 << 9)
+#define COCON0 (1 << 8)
+#define AUTOFC (1 << 7)
+#define TXRST (1 << 6)
+#define RXRST (1 << 5)
+#define ETHRST (1 << 4)
+#define MODLEN1 (1 << 3)
+#define MODLEN0 (1 << 2)
+#define AESLEN1 (1 << 1)
+#define AESLEN0 (1 << 0)
+
+/* EIE */
+#define INTIE (1 << 15)
+#define MODEXIE (1 << 14)
+#define HASHIE (1 << 13)
+#define AESIE (1 << 12)
+#define LINKIE (1 << 11)
+#define PKTIE (1 << 6)
+#define DMAIE (1 << 5)
+#define TXIE (1 << 3)
+#define TXABTIE (1 << 2)
+#define RXABTIE (1 << 1)
+#define PCFULIE (1 << 0)
+
+/* EIDLED */
+#define LACFG3 (1 << 15)
+#define LACFG2 (1 << 14)
+#define LACFG1 (1 << 13)
+#define LACFG0 (1 << 12)
+#define LBCFG3 (1 << 11)
+#define LBCFG2 (1 << 10)
+#define LBCFG1 (1 << 9)
+#define LBCFG0 (1 << 8)
+#define DEVID_SHIFT 5
+#define DEVID_MASK (0x7 << DEVID_SHIFT)
+#define REVID_SHIFT 0
+#define REVID_MASK (0x1F << REVID_SHIFT)
+
+/* PHY registers */
+#define PHCON1 0x00
+#define PHSTAT1 0x01
+#define PHANA 0x04
+#define PHANLPA 0x05
+#define PHANE 0x06
+#define PHCON2 0x11
+#define PHSTAT2 0x1B
+#define PHSTAT3 0x1F
+
+/* PHCON1 */
+#define PRST (1 << 15)
+#define PLOOPBK (1 << 14)
+#define SPD100 (1 << 13)
+#define ANEN (1 << 12)
+#define PSLEEP (1 << 11)
+#define RENEG (1 << 9)
+#define PFULDPX (1 << 8)
+
+/* PHSTAT1 */
+#define FULL100 (1 << 14)
+#define HALF100 (1 << 13)
+#define FULL10 (1 << 12)
+#define HALF10 (1 << 11)
+#define ANDONE (1 << 5)
+#define LRFAULT (1 << 4)
+#define ANABLE (1 << 3)
+#define LLSTAT (1 << 2)
+#define EXTREGS (1 << 0)
+
+/* PHSTAT2 */
+#define PLRITY (1 << 4)
+
+/* PHSTAT3 */
+#define PHY3SPD100 (1 << 3)
+#define PHY3DPX (1 << 4)
+#define SPDDPX_SHIFT 2
+#define SPDDPX_MASK (0x7 << SPDDPX_SHIFT)
+
+/* PHANA */
+/* Default value for PHY initialization*/
+#define PHANA_DEFAULT 0x05E1
+
+/* PHANE */
+#define PDFLT (1 << 4)
+#define LPARCD (1 << 1)
+#define LPANABL (1 << 0)
+
+#define EUDAST_TEST_VAL 0x1234
+
+#define TSV_SIZE 7
+
+#define ENCX24J600_DEV_ID 0x1
+
+/* Configuration */
+
+/* Led is on when the link is present and driven low
+ * temporarily when packet is TX'd or RX'd
+ */
+#define LED_A_SETTINGS 0xC
+
+/* Led is on if the link is in 100 Mbps mode */
+#define LED_B_SETTINGS 0x8
+
+/* maximum ethernet frame length
+ * Currently not used as a limit anywhere
+ * (we're using the "huge frame enable" feature of
+ * enc424j600).
+ */
+#define MAX_FRAMELEN 1518
+
+/* Size in bytes of the receive buffer in enc424j600.
+ * Must be word aligned (even).
+ */
+#define RX_BUFFER_SIZE (15 * MAX_FRAMELEN)
+
+/* Start of the general purpose area in sram */
+#define SRAM_GP_START 0x0
+
+/* SRAM size */
+#define SRAM_SIZE 0x6000
+
+/* Start of the receive buffer */
+#define ERXST_VAL (SRAM_SIZE - RX_BUFFER_SIZE)
+
+#define RSV_RXLONGEVDROPEV	16
+#define RSV_CARRIEREV		18
+#define RSV_CRCERROR		20
+#define RSV_LENCHECKERR		21
+#define RSV_LENOUTOFRANGE	22
+#define RSV_RXOK		23
+#define RSV_RXMULTICAST		24
+#define RSV_RXBROADCAST		25
+#define RSV_DRIBBLENIBBLE	26
+#define RSV_RXCONTROLFRAME	27
+#define RSV_RXPAUSEFRAME	28
+#define RSV_RXUNKNOWNOPCODE	29
+#define RSV_RXTYPEVLAN		30
+
+#define RSV_RUNTFILTERMATCH	31
+#define RSV_NOTMEFILTERMATCH	32
+#define RSV_HASHFILTERMATCH	33
+#define RSV_MAGICPKTFILTERMATCH	34
+#define RSV_PTRNMTCHFILTERMATCH	35
+#define RSV_UNICASTFILTERMATCH	36
+
+#define RSV_SIZE		8
+#define RSV_BITMASK(x)		(1 << ((x) - 16))
+#define RSV_GETBIT(x, y)	(((x) & RSV_BITMASK(y)) ? 1 : 0)
+
+struct rsv {
+	u16 next_packet;
+	u16 len;
+	u32 rxstat;
+};
+
+/* Put RX buffer at 0 as suggested by the Errata datasheet */
+
+#define RXSTART_INIT		ERXST_VAL
+#define RXEND_INIT		0x5FFF
+
+int regmap_encx24j600_spi_write(void *context, u8 reg, const u8 *data,
+				size_t count);
+int regmap_encx24j600_spi_read(void *context, u8 reg, u8 *data, size_t count);
+
+
+#endif
-- 
2.4.1
