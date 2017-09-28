From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time as a PTP hardware clock
Date: Thu, 28 Sep 2017 10:25:34 -0500
Message-ID: <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds basic support for exposing the 32-bit timestamp counter
inside the mv88e6xxx switch code as a ptp_clock.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 drivers/net/dsa/mv88e6xxx/Kconfig  |  10 +++
 drivers/net/dsa/mv88e6xxx/Makefile |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c   |  20 +++++
 drivers/net/dsa/mv88e6xxx/chip.h   |  16 ++++
 drivers/net/dsa/mv88e6xxx/ptp.c    | 180 +++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/ptp.h    |  83 +++++++++++++++++
 6 files changed, 310 insertions(+)
 create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.h

diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
index 1aaa7a9..ae9e7f7 100644
--- a/drivers/net/dsa/mv88e6xxx/Kconfig
+++ b/drivers/net/dsa/mv88e6xxx/Kconfig
@@ -18,3 +18,13 @@ config NET_DSA_MV88E6XXX_GLOBAL2
 
 	  It is required on most chips. If the chip you compile the support for
 	  doesn't have such registers set, say N here. In doubt, say Y.
+
+config NET_DSA_MV88E6XXX_PTP
+	bool "PTP support for Marvell 88E6xxx"
+	default n
+	depends on NET_DSA_MV88E6XXX_GLOBAL2
+	imply NETWORK_PHY_TIMESTAMPING
+	imply PTP_1588_CLOCK
+	help
+	  Say Y to enable PTP hardware timestamping on Marvell 88E6xxx switch
+	  chips that support it.
diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 5cd5551..47eda30 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -6,4 +6,5 @@ mv88e6xxx-objs += global1_vtu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += phy.o
 mv88e6xxx-objs += port.o
+mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_PTP) += ptp.o
 mv88e6xxx-objs += serdes.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 67efa7b..2ed37d8 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -38,6 +38,7 @@
 #include "global2.h"
 #include "phy.h"
 #include "port.h"
+#include "ptp.h"
 #include "serdes.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
@@ -2033,6 +2034,13 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 	if (err)
 		goto unlock;
 
+	/* Setup PTP Hardware Clock */
+	if (chip->info->ptp_support) {
+		err = mv88e6xxx_ptp_setup(chip);
+		if (err)
+			goto unlock;
+	}
+
 unlock:
 	mutex_unlock(&chip->reg_lock);
 
@@ -3418,6 +3426,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.ptp_support = true,
 		.ops = &mv88e6191_ops,
 	},
 
@@ -3438,6 +3447,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.ptp_support = true,
 		.ops = &mv88e6240_ops,
 	},
 
@@ -3458,6 +3468,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.ptp_support = true,
 		.ops = &mv88e6290_ops,
 	},
 
@@ -3477,6 +3488,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.ptp_support = true,
 		.ops = &mv88e6320_ops,
 	},
 
@@ -3495,6 +3507,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.atu_move_port_mask = 0xf,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.ptp_support = true,
 		.ops = &mv88e6321_ops,
 	},
 
@@ -3514,6 +3527,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.ptp_support = true,
 		.ops = &mv88e6341_ops,
 	},
 
@@ -3574,6 +3588,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_EDSA,
+		.ptp_support = true,
 		.ops = &mv88e6352_ops,
 	},
 	[MV88E6390] = {
@@ -3593,6 +3608,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.ptp_support = true,
 		.ops = &mv88e6390_ops,
 	},
 	[MV88E6390X] = {
@@ -3612,6 +3628,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.pvt = true,
 		.multi_chip = true,
 		.tag_protocol = DSA_TAG_PROTO_DSA,
+		.ptp_support = true,
 		.ops = &mv88e6390x_ops,
 	},
 };
@@ -3949,6 +3966,9 @@ static void mv88e6xxx_remove(struct mdio_device *mdiodev)
 	struct dsa_switch *ds = dev_get_drvdata(&mdiodev->dev);
 	struct mv88e6xxx_chip *chip = ds->priv;
 
+	if (chip->info->ptp_support)
+		mv88e6xxx_ptp_free(chip);
+
 	mv88e6xxx_phy_destroy(chip);
 	mv88e6xxx_unregister_switch(chip);
 	mv88e6xxx_mdios_unregister(chip);
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index d99d592..648bd50 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -16,6 +16,8 @@
 #include <linux/irq.h>
 #include <linux/gpio/consumer.h>
 #include <linux/phy.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/timecounter.h>
 #include <net/dsa.h>
 
 #ifndef UINT64_MAX
@@ -126,6 +128,9 @@ struct mv88e6xxx_info {
 	 */
 	u8 atu_move_port_mask;
 	const struct mv88e6xxx_ops *ops;
+
+	/* Supports PTP */
+	bool ptp_support;
 };
 
 struct mv88e6xxx_atu_entry {
@@ -208,6 +213,17 @@ struct mv88e6xxx_chip {
 	int irq;
 	int device_irq;
 	int watchdog_irq;
+
+	/* This cyclecounter abstracts the switch PTP time.
+	 * reg_lock must be held for any operation that read()s.
+	 */
+	struct cyclecounter	tstamp_cc;
+	struct timecounter	tstamp_tc;
+	struct delayed_work	overflow_work;
+	unsigned long		last_overflow_check;
+
+	struct ptp_clock	*ptp_clock;
+	struct ptp_clock_info	ptp_clock_info;
 };
 
 struct mv88e6xxx_bus_ops {
diff --git a/drivers/net/dsa/mv88e6xxx/ptp.c b/drivers/net/dsa/mv88e6xxx/ptp.c
new file mode 100644
index 0000000..155f8e9
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/ptp.c
@@ -0,0 +1,180 @@
+/*
+ * Marvell 88E6xxx Switch PTP support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2017 National Instruments
+ *      Erik Hons <erik.hons@ni.com>
+ *      Brandon Streiff <brandon.streiff@ni.com>
+ *      Dane Wagner <dane.wagner@ni.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "chip.h"
+#include "global2.h"
+#include "ptp.h"
+
+static int mv88e6xxx_tai_read(struct mv88e6xxx_chip *chip, int addr,
+			      u16 *data, int len)
+{
+	if (!chip->info->ops->avb_ops->tai_read)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->avb_ops->tai_read(chip, addr, data, len);
+}
+
+static u64 mv88e6xxx_ptp_clock_read(const struct cyclecounter *cc)
+{
+	struct mv88e6xxx_chip *chip =
+		container_of(cc, struct mv88e6xxx_chip, tstamp_cc);
+	int err;
+	u16 phc_time[2];
+
+	err = mv88e6xxx_tai_read(chip, MV88E6XXX_TAI_TIME_LO, phc_time,
+				 ARRAY_SIZE(phc_time));
+	if (err)
+		return 0;
+	else
+		return ((u32)phc_time[1] << 16) | phc_time[0];
+}
+
+static int mv88e6xxx_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
+{
+	if (scaled_ppm == 0)
+		return 0;
+
+	return -EOPNOTSUPP;
+}
+
+static int mv88e6xxx_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct mv88e6xxx_chip *chip =
+		container_of(ptp, struct mv88e6xxx_chip, ptp_clock_info);
+
+	mutex_lock(&chip->reg_lock);
+	timecounter_adjtime(&chip->tstamp_tc, delta);
+	mutex_unlock(&chip->reg_lock);
+
+	return 0;
+}
+
+static int mv88e6xxx_ptp_gettime(struct ptp_clock_info *ptp,
+				 struct timespec64 *ts)
+{
+	struct mv88e6xxx_chip *chip =
+		container_of(ptp, struct mv88e6xxx_chip, ptp_clock_info);
+	u64 ns;
+
+	mutex_lock(&chip->reg_lock);
+	ns = timecounter_read(&chip->tstamp_tc);
+	chip->last_overflow_check = jiffies;
+	mutex_unlock(&chip->reg_lock);
+
+	*ts = ns_to_timespec64(ns);
+
+	return 0;
+}
+
+static int mv88e6xxx_ptp_settime(struct ptp_clock_info *ptp,
+				 const struct timespec64 *ts)
+{
+	struct mv88e6xxx_chip *chip =
+		container_of(ptp, struct mv88e6xxx_chip, ptp_clock_info);
+	u64 ns;
+
+	ns = timespec64_to_ns(ts);
+
+	mutex_lock(&chip->reg_lock);
+	timecounter_init(&chip->tstamp_tc, &chip->tstamp_cc, ns);
+	mutex_unlock(&chip->reg_lock);
+
+	return 0;
+}
+
+static int mv88e6xxx_ptp_enable(struct ptp_clock_info *ptp,
+				struct ptp_clock_request *rq, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static int mv88e6xxx_ptp_verify(struct ptp_clock_info *ptp, unsigned int pin,
+				enum ptp_pin_function func, unsigned int chan)
+{
+	return -EOPNOTSUPP;
+}
+
+/* The 32-bit timestamp counter overflows every ~34.3 seconds; this task
+ * forces periodic reads so that we don't miss any wraparounds.
+ */
+#define MV88E6XXX_TAI_OVERFLOW_PERIOD (34 * HZ / 2)
+static void mv88e6xxx_ptp_overflow_check(struct work_struct *work)
+{
+	struct delayed_work *dw = to_delayed_work(work);
+	struct mv88e6xxx_chip *chip =
+		container_of(dw, struct mv88e6xxx_chip, overflow_work);
+	bool timeout = time_is_before_jiffies(chip->last_overflow_check +
+					      MV88E6XXX_TAI_OVERFLOW_PERIOD);
+
+	if (timeout) {
+		mutex_lock(&chip->reg_lock);
+		timecounter_read(&chip->tstamp_tc);
+		chip->last_overflow_check = jiffies;
+		mutex_unlock(&chip->reg_lock);
+	}
+
+	schedule_delayed_work(&chip->overflow_work,
+			      MV88E6XXX_TAI_OVERFLOW_PERIOD);
+}
+
+int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip)
+{
+	/* Set up the cycle counter */
+	memset(&chip->tstamp_cc, 0, sizeof(chip->tstamp_cc));
+	chip->tstamp_cc.read	= mv88e6xxx_ptp_clock_read;
+	chip->tstamp_cc.mask	= CYCLECOUNTER_MASK(32);
+	/* Raw timestamps are in units of 8-ns clock periods. */
+	chip->tstamp_cc.mult	= 8;
+	chip->tstamp_cc.shift	= 0;
+
+	timecounter_init(&chip->tstamp_tc, &chip->tstamp_cc,
+			 ktime_to_ns(ktime_get_real()));
+
+	chip->last_overflow_check = jiffies;
+
+	INIT_DELAYED_WORK(&chip->overflow_work, mv88e6xxx_ptp_overflow_check);
+
+	chip->ptp_clock_info.owner = THIS_MODULE;
+	snprintf(chip->ptp_clock_info.name, sizeof(chip->ptp_clock_info.name),
+		 dev_name(chip->dev));
+	chip->ptp_clock_info.max_adj	= 0;
+
+	chip->ptp_clock_info.adjfine	= mv88e6xxx_ptp_adjfine;
+	chip->ptp_clock_info.adjtime	= mv88e6xxx_ptp_adjtime;
+	chip->ptp_clock_info.gettime64	= mv88e6xxx_ptp_gettime;
+	chip->ptp_clock_info.settime64	= mv88e6xxx_ptp_settime;
+	chip->ptp_clock_info.enable	= mv88e6xxx_ptp_enable;
+	chip->ptp_clock_info.verify	= mv88e6xxx_ptp_verify;
+
+	chip->ptp_clock = ptp_clock_register(&chip->ptp_clock_info, chip->dev);
+	if (IS_ERR(chip->ptp_clock))
+		return PTR_ERR(chip->ptp_clock);
+
+	schedule_delayed_work(&chip->overflow_work,
+			      MV88E6XXX_TAI_OVERFLOW_PERIOD);
+
+	return 0;
+}
+
+void mv88e6xxx_ptp_free(struct mv88e6xxx_chip *chip)
+{
+	if (chip->ptp_clock) {
+		cancel_delayed_work_sync(&chip->overflow_work);
+
+		ptp_clock_unregister(chip->ptp_clock);
+		chip->ptp_clock = NULL;
+	}
+}
diff --git a/drivers/net/dsa/mv88e6xxx/ptp.h b/drivers/net/dsa/mv88e6xxx/ptp.h
new file mode 100644
index 0000000..c662953
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/ptp.h
@@ -0,0 +1,83 @@
+/*
+ * Marvell 88E6xxx Switch PTP support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2017 National Instruments
+ *      Erik Hons <erik.hons@ni.com>
+ *      Brandon Streiff <brandon.streiff@ni.com>
+ *      Dane Wagner <dane.wagner@ni.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _MV88E6XXX_PTP_H
+#define _MV88E6XXX_PTP_H
+
+#include "chip.h"
+
+/* Offset 0x00: TAI Global Config */
+#define MV88E6XXX_TAI_CFG			0x00
+
+/* Offset 0x01: Timestamp Clock Period (ps) */
+#define MV88E6XXX_TAI_CLOCK_PERIOD		0x01
+
+/* Offset 0x02/0x03: Trigger Generation Amount */
+#define MV88E6XXX_TAI_TRIG_GEN_AMOUNT_LO	0x02
+#define MV88E6XXX_TAI_TRIG_GEN_AMOUNT_HI	0x03
+
+/* Offset 0x04: Clock Compensation */
+#define MV88E6XXX_TAI_TRIG_CLOCK_COMP		0x04
+
+/* Offset 0x05: Trigger Configuration */
+#define MV88E6XXX_TAI_TRIG_CFG			0x05
+
+/* Offset 0x06: Ingress Rate Limiter Clock Generation Amount */
+#define MV88E6XXX_TAI_IRL_AMOUNT		0x06
+
+/* Offset 0x07: Ingress Rate Limiter Compensation */
+#define MV88E6XXX_TAI_IRL_COMP			0x07
+
+/* Offset 0x08: Ingress Rate Limiter Compensation */
+#define MV88E6XXX_TAI_IRL_COMP_PS		0x08
+
+/* Offset 0x09: Event Status */
+#define MV88E6XXX_TAI_EVENT_STATUS		0x09
+
+/* Offset 0x0A/0x0B: Event Time */
+#define MV88E6XXX_TAI_EVENT_TIME_LO		0x0a
+#define MV88E6XXX_TAI_EVENT_TYPE_HI		0x0b
+
+/* Offset 0x0E/0x0F: PTP Global Time */
+#define MV88E6XXX_TAI_TIME_LO			0x0e
+#define MV88E6XXX_TAI_TIME_HI			0x0f
+
+/* Offset 0x10/0x11: Trig Generation Time */
+#define MV88E6XXX_TAI_TRIG_TIME_LO		0x10
+#define MV88E6XXX_TAI_TRIG_TIME_HI		0x11
+
+/* Offset 0x12: Lock Status */
+#define MV88E6XXX_TAI_LOCK_STATUS		0x12
+
+#ifdef CONFIG_NET_DSA_MV88E6XXX_PTP
+
+int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip);
+void mv88e6xxx_ptp_free(struct mv88e6xxx_chip *chip);
+
+#else /* !CONFIG_NET_DSA_MV88E6XXX_PTP */
+
+static inline int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip)
+{
+	return -EOPNOTSUPP;
+}
+
+static void mv88e6xxx_ptp_free(struct mv88e6xxx_chip *chip)
+{
+}
+
+#endif /* CONFIG_NET_DSA_MV88E6XXX_PTP */
+
+#endif /* _MV88E6XXX_PTP_H */
-- 
2.1.4
