From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: [PATCH net-next v4 3/3] Linn Ethernet packet sniffer driver
Date: Tue, 24 Feb 2015 16:48:11 +0000
Message-ID: <616ff2fd014ce94b2d0325810fb6938619b1b543.1424796018.git.stathis.voukelatos@linn.co.uk>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver for the Ethernet Mii packet sniffer H/W module found in
the IMG Pistachio SoC.

Signed-off-by: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
---
 drivers/net/ethernet/linn/Kconfig                  |  11 +
 drivers/net/ethernet/linn/Makefile                 |   1 +
 .../linn/pkt-sniffer/backends/ether/Makefile       |  20 +
 .../linn/pkt-sniffer/backends/ether/channel.c      | 444 +++++++++++++++++++++
 .../linn/pkt-sniffer/backends/ether/channel.h      |  80 ++++
 .../ethernet/linn/pkt-sniffer/backends/ether/hw.h  |  46 +++
 .../linn/pkt-sniffer/backends/ether/platform.c     | 318 +++++++++++++++
 7 files changed, 920 insertions(+)
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.h
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/hw.h
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/platform.c

diff --git a/drivers/net/ethernet/linn/Kconfig b/drivers/net/ethernet/linn/Kconfig
index 6654f4e..bbfd6a4 100644
--- a/drivers/net/ethernet/linn/Kconfig
+++ b/drivers/net/ethernet/linn/Kconfig
@@ -22,4 +22,15 @@ menuconfig PKT_SNIFFER
     The core driver can also be built as a module. If so, the module
     will be called snf_core.
 
+config PKT_SNIFFER_ETHER
+    tristate "Ethernet packet sniffer"
+    depends on PKT_SNIFFER
+    help
+        Say Y here if you want to use the Ethernet packet sniffer
+        module by Linn Products Ltd. It can be found in the upcoming
+        Pistachio SoC by Imagination Technologies.
+
+        The driver can also be built as a module. If so, the module
+        will be called snf_ether.
+
 endif # NET_VENDOR_LINN
diff --git a/drivers/net/ethernet/linn/Makefile b/drivers/net/ethernet/linn/Makefile
index f3338f3..f51eb66 100644
--- a/drivers/net/ethernet/linn/Makefile
+++ b/drivers/net/ethernet/linn/Makefile
@@ -17,3 +17,4 @@
 ###############################################################################
 
 obj-$(CONFIG_PKT_SNIFFER) += pkt-sniffer/core/
+obj-$(CONFIG_PKT_SNIFFER_ETHER) += pkt-sniffer/backends/ether/
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/Makefile b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/Makefile
new file mode 100644
index 0000000..1f97e51
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/Makefile
@@ -0,0 +1,20 @@
+###############################################################################
+# Makefile for the Linn ethernet packet sniffer driver
+#
+# Copyright (C) 2015 Linn Products Ltd
+#
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License version 2
+# as published by the Free Software Foundation.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+# GNU General Public License for more details.
+#
+# Written by:
+# Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+###############################################################################
+
+obj-$(CONFIG_PKT_SNIFFER_ETHER) += snf_ether.o
+snf_ether-objs := platform.o channel.o
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.c b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.c
new file mode 100644
index 0000000..87ec790
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.c
@@ -0,0 +1,444 @@
+/*
+ * Ethernet Mii packet sniffer driver
+ *  - channel functions
+ *
+ * Copyright (C) 2015 Linn Products Ltd
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
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#include <linux/io.h>
+#include <linux/hrtimer.h>
+#include <linux/clocksource.h>
+#include "../../core/snf_core.h"
+#include "hw.h"
+#include "channel.h"
+
+#define to_ether_snf_chan(dev) container_of(dev, struct ether_snf_chan, chan)
+
+#define CMD_DONTCARE	0
+#define CMD_MATCH	1
+#define CMD_COPY	2
+#define CMD_MATCHSTAMP	3
+#define CMD_COPYDONE	4
+
+/* Checks if the supplied command string is compatible with the
+ * capabilities of the H/W.
+ */
+static bool validate_pattern(
+			struct ether_snf_chan *ch,
+			const u8 *buf,
+			int count)
+{
+	int i, complete, max_copy_bytes;
+	int ts = 0;
+	int copy_before = 0;
+	int copy_after = 0;
+
+	if (count > ch->max_cmds)
+		return false;
+
+	/* Iterate through the commands in the string */
+	for (i = 0, complete = 0; (i < count) && !complete; i++) {
+		u8 cmd = buf[2 * i];
+
+		switch (cmd) {
+		case CMD_DONTCARE:
+		case CMD_MATCH:
+			break;
+
+		case CMD_MATCHSTAMP:
+			/* The timestamp needs to be word-aligned in the FIFO
+			 * therefore, the number of 'copy' commands before it
+			 * needs to be a multiple of 4
+			 */
+			if (copy_before & 3)
+				return false;
+			/* Signal that a timestamp will be present */
+			ts = 1;
+			break;
+
+		case CMD_COPY:
+			/* Increment count of bytes that will be returned */
+			if (ts)
+				copy_after++;
+			else
+				copy_before++;
+			break;
+
+		case CMD_COPYDONE:
+			/* Increment count of bytes that will be returned
+			 * This command terminates the string
+			 */
+			if (ts)
+				copy_after++;
+			else
+				copy_before++;
+			/* This command completes the command string */
+			complete = 1;
+			break;
+
+		default:
+			/* Invalid command id */
+			return false;
+		}
+	}
+
+	/* Check if the string was properly terminated
+	 * and contained valid number of commands
+	 */
+	if (complete) {
+		max_copy_bytes = ch->fifo_blk_words * 4;
+		if (ts)
+			max_copy_bytes -= 4;
+		/* Too many copy commands will case the FIFO
+		 * to wrap around
+		 */
+		if ((copy_before + copy_after) > max_copy_bytes)
+			return false;
+		ch->nfb_before = copy_before;
+		ch->nfb_after = copy_after;
+		ch->evt.ts_valid = ts;
+		ch->evt.len = ch->nfb_before + ch->nfb_after;
+		return true;
+	}
+
+	/* Command string not terminated */
+	return false;
+}
+
+/* Channel methods */
+
+/* Enables the channel */
+static int esnf_start(struct snf_chan *dev)
+{
+	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
+
+	if (!ch->started) {
+		ch->evt.ts = 0;
+		/* Enable interrupts */
+		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
+			  ch->regs + SET_INTERRUPT_ENABLE);
+		/* Enable the packet matching logic */
+		iowrite32(ENABLE_BIT, ch->reg_enable);
+
+		ch->started = 1;
+		dev_info(ch->dev, "%s: started\n", ch->name);
+	} else {
+		dev_dbg(ch->dev, "%s: already running\n", ch->name);
+	}
+
+	return 0;
+}
+
+/* Disables the channel */
+static int esnf_stop(struct snf_chan *dev)
+{
+	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
+
+	if (ch->started) {
+		/* Disable interrupts */
+		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
+			  ch->regs + CLEAR_INTERRUPT_ENABLE);
+		/* Stop the sniffer channel */
+		iowrite32(0, ch->reg_enable);
+		/* Clear any pending interrupts */
+		iowrite32(ch->data_irq_bit | ch->full_irq_bit,
+			  ch->regs + INTERRUPT_STATUS);
+
+		ch->started = 0;
+		dev_info(ch->dev, "%s: stopped\n", ch->name);
+	} else {
+		dev_dbg(ch->dev, "%s: already stopped\n", ch->name);
+	}
+
+	return 0;
+}
+
+/* Sets the command string (pattern) for the channel
+ * The bytes in the pattern buffer are in the following order:
+ */
+static int esnf_set_pattern(struct snf_chan *dev, const u8 *pattern, int count)
+{
+	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
+	int i, shift = 0;
+	u32  val = 0, *ptr;
+
+	dev_info(ch->dev, "%s: set cmd pattern with %d entries\n",
+		 ch->name, count);
+
+	if (ch->started) {
+		dev_err(ch->dev,
+			"%s: cannot apply cmd pattern. Channel is active\n",
+			ch->name);
+		return -EBUSY;
+	}
+
+	if (!validate_pattern(ch, pattern, count)) {
+		dev_err(ch->dev,
+			"%s: invalid cmd pattern\n",
+			ch->name);
+		return -EINVAL;
+	}
+
+	for (ptr = ch->cmd_ram, i = 0, shift = 24; i < (2 * count); i++) {
+		val |= ((u32)pattern[i]) << shift;
+		if (!shift) {
+			iowrite32(val, ptr++);
+			val = 0;
+			shift = 24;
+		} else {
+			shift -= 8;
+		}
+	}
+	if (shift)
+		iowrite32(val, ptr);
+
+	return 0;
+}
+
+/* Returns max number of commands supported by the channel */
+static int esnf_max_ptn_entries(struct snf_chan *dev)
+{
+	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
+
+	return ch->max_cmds;
+}
+
+static int esnf_ts_enabled(struct snf_chan *dev)
+{
+	struct ether_snf_chan *ch = to_ether_snf_chan(dev);
+
+	return ch->evt.ts_valid;
+}
+
+/* Gray decoder */
+static u32 gray_decode(u32 gray)
+{
+	gray ^= (gray >> 16);
+	gray ^= (gray >> 8);
+	gray ^= (gray >> 4);
+	gray ^= (gray >> 2);
+	gray ^= (gray >> 1);
+	return gray;
+}
+
+/* Read a block from the data FIFO */
+static void read_fifo_data(struct ether_snf_chan *ch)
+{
+	int i;
+	u32 val, *ptr;
+	int ts = ch->evt.ts_valid;
+	int dw = ch->fifo_blk_words;
+	int bytes_before = ch->nfb_before;
+	int bytes_after = ch->nfb_after;
+
+	ptr = (u32 *)ch->evt.data;
+	for (i = 0; i < dw; i++) {
+		val = ioread32(ch->reg_fifo);
+		if (bytes_before > 0) {
+			/* Bytes before the timestamp */
+			*ptr++ = cpu_to_be32(val);
+			bytes_before -= 4;
+		} else if (ts) {
+			ch->raw_tstamp = gray_decode(val);
+			/* First timestamp since the channel was started.
+			 * Initialise the timecounter
+			 */
+			if (!ch->evt.ts)
+				timecounter_init(
+					&ch->tc,
+					&ch->cc,
+					ktime_to_ns(ktime_get_real()));
+			ch->evt.ts = timecounter_read(&ch->tc);
+			ts = 0;
+		} else if (bytes_after > 0) {
+			/* Bytes after the timestamp */
+			*ptr++ = cpu_to_be32(val);
+			bytes_after -= 4;
+		}
+	}
+}
+
+/* Read method for the timestamp cycle counter
+ * Returns the last received timestamp value
+ */
+static cycle_t esnf_cyclecounter_read(const struct cyclecounter *cc)
+{
+	struct ether_snf_chan *ch = container_of(cc, struct ether_snf_chan, cc);
+
+	return ch->raw_tstamp;
+}
+
+/* Taken from clocks_calc_mult_shift() in kernel/time/clocksource.c
+ * Unfortunately that function is not exported by the kernel
+ */
+static void esnf_clocks_calc_mult_shift(
+				u32 *mult,
+				u32 *shift,
+				u32 from,
+				u32 to,
+				u32 maxsec)
+{
+	u64 tmp;
+	u32 sft, sftacc = 32;
+
+	/* Calculate the shift factor which is limiting the conversion
+	 * range:
+	 */
+	tmp = ((u64)maxsec * from) >> 32;
+	while (tmp) {
+		tmp >>= 1;
+		sftacc--;
+	}
+
+	/* Find the conversion shift/mult pair which has the best
+	 * accuracy and fits the maxsec conversion range:
+	 */
+	for (sft = 32; sft > 0; sft--) {
+		tmp = (u64)to << sft;
+		tmp += from / 2;
+		do_div(tmp, from);
+		if ((tmp >> sftacc) == 0)
+			break;
+	}
+	*mult = tmp;
+	*shift = sft;
+}
+
+/* Follows the logic of __clocksource_updatefreq_scale() in
+ * in kernel/time/clocksource.c
+ */
+static void calc_mult_shift(u32 *mult, u32 *shift, cycle_t mask, u32 freq)
+{
+	u64 sec;
+
+	sec = mask - (mask >> 3);
+	do_div(sec, freq);
+	if (!sec)
+		sec = 1;
+	else if (sec > 600 && mask > UINT_MAX)
+		sec = 600;
+	esnf_clocks_calc_mult_shift(mult, shift, freq, NSEC_PER_SEC, sec);
+}
+
+/* Initialises a sniffer channel */
+int channel_init(
+	struct ether_snf_chan *ch,
+	struct platform_device *pdev,
+	void *regs,
+	int fifo_blk_words,
+	u32 tstamp_hz,
+	u32 tstamp_bits,
+	int tx)
+{
+	struct resource *res;
+	u32 *ptr;
+	int i;
+
+	ch->regs = regs;
+	ch->dev = &pdev->dev;
+	ch->data_irq_bit = tx ? TX_DATA_IRQ_BIT : RX_DATA_IRQ_BIT;
+	ch->full_irq_bit = tx ? TX_FULL_IRQ_BIT : RX_FULL_IRQ_BIT;
+	ch->reg_enable = ch->regs +
+			 (tx ? TX_SNIFFER_ENABLE : RX_SNIFFER_ENABLE);
+	ch->reg_fifo = ch->regs + (tx ? TX_FIFO_DAT : RX_FIFO_DAT);
+
+	/* Retrieve and remap the address space for the command memory */
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM,
+					   tx ? "tx-ram" : "rx-ram");
+	if (!res)
+		return -ENOSYS;
+	ch->cmd_ram = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(ch->cmd_ram))
+		return PTR_ERR(ch->cmd_ram);
+
+	/* It is 2 bytes/command, hence divide by 2 */
+	ch->max_cmds = resource_size(res) / 2;
+
+	/* Initialise the command string RAM */
+	for (i = 0, ptr = ch->cmd_ram; i < resource_size(res); i += 4)
+		iowrite32((CMD_DONTCARE << 24) | (CMD_DONTCARE << 8),
+			  ptr++);
+
+	ch->fifo_blk_words = fifo_blk_words;
+	ch->started = 0;
+
+	/* Initialise the timestamp cycle counter */
+	ch->cc.read = esnf_cyclecounter_read;
+	ch->cc.mask = CLOCKSOURCE_MASK(tstamp_bits);
+	calc_mult_shift(&ch->cc.mult, &ch->cc.shift, ch->cc.mask, tstamp_hz);
+
+	/* Register the channel methods */
+	ch->chan.start = esnf_start;
+	ch->chan.stop = esnf_stop;
+	ch->chan.set_pattern = esnf_set_pattern;
+	ch->chan.max_ptn_entries = esnf_max_ptn_entries;
+	ch->chan.ts_enabled = esnf_ts_enabled;
+
+	strncpy(ch->name, tx ? "TX" : "RX", MAX_CHAN_NAME_SIZE - 1);
+
+	dev_dbg(ch->dev, "%s: channel initialized\n", ch->name);
+
+	return 0;
+}
+
+/* Registers the channel with the sniffer core module */
+int channel_register(struct ether_snf_chan *ch, const char *name)
+{
+	int ret;
+
+	ret = snf_channel_add(&ch->chan, name);
+	if (ret < 0)
+		return ret;
+
+	dev_info(ch->dev, "%s channel added\n", ch->name);
+	return 0;
+}
+
+/* Unregisters the channel */
+int channel_unregister(struct ether_snf_chan *ch)
+{
+	int ret;
+
+	ch->chan.stop(&ch->chan);
+	ret = snf_channel_remove(&ch->chan);
+	if (!ret)
+		dev_info(ch->dev, "%s channel removed\n", ch->name);
+	return ret;
+}
+
+/* Process match event data */
+void channel_data_available(struct ether_snf_chan *ch)
+{
+	int ret;
+
+	dev_dbg(ch->dev, "%s match event\n", ch->name);
+
+	read_fifo_data(ch);
+	ret = snf_channel_notify_match(&ch->chan, &ch->evt);
+	if (ret < 0)
+		dev_err(ch->dev, "%s: event notification failed\n", ch->name);
+}
+
+/* Suspend opertion */
+int channel_suspend(struct ether_snf_chan *ch)
+{
+	return snf_channel_suspend(&ch->chan);
+}
+
+/* Resume operation */
+int channel_resume(struct ether_snf_chan *ch)
+{
+	return snf_channel_resume(&ch->chan);
+}
+
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.h b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.h
new file mode 100644
index 0000000..75b942e
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.h
@@ -0,0 +1,80 @@
+/*
+ * Ethernet Mii packet sniffer driver
+ *  - channel interface
+ *
+ * Copyright (C) 2015 Linn Products Ltd
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
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#ifndef _ETHER_SNIFFER_CHANNEL_H_
+#define _ETHER_SNIFFER_CHANNEL_H_
+
+#include <linux/platform_device.h>
+#include <linux/timecounter.h>
+#include "../../core/snf_core.h"
+
+#define MAX_CHAN_NAME_SIZE 5
+
+struct ether_snf_chan {
+	/* Sniffer core structure */
+	struct snf_chan chan;
+	/* Pointer to device struct */
+	struct device *dev;
+	/* Registers */
+	u8 __iomem *regs;
+	/* Command string memory */
+	u32 __iomem *cmd_ram;
+	/* Bit number for the data IRQ */
+	int data_irq_bit;
+	/* Bit number for the FIFO full IRQ */
+	int full_irq_bit;
+	/* Channel enable register */
+	u8 __iomem *reg_enable;
+	/* Data FIFO register */
+	u8 __iomem *reg_fifo;
+	/* Max number of commands in the string */
+	int max_cmds;
+	/* Max matching bytes that can fit in a FIFO block */
+	int fifo_blk_words;
+	/* Number of bytes in the FIFO before the timestamp */
+	int nfb_before;
+	/* Number of bytes in the FIFO after the timestamp */
+	int nfb_after;
+	/* Channel active flag */
+	int started;
+	/* Last raw timestamp from the FIFO */
+	u32 raw_tstamp;
+	/* Channel name (only used by debug messages) */
+	char name[MAX_CHAN_NAME_SIZE];
+	/* Struct to hold data from a packet match */
+	struct snf_match_evt evt;
+	/* Cycle and time counters for tstamp handling */
+	struct cyclecounter cc;
+	struct timecounter tc;
+};
+
+int channel_init(
+		struct ether_snf_chan *ch,
+		struct platform_device *pdev,
+		void *regs,
+		int fifo_blk_words,
+		u32 tstamp_hz,
+		u32 tstamp_bits,
+		int tx);
+int channel_register(struct ether_snf_chan *ch, const char *name);
+int channel_unregister(struct ether_snf_chan *ch);
+void channel_data_available(struct ether_snf_chan *ch);
+int channel_suspend(struct ether_snf_chan *ch);
+int channel_resume(struct ether_snf_chan *ch);
+
+#endif
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/hw.h b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/hw.h
new file mode 100644
index 0000000..edb1093
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/hw.h
@@ -0,0 +1,46 @@
+/*
+ * Ethernet Mii packet sniffer driver
+ *  - register map
+ *
+ * Copyright (C) 2015 Linn Products Ltd
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
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#ifndef _ETHER_SNIFFER_HW_H_
+#define _ETHER_SNIFFER_HW_H_
+
+#include <linux/bitops.h>
+
+/* Registers */
+#define INTERRUPT_ENABLE        0x00
+#define SET_INTERRUPT_ENABLE    0x04
+#define CLEAR_INTERRUPT_ENABLE  0x08
+#define INTERRUPT_STATUS        0x0c
+#define TX_FIFO_DAT             0x10
+#define RX_FIFO_DAT             0x14
+#define TX_FIFO_OCC             0x18
+#define RX_FIFO_OCC             0x1c
+#define TX_SNIFFER_ENABLE       0x20
+#define RX_SNIFFER_ENABLE       0x24
+
+/* IRQ register bits */
+#define TX_DATA_IRQ_BIT         BIT(0)
+#define RX_DATA_IRQ_BIT         BIT(1)
+#define TX_FULL_IRQ_BIT         BIT(2)
+#define RX_FULL_IRQ_BIT         BIT(3)
+
+/* Enable register bits */
+#define ENABLE_BIT              BIT(0)
+
+#endif
+
diff --git a/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/platform.c b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/platform.c
new file mode 100644
index 0000000..4da039a
--- /dev/null
+++ b/drivers/net/ethernet/linn/pkt-sniffer/backends/ether/platform.c
@@ -0,0 +1,318 @@
+/*
+ * This module is the driver for the Linn Ethernet Mii packet sniffer
+ * H/W module. It allows incoming and outoing Ethernet packets to be
+ * parsed, matched against a user-defined pattern and timestamped.
+ * It sits between an Ethernet MAC and PHY and is completely passive
+ * with respect to Ethernet frames.
+ *
+ * Packet filtering is driven by a user-supplied command string
+ * which consists of a series of interleaved command and data bytes.
+ * ie. the command string has the following format:
+ *  --------------------------------
+ *  | CMD | DATA | CMD | DATA | ....
+ *  --------------------------------
+ * The following commands are supported:
+ * 0 - Don't care
+ * 1 - Match: packet data must match command string byte
+ * 2 - Copy: packet data will be copied to FIFO
+ * 3 - Match/Stamp: if packet data matches string byte, a timestamp
+ *                  is copied into the FIFO
+ * 4 - Copy/Done: packet data will be copied into the FIFO.
+ *                This command terminates the command string.
+ * Example:
+ *   0x00, 0x00, 0x01, 0xDE, 0x03, 0x20, 0x04, 0x00
+ *   The above string will match Ethernet packets where the 2nd and 3rd
+ *   bytes of the destination MAC address are 0xDE and 0x22.
+ *   For each matched packet a timestamp and the 4th byte of the destination
+ *   MAC will be copied to the FIFO
+ *
+ * - An IRQ is triggered for every packet match event
+ * - The modules includes a H/W block based FIFO where matched packet data
+ *   and timestamp values are placed
+ * - The FIFO is accessed through a single register
+ * - An IRQ is also generated if all FIFO blocks are filled.
+ * - Timestamps are Gray encoded
+ *
+ * Copyright (C) 2015 Linn Products Ltd
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
+ * Written by:
+ * Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/of_device.h>
+#include <linux/platform_device.h>
+#include <linux/clk.h>
+#include "../../core/snf_core.h"
+#include "hw.h"
+#include "channel.h"
+
+/* Names for the TX and RX channel net interfaces */
+static const char tx_channel_name[] = "snfethtx%d";
+static const char rx_channel_name[] = "snfethrx%d";
+
+struct ether_snf {
+	u8 __iomem *regs;
+	int irq;
+	struct clk *sys_clk;
+	struct clk *ts_clk;
+	struct ether_snf_chan txc;
+	struct ether_snf_chan rxc;
+};
+
+/* Interrupt handler */
+static irqreturn_t esnf_interrupt(int irq, void *dev_id)
+{
+	struct platform_device *pdev = (struct platform_device *)dev_id;
+	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
+	u32 irq_status;
+
+	if (unlikely(esnf->irq != irq))
+		return IRQ_NONE;
+
+	irq_status = ioread32(esnf->regs + INTERRUPT_STATUS) &
+				 ioread32(esnf->regs + INTERRUPT_ENABLE);
+
+	dev_dbg(&pdev->dev, "irq: 0x%08x\n", irq_status);
+
+	/* TX FIFO full */
+	if (unlikely(irq_status & TX_FULL_IRQ_BIT))
+		dev_notice(&pdev->dev, "TX FIFO full\n");
+
+	/* RX FIFO full */
+	if (unlikely(irq_status & RX_FULL_IRQ_BIT))
+		dev_notice(&pdev->dev, "RX FIFO full\n");
+
+	/* TX match data available */
+	if (irq_status & TX_DATA_IRQ_BIT) {
+		dev_dbg(&pdev->dev, "TX data\n");
+		channel_data_available(&esnf->txc);
+	}
+
+	/* RX match data available */
+	if (irq_status & RX_DATA_IRQ_BIT) {
+		dev_dbg(&pdev->dev, "RX data\n");
+		channel_data_available(&esnf->rxc);
+	}
+
+	/* Clear interrupts */
+	iowrite32(irq_status, esnf->regs + INTERRUPT_STATUS);
+
+	return IRQ_HANDLED;
+}
+
+/* Called when the packet sniffer device is bound with the driver */
+static int esnf_driver_probe(struct platform_device *pdev)
+{
+	struct ether_snf *esnf;
+	struct resource *res;
+	int ret, irq;
+	u32 fifo_blk_words, ts_hz, ts_bits;
+	void __iomem *regs;
+	struct device_node *ofn = pdev->dev.of_node;
+
+	/* Allocate the device data structure */
+	esnf = devm_kzalloc(&pdev->dev, sizeof(*esnf), GFP_KERNEL);
+	if (!esnf)
+		return -ENOMEM;
+
+	/* Retrieve and remap register memory space */
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
+	regs = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(regs))
+		return PTR_ERR(regs);
+	esnf->regs = regs;
+
+	if (!ofn)
+		return -ENODEV;
+
+	/* Read requirede properties from the device tree node */
+	ret = of_property_read_u32(
+				ofn,
+				"fifo-block-words",
+				&fifo_blk_words);
+	if (ret < 0)
+		return ret;
+
+	if (((fifo_blk_words - 1) * 4) > MAX_MATCH_BYTES) {
+		dev_err(&pdev->dev,
+			"Invalid FIFO block size entry in device tree\n");
+		return -EINVAL;
+	}
+
+	ret = of_property_read_u32(
+				ofn,
+				"tstamp-bits",
+				&ts_bits);
+	if (ret < 0)
+		return ret;
+
+	/* Enable peripheral bus and timstamp clocks */
+	esnf->sys_clk = devm_clk_get(&pdev->dev, "sys");
+	if (IS_ERR(esnf->sys_clk)) {
+		ret = PTR_ERR(esnf->sys_clk);
+		return ret;
+	}
+	ret = clk_prepare_enable(esnf->sys_clk);
+	if (ret < 0)
+		return ret;
+
+	esnf->ts_clk = devm_clk_get(&pdev->dev, "tstamp");
+	if (IS_ERR(esnf->ts_clk)) {
+		ret = PTR_ERR(esnf->ts_clk);
+		goto fail1;
+	}
+	ret = clk_prepare_enable(esnf->ts_clk);
+	if (ret < 0)
+		goto fail1;
+
+	/* Initialise the TX and RX channels */
+	ts_hz = clk_get_rate(esnf->ts_clk);
+	ret = channel_init(
+			&esnf->txc,
+			pdev,
+			regs,
+			fifo_blk_words,
+			ts_hz,
+			ts_bits,
+			1);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to init TX channel (%d)\n", ret);
+		goto fail2;
+	}
+	ret = channel_init(
+			&esnf->rxc,
+			pdev,
+			regs,
+			fifo_blk_words,
+			ts_hz,
+			ts_bits,
+			0);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to init RX channel (%d)\n", ret);
+		goto fail2;
+	}
+
+	/* Register the channels with the sniffer core module */
+	ret = channel_register(&esnf->txc, tx_channel_name);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to register TX chan (%d)\n", ret);
+		goto fail2;
+	}
+	ret = channel_register(&esnf->rxc, rx_channel_name);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to register RX chan (%d)\n", ret);
+		goto fail3;
+	}
+
+	platform_set_drvdata(pdev, esnf);
+
+	/* Register the interrupt handler */
+	irq = platform_get_irq(pdev, 0);
+	if (irq < 0)
+		goto fail4;
+	esnf->irq = irq;
+	ret = devm_request_irq(
+			&pdev->dev,
+			irq,
+			esnf_interrupt,
+			0,
+			KBUILD_MODNAME,
+			pdev);
+	if (ret < 0)
+		goto fail4;
+
+	return 0;
+
+fail4:
+	channel_unregister(&esnf->rxc);
+fail3:
+	channel_unregister(&esnf->txc);
+fail2:
+	clk_disable_unprepare(esnf->ts_clk);
+fail1:
+	clk_disable_unprepare(esnf->sys_clk);
+	return ret;
+}
+
+/* Called when the packet sniffer device unregisters with the driver */
+static int esnf_driver_remove(struct platform_device *pdev)
+{
+	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
+	int ret;
+
+	ret = channel_unregister(&esnf->txc);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to unregister TX chan (%d)\n", ret);
+		return ret;
+	}
+	ret = channel_unregister(&esnf->rxc);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "Failed to unregister RX chan (%d)\n", ret);
+		return ret;
+	}
+	clk_disable_unprepare(esnf->ts_clk);
+	clk_disable_unprepare(esnf->sys_clk);
+	return 0;
+}
+
+#ifdef CONFIG_PM
+/* Driver suspend method */
+static int esnf_driver_suspend(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
+
+	channel_suspend(&esnf->txc);
+	channel_suspend(&esnf->rxc);
+	return 0;
+}
+
+/* Driver resume method */
+static int esnf_driver_resume(struct device *dev)
+{
+	struct platform_device *pdev = to_platform_device(dev);
+	struct ether_snf *esnf = (struct ether_snf *)platform_get_drvdata(pdev);
+
+	channel_resume(&esnf->txc);
+	channel_resume(&esnf->rxc);
+	return 0;
+}
+
+static SIMPLE_DEV_PM_OPS(esnf_pm_ops, esnf_driver_suspend, esnf_driver_resume);
+#endif
+
+static const struct of_device_id esnf_of_match_table[] = {
+	{ .compatible = "linn,eth-packet-sniffer" },
+	{},
+};
+MODULE_DEVICE_TABLE(of, esnf_of_match_table);
+
+static struct platform_driver esnf_platform_driver = {
+	.driver = {
+		.name           = KBUILD_MODNAME,
+#ifdef CONFIG_PM
+		.pm	        = &esnf_pm_ops,
+#endif
+		.of_match_table = esnf_of_match_table,
+	},
+	.probe = esnf_driver_probe,
+	.remove = esnf_driver_remove,
+};
+
+module_platform_driver(esnf_platform_driver);
+
+MODULE_DESCRIPTION("Linn Ethernet Packet Sniffer");
+MODULE_AUTHOR("Linn Products Ltd");
+MODULE_LICENSE("GPL v2");
+
-- 
1.9.1
