From: <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 01/10] drivers: reset: STi SoC system configuration reset controller support
Date: Tue, 12 Nov 2013 13:52:18 +0000
Message-ID: <1384264338-7353-1-git-send-email-srinivas.kandagatla@st.com>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, <stephen.gallimore@st.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	<devicetree@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <kernel@stlinux.com>,
	<linux-pm@vger.kernel.org>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Gallimore <stephen.gallimore@st.com>

This patch adds a reset controller implementation for STMicroelectronics
STi family SoCs; it allows a group of related reset like controls found
in multiple system configuration registers to be represented by a single
controller device. System configuration registers are accessed through
the regmap framework and the mfd/syscon driver.

The implementation optionally supports waiting for the reset action to
be acknowledged in a separate status register and supports both
active high and active low reset lines. These properties are common across
all the reset channels in a specific reset controller instance, hence
all channels in a paritcular controller are expected to behave in the
same way.

Signed-off-by: Stephen Gallimore <stephen.gallimore@st.com>
---
 drivers/reset/Kconfig            |    2 +
 drivers/reset/Makefile           |    3 +
 drivers/reset/sti/Kconfig        |    7 ++
 drivers/reset/sti/Makefile       |    1 +
 drivers/reset/sti/reset-syscfg.c |  186 ++++++++++++++++++++++++++++++++++++++
 drivers/reset/sti/reset-syscfg.h |   69 ++++++++++++++
 6 files changed, 268 insertions(+), 0 deletions(-)
 create mode 100644 drivers/reset/sti/Kconfig
 create mode 100644 drivers/reset/sti/Makefile
 create mode 100644 drivers/reset/sti/reset-syscfg.c
 create mode 100644 drivers/reset/sti/reset-syscfg.h

diff --git a/drivers/reset/Kconfig b/drivers/reset/Kconfig
index c9d04f7..0615f50 100644
--- a/drivers/reset/Kconfig
+++ b/drivers/reset/Kconfig
@@ -11,3 +11,5 @@ menuconfig RESET_CONTROLLER
 	  via GPIOs or SoC-internal reset controller modules.
 
 	  If unsure, say no.
+
+source "drivers/reset/sti/Kconfig"
diff --git a/drivers/reset/Makefile b/drivers/reset/Makefile
index 1e2d83f..2b2a57c 100644
--- a/drivers/reset/Makefile
+++ b/drivers/reset/Makefile
@@ -1 +1,4 @@
 obj-$(CONFIG_RESET_CONTROLLER) += core.o
+
+# SoC specific
+obj-$(CONFIG_ARCH_STI) += sti/
diff --git a/drivers/reset/sti/Kconfig b/drivers/reset/sti/Kconfig
new file mode 100644
index 0000000..ba13796
--- /dev/null
+++ b/drivers/reset/sti/Kconfig
@@ -0,0 +1,7 @@
+if ARCH_STI
+
+config STI_RESET_SYSCFG
+	bool
+	select RESET_CONTROLLER
+
+endif
diff --git a/drivers/reset/sti/Makefile b/drivers/reset/sti/Makefile
new file mode 100644
index 0000000..c4a51d9
--- /dev/null
+++ b/drivers/reset/sti/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_STI_RESET_SYSCFG) += reset-syscfg.o
diff --git a/drivers/reset/sti/reset-syscfg.c b/drivers/reset/sti/reset-syscfg.c
new file mode 100644
index 0000000..a145cc0
--- /dev/null
+++ b/drivers/reset/sti/reset-syscfg.c
@@ -0,0 +1,186 @@
+/*
+ * Copyright (C) 2013 STMicroelectronics Limited
+ * Author: Stephen Gallimore <stephen.gallimore@st.com>
+ *
+ * Inspired by mach-imx/src.c
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#include <linux/kernel.h>
+#include <linux/platform_device.h>
+#include <linux/module.h>
+#include <linux/err.h>
+#include <linux/types.h>
+#include <linux/of_device.h>
+#include <linux/regmap.h>
+#include <linux/mfd/syscon.h>
+
+#include "reset-syscfg.h"
+
+/**
+ * Reset channel regmap configuration
+ *
+ * @reset: regmap field for the channel's reset bit.
+ * @ack: regmap field for the channel's ack bit (optional).
+ */
+struct syscfg_reset_channel {
+	struct regmap_field *reset;
+	struct regmap_field *ack;
+};
+
+/**
+ * A reset controller which groups together a set of related reset bits, which
+ * may be located in different system configuration registers.
+ *
+ * @rst: base reset controller structure.
+ * @active_low: are the resets in this controller active low, i.e. clearing
+ *              the reset bit puts the hardware into reset.
+ * @channels: An array of reset channels for this controller.
+ */
+struct syscfg_reset_controller {
+	struct reset_controller_dev rst;
+	bool active_low;
+	struct syscfg_reset_channel *channels;
+};
+
+#define to_syscfg_reset_controller(_rst) \
+	container_of(_rst, struct syscfg_reset_controller, rst)
+
+static int syscfg_reset_program_hw(struct reset_controller_dev *rcdev,
+				   unsigned long idx, int assert)
+{
+	struct syscfg_reset_controller *rst = to_syscfg_reset_controller(rcdev);
+	const struct syscfg_reset_channel *ch;
+	u32 ctrl_val = rst->active_low ? !assert : !!assert;
+	int err;
+
+	if (idx >= rcdev->nr_resets)
+		return -EINVAL;
+
+	ch = &rst->channels[idx];
+
+	err = regmap_field_write(ch->reset, ctrl_val);
+	if (err)
+		return err;
+
+	if (ch->ack) {
+		unsigned long timeout = jiffies + msecs_to_jiffies(1000);
+		u32 ack_val;
+
+		while (true) {
+			err = regmap_field_read(ch->ack, &ack_val);
+			if (err)
+				return err;
+
+			if (ack_val == ctrl_val)
+				break;
+
+			if (time_after(jiffies, timeout))
+				return -ETIME;
+
+			cpu_relax();
+		}
+	}
+
+	return 0;
+}
+
+static int syscfg_reset_assert(struct reset_controller_dev *rcdev,
+			       unsigned long idx)
+{
+	return syscfg_reset_program_hw(rcdev, idx, true);
+}
+
+static int syscfg_reset_deassert(struct reset_controller_dev *rcdev,
+				 unsigned long idx)
+{
+	return syscfg_reset_program_hw(rcdev, idx, false);
+}
+
+static int syscfg_reset_dev(struct reset_controller_dev *rcdev,
+			    unsigned long idx)
+{
+	int err = syscfg_reset_assert(rcdev, idx);
+	if (err)
+		return err;
+
+	return syscfg_reset_deassert(rcdev, idx);
+}
+
+static struct reset_control_ops syscfg_reset_ops = {
+	.reset    = syscfg_reset_dev,
+	.assert   = syscfg_reset_assert,
+	.deassert = syscfg_reset_deassert,
+};
+
+static int syscfg_reset_controller_register(struct device *dev,
+				const struct syscfg_reset_controller_data *data)
+{
+	struct syscfg_reset_controller *rc;
+	size_t size;
+	int i, err;
+
+	rc = devm_kzalloc(dev, sizeof(*rc), GFP_KERNEL);
+	if (!rc)
+		return -ENOMEM;
+
+	size = sizeof(struct syscfg_reset_channel) * data->nr_channels;
+
+	rc->channels = devm_kzalloc(dev, size, GFP_KERNEL);
+	if (!rc->channels)
+		return -ENOMEM;
+
+	rc->rst.ops = &syscfg_reset_ops,
+	rc->rst.of_node = dev->of_node;
+	rc->rst.nr_resets = data->nr_channels;
+	rc->active_low = data->active_low;
+
+	for (i = 0; i < data->nr_channels; i++) {
+		struct regmap *map;
+		struct regmap_field *f;
+		const char *compatible = data->channels[i].compatible;
+
+		map = syscon_regmap_lookup_by_compatible(compatible);
+		if (IS_ERR(map))
+			return PTR_ERR(map);
+
+		f = devm_regmap_field_alloc(dev, map, data->channels[i].reset);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
+
+		rc->channels[i].reset = f;
+
+		if (!data->wait_for_ack)
+			continue;
+
+		f = devm_regmap_field_alloc(dev, map, data->channels[i].ack);
+		if (IS_ERR(f))
+			return PTR_ERR(f);
+
+		rc->channels[i].ack = f;
+	}
+
+	err = reset_controller_register(&rc->rst);
+	if (!err)
+		dev_info(dev, "registered\n");
+
+	return err;
+}
+
+int syscfg_reset_probe(struct platform_device *pdev)
+{
+	struct device *dev = pdev ? &pdev->dev : NULL;
+	const struct of_device_id *match;
+
+	if (!dev || !dev->driver)
+		return -ENODEV;
+
+	match = of_match_device(dev->driver->of_match_table, dev);
+	if (!match || !match->data)
+		return -EINVAL;
+
+	return syscfg_reset_controller_register(dev, match->data);
+}
diff --git a/drivers/reset/sti/reset-syscfg.h b/drivers/reset/sti/reset-syscfg.h
new file mode 100644
index 0000000..2cc2283
--- /dev/null
+++ b/drivers/reset/sti/reset-syscfg.h
@@ -0,0 +1,69 @@
+/*
+ * Copyright (C) 2013 STMicroelectronics (R&D) Limited
+ * Author: Stephen Gallimore <stephen.gallimore@st.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef __STI_RESET_SYSCFG_H
+#define __STI_RESET_SYSCFG_H
+
+#include <linux/device.h>
+#include <linux/regmap.h>
+#include <linux/reset-controller.h>
+
+/**
+ * Reset channel description for a system configuration register based
+ * reset controller.
+ *
+ * @compatible: Compatible string of the syscon regmap containing this
+ *              channel's control and ack (status) bits.
+ * @reset: Regmap field description of the channel's reset bit.
+ * @ack: Regmap field description of the channel's acknowledge bit.
+ */
+struct syscfg_reset_channel_data {
+	const char *compatible;
+	struct reg_field reset;
+	struct reg_field ack;
+};
+
+#define _SYSCFG_RST_CH(_c, _rr, _rb, _ar, _ab)		\
+	{ .compatible	= _c,				\
+	  .reset	= REG_FIELD(_rr, _rb, _rb),	\
+	  .ack		= REG_FIELD(_ar, _ab, _ab), }
+
+#define _SYSCFG_RST_CH_NO_ACK(_c, _rr, _rb)		\
+	{ .compatible	= _c,			\
+	  .reset	= REG_FIELD(_rr, _rb, _rb), }
+
+/**
+ * Description of a system configuration register based reset controller.
+ *
+ * @wait_for_ack: The controller will wait for reset assert and de-assert to
+ *                be "ack'd" in a channel's ack field.
+ * @active_low: Are the resets in this controller active low, i.e. clearing
+ *              the reset bit puts the hardware into reset.
+ * @nr_channels: The number of reset channels in this controller.
+ * @channels: An array of reset channel descriptions.
+ */
+struct syscfg_reset_controller_data {
+	bool wait_for_ack;
+	bool active_low;
+	int nr_channels;
+	const struct syscfg_reset_channel_data *channels;
+};
+
+/**
+ * syscfg_reset_probe(): platform device probe function used by syscfg
+ *                       reset controller drivers. This registers a reset
+ *                       controller configured by the OF match data for
+ *                       the compatible device which should be of type
+ *                       "struct syscfg_reset_controller_data".
+ *
+ * @pdev: platform device
+ */
+int syscfg_reset_probe(struct platform_device *pdev);
+
+#endif /* __STI_RESET_SYSCFG_H */
-- 
1.7.6.5

