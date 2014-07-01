From: Stefan Wahren <stefan.wahren@i2se.com>
Subject: [PATCH RFC V2 2/2] net: qualcomm: new Ethernet over SPI driver for QCA7000
Date: Tue,  1 Jul 2014 18:36:49 +0200
Message-ID: <1404232609-4314-3-git-send-email-stefan.wahren@i2se.com>
References: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org
To: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, eric.dumazet@gmail.com,
	dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:54827 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330AbaGAQh3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 12:37:29 -0400
In-Reply-To: <1404232609-4314-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Ethernet over SPI driver for the
Qualcomm QCA7000 HomePlug GreenPHY.

Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
---
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/qualcomm/Kconfig       |   30 +
 drivers/net/ethernet/qualcomm/Makefile      |    6 +
 drivers/net/ethernet/qualcomm/qca_7k.c      |  149 ++++
 drivers/net/ethernet/qualcomm/qca_7k.h      |   72 ++
 drivers/net/ethernet/qualcomm/qca_debug.c   |  311 +++++++++
 drivers/net/ethernet/qualcomm/qca_debug.h   |   34 +
 drivers/net/ethernet/qualcomm/qca_framing.c |  155 +++++
 drivers/net/ethernet/qualcomm/qca_framing.h |  134 ++++
 drivers/net/ethernet/qualcomm/qca_spi.c     | 1001 +++++++++++++++++++++++++++
 drivers/net/ethernet/qualcomm/qca_spi.h     |  114 +++
 12 files changed, 2008 insertions(+)
 create mode 100644 drivers/net/ethernet/qualcomm/Kconfig
 create mode 100644 drivers/net/ethernet/qualcomm/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_7k.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_debug.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.c
 create mode 100644 drivers/net/ethernet/qualcomm/qca_spi.h

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index edb7186..1d102b5 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -149,6 +149,7 @@ config ETHOC
 source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
+source "drivers/net/ethernet/qualcomm/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/renesas/Kconfig"
 source "drivers/net/ethernet/rdc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 58de333..b40e0d7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
+obj-$(CONFIG_NET_VENDOR_QUALCOMM) += qualcomm/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
new file mode 100644
index 0000000..f3a4714
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -0,0 +1,30 @@
+#
+# Qualcomm network device configuration
+#
+
+config NET_VENDOR_QUALCOMM
+	bool "Qualcomm devices"
+	default y
+	depends on SPI_MASTER && OF_GPIO
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Qualcomm cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+if NET_VENDOR_QUALCOMM
+
+config QCA7000
+	tristate "Qualcomm Atheros QCA7000 support"
+	depends on SPI_MASTER && OF_GPIO
+	---help---
+	  This SPI protocol driver supports the Qualcomm Atheros QCA7000.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called qcaspi.
+
+endif # NET_VENDOR_QUALCOMM
diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
new file mode 100644
index 0000000..9da2d75
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Qualcomm network device drivers.
+#
+
+obj-$(CONFIG_QCA7000) += qcaspi.o
+qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
diff --git a/drivers/net/ethernet/qualcomm/qca_7k.c b/drivers/net/ethernet/qualcomm/qca_7k.c
new file mode 100644
index 0000000..f7fc52b
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_7k.c
@@ -0,0 +1,149 @@
+/*
+ *
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ *
+ */
+
+/*   This module implements the Qualcomm Atheros SPI protocol for
+ *   kernel-based SPI device.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/spi/spi.h>
+#include <linux/version.h>
+
+#include "qca_7k.h"
+
+void
+qcaspi_spi_error(struct qcaspi *qca)
+{
+	if (qca->sync != QCASPI_SYNC_READY)
+		return;
+
+	netdev_err(qca->net_dev, "spi error\n");
+	qca->sync = QCASPI_SYNC_UNKNOWN;
+	qca->stats.spi_err++;
+}
+
+int
+qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result)
+{
+	u16 rx_data;
+	u16 tx_data;
+	struct spi_transfer *transfer;
+	struct spi_message *msg;
+	int ret;
+
+	tx_data = cpu_to_be16(QCA7K_SPI_READ | QCA7K_SPI_INTERNAL | reg);
+
+	if (qca->legacy_mode) {
+		msg = &qca->spi_msg1;
+		transfer = &qca->spi_xfer1;
+		transfer->tx_buf = &tx_data;
+		transfer->rx_buf = NULL;
+		transfer->len = QCASPI_CMD_LEN;
+		spi_sync(qca->spi_dev, msg);
+	} else {
+		msg = &qca->spi_msg2;
+		transfer = &qca->spi_xfer2[0];
+		transfer->tx_buf = &tx_data;
+		transfer->rx_buf = NULL;
+		transfer->len = QCASPI_CMD_LEN;
+		transfer = &qca->spi_xfer2[1];
+	}
+	transfer->tx_buf = NULL;
+	transfer->rx_buf = &rx_data;
+	transfer->len = QCASPI_CMD_LEN;
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (!ret)
+		ret = msg->status;
+
+	if (ret)
+		qcaspi_spi_error(qca);
+	else
+		*result = be16_to_cpu(rx_data);
+
+	return ret;
+}
+
+int
+qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value)
+{
+	u16 tx_data[2];
+	struct spi_transfer *transfer;
+	struct spi_message *msg;
+	int ret;
+
+	tx_data[0] = cpu_to_be16(QCA7K_SPI_WRITE | QCA7K_SPI_INTERNAL | reg);
+	tx_data[1] = cpu_to_be16(value);
+
+	if (qca->legacy_mode) {
+		msg = &qca->spi_msg1;
+		transfer = &qca->spi_xfer1;
+		transfer->tx_buf = &tx_data[0];
+		transfer->rx_buf = NULL;
+		transfer->len = QCASPI_CMD_LEN;
+		spi_sync(qca->spi_dev, msg);
+	} else {
+		msg = &qca->spi_msg2;
+		transfer = &qca->spi_xfer2[0];
+		transfer->tx_buf = &tx_data[0];
+		transfer->rx_buf = NULL;
+		transfer->len = QCASPI_CMD_LEN;
+		transfer = &qca->spi_xfer2[1];
+	}
+	transfer->tx_buf = &tx_data[1];
+	transfer->rx_buf = NULL;
+	transfer->len = QCASPI_CMD_LEN;
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (!ret)
+		ret = msg->status;
+
+	if (ret)
+		qcaspi_spi_error(qca);
+
+	return ret;
+}
+
+int
+qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd)
+{
+	struct spi_message *msg = &qca->spi_msg1;
+	struct spi_transfer *transfer = &qca->spi_xfer1;
+	int ret;
+
+	cmd = cpu_to_be16(cmd);
+	transfer->len = sizeof(cmd);
+	transfer->tx_buf = &cmd;
+	transfer->rx_buf = NULL;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (!ret)
+		ret = msg->status;
+
+	if (ret)
+		qcaspi_spi_error(qca);
+
+	return ret;
+}
+
diff --git a/drivers/net/ethernet/qualcomm/qca_7k.h b/drivers/net/ethernet/qualcomm/qca_7k.h
new file mode 100644
index 0000000..1cad851
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_7k.h
@@ -0,0 +1,72 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ *
+ */
+
+/*   Qualcomm Atheros SPI register definition.
+ *
+ *   This module is designed to define the Qualcomm Atheros SPI
+ *   register placeholders.
+ */
+
+#ifndef _QCA_7K_H
+#define _QCA_7K_H
+
+#include <linux/types.h>
+
+#include "qca_spi.h"
+
+#define QCA7K_SPI_READ     (1 << 15)
+#define QCA7K_SPI_WRITE    (0 << 15)
+#define QCA7K_SPI_INTERNAL (1 << 14)
+#define QCA7K_SPI_EXTERNAL (0 << 14)
+
+#define QCASPI_CMD_LEN    2
+#define QCASPI_HW_PKT_LEN 4
+#define QCASPI_HW_BUF_LEN 0xC5B
+
+/*   SPI registers;                               */
+#define SPI_REG_BFR_SIZE        0x0100
+#define SPI_REG_WRBUF_SPC_AVA   0x0200
+#define SPI_REG_RDBUF_BYTE_AVA  0x0300
+#define SPI_REG_SPI_CONFIG      0x0400
+#define SPI_REG_SPI_STATUS      0x0500
+#define SPI_REG_INTR_CAUSE      0x0C00
+#define SPI_REG_INTR_ENABLE     0x0D00
+#define SPI_REG_RDBUF_WATERMARK 0x1200
+#define SPI_REG_WRBUF_WATERMARK 0x1300
+#define SPI_REG_SIGNATURE       0x1A00
+#define SPI_REG_ACTION_CTRL     0x1B00
+
+/*   SPI_CONFIG register definition;             */
+#define QCASPI_SLAVE_RESET_BIT (1 << 6)
+
+/*   INTR_CAUSE/ENABLE register definition.      */
+#define SPI_INT_WRBUF_BELOW_WM (1 << 10)
+#define SPI_INT_CPU_ON         (1 << 6)
+#define SPI_INT_ADDR_ERR       (1 << 3)
+#define SPI_INT_WRBUF_ERR      (1 << 2)
+#define SPI_INT_RDBUF_ERR      (1 << 1)
+#define SPI_INT_PKT_AVLBL      (1 << 0)
+
+void qcaspi_spi_error(struct qcaspi *qca);
+int qcaspi_read_register(struct qcaspi *qca, u16 reg, u16 *result);
+int qcaspi_write_register(struct qcaspi *qca, u16 reg, u16 value);
+int qcaspi_tx_cmd(struct qcaspi *qca, u16 cmd);
+
+#endif /* _QCA_7K_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_debug.c b/drivers/net/ethernet/qualcomm/qca_debug.c
new file mode 100644
index 0000000..e88448c
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_debug.c
@@ -0,0 +1,311 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   This file contains debugging routines for use in the QCA7K driver.
+ */
+
+#include <linux/debugfs.h>
+#include <linux/ethtool.h>
+#include <linux/seq_file.h>
+#include <linux/types.h>
+
+#include "qca_7k.h"
+#include "qca_spi.h"
+
+#define QCASPI_MAX_REGS 0x20
+
+static const u16 qcaspi_spi_regs[] = {
+	SPI_REG_BFR_SIZE,
+	SPI_REG_WRBUF_SPC_AVA,
+	SPI_REG_RDBUF_BYTE_AVA,
+	SPI_REG_SPI_CONFIG,
+	SPI_REG_SPI_STATUS,
+	SPI_REG_INTR_CAUSE,
+	SPI_REG_INTR_ENABLE,
+	SPI_REG_RDBUF_WATERMARK,
+	SPI_REG_WRBUF_WATERMARK,
+	SPI_REG_SIGNATURE,
+	SPI_REG_ACTION_CTRL
+};
+
+/* The order of these strings must match the order of the fields in
+ * struct qcaspi_stats
+ * See qca_spi.h
+ */
+static const char qcaspi_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"Triggered resets",
+	"Device resets",
+	"Reset timeouts",
+	"Read errors",
+	"Write errors",
+	"Read buffer errors",
+	"Write buffer errors",
+	"Out of memory",
+	"Write buffer misses",
+	"Transmit ring full",
+	"SPI errors",
+};
+
+#ifdef CONFIG_DEBUG_FS
+
+static int
+qcaspi_info_show(struct seq_file *s, void *what)
+{
+	struct qcaspi *qca = s->private;
+
+	seq_printf(s, "RX buffer size   : %lu\n",
+		(unsigned long) qca->buffer_size);
+
+	seq_puts(s, "TX ring state    : ");
+
+	if (qca->txr.skb[qca->txr.head] == NULL)
+		seq_puts(s, "empty");
+	else if (qca->txr.skb[qca->txr.tail])
+		seq_puts(s, "full");
+	else
+		seq_puts(s, "in use");
+
+	seq_puts(s, "\n");
+
+	seq_printf(s, "TX ring size     : %u\n",
+		qca->txr.size);
+
+	seq_printf(s, "Sync state       : %u (",
+		(unsigned int) qca->sync);
+	switch (qca->sync) {
+	case QCASPI_SYNC_UNKNOWN:
+		seq_puts(s, "QCASPI_SYNC_UNKNOWN");
+		break;
+	case QCASPI_SYNC_RESET:
+		seq_puts(s, "QCASPI_SYNC_RESET");
+		break;
+	case QCASPI_SYNC_READY:
+		seq_puts(s, "QCASPI_SYNC_READY");
+		break;
+	default:
+		seq_puts(s, "INVALID");
+		break;
+	}
+	seq_puts(s, ")\n");
+
+	seq_printf(s, "IRQ              : %d\n",
+		qca->spi_dev->irq);
+	seq_printf(s, "INTR REQ         : %u\n",
+		qca->intr_req);
+	seq_printf(s, "INTR SVC         : %u\n",
+		qca->intr_svc);
+
+	seq_printf(s, "SPI max speed    : %lu\n",
+		(unsigned long) qca->spi_dev->max_speed_hz);
+	seq_printf(s, "SPI mode         : %x\n",
+		qca->spi_dev->mode);
+	seq_printf(s, "SPI chip select  : %u\n",
+		(unsigned int) qca->spi_dev->chip_select);
+	seq_printf(s, "SPI legacy mode  : %u\n",
+		(unsigned int) qca->legacy_mode);
+	seq_printf(s, "SPI burst length : %u\n",
+		(unsigned int) qca->burst_len);
+
+	return 0;
+}
+
+static int
+qcaspi_info_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, qcaspi_info_show, inode->i_private);
+}
+
+static const struct file_operations qcaspi_info_ops = {
+	.open = qcaspi_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+void
+qcaspi_init_device_debugfs(struct qcaspi *qca)
+{
+	struct dentry *device_root;
+
+	device_root = debugfs_create_dir(dev_name(&qca->net_dev->dev), NULL);
+	qca->device_root = device_root;
+
+	if (IS_ERR(device_root) || !device_root) {
+		pr_warn("failed to create debugfs directory for %s\n",
+			dev_name(&qca->net_dev->dev));
+		return;
+	}
+	debugfs_create_file("info", S_IFREG | S_IRUGO, device_root, qca,
+			&qcaspi_info_ops);
+}
+
+void
+qcaspi_remove_device_debugfs(struct qcaspi *qca)
+{
+	debugfs_remove_recursive(qca->device_root);
+}
+
+#else /* CONFIG_DEBUG_FS */
+
+void
+qcaspi_init_device_debugfs(struct qcaspi *qca)
+{
+}
+
+void
+qcaspi_remove_device_debugfs(struct qcaspi *qca)
+{
+}
+
+#endif
+
+static void
+qcaspi_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *p)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+
+	strlcpy(p->driver, QCASPI_DRV_NAME, sizeof(p->driver));
+	strlcpy(p->version, QCASPI_DRV_VERSION, sizeof(p->version));
+	strlcpy(p->fw_version, "QCA7000", sizeof(p->fw_version));
+	strlcpy(p->bus_info, dev_name(&qca->spi_dev->dev),
+		sizeof(p->bus_info));
+}
+
+static int
+qcaspi_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	cmd->transceiver = XCVR_INTERNAL;
+	cmd->supported = SUPPORTED_10baseT_Half;
+	ethtool_cmd_speed_set(cmd,  SPEED_10);
+	cmd->duplex = DUPLEX_HALF;
+	cmd->port = PORT_OTHER;
+	cmd->autoneg = AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static void
+qcaspi_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *estats, u64 *data)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+	struct qcaspi_stats *st = &qca->stats;
+
+	memcpy(data, st, ARRAY_SIZE(qcaspi_gstrings_stats) * sizeof(u64));
+}
+
+static void
+qcaspi_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(buf, &qcaspi_gstrings_stats,
+			sizeof(qcaspi_gstrings_stats));
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+}
+
+static int
+qcaspi_get_sset_count(struct net_device *dev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(qcaspi_gstrings_stats);
+	default:
+		return -EINVAL;
+	}
+}
+
+static int
+qcaspi_get_regs_len(struct net_device *dev)
+{
+	return sizeof(u32) * QCASPI_MAX_REGS;
+}
+
+static void
+qcaspi_get_regs(struct net_device *dev, struct ethtool_regs *regs, void *p)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+	u32 *regs_buff = p;
+	int i;
+
+	regs->version = 1;
+	memset(regs_buff, 0, sizeof(u32) * QCASPI_MAX_REGS);
+
+	for (i = 0; i < ARRAY_SIZE(qcaspi_spi_regs); i++) {
+		u16 offset, value;
+
+		qcaspi_read_register(qca, qcaspi_spi_regs[i], &value);
+		offset = qcaspi_spi_regs[i] >> 8;
+		regs_buff[offset] = value;
+	}
+}
+
+static void
+qcaspi_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+
+	ring->rx_max_pending = 4;
+	ring->tx_max_pending = TX_RING_MAX_LEN;
+	ring->rx_pending = 4;
+	ring->tx_pending = qca->txr.count;
+}
+
+static int
+qcaspi_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+
+	if ((ring->rx_pending) ||
+	    (ring->rx_mini_pending) ||
+	    (ring->rx_jumbo_pending))
+		return -EINVAL;
+
+	if (netif_running(dev))
+		qcaspi_netdev_close(dev);
+
+	qca->txr.count = max_t(u32, ring->tx_pending, TX_RING_MIN_LEN);
+	qca->txr.count = min_t(u16, qca->txr.count, TX_RING_MAX_LEN);
+
+	if (netif_running(dev))
+		qcaspi_netdev_open(dev);
+
+	return 0;
+}
+
+static const struct ethtool_ops qcaspi_ethtool_ops = {
+	.get_drvinfo = qcaspi_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_settings = qcaspi_get_settings,
+	.get_ethtool_stats = qcaspi_get_ethtool_stats,
+	.get_strings = qcaspi_get_strings,
+	.get_sset_count = qcaspi_get_sset_count,
+	.get_regs_len = qcaspi_get_regs_len,
+	.get_regs = qcaspi_get_regs,
+	.get_ringparam = qcaspi_get_ringparam,
+	.set_ringparam = qcaspi_set_ringparam,
+};
+
+void qcaspi_set_ethtool_ops(struct net_device *dev)
+{
+	SET_ETHTOOL_OPS(dev, &qcaspi_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/qualcomm/qca_debug.h b/drivers/net/ethernet/qualcomm/qca_debug.h
new file mode 100644
index 0000000..46a7858
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_debug.h
@@ -0,0 +1,34 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   This file contains debugging routines for use in the QCA7K driver.
+ */
+
+#ifndef _QCA_DEBUG_H
+#define _QCA_DEBUG_H
+
+#include "qca_spi.h"
+
+void qcaspi_init_device_debugfs(struct qcaspi *qca);
+
+void qcaspi_remove_device_debugfs(struct qcaspi *qca);
+
+void qcaspi_set_ethtool_ops(struct net_device *dev);
+
+#endif /* _QCA_DEBUG_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.c b/drivers/net/ethernet/qualcomm/qca_framing.c
new file mode 100644
index 0000000..3c8d8d4
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_framing.c
@@ -0,0 +1,155 @@
+/*
+ *   Copyright (c) 2011, 2012, Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   Atheros ethernet framing. Every Ethernet frame is surrounded
+ *   by an atheros frame while transmitted over a serial channel;
+ */
+
+#include <linux/kernel.h>
+
+#include "qca_framing.h"
+
+u16
+qcafrm_create_header(u8 *buf, u16 len)
+{
+	if (!buf)
+		return 0;
+
+	len = cpu_to_le16(len);
+
+	buf[0] = 0xAA;
+	buf[1] = 0xAA;
+	buf[2] = 0xAA;
+	buf[3] = 0xAA;
+	buf[4] = len & 0xff;
+	buf[5] = (len >> 8) & 0xff;
+	buf[6] = 0;
+	buf[7] = 0;
+
+	return QCAFRM_HEADER_LEN;
+}
+
+u16
+qcafrm_create_footer(u8 *buf)
+{
+	if (!buf)
+		return 0;
+
+	buf[0] = 0x55;
+	buf[1] = 0x55;
+	return QCAFRM_FOOTER_LEN;
+}
+
+/*   Gather received bytes and try to extract a full ethernet frame by
+ *   following a simple state machine.
+ *
+ * Return:   QCAFRM_GATHER       No ethernet frame fully received yet.
+ *           QCAFRM_NOHEAD       Header expected but not found.
+ *           QCAFRM_INVLEN       Atheros frame length is invalid
+ *           QCAFRM_NOTAIL       Footer expected but not found.
+ *           > 0                 Number of byte in the fully received
+ *                               Ethernet frame
+ */
+
+s32
+qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte)
+{
+	s32 ret = QCAFRM_GATHER;
+	u16 len;
+
+	switch (handle->state) {
+	case QCAFRM_HW_LEN0:
+	case QCAFRM_HW_LEN1:
+		/* by default, just go to next state */
+		handle->state--;
+
+		if (recv_byte != 0x00) {
+			/* first two bytes of length must be 0 */
+			handle->state = QCAFRM_HW_LEN0;
+		}
+		break;
+	case QCAFRM_HW_LEN2:
+	case QCAFRM_HW_LEN3:
+		handle->state--;
+		break;
+	/* 4 bytes header pattern */
+	case QCAFRM_WAIT_AA1:
+	case QCAFRM_WAIT_AA2:
+	case QCAFRM_WAIT_AA3:
+	case QCAFRM_WAIT_AA4:
+		if (recv_byte != 0xAA) {
+			ret = QCAFRM_NOHEAD;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state--;
+		}
+		break;
+		/* 2 bytes length. */
+		/* Borrow offset field to hold length for now. */
+	case QCAFRM_WAIT_LEN_BYTE0:
+		handle->offset = recv_byte;
+		handle->state = QCAFRM_WAIT_LEN_BYTE1;
+		break;
+	case QCAFRM_WAIT_LEN_BYTE1:
+		handle->offset = handle->offset | (recv_byte << 8);
+		handle->state = QCAFRM_WAIT_RSVD_BYTE1;
+		break;
+	case QCAFRM_WAIT_RSVD_BYTE1:
+		handle->state = QCAFRM_WAIT_RSVD_BYTE2;
+		break;
+	case QCAFRM_WAIT_RSVD_BYTE2:
+		len = handle->offset;
+		if (len > buf_len || len < QCAFRM_ETHMINLEN) {
+			ret = QCAFRM_INVLEN;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state = (enum qcafrm_state)(len + 1);
+			/* Remaining number of bytes. */
+			handle->offset = 0;
+		}
+		break;
+	default:
+		/* Receiving Ethernet frame itself. */
+		buf[handle->offset] = recv_byte;
+		handle->offset++;
+		handle->state--;
+		break;
+	case QCAFRM_WAIT_551:
+		if (recv_byte != 0x55) {
+			ret = QCAFRM_NOTAIL;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			handle->state = QCAFRM_WAIT_552;
+		}
+		break;
+	case QCAFRM_WAIT_552:
+		if (recv_byte != 0x55) {
+			ret = QCAFRM_NOTAIL;
+			handle->state = QCAFRM_HW_LEN0;
+		} else {
+			ret = handle->offset;
+			/* Frame is fully received. */
+			handle->state = QCAFRM_HW_LEN0;
+		}
+		break;
+	}
+
+	return ret;
+}
+
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_framing.h
new file mode 100644
index 0000000..5d96595
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_framing.h
@@ -0,0 +1,134 @@
+/*
+ *   Copyright (c) 2011, 2012, Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   Atheros Ethernet framing. Every Ethernet frame is surrounded by an atheros
+ *   frame while transmitted over a serial channel.
+ */
+
+#ifndef _QCA_FRAMING_H
+#define _QCA_FRAMING_H
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/types.h>
+
+/* Frame is currently being received */
+#define QCAFRM_GATHER 0
+
+/*  No header byte while expecting it */
+#define QCAFRM_NOHEAD (QCAFRM_ERR_BASE - 1)
+
+/* No tailer byte while expecting it */
+#define QCAFRM_NOTAIL (QCAFRM_ERR_BASE - 2)
+
+/* Frame length is invalid */
+#define QCAFRM_INVLEN (QCAFRM_ERR_BASE - 3)
+
+/* Frame length is invalid */
+#define QCAFRM_INVFRAME (QCAFRM_ERR_BASE - 4)
+
+/* Min/Max Ethernet MTU */
+#define QCAFRM_ETHMINMTU 46
+#define QCAFRM_ETHMAXMTU 1500
+
+/* Min/Max frame lengths */
+#define QCAFRM_ETHMINLEN (QCAFRM_ETHMINMTU + ETH_HLEN)
+#define QCAFRM_ETHMAXLEN (QCAFRM_ETHMAXMTU + VLAN_ETH_HLEN)
+
+/* QCA7K header len */
+#define QCAFRM_HEADER_LEN 8
+
+/* QCA7K footer len */
+#define QCAFRM_FOOTER_LEN 2
+
+/* QCA7K Framing. */
+#define QCAFRM_ERR_BASE -1000
+
+enum qcafrm_state {
+	QCAFRM_HW_LEN0 = 0x8000,
+	QCAFRM_HW_LEN1 = QCAFRM_HW_LEN0 - 1,
+	QCAFRM_HW_LEN2 = QCAFRM_HW_LEN1 - 1,
+	QCAFRM_HW_LEN3 = QCAFRM_HW_LEN2 - 1,
+
+	/*  Waiting first 0xAA of header */
+	QCAFRM_WAIT_AA1 = QCAFRM_HW_LEN3 - 1,
+
+	/*  Waiting second 0xAA of header */
+	QCAFRM_WAIT_AA2 = QCAFRM_WAIT_AA1 - 1,
+
+	/*  Waiting third 0xAA of header */
+	QCAFRM_WAIT_AA3 = QCAFRM_WAIT_AA2 - 1,
+
+	/*  Waiting fourth 0xAA of header */
+	QCAFRM_WAIT_AA4 = QCAFRM_WAIT_AA3 - 1,
+
+	/*  Waiting Byte 0-1 of length (litte endian) */
+	QCAFRM_WAIT_LEN_BYTE0 = QCAFRM_WAIT_AA4 - 1,
+	QCAFRM_WAIT_LEN_BYTE1 = QCAFRM_WAIT_AA4 - 2,
+
+	/* Reserved bytes */
+	QCAFRM_WAIT_RSVD_BYTE1 = QCAFRM_WAIT_AA4 - 3,
+	QCAFRM_WAIT_RSVD_BYTE2 = QCAFRM_WAIT_AA4 - 4,
+
+	/*  The frame length is used as the state until
+	 *  the end of the Ethernet frame
+	 *  Waiting for first 0x55 of footer
+	 */
+	QCAFRM_WAIT_551 = 1,
+
+	/*  Waiting for second 0x55 of footer */
+	QCAFRM_WAIT_552 = QCAFRM_WAIT_551 - 1
+};
+
+/*   Structure to maintain the frame decoding during reception. */
+
+struct qcafrm_handle {
+	/*  Current decoding state */
+	enum qcafrm_state state;
+
+	/* Offset in buffer (borrowed for length too) */
+	s16 offset;
+
+	/* Frame length as kept by this module */
+	u16 len;
+};
+
+u16 qcafrm_create_header(u8 *buf, u16 len);
+
+u16 qcafrm_create_footer(u8 *buf);
+
+static inline void qcafrm_fsm_init(struct qcafrm_handle *handle)
+{
+	handle->state = QCAFRM_HW_LEN0;
+}
+
+/*   Gather received bytes and try to extract a full Ethernet frame
+ *   by following a simple state machine.
+ *
+ * Return:   QCAFRM_GATHER       No Ethernet frame fully received yet.
+ *           QCAFRM_NOHEAD       Header expected but not found.
+ *           QCAFRM_INVLEN       QCA7K frame length is invalid
+ *           QCAFRM_NOTAIL       Footer expected but not found.
+ *           > 0                 Number of byte in the fully received
+ *                               Ethernet frame
+ */
+
+s32 qcafrm_fsm_decode(struct qcafrm_handle *handle, u8 *buf, u16 buf_len, u8 recv_byte);
+
+#endif /* _QCA_FRAMING_H */
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
new file mode 100644
index 0000000..30d8e23
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -0,0 +1,1001 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   This module implements the Qualcomm Atheros SPI protocol for
+ *   kernel-based SPI device; it is essentially an Ethernet-to-SPI
+ *   serial converter;
+ */
+
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/jiffies.h>
+#include <linux/kernel.h>
+#include <linux/kthread.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_net.h>
+#include <linux/sched.h>
+#include <linux/skbuff.h>
+#include <linux/spi/spi.h>
+#include <linux/types.h>
+#include <linux/version.h>
+
+#include "qca_7k.h"
+#include "qca_debug.h"
+#include "qca_framing.h"
+#include "qca_spi.h"
+
+#define MAX_DMA_BURST_LEN 5000
+
+/*   Modules parameters     */
+#define QCASPI_CLK_SPEED_MIN 1000000
+#define QCASPI_CLK_SPEED_MAX 16000000
+#define QCASPI_CLK_SPEED     8000000
+static int qcaspi_clkspeed;
+module_param(qcaspi_clkspeed, int, 0);
+MODULE_PARM_DESC(qcaspi_clkspeed, "SPI bus clock speed (Hz). Use 1000000-16000000.");
+
+#define QCASPI_BURST_LEN_MIN 1
+#define QCASPI_BURST_LEN_MAX MAX_DMA_BURST_LEN
+static int qcaspi_burst_len = MAX_DMA_BURST_LEN;
+module_param(qcaspi_burst_len, int, 0);
+MODULE_PARM_DESC(qcaspi_burst_len, "Number of data bytes per burst. Use 1-5000.");
+
+#define QCASPI_PLUGGABLE_MIN 0
+#define QCASPI_PLUGGABLE_MAX 1
+static int qcaspi_pluggable = QCASPI_PLUGGABLE_MIN;
+module_param(qcaspi_pluggable, int, 0);
+MODULE_PARM_DESC(qcaspi_pluggable, "Pluggable SPI connection (yes/no).");
+
+#define QCASPI_MTU QCAFRM_ETHMAXMTU
+#define QCASPI_TX_TIMEOUT (1 * HZ)
+#define QCASPI_QCA7K_REBOOT_TIME_MS 1000
+
+void
+start_spi_intr_handling(struct qcaspi *qca, u16 *intr_cause)
+{
+	*intr_cause = 0;
+
+	qcaspi_write_register(qca, SPI_REG_INTR_ENABLE, 0);
+	qcaspi_read_register(qca, SPI_REG_INTR_CAUSE, intr_cause);
+	netdev_dbg(qca->net_dev, "interrupts: 0x%04x\n", *intr_cause);
+}
+
+void
+end_spi_intr_handling(struct qcaspi *qca, u16 intr_cause)
+{
+	u16 intr_enable = (SPI_INT_CPU_ON |
+			SPI_INT_PKT_AVLBL |
+			SPI_INT_RDBUF_ERR |
+			SPI_INT_WRBUF_ERR);
+
+	qcaspi_write_register(qca, SPI_REG_INTR_CAUSE, intr_cause);
+	qcaspi_write_register(qca, SPI_REG_INTR_ENABLE, intr_enable);
+	netdev_dbg(qca->net_dev, "acking int: 0x%04x\n", intr_cause);
+}
+
+u32
+qcaspi_write_burst(struct qcaspi *qca, u8 *src, u32 len)
+{
+	u16 cmd;
+	struct spi_message *msg = &qca->spi_msg2;
+	struct spi_transfer *transfer = &qca->spi_xfer2[0];
+	int ret;
+
+	cmd = cpu_to_be16(QCA7K_SPI_WRITE | QCA7K_SPI_EXTERNAL);
+	transfer->tx_buf = &cmd;
+	transfer->rx_buf = NULL;
+	transfer->len = QCASPI_CMD_LEN;
+	transfer = &qca->spi_xfer2[1];
+	transfer->tx_buf = src;
+	transfer->rx_buf = NULL;
+	transfer->len = len;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (ret || (msg->actual_length != QCASPI_CMD_LEN + len)) {
+		qcaspi_spi_error(qca);
+		return 0;
+	}
+
+	return len;
+}
+
+u32
+qcaspi_write_legacy(struct qcaspi *qca, u8 *src, u32 len)
+{
+	struct spi_message *msg = &qca->spi_msg1;
+	struct spi_transfer *transfer = &qca->spi_xfer1;
+	int ret;
+
+	transfer->tx_buf = src;
+	transfer->rx_buf = NULL;
+	transfer->len = len;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (ret || (msg->actual_length != len)) {
+		qcaspi_spi_error(qca);
+		return 0;
+	}
+
+	return len;
+}
+
+u32
+qcaspi_read_burst(struct qcaspi *qca, u8 *dst, u32 len)
+{
+	struct spi_message *msg = &qca->spi_msg2;
+	u16 cmd;
+	struct spi_transfer *transfer = &qca->spi_xfer2[0];
+	int ret;
+
+	cmd = cpu_to_be16(QCA7K_SPI_READ | QCA7K_SPI_EXTERNAL);
+	transfer->tx_buf = &cmd;
+	transfer->rx_buf = NULL;
+	transfer->len = QCASPI_CMD_LEN;
+	transfer = &qca->spi_xfer2[1];
+	transfer->tx_buf = NULL;
+	transfer->rx_buf = dst;
+	transfer->len = len;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (ret || (msg->actual_length != QCASPI_CMD_LEN + len)) {
+		qcaspi_spi_error(qca);
+		return 0;
+	}
+
+	return len;
+}
+
+u32
+qcaspi_read_legacy(struct qcaspi *qca, u8 *dst, u32 len)
+{
+	struct spi_message *msg = &qca->spi_msg1;
+	struct spi_transfer *transfer = &qca->spi_xfer1;
+	int ret;
+
+	transfer->tx_buf = NULL;
+	transfer->rx_buf = dst;
+	transfer->len = len;
+
+	ret = spi_sync(qca->spi_dev, msg);
+
+	if (ret || (msg->actual_length != len)) {
+		qcaspi_spi_error(qca);
+		return 0;
+	}
+
+	return len;
+}
+
+int
+qcaspi_tx_frame(struct qcaspi *qca, struct sk_buff *skb)
+{
+	u32 count;
+	u32 bytes_written;
+	u32 offset;
+	u32 len;
+
+	len = skb->len;
+
+	qcaspi_write_register(qca, SPI_REG_BFR_SIZE, len);
+	if (qca->legacy_mode)
+		qcaspi_tx_cmd(qca, QCA7K_SPI_WRITE | QCA7K_SPI_EXTERNAL);
+
+	offset = 0;
+	while (len) {
+		count = len;
+		if (count > qca->burst_len)
+			count = qca->burst_len;
+
+		if (qca->legacy_mode) {
+			bytes_written = qcaspi_write_legacy(qca,
+					skb->data + offset, count);
+		} else {
+			bytes_written = qcaspi_write_burst(qca,
+					skb->data + offset, count);
+		}
+
+		if (bytes_written != count)
+			return -1;
+
+		offset += count;
+		len -= count;
+	}
+
+	return 0;
+}
+
+int
+qcaspi_transmit(struct qcaspi *qca)
+{
+	struct net_device_stats *n_stats = &qca->net_dev->stats;
+	u16 available = 0;
+	u32 pkt_len;
+	u16 new_head;
+	u16 packets = 0;
+
+	if (qca->txr.skb[qca->txr.head] == NULL)
+		return 0;
+
+	qcaspi_read_register(qca, SPI_REG_WRBUF_SPC_AVA, &available);
+
+	while (qca->txr.skb[qca->txr.head]) {
+		pkt_len = qca->txr.skb[qca->txr.head]->len + QCASPI_HW_PKT_LEN;
+
+		if (available < pkt_len) {
+			if (packets == 0)
+				qca->stats.write_buf_miss++;
+			break;
+		}
+
+		if (qcaspi_tx_frame(qca, qca->txr.skb[qca->txr.head]) == -1) {
+			qca->stats.write_err++;
+			return -1;
+		}
+
+		packets++;
+		n_stats->tx_packets++;
+		n_stats->tx_bytes += qca->txr.skb[qca->txr.head]->len;
+		available -= pkt_len;
+
+		/* remove the skb from the queue */
+		/* XXX After inconsistent lock states netif_tx_lock()
+		 * has been replaced by netif_tx_lock_bh() and so on.
+		 */
+		netif_tx_lock_bh(qca->net_dev);
+		dev_kfree_skb(qca->txr.skb[qca->txr.head]);
+		qca->txr.skb[qca->txr.head] = NULL;
+		qca->txr.size -= pkt_len;
+		new_head = qca->txr.head + 1;
+		if (new_head >= qca->txr.count)
+			new_head = 0;
+		qca->txr.head = new_head;
+		if (netif_queue_stopped(qca->net_dev))
+			netif_wake_queue(qca->net_dev);
+		netif_tx_unlock_bh(qca->net_dev);
+	}
+
+	return 0;
+}
+
+int
+qcaspi_receive(struct qcaspi *qca)
+{
+	struct net_device_stats *n_stats = &qca->net_dev->stats;
+	u16 available = 0;
+	u32 bytes_read;
+	u32 count;
+	u8 *cp;
+
+	/* Allocate rx SKB if we don't have one available. */
+	if (!qca->rx_skb) {
+		qca->rx_skb = netdev_alloc_skb(qca->net_dev,
+				qca->net_dev->mtu + VLAN_ETH_HLEN);
+		if (!qca->rx_skb) {
+			netdev_dbg(qca->net_dev, "out of RX resources\n");
+			qca->stats.out_of_mem++;
+			return -1;
+		}
+	}
+
+	/* Read the packet size. */
+	qcaspi_read_register(qca, SPI_REG_RDBUF_BYTE_AVA, &available);
+	netdev_dbg(qca->net_dev, "qcaspi_receive: SPI_REG_RDBUF_BYTE_AVA: Value: %08x\n",
+			available);
+
+	if (available == 0) {
+		netdev_dbg(qca->net_dev, "qcaspi_receive called without any data being available!\n");
+		return -1;
+	}
+
+	qcaspi_write_register(qca, SPI_REG_BFR_SIZE, available);
+
+	if (qca->legacy_mode)
+		qcaspi_tx_cmd(qca, QCA7K_SPI_READ | QCA7K_SPI_EXTERNAL);
+
+	while (available) {
+		count = available;
+		if (count > qca->burst_len)
+			count = qca->burst_len;
+
+		if (qca->legacy_mode) {
+			bytes_read = qcaspi_read_legacy(qca, qca->rx_buffer,
+					count);
+		} else {
+			bytes_read = qcaspi_read_burst(qca, qca->rx_buffer,
+					count);
+		}
+
+		cp = qca->rx_buffer;
+
+		netdev_dbg(qca->net_dev, "available: %d, byte read: %d\n",
+				available, bytes_read);
+
+		if (bytes_read)
+			available -= bytes_read;
+		else
+			qca->stats.read_err++;
+
+		while ((bytes_read--) && (qca->rx_skb)) {
+			s32 retcode;
+
+			retcode = qcafrm_fsm_decode(&qca->frm_handle,
+					qca->rx_skb->data,
+					skb_tailroom(qca->rx_skb),
+					*cp);
+			cp++;
+			switch (retcode) {
+			case QCAFRM_GATHER:
+			case QCAFRM_NOHEAD:
+				break;
+			case QCAFRM_NOTAIL:
+				netdev_dbg(qca->net_dev, "no RX tail\n");
+				n_stats->rx_errors++;
+				n_stats->rx_dropped++;
+				break;
+			case QCAFRM_INVLEN:
+				netdev_dbg(qca->net_dev, "invalid RX length\n");
+				n_stats->rx_errors++;
+				n_stats->rx_dropped++;
+				break;
+			default:
+				qca->rx_skb->dev = qca->net_dev;
+				n_stats->rx_packets++;
+				n_stats->rx_bytes += retcode;
+				skb_put(qca->rx_skb, retcode);
+				qca->rx_skb->protocol = eth_type_trans(
+					qca->rx_skb, qca->rx_skb->dev);
+				qca->rx_skb->ip_summed = CHECKSUM_UNNECESSARY;
+				netif_rx_ni(qca->rx_skb);
+				qca->rx_skb = netdev_alloc_skb(qca->net_dev,
+					qca->net_dev->mtu + VLAN_ETH_HLEN);
+				if (!qca->rx_skb) {
+					netdev_dbg(qca->net_dev, "out of RX resources\n");
+					n_stats->rx_errors++;
+					qca->stats.out_of_mem++;
+					break;
+				}
+			}
+		}
+	}
+
+	return 0;
+}
+
+int
+qcaspi_tx_ring_has_space(struct tx_ring *txr)
+{
+	if (txr->skb[txr->tail])
+		return 0;
+
+	return (txr->size + QCAFRM_ETHMAXLEN < QCASPI_HW_BUF_LEN) ? 1 : 0;
+}
+
+/*   Flush the tx ring. This function is only safe to
+ *   call from the qcaspi_spi_thread.
+ */
+
+void
+qcaspi_flush_tx_ring(struct qcaspi *qca)
+{
+	int i;
+
+	/* XXX After inconsistent lock states netif_tx_lock()
+	 * has been replaced by netif_tx_lock_bh() and so on.
+	 */
+	netif_tx_lock_bh(qca->net_dev);
+	for (i = 0; i < TX_RING_MAX_LEN; i++) {
+		if (qca->txr.skb[i]) {
+			dev_kfree_skb(qca->txr.skb[i]);
+			qca->txr.skb[i] = NULL;
+			qca->net_dev->stats.tx_dropped++;
+		}
+	}
+	qca->txr.tail = 0;
+	qca->txr.head = 0;
+	qca->txr.size = 0;
+	netif_tx_unlock_bh(qca->net_dev);
+}
+
+void
+qcaspi_qca7k_sync(struct qcaspi *qca, int event)
+{
+	u16 signature = 0;
+	u16 spi_config;
+	u16 wrbuf_space = 0;
+	static u16 reset_count;
+
+	if (event == QCASPI_EVENT_CPUON) {
+		/* Read signature twice, if not valid
+		 * go back to unknown state.
+		 */
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+		if (signature != QCASPI_GOOD_SIGNATURE) {
+			qca->sync = QCASPI_SYNC_UNKNOWN;
+			netdev_dbg(qca->net_dev, "sync: got CPU on, but signature was invalid, restart\n");
+		} else {
+			/* ensure that the WRBUF is empty */
+			qcaspi_read_register(qca, SPI_REG_WRBUF_SPC_AVA,
+				&wrbuf_space);
+			if (wrbuf_space != QCASPI_HW_BUF_LEN) {
+				netdev_dbg(qca->net_dev, "sync: got CPU on, but wrbuf not empty. reset!\n");
+				qca->sync = QCASPI_SYNC_UNKNOWN;
+			} else {
+				netdev_dbg(qca->net_dev, "sync: got CPU on, now in sync\n");
+				qca->sync = QCASPI_SYNC_READY;
+				return;
+			}
+		}
+	}
+
+	switch (qca->sync) {
+	case QCASPI_SYNC_READY:
+		/* Read signature, if not valid go to unknown state. */
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+		if (signature != QCASPI_GOOD_SIGNATURE) {
+			qca->sync = QCASPI_SYNC_UNKNOWN;
+			netdev_dbg(qca->net_dev, "sync: bad signature, restart\n");
+			/* don't reset right away */
+			return;
+		}
+		break;
+	case QCASPI_SYNC_UNKNOWN:
+		/* Read signature, if not valid stay in unknown state */
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+		if (signature != QCASPI_GOOD_SIGNATURE) {
+			netdev_dbg(qca->net_dev, "sync: could not read signature to reset device, retry.\n");
+			return;
+		}
+
+		/* TODO: use GPIO to reset QCA7000 in legacy mode*/
+		netdev_dbg(qca->net_dev, "sync: resetting device.\n");
+		qcaspi_read_register(qca, SPI_REG_SPI_CONFIG, &spi_config);
+		spi_config |= QCASPI_SLAVE_RESET_BIT;
+		qcaspi_write_register(qca, SPI_REG_SPI_CONFIG, spi_config);
+
+		qca->sync = QCASPI_SYNC_RESET;
+		qca->stats.trig_reset++;
+		reset_count = 0;
+		break;
+	case QCASPI_SYNC_RESET:
+		reset_count++;
+		netdev_dbg(qca->net_dev, "sync: waiting for CPU on, count %u.\n",
+				reset_count);
+		if (reset_count >= QCASPI_RESET_TIMEOUT) {
+			/* reset did not seem to take place, try again */
+			qca->sync = QCASPI_SYNC_UNKNOWN;
+			qca->stats.reset_timeout++;
+			netdev_dbg(qca->net_dev, "sync: reset timeout, restarting process.\n");
+		}
+		break;
+	}
+}
+
+static int
+qcaspi_spi_thread(void *data)
+{
+	struct qcaspi *qca = (struct qcaspi *) data;
+	u16 intr_cause = 0;
+
+	netdev_info(qca->net_dev, "SPI thread created\n");
+	while (!kthread_should_stop()) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((qca->intr_req == qca->intr_svc) &&
+		    (qca->txr.skb[qca->txr.head] == NULL) &&
+		    (qca->sync == QCASPI_SYNC_READY))
+			schedule();
+
+		set_current_state(TASK_RUNNING);
+
+		netdev_dbg(qca->net_dev, "have work to do. int: %d, tx_skb: %p\n",
+				qca->intr_req - qca->intr_svc,
+				qca->txr.skb[qca->txr.head]);
+
+		qcaspi_qca7k_sync(qca, QCASPI_EVENT_UPDATE);
+
+		if (qca->sync != QCASPI_SYNC_READY) {
+			netdev_dbg(qca->net_dev, "sync: not ready %u, turn off carrier and flush\n",
+					(unsigned int) qca->sync);
+			netif_stop_queue(qca->net_dev);
+			netif_carrier_off(qca->net_dev);
+			qcaspi_flush_tx_ring(qca);
+			msleep(QCASPI_QCA7K_REBOOT_TIME_MS);
+		}
+
+		if (qca->intr_svc != qca->intr_req) {
+			qca->intr_svc = qca->intr_req;
+			start_spi_intr_handling(qca, &intr_cause);
+
+			if (intr_cause & SPI_INT_CPU_ON) {
+				qcaspi_qca7k_sync(qca, QCASPI_EVENT_CPUON);
+
+				/* not synced. */
+				if (qca->sync != QCASPI_SYNC_READY)
+					continue;
+
+				qca->stats.device_reset++;
+				netif_wake_queue(qca->net_dev);
+				netif_carrier_on(qca->net_dev);
+			}
+
+			if (intr_cause & SPI_INT_RDBUF_ERR) {
+				/* restart sync */
+				netdev_dbg(qca->net_dev, "===> rdbuf error!\n");
+				qca->stats.read_buf_err++;
+				qca->sync = QCASPI_SYNC_UNKNOWN;
+				continue;
+			}
+
+			if (intr_cause & SPI_INT_WRBUF_ERR) {
+				/* restart sync */
+				netdev_dbg(qca->net_dev, "===> wrbuf error!\n");
+				qca->stats.write_buf_err++;
+				qca->sync = QCASPI_SYNC_UNKNOWN;
+				continue;
+			}
+
+			/* can only handle other interrupts
+			 * if sync has occured
+			 */
+			if (qca->sync == QCASPI_SYNC_READY) {
+				if (intr_cause & SPI_INT_PKT_AVLBL)
+					qcaspi_receive(qca);
+			}
+
+			end_spi_intr_handling(qca, intr_cause);
+		}
+
+		if (qca->sync == QCASPI_SYNC_READY)
+			qcaspi_transmit(qca);
+	}
+	set_current_state(TASK_RUNNING);
+	netdev_info(qca->net_dev, "SPI thread exit\n");
+
+	return 0;
+}
+
+static irqreturn_t
+qcaspi_intr_handler(int irq, void *data)
+{
+	struct qcaspi *qca = (struct qcaspi *) data;
+	qca->intr_req++;
+	if (qca->spi_thread &&
+		qca->spi_thread->state != TASK_RUNNING)
+		wake_up_process(qca->spi_thread);
+
+	return IRQ_HANDLED;
+}
+
+int
+qcaspi_netdev_open(struct net_device *dev)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+	int ret = 0;
+
+	if (!qca)
+		return -EINVAL;
+
+	qca->intr_req = 1;
+	qca->intr_svc = 0;
+	qca->sync = QCASPI_SYNC_UNKNOWN;
+	qcafrm_fsm_init(&qca->frm_handle);
+
+	qca->spi_thread = kthread_run((void *)qcaspi_spi_thread,
+			qca, "%s", dev->name);
+
+	if (IS_ERR(qca->spi_thread)) {
+		netdev_err(dev, "%s: unable to start kernel thread.\n",
+				QCASPI_DRV_NAME);
+		return PTR_ERR(qca->spi_thread);
+	}
+
+	ret = request_irq(qca->spi_dev->irq, qcaspi_intr_handler, 0,
+			dev->name, qca);
+	if (ret) {
+		netdev_err(dev, "%s: unable to get IRQ %d (irqval=%d).\n",
+				QCASPI_DRV_NAME, qca->spi_dev->irq, ret);
+		kthread_stop(qca->spi_thread);
+		return ret;
+	}
+
+	netif_start_queue(qca->net_dev);
+
+	return 0;
+}
+
+int
+qcaspi_netdev_close(struct net_device *dev)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+
+	netif_stop_queue(dev);
+
+	qcaspi_write_register(qca, SPI_REG_INTR_ENABLE, 0);
+	free_irq(qca->spi_dev->irq, qca);
+
+	kthread_stop(qca->spi_thread);
+	qca->spi_thread = NULL;
+	qcaspi_flush_tx_ring(qca);
+
+	return 0;
+}
+
+netdev_tx_t
+qcaspi_netdev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	u32 frame_len;
+	u8 *ptmp;
+	struct qcaspi *qca = netdev_priv(dev);
+	u16 new_tail;
+	struct sk_buff *tskb;
+	u8 pad_len = 0;
+
+	if (skb->len < QCAFRM_ETHMINLEN)
+		pad_len = QCAFRM_ETHMINLEN - skb->len;
+
+	if (qca->txr.skb[qca->txr.tail]) {
+		netdev_warn(qca->net_dev, "queue was unexpectedly full!\n");
+		netif_stop_queue(qca->net_dev);
+		qca->stats.ring_full++;
+		return NETDEV_TX_BUSY;
+	}
+
+	if ((skb_headroom(skb) < QCAFRM_HEADER_LEN) ||
+	    (skb_tailroom(skb) < QCAFRM_FOOTER_LEN + pad_len)) {
+		tskb = skb_copy_expand(skb, QCAFRM_HEADER_LEN,
+				QCAFRM_FOOTER_LEN + pad_len, GFP_ATOMIC);
+		if (!tskb) {
+			netdev_dbg(qca->net_dev, "could not allocate tx_buff\n");
+			qca->stats.out_of_mem++;
+			return NETDEV_TX_BUSY;
+		}
+		dev_kfree_skb(skb);
+		skb = tskb;
+	}
+
+	frame_len = skb->len + pad_len;
+
+	ptmp = skb_push(skb, QCAFRM_HEADER_LEN);
+	qcafrm_create_header(ptmp, frame_len);
+
+	if (pad_len) {
+		ptmp = skb_put(skb, pad_len);
+		memset(ptmp, 0, pad_len);
+	}
+
+	ptmp = skb_put(skb, QCAFRM_FOOTER_LEN);
+	qcafrm_create_footer(ptmp);
+
+	netdev_dbg(qca->net_dev, "Tx-ing packet: Size: 0x%08x\n",
+			skb->len);
+
+	qca->txr.size += skb->len + QCASPI_HW_PKT_LEN;
+
+	new_tail = qca->txr.tail + 1;
+	if (new_tail >= qca->txr.count)
+		new_tail = 0;
+
+	qca->txr.skb[qca->txr.tail] = skb;
+	qca->txr.tail = new_tail;
+
+	if (!qcaspi_tx_ring_has_space(&qca->txr)) {
+		netif_stop_queue(qca->net_dev);
+		qca->stats.ring_full++;
+	}
+
+	dev->trans_start = jiffies;
+
+	if (qca->spi_thread &&
+		qca->spi_thread->state != TASK_RUNNING)
+		wake_up_process(qca->spi_thread);
+
+	return NETDEV_TX_OK;
+}
+
+void
+qcaspi_netdev_tx_timeout(struct net_device *dev)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+	netdev_info(qca->net_dev, "Transmit timeout at %ld, latency %ld\n",
+			jiffies, jiffies - dev->trans_start);
+	qca->net_dev->stats.tx_errors++;
+	/* wake the queue if there is room */
+	if (qcaspi_tx_ring_has_space(&qca->txr))
+		netif_wake_queue(dev);
+}
+
+static int
+qcaspi_netdev_init(struct net_device *dev)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+
+	dev->mtu = QCASPI_MTU;
+	dev->type = ARPHRD_ETHER;
+	qca->clkspeed = qcaspi_clkspeed;
+	qca->burst_len = qcaspi_burst_len;
+	qca->spi_thread = NULL;
+	qca->buffer_size = (dev->mtu + VLAN_ETH_HLEN + QCAFRM_HEADER_LEN +
+		QCAFRM_FOOTER_LEN + 4) * 4;
+
+	memset(&qca->stats, 0, sizeof(struct qcaspi_stats));
+
+	qca->rx_buffer = kmalloc(qca->buffer_size, GFP_KERNEL);
+	if (!qca->rx_buffer)
+		return -ENOBUFS;
+
+	qca->rx_skb = netdev_alloc_skb(dev, qca->net_dev->mtu + VLAN_ETH_HLEN);
+	if (!qca->rx_skb) {
+		kfree(qca->rx_buffer);
+		netdev_info(qca->net_dev, "Failed to allocate RX sk_buff.\n");
+		return -ENOBUFS;
+	}
+
+	return 0;
+}
+
+static void
+qcaspi_netdev_uninit(struct net_device *dev)
+{
+	struct qcaspi *qca = netdev_priv(dev);
+	kfree(qca->rx_buffer);
+	qca->buffer_size = 0;
+	if (qca->rx_skb)
+		dev_kfree_skb(qca->rx_skb);
+}
+
+int
+qcaspi_netdev_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < QCAFRM_ETHMINMTU) || (new_mtu > QCAFRM_ETHMAXMTU))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
+static int
+qcaspi_netdev_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sa = addr;
+
+	if (netif_running(dev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(sa->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+	return 0;
+}
+
+static const struct net_device_ops qcaspi_netdev_ops = {
+	.ndo_init = qcaspi_netdev_init,
+	.ndo_uninit = qcaspi_netdev_uninit,
+	.ndo_open = qcaspi_netdev_open,
+	.ndo_stop = qcaspi_netdev_close,
+	.ndo_start_xmit = qcaspi_netdev_xmit,
+	.ndo_change_mtu = qcaspi_netdev_change_mtu,
+	.ndo_set_mac_address = qcaspi_netdev_set_mac_address,
+	.ndo_tx_timeout = qcaspi_netdev_tx_timeout,
+	.ndo_validate_addr = eth_validate_addr,
+};
+
+void
+qcaspi_netdev_setup(struct net_device *dev)
+{
+	struct qcaspi *qca = NULL;
+
+	ether_setup(dev);
+
+	dev->netdev_ops = &qcaspi_netdev_ops;
+	qcaspi_set_ethtool_ops(dev);
+	dev->watchdog_timeo = QCASPI_TX_TIMEOUT;
+	dev->flags = IFF_MULTICAST;
+	dev->tx_queue_len = 100;
+
+	qca = netdev_priv(dev);
+	memset(qca, 0, sizeof(struct qcaspi));
+
+	memset(&qca->spi_xfer1, 0, sizeof(struct spi_transfer));
+	memset(&qca->spi_xfer2, 0, sizeof(struct spi_transfer) * 2);
+
+	spi_message_init(&qca->spi_msg1);
+	spi_message_add_tail(&qca->spi_xfer1, &qca->spi_msg1);
+
+	spi_message_init(&qca->spi_msg2);
+	spi_message_add_tail(&qca->spi_xfer2[0], &qca->spi_msg2);
+	spi_message_add_tail(&qca->spi_xfer2[1], &qca->spi_msg2);
+
+	memset(&qca->txr, 0, sizeof(qca->txr));
+	qca->txr.count = TX_RING_MAX_LEN;
+}
+
+static const struct of_device_id qca_spi_of_match[] = {
+	{ .compatible = "qca,qca7000" },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, qca_spi_of_match);
+
+static int
+qca_spi_probe(struct spi_device *spi_device)
+{
+	struct qcaspi *qca = NULL;
+	struct net_device *qcaspi_devs = NULL;
+	u8 legacy_mode = 0;
+	u16 signature;
+	const char *mac;
+
+	if (!spi_device->dev.of_node) {
+		dev_err(&spi_device->dev, "Missing device tree\n");
+		return -EINVAL;
+	}
+
+	if (of_find_property(spi_device->dev.of_node,
+		"qca,legacy-mode", NULL)) {
+		legacy_mode = 1;
+	}
+
+	if (qcaspi_clkspeed == 0) {
+		if (of_find_property(spi_device->dev.of_node,
+					"spi-max-frequency", NULL)) {
+			qcaspi_clkspeed = spi_device->max_speed_hz;
+		} else {
+			qcaspi_clkspeed = QCASPI_CLK_SPEED;
+		}
+	}
+
+	if ((qcaspi_clkspeed < QCASPI_CLK_SPEED_MIN) ||
+	    (qcaspi_clkspeed > QCASPI_CLK_SPEED_MAX)) {
+		dev_info(&spi_device->dev, "Invalid clkspeed: %d\n",
+			qcaspi_clkspeed);
+		return -EINVAL;
+	}
+
+	if ((qcaspi_burst_len < QCASPI_BURST_LEN_MIN) ||
+	    (qcaspi_burst_len > QCASPI_BURST_LEN_MAX)) {
+		dev_info(&spi_device->dev, "Invalid burst len: %d\n",
+			qcaspi_burst_len);
+		return -EINVAL;
+	}
+
+	if ((qcaspi_pluggable < QCASPI_PLUGGABLE_MIN) ||
+	    (qcaspi_pluggable > QCASPI_PLUGGABLE_MAX)) {
+		dev_info(&spi_device->dev, "Invalid pluggable: %d\n",
+			qcaspi_pluggable);
+		return -EINVAL;
+	}
+
+	dev_info(&spi_device->dev, "ver=%s, clkspeed=%d, burst_len=%d, pluggable=%d\n",
+		QCASPI_DRV_VERSION,
+		qcaspi_clkspeed,
+		qcaspi_burst_len,
+		qcaspi_pluggable);
+
+	spi_device->mode = SPI_MODE_3;
+	spi_device->max_speed_hz = qcaspi_clkspeed;
+	if (spi_setup(spi_device) < 0) {
+		dev_err(&spi_device->dev, "Unable to setup SPI device\n");
+		return -EFAULT;
+	}
+
+	qcaspi_devs = alloc_etherdev(sizeof(struct qcaspi));
+	if (!qcaspi_devs)
+		return -ENOMEM;
+
+	qcaspi_netdev_setup(qcaspi_devs);
+
+	qca = netdev_priv(qcaspi_devs);
+	if (!qca) {
+		free_netdev(qcaspi_devs);
+		dev_err(&spi_device->dev, "Fail to retrieve private structure\n");
+		return -ENOMEM;
+	}
+	qca->net_dev = qcaspi_devs;
+	qca->spi_dev = spi_device;
+	qca->legacy_mode = legacy_mode;
+
+	mac = of_get_mac_address(spi_device->dev.of_node);
+
+	if (mac)
+		memcpy(qca->net_dev->dev_addr, mac, ETH_ALEN);
+
+	if (!is_valid_ether_addr(qca->net_dev->dev_addr)) {
+		eth_hw_addr_random(qca->net_dev);
+		dev_info(&spi_device->dev, "Using random MAC address: %pM\n",
+			qca->net_dev->dev_addr);
+	}
+
+	netif_carrier_off(qca->net_dev);
+
+	if (!qcaspi_pluggable) {
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+		qcaspi_read_register(qca, SPI_REG_SIGNATURE, &signature);
+
+		if (signature != QCASPI_GOOD_SIGNATURE) {
+			dev_err(&spi_device->dev, "Invalid signature (0x%04X)\n",
+				signature);
+			free_netdev(qcaspi_devs);
+			return -EFAULT;
+		}
+	}
+
+	if (register_netdev(qcaspi_devs)) {
+		dev_info(&spi_device->dev, "Unable to register net device %s\n",
+			qcaspi_devs->name);
+		free_netdev(qcaspi_devs);
+		return -EFAULT;
+	}
+
+	spi_set_drvdata(spi_device, qcaspi_devs);
+
+	qcaspi_init_device_debugfs(qca);
+
+	return 0;
+}
+
+static int
+qca_spi_remove(struct spi_device *spi_device)
+{
+	struct net_device *qcaspi_devs = spi_get_drvdata(spi_device);
+	struct qcaspi *qca = netdev_priv(qcaspi_devs);
+
+	qcaspi_remove_device_debugfs(qca);
+
+	unregister_netdev(qcaspi_devs);
+	free_netdev(qcaspi_devs);
+
+	return 0;
+}
+
+static const struct spi_device_id qca_spi_id[] = {
+	{ "qca7000", 0 },
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(spi, qca_spi_id);
+
+static struct spi_driver qca_spi_driver = {
+	.driver	= {
+		.name	= QCASPI_DRV_NAME,
+		.owner	= THIS_MODULE,
+		.of_match_table = qca_spi_of_match,
+	},
+	.id_table = qca_spi_id,
+	.probe    = qca_spi_probe,
+	.remove   = qca_spi_remove,
+};
+module_spi_driver(qca_spi_driver);
+
+MODULE_DESCRIPTION("Qualcomm Atheros SPI Driver");
+MODULE_AUTHOR("Qualcomm Atheros Communications");
+MODULE_AUTHOR("Stefan Wahren <stefan.wahren@i2se.com>");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(QCASPI_DRV_VERSION);
+
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.h b/drivers/net/ethernet/qualcomm/qca_spi.h
new file mode 100644
index 0000000..6e31a0e
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/qca_spi.h
@@ -0,0 +1,114 @@
+/*
+ *   Copyright (c) 2011, 2012, Qualcomm Atheros Communications Inc.
+ *   Copyright (c) 2014, I2SE GmbH
+ *
+ *   Permission to use, copy, modify, and/or distribute this software
+ *   for any purpose with or without fee is hereby granted, provided
+ *   that the above copyright notice and this permission notice appear
+ *   in all copies.
+ *
+ *   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
+ *   WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
+ *   WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL
+ *   THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
+ *   CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
+ *   LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
+ *   NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
+ *   CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*   Qualcomm Atheros SPI register definition.
+ *
+ *   This module is designed to define the Qualcomm Atheros SPI register
+ *   placeholders;
+ */
+
+#ifndef _QCA_SPI_H
+#define _QCA_SPI_H
+
+#include <linux/netdevice.h>
+#include <linux/sched.h>
+#include <linux/skbuff.h>
+#include <linux/spi/spi.h>
+#include <linux/types.h>
+
+#include "qca_framing.h"
+
+#define QCASPI_DRV_VERSION "0.2.7-i"
+#define QCASPI_DRV_NAME    "qcaspi"
+
+#define QCASPI_GOOD_SIGNATURE 0xAA55
+
+#define TX_RING_MAX_LEN 10
+#define TX_RING_MIN_LEN 2
+
+/* sync related constants */
+#define QCASPI_SYNC_UNKNOWN 0
+#define QCASPI_SYNC_RESET   1
+#define QCASPI_SYNC_READY   2
+
+#define QCASPI_RESET_TIMEOUT 10
+
+/* sync events */
+#define QCASPI_EVENT_UPDATE 0
+#define QCASPI_EVENT_CPUON  1
+
+struct tx_ring {
+	struct sk_buff *skb[TX_RING_MAX_LEN];
+	u16 head;
+	u16 tail;
+	u16 size;
+	u16 count;
+};
+
+struct qcaspi_stats {
+	u64 trig_reset;
+	u64 device_reset;
+	u64 reset_timeout;
+	u64 read_err;
+	u64 write_err;
+	u64 read_buf_err;
+	u64 write_buf_err;
+	u64 out_of_mem;
+	u64 write_buf_miss;
+	u64 ring_full;
+	u64 spi_err;
+};
+
+struct qcaspi {
+	struct net_device *net_dev;
+	struct spi_device *spi_dev;
+	struct task_struct *spi_thread;
+
+	struct tx_ring txr;
+	struct qcaspi_stats stats;
+
+	struct spi_message spi_msg1;
+	struct spi_message spi_msg2;
+	struct spi_transfer spi_xfer1;
+	struct spi_transfer spi_xfer2[2];
+
+	u8 *rx_buffer;
+	u32 buffer_size;
+	u8 sync;
+
+	struct qcafrm_handle frm_handle;
+	struct sk_buff *rx_skb;
+
+	unsigned int intr_req;
+	unsigned int intr_svc;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *device_root;
+#endif
+
+	/* user configurable options */
+	u32 clkspeed;
+	u8 legacy_mode;
+	u16 burst_len;
+};
+
+int qcaspi_netdev_open(struct net_device *dev);
+int qcaspi_netdev_close(struct net_device *dev);
+
+#endif /* _QCA_SPI_H */
-- 
1.7.10.4
