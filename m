From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v2] tile: support PTP using the tilegx mPIPE (IEEE 1588)
Date: Thu, 25 Jul 2013 11:19:38 -0400
Message-ID: <201307251525.r6PFP7Ox030354@farm-0012.internal.tilera.com>
References: <20130724062533.GA5163@netboy>
 <cover.1374609948.git.cmetcalf@tilera.com>
 <77f753af79722f39c5fa77cd35adefdd1634e5d5.1374609949.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130724062533.GA5163@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v2:
 - Moved Kconfig stanza to drivers/ethernet/tile/Kconfig
 - Clarify minimum and maximum frequency adjustments
 - Merge PTP support into tilegx.c driver source code directly
 - Support SIOCSHWTSTAMP ioctl appopriately
 - Rebased to be the last patch in the series to simplify development

 arch/tile/gxio/iorpc_mpipe.c         |  19 +++
 arch/tile/include/gxio/iorpc_mpipe.h |  10 +-
 arch/tile/include/gxio/mpipe.h       |  14 +++
 drivers/net/ethernet/tile/Kconfig    |  11 ++
 drivers/net/ethernet/tile/tilegx.c   | 216 ++++++++++++++++++++++++++++++++++-
 5 files changed, 266 insertions(+), 4 deletions(-)

diff --git a/arch/tile/gxio/iorpc_mpipe.c b/arch/tile/gxio/iorpc_mpipe.c
index c2fb1516..4f8f3d6 100644
--- a/arch/tile/gxio/iorpc_mpipe.c
+++ b/arch/tile/gxio/iorpc_mpipe.c
@@ -475,6 +475,25 @@ int gxio_mpipe_adjust_timestamp_aux(gxio_mpipe_context_t * context,
 
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
 struct config_edma_ring_blks_param {
 	unsigned int ering;
 	unsigned int max_blks;
diff --git a/arch/tile/include/gxio/iorpc_mpipe.h b/arch/tile/include/gxio/iorpc_mpipe.h
index eef60fd..ea6dea3 100644
--- a/arch/tile/include/gxio/iorpc_mpipe.h
+++ b/arch/tile/include/gxio/iorpc_mpipe.h
@@ -46,10 +46,11 @@
 #define GXIO_MPIPE_OP_LINK_CLOSE_AUX   IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1212)
 #define GXIO_MPIPE_OP_LINK_SET_ATTR_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1213)
 
-#define GXIO_MPIPE_OP_GET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121e)
-#define GXIO_MPIPE_OP_SET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121f)
-#define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x1220)
+#define GXIO_MPIPE_OP_GET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x121e)
+#define GXIO_MPIPE_OP_SET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x121f)
+#define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1220)
 #define GXIO_MPIPE_OP_CONFIG_EDMA_RING_BLKS IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1221)
+#define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_FREQ IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1222)
 #define GXIO_MPIPE_OP_ARM_POLLFD       IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9000)
 #define GXIO_MPIPE_OP_CLOSE_POLLFD     IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9001)
 #define GXIO_MPIPE_OP_GET_MMIO_BASE    IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x8000)
@@ -128,6 +129,9 @@ int gxio_mpipe_set_timestamp_aux(gxio_mpipe_context_t * context, uint64_t sec,
 int gxio_mpipe_adjust_timestamp_aux(gxio_mpipe_context_t * context,
 				    int64_t nsec);
 
+int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t * context,
+                                     int32_t ppb);
+
 int gxio_mpipe_arm_pollfd(gxio_mpipe_context_t * context, int pollfd_cookie);
 
 int gxio_mpipe_close_pollfd(gxio_mpipe_context_t * context, int pollfd_cookie);
diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
index eb7fee4..e37cf4f 100644
--- a/arch/tile/include/gxio/mpipe.h
+++ b/arch/tile/include/gxio/mpipe.h
@@ -1854,4 +1854,18 @@ extern int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
 extern int gxio_mpipe_adjust_timestamp(gxio_mpipe_context_t *context,
 				       int64_t delta);
 
+/** Adjust the mPIPE timestamp clock frequency.
+ *
+ * @param context An initialized mPIPE context.
+ * @param ppb A 32-bit signed PPB (Parts Per Billion) value to adjust.
+ * The absolute value of ppb must be less than or equal to 1000000000.
+ * Values less than about 30000 will generally cause a GXIO_ERR_INVAL
+ * return due to the granularity of the hardware that converts reference
+ * clock cycles into seconds and nanoseconds.
+ * @return If the call was successful, zero; otherwise, a negative error
+ *  code.
+ */
+extern int gxio_mpipe_adjust_timestamp_freq(gxio_mpipe_context_t* context,
+                                            int32_t ppb);
+
 #endif /* !_GXIO_MPIPE_H_ */
diff --git a/drivers/net/ethernet/tile/Kconfig b/drivers/net/ethernet/tile/Kconfig
index 098b1c4..4083ba8 100644
--- a/drivers/net/ethernet/tile/Kconfig
+++ b/drivers/net/ethernet/tile/Kconfig
@@ -15,3 +15,14 @@ config TILE_NET
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called tile_net.
+
+config PTP_1588_CLOCK_TILEGX
+        tristate "Tilera TILE-Gx mPIPE as PTP clock"
+        select PTP_1588_CLOCK
+        depends on TILE_NET
+        depends on TILEGX
+        ---help---
+          This driver adds support for using the mPIPE as a PTP
+          clock. This clock is only useful if your PTP programs are
+          getting hardware time stamps on the PTP Ethernet packets
+          using the SO_TIMESTAMPING API.
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index a9ac91b..91b1deb 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -38,6 +38,8 @@
 #include <linux/ip.h>
 #include <linux/ipv6.h>
 #include <linux/tcp.h>
+#include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
 
 #include <asm/checksum.h>
 #include <asm/homecache.h>
@@ -185,6 +187,10 @@ struct tile_net_priv {
 	int echannel;
 	/* mPIPE instance, 0 or 1. */
 	int instance;
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	/* The timestamp config. */
+	struct hwtstamp_config stamp_cfg;
+#endif
 };
 
 static struct mpipe_data {
@@ -223,6 +229,15 @@ static struct mpipe_data {
 	int first_bucket;
 	int num_buckets;
 
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	/* PTP-specific data. */
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info caps;
+
+	/* Lock for ptp accessors. */
+	struct mutex ptp_lock;
+#endif
+
 } mpipe_data[NR_MPIPE_MAX] = {
 	[0 ... (NR_MPIPE_MAX - 1)] {
 		.ingress_irq = -1,
@@ -434,6 +449,94 @@ static void tile_net_provide_needed_buffers(void)
 	}
 }
 
+/* Get RX timestamp, and store it in the skb. */
+static void tile_rx_timestamp(struct tile_net_priv *priv, struct sk_buff *skb,
+			      gxio_mpipe_idesc_t *idesc)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	if (unlikely(priv->stamp_cfg.rx_filter != HWTSTAMP_FILTER_NONE)) {
+		struct skb_shared_hwtstamps *shhwtstamps = skb_hwtstamps(skb);
+		memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+		shhwtstamps->hwtstamp = ktime_set(idesc->time_stamp_sec,
+						  idesc->time_stamp_ns);
+	}
+#endif
+}
+
+/* Get TX timestamp, and store it in the skb. */
+static void tile_tx_timestamp(struct sk_buff *skb, int instance)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct skb_shared_info *shtx = skb_shinfo(skb);
+	if (unlikely((shtx->tx_flags & SKBTX_HW_TSTAMP) != 0)) {
+		struct mpipe_data *md = &mpipe_data[instance];
+		struct skb_shared_hwtstamps shhwtstamps;
+		struct timespec ts;
+
+		shtx->tx_flags |= SKBTX_IN_PROGRESS;
+		gxio_mpipe_get_timestamp(&md->context, &ts);
+		memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+		shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
+		skb_tstamp_tx(skb, &shhwtstamps);
+	}
+#endif
+}
+
+/* Use ioctl() to enable or disable TX or RX timestamping. */
+static int tile_hwtstamp_ioctl(struct net_device *dev, struct ifreq *rq,
+			       int cmd)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct hwtstamp_config config;
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	if (copy_from_user(&config, rq->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	if (config.flags)  /* reserved for future extensions */
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+	case HWTSTAMP_TX_ON:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (copy_to_user(rq->ifr_data, &config, sizeof(config)))
+		return -EFAULT;
+
+	priv->stamp_cfg = config;
+	return 0;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
+
 static inline bool filter_packet(struct net_device *dev, void *buf)
 {
 	/* Filter packets received before we're up. */
@@ -453,7 +556,8 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 				 gxio_mpipe_idesc_t *idesc, unsigned long len)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	int instance = mpipe_instance(dev);
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int instance = priv->instance;
 
 	/* Encode the actual packet length. */
 	skb_put(skb, len);
@@ -464,6 +568,9 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	if (idesc->cs && idesc->csum_seed_val == 0xFFFF)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	/* Get RX timestamp from idesc. */
+	tile_rx_timestamp(priv, skb, idesc);
+
 	napi_gro_receive(&info->mpipe[instance].napi, skb);
 
 	/* Update stats. */
@@ -709,6 +816,103 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	return HRTIMER_NORESTART;
 }
 
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+
+/* PTP clock operations. */
+
+static int ptp_mpipe_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	int ret = 0;
+	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
+	mutex_lock(&md->ptp_lock);
+	if (gxio_mpipe_adjust_timestamp_freq(&md->context, ppb))
+		ret = -EINVAL;
+	mutex_unlock(&md->ptp_lock);
+	return ret;
+}
+
+static int ptp_mpipe_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	int ret = 0;
+	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
+	mutex_lock(&md->ptp_lock);
+	if (gxio_mpipe_adjust_timestamp(&md->context, delta))
+		ret = -EBUSY;
+	mutex_unlock(&md->ptp_lock);
+	return ret;
+}
+
+static int ptp_mpipe_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	int ret = 0;
+	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
+	mutex_lock(&md->ptp_lock);
+	if (gxio_mpipe_get_timestamp(&md->context, ts))
+		ret = -EBUSY;
+	mutex_unlock(&md->ptp_lock);
+	return ret;
+}
+
+static int ptp_mpipe_settime(struct ptp_clock_info *ptp,
+			     const struct timespec *ts)
+{
+	int ret = 0;
+	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
+	mutex_lock(&md->ptp_lock);
+	if (gxio_mpipe_set_timestamp(&md->context, ts))
+		ret = -EBUSY;
+	mutex_unlock(&md->ptp_lock);
+	return ret;
+}
+
+static int ptp_mpipe_enable(struct ptp_clock_info *ptp,
+			    struct ptp_clock_request *request, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+static struct ptp_clock_info ptp_mpipe_caps = {
+	.owner		= THIS_MODULE,
+	.name		= "mPIPE clock",
+	.max_adj	= 999999999,
+	.n_ext_ts	= 0,
+	.pps		= 0,
+	.adjfreq	= ptp_mpipe_adjfreq,
+	.adjtime	= ptp_mpipe_adjtime,
+	.gettime	= ptp_mpipe_gettime,
+	.settime	= ptp_mpipe_settime,
+	.enable		= ptp_mpipe_enable,
+};
+
+#endif /* CONFIG_PTP_1588_CLOCK_TILEGX */
+
+/* Sync mPIPE's timestamp up with Linux system time and register PTP clock. */
+static void register_ptp_clock(struct net_device *dev, struct mpipe_data *md)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	struct timespec ts;
+
+	getnstimeofday(&ts);
+	gxio_mpipe_set_timestamp(&md->context, &ts);
+
+	mutex_init(&md->ptp_lock);
+	md->caps = ptp_mpipe_caps;
+	md->ptp_clock = ptp_clock_register(&md->caps, NULL);
+	if (IS_ERR(md->ptp_clock))
+		netdev_err(dev, "ptp_clock_register failed %ld\n",
+			   PTR_ERR(md->ptp_clock));
+#endif
+}
+
+/* Initialize PTP fields in a new device. */
+static void init_ptp_dev(struct tile_net_priv *priv)
+{
+#ifdef CONFIG_PTP_1588_CLOCK_TILEGX
+	priv->stamp_cfg.rx_filter = HWTSTAMP_FILTER_NONE;
+	priv->stamp_cfg.tx_type = HWTSTAMP_TX_OFF;
+#endif
+}
+
 /* Helper functions for "tile_net_update()". */
 static void enable_ingress_irq(void *irq)
 {
@@ -1151,6 +1355,9 @@ static int tile_net_init_mpipe(struct net_device *dev)
 	if (rc != 0)
 		goto fail;
 
+	/* Register PTP clock and set mPIPE timestamp, if configured. */
+	register_ptp_clock(dev, md);
+
 	return 0;
 
 fail:
@@ -1852,6 +2059,9 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	for (i = 0; i < num_edescs; i++)
 		gxio_mpipe_equeue_put_at(equeue, edescs[i], slot++);
 
+	/* Store TX timestamp if needed. */
+	tile_tx_timestamp(skb, instance);
+
 	/* Add a completion record. */
 	add_comp(equeue, comps, slot - 1, skb);
 
@@ -1886,6 +2096,9 @@ static void tile_net_tx_timeout(struct net_device *dev)
 /* Ioctl commands. */
 static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
+	if (cmd == SIOCSHWTSTAMP)
+		return tile_hwtstamp_ioctl(dev, rq, cmd);
+
 	return -EOPNOTSUPP;
 }
 
@@ -1999,6 +2212,7 @@ static void tile_net_dev_init(const char *name, const uint8_t *mac)
 	priv->channel = -1;
 	priv->loopify_channel = -1;
 	priv->echannel = -1;
+	init_ptp_dev(priv);
 
 	/* Get the MAC address and set it in the device struct; this must
 	 * be done before the device is opened.  If the MAC is all zeroes,
-- 
1.8.3.1
