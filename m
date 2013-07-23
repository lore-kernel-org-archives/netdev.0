From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 05/13] tile: support PTP using the tilegx mPIPE (IEEE 1588)
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/gxio/iorpc_mpipe.c           |  19 ++++
 arch/tile/include/gxio/iorpc_mpipe.h   |   4 +
 arch/tile/include/gxio/mpipe.h         |  13 +++
 drivers/net/ethernet/tile/Makefile     |   1 +
 drivers/net/ethernet/tile/tilegx.c     |  56 +++++++++
 drivers/net/ethernet/tile/tilegx_ptp.c | 202 +++++++++++++++++++++++++++++++++
 drivers/ptp/Kconfig                    |  10 ++
 7 files changed, 305 insertions(+)
 create mode 100644 drivers/net/ethernet/tile/tilegx_ptp.c

diff --git a/arch/tile/gxio/iorpc_mpipe.c b/arch/tile/gxio/iorpc_mpipe.c
index 31b87bf..ad48e71 100644
--- a/arch/tile/gxio/iorpc_mpipe.c
+++ b/arch/tile/gxio/iorpc_mpipe.c
@@ -454,6 +454,25 @@ int gxio_mpipe_adjust_timestamp_aux(gxio_mpipe_context_t * context,
 
 EXPORT_SYMBOL(gxio_mpipe_adjust_timestamp_aux);
 
+struct adjust_timestamp_freq_param {
+	int32_t ppb;
+};
+
+int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t * context,
+				     int32_t ppb)
+{
+	struct adjust_timestamp_freq_param temp;
+	struct adjust_timestamp_freq_param *params = &temp;
+
+	params->ppb = ppb;
+
+	return hv_dev_pwrite(context->fd, 0, (HV_VirtAddr) params,
+			     sizeof(*params),
+			     GXIO_MPIPE_OP_ADJUST_TIMESTAMP_FREQ);
+}
+
+EXPORT_SYMBOL(gxio_mpipe_adjust_timestamp_freq);
+
 struct arm_pollfd_param {
 	union iorpc_pollfd pollfd;
 };
diff --git a/arch/tile/include/gxio/iorpc_mpipe.h b/arch/tile/include/gxio/iorpc_mpipe.h
index 9d50fce..6961ec2 100644
--- a/arch/tile/include/gxio/iorpc_mpipe.h
+++ b/arch/tile/include/gxio/iorpc_mpipe.h
@@ -48,6 +48,7 @@
 #define GXIO_MPIPE_OP_GET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121e)
 #define GXIO_MPIPE_OP_SET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121f)
 #define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x1220)
+#define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_FREQ IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1222)
 #define GXIO_MPIPE_OP_ARM_POLLFD       IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9000)
 #define GXIO_MPIPE_OP_CLOSE_POLLFD     IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9001)
 #define GXIO_MPIPE_OP_GET_MMIO_BASE    IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x8000)
@@ -124,6 +125,9 @@ int gxio_mpipe_set_timestamp_aux(gxio_mpipe_context_t * context, uint64_t sec,
 int gxio_mpipe_adjust_timestamp_aux(gxio_mpipe_context_t * context,
 				    int64_t nsec);
 
+int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t * context,
+                                     int32_t ppb);
+
 int gxio_mpipe_arm_pollfd(gxio_mpipe_context_t * context, int pollfd_cookie);
 
 int gxio_mpipe_close_pollfd(gxio_mpipe_context_t * context, int pollfd_cookie);
diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
index b74f470..57f5ca2 100644
--- a/arch/tile/include/gxio/mpipe.h
+++ b/arch/tile/include/gxio/mpipe.h
@@ -1733,4 +1733,17 @@ extern int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
 extern int gxio_mpipe_adjust_timestamp(gxio_mpipe_context_t *context,
 				       int64_t delta);
 
+/* Adjust the mPIPE timestamp clock frequency.
+ *
+ * @param context An initialized mPIPE context.
+ * @param ppb A 32-bits signed PPB(Parts Per Billion) value to adjust.
+ * The absolute value of ppb must be less than or equal to 1000000000,
+ * and should be larger then 30000, otherwise just ignored because of
+ * the clock precision restriction.
+ * @return If the call was successful, zero; otherwise, a negative error
+ *  code.
+ */
+extern int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t *context,
+					    int32_t ppb);
+
 #endif /* !_GXIO_MPIPE_H_ */
diff --git a/drivers/net/ethernet/tile/Makefile b/drivers/net/ethernet/tile/Makefile
index 0ef9eef..e2df77e 100644
--- a/drivers/net/ethernet/tile/Makefile
+++ b/drivers/net/ethernet/tile/Makefile
@@ -5,6 +5,7 @@
 obj-$(CONFIG_TILE_NET) += tile_net.o
 ifdef CONFIG_TILEGX
 tile_net-y := tilegx.o
+obj-$(CONFIG_PTP_1588_CLOCK_TILEGX) += tilegx_ptp.o
 else
 tile_net-y := tilepro.o
 endif
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index f3c2d03..3d4406c 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -389,6 +389,39 @@ oops:
 	pr_notice("Tile %d still needs some buffers\n", info->my_cpu);
 }
 
+/* Get RX timestamp, and store it in the skb. */
+static void tile_rx_timestamp(struct sk_buff *skb, gxio_mpipe_idesc_t *idesc)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+
+	memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+	shhwtstamps->hwtstamp = ktime_set(idesc->time_stamp_sec,
+					  idesc->time_stamp_ns);
+#endif
+}
+
+/* Get TX timestamp, and store it in the skb. */
+static void tile_tx_timestamp(struct sk_buff *skb)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct skb_shared_info *shtx;
+	struct timespec ts;
+
+	shtx = skb_shinfo(skb);
+	if (likely((shtx->tx_flags & SKBTX_HW_TSTAMP) == 0))
+		return;
+
+	shtx->tx_flags |= SKBTX_IN_PROGRESS;
+
+	gxio_mpipe_get_timestamp(&context, &ts);
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+	skb_tstamp_tx(skb, &shhwtstamps);
+#endif
+}
+
 static inline bool filter_packet(struct net_device *dev, void *buf)
 {
 	/* Filter packets received before we're up. */
@@ -419,6 +452,9 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	if (idesc->cs && idesc->csum_seed_val == 0xFFFF)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	/* Get RX timestamp from idesc. */
+	tile_rx_timestamp(skb, idesc);
+
 	netif_receive_skb(skb);
 
 	/* Update stats. */
@@ -987,6 +1023,7 @@ static int tile_net_init_mpipe(struct net_device *dev)
 	int i, num_buffers, rc;
 	int cpu;
 	int first_ring, ring;
+	struct timespec ts;
 	int network_cpus_count = cpus_weight(network_cpus_map);
 
 	if (!hash_default) {
@@ -1000,6 +1037,10 @@ static int tile_net_init_mpipe(struct net_device *dev)
 		return -EIO;
 	}
 
+	/* Sync mPIPE's timestamp up with Linux system time. */
+	getnstimeofday(&ts);
+	gxio_mpipe_set_timestamp(&context, &ts);
+
 	/* Set up the buffer stacks. */
 	num_buffers =
 		network_cpus_count * (IQUEUE_ENTRIES + TILE_NET_BATCH);
@@ -1284,6 +1325,12 @@ static int tile_net_stop(struct net_device *dev)
 	return 0;
 }
 
+gxio_mpipe_context_t *get_mpipe_context(int index)
+{
+	return ingress_irq < 0 ? NULL : &context;
+}
+EXPORT_SYMBOL_GPL(get_mpipe_context);
+
 /* Determine the VA for a fragment. */
 static inline void *tile_net_frag_buf(skb_frag_t *f)
 {
@@ -1693,6 +1740,9 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < num_edescs; i++)
 		gxio_mpipe_equeue_put_at(equeue, edescs[i], slot++);
 
+	/* Store TX timestamp if needed. */
+	tile_tx_timestamp(skb);
+
 	/* Add a completion record. */
 	add_comp(equeue, comps, slot - 1, skb);
 
@@ -1727,6 +1777,12 @@ static void tile_net_tx_timeout(struct net_device *dev)
 /* Ioctl commands. */
 static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	if (cmd == SIOCSHWTSTAMP) {
+		/* Hardware timestamping was enabled by default. */
+		return 0;
+	}
+#endif
 	return -EOPNOTSUPP;
 }
 
diff --git a/drivers/net/ethernet/tile/tilegx_ptp.c b/drivers/net/ethernet/tile/tilegx_ptp.c
new file mode 100644
index 0000000..a188463
--- /dev/null
+++ b/drivers/net/ethernet/tile/tilegx_ptp.c
@@ -0,0 +1,202 @@
+/*
+ * PTP 1588 clock using the TILE-Gx.
+ *
+ * Copyright 2013 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ *
+ * This source code is derived from ptp_ixp46x.c wrote by Richard Cochran.
+ */
+
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/gpio.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/ptp_clock_kernel.h>
+
+#include <gxio/mpipe.h>
+#include <gxio/iorpc_mpipe.h>
+
+#define GBE_LINK_NR		4
+
+/* nanoseconds will be incremented each clock cycle. */
+#define GBE_TIMER_INCREMENT	8
+
+
+MODULE_AUTHOR("Tilera Corporation");
+MODULE_DESCRIPTION("PTP clock using the TILE-Gx");
+MODULE_LICENSE("GPL");
+
+
+struct mpipe_clock {
+	struct ptp_clock *ptp_clock;
+	gxio_mpipe_context_t *context;
+	struct ptp_clock_info caps;
+	struct mutex lock;
+};
+
+static struct mpipe_clock mpipe_clock;
+
+extern gxio_mpipe_context_t *get_mpipe_context(int index);
+
+/*
+ * Check if the context of mpipe device is valid.
+ */
+static inline int mpipe_context_check(struct mpipe_clock *clock)
+{
+	if (!clock->context) {
+		clock->context = get_mpipe_context(0);
+		if (!clock->context) {
+			pr_debug("Invalid mPIPE context.\n");
+			return -EIO;
+		}
+	}
+
+	return 0;
+}
+
+
+/*
+ * PTP clock operations.
+ */
+
+static int ptp_mpipe_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	int ret = 0;
+	struct mpipe_clock *clock = container_of(ptp, struct mpipe_clock, caps);
+
+	mutex_lock(&clock->lock);
+	if (mpipe_context_check(clock)) {
+		mutex_unlock(&clock->lock);
+		return -EIO;
+	}
+
+	if (gxio_mpipe_adjust_timestamp_freq(clock->context, ppb))
+		ret = -EINVAL;
+
+	mutex_unlock(&clock->lock);
+	return ret;
+}
+
+static int ptp_mpipe_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	int ret;
+	struct mpipe_clock *clock = container_of(ptp, struct mpipe_clock, caps);
+
+	mutex_lock(&clock->lock);
+
+	if (mpipe_context_check(clock)) {
+		mutex_unlock(&clock->lock);
+		return -EIO;
+	}
+
+	ret = gxio_mpipe_adjust_timestamp(clock->context, delta);
+
+	/* Convert a gxio error code to a Linux error code. */
+	if (ret < 0)
+		ret = -EBUSY;
+
+	mutex_unlock(&clock->lock);
+
+	return ret;
+}
+
+static int ptp_mpipe_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	int ret;
+	struct mpipe_clock *clock = container_of(ptp, struct mpipe_clock, caps);
+
+	mutex_lock(&clock->lock);
+
+	if (mpipe_context_check(clock)) {
+		mutex_unlock(&clock->lock);
+		return -EIO;
+	}
+
+	ret = gxio_mpipe_get_timestamp(clock->context, ts);
+
+	/* Convert a gxio error code to a Linux error code. */
+	if (ret < 0)
+		ret = -EBUSY;
+
+	mutex_unlock(&clock->lock);
+
+	return ret;
+}
+
+static int ptp_mpipe_settime(struct ptp_clock_info *ptp,
+			     const struct timespec *ts)
+{
+	int ret;
+	struct mpipe_clock *clock = container_of(ptp, struct mpipe_clock, caps);
+
+	mutex_lock(&clock->lock);
+
+	if (mpipe_context_check(clock)) {
+		mutex_unlock(&clock->lock);
+		return -EIO;
+	}
+
+	ret = gxio_mpipe_set_timestamp(clock->context, ts);
+
+	/* Convert a gxio error code to a Linux error code. */
+	if (ret < 0)
+		ret = -EBUSY;
+
+	mutex_unlock(&clock->lock);
+
+	return ret;
+}
+
+static struct ptp_clock_info ptp_mpipe_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "mPIPE ptp timer",
+	.max_adj	= 512000,
+	.n_ext_ts	= 0,
+	.pps		= 0,
+	.adjfreq	= ptp_mpipe_adjfreq,
+	.adjtime	= ptp_mpipe_adjtime,
+	.gettime	= ptp_mpipe_gettime,
+	.settime	= ptp_mpipe_settime,
+};
+
+
+static void __exit ptp_tilegx_exit(void)
+{
+	ptp_clock_unregister(mpipe_clock.ptp_clock);
+	mutex_destroy(&mpipe_clock.lock);
+}
+
+
+static int __init ptp_tilegx_init(void)
+{
+	int err = 0;
+
+	mpipe_clock.context = NULL;
+	mpipe_clock.caps = ptp_mpipe_caps;
+	mutex_init(&mpipe_clock.lock);
+
+	mpipe_clock.ptp_clock = ptp_clock_register(&mpipe_clock.caps, NULL);
+	if (IS_ERR(mpipe_clock.ptp_clock)) {
+		err = PTR_ERR(mpipe_clock.ptp_clock);
+		pr_debug("Register ptp clock fail: %d\n", err);
+	}
+
+	return err;
+}
+
+module_init(ptp_tilegx_init);
+module_exit(ptp_tilegx_exit);
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 5be73ba..255ed1a 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -87,4 +87,14 @@ config PTP_1588_CLOCK_PCH
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_pch.
 
+config PTP_1588_CLOCK_TILEGX
+        tristate "Tilera TILE-Gx mPIPE as PTP clock"
+        select PTP_1588_CLOCK
+        depends on TILEGX
+        help
+          This driver adds support for using the mPIPE as a PTP
+          clock. This clock is only useful if your PTP programs are
+          getting hardware time stamps on the PTP Ethernet packets
+          using the SO_TIMESTAMPING API.
+
 endmenu
-- 
1.8.3.1
