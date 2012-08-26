From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 2/2] drivers/ieee802154: move ieee802154 drivers to net folder
Date: Sun, 26 Aug 2012 19:10:11 +0400
Message-ID: <1345993811-13803-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37262 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab2HZPPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 11:15:55 -0400
Received: by wicr5 with SMTP id r5so2733352wic.1
        for <netdev@vger.kernel.org>; Sun, 26 Aug 2012 08:15:54 -0700 (PDT)
In-Reply-To: <1345993811-13803-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The IEEE 802.15.4 standard represents a networking protocol. I don't
exactly know why drivers for this protocol are stored into the root
'driver' folder, but better will be to store them with other
networking stuff. Currently there are only 3 drivers available for
IEEE 802.15.4 stack, so lets do it now with the smallest overhead.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/Makefile                   |    1 -
 drivers/ieee802154/Kconfig         |   36 --
 drivers/ieee802154/Makefile        |    3 -
 drivers/ieee802154/at86rf230.c     |  958 ------------------------------------
 drivers/ieee802154/fakehard.c      |  449 -----------------
 drivers/ieee802154/fakelb.c        |  294 -----------
 drivers/net/Kconfig                |    4 +-
 drivers/net/Makefile               |    1 +
 drivers/net/ieee802154/Kconfig     |   36 ++
 drivers/net/ieee802154/Makefile    |    3 +
 drivers/net/ieee802154/at86rf230.c |  958 ++++++++++++++++++++++++++++++++++++
 drivers/net/ieee802154/fakehard.c  |  449 +++++++++++++++++
 drivers/net/ieee802154/fakelb.c    |  294 +++++++++++
 13 files changed, 1743 insertions(+), 1743 deletions(-)
 delete mode 100644 drivers/ieee802154/Kconfig
 delete mode 100644 drivers/ieee802154/Makefile
 delete mode 100644 drivers/ieee802154/at86rf230.c
 delete mode 100644 drivers/ieee802154/fakehard.c
 delete mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 drivers/net/ieee802154/Kconfig
 create mode 100644 drivers/net/ieee802154/Makefile
 create mode 100644 drivers/net/ieee802154/at86rf230.c
 create mode 100644 drivers/net/ieee802154/fakehard.c
 create mode 100644 drivers/net/ieee802154/fakelb.c

diff --git a/drivers/Makefile b/drivers/Makefile
index 5b42184..1ecd1bf 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -120,7 +120,6 @@ obj-$(CONFIG_VHOST_NET)		+= vhost/
 obj-$(CONFIG_VLYNQ)		+= vlynq/
 obj-$(CONFIG_STAGING)		+= staging/
 obj-y				+= platform/
-obj-y				+= ieee802154/
 #common clk code
 obj-y				+= clk/
 
diff --git a/drivers/ieee802154/Kconfig b/drivers/ieee802154/Kconfig
deleted file mode 100644
index 1fc4eef..0000000
--- a/drivers/ieee802154/Kconfig
+++ /dev/null
@@ -1,36 +0,0 @@
-menuconfig IEEE802154_DRIVERS
-	tristate "IEEE 802.15.4 drivers"
-	depends on NETDEVICES && IEEE802154
-	default y
-	---help---
-	  Say Y here to get to see options for IEEE 802.15.4 Low-Rate
-	  Wireless Personal Area Network device drivers. This option alone
-	  does not add any kernel code.
-
-	  If you say N, all options in this submenu will be skipped and
-	  disabled.
-
-config IEEE802154_FAKEHARD
-	tristate "Fake LR-WPAN driver with several interconnected devices"
-	depends on  IEEE802154_DRIVERS
-	---help---
-	  Say Y here to enable the fake driver that serves as an example
-          of HardMAC device driver.
-
-          This driver can also be built as a module. To do so say M here.
-	  The module will be called 'fakehard'.
-
-config IEEE802154_FAKELB
-	depends on IEEE802154_DRIVERS && MAC802154
-	tristate "IEEE 802.15.4 loopback driver"
-	---help---
-	  Say Y here to enable the fake driver that can emulate a net
-	  of several interconnected radio devices.
-
-	  This driver can also be built as a module. To do so say M here.
-	  The module will be called 'fakelb'.
-
-config IEEE802154_AT86RF230
-        depends on IEEE802154_DRIVERS && MAC802154
-        tristate "AT86RF230/231 transceiver driver"
-        depends on SPI
diff --git a/drivers/ieee802154/Makefile b/drivers/ieee802154/Makefile
deleted file mode 100644
index 4f4371d..0000000
--- a/drivers/ieee802154/Makefile
+++ /dev/null
@@ -1,3 +0,0 @@
-obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
-obj-$(CONFIG_IEEE802154_FAKELB) += fakelb.o
-obj-$(CONFIG_IEEE802154_AT86RF230) += at86rf230.o
diff --git a/drivers/ieee802154/at86rf230.c b/drivers/ieee802154/at86rf230.c
deleted file mode 100644
index ba753d8..0000000
--- a/drivers/ieee802154/at86rf230.c
+++ /dev/null
@@ -1,958 +0,0 @@
-/*
- * AT86RF230/RF231 driver
- *
- * Copyright (C) 2009-2012 Siemens AG
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
- *
- * Written by:
- * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
- * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
- */
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/interrupt.h>
-#include <linux/gpio.h>
-#include <linux/delay.h>
-#include <linux/mutex.h>
-#include <linux/workqueue.h>
-#include <linux/spinlock.h>
-#include <linux/spi/spi.h>
-#include <linux/spi/at86rf230.h>
-#include <linux/skbuff.h>
-
-#include <net/mac802154.h>
-#include <net/wpan-phy.h>
-
-struct at86rf230_local {
-	struct spi_device *spi;
-	int rstn, slp_tr, dig2;
-
-	u8 part;
-	u8 vers;
-
-	u8 buf[2];
-	struct mutex bmux;
-
-	struct work_struct irqwork;
-	struct completion tx_complete;
-
-	struct ieee802154_dev *dev;
-
-	spinlock_t lock;
-	bool irq_disabled;
-	bool is_tx;
-};
-
-#define	RG_TRX_STATUS	(0x01)
-#define	SR_TRX_STATUS		0x01, 0x1f, 0
-#define	SR_RESERVED_01_3	0x01, 0x20, 5
-#define	SR_CCA_STATUS		0x01, 0x40, 6
-#define	SR_CCA_DONE		0x01, 0x80, 7
-#define	RG_TRX_STATE	(0x02)
-#define	SR_TRX_CMD		0x02, 0x1f, 0
-#define	SR_TRAC_STATUS		0x02, 0xe0, 5
-#define	RG_TRX_CTRL_0	(0x03)
-#define	SR_CLKM_CTRL		0x03, 0x07, 0
-#define	SR_CLKM_SHA_SEL		0x03, 0x08, 3
-#define	SR_PAD_IO_CLKM		0x03, 0x30, 4
-#define	SR_PAD_IO		0x03, 0xc0, 6
-#define	RG_TRX_CTRL_1	(0x04)
-#define	SR_IRQ_POLARITY		0x04, 0x01, 0
-#define	SR_IRQ_MASK_MODE	0x04, 0x02, 1
-#define	SR_SPI_CMD_MODE		0x04, 0x0c, 2
-#define	SR_RX_BL_CTRL		0x04, 0x10, 4
-#define	SR_TX_AUTO_CRC_ON	0x04, 0x20, 5
-#define	SR_IRQ_2_EXT_EN		0x04, 0x40, 6
-#define	SR_PA_EXT_EN		0x04, 0x80, 7
-#define	RG_PHY_TX_PWR	(0x05)
-#define	SR_TX_PWR		0x05, 0x0f, 0
-#define	SR_PA_LT		0x05, 0x30, 4
-#define	SR_PA_BUF_LT		0x05, 0xc0, 6
-#define	RG_PHY_RSSI	(0x06)
-#define	SR_RSSI			0x06, 0x1f, 0
-#define	SR_RND_VALUE		0x06, 0x60, 5
-#define	SR_RX_CRC_VALID		0x06, 0x80, 7
-#define	RG_PHY_ED_LEVEL	(0x07)
-#define	SR_ED_LEVEL		0x07, 0xff, 0
-#define	RG_PHY_CC_CCA	(0x08)
-#define	SR_CHANNEL		0x08, 0x1f, 0
-#define	SR_CCA_MODE		0x08, 0x60, 5
-#define	SR_CCA_REQUEST		0x08, 0x80, 7
-#define	RG_CCA_THRES	(0x09)
-#define	SR_CCA_ED_THRES		0x09, 0x0f, 0
-#define	SR_RESERVED_09_1	0x09, 0xf0, 4
-#define	RG_RX_CTRL	(0x0a)
-#define	SR_PDT_THRES		0x0a, 0x0f, 0
-#define	SR_RESERVED_0a_1	0x0a, 0xf0, 4
-#define	RG_SFD_VALUE	(0x0b)
-#define	SR_SFD_VALUE		0x0b, 0xff, 0
-#define	RG_TRX_CTRL_2	(0x0c)
-#define	SR_OQPSK_DATA_RATE	0x0c, 0x03, 0
-#define	SR_RESERVED_0c_2	0x0c, 0x7c, 2
-#define	SR_RX_SAFE_MODE		0x0c, 0x80, 7
-#define	RG_ANT_DIV	(0x0d)
-#define	SR_ANT_CTRL		0x0d, 0x03, 0
-#define	SR_ANT_EXT_SW_EN	0x0d, 0x04, 2
-#define	SR_ANT_DIV_EN		0x0d, 0x08, 3
-#define	SR_RESERVED_0d_2	0x0d, 0x70, 4
-#define	SR_ANT_SEL		0x0d, 0x80, 7
-#define	RG_IRQ_MASK	(0x0e)
-#define	SR_IRQ_MASK		0x0e, 0xff, 0
-#define	RG_IRQ_STATUS	(0x0f)
-#define	SR_IRQ_0_PLL_LOCK	0x0f, 0x01, 0
-#define	SR_IRQ_1_PLL_UNLOCK	0x0f, 0x02, 1
-#define	SR_IRQ_2_RX_START	0x0f, 0x04, 2
-#define	SR_IRQ_3_TRX_END	0x0f, 0x08, 3
-#define	SR_IRQ_4_CCA_ED_DONE	0x0f, 0x10, 4
-#define	SR_IRQ_5_AMI		0x0f, 0x20, 5
-#define	SR_IRQ_6_TRX_UR		0x0f, 0x40, 6
-#define	SR_IRQ_7_BAT_LOW	0x0f, 0x80, 7
-#define	RG_VREG_CTRL	(0x10)
-#define	SR_RESERVED_10_6	0x10, 0x03, 0
-#define	SR_DVDD_OK		0x10, 0x04, 2
-#define	SR_DVREG_EXT		0x10, 0x08, 3
-#define	SR_RESERVED_10_3	0x10, 0x30, 4
-#define	SR_AVDD_OK		0x10, 0x40, 6
-#define	SR_AVREG_EXT		0x10, 0x80, 7
-#define	RG_BATMON	(0x11)
-#define	SR_BATMON_VTH		0x11, 0x0f, 0
-#define	SR_BATMON_HR		0x11, 0x10, 4
-#define	SR_BATMON_OK		0x11, 0x20, 5
-#define	SR_RESERVED_11_1	0x11, 0xc0, 6
-#define	RG_XOSC_CTRL	(0x12)
-#define	SR_XTAL_TRIM		0x12, 0x0f, 0
-#define	SR_XTAL_MODE		0x12, 0xf0, 4
-#define	RG_RX_SYN	(0x15)
-#define	SR_RX_PDT_LEVEL		0x15, 0x0f, 0
-#define	SR_RESERVED_15_2	0x15, 0x70, 4
-#define	SR_RX_PDT_DIS		0x15, 0x80, 7
-#define	RG_XAH_CTRL_1	(0x17)
-#define	SR_RESERVED_17_8	0x17, 0x01, 0
-#define	SR_AACK_PROM_MODE	0x17, 0x02, 1
-#define	SR_AACK_ACK_TIME	0x17, 0x04, 2
-#define	SR_RESERVED_17_5	0x17, 0x08, 3
-#define	SR_AACK_UPLD_RES_FT	0x17, 0x10, 4
-#define	SR_AACK_FLTR_RES_FT	0x17, 0x20, 5
-#define	SR_RESERVED_17_2	0x17, 0x40, 6
-#define	SR_RESERVED_17_1	0x17, 0x80, 7
-#define	RG_FTN_CTRL	(0x18)
-#define	SR_RESERVED_18_2	0x18, 0x7f, 0
-#define	SR_FTN_START		0x18, 0x80, 7
-#define	RG_PLL_CF	(0x1a)
-#define	SR_RESERVED_1a_2	0x1a, 0x7f, 0
-#define	SR_PLL_CF_START		0x1a, 0x80, 7
-#define	RG_PLL_DCU	(0x1b)
-#define	SR_RESERVED_1b_3	0x1b, 0x3f, 0
-#define	SR_RESERVED_1b_2	0x1b, 0x40, 6
-#define	SR_PLL_DCU_START	0x1b, 0x80, 7
-#define	RG_PART_NUM	(0x1c)
-#define	SR_PART_NUM		0x1c, 0xff, 0
-#define	RG_VERSION_NUM	(0x1d)
-#define	SR_VERSION_NUM		0x1d, 0xff, 0
-#define	RG_MAN_ID_0	(0x1e)
-#define	SR_MAN_ID_0		0x1e, 0xff, 0
-#define	RG_MAN_ID_1	(0x1f)
-#define	SR_MAN_ID_1		0x1f, 0xff, 0
-#define	RG_SHORT_ADDR_0	(0x20)
-#define	SR_SHORT_ADDR_0		0x20, 0xff, 0
-#define	RG_SHORT_ADDR_1	(0x21)
-#define	SR_SHORT_ADDR_1		0x21, 0xff, 0
-#define	RG_PAN_ID_0	(0x22)
-#define	SR_PAN_ID_0		0x22, 0xff, 0
-#define	RG_PAN_ID_1	(0x23)
-#define	SR_PAN_ID_1		0x23, 0xff, 0
-#define	RG_IEEE_ADDR_0	(0x24)
-#define	SR_IEEE_ADDR_0		0x24, 0xff, 0
-#define	RG_IEEE_ADDR_1	(0x25)
-#define	SR_IEEE_ADDR_1		0x25, 0xff, 0
-#define	RG_IEEE_ADDR_2	(0x26)
-#define	SR_IEEE_ADDR_2		0x26, 0xff, 0
-#define	RG_IEEE_ADDR_3	(0x27)
-#define	SR_IEEE_ADDR_3		0x27, 0xff, 0
-#define	RG_IEEE_ADDR_4	(0x28)
-#define	SR_IEEE_ADDR_4		0x28, 0xff, 0
-#define	RG_IEEE_ADDR_5	(0x29)
-#define	SR_IEEE_ADDR_5		0x29, 0xff, 0
-#define	RG_IEEE_ADDR_6	(0x2a)
-#define	SR_IEEE_ADDR_6		0x2a, 0xff, 0
-#define	RG_IEEE_ADDR_7	(0x2b)
-#define	SR_IEEE_ADDR_7		0x2b, 0xff, 0
-#define	RG_XAH_CTRL_0	(0x2c)
-#define	SR_SLOTTED_OPERATION	0x2c, 0x01, 0
-#define	SR_MAX_CSMA_RETRIES	0x2c, 0x0e, 1
-#define	SR_MAX_FRAME_RETRIES	0x2c, 0xf0, 4
-#define	RG_CSMA_SEED_0	(0x2d)
-#define	SR_CSMA_SEED_0		0x2d, 0xff, 0
-#define	RG_CSMA_SEED_1	(0x2e)
-#define	SR_CSMA_SEED_1		0x2e, 0x07, 0
-#define	SR_AACK_I_AM_COORD	0x2e, 0x08, 3
-#define	SR_AACK_DIS_ACK		0x2e, 0x10, 4
-#define	SR_AACK_SET_PD		0x2e, 0x20, 5
-#define	SR_AACK_FVN_MODE	0x2e, 0xc0, 6
-#define	RG_CSMA_BE	(0x2f)
-#define	SR_MIN_BE		0x2f, 0x0f, 0
-#define	SR_MAX_BE		0x2f, 0xf0, 4
-
-#define CMD_REG		0x80
-#define CMD_REG_MASK	0x3f
-#define CMD_WRITE	0x40
-#define CMD_FB		0x20
-
-#define IRQ_BAT_LOW	(1 << 7)
-#define IRQ_TRX_UR	(1 << 6)
-#define IRQ_AMI		(1 << 5)
-#define IRQ_CCA_ED	(1 << 4)
-#define IRQ_TRX_END	(1 << 3)
-#define IRQ_RX_START	(1 << 2)
-#define IRQ_PLL_UNL	(1 << 1)
-#define IRQ_PLL_LOCK	(1 << 0)
-
-#define STATE_P_ON		0x00	/* BUSY */
-#define STATE_BUSY_RX		0x01
-#define STATE_BUSY_TX		0x02
-#define STATE_FORCE_TRX_OFF	0x03
-#define STATE_FORCE_TX_ON	0x04	/* IDLE */
-/* 0x05 */				/* INVALID_PARAMETER */
-#define STATE_RX_ON		0x06
-/* 0x07 */				/* SUCCESS */
-#define STATE_TRX_OFF		0x08
-#define STATE_TX_ON		0x09
-/* 0x0a - 0x0e */			/* 0x0a - UNSUPPORTED_ATTRIBUTE */
-#define STATE_SLEEP		0x0F
-#define STATE_BUSY_RX_AACK	0x11
-#define STATE_BUSY_TX_ARET	0x12
-#define STATE_BUSY_RX_AACK_ON	0x16
-#define STATE_BUSY_TX_ARET_ON	0x19
-#define STATE_RX_ON_NOCLK	0x1C
-#define STATE_RX_AACK_ON_NOCLK	0x1D
-#define STATE_BUSY_RX_AACK_NOCLK 0x1E
-#define STATE_TRANSITION_IN_PROGRESS 0x1F
-
-static int
-__at86rf230_write(struct at86rf230_local *lp, u8 addr, u8 data)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer = {
-		.len	= 2,
-		.tx_buf	= buf,
-	};
-
-	buf[0] = (addr & CMD_REG_MASK) | CMD_REG | CMD_WRITE;
-	buf[1] = data;
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	return status;
-}
-
-static int
-__at86rf230_read_subreg(struct at86rf230_local *lp,
-			u8 addr, u8 mask, int shift, u8 *data)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer = {
-		.len	= 2,
-		.tx_buf	= buf,
-		.rx_buf	= buf,
-	};
-
-	buf[0] = (addr & CMD_REG_MASK) | CMD_REG;
-	buf[1] = 0xff;
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	if (status == 0)
-		*data = buf[1];
-
-	return status;
-}
-
-static int
-at86rf230_read_subreg(struct at86rf230_local *lp,
-		      u8 addr, u8 mask, int shift, u8 *data)
-{
-	int status;
-
-	mutex_lock(&lp->bmux);
-	status = __at86rf230_read_subreg(lp, addr, mask, shift, data);
-	mutex_unlock(&lp->bmux);
-
-	return status;
-}
-
-static int
-at86rf230_write_subreg(struct at86rf230_local *lp,
-		       u8 addr, u8 mask, int shift, u8 data)
-{
-	int status;
-	u8 val;
-
-	mutex_lock(&lp->bmux);
-	status = __at86rf230_read_subreg(lp, addr, 0xff, 0, &val);
-	if (status)
-		goto out;
-
-	val &= ~mask;
-	val |= (data << shift) & mask;
-
-	status = __at86rf230_write(lp, addr, val);
-out:
-	mutex_unlock(&lp->bmux);
-
-	return status;
-}
-
-static int
-at86rf230_write_fbuf(struct at86rf230_local *lp, u8 *data, u8 len)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer_head = {
-		.len		= 2,
-		.tx_buf		= buf,
-
-	};
-	struct spi_transfer xfer_buf = {
-		.len		= len,
-		.tx_buf		= data,
-	};
-
-	mutex_lock(&lp->bmux);
-	buf[0] = CMD_WRITE | CMD_FB;
-	buf[1] = len + 2; /* 2 bytes for CRC that isn't written */
-
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head, &msg);
-	spi_message_add_tail(&xfer_buf, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	mutex_unlock(&lp->bmux);
-	return status;
-}
-
-static int
-at86rf230_read_fbuf(struct at86rf230_local *lp, u8 *data, u8 *len, u8 *lqi)
-{
-	u8 *buf = lp->buf;
-	int status;
-	struct spi_message msg;
-	struct spi_transfer xfer_head = {
-		.len		= 2,
-		.tx_buf		= buf,
-		.rx_buf		= buf,
-	};
-	struct spi_transfer xfer_head1 = {
-		.len		= 2,
-		.tx_buf		= buf,
-		.rx_buf		= buf,
-	};
-	struct spi_transfer xfer_buf = {
-		.len		= 0,
-		.rx_buf		= data,
-	};
-
-	mutex_lock(&lp->bmux);
-
-	buf[0] = CMD_FB;
-	buf[1] = 0x00;
-
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-
-	xfer_buf.len = *(buf + 1) + 1;
-	*len = buf[1];
-
-	buf[0] = CMD_FB;
-	buf[1] = 0x00;
-
-	spi_message_init(&msg);
-	spi_message_add_tail(&xfer_head1, &msg);
-	spi_message_add_tail(&xfer_buf, &msg);
-
-	status = spi_sync(lp->spi, &msg);
-
-	if (msg.status)
-		status = msg.status;
-
-	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
-	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
-	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
-
-	if (status) {
-		if (lqi && (*len > lp->buf[1]))
-			*lqi = data[lp->buf[1]];
-	}
-	mutex_unlock(&lp->bmux);
-
-	return status;
-}
-
-static int
-at86rf230_ed(struct ieee802154_dev *dev, u8 *level)
-{
-	might_sleep();
-	BUG_ON(!level);
-	*level = 0xbe;
-	return 0;
-}
-
-static int
-at86rf230_state(struct ieee802154_dev *dev, int state)
-{
-	struct at86rf230_local *lp = dev->priv;
-	int rc;
-	u8 val;
-	u8 desired_status;
-
-	might_sleep();
-
-	if (state == STATE_FORCE_TX_ON)
-		desired_status = STATE_TX_ON;
-	else if (state == STATE_FORCE_TRX_OFF)
-		desired_status = STATE_TRX_OFF;
-	else
-		desired_status = state;
-
-	do {
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
-		if (rc)
-			goto err;
-	} while (val == STATE_TRANSITION_IN_PROGRESS);
-
-	if (val == desired_status)
-		return 0;
-
-	/* state is equal to phy states */
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, state);
-	if (rc)
-		goto err;
-
-	do {
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
-		if (rc)
-			goto err;
-	} while (val == STATE_TRANSITION_IN_PROGRESS);
-
-
-	if (val == desired_status)
-		return 0;
-
-	pr_err("unexpected state change: %d, asked for %d\n", val, state);
-	return -EBUSY;
-
-err:
-	pr_err("error: %d\n", rc);
-	return rc;
-}
-
-static int
-at86rf230_start(struct ieee802154_dev *dev)
-{
-	struct at86rf230_local *lp = dev->priv;
-	u8 rc;
-
-	rc = at86rf230_write_subreg(lp, SR_RX_SAFE_MODE, 1);
-	if (rc)
-		return rc;
-
-	return at86rf230_state(dev, STATE_RX_ON);
-}
-
-static void
-at86rf230_stop(struct ieee802154_dev *dev)
-{
-	at86rf230_state(dev, STATE_FORCE_TRX_OFF);
-}
-
-static int
-at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
-{
-	struct at86rf230_local *lp = dev->priv;
-	int rc;
-
-	might_sleep();
-
-	if (page != 0 || channel < 11 || channel > 26) {
-		WARN_ON(1);
-		return -EINVAL;
-	}
-
-	rc = at86rf230_write_subreg(lp, SR_CHANNEL, channel);
-	msleep(1); /* Wait for PLL */
-	dev->phy->current_channel = channel;
-
-	return 0;
-}
-
-static int
-at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
-{
-	struct at86rf230_local *lp = dev->priv;
-	int rc;
-	unsigned long flags;
-
-	spin_lock(&lp->lock);
-	if  (lp->irq_disabled) {
-		spin_unlock(&lp->lock);
-		return -EBUSY;
-	}
-	spin_unlock(&lp->lock);
-
-	might_sleep();
-
-	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
-	if (rc)
-		goto err;
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->is_tx = 1;
-	INIT_COMPLETION(lp->tx_complete);
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	rc = at86rf230_write_fbuf(lp, skb->data, skb->len);
-	if (rc)
-		goto err_rx;
-
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_BUSY_TX);
-	if (rc)
-		goto err_rx;
-
-	rc = wait_for_completion_interruptible(&lp->tx_complete);
-	if (rc < 0)
-		goto err_rx;
-
-	rc = at86rf230_start(dev);
-
-	return rc;
-
-err_rx:
-	at86rf230_start(dev);
-err:
-	pr_err("error: %d\n", rc);
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->is_tx = 0;
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	return rc;
-}
-
-static int at86rf230_rx(struct at86rf230_local *lp)
-{
-	u8 len = 128, lqi = 0;
-	struct sk_buff *skb;
-
-	skb = alloc_skb(len, GFP_KERNEL);
-
-	if (!skb)
-		return -ENOMEM;
-
-	if (at86rf230_read_fbuf(lp, skb_put(skb, len), &len, &lqi))
-		goto err;
-
-	if (len < 2)
-		goto err;
-
-	skb_trim(skb, len - 2); /* We do not put CRC into the frame */
-
-	ieee802154_rx_irqsafe(lp->dev, skb, lqi);
-
-	dev_dbg(&lp->spi->dev, "READ_FBUF: %d %x\n", len, lqi);
-
-	return 0;
-err:
-	pr_debug("received frame is too small\n");
-
-	kfree_skb(skb);
-	return -EINVAL;
-}
-
-static struct ieee802154_ops at86rf230_ops = {
-	.owner = THIS_MODULE,
-	.xmit = at86rf230_xmit,
-	.ed = at86rf230_ed,
-	.set_channel = at86rf230_channel,
-	.start = at86rf230_start,
-	.stop = at86rf230_stop,
-};
-
-static void at86rf230_irqwork(struct work_struct *work)
-{
-	struct at86rf230_local *lp =
-		container_of(work, struct at86rf230_local, irqwork);
-	u8 status = 0, val;
-	int rc;
-	unsigned long flags;
-
-	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &val);
-	status |= val;
-
-	status &= ~IRQ_PLL_LOCK; /* ignore */
-	status &= ~IRQ_RX_START; /* ignore */
-	status &= ~IRQ_AMI; /* ignore */
-	status &= ~IRQ_TRX_UR; /* FIXME: possibly handle ???*/
-
-	if (status & IRQ_TRX_END) {
-		spin_lock_irqsave(&lp->lock, flags);
-		status &= ~IRQ_TRX_END;
-		if (lp->is_tx) {
-			lp->is_tx = 0;
-			spin_unlock_irqrestore(&lp->lock, flags);
-			complete(&lp->tx_complete);
-		} else {
-			spin_unlock_irqrestore(&lp->lock, flags);
-			at86rf230_rx(lp);
-		}
-	}
-
-	spin_lock_irqsave(&lp->lock, flags);
-	lp->irq_disabled = 0;
-	spin_unlock_irqrestore(&lp->lock, flags);
-
-	enable_irq(lp->spi->irq);
-}
-
-static irqreturn_t at86rf230_isr(int irq, void *data)
-{
-	struct at86rf230_local *lp = data;
-
-	disable_irq_nosync(irq);
-
-	spin_lock(&lp->lock);
-	lp->irq_disabled = 1;
-	spin_unlock(&lp->lock);
-
-	schedule_work(&lp->irqwork);
-
-	return IRQ_HANDLED;
-}
-
-
-static int at86rf230_hw_init(struct at86rf230_local *lp)
-{
-	u8 status;
-	int rc;
-
-	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-	if (rc)
-		return rc;
-
-	dev_info(&lp->spi->dev, "Status: %02x\n", status);
-	if (status == STATE_P_ON) {
-		rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TRX_OFF);
-		if (rc)
-			return rc;
-		msleep(1);
-		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-		if (rc)
-			return rc;
-		dev_info(&lp->spi->dev, "Status: %02x\n", status);
-	}
-
-	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, 0xff); /* IRQ_TRX_UR |
-							     * IRQ_CCA_ED |
-							     * IRQ_TRX_END |
-							     * IRQ_PLL_UNL |
-							     * IRQ_PLL_LOCK
-							     */
-	if (rc)
-		return rc;
-
-	/* CLKM changes are applied immediately */
-	rc = at86rf230_write_subreg(lp, SR_CLKM_SHA_SEL, 0x00);
-	if (rc)
-		return rc;
-
-	/* Turn CLKM Off */
-	rc = at86rf230_write_subreg(lp, SR_CLKM_CTRL, 0x00);
-	if (rc)
-		return rc;
-	/* Wait the next SLEEP cycle */
-	msleep(100);
-
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TX_ON);
-	if (rc)
-		return rc;
-	msleep(1);
-
-	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
-	if (rc)
-		return rc;
-	dev_info(&lp->spi->dev, "Status: %02x\n", status);
-
-	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &status);
-	if (rc)
-		return rc;
-	if (!status) {
-		dev_err(&lp->spi->dev, "DVDD error\n");
-		return -EINVAL;
-	}
-
-	rc = at86rf230_read_subreg(lp, SR_AVDD_OK, &status);
-	if (rc)
-		return rc;
-	if (!status) {
-		dev_err(&lp->spi->dev, "AVDD error\n");
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static int at86rf230_suspend(struct spi_device *spi, pm_message_t message)
-{
-	return 0;
-}
-
-static int at86rf230_resume(struct spi_device *spi)
-{
-	return 0;
-}
-
-static int at86rf230_fill_data(struct spi_device *spi)
-{
-	struct at86rf230_local *lp = spi_get_drvdata(spi);
-	struct at86rf230_platform_data *pdata = spi->dev.platform_data;
-
-	if (!pdata) {
-		dev_err(&spi->dev, "no platform_data\n");
-		return -EINVAL;
-	}
-
-	lp->rstn = pdata->rstn;
-	lp->slp_tr = pdata->slp_tr;
-	lp->dig2 = pdata->dig2;
-
-	return 0;
-}
-
-static int __devinit at86rf230_probe(struct spi_device *spi)
-{
-	struct ieee802154_dev *dev;
-	struct at86rf230_local *lp;
-	u8 man_id_0, man_id_1;
-	int rc;
-	const char *chip;
-	int supported = 0;
-
-	if (!spi->irq) {
-		dev_err(&spi->dev, "no IRQ specified\n");
-		return -EINVAL;
-	}
-
-	dev = ieee802154_alloc_device(sizeof(*lp), &at86rf230_ops);
-	if (!dev)
-		return -ENOMEM;
-
-	lp = dev->priv;
-	lp->dev = dev;
-
-	lp->spi = spi;
-
-	dev->priv = lp;
-	dev->parent = &spi->dev;
-	dev->extra_tx_headroom = 0;
-	/* We do support only 2.4 Ghz */
-	dev->phy->channels_supported[0] = 0x7FFF800;
-	dev->flags = IEEE802154_HW_OMIT_CKSUM;
-
-	mutex_init(&lp->bmux);
-	INIT_WORK(&lp->irqwork, at86rf230_irqwork);
-	spin_lock_init(&lp->lock);
-	init_completion(&lp->tx_complete);
-
-	spi_set_drvdata(spi, lp);
-
-	rc = at86rf230_fill_data(spi);
-	if (rc)
-		goto err_fill;
-
-	rc = gpio_request(lp->rstn, "rstn");
-	if (rc)
-		goto err_rstn;
-
-	if (gpio_is_valid(lp->slp_tr)) {
-		rc = gpio_request(lp->slp_tr, "slp_tr");
-		if (rc)
-			goto err_slp_tr;
-	}
-
-	rc = gpio_direction_output(lp->rstn, 1);
-	if (rc)
-		goto err_gpio_dir;
-
-	if (gpio_is_valid(lp->slp_tr)) {
-		rc = gpio_direction_output(lp->slp_tr, 0);
-		if (rc)
-			goto err_gpio_dir;
-	}
-
-	/* Reset */
-	msleep(1);
-	gpio_set_value(lp->rstn, 0);
-	msleep(1);
-	gpio_set_value(lp->rstn, 1);
-	msleep(1);
-
-	rc = at86rf230_read_subreg(lp, SR_MAN_ID_0, &man_id_0);
-	if (rc)
-		goto err_gpio_dir;
-	rc = at86rf230_read_subreg(lp, SR_MAN_ID_1, &man_id_1);
-	if (rc)
-		goto err_gpio_dir;
-
-	if (man_id_1 != 0x00 || man_id_0 != 0x1f) {
-		dev_err(&spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
-			man_id_1, man_id_0);
-		rc = -EINVAL;
-		goto err_gpio_dir;
-	}
-
-	rc = at86rf230_read_subreg(lp, SR_PART_NUM, &lp->part);
-	if (rc)
-		goto err_gpio_dir;
-
-	rc = at86rf230_read_subreg(lp, SR_VERSION_NUM, &lp->vers);
-	if (rc)
-		goto err_gpio_dir;
-
-	switch (lp->part) {
-	case 2:
-		chip = "at86rf230";
-		/* supported = 1;  FIXME: should be easy to support; */
-		break;
-	case 3:
-		chip = "at86rf231";
-		supported = 1;
-		break;
-	default:
-		chip = "UNKNOWN";
-		break;
-	}
-
-	dev_info(&spi->dev, "Detected %s chip version %d\n", chip, lp->vers);
-	if (!supported) {
-		rc = -ENOTSUPP;
-		goto err_gpio_dir;
-	}
-
-	rc = at86rf230_hw_init(lp);
-	if (rc)
-		goto err_gpio_dir;
-
-	rc = request_irq(spi->irq, at86rf230_isr, IRQF_SHARED,
-			 dev_name(&spi->dev), lp);
-	if (rc)
-		goto err_gpio_dir;
-
-	rc = ieee802154_register_device(lp->dev);
-	if (rc)
-		goto err_irq;
-
-	return rc;
-
-	ieee802154_unregister_device(lp->dev);
-err_irq:
-	free_irq(spi->irq, lp);
-	flush_work(&lp->irqwork);
-err_gpio_dir:
-	if (gpio_is_valid(lp->slp_tr))
-		gpio_free(lp->slp_tr);
-err_slp_tr:
-	gpio_free(lp->rstn);
-err_rstn:
-err_fill:
-	spi_set_drvdata(spi, NULL);
-	mutex_destroy(&lp->bmux);
-	ieee802154_free_device(lp->dev);
-	return rc;
-}
-
-static int __devexit at86rf230_remove(struct spi_device *spi)
-{
-	struct at86rf230_local *lp = spi_get_drvdata(spi);
-
-	ieee802154_unregister_device(lp->dev);
-
-	free_irq(spi->irq, lp);
-	flush_work(&lp->irqwork);
-
-	if (gpio_is_valid(lp->slp_tr))
-		gpio_free(lp->slp_tr);
-	gpio_free(lp->rstn);
-
-	spi_set_drvdata(spi, NULL);
-	mutex_destroy(&lp->bmux);
-	ieee802154_free_device(lp->dev);
-
-	dev_dbg(&spi->dev, "unregistered at86rf230\n");
-	return 0;
-}
-
-static struct spi_driver at86rf230_driver = {
-	.driver = {
-		.name	= "at86rf230",
-		.owner	= THIS_MODULE,
-	},
-	.probe      = at86rf230_probe,
-	.remove     = __devexit_p(at86rf230_remove),
-	.suspend    = at86rf230_suspend,
-	.resume     = at86rf230_resume,
-};
-
-module_spi_driver(at86rf230_driver);
-
-MODULE_DESCRIPTION("AT86RF230 Transceiver Driver");
-MODULE_LICENSE("GPL v2");
diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
deleted file mode 100644
index 73d4531..0000000
--- a/drivers/ieee802154/fakehard.c
+++ /dev/null
@@ -1,449 +0,0 @@
-/*
- * Sample driver for HardMAC IEEE 802.15.4 devices
- *
- * Copyright (C) 2009 Siemens AG
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
- *
- * Written by:
- * Dmitry Eremin-Solenikov <dmitry.baryshkov@siemens.com>
- */
-#include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/platform_device.h>
-#include <linux/netdevice.h>
-#include <linux/skbuff.h>
-#include <linux/if_arp.h>
-
-#include <net/af_ieee802154.h>
-#include <net/ieee802154_netdev.h>
-#include <net/ieee802154.h>
-#include <net/nl802154.h>
-#include <net/wpan-phy.h>
-
-struct fakehard_priv {
-	struct wpan_phy *phy;
-};
-
-static struct wpan_phy *fake_to_phy(const struct net_device *dev)
-{
-	struct fakehard_priv *priv = netdev_priv(dev);
-	return priv->phy;
-}
-
-/**
- * fake_get_phy - Return a phy corresponding to this device.
- * @dev: The network device for which to return the wan-phy object
- *
- * This function returns a wpan-phy object corresponding to the passed
- * network device. Reference counter for wpan-phy object is incremented,
- * so when the wpan-phy isn't necessary, you should drop the reference
- * via @wpan_phy_put() call.
- */
-static struct wpan_phy *fake_get_phy(const struct net_device *dev)
-{
-	struct wpan_phy *phy = fake_to_phy(dev);
-	return to_phy(get_device(&phy->dev));
-}
-
-/**
- * fake_get_pan_id - Retrieve the PAN ID of the device.
- * @dev: The network device to retrieve the PAN of.
- *
- * Return the ID of the PAN from the PIB.
- */
-static u16 fake_get_pan_id(const struct net_device *dev)
-{
-	BUG_ON(dev->type != ARPHRD_IEEE802154);
-
-	return 0xeba1;
-}
-
-/**
- * fake_get_short_addr - Retrieve the short address of the device.
- * @dev: The network device to retrieve the short address of.
- *
- * Returns the IEEE 802.15.4 short-form address cached for this
- * device. If the device has not yet had a short address assigned
- * then this should return 0xFFFF to indicate a lack of association.
- */
-static u16 fake_get_short_addr(const struct net_device *dev)
-{
-	BUG_ON(dev->type != ARPHRD_IEEE802154);
-
-	return 0x1;
-}
-
-/**
- * fake_get_dsn - Retrieve the DSN of the device.
- * @dev: The network device to retrieve the DSN for.
- *
- * Returns the IEEE 802.15.4 DSN for the network device.
- * The DSN is the sequence number which will be added to each
- * packet or MAC command frame by the MAC during transmission.
- *
- * DSN means 'Data Sequence Number'.
- *
- * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
- *       document.
- */
-static u8 fake_get_dsn(const struct net_device *dev)
-{
-	BUG_ON(dev->type != ARPHRD_IEEE802154);
-
-	return 0x00; /* DSN are implemented in HW, so return just 0 */
-}
-
-/**
- * fake_get_bsn - Retrieve the BSN of the device.
- * @dev: The network device to retrieve the BSN for.
- *
- * Returns the IEEE 802.15.4 BSN for the network device.
- * The BSN is the sequence number which will be added to each
- * beacon frame sent by the MAC.
- *
- * BSN means 'Beacon Sequence Number'.
- *
- * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
- *       document.
- */
-static u8 fake_get_bsn(const struct net_device *dev)
-{
-	BUG_ON(dev->type != ARPHRD_IEEE802154);
-
-	return 0x00; /* BSN are implemented in HW, so return just 0 */
-}
-
-/**
- * fake_assoc_req - Make an association request to the HW.
- * @dev: The network device which we are associating to a network.
- * @addr: The coordinator with which we wish to associate.
- * @channel: The channel on which to associate.
- * @cap: The capability information field to use in the association.
- *
- * Start an association with a coordinator. The coordinator's address
- * and PAN ID can be found in @addr.
- *
- * Note: This is in section 7.3.1 and 7.5.3.1 of the IEEE
- *       802.15.4-2006 document.
- */
-static int fake_assoc_req(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
-{
-	struct wpan_phy *phy = fake_to_phy(dev);
-
-	mutex_lock(&phy->pib_lock);
-	phy->current_channel = channel;
-	phy->current_page = page;
-	mutex_unlock(&phy->pib_lock);
-
-	/* We simply emulate it here */
-	return ieee802154_nl_assoc_confirm(dev, fake_get_short_addr(dev),
-			IEEE802154_SUCCESS);
-}
-
-/**
- * fake_assoc_resp - Send an association response to a device.
- * @dev: The network device on which to send the response.
- * @addr: The address of the device to respond to.
- * @short_addr: The assigned short address for the device (if any).
- * @status: The result of the association request.
- *
- * Queue the association response of the coordinator to another
- * device's attempt to associate with the network which we
- * coordinate. This is then added to the indirect-send queue to be
- * transmitted to the end device when it polls for data.
- *
- * Note: This is in section 7.3.2 and 7.5.3.1 of the IEEE
- *       802.15.4-2006 document.
- */
-static int fake_assoc_resp(struct net_device *dev,
-		struct ieee802154_addr *addr, u16 short_addr, u8 status)
-{
-	return 0;
-}
-
-/**
- * fake_disassoc_req - Disassociate a device from a network.
- * @dev: The network device on which we're disassociating a device.
- * @addr: The device to disassociate from the network.
- * @reason: The reason to give to the device for being disassociated.
- *
- * This sends a disassociation notification to the device being
- * disassociated from the network.
- *
- * Note: This is in section 7.5.3.2 of the IEEE 802.15.4-2006
- *       document, with the reason described in 7.3.3.2.
- */
-static int fake_disassoc_req(struct net_device *dev,
-		struct ieee802154_addr *addr, u8 reason)
-{
-	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
-}
-
-/**
- * fake_start_req - Start an IEEE 802.15.4 PAN.
- * @dev: The network device on which to start the PAN.
- * @addr: The coordinator address to use when starting the PAN.
- * @channel: The channel on which to start the PAN.
- * @bcn_ord: Beacon order.
- * @sf_ord: Superframe order.
- * @pan_coord: Whether or not we are the PAN coordinator or just
- *             requesting a realignment perhaps?
- * @blx: Battery Life Extension feature bitfield.
- * @coord_realign: Something to realign something else.
- *
- * If pan_coord is non-zero then this starts a network with the
- * provided parameters, otherwise it attempts a coordinator
- * realignment of the stated network instead.
- *
- * Note: This is in section 7.5.2.3 of the IEEE 802.15.4-2006
- * document, with 7.3.8 describing coordinator realignment.
- */
-static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
-				u8 channel, u8 page,
-				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
-				u8 coord_realign)
-{
-	struct wpan_phy *phy = fake_to_phy(dev);
-
-	mutex_lock(&phy->pib_lock);
-	phy->current_channel = channel;
-	phy->current_page = page;
-	mutex_unlock(&phy->pib_lock);
-
-	/* We don't emulate beacons here at all, so START should fail */
-	ieee802154_nl_start_confirm(dev, IEEE802154_INVALID_PARAMETER);
-	return 0;
-}
-
-/**
- * fake_scan_req - Start a channel scan.
- * @dev: The network device on which to perform a channel scan.
- * @type: The type of scan to perform.
- * @channels: The channel bitmask to scan.
- * @duration: How long to spend on each channel.
- *
- * This starts either a passive (energy) scan or an active (PAN) scan
- * on the channels indicated in the @channels bitmask. The duration of
- * the scan is measured in terms of superframe duration. Specifically,
- * the scan will spend aBaseSuperFrameDuration * ((2^n) + 1) on each
- * channel.
- *
- * Note: This is in section 7.5.2.1 of the IEEE 802.15.4-2006 document.
- */
-static int fake_scan_req(struct net_device *dev, u8 type, u32 channels,
-		u8 page, u8 duration)
-{
-	u8 edl[27] = {};
-	return ieee802154_nl_scan_confirm(dev, IEEE802154_SUCCESS, type,
-			channels, page,
-			type == IEEE802154_MAC_SCAN_ED ? edl : NULL);
-}
-
-static struct ieee802154_mlme_ops fake_mlme = {
-	.assoc_req = fake_assoc_req,
-	.assoc_resp = fake_assoc_resp,
-	.disassoc_req = fake_disassoc_req,
-	.start_req = fake_start_req,
-	.scan_req = fake_scan_req,
-
-	.get_phy = fake_get_phy,
-
-	.get_pan_id = fake_get_pan_id,
-	.get_short_addr = fake_get_short_addr,
-	.get_dsn = fake_get_dsn,
-	.get_bsn = fake_get_bsn,
-};
-
-static int ieee802154_fake_open(struct net_device *dev)
-{
-	netif_start_queue(dev);
-	return 0;
-}
-
-static int ieee802154_fake_close(struct net_device *dev)
-{
-	netif_stop_queue(dev);
-	return 0;
-}
-
-static netdev_tx_t ieee802154_fake_xmit(struct sk_buff *skb,
-					      struct net_device *dev)
-{
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
-	/* FIXME: do hardware work here ... */
-
-	dev_kfree_skb(skb);
-	return NETDEV_TX_OK;
-}
-
-
-static int ieee802154_fake_ioctl(struct net_device *dev, struct ifreq *ifr,
-		int cmd)
-{
-	struct sockaddr_ieee802154 *sa =
-		(struct sockaddr_ieee802154 *)&ifr->ifr_addr;
-	u16 pan_id, short_addr;
-
-	switch (cmd) {
-	case SIOCGIFADDR:
-		/* FIXME: fixed here, get from device IRL */
-		pan_id = fake_get_pan_id(dev);
-		short_addr = fake_get_short_addr(dev);
-		if (pan_id == IEEE802154_PANID_BROADCAST ||
-		    short_addr == IEEE802154_ADDR_BROADCAST)
-			return -EADDRNOTAVAIL;
-
-		sa->family = AF_IEEE802154;
-		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
-		sa->addr.pan_id = pan_id;
-		sa->addr.short_addr = short_addr;
-		return 0;
-	}
-	return -ENOIOCTLCMD;
-}
-
-static int ieee802154_fake_mac_addr(struct net_device *dev, void *p)
-{
-	return -EBUSY; /* HW address is built into the device */
-}
-
-static const struct net_device_ops fake_ops = {
-	.ndo_open		= ieee802154_fake_open,
-	.ndo_stop		= ieee802154_fake_close,
-	.ndo_start_xmit		= ieee802154_fake_xmit,
-	.ndo_do_ioctl		= ieee802154_fake_ioctl,
-	.ndo_set_mac_address	= ieee802154_fake_mac_addr,
-};
-
-static void ieee802154_fake_destruct(struct net_device *dev)
-{
-	struct wpan_phy *phy = fake_to_phy(dev);
-
-	wpan_phy_unregister(phy);
-	free_netdev(dev);
-	wpan_phy_free(phy);
-}
-
-static void ieee802154_fake_setup(struct net_device *dev)
-{
-	dev->addr_len		= IEEE802154_ADDR_LEN;
-	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
-	dev->features		= NETIF_F_HW_CSUM;
-	dev->needed_tailroom	= 2; /* FCS */
-	dev->mtu		= 127;
-	dev->tx_queue_len	= 10;
-	dev->type		= ARPHRD_IEEE802154;
-	dev->flags		= IFF_NOARP | IFF_BROADCAST;
-	dev->watchdog_timeo	= 0;
-	dev->destructor		= ieee802154_fake_destruct;
-}
-
-
-static int __devinit ieee802154fake_probe(struct platform_device *pdev)
-{
-	struct net_device *dev;
-	struct fakehard_priv *priv;
-	struct wpan_phy *phy = wpan_phy_alloc(0);
-	int err;
-
-	if (!phy)
-		return -ENOMEM;
-
-	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d", ieee802154_fake_setup);
-	if (!dev) {
-		wpan_phy_free(phy);
-		return -ENOMEM;
-	}
-
-	memcpy(dev->dev_addr, "\xba\xbe\xca\xfe\xde\xad\xbe\xef",
-			dev->addr_len);
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
-
-	/*
-	 * For now we'd like to emulate 2.4 GHz-only device,
-	 * both O-QPSK and CSS
-	 */
-	/* 2.4 GHz O-QPSK 802.15.4-2003 */
-	phy->channels_supported[0] |= 0x7FFF800;
-	/* 2.4 GHz CSS 802.15.4a-2007 */
-	phy->channels_supported[3] |= 0x3fff;
-
-	phy->transmit_power = 0xbf;
-
-	dev->netdev_ops = &fake_ops;
-	dev->ml_priv = &fake_mlme;
-
-	priv = netdev_priv(dev);
-	priv->phy = phy;
-
-	wpan_phy_set_dev(phy, &pdev->dev);
-	SET_NETDEV_DEV(dev, &phy->dev);
-
-	platform_set_drvdata(pdev, dev);
-
-	err = wpan_phy_register(phy);
-	if (err)
-		goto out;
-
-	err = register_netdev(dev);
-	if (err < 0)
-		goto out;
-
-	dev_info(&pdev->dev, "Added ieee802154 HardMAC hardware\n");
-	return 0;
-
-out:
-	unregister_netdev(dev);
-	return err;
-}
-
-static int __devexit ieee802154fake_remove(struct platform_device *pdev)
-{
-	struct net_device *dev = platform_get_drvdata(pdev);
-	unregister_netdev(dev);
-	return 0;
-}
-
-static struct platform_device *ieee802154fake_dev;
-
-static struct platform_driver ieee802154fake_driver = {
-	.probe = ieee802154fake_probe,
-	.remove = __devexit_p(ieee802154fake_remove),
-	.driver = {
-			.name = "ieee802154hardmac",
-			.owner = THIS_MODULE,
-	},
-};
-
-static __init int fake_init(void)
-{
-	ieee802154fake_dev = platform_device_register_simple(
-			"ieee802154hardmac", -1, NULL, 0);
-	return platform_driver_register(&ieee802154fake_driver);
-}
-
-static __exit void fake_exit(void)
-{
-	platform_driver_unregister(&ieee802154fake_driver);
-	platform_device_unregister(ieee802154fake_dev);
-}
-
-module_init(fake_init);
-module_exit(fake_exit);
-MODULE_LICENSE("GPL");
-
diff --git a/drivers/ieee802154/fakelb.c b/drivers/ieee802154/fakelb.c
deleted file mode 100644
index e7456fc..0000000
--- a/drivers/ieee802154/fakelb.c
+++ /dev/null
@@ -1,294 +0,0 @@
-/*
- * Loopback IEEE 802.15.4 interface
- *
- * Copyright 2007-2012 Siemens AG
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2
- * as published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, write to the Free Software Foundation, Inc.,
- * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
- *
- * Written by:
- * Sergey Lapin <slapin@ossfans.org>
- * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
- * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
- */
-
-#include <linux/module.h>
-#include <linux/timer.h>
-#include <linux/platform_device.h>
-#include <linux/netdevice.h>
-#include <linux/spinlock.h>
-#include <net/mac802154.h>
-#include <net/wpan-phy.h>
-
-static int numlbs = 1;
-
-struct fakelb_dev_priv {
-	struct ieee802154_dev *dev;
-
-	struct list_head list;
-	struct fakelb_priv *fake;
-
-	spinlock_t lock;
-	bool working;
-};
-
-struct fakelb_priv {
-	struct list_head list;
-	rwlock_t lock;
-};
-
-static int
-fakelb_hw_ed(struct ieee802154_dev *dev, u8 *level)
-{
-	might_sleep();
-	BUG_ON(!level);
-	*level = 0xbe;
-
-	return 0;
-}
-
-static int
-fakelb_hw_channel(struct ieee802154_dev *dev, int page, int channel)
-{
-	pr_debug("set channel to %d\n", channel);
-
-	might_sleep();
-	dev->phy->current_page = page;
-	dev->phy->current_channel = channel;
-
-	return 0;
-}
-
-static void
-fakelb_hw_deliver(struct fakelb_dev_priv *priv, struct sk_buff *skb)
-{
-	struct sk_buff *newskb;
-
-	spin_lock(&priv->lock);
-	if (priv->working) {
-		newskb = pskb_copy(skb, GFP_ATOMIC);
-		ieee802154_rx_irqsafe(priv->dev, newskb, 0xcc);
-	}
-	spin_unlock(&priv->lock);
-}
-
-static int
-fakelb_hw_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
-{
-	struct fakelb_dev_priv *priv = dev->priv;
-	struct fakelb_priv *fake = priv->fake;
-
-	might_sleep();
-
-	read_lock_bh(&fake->lock);
-	if (priv->list.next == priv->list.prev) {
-		/* we are the only one device */
-		fakelb_hw_deliver(priv, skb);
-	} else {
-		struct fakelb_dev_priv *dp;
-		list_for_each_entry(dp, &priv->fake->list, list) {
-			if (dp != priv &&
-			    (dp->dev->phy->current_channel ==
-			     priv->dev->phy->current_channel))
-				fakelb_hw_deliver(dp, skb);
-		}
-	}
-	read_unlock_bh(&fake->lock);
-
-	return 0;
-}
-
-static int
-fakelb_hw_start(struct ieee802154_dev *dev) {
-	struct fakelb_dev_priv *priv = dev->priv;
-	int ret = 0;
-
-	spin_lock(&priv->lock);
-	if (priv->working)
-		ret = -EBUSY;
-	else
-		priv->working = 1;
-	spin_unlock(&priv->lock);
-
-	return ret;
-}
-
-static void
-fakelb_hw_stop(struct ieee802154_dev *dev) {
-	struct fakelb_dev_priv *priv = dev->priv;
-
-	spin_lock(&priv->lock);
-	priv->working = 0;
-	spin_unlock(&priv->lock);
-}
-
-static struct ieee802154_ops fakelb_ops = {
-	.owner = THIS_MODULE,
-	.xmit = fakelb_hw_xmit,
-	.ed = fakelb_hw_ed,
-	.set_channel = fakelb_hw_channel,
-	.start = fakelb_hw_start,
-	.stop = fakelb_hw_stop,
-};
-
-/* Number of dummy devices to be set up by this module. */
-module_param(numlbs, int, 0);
-MODULE_PARM_DESC(numlbs, " number of pseudo devices");
-
-static int fakelb_add_one(struct device *dev, struct fakelb_priv *fake)
-{
-	struct fakelb_dev_priv *priv;
-	int err;
-	struct ieee802154_dev *ieee;
-
-	ieee = ieee802154_alloc_device(sizeof(*priv), &fakelb_ops);
-	if (!ieee)
-		return -ENOMEM;
-
-	priv = ieee->priv;
-	priv->dev = ieee;
-
-	/* 868 MHz BPSK	802.15.4-2003 */
-	ieee->phy->channels_supported[0] |= 1;
-	/* 915 MHz BPSK	802.15.4-2003 */
-	ieee->phy->channels_supported[0] |= 0x7fe;
-	/* 2.4 GHz O-QPSK 802.15.4-2003 */
-	ieee->phy->channels_supported[0] |= 0x7FFF800;
-	/* 868 MHz ASK 802.15.4-2006 */
-	ieee->phy->channels_supported[1] |= 1;
-	/* 915 MHz ASK 802.15.4-2006 */
-	ieee->phy->channels_supported[1] |= 0x7fe;
-	/* 868 MHz O-QPSK 802.15.4-2006 */
-	ieee->phy->channels_supported[2] |= 1;
-	/* 915 MHz O-QPSK 802.15.4-2006 */
-	ieee->phy->channels_supported[2] |= 0x7fe;
-	/* 2.4 GHz CSS 802.15.4a-2007 */
-	ieee->phy->channels_supported[3] |= 0x3fff;
-	/* UWB Sub-gigahertz 802.15.4a-2007 */
-	ieee->phy->channels_supported[4] |= 1;
-	/* UWB Low band 802.15.4a-2007 */
-	ieee->phy->channels_supported[4] |= 0x1e;
-	/* UWB High band 802.15.4a-2007 */
-	ieee->phy->channels_supported[4] |= 0xffe0;
-	/* 750 MHz O-QPSK 802.15.4c-2009 */
-	ieee->phy->channels_supported[5] |= 0xf;
-	/* 750 MHz MPSK 802.15.4c-2009 */
-	ieee->phy->channels_supported[5] |= 0xf0;
-	/* 950 MHz BPSK 802.15.4d-2009 */
-	ieee->phy->channels_supported[6] |= 0x3ff;
-	/* 950 MHz GFSK 802.15.4d-2009 */
-	ieee->phy->channels_supported[6] |= 0x3ffc00;
-
-	INIT_LIST_HEAD(&priv->list);
-	priv->fake = fake;
-
-	spin_lock_init(&priv->lock);
-
-	ieee->parent = dev;
-
-	err = ieee802154_register_device(ieee);
-	if (err)
-		goto err_reg;
-
-	write_lock_bh(&fake->lock);
-	list_add_tail(&priv->list, &fake->list);
-	write_unlock_bh(&fake->lock);
-
-	return 0;
-
-err_reg:
-	ieee802154_free_device(priv->dev);
-	return err;
-}
-
-static void fakelb_del(struct fakelb_dev_priv *priv)
-{
-	write_lock_bh(&priv->fake->lock);
-	list_del(&priv->list);
-	write_unlock_bh(&priv->fake->lock);
-
-	ieee802154_unregister_device(priv->dev);
-	ieee802154_free_device(priv->dev);
-}
-
-static int __devinit fakelb_probe(struct platform_device *pdev)
-{
-	struct fakelb_priv *priv;
-	struct fakelb_dev_priv *dp;
-	int err = -ENOMEM;
-	int i;
-
-	priv = kzalloc(sizeof(struct fakelb_priv), GFP_KERNEL);
-	if (!priv)
-		goto err_alloc;
-
-	INIT_LIST_HEAD(&priv->list);
-	rwlock_init(&priv->lock);
-
-	for (i = 0; i < numlbs; i++) {
-		err = fakelb_add_one(&pdev->dev, priv);
-		if (err < 0)
-			goto err_slave;
-	}
-
-	platform_set_drvdata(pdev, priv);
-	dev_info(&pdev->dev, "added ieee802154 hardware\n");
-	return 0;
-
-err_slave:
-	list_for_each_entry(dp, &priv->list, list)
-		fakelb_del(dp);
-	kfree(priv);
-err_alloc:
-	return err;
-}
-
-static int __devexit fakelb_remove(struct platform_device *pdev)
-{
-	struct fakelb_priv *priv = platform_get_drvdata(pdev);
-	struct fakelb_dev_priv *dp, *temp;
-
-	list_for_each_entry_safe(dp, temp, &priv->list, list)
-		fakelb_del(dp);
-	kfree(priv);
-
-	return 0;
-}
-
-static struct platform_device *ieee802154fake_dev;
-
-static struct platform_driver ieee802154fake_driver = {
-	.probe = fakelb_probe,
-	.remove = __devexit_p(fakelb_remove),
-	.driver = {
-			.name = "ieee802154fakelb",
-			.owner = THIS_MODULE,
-	},
-};
-
-static __init int fakelb_init_module(void)
-{
-	ieee802154fake_dev = platform_device_register_simple(
-			     "ieee802154fakelb", -1, NULL, 0);
-	return platform_driver_register(&ieee802154fake_driver);
-}
-
-static __exit void fake_remove_module(void)
-{
-	platform_driver_unregister(&ieee802154fake_driver);
-	platform_device_unregister(ieee802154fake_dev);
-}
-
-module_init(fakelb_init_module);
-module_exit(fake_remove_module);
-MODULE_LICENSE("GPL");
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0c2bd80..707ab7b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -107,8 +107,6 @@ config MII
 	  or internal device.  It is safe to say Y or M here even if your
 	  ethernet card lacks MII.
 
-source "drivers/ieee802154/Kconfig"
-
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
@@ -290,6 +288,8 @@ source "drivers/net/wimax/Kconfig"
 
 source "drivers/net/wan/Kconfig"
 
+source "drivers/net/ieee802154/Kconfig"
+
 config XEN_NETDEV_FRONTEND
 	tristate "Xen network device frontend driver"
 	depends on XEN
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3d375ca..b682a1d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
 obj-$(CONFIG_WAN) += wan/
 obj-$(CONFIG_WLAN) += wireless/
 obj-$(CONFIG_WIMAX) += wimax/
+obj-$(CONFIG_IEEE802154) += ieee802154/
 
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
diff --git a/drivers/net/ieee802154/Kconfig b/drivers/net/ieee802154/Kconfig
new file mode 100644
index 0000000..1fc4eef
--- /dev/null
+++ b/drivers/net/ieee802154/Kconfig
@@ -0,0 +1,36 @@
+menuconfig IEEE802154_DRIVERS
+	tristate "IEEE 802.15.4 drivers"
+	depends on NETDEVICES && IEEE802154
+	default y
+	---help---
+	  Say Y here to get to see options for IEEE 802.15.4 Low-Rate
+	  Wireless Personal Area Network device drivers. This option alone
+	  does not add any kernel code.
+
+	  If you say N, all options in this submenu will be skipped and
+	  disabled.
+
+config IEEE802154_FAKEHARD
+	tristate "Fake LR-WPAN driver with several interconnected devices"
+	depends on  IEEE802154_DRIVERS
+	---help---
+	  Say Y here to enable the fake driver that serves as an example
+          of HardMAC device driver.
+
+          This driver can also be built as a module. To do so say M here.
+	  The module will be called 'fakehard'.
+
+config IEEE802154_FAKELB
+	depends on IEEE802154_DRIVERS && MAC802154
+	tristate "IEEE 802.15.4 loopback driver"
+	---help---
+	  Say Y here to enable the fake driver that can emulate a net
+	  of several interconnected radio devices.
+
+	  This driver can also be built as a module. To do so say M here.
+	  The module will be called 'fakelb'.
+
+config IEEE802154_AT86RF230
+        depends on IEEE802154_DRIVERS && MAC802154
+        tristate "AT86RF230/231 transceiver driver"
+        depends on SPI
diff --git a/drivers/net/ieee802154/Makefile b/drivers/net/ieee802154/Makefile
new file mode 100644
index 0000000..4f4371d
--- /dev/null
+++ b/drivers/net/ieee802154/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_IEEE802154_FAKEHARD) += fakehard.o
+obj-$(CONFIG_IEEE802154_FAKELB) += fakelb.o
+obj-$(CONFIG_IEEE802154_AT86RF230) += at86rf230.o
diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
new file mode 100644
index 0000000..ba753d8
--- /dev/null
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -0,0 +1,958 @@
+/*
+ * AT86RF230/RF231 driver
+ *
+ * Copyright (C) 2009-2012 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/gpio.h>
+#include <linux/delay.h>
+#include <linux/mutex.h>
+#include <linux/workqueue.h>
+#include <linux/spinlock.h>
+#include <linux/spi/spi.h>
+#include <linux/spi/at86rf230.h>
+#include <linux/skbuff.h>
+
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+struct at86rf230_local {
+	struct spi_device *spi;
+	int rstn, slp_tr, dig2;
+
+	u8 part;
+	u8 vers;
+
+	u8 buf[2];
+	struct mutex bmux;
+
+	struct work_struct irqwork;
+	struct completion tx_complete;
+
+	struct ieee802154_dev *dev;
+
+	spinlock_t lock;
+	bool irq_disabled;
+	bool is_tx;
+};
+
+#define	RG_TRX_STATUS	(0x01)
+#define	SR_TRX_STATUS		0x01, 0x1f, 0
+#define	SR_RESERVED_01_3	0x01, 0x20, 5
+#define	SR_CCA_STATUS		0x01, 0x40, 6
+#define	SR_CCA_DONE		0x01, 0x80, 7
+#define	RG_TRX_STATE	(0x02)
+#define	SR_TRX_CMD		0x02, 0x1f, 0
+#define	SR_TRAC_STATUS		0x02, 0xe0, 5
+#define	RG_TRX_CTRL_0	(0x03)
+#define	SR_CLKM_CTRL		0x03, 0x07, 0
+#define	SR_CLKM_SHA_SEL		0x03, 0x08, 3
+#define	SR_PAD_IO_CLKM		0x03, 0x30, 4
+#define	SR_PAD_IO		0x03, 0xc0, 6
+#define	RG_TRX_CTRL_1	(0x04)
+#define	SR_IRQ_POLARITY		0x04, 0x01, 0
+#define	SR_IRQ_MASK_MODE	0x04, 0x02, 1
+#define	SR_SPI_CMD_MODE		0x04, 0x0c, 2
+#define	SR_RX_BL_CTRL		0x04, 0x10, 4
+#define	SR_TX_AUTO_CRC_ON	0x04, 0x20, 5
+#define	SR_IRQ_2_EXT_EN		0x04, 0x40, 6
+#define	SR_PA_EXT_EN		0x04, 0x80, 7
+#define	RG_PHY_TX_PWR	(0x05)
+#define	SR_TX_PWR		0x05, 0x0f, 0
+#define	SR_PA_LT		0x05, 0x30, 4
+#define	SR_PA_BUF_LT		0x05, 0xc0, 6
+#define	RG_PHY_RSSI	(0x06)
+#define	SR_RSSI			0x06, 0x1f, 0
+#define	SR_RND_VALUE		0x06, 0x60, 5
+#define	SR_RX_CRC_VALID		0x06, 0x80, 7
+#define	RG_PHY_ED_LEVEL	(0x07)
+#define	SR_ED_LEVEL		0x07, 0xff, 0
+#define	RG_PHY_CC_CCA	(0x08)
+#define	SR_CHANNEL		0x08, 0x1f, 0
+#define	SR_CCA_MODE		0x08, 0x60, 5
+#define	SR_CCA_REQUEST		0x08, 0x80, 7
+#define	RG_CCA_THRES	(0x09)
+#define	SR_CCA_ED_THRES		0x09, 0x0f, 0
+#define	SR_RESERVED_09_1	0x09, 0xf0, 4
+#define	RG_RX_CTRL	(0x0a)
+#define	SR_PDT_THRES		0x0a, 0x0f, 0
+#define	SR_RESERVED_0a_1	0x0a, 0xf0, 4
+#define	RG_SFD_VALUE	(0x0b)
+#define	SR_SFD_VALUE		0x0b, 0xff, 0
+#define	RG_TRX_CTRL_2	(0x0c)
+#define	SR_OQPSK_DATA_RATE	0x0c, 0x03, 0
+#define	SR_RESERVED_0c_2	0x0c, 0x7c, 2
+#define	SR_RX_SAFE_MODE		0x0c, 0x80, 7
+#define	RG_ANT_DIV	(0x0d)
+#define	SR_ANT_CTRL		0x0d, 0x03, 0
+#define	SR_ANT_EXT_SW_EN	0x0d, 0x04, 2
+#define	SR_ANT_DIV_EN		0x0d, 0x08, 3
+#define	SR_RESERVED_0d_2	0x0d, 0x70, 4
+#define	SR_ANT_SEL		0x0d, 0x80, 7
+#define	RG_IRQ_MASK	(0x0e)
+#define	SR_IRQ_MASK		0x0e, 0xff, 0
+#define	RG_IRQ_STATUS	(0x0f)
+#define	SR_IRQ_0_PLL_LOCK	0x0f, 0x01, 0
+#define	SR_IRQ_1_PLL_UNLOCK	0x0f, 0x02, 1
+#define	SR_IRQ_2_RX_START	0x0f, 0x04, 2
+#define	SR_IRQ_3_TRX_END	0x0f, 0x08, 3
+#define	SR_IRQ_4_CCA_ED_DONE	0x0f, 0x10, 4
+#define	SR_IRQ_5_AMI		0x0f, 0x20, 5
+#define	SR_IRQ_6_TRX_UR		0x0f, 0x40, 6
+#define	SR_IRQ_7_BAT_LOW	0x0f, 0x80, 7
+#define	RG_VREG_CTRL	(0x10)
+#define	SR_RESERVED_10_6	0x10, 0x03, 0
+#define	SR_DVDD_OK		0x10, 0x04, 2
+#define	SR_DVREG_EXT		0x10, 0x08, 3
+#define	SR_RESERVED_10_3	0x10, 0x30, 4
+#define	SR_AVDD_OK		0x10, 0x40, 6
+#define	SR_AVREG_EXT		0x10, 0x80, 7
+#define	RG_BATMON	(0x11)
+#define	SR_BATMON_VTH		0x11, 0x0f, 0
+#define	SR_BATMON_HR		0x11, 0x10, 4
+#define	SR_BATMON_OK		0x11, 0x20, 5
+#define	SR_RESERVED_11_1	0x11, 0xc0, 6
+#define	RG_XOSC_CTRL	(0x12)
+#define	SR_XTAL_TRIM		0x12, 0x0f, 0
+#define	SR_XTAL_MODE		0x12, 0xf0, 4
+#define	RG_RX_SYN	(0x15)
+#define	SR_RX_PDT_LEVEL		0x15, 0x0f, 0
+#define	SR_RESERVED_15_2	0x15, 0x70, 4
+#define	SR_RX_PDT_DIS		0x15, 0x80, 7
+#define	RG_XAH_CTRL_1	(0x17)
+#define	SR_RESERVED_17_8	0x17, 0x01, 0
+#define	SR_AACK_PROM_MODE	0x17, 0x02, 1
+#define	SR_AACK_ACK_TIME	0x17, 0x04, 2
+#define	SR_RESERVED_17_5	0x17, 0x08, 3
+#define	SR_AACK_UPLD_RES_FT	0x17, 0x10, 4
+#define	SR_AACK_FLTR_RES_FT	0x17, 0x20, 5
+#define	SR_RESERVED_17_2	0x17, 0x40, 6
+#define	SR_RESERVED_17_1	0x17, 0x80, 7
+#define	RG_FTN_CTRL	(0x18)
+#define	SR_RESERVED_18_2	0x18, 0x7f, 0
+#define	SR_FTN_START		0x18, 0x80, 7
+#define	RG_PLL_CF	(0x1a)
+#define	SR_RESERVED_1a_2	0x1a, 0x7f, 0
+#define	SR_PLL_CF_START		0x1a, 0x80, 7
+#define	RG_PLL_DCU	(0x1b)
+#define	SR_RESERVED_1b_3	0x1b, 0x3f, 0
+#define	SR_RESERVED_1b_2	0x1b, 0x40, 6
+#define	SR_PLL_DCU_START	0x1b, 0x80, 7
+#define	RG_PART_NUM	(0x1c)
+#define	SR_PART_NUM		0x1c, 0xff, 0
+#define	RG_VERSION_NUM	(0x1d)
+#define	SR_VERSION_NUM		0x1d, 0xff, 0
+#define	RG_MAN_ID_0	(0x1e)
+#define	SR_MAN_ID_0		0x1e, 0xff, 0
+#define	RG_MAN_ID_1	(0x1f)
+#define	SR_MAN_ID_1		0x1f, 0xff, 0
+#define	RG_SHORT_ADDR_0	(0x20)
+#define	SR_SHORT_ADDR_0		0x20, 0xff, 0
+#define	RG_SHORT_ADDR_1	(0x21)
+#define	SR_SHORT_ADDR_1		0x21, 0xff, 0
+#define	RG_PAN_ID_0	(0x22)
+#define	SR_PAN_ID_0		0x22, 0xff, 0
+#define	RG_PAN_ID_1	(0x23)
+#define	SR_PAN_ID_1		0x23, 0xff, 0
+#define	RG_IEEE_ADDR_0	(0x24)
+#define	SR_IEEE_ADDR_0		0x24, 0xff, 0
+#define	RG_IEEE_ADDR_1	(0x25)
+#define	SR_IEEE_ADDR_1		0x25, 0xff, 0
+#define	RG_IEEE_ADDR_2	(0x26)
+#define	SR_IEEE_ADDR_2		0x26, 0xff, 0
+#define	RG_IEEE_ADDR_3	(0x27)
+#define	SR_IEEE_ADDR_3		0x27, 0xff, 0
+#define	RG_IEEE_ADDR_4	(0x28)
+#define	SR_IEEE_ADDR_4		0x28, 0xff, 0
+#define	RG_IEEE_ADDR_5	(0x29)
+#define	SR_IEEE_ADDR_5		0x29, 0xff, 0
+#define	RG_IEEE_ADDR_6	(0x2a)
+#define	SR_IEEE_ADDR_6		0x2a, 0xff, 0
+#define	RG_IEEE_ADDR_7	(0x2b)
+#define	SR_IEEE_ADDR_7		0x2b, 0xff, 0
+#define	RG_XAH_CTRL_0	(0x2c)
+#define	SR_SLOTTED_OPERATION	0x2c, 0x01, 0
+#define	SR_MAX_CSMA_RETRIES	0x2c, 0x0e, 1
+#define	SR_MAX_FRAME_RETRIES	0x2c, 0xf0, 4
+#define	RG_CSMA_SEED_0	(0x2d)
+#define	SR_CSMA_SEED_0		0x2d, 0xff, 0
+#define	RG_CSMA_SEED_1	(0x2e)
+#define	SR_CSMA_SEED_1		0x2e, 0x07, 0
+#define	SR_AACK_I_AM_COORD	0x2e, 0x08, 3
+#define	SR_AACK_DIS_ACK		0x2e, 0x10, 4
+#define	SR_AACK_SET_PD		0x2e, 0x20, 5
+#define	SR_AACK_FVN_MODE	0x2e, 0xc0, 6
+#define	RG_CSMA_BE	(0x2f)
+#define	SR_MIN_BE		0x2f, 0x0f, 0
+#define	SR_MAX_BE		0x2f, 0xf0, 4
+
+#define CMD_REG		0x80
+#define CMD_REG_MASK	0x3f
+#define CMD_WRITE	0x40
+#define CMD_FB		0x20
+
+#define IRQ_BAT_LOW	(1 << 7)
+#define IRQ_TRX_UR	(1 << 6)
+#define IRQ_AMI		(1 << 5)
+#define IRQ_CCA_ED	(1 << 4)
+#define IRQ_TRX_END	(1 << 3)
+#define IRQ_RX_START	(1 << 2)
+#define IRQ_PLL_UNL	(1 << 1)
+#define IRQ_PLL_LOCK	(1 << 0)
+
+#define STATE_P_ON		0x00	/* BUSY */
+#define STATE_BUSY_RX		0x01
+#define STATE_BUSY_TX		0x02
+#define STATE_FORCE_TRX_OFF	0x03
+#define STATE_FORCE_TX_ON	0x04	/* IDLE */
+/* 0x05 */				/* INVALID_PARAMETER */
+#define STATE_RX_ON		0x06
+/* 0x07 */				/* SUCCESS */
+#define STATE_TRX_OFF		0x08
+#define STATE_TX_ON		0x09
+/* 0x0a - 0x0e */			/* 0x0a - UNSUPPORTED_ATTRIBUTE */
+#define STATE_SLEEP		0x0F
+#define STATE_BUSY_RX_AACK	0x11
+#define STATE_BUSY_TX_ARET	0x12
+#define STATE_BUSY_RX_AACK_ON	0x16
+#define STATE_BUSY_TX_ARET_ON	0x19
+#define STATE_RX_ON_NOCLK	0x1C
+#define STATE_RX_AACK_ON_NOCLK	0x1D
+#define STATE_BUSY_RX_AACK_NOCLK 0x1E
+#define STATE_TRANSITION_IN_PROGRESS 0x1F
+
+static int
+__at86rf230_write(struct at86rf230_local *lp, u8 addr, u8 data)
+{
+	u8 *buf = lp->buf;
+	int status;
+	struct spi_message msg;
+	struct spi_transfer xfer = {
+		.len	= 2,
+		.tx_buf	= buf,
+	};
+
+	buf[0] = (addr & CMD_REG_MASK) | CMD_REG | CMD_WRITE;
+	buf[1] = data;
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+	spi_message_init(&msg);
+	spi_message_add_tail(&xfer, &msg);
+
+	status = spi_sync(lp->spi, &msg);
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	if (msg.status)
+		status = msg.status;
+
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+
+	return status;
+}
+
+static int
+__at86rf230_read_subreg(struct at86rf230_local *lp,
+			u8 addr, u8 mask, int shift, u8 *data)
+{
+	u8 *buf = lp->buf;
+	int status;
+	struct spi_message msg;
+	struct spi_transfer xfer = {
+		.len	= 2,
+		.tx_buf	= buf,
+		.rx_buf	= buf,
+	};
+
+	buf[0] = (addr & CMD_REG_MASK) | CMD_REG;
+	buf[1] = 0xff;
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	spi_message_init(&msg);
+	spi_message_add_tail(&xfer, &msg);
+
+	status = spi_sync(lp->spi, &msg);
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	if (msg.status)
+		status = msg.status;
+
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+
+	if (status == 0)
+		*data = buf[1];
+
+	return status;
+}
+
+static int
+at86rf230_read_subreg(struct at86rf230_local *lp,
+		      u8 addr, u8 mask, int shift, u8 *data)
+{
+	int status;
+
+	mutex_lock(&lp->bmux);
+	status = __at86rf230_read_subreg(lp, addr, mask, shift, data);
+	mutex_unlock(&lp->bmux);
+
+	return status;
+}
+
+static int
+at86rf230_write_subreg(struct at86rf230_local *lp,
+		       u8 addr, u8 mask, int shift, u8 data)
+{
+	int status;
+	u8 val;
+
+	mutex_lock(&lp->bmux);
+	status = __at86rf230_read_subreg(lp, addr, 0xff, 0, &val);
+	if (status)
+		goto out;
+
+	val &= ~mask;
+	val |= (data << shift) & mask;
+
+	status = __at86rf230_write(lp, addr, val);
+out:
+	mutex_unlock(&lp->bmux);
+
+	return status;
+}
+
+static int
+at86rf230_write_fbuf(struct at86rf230_local *lp, u8 *data, u8 len)
+{
+	u8 *buf = lp->buf;
+	int status;
+	struct spi_message msg;
+	struct spi_transfer xfer_head = {
+		.len		= 2,
+		.tx_buf		= buf,
+
+	};
+	struct spi_transfer xfer_buf = {
+		.len		= len,
+		.tx_buf		= data,
+	};
+
+	mutex_lock(&lp->bmux);
+	buf[0] = CMD_WRITE | CMD_FB;
+	buf[1] = len + 2; /* 2 bytes for CRC that isn't written */
+
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+
+	spi_message_init(&msg);
+	spi_message_add_tail(&xfer_head, &msg);
+	spi_message_add_tail(&xfer_buf, &msg);
+
+	status = spi_sync(lp->spi, &msg);
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	if (msg.status)
+		status = msg.status;
+
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+
+	mutex_unlock(&lp->bmux);
+	return status;
+}
+
+static int
+at86rf230_read_fbuf(struct at86rf230_local *lp, u8 *data, u8 *len, u8 *lqi)
+{
+	u8 *buf = lp->buf;
+	int status;
+	struct spi_message msg;
+	struct spi_transfer xfer_head = {
+		.len		= 2,
+		.tx_buf		= buf,
+		.rx_buf		= buf,
+	};
+	struct spi_transfer xfer_head1 = {
+		.len		= 2,
+		.tx_buf		= buf,
+		.rx_buf		= buf,
+	};
+	struct spi_transfer xfer_buf = {
+		.len		= 0,
+		.rx_buf		= data,
+	};
+
+	mutex_lock(&lp->bmux);
+
+	buf[0] = CMD_FB;
+	buf[1] = 0x00;
+
+	spi_message_init(&msg);
+	spi_message_add_tail(&xfer_head, &msg);
+
+	status = spi_sync(lp->spi, &msg);
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+
+	xfer_buf.len = *(buf + 1) + 1;
+	*len = buf[1];
+
+	buf[0] = CMD_FB;
+	buf[1] = 0x00;
+
+	spi_message_init(&msg);
+	spi_message_add_tail(&xfer_head1, &msg);
+	spi_message_add_tail(&xfer_buf, &msg);
+
+	status = spi_sync(lp->spi, &msg);
+
+	if (msg.status)
+		status = msg.status;
+
+	dev_vdbg(&lp->spi->dev, "status = %d\n", status);
+	dev_vdbg(&lp->spi->dev, "buf[0] = %02x\n", buf[0]);
+	dev_vdbg(&lp->spi->dev, "buf[1] = %02x\n", buf[1]);
+
+	if (status) {
+		if (lqi && (*len > lp->buf[1]))
+			*lqi = data[lp->buf[1]];
+	}
+	mutex_unlock(&lp->bmux);
+
+	return status;
+}
+
+static int
+at86rf230_ed(struct ieee802154_dev *dev, u8 *level)
+{
+	might_sleep();
+	BUG_ON(!level);
+	*level = 0xbe;
+	return 0;
+}
+
+static int
+at86rf230_state(struct ieee802154_dev *dev, int state)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc;
+	u8 val;
+	u8 desired_status;
+
+	might_sleep();
+
+	if (state == STATE_FORCE_TX_ON)
+		desired_status = STATE_TX_ON;
+	else if (state == STATE_FORCE_TRX_OFF)
+		desired_status = STATE_TRX_OFF;
+	else
+		desired_status = state;
+
+	do {
+		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
+		if (rc)
+			goto err;
+	} while (val == STATE_TRANSITION_IN_PROGRESS);
+
+	if (val == desired_status)
+		return 0;
+
+	/* state is equal to phy states */
+	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, state);
+	if (rc)
+		goto err;
+
+	do {
+		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &val);
+		if (rc)
+			goto err;
+	} while (val == STATE_TRANSITION_IN_PROGRESS);
+
+
+	if (val == desired_status)
+		return 0;
+
+	pr_err("unexpected state change: %d, asked for %d\n", val, state);
+	return -EBUSY;
+
+err:
+	pr_err("error: %d\n", rc);
+	return rc;
+}
+
+static int
+at86rf230_start(struct ieee802154_dev *dev)
+{
+	struct at86rf230_local *lp = dev->priv;
+	u8 rc;
+
+	rc = at86rf230_write_subreg(lp, SR_RX_SAFE_MODE, 1);
+	if (rc)
+		return rc;
+
+	return at86rf230_state(dev, STATE_RX_ON);
+}
+
+static void
+at86rf230_stop(struct ieee802154_dev *dev)
+{
+	at86rf230_state(dev, STATE_FORCE_TRX_OFF);
+}
+
+static int
+at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc;
+
+	might_sleep();
+
+	if (page != 0 || channel < 11 || channel > 26) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+
+	rc = at86rf230_write_subreg(lp, SR_CHANNEL, channel);
+	msleep(1); /* Wait for PLL */
+	dev->phy->current_channel = channel;
+
+	return 0;
+}
+
+static int
+at86rf230_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
+{
+	struct at86rf230_local *lp = dev->priv;
+	int rc;
+	unsigned long flags;
+
+	spin_lock(&lp->lock);
+	if  (lp->irq_disabled) {
+		spin_unlock(&lp->lock);
+		return -EBUSY;
+	}
+	spin_unlock(&lp->lock);
+
+	might_sleep();
+
+	rc = at86rf230_state(dev, STATE_FORCE_TX_ON);
+	if (rc)
+		goto err;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	lp->is_tx = 1;
+	INIT_COMPLETION(lp->tx_complete);
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	rc = at86rf230_write_fbuf(lp, skb->data, skb->len);
+	if (rc)
+		goto err_rx;
+
+	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_BUSY_TX);
+	if (rc)
+		goto err_rx;
+
+	rc = wait_for_completion_interruptible(&lp->tx_complete);
+	if (rc < 0)
+		goto err_rx;
+
+	rc = at86rf230_start(dev);
+
+	return rc;
+
+err_rx:
+	at86rf230_start(dev);
+err:
+	pr_err("error: %d\n", rc);
+
+	spin_lock_irqsave(&lp->lock, flags);
+	lp->is_tx = 0;
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	return rc;
+}
+
+static int at86rf230_rx(struct at86rf230_local *lp)
+{
+	u8 len = 128, lqi = 0;
+	struct sk_buff *skb;
+
+	skb = alloc_skb(len, GFP_KERNEL);
+
+	if (!skb)
+		return -ENOMEM;
+
+	if (at86rf230_read_fbuf(lp, skb_put(skb, len), &len, &lqi))
+		goto err;
+
+	if (len < 2)
+		goto err;
+
+	skb_trim(skb, len - 2); /* We do not put CRC into the frame */
+
+	ieee802154_rx_irqsafe(lp->dev, skb, lqi);
+
+	dev_dbg(&lp->spi->dev, "READ_FBUF: %d %x\n", len, lqi);
+
+	return 0;
+err:
+	pr_debug("received frame is too small\n");
+
+	kfree_skb(skb);
+	return -EINVAL;
+}
+
+static struct ieee802154_ops at86rf230_ops = {
+	.owner = THIS_MODULE,
+	.xmit = at86rf230_xmit,
+	.ed = at86rf230_ed,
+	.set_channel = at86rf230_channel,
+	.start = at86rf230_start,
+	.stop = at86rf230_stop,
+};
+
+static void at86rf230_irqwork(struct work_struct *work)
+{
+	struct at86rf230_local *lp =
+		container_of(work, struct at86rf230_local, irqwork);
+	u8 status = 0, val;
+	int rc;
+	unsigned long flags;
+
+	rc = at86rf230_read_subreg(lp, RG_IRQ_STATUS, 0xff, 0, &val);
+	status |= val;
+
+	status &= ~IRQ_PLL_LOCK; /* ignore */
+	status &= ~IRQ_RX_START; /* ignore */
+	status &= ~IRQ_AMI; /* ignore */
+	status &= ~IRQ_TRX_UR; /* FIXME: possibly handle ???*/
+
+	if (status & IRQ_TRX_END) {
+		spin_lock_irqsave(&lp->lock, flags);
+		status &= ~IRQ_TRX_END;
+		if (lp->is_tx) {
+			lp->is_tx = 0;
+			spin_unlock_irqrestore(&lp->lock, flags);
+			complete(&lp->tx_complete);
+		} else {
+			spin_unlock_irqrestore(&lp->lock, flags);
+			at86rf230_rx(lp);
+		}
+	}
+
+	spin_lock_irqsave(&lp->lock, flags);
+	lp->irq_disabled = 0;
+	spin_unlock_irqrestore(&lp->lock, flags);
+
+	enable_irq(lp->spi->irq);
+}
+
+static irqreturn_t at86rf230_isr(int irq, void *data)
+{
+	struct at86rf230_local *lp = data;
+
+	disable_irq_nosync(irq);
+
+	spin_lock(&lp->lock);
+	lp->irq_disabled = 1;
+	spin_unlock(&lp->lock);
+
+	schedule_work(&lp->irqwork);
+
+	return IRQ_HANDLED;
+}
+
+
+static int at86rf230_hw_init(struct at86rf230_local *lp)
+{
+	u8 status;
+	int rc;
+
+	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
+	if (rc)
+		return rc;
+
+	dev_info(&lp->spi->dev, "Status: %02x\n", status);
+	if (status == STATE_P_ON) {
+		rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TRX_OFF);
+		if (rc)
+			return rc;
+		msleep(1);
+		rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
+		if (rc)
+			return rc;
+		dev_info(&lp->spi->dev, "Status: %02x\n", status);
+	}
+
+	rc = at86rf230_write_subreg(lp, SR_IRQ_MASK, 0xff); /* IRQ_TRX_UR |
+							     * IRQ_CCA_ED |
+							     * IRQ_TRX_END |
+							     * IRQ_PLL_UNL |
+							     * IRQ_PLL_LOCK
+							     */
+	if (rc)
+		return rc;
+
+	/* CLKM changes are applied immediately */
+	rc = at86rf230_write_subreg(lp, SR_CLKM_SHA_SEL, 0x00);
+	if (rc)
+		return rc;
+
+	/* Turn CLKM Off */
+	rc = at86rf230_write_subreg(lp, SR_CLKM_CTRL, 0x00);
+	if (rc)
+		return rc;
+	/* Wait the next SLEEP cycle */
+	msleep(100);
+
+	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_TX_ON);
+	if (rc)
+		return rc;
+	msleep(1);
+
+	rc = at86rf230_read_subreg(lp, SR_TRX_STATUS, &status);
+	if (rc)
+		return rc;
+	dev_info(&lp->spi->dev, "Status: %02x\n", status);
+
+	rc = at86rf230_read_subreg(lp, SR_DVDD_OK, &status);
+	if (rc)
+		return rc;
+	if (!status) {
+		dev_err(&lp->spi->dev, "DVDD error\n");
+		return -EINVAL;
+	}
+
+	rc = at86rf230_read_subreg(lp, SR_AVDD_OK, &status);
+	if (rc)
+		return rc;
+	if (!status) {
+		dev_err(&lp->spi->dev, "AVDD error\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int at86rf230_suspend(struct spi_device *spi, pm_message_t message)
+{
+	return 0;
+}
+
+static int at86rf230_resume(struct spi_device *spi)
+{
+	return 0;
+}
+
+static int at86rf230_fill_data(struct spi_device *spi)
+{
+	struct at86rf230_local *lp = spi_get_drvdata(spi);
+	struct at86rf230_platform_data *pdata = spi->dev.platform_data;
+
+	if (!pdata) {
+		dev_err(&spi->dev, "no platform_data\n");
+		return -EINVAL;
+	}
+
+	lp->rstn = pdata->rstn;
+	lp->slp_tr = pdata->slp_tr;
+	lp->dig2 = pdata->dig2;
+
+	return 0;
+}
+
+static int __devinit at86rf230_probe(struct spi_device *spi)
+{
+	struct ieee802154_dev *dev;
+	struct at86rf230_local *lp;
+	u8 man_id_0, man_id_1;
+	int rc;
+	const char *chip;
+	int supported = 0;
+
+	if (!spi->irq) {
+		dev_err(&spi->dev, "no IRQ specified\n");
+		return -EINVAL;
+	}
+
+	dev = ieee802154_alloc_device(sizeof(*lp), &at86rf230_ops);
+	if (!dev)
+		return -ENOMEM;
+
+	lp = dev->priv;
+	lp->dev = dev;
+
+	lp->spi = spi;
+
+	dev->priv = lp;
+	dev->parent = &spi->dev;
+	dev->extra_tx_headroom = 0;
+	/* We do support only 2.4 Ghz */
+	dev->phy->channels_supported[0] = 0x7FFF800;
+	dev->flags = IEEE802154_HW_OMIT_CKSUM;
+
+	mutex_init(&lp->bmux);
+	INIT_WORK(&lp->irqwork, at86rf230_irqwork);
+	spin_lock_init(&lp->lock);
+	init_completion(&lp->tx_complete);
+
+	spi_set_drvdata(spi, lp);
+
+	rc = at86rf230_fill_data(spi);
+	if (rc)
+		goto err_fill;
+
+	rc = gpio_request(lp->rstn, "rstn");
+	if (rc)
+		goto err_rstn;
+
+	if (gpio_is_valid(lp->slp_tr)) {
+		rc = gpio_request(lp->slp_tr, "slp_tr");
+		if (rc)
+			goto err_slp_tr;
+	}
+
+	rc = gpio_direction_output(lp->rstn, 1);
+	if (rc)
+		goto err_gpio_dir;
+
+	if (gpio_is_valid(lp->slp_tr)) {
+		rc = gpio_direction_output(lp->slp_tr, 0);
+		if (rc)
+			goto err_gpio_dir;
+	}
+
+	/* Reset */
+	msleep(1);
+	gpio_set_value(lp->rstn, 0);
+	msleep(1);
+	gpio_set_value(lp->rstn, 1);
+	msleep(1);
+
+	rc = at86rf230_read_subreg(lp, SR_MAN_ID_0, &man_id_0);
+	if (rc)
+		goto err_gpio_dir;
+	rc = at86rf230_read_subreg(lp, SR_MAN_ID_1, &man_id_1);
+	if (rc)
+		goto err_gpio_dir;
+
+	if (man_id_1 != 0x00 || man_id_0 != 0x1f) {
+		dev_err(&spi->dev, "Non-Atmel dev found (MAN_ID %02x %02x)\n",
+			man_id_1, man_id_0);
+		rc = -EINVAL;
+		goto err_gpio_dir;
+	}
+
+	rc = at86rf230_read_subreg(lp, SR_PART_NUM, &lp->part);
+	if (rc)
+		goto err_gpio_dir;
+
+	rc = at86rf230_read_subreg(lp, SR_VERSION_NUM, &lp->vers);
+	if (rc)
+		goto err_gpio_dir;
+
+	switch (lp->part) {
+	case 2:
+		chip = "at86rf230";
+		/* supported = 1;  FIXME: should be easy to support; */
+		break;
+	case 3:
+		chip = "at86rf231";
+		supported = 1;
+		break;
+	default:
+		chip = "UNKNOWN";
+		break;
+	}
+
+	dev_info(&spi->dev, "Detected %s chip version %d\n", chip, lp->vers);
+	if (!supported) {
+		rc = -ENOTSUPP;
+		goto err_gpio_dir;
+	}
+
+	rc = at86rf230_hw_init(lp);
+	if (rc)
+		goto err_gpio_dir;
+
+	rc = request_irq(spi->irq, at86rf230_isr, IRQF_SHARED,
+			 dev_name(&spi->dev), lp);
+	if (rc)
+		goto err_gpio_dir;
+
+	rc = ieee802154_register_device(lp->dev);
+	if (rc)
+		goto err_irq;
+
+	return rc;
+
+	ieee802154_unregister_device(lp->dev);
+err_irq:
+	free_irq(spi->irq, lp);
+	flush_work(&lp->irqwork);
+err_gpio_dir:
+	if (gpio_is_valid(lp->slp_tr))
+		gpio_free(lp->slp_tr);
+err_slp_tr:
+	gpio_free(lp->rstn);
+err_rstn:
+err_fill:
+	spi_set_drvdata(spi, NULL);
+	mutex_destroy(&lp->bmux);
+	ieee802154_free_device(lp->dev);
+	return rc;
+}
+
+static int __devexit at86rf230_remove(struct spi_device *spi)
+{
+	struct at86rf230_local *lp = spi_get_drvdata(spi);
+
+	ieee802154_unregister_device(lp->dev);
+
+	free_irq(spi->irq, lp);
+	flush_work(&lp->irqwork);
+
+	if (gpio_is_valid(lp->slp_tr))
+		gpio_free(lp->slp_tr);
+	gpio_free(lp->rstn);
+
+	spi_set_drvdata(spi, NULL);
+	mutex_destroy(&lp->bmux);
+	ieee802154_free_device(lp->dev);
+
+	dev_dbg(&spi->dev, "unregistered at86rf230\n");
+	return 0;
+}
+
+static struct spi_driver at86rf230_driver = {
+	.driver = {
+		.name	= "at86rf230",
+		.owner	= THIS_MODULE,
+	},
+	.probe      = at86rf230_probe,
+	.remove     = __devexit_p(at86rf230_remove),
+	.suspend    = at86rf230_suspend,
+	.resume     = at86rf230_resume,
+};
+
+module_spi_driver(at86rf230_driver);
+
+MODULE_DESCRIPTION("AT86RF230 Transceiver Driver");
+MODULE_LICENSE("GPL v2");
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
new file mode 100644
index 0000000..73d4531
--- /dev/null
+++ b/drivers/net/ieee802154/fakehard.c
@@ -0,0 +1,449 @@
+/*
+ * Sample driver for HardMAC IEEE 802.15.4 devices
+ *
+ * Copyright (C) 2009 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Dmitry Eremin-Solenikov <dmitry.baryshkov@siemens.com>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+
+#include <net/af_ieee802154.h>
+#include <net/ieee802154_netdev.h>
+#include <net/ieee802154.h>
+#include <net/nl802154.h>
+#include <net/wpan-phy.h>
+
+struct fakehard_priv {
+	struct wpan_phy *phy;
+};
+
+static struct wpan_phy *fake_to_phy(const struct net_device *dev)
+{
+	struct fakehard_priv *priv = netdev_priv(dev);
+	return priv->phy;
+}
+
+/**
+ * fake_get_phy - Return a phy corresponding to this device.
+ * @dev: The network device for which to return the wan-phy object
+ *
+ * This function returns a wpan-phy object corresponding to the passed
+ * network device. Reference counter for wpan-phy object is incremented,
+ * so when the wpan-phy isn't necessary, you should drop the reference
+ * via @wpan_phy_put() call.
+ */
+static struct wpan_phy *fake_get_phy(const struct net_device *dev)
+{
+	struct wpan_phy *phy = fake_to_phy(dev);
+	return to_phy(get_device(&phy->dev));
+}
+
+/**
+ * fake_get_pan_id - Retrieve the PAN ID of the device.
+ * @dev: The network device to retrieve the PAN of.
+ *
+ * Return the ID of the PAN from the PIB.
+ */
+static u16 fake_get_pan_id(const struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0xeba1;
+}
+
+/**
+ * fake_get_short_addr - Retrieve the short address of the device.
+ * @dev: The network device to retrieve the short address of.
+ *
+ * Returns the IEEE 802.15.4 short-form address cached for this
+ * device. If the device has not yet had a short address assigned
+ * then this should return 0xFFFF to indicate a lack of association.
+ */
+static u16 fake_get_short_addr(const struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x1;
+}
+
+/**
+ * fake_get_dsn - Retrieve the DSN of the device.
+ * @dev: The network device to retrieve the DSN for.
+ *
+ * Returns the IEEE 802.15.4 DSN for the network device.
+ * The DSN is the sequence number which will be added to each
+ * packet or MAC command frame by the MAC during transmission.
+ *
+ * DSN means 'Data Sequence Number'.
+ *
+ * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
+ *       document.
+ */
+static u8 fake_get_dsn(const struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x00; /* DSN are implemented in HW, so return just 0 */
+}
+
+/**
+ * fake_get_bsn - Retrieve the BSN of the device.
+ * @dev: The network device to retrieve the BSN for.
+ *
+ * Returns the IEEE 802.15.4 BSN for the network device.
+ * The BSN is the sequence number which will be added to each
+ * beacon frame sent by the MAC.
+ *
+ * BSN means 'Beacon Sequence Number'.
+ *
+ * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
+ *       document.
+ */
+static u8 fake_get_bsn(const struct net_device *dev)
+{
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	return 0x00; /* BSN are implemented in HW, so return just 0 */
+}
+
+/**
+ * fake_assoc_req - Make an association request to the HW.
+ * @dev: The network device which we are associating to a network.
+ * @addr: The coordinator with which we wish to associate.
+ * @channel: The channel on which to associate.
+ * @cap: The capability information field to use in the association.
+ *
+ * Start an association with a coordinator. The coordinator's address
+ * and PAN ID can be found in @addr.
+ *
+ * Note: This is in section 7.3.1 and 7.5.3.1 of the IEEE
+ *       802.15.4-2006 document.
+ */
+static int fake_assoc_req(struct net_device *dev,
+		struct ieee802154_addr *addr, u8 channel, u8 page, u8 cap)
+{
+	struct wpan_phy *phy = fake_to_phy(dev);
+
+	mutex_lock(&phy->pib_lock);
+	phy->current_channel = channel;
+	phy->current_page = page;
+	mutex_unlock(&phy->pib_lock);
+
+	/* We simply emulate it here */
+	return ieee802154_nl_assoc_confirm(dev, fake_get_short_addr(dev),
+			IEEE802154_SUCCESS);
+}
+
+/**
+ * fake_assoc_resp - Send an association response to a device.
+ * @dev: The network device on which to send the response.
+ * @addr: The address of the device to respond to.
+ * @short_addr: The assigned short address for the device (if any).
+ * @status: The result of the association request.
+ *
+ * Queue the association response of the coordinator to another
+ * device's attempt to associate with the network which we
+ * coordinate. This is then added to the indirect-send queue to be
+ * transmitted to the end device when it polls for data.
+ *
+ * Note: This is in section 7.3.2 and 7.5.3.1 of the IEEE
+ *       802.15.4-2006 document.
+ */
+static int fake_assoc_resp(struct net_device *dev,
+		struct ieee802154_addr *addr, u16 short_addr, u8 status)
+{
+	return 0;
+}
+
+/**
+ * fake_disassoc_req - Disassociate a device from a network.
+ * @dev: The network device on which we're disassociating a device.
+ * @addr: The device to disassociate from the network.
+ * @reason: The reason to give to the device for being disassociated.
+ *
+ * This sends a disassociation notification to the device being
+ * disassociated from the network.
+ *
+ * Note: This is in section 7.5.3.2 of the IEEE 802.15.4-2006
+ *       document, with the reason described in 7.3.3.2.
+ */
+static int fake_disassoc_req(struct net_device *dev,
+		struct ieee802154_addr *addr, u8 reason)
+{
+	return ieee802154_nl_disassoc_confirm(dev, IEEE802154_SUCCESS);
+}
+
+/**
+ * fake_start_req - Start an IEEE 802.15.4 PAN.
+ * @dev: The network device on which to start the PAN.
+ * @addr: The coordinator address to use when starting the PAN.
+ * @channel: The channel on which to start the PAN.
+ * @bcn_ord: Beacon order.
+ * @sf_ord: Superframe order.
+ * @pan_coord: Whether or not we are the PAN coordinator or just
+ *             requesting a realignment perhaps?
+ * @blx: Battery Life Extension feature bitfield.
+ * @coord_realign: Something to realign something else.
+ *
+ * If pan_coord is non-zero then this starts a network with the
+ * provided parameters, otherwise it attempts a coordinator
+ * realignment of the stated network instead.
+ *
+ * Note: This is in section 7.5.2.3 of the IEEE 802.15.4-2006
+ * document, with 7.3.8 describing coordinator realignment.
+ */
+static int fake_start_req(struct net_device *dev, struct ieee802154_addr *addr,
+				u8 channel, u8 page,
+				u8 bcn_ord, u8 sf_ord, u8 pan_coord, u8 blx,
+				u8 coord_realign)
+{
+	struct wpan_phy *phy = fake_to_phy(dev);
+
+	mutex_lock(&phy->pib_lock);
+	phy->current_channel = channel;
+	phy->current_page = page;
+	mutex_unlock(&phy->pib_lock);
+
+	/* We don't emulate beacons here at all, so START should fail */
+	ieee802154_nl_start_confirm(dev, IEEE802154_INVALID_PARAMETER);
+	return 0;
+}
+
+/**
+ * fake_scan_req - Start a channel scan.
+ * @dev: The network device on which to perform a channel scan.
+ * @type: The type of scan to perform.
+ * @channels: The channel bitmask to scan.
+ * @duration: How long to spend on each channel.
+ *
+ * This starts either a passive (energy) scan or an active (PAN) scan
+ * on the channels indicated in the @channels bitmask. The duration of
+ * the scan is measured in terms of superframe duration. Specifically,
+ * the scan will spend aBaseSuperFrameDuration * ((2^n) + 1) on each
+ * channel.
+ *
+ * Note: This is in section 7.5.2.1 of the IEEE 802.15.4-2006 document.
+ */
+static int fake_scan_req(struct net_device *dev, u8 type, u32 channels,
+		u8 page, u8 duration)
+{
+	u8 edl[27] = {};
+	return ieee802154_nl_scan_confirm(dev, IEEE802154_SUCCESS, type,
+			channels, page,
+			type == IEEE802154_MAC_SCAN_ED ? edl : NULL);
+}
+
+static struct ieee802154_mlme_ops fake_mlme = {
+	.assoc_req = fake_assoc_req,
+	.assoc_resp = fake_assoc_resp,
+	.disassoc_req = fake_disassoc_req,
+	.start_req = fake_start_req,
+	.scan_req = fake_scan_req,
+
+	.get_phy = fake_get_phy,
+
+	.get_pan_id = fake_get_pan_id,
+	.get_short_addr = fake_get_short_addr,
+	.get_dsn = fake_get_dsn,
+	.get_bsn = fake_get_bsn,
+};
+
+static int ieee802154_fake_open(struct net_device *dev)
+{
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int ieee802154_fake_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static netdev_tx_t ieee802154_fake_xmit(struct sk_buff *skb,
+					      struct net_device *dev)
+{
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
+	/* FIXME: do hardware work here ... */
+
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+
+static int ieee802154_fake_ioctl(struct net_device *dev, struct ifreq *ifr,
+		int cmd)
+{
+	struct sockaddr_ieee802154 *sa =
+		(struct sockaddr_ieee802154 *)&ifr->ifr_addr;
+	u16 pan_id, short_addr;
+
+	switch (cmd) {
+	case SIOCGIFADDR:
+		/* FIXME: fixed here, get from device IRL */
+		pan_id = fake_get_pan_id(dev);
+		short_addr = fake_get_short_addr(dev);
+		if (pan_id == IEEE802154_PANID_BROADCAST ||
+		    short_addr == IEEE802154_ADDR_BROADCAST)
+			return -EADDRNOTAVAIL;
+
+		sa->family = AF_IEEE802154;
+		sa->addr.addr_type = IEEE802154_ADDR_SHORT;
+		sa->addr.pan_id = pan_id;
+		sa->addr.short_addr = short_addr;
+		return 0;
+	}
+	return -ENOIOCTLCMD;
+}
+
+static int ieee802154_fake_mac_addr(struct net_device *dev, void *p)
+{
+	return -EBUSY; /* HW address is built into the device */
+}
+
+static const struct net_device_ops fake_ops = {
+	.ndo_open		= ieee802154_fake_open,
+	.ndo_stop		= ieee802154_fake_close,
+	.ndo_start_xmit		= ieee802154_fake_xmit,
+	.ndo_do_ioctl		= ieee802154_fake_ioctl,
+	.ndo_set_mac_address	= ieee802154_fake_mac_addr,
+};
+
+static void ieee802154_fake_destruct(struct net_device *dev)
+{
+	struct wpan_phy *phy = fake_to_phy(dev);
+
+	wpan_phy_unregister(phy);
+	free_netdev(dev);
+	wpan_phy_free(phy);
+}
+
+static void ieee802154_fake_setup(struct net_device *dev)
+{
+	dev->addr_len		= IEEE802154_ADDR_LEN;
+	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
+	dev->features		= NETIF_F_HW_CSUM;
+	dev->needed_tailroom	= 2; /* FCS */
+	dev->mtu		= 127;
+	dev->tx_queue_len	= 10;
+	dev->type		= ARPHRD_IEEE802154;
+	dev->flags		= IFF_NOARP | IFF_BROADCAST;
+	dev->watchdog_timeo	= 0;
+	dev->destructor		= ieee802154_fake_destruct;
+}
+
+
+static int __devinit ieee802154fake_probe(struct platform_device *pdev)
+{
+	struct net_device *dev;
+	struct fakehard_priv *priv;
+	struct wpan_phy *phy = wpan_phy_alloc(0);
+	int err;
+
+	if (!phy)
+		return -ENOMEM;
+
+	dev = alloc_netdev(sizeof(struct fakehard_priv), "hardwpan%d", ieee802154_fake_setup);
+	if (!dev) {
+		wpan_phy_free(phy);
+		return -ENOMEM;
+	}
+
+	memcpy(dev->dev_addr, "\xba\xbe\xca\xfe\xde\xad\xbe\xef",
+			dev->addr_len);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
+
+	/*
+	 * For now we'd like to emulate 2.4 GHz-only device,
+	 * both O-QPSK and CSS
+	 */
+	/* 2.4 GHz O-QPSK 802.15.4-2003 */
+	phy->channels_supported[0] |= 0x7FFF800;
+	/* 2.4 GHz CSS 802.15.4a-2007 */
+	phy->channels_supported[3] |= 0x3fff;
+
+	phy->transmit_power = 0xbf;
+
+	dev->netdev_ops = &fake_ops;
+	dev->ml_priv = &fake_mlme;
+
+	priv = netdev_priv(dev);
+	priv->phy = phy;
+
+	wpan_phy_set_dev(phy, &pdev->dev);
+	SET_NETDEV_DEV(dev, &phy->dev);
+
+	platform_set_drvdata(pdev, dev);
+
+	err = wpan_phy_register(phy);
+	if (err)
+		goto out;
+
+	err = register_netdev(dev);
+	if (err < 0)
+		goto out;
+
+	dev_info(&pdev->dev, "Added ieee802154 HardMAC hardware\n");
+	return 0;
+
+out:
+	unregister_netdev(dev);
+	return err;
+}
+
+static int __devexit ieee802154fake_remove(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	unregister_netdev(dev);
+	return 0;
+}
+
+static struct platform_device *ieee802154fake_dev;
+
+static struct platform_driver ieee802154fake_driver = {
+	.probe = ieee802154fake_probe,
+	.remove = __devexit_p(ieee802154fake_remove),
+	.driver = {
+			.name = "ieee802154hardmac",
+			.owner = THIS_MODULE,
+	},
+};
+
+static __init int fake_init(void)
+{
+	ieee802154fake_dev = platform_device_register_simple(
+			"ieee802154hardmac", -1, NULL, 0);
+	return platform_driver_register(&ieee802154fake_driver);
+}
+
+static __exit void fake_exit(void)
+{
+	platform_driver_unregister(&ieee802154fake_driver);
+	platform_device_unregister(ieee802154fake_dev);
+}
+
+module_init(fake_init);
+module_exit(fake_exit);
+MODULE_LICENSE("GPL");
+
diff --git a/drivers/net/ieee802154/fakelb.c b/drivers/net/ieee802154/fakelb.c
new file mode 100644
index 0000000..e7456fc
--- /dev/null
+++ b/drivers/net/ieee802154/fakelb.c
@@ -0,0 +1,294 @@
+/*
+ * Loopback IEEE 802.15.4 interface
+ *
+ * Copyright 2007-2012 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <slapin@ossfans.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
+ * Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
+ */
+
+#include <linux/module.h>
+#include <linux/timer.h>
+#include <linux/platform_device.h>
+#include <linux/netdevice.h>
+#include <linux/spinlock.h>
+#include <net/mac802154.h>
+#include <net/wpan-phy.h>
+
+static int numlbs = 1;
+
+struct fakelb_dev_priv {
+	struct ieee802154_dev *dev;
+
+	struct list_head list;
+	struct fakelb_priv *fake;
+
+	spinlock_t lock;
+	bool working;
+};
+
+struct fakelb_priv {
+	struct list_head list;
+	rwlock_t lock;
+};
+
+static int
+fakelb_hw_ed(struct ieee802154_dev *dev, u8 *level)
+{
+	might_sleep();
+	BUG_ON(!level);
+	*level = 0xbe;
+
+	return 0;
+}
+
+static int
+fakelb_hw_channel(struct ieee802154_dev *dev, int page, int channel)
+{
+	pr_debug("set channel to %d\n", channel);
+
+	might_sleep();
+	dev->phy->current_page = page;
+	dev->phy->current_channel = channel;
+
+	return 0;
+}
+
+static void
+fakelb_hw_deliver(struct fakelb_dev_priv *priv, struct sk_buff *skb)
+{
+	struct sk_buff *newskb;
+
+	spin_lock(&priv->lock);
+	if (priv->working) {
+		newskb = pskb_copy(skb, GFP_ATOMIC);
+		ieee802154_rx_irqsafe(priv->dev, newskb, 0xcc);
+	}
+	spin_unlock(&priv->lock);
+}
+
+static int
+fakelb_hw_xmit(struct ieee802154_dev *dev, struct sk_buff *skb)
+{
+	struct fakelb_dev_priv *priv = dev->priv;
+	struct fakelb_priv *fake = priv->fake;
+
+	might_sleep();
+
+	read_lock_bh(&fake->lock);
+	if (priv->list.next == priv->list.prev) {
+		/* we are the only one device */
+		fakelb_hw_deliver(priv, skb);
+	} else {
+		struct fakelb_dev_priv *dp;
+		list_for_each_entry(dp, &priv->fake->list, list) {
+			if (dp != priv &&
+			    (dp->dev->phy->current_channel ==
+			     priv->dev->phy->current_channel))
+				fakelb_hw_deliver(dp, skb);
+		}
+	}
+	read_unlock_bh(&fake->lock);
+
+	return 0;
+}
+
+static int
+fakelb_hw_start(struct ieee802154_dev *dev) {
+	struct fakelb_dev_priv *priv = dev->priv;
+	int ret = 0;
+
+	spin_lock(&priv->lock);
+	if (priv->working)
+		ret = -EBUSY;
+	else
+		priv->working = 1;
+	spin_unlock(&priv->lock);
+
+	return ret;
+}
+
+static void
+fakelb_hw_stop(struct ieee802154_dev *dev) {
+	struct fakelb_dev_priv *priv = dev->priv;
+
+	spin_lock(&priv->lock);
+	priv->working = 0;
+	spin_unlock(&priv->lock);
+}
+
+static struct ieee802154_ops fakelb_ops = {
+	.owner = THIS_MODULE,
+	.xmit = fakelb_hw_xmit,
+	.ed = fakelb_hw_ed,
+	.set_channel = fakelb_hw_channel,
+	.start = fakelb_hw_start,
+	.stop = fakelb_hw_stop,
+};
+
+/* Number of dummy devices to be set up by this module. */
+module_param(numlbs, int, 0);
+MODULE_PARM_DESC(numlbs, " number of pseudo devices");
+
+static int fakelb_add_one(struct device *dev, struct fakelb_priv *fake)
+{
+	struct fakelb_dev_priv *priv;
+	int err;
+	struct ieee802154_dev *ieee;
+
+	ieee = ieee802154_alloc_device(sizeof(*priv), &fakelb_ops);
+	if (!ieee)
+		return -ENOMEM;
+
+	priv = ieee->priv;
+	priv->dev = ieee;
+
+	/* 868 MHz BPSK	802.15.4-2003 */
+	ieee->phy->channels_supported[0] |= 1;
+	/* 915 MHz BPSK	802.15.4-2003 */
+	ieee->phy->channels_supported[0] |= 0x7fe;
+	/* 2.4 GHz O-QPSK 802.15.4-2003 */
+	ieee->phy->channels_supported[0] |= 0x7FFF800;
+	/* 868 MHz ASK 802.15.4-2006 */
+	ieee->phy->channels_supported[1] |= 1;
+	/* 915 MHz ASK 802.15.4-2006 */
+	ieee->phy->channels_supported[1] |= 0x7fe;
+	/* 868 MHz O-QPSK 802.15.4-2006 */
+	ieee->phy->channels_supported[2] |= 1;
+	/* 915 MHz O-QPSK 802.15.4-2006 */
+	ieee->phy->channels_supported[2] |= 0x7fe;
+	/* 2.4 GHz CSS 802.15.4a-2007 */
+	ieee->phy->channels_supported[3] |= 0x3fff;
+	/* UWB Sub-gigahertz 802.15.4a-2007 */
+	ieee->phy->channels_supported[4] |= 1;
+	/* UWB Low band 802.15.4a-2007 */
+	ieee->phy->channels_supported[4] |= 0x1e;
+	/* UWB High band 802.15.4a-2007 */
+	ieee->phy->channels_supported[4] |= 0xffe0;
+	/* 750 MHz O-QPSK 802.15.4c-2009 */
+	ieee->phy->channels_supported[5] |= 0xf;
+	/* 750 MHz MPSK 802.15.4c-2009 */
+	ieee->phy->channels_supported[5] |= 0xf0;
+	/* 950 MHz BPSK 802.15.4d-2009 */
+	ieee->phy->channels_supported[6] |= 0x3ff;
+	/* 950 MHz GFSK 802.15.4d-2009 */
+	ieee->phy->channels_supported[6] |= 0x3ffc00;
+
+	INIT_LIST_HEAD(&priv->list);
+	priv->fake = fake;
+
+	spin_lock_init(&priv->lock);
+
+	ieee->parent = dev;
+
+	err = ieee802154_register_device(ieee);
+	if (err)
+		goto err_reg;
+
+	write_lock_bh(&fake->lock);
+	list_add_tail(&priv->list, &fake->list);
+	write_unlock_bh(&fake->lock);
+
+	return 0;
+
+err_reg:
+	ieee802154_free_device(priv->dev);
+	return err;
+}
+
+static void fakelb_del(struct fakelb_dev_priv *priv)
+{
+	write_lock_bh(&priv->fake->lock);
+	list_del(&priv->list);
+	write_unlock_bh(&priv->fake->lock);
+
+	ieee802154_unregister_device(priv->dev);
+	ieee802154_free_device(priv->dev);
+}
+
+static int __devinit fakelb_probe(struct platform_device *pdev)
+{
+	struct fakelb_priv *priv;
+	struct fakelb_dev_priv *dp;
+	int err = -ENOMEM;
+	int i;
+
+	priv = kzalloc(sizeof(struct fakelb_priv), GFP_KERNEL);
+	if (!priv)
+		goto err_alloc;
+
+	INIT_LIST_HEAD(&priv->list);
+	rwlock_init(&priv->lock);
+
+	for (i = 0; i < numlbs; i++) {
+		err = fakelb_add_one(&pdev->dev, priv);
+		if (err < 0)
+			goto err_slave;
+	}
+
+	platform_set_drvdata(pdev, priv);
+	dev_info(&pdev->dev, "added ieee802154 hardware\n");
+	return 0;
+
+err_slave:
+	list_for_each_entry(dp, &priv->list, list)
+		fakelb_del(dp);
+	kfree(priv);
+err_alloc:
+	return err;
+}
+
+static int __devexit fakelb_remove(struct platform_device *pdev)
+{
+	struct fakelb_priv *priv = platform_get_drvdata(pdev);
+	struct fakelb_dev_priv *dp, *temp;
+
+	list_for_each_entry_safe(dp, temp, &priv->list, list)
+		fakelb_del(dp);
+	kfree(priv);
+
+	return 0;
+}
+
+static struct platform_device *ieee802154fake_dev;
+
+static struct platform_driver ieee802154fake_driver = {
+	.probe = fakelb_probe,
+	.remove = __devexit_p(fakelb_remove),
+	.driver = {
+			.name = "ieee802154fakelb",
+			.owner = THIS_MODULE,
+	},
+};
+
+static __init int fakelb_init_module(void)
+{
+	ieee802154fake_dev = platform_device_register_simple(
+			     "ieee802154fakelb", -1, NULL, 0);
+	return platform_driver_register(&ieee802154fake_driver);
+}
+
+static __exit void fake_remove_module(void)
+{
+	platform_driver_unregister(&ieee802154fake_driver);
+	platform_device_unregister(ieee802154fake_dev);
+}
+
+module_init(fakelb_init_module);
+module_exit(fake_remove_module);
+MODULE_LICENSE("GPL");
-- 
1.7.2.3
