From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 10/13] tile: support multiple mPIPE shims in tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <5494352daa11f4452e7003aff5d0b2d0792b0cfb.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initial driver support was for a single mPIPE shim on the chip
(as is the case for the Gx36 hardware).  The Gx72 chip has two mPIPE
shims, so we extend the driver to handle that case.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/gxio/iorpc_mpipe_info.c         |  18 +
 arch/tile/gxio/mpipe.c                    |  26 +-
 arch/tile/include/gxio/iorpc_mpipe_info.h |   4 +
 arch/tile/include/gxio/mpipe.h            |  28 ++
 arch/tile/include/hv/drv_mpipe_intf.h     |   3 +
 drivers/net/ethernet/tile/tilegx.c        | 561 ++++++++++++++++++------------
 drivers/net/ethernet/tile/tilegx_ptp.c    |  36 +-
 7 files changed, 448 insertions(+), 228 deletions(-)

diff --git a/arch/tile/gxio/iorpc_mpipe_info.c b/arch/tile/gxio/iorpc_mpipe_info.c
index d0254aa..64883aa 100644
--- a/arch/tile/gxio/iorpc_mpipe_info.c
+++ b/arch/tile/gxio/iorpc_mpipe_info.c
@@ -16,6 +16,24 @@
 #include "gxio/iorpc_mpipe_info.h"
 
 
+struct instance_aux_param {
+	_gxio_mpipe_link_name_t name;
+};
+
+int gxio_mpipe_info_instance_aux(gxio_mpipe_info_context_t * context,
+				 _gxio_mpipe_link_name_t name)
+{
+	struct instance_aux_param temp;
+	struct instance_aux_param *params = &temp;
+
+	params->name = name;
+
+	return hv_dev_pwrite(context->fd, 0, (HV_VirtAddr) params,
+			     sizeof(*params), GXIO_MPIPE_INFO_OP_INSTANCE_AUX);
+}
+
+EXPORT_SYMBOL(gxio_mpipe_info_instance_aux);
+
 struct enumerate_aux_param {
 	_gxio_mpipe_link_name_t name;
 	_gxio_mpipe_link_mac_t mac;
diff --git a/arch/tile/gxio/mpipe.c b/arch/tile/gxio/mpipe.c
index 0567cf0..665f88b 100644
--- a/arch/tile/gxio/mpipe.c
+++ b/arch/tile/gxio/mpipe.c
@@ -36,8 +36,15 @@ int gxio_mpipe_init(gxio_mpipe_context_t *context, unsigned int mpipe_index)
 	int fd;
 	int i;
 
+	if (mpipe_index >= GXIO_MPIPE_INSTANCE_MAX) {
+		return -EINVAL;
+	}
+
 	snprintf(file, sizeof(file), "mpipe/%d/iorpc", mpipe_index);
 	fd = hv_dev_open((HV_VirtAddr) file, 0);
+
+	context->fd = fd;
+
 	if (fd < 0) {
 		if (fd >= GXIO_ERR_MIN && fd <= GXIO_ERR_MAX)
 			return fd;
@@ -45,8 +52,6 @@ int gxio_mpipe_init(gxio_mpipe_context_t *context, unsigned int mpipe_index)
 			return -ENODEV;
 	}
 
-	context->fd = fd;
-
 	/* Map in the MMIO space. */
 	context->mmio_cfg_base = (void __force *)
 		iorpc_ioremap(fd, HV_MPIPE_CONFIG_MMIO_OFFSET,
@@ -64,12 +69,15 @@ int gxio_mpipe_init(gxio_mpipe_context_t *context, unsigned int mpipe_index)
 	for (i = 0; i < 8; i++)
 		context->__stacks.stacks[i] = 255;
 
+	context->instance = mpipe_index;
+
 	return 0;
 
       fast_failed:
 	iounmap((void __force __iomem *)(context->mmio_cfg_base));
       cfg_failed:
 	hv_dev_close(context->fd);
+	context->fd = -1;
 	return -ENODEV;
 }
 
@@ -496,6 +504,20 @@ static gxio_mpipe_context_t *_gxio_get_link_context(void)
 	return contextp;
 }
 
+int gxio_mpipe_link_instance(const char *link_name)
+{
+	_gxio_mpipe_link_name_t name;
+	gxio_mpipe_context_t *context = _gxio_get_link_context();
+
+	if (!context)
+		return GXIO_ERR_NO_DEVICE;
+
+	strncpy(name.name, link_name, sizeof(name.name));
+	name.name[GXIO_MPIPE_LINK_NAME_LEN - 1] = '\0';
+
+	return gxio_mpipe_info_instance_aux(context, name);
+}
+
 int gxio_mpipe_link_enumerate_mac(int idx, char *link_name, uint8_t *link_mac)
 {
 	int rv;
diff --git a/arch/tile/include/gxio/iorpc_mpipe_info.h b/arch/tile/include/gxio/iorpc_mpipe_info.h
index 0bcf3f7..476c5e5 100644
--- a/arch/tile/include/gxio/iorpc_mpipe_info.h
+++ b/arch/tile/include/gxio/iorpc_mpipe_info.h
@@ -27,11 +27,15 @@
 #include <asm/pgtable.h>
 
 
+#define GXIO_MPIPE_INFO_OP_INSTANCE_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1250)
 #define GXIO_MPIPE_INFO_OP_ENUMERATE_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1251)
 #define GXIO_MPIPE_INFO_OP_GET_MMIO_BASE IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x8000)
 #define GXIO_MPIPE_INFO_OP_CHECK_MMIO_OFFSET IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x8001)
 
 
+int gxio_mpipe_info_instance_aux(gxio_mpipe_info_context_t * context,
+				 _gxio_mpipe_link_name_t name);
+
 int gxio_mpipe_info_enumerate_aux(gxio_mpipe_info_context_t * context,
 				  unsigned int idx,
 				  _gxio_mpipe_link_name_t * name,
diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
index 6b99d35..0b1c4f6 100644
--- a/arch/tile/include/gxio/mpipe.h
+++ b/arch/tile/include/gxio/mpipe.h
@@ -220,6 +220,13 @@ typedef MPIPE_PDESC_t gxio_mpipe_idesc_t;
  */
 typedef MPIPE_EDMA_DESC_t gxio_mpipe_edesc_t;
 
+/*
+ * Max # of mpipe instances. 2 currently.
+ */
+#define GXIO_MPIPE_INSTANCE_MAX  HV_MPIPE_INSTANCE_MAX
+
+#define NR_MPIPE_MAX   GXIO_MPIPE_INSTANCE_MAX
+
 /* Get the "va" field from an "idesc".
  *
  * This is the address at which the ingress hardware copied the first
@@ -311,6 +318,9 @@ typedef struct {
 	/* File descriptor for calling up to Linux (and thus the HV). */
 	int fd;
 
+	/* Corresponding mpipe instance #. */
+	int instance;
+
 	/* The VA at which configuration registers are mapped. */
 	char *mmio_cfg_base;
 
@@ -1716,6 +1726,24 @@ typedef struct {
 	uint8_t mac;
 } gxio_mpipe_link_t;
 
+/* Translate a link name to the instance number of the mPIPE shim which is
+ *  connected to that link.  This call does not verify whether the link is
+ *  currently available, and does not reserve any link resources;
+ *  gxio_mpipe_link_open() must be called to perform those functions.
+ *
+ *  Typically applications will call this function to translate a link name
+ *  to an mPIPE instance number; call gxio_mpipe_init(), passing it that
+ *  instance number, to initialize the mPIPE shim; and then call
+ *  gxio_mpipe_link_open(), passing it the same link name plus the mPIPE
+ *  context, to configure the link.
+ *
+ * @param link_name Name of the link; see @ref gxio_mpipe_link_names.
+ * @return The mPIPE instance number which is associated with the named
+ *  link, or a negative error code (::GXIO_ERR_NO_DEVICE) if the link does
+ *  not exist.
+ */
+extern int gxio_mpipe_link_instance(const char *link_name);
+
 /* Retrieve one of this system's legal link names, and its MAC address.
  *
  * @param index Link name index.  If a system supports N legal link names,
diff --git a/arch/tile/include/hv/drv_mpipe_intf.h b/arch/tile/include/hv/drv_mpipe_intf.h
index 6cdae3b..c97e416 100644
--- a/arch/tile/include/hv/drv_mpipe_intf.h
+++ b/arch/tile/include/hv/drv_mpipe_intf.h
@@ -23,6 +23,9 @@
 #include <arch/mpipe_constants.h>
 
 
+/** Number of mPIPE instances supported */
+#define HV_MPIPE_INSTANCE_MAX   (2)
+
 /** Number of buffer stacks (32). */
 #define HV_MPIPE_NUM_BUFFER_STACKS \
   (MPIPE_MMIO_INIT_DAT_GX36_1__BUFFER_STACK_MASK_WIDTH)
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 9c128ff..18eb7b9 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -133,27 +133,31 @@ struct tile_net_tx_wake {
 
 /* Info for a specific cpu. */
 struct tile_net_info {
-	/* The NAPI struct. */
-	struct napi_struct napi;
-	/* Packet queue. */
-	gxio_mpipe_iqueue_t iqueue;
 	/* Our cpu. */
 	int my_cpu;
-	/* True if iqueue is valid. */
-	bool has_iqueue;
-	/* NAPI flags. */
-	bool napi_added;
-	bool napi_enabled;
-	/* Number of buffers (by kind) which must still be provided. */
-	unsigned int num_needed_buffers[MAX_KINDS];
 	/* A timer for handling egress completions. */
 	struct hrtimer egress_timer;
 	/* True if "egress_timer" is scheduled. */
 	bool egress_timer_scheduled;
-	/* Comps for each egress channel. */
-	struct tile_net_comps *comps_for_echannel[TILE_NET_CHANNELS];
-	/* Transmit wake timer for each egress channel. */
-	struct tile_net_tx_wake tx_wake[TILE_NET_CHANNELS];
+	struct info_mpipe {
+		/* Packet queue. */
+		gxio_mpipe_iqueue_t iqueue;
+		/* The NAPI struct. */
+		struct napi_struct napi;
+		/* Number of buffers (by kind) which must still be provided. */
+		unsigned int num_needed_buffers[MAX_KINDS];
+		/* instance id. */
+		int instance;
+		/* True if iqueue is valid. */
+		bool has_iqueue;
+		/* NAPI flags. */
+		bool napi_added;
+		bool napi_enabled;
+		/* Comps for each egress channel. */
+		struct tile_net_comps *comps_for_echannel[TILE_NET_CHANNELS];
+		/* Transmit wake timer for each egress channel. */
+		struct tile_net_tx_wake tx_wake[TILE_NET_CHANNELS];
+	} mpipe[NR_MPIPE_MAX];
 };
 
 /* Info for egress on a particular egress channel. */
@@ -178,17 +182,54 @@ struct tile_net_priv {
 	int loopify_channel;
 	/* The egress channel (channel or loopify_channel). */
 	int echannel;
+	/* mPIPE instance, 0 or 1. */
+	int instance;
 };
 
-/* Egress info, indexed by "priv->echannel" (lazily created as needed). */
-static struct tile_net_egress egress_for_echannel[TILE_NET_CHANNELS];
+static struct mpipe_data {
+	/* The ingress irq. */
+	int ingress_irq;
 
-/* Devices currently associated with each channel.
- * NOTE: The array entry can become NULL after ifconfig down, but
- * we do not free the underlying net_device structures, so it is
- * safe to use a pointer after reading it from this array.
- */
-static struct net_device *tile_net_devs_for_channel[TILE_NET_CHANNELS];
+	/* The "context" for all devices. */
+	gxio_mpipe_context_t context;
+
+	/* Egress info, indexed by "priv->echannel"
+	 * (lazily created as needed).
+	 */
+	struct tile_net_egress
+	egress_for_echannel[TILE_NET_CHANNELS];
+
+	/* Devices currently associated with each channel.
+	 * NOTE: The array entry can become NULL after ifconfig down, but
+	 * we do not free the underlying net_device structures, so it is
+	 * safe to use a pointer after reading it from this array.
+	 */
+	struct net_device
+	*tile_net_devs_for_channel[TILE_NET_CHANNELS];
+
+	/* The actual memory allocated for the buffer stacks. */
+	void *buffer_stack_vas[MAX_KINDS];
+
+	/* The amount of memory allocated for each buffer stack. */
+	size_t buffer_stack_bytes[MAX_KINDS];
+
+	/* The first buffer stack index
+	 * (small = +0, large = +1, jumbo = +2).
+	 */
+	int first_buffer_stack;
+
+	/* The buckets. */
+	int first_bucket;
+	int num_buckets;
+
+} mpipe_data[NR_MPIPE_MAX] = {
+	[0 ... (NR_MPIPE_MAX - 1)] {
+		.ingress_irq = -1,
+		.first_buffer_stack = -1,
+		.first_bucket = -1,
+		.num_buckets = 1
+	}
+};
 
 /* A mutex for "tile_net_devs_for_channel". */
 static DEFINE_MUTEX(tile_net_devs_for_channel_mutex);
@@ -196,8 +237,6 @@ static DEFINE_MUTEX(tile_net_devs_for_channel_mutex);
 /* The per-cpu info. */
 static DEFINE_PER_CPU(struct tile_net_info, per_cpu_info);
 
-/* The "context" for all devices. */
-static gxio_mpipe_context_t context;
 
 /* The buffer size enums for each buffer stack.
  * See arch/tile/include/gxio/mpipe.h for the set of possible values.
@@ -210,22 +249,6 @@ static gxio_mpipe_buffer_size_enum_t buffer_size_enums[MAX_KINDS] = {
 	GXIO_MPIPE_BUFFER_SIZE_16384
 };
 
-/* The actual memory allocated for the buffer stacks. */
-static void *buffer_stack_vas[MAX_KINDS];
-
-/* The amount of memory allocated for each buffer stack. */
-static size_t buffer_stack_bytes[MAX_KINDS];
-
-/* The first buffer stack index (small = +0, large = +1, jumbo = +2). */
-static int first_buffer_stack = -1;
-
-/* The buckets. */
-static int first_bucket = -1;
-static int num_buckets = 1;
-
-/* The ingress irq. */
-static int ingress_irq = -1;
-
 /* Text value of tile_net.cpus if passed as a module parameter. */
 static char *network_cpus_string;
 
@@ -241,6 +264,13 @@ static char *custom_str;
 /* If "tile_net.jumbo=NUM" was specified, this is "NUM". */
 static uint jumbo_num;
 
+/* Obtain mpipe instance from struct tile_net_priv given struct net_device. */
+static inline int mpipe_instance(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	return priv->instance;
+}
+
 /* The "tile_net.cpus" argument specifies the cpus that are dedicated
  * to handle ingress packets.
  *
@@ -314,8 +344,9 @@ static void tile_net_stats_add(unsigned long value, unsigned long *field)
 }
 
 /* Allocate and push a buffer. */
-static bool tile_net_provide_buffer(int kind)
+static bool tile_net_provide_buffer(int instance, int kind)
 {
+	struct mpipe_data *md = &mpipe_data[instance];
 	gxio_mpipe_buffer_size_enum_t bse = buffer_size_enums[kind];
 	size_t bs = gxio_mpipe_buffer_size_enum_to_buffer_size(bse);
 	const unsigned long buffer_alignment = 128;
@@ -337,7 +368,7 @@ static bool tile_net_provide_buffer(int kind)
 	/* Make sure "skb" and the back-pointer have been flushed. */
 	wmb();
 
-	gxio_mpipe_push_buffer(&context, first_buffer_stack + kind,
+	gxio_mpipe_push_buffer(&md->context, md->first_buffer_stack + kind,
 			       (void *)va_to_tile_io_addr(skb->data));
 
 	return true;
@@ -363,11 +394,14 @@ static struct sk_buff *mpipe_buf_to_skb(void *va)
 	return skb;
 }
 
-static void tile_net_pop_all_buffers(int stack)
+static void tile_net_pop_all_buffers(int instance, int stack)
 {
+	struct mpipe_data *md = &mpipe_data[instance];
+
 	for (;;) {
 		tile_io_addr_t addr =
-			(tile_io_addr_t)gxio_mpipe_pop_buffer(&context, stack);
+			(tile_io_addr_t)gxio_mpipe_pop_buffer(&md->context,
+							      stack);
 		if (addr == 0)
 			break;
 		dev_kfree_skb_irq(mpipe_buf_to_skb(tile_io_addr_to_va(addr)));
@@ -378,17 +412,23 @@ static void tile_net_pop_all_buffers(int stack)
 static void tile_net_provide_needed_buffers(void)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	int kind;
-
-	for (kind = 0; kind < MAX_KINDS; kind++) {
-		while (info->num_needed_buffers[kind] != 0) {
-			if (!tile_net_provide_buffer(kind)) {
-				/* Add info to the allocation failure dump. */
-				pr_notice("Tile %d still needs some buffers\n",
-					  info->my_cpu);
-				return;
+	int instance, kind;
+	for (instance = 0; instance < NR_MPIPE_MAX &&
+		     info->mpipe[instance].has_iqueue; instance++)	{
+		for (kind = 0; kind < MAX_KINDS; kind++) {
+			while (info->mpipe[instance].num_needed_buffers[kind]
+			       != 0) {
+				if (!tile_net_provide_buffer(instance, kind)) {
+					/* Add info to the allocation
+					   failure dump. */
+					pr_notice("Tile %d still needs"	\
+						  " some buffers\n",
+						  info->my_cpu);
+					return;
+				}
+				info->mpipe[instance].
+					num_needed_buffers[kind]--;
 			}
-			info->num_needed_buffers[kind]--;
 		}
 	}
 }
@@ -406,12 +446,13 @@ static void tile_rx_timestamp(struct sk_buff *skb, gxio_mpipe_idesc_t *idesc)
 }
 
 /* Get TX timestamp, and store it in the skb. */
-static void tile_tx_timestamp(struct sk_buff *skb)
+static void tile_tx_timestamp(struct sk_buff *skb, int instance)
 {
 #ifdef CONFIG_PTP_1588_CLOCK_TILEGX
 	struct skb_shared_hwtstamps shhwtstamps;
 	struct skb_shared_info *shtx;
 	struct timespec ts;
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	shtx = skb_shinfo(skb);
 	if (likely((shtx->tx_flags & SKBTX_HW_TSTAMP) == 0))
@@ -419,7 +460,7 @@ static void tile_tx_timestamp(struct sk_buff *skb)
 
 	shtx->tx_flags |= SKBTX_IN_PROGRESS;
 
-	gxio_mpipe_get_timestamp(&context, &ts);
+	gxio_mpipe_get_timestamp(&md->context, &ts);
 	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
 	shhwtstamps.hwtstamp = ktime_set(ts.tv_sec, ts.tv_nsec);
 	skb_tstamp_tx(skb, &shhwtstamps);
@@ -445,6 +486,7 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 				 gxio_mpipe_idesc_t *idesc, unsigned long len)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
+	int instance = mpipe_instance(dev);
 
 	/* Encode the actual packet length. */
 	skb_put(skb, len);
@@ -458,7 +500,7 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	/* Get RX timestamp from idesc. */
 	tile_rx_timestamp(skb, idesc);
 
-	napi_gro_receive(&info->napi, skb);
+	napi_gro_receive(&info->mpipe[instance].napi, skb);
 
 	/* Update stats. */
 	tile_net_stats_add(1, &dev->stats.rx_packets);
@@ -466,18 +508,19 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 
 	/* Need a new buffer. */
 	if (idesc->size == buffer_size_enums[0])
-		info->num_needed_buffers[0]++;
+		info->mpipe[instance].num_needed_buffers[0]++;
 	else if (idesc->size == buffer_size_enums[1])
-		info->num_needed_buffers[1]++;
+		info->mpipe[instance].num_needed_buffers[1]++;
 	else
-		info->num_needed_buffers[2]++;
+		info->mpipe[instance].num_needed_buffers[2]++;
 }
 
 /* Handle a packet.  Return true if "processed", false if "filtered". */
-static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
+static bool tile_net_handle_packet(int instance, gxio_mpipe_idesc_t *idesc)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	struct net_device *dev = tile_net_devs_for_channel[idesc->channel];
+	struct mpipe_data *md = &mpipe_data[instance];
+	struct net_device *dev = md->tile_net_devs_for_channel[idesc->channel];
 	uint8_t l2_offset;
 	void *va;
 	void *buf;
@@ -544,14 +587,20 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	unsigned int work = 0;
 	gxio_mpipe_idesc_t *idesc;
-	int i, n;
-
-	/* Process packets. */
-	while ((n = gxio_mpipe_iqueue_try_peek(&info->iqueue, &idesc)) > 0) {
+	int instance, i, n;
+	struct mpipe_data *md;
+	struct info_mpipe *info_mpipe =
+		container_of(napi, struct info_mpipe, napi);
+
+	instance = info_mpipe->instance;
+	while ((n = gxio_mpipe_iqueue_try_peek(
+			&info_mpipe->iqueue,
+			&idesc)) > 0) {
 		for (i = 0; i < n; i++) {
 			if (i == TILE_NET_BATCH)
 				goto done;
-			if (tile_net_handle_packet(idesc + i)) {
+			if (tile_net_handle_packet(instance,
+						   idesc + i)) {
 				if (++work >= budget)
 					goto done;
 			}
@@ -559,14 +608,16 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 	}
 
 	/* There are no packets left. */
-	napi_complete(&info->napi);
+	napi_complete(&info_mpipe->napi);
 
+	md = &mpipe_data[instance];
 	/* Re-enable hypervisor interrupts. */
-	gxio_mpipe_enable_notif_ring_interrupt(&context, info->iqueue.ring);
+	gxio_mpipe_enable_notif_ring_interrupt(
+		&md->context, info->mpipe[instance].iqueue.ring);
 
 	/* HACK: Avoid the "rotting packet" problem. */
-	if (gxio_mpipe_iqueue_try_peek(&info->iqueue, &idesc) > 0)
-		napi_schedule(&info->napi);
+	if (gxio_mpipe_iqueue_try_peek(&info_mpipe->iqueue, &idesc) > 0)
+		napi_schedule(&info_mpipe->napi);
 
 	/* ISSUE: Handle completions? */
 
@@ -576,11 +627,11 @@ done:
 	return work;
 }
 
-/* Handle an ingress interrupt on the current cpu. */
-static irqreturn_t tile_net_handle_ingress_irq(int irq, void *unused)
+/* Handle an ingress interrupt from an instance on the current cpu. */
+static irqreturn_t tile_net_handle_ingress_irq(int irq, void *id)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-	napi_schedule(&info->napi);
+	napi_schedule(&info->mpipe[(uint64_t)id].napi);
 	return IRQ_HANDLED;
 }
 
@@ -622,7 +673,9 @@ static void tile_net_schedule_tx_wake_timer(struct net_device *dev,
 {
 	struct tile_net_info *info = &per_cpu(per_cpu_info, tx_queue_idx);
 	struct tile_net_priv *priv = netdev_priv(dev);
-	struct tile_net_tx_wake *tx_wake = &info->tx_wake[priv->echannel];
+	int instance = priv->instance;
+	struct tile_net_tx_wake *tx_wake =
+		&info->mpipe[instance].tx_wake[priv->echannel];
 
 	hrtimer_start(&tx_wake->timer,
 		      ktime_set(0, TX_TIMER_DELAY_USEC * 1000UL),
@@ -660,7 +713,7 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	unsigned long irqflags;
 	bool pending = false;
-	int i;
+	int i, instance;
 
 	local_irq_save(irqflags);
 
@@ -668,13 +721,19 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	info->egress_timer_scheduled = false;
 
 	/* Free all possible comps for this tile. */
-	for (i = 0; i < TILE_NET_CHANNELS; i++) {
-		struct tile_net_egress *egress = &egress_for_echannel[i];
-		struct tile_net_comps *comps = info->comps_for_echannel[i];
-		if (comps->comp_last >= comps->comp_next)
-			continue;
-		tile_net_free_comps(egress->equeue, comps, -1, true);
-		pending = pending || (comps->comp_last < comps->comp_next);
+	for (instance = 0; instance < NR_MPIPE_MAX &&
+		     info->mpipe[instance].has_iqueue; instance++) {
+		for (i = 0; i < TILE_NET_CHANNELS; i++) {
+			struct tile_net_egress *egress =
+				&mpipe_data[instance].egress_for_echannel[i];
+			struct tile_net_comps *comps =
+				info->mpipe[instance].comps_for_echannel[i];
+			if (!egress || comps->comp_last >= comps->comp_next)
+				continue;
+			tile_net_free_comps(egress->equeue, comps, -1, true);
+			pending = pending ||
+				(comps->comp_last < comps->comp_next);
+		}
 	}
 
 	/* Reschedule timer if needed. */
@@ -686,13 +745,15 @@ static enum hrtimer_restart tile_net_handle_egress_timer(struct hrtimer *t)
 	return HRTIMER_NORESTART;
 }
 
-/* Helper function for "tile_net_update()". */
-static void manage_ingress_irq(void *enable)
+/* Helper functions for "tile_net_update()". */
+static void enable_ingress_irq(void *irq)
 {
-	if (enable)
-		enable_percpu_irq(ingress_irq, 0);
-	else
-		disable_percpu_irq(ingress_irq);
+	enable_percpu_irq((long)irq, 0);
+}
+
+static void disable_ingress_irq(void *irq)
+{
+	disable_percpu_irq((long)irq);
 }
 
 /* Helper function for tile_net_open() and tile_net_stop().
@@ -702,19 +763,22 @@ static int tile_net_update(struct net_device *dev)
 {
 	static gxio_mpipe_rules_t rules;  /* too big to fit on the stack */
 	bool saw_channel = false;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 	int channel;
 	int rc;
 	int cpu;
 
-	gxio_mpipe_rules_init(&rules, &context);
+	saw_channel = false;
+	gxio_mpipe_rules_init(&rules, &md->context);
 
 	for (channel = 0; channel < TILE_NET_CHANNELS; channel++) {
-		if (tile_net_devs_for_channel[channel] == NULL)
+		if (md->tile_net_devs_for_channel[channel] == NULL)
 			continue;
 		if (!saw_channel) {
 			saw_channel = true;
-			gxio_mpipe_rules_begin(&rules, first_bucket,
-					       num_buckets, NULL);
+			gxio_mpipe_rules_begin(&rules, md->first_bucket,
+					       md->num_buckets, NULL);
 			gxio_mpipe_rules_set_headroom(&rules, NET_IP_ALIGN);
 		}
 		gxio_mpipe_rules_add_channel(&rules, channel);
@@ -725,7 +789,8 @@ static int tile_net_update(struct net_device *dev)
 	 */
 	rc = gxio_mpipe_rules_commit(&rules);
 	if (rc != 0) {
-		netdev_warn(dev, "gxio_mpipe_rules_commit failed: %d\n", rc);
+		netdev_warn(dev, "gxio_mpipe_rules_commit: mpipe[%d] %d\n",
+			    instance, rc);
 		return -EIO;
 	}
 
@@ -733,35 +798,38 @@ static int tile_net_update(struct net_device *dev)
 	 * We use on_each_cpu to handle the IPI mask or unmask.
 	 */
 	if (!saw_channel)
-		on_each_cpu(manage_ingress_irq, (void *)0, 1);
+		on_each_cpu(disable_ingress_irq,
+			    (void *)(long)(md->ingress_irq), 1);
 	for_each_online_cpu(cpu) {
 		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
-		if (!info->has_iqueue)
+
+		if (!info->mpipe[instance].has_iqueue)
 			continue;
 		if (saw_channel) {
-			if (!info->napi_added) {
-				netif_napi_add(dev, &info->napi,
+			if (!info->mpipe[instance].napi_added) {
+				netif_napi_add(dev, &info->mpipe[instance].napi,
 					       tile_net_poll, TILE_NET_WEIGHT);
-				info->napi_added = true;
+				info->mpipe[instance].napi_added = true;
 			}
-			if (!info->napi_enabled) {
-				napi_enable(&info->napi);
-				info->napi_enabled = true;
+			if (!info->mpipe[instance].napi_enabled) {
+				napi_enable(&info->mpipe[instance].napi);
+				info->mpipe[instance].napi_enabled = true;
 			}
 		} else {
-			if (info->napi_enabled) {
-				napi_disable(&info->napi);
-				info->napi_enabled = false;
+			if (info->mpipe[instance].napi_enabled) {
+				napi_disable(&info->mpipe[instance].napi);
+				info->mpipe[instance].napi_enabled = false;
 			}
 			/* FIXME: Drain the iqueue. */
 		}
 	}
 	if (saw_channel)
-		on_each_cpu(manage_ingress_irq, (void *)1, 1);
+		on_each_cpu(enable_ingress_irq,
+			    (void *)(long)(md->ingress_irq), 1);
 
 	/* HACK: Allow packets to flow in the simulator. */
 	if (saw_channel)
-		sim_enable_mpipe_links(0, -1);
+		sim_enable_mpipe_links(instance, -1);
 
 	return 0;
 }
@@ -771,46 +839,52 @@ static int create_buffer_stack(struct net_device *dev,
 			       int kind, size_t num_buffers)
 {
 	pte_t hash_pte = pte_set_home((pte_t) { 0 }, PAGE_HOME_HASH);
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 	size_t needed = gxio_mpipe_calc_buffer_stack_bytes(num_buffers);
-	int stack_idx = first_buffer_stack + kind;
+	int stack_idx = md->first_buffer_stack + kind;
 	void* va;
 	int i, rc;
 
 	/* Round up to 64KB and then use alloc_pages() so we get the
 	 * required 64KB alignment.
 	 */
-	buffer_stack_bytes[kind] = ALIGN(needed, 64 * 1024);
+	md->buffer_stack_bytes[kind] =
+		ALIGN(needed, 64 * 1024);
 
-	va = alloc_pages_exact(buffer_stack_bytes[kind], GFP_KERNEL);
+	va = alloc_pages_exact(md->buffer_stack_bytes[kind], GFP_KERNEL);
 	if (va == NULL) {
 		netdev_err(dev,
 			   "Could not alloc %zd bytes for buffer stack %d\n",
-			   buffer_stack_bytes[kind], kind);
+			   md->buffer_stack_bytes[kind], kind);
 		return -ENOMEM;
 	}
 
 	/* Initialize the buffer stack. */
-	rc = gxio_mpipe_init_buffer_stack(&context, stack_idx,
-					  buffer_size_enums[kind],
-					  va, buffer_stack_bytes[kind], 0);
+	rc = gxio_mpipe_init_buffer_stack(&md->context, stack_idx,
+					  buffer_size_enums[kind],  va,
+					  md->buffer_stack_bytes[kind], 0);
 	if (rc != 0) {
-		netdev_err(dev, "gxio_mpipe_init_buffer_stack: %d\n", rc);
-		free_pages_exact(va, buffer_stack_bytes[kind]);
+		netdev_err(dev, "gxio_mpipe_init_buffer_stack: mpipe[%d] %d\n",
+			   instance, rc);
+		free_pages_exact(va, md->buffer_stack_bytes[kind]);
 		return rc;
 	}
 
-	buffer_stack_vas[kind] = va;
+	md->buffer_stack_vas[kind] = va;
 
-	rc = gxio_mpipe_register_client_memory(&context, stack_idx,
+	rc = gxio_mpipe_register_client_memory(&md->context, stack_idx,
 					       hash_pte, 0);
 	if (rc != 0) {
-		netdev_err(dev, "gxio_mpipe_register_client_memory: %d\n", rc);
+		netdev_err(dev,
+			   "gxio_mpipe_register_client_memory: mpipe[%d] %d\n",
+			   instance, rc);
 		return rc;
 	}
 
 	/* Provide initial buffers. */
 	for (i = 0; i < num_buffers; i++) {
-		if (!tile_net_provide_buffer(kind)) {
+		if (!tile_net_provide_buffer(instance, kind)) {
 			netdev_err(dev, "Cannot allocate initial sk_bufs!\n");
 			return -ENOMEM;
 		}
@@ -829,14 +903,18 @@ static int init_buffer_stacks(struct net_device *dev,
 	int num_kinds = MAX_KINDS - (jumbo_num == 0);
 	size_t num_buffers;
 	int rc;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	/* Allocate the buffer stacks. */
-	rc = gxio_mpipe_alloc_buffer_stacks(&context, num_kinds, 0, 0);
+	rc = gxio_mpipe_alloc_buffer_stacks(&md->context, num_kinds, 0, 0);
 	if (rc < 0) {
-		netdev_err(dev, "gxio_mpipe_alloc_buffer_stacks: %d\n", rc);
+		netdev_err(dev,
+			   "gxio_mpipe_alloc_buffer_stacks: mpipe[%d] %d\n",
+			   instance, rc);
 		return rc;
 	}
-	first_buffer_stack = rc;
+	md->first_buffer_stack = rc;
 
 	/* Enough small/large buffers to (normally) avoid buffer errors. */
 	num_buffers =
@@ -865,6 +943,8 @@ static int alloc_percpu_mpipe_resources(struct net_device *dev,
 {
 	struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
 	int order, i, rc;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 	struct page *page;
 	void *addr;
 
@@ -879,7 +959,7 @@ static int alloc_percpu_mpipe_resources(struct net_device *dev,
 	addr = pfn_to_kaddr(page_to_pfn(page));
 	memset(addr, 0, COMPS_SIZE);
 	for (i = 0; i < TILE_NET_CHANNELS; i++)
-		info->comps_for_echannel[i] =
+		info->mpipe[instance].comps_for_echannel[i] =
 			addr + i * sizeof(struct tile_net_comps);
 
 	/* If this is a network cpu, create an iqueue. */
@@ -893,14 +973,15 @@ static int alloc_percpu_mpipe_resources(struct net_device *dev,
 			return -ENOMEM;
 		}
 		addr = pfn_to_kaddr(page_to_pfn(page));
-		rc = gxio_mpipe_iqueue_init(&info->iqueue, &context, ring++,
-					    addr, NOTIF_RING_SIZE, 0);
+		rc = gxio_mpipe_iqueue_init(&info->mpipe[instance].iqueue,
+					    &md->context, ring++, addr,
+					    NOTIF_RING_SIZE, 0);
 		if (rc < 0) {
 			netdev_err(dev,
 				   "gxio_mpipe_iqueue_init failed: %d\n", rc);
 			return rc;
 		}
-		info->has_iqueue = true;
+		info->mpipe[instance].has_iqueue = true;
 	}
 
 	return ring;
@@ -913,40 +994,41 @@ static int init_notif_group_and_buckets(struct net_device *dev,
 					int ring, int network_cpus_count)
 {
 	int group, rc;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	/* Allocate one NotifGroup. */
-	rc = gxio_mpipe_alloc_notif_groups(&context, 1, 0, 0);
+	rc = gxio_mpipe_alloc_notif_groups(&md->context, 1, 0, 0);
 	if (rc < 0) {
-		netdev_err(dev, "gxio_mpipe_alloc_notif_groups failed: %d\n",
-			   rc);
+		netdev_err(dev, "gxio_mpipe_alloc_notif_groups: mpipe[%d] %d\n",
+			   instance, rc);
 		return rc;
 	}
 	group = rc;
 
 	/* Initialize global num_buckets value. */
 	if (network_cpus_count > 4)
-		num_buckets = 256;
+		md->num_buckets = 256;
 	else if (network_cpus_count > 1)
-		num_buckets = 16;
+		md->num_buckets = 16;
 
 	/* Allocate some buckets, and set global first_bucket value. */
-	rc = gxio_mpipe_alloc_buckets(&context, num_buckets, 0, 0);
+	rc = gxio_mpipe_alloc_buckets(&md->context, md->num_buckets, 0, 0);
 	if (rc < 0) {
-		netdev_err(dev, "gxio_mpipe_alloc_buckets failed: %d\n", rc);
+		netdev_err(dev, "gxio_mpipe_alloc_buckets: mpipe[%d] %d\n",
+			   instance, rc);
 		return rc;
 	}
-	first_bucket = rc;
+	md->first_bucket = rc;
 
 	/* Init group and buckets. */
 	rc = gxio_mpipe_init_notif_group_and_buckets(
-		&context, group, ring, network_cpus_count,
-		first_bucket, num_buckets,
+		&md->context, group, ring, network_cpus_count,
+		md->first_bucket, md->num_buckets,
 		GXIO_MPIPE_BUCKET_STICKY_FLOW_LOCALITY);
 	if (rc != 0) {
-		netdev_err(
-			dev,
-			"gxio_mpipe_init_notif_group_and_buckets failed: %d\n",
-			rc);
+		netdev_err(dev,	"gxio_mpipe_init_notif_group_and_buckets: "
+			   "mpipe[%d] %d\n", instance, rc);
 		return rc;
 	}
 
@@ -960,30 +1042,39 @@ static int init_notif_group_and_buckets(struct net_device *dev,
  */
 static int tile_net_setup_interrupts(struct net_device *dev)
 {
-	int cpu, rc;
+	int cpu, rc, irq;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
+
+	irq = md->ingress_irq;
+	if (irq < 0) {
+		irq = create_irq();
+		if (irq < 0) {
+			netdev_err(dev,
+				   "create_irq failed: mpipe[%d] %d\n",
+				   instance, irq);
+			return irq;
+		}
+		tile_irq_activate(irq, TILE_IRQ_PERCPU);
 
-	rc = create_irq();
-	if (rc < 0) {
-		netdev_err(dev, "create_irq failed: %d\n", rc);
-		return rc;
-	}
-	ingress_irq = rc;
-	tile_irq_activate(ingress_irq, TILE_IRQ_PERCPU);
-	rc = request_irq(ingress_irq, tile_net_handle_ingress_irq,
-			 0, "tile_net", NULL);
-	if (rc != 0) {
-		netdev_err(dev, "request_irq failed: %d\n", rc);
-		destroy_irq(ingress_irq);
-		ingress_irq = -1;
-		return rc;
+		rc = request_irq(irq, tile_net_handle_ingress_irq,
+				 0, "tile_net", (void *)((uint64_t)instance));
+
+		if (rc != 0) {
+			netdev_err(dev, "request_irq failed: mpipe[%d] %d\n",
+				   instance, rc);
+			destroy_irq(irq);
+			return rc;
+		}
+		md->ingress_irq = irq;
 	}
 
 	for_each_online_cpu(cpu) {
 		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
-		if (info->has_iqueue) {
-			gxio_mpipe_request_notif_ring_interrupt(
-				&context, cpu_x(cpu), cpu_y(cpu),
-				KERNEL_PL, ingress_irq, info->iqueue.ring);
+		if (info->mpipe[instance].has_iqueue) {
+			gxio_mpipe_request_notif_ring_interrupt(&md->context,
+				cpu_x(cpu), cpu_y(cpu), KERNEL_PL, irq,
+				info->mpipe[instance].iqueue.ring);
 		}
 	}
 
@@ -991,40 +1082,45 @@ static int tile_net_setup_interrupts(struct net_device *dev)
 }
 
 /* Undo any state set up partially by a failed call to tile_net_init_mpipe. */
-static void tile_net_init_mpipe_fail(void)
+static void tile_net_init_mpipe_fail(int instance)
 {
 	int kind, cpu;
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	/* Do cleanups that require the mpipe context first. */
 	for (kind = 0; kind < MAX_KINDS; kind++) {
-		if (buffer_stack_vas[kind] != NULL) {
-			tile_net_pop_all_buffers(first_buffer_stack + kind);
+		if (md->buffer_stack_vas[kind] != NULL) {
+			tile_net_pop_all_buffers(instance,
+						 md->first_buffer_stack +
+						 kind);
 		}
 	}
 
 	/* Destroy mpipe context so the hardware no longer owns any memory. */
-	gxio_mpipe_destroy(&context);
+	gxio_mpipe_destroy(&md->context);
 
 	for_each_online_cpu(cpu) {
 		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
-		free_pages((unsigned long)(info->comps_for_echannel[0]),
-			   get_order(COMPS_SIZE));
-		info->comps_for_echannel[0] = NULL;
-		free_pages((unsigned long)(info->iqueue.idescs),
+		free_pages(
+			(unsigned long)(
+				info->mpipe[instance].comps_for_echannel[0]),
+			get_order(COMPS_SIZE));
+		info->mpipe[instance].comps_for_echannel[0] = NULL;
+		free_pages((unsigned long)(info->mpipe[instance].iqueue.idescs),
 			   get_order(NOTIF_RING_SIZE));
-		info->iqueue.idescs = NULL;
+		info->mpipe[instance].iqueue.idescs = NULL;
 	}
 
 	for (kind = 0; kind < MAX_KINDS; kind++) {
-		if (buffer_stack_vas[kind] != NULL) {
-			free_pages_exact(buffer_stack_vas[kind],
-					 buffer_stack_bytes[kind]);
-			buffer_stack_vas[kind] = NULL;
+		if (md->buffer_stack_vas[kind] != NULL) {
+			free_pages_exact(md->buffer_stack_vas[kind],
+					 md->buffer_stack_bytes[kind]);
+			md->buffer_stack_vas[kind] = NULL;
 		}
 	}
 
-	first_buffer_stack = -1;
-	first_bucket = -1;
+	md->first_buffer_stack = -1;
+	md->first_bucket = -1;
 }
 
 /* The first time any tilegx network device is opened, we initialize
@@ -1042,6 +1138,8 @@ static int tile_net_init_mpipe(struct net_device *dev)
 	int cpu;
 	int first_ring, ring;
 	struct timespec ts;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 	int network_cpus_count = cpus_weight(network_cpus_map);
 
 	if (!hash_default) {
@@ -1049,15 +1147,16 @@ static int tile_net_init_mpipe(struct net_device *dev)
 		return -EIO;
 	}
 
-	rc = gxio_mpipe_init(&context, 0);
+	rc = gxio_mpipe_init(&md->context, instance);
 	if (rc != 0) {
-		netdev_err(dev, "gxio_mpipe_init failed: %d\n", rc);
+		netdev_err(dev, "gxio_mpipe_init: mpipe[%d] %d\n",
+			   instance, rc);
 		return -EIO;
 	}
 
 	/* Sync mPIPE's timestamp up with Linux system time. */
 	getnstimeofday(&ts);
-	gxio_mpipe_set_timestamp(&context, &ts);
+	gxio_mpipe_set_timestamp(&md->context, &ts);
 
 	/* Set up the buffer stacks. */
 	rc = init_buffer_stacks(dev, network_cpus_count);
@@ -1065,7 +1164,8 @@ static int tile_net_init_mpipe(struct net_device *dev)
 		goto fail;
 
 	/* Allocate one NotifRing for each network cpu. */
-	rc = gxio_mpipe_alloc_notif_rings(&context, network_cpus_count, 0, 0);
+	rc = gxio_mpipe_alloc_notif_rings(&md->context,
+					  network_cpus_count, 0, 0);
 	if (rc < 0) {
 		netdev_err(dev, "gxio_mpipe_alloc_notif_rings failed %d\n",
 			   rc);
@@ -1095,7 +1195,7 @@ static int tile_net_init_mpipe(struct net_device *dev)
 	return 0;
 
 fail:
-	tile_net_init_mpipe_fail();
+	tile_net_init_mpipe_fail(instance);
 	return rc;
 }
 
@@ -1113,9 +1213,11 @@ static int tile_net_init_egress(struct net_device *dev, int echannel)
 	int headers_order, edescs_order, equeue_order;
 	size_t edescs_size;
 	int rc = -ENOMEM;
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	/* Only initialize once. */
-	if (egress_for_echannel[echannel].equeue != NULL)
+	if (md->egress_for_echannel[echannel].equeue != NULL)
 		return 0;
 
 	/* Allocate memory for the "headers". */
@@ -1154,20 +1256,21 @@ static int tile_net_init_egress(struct net_device *dev, int echannel)
 
 	/* Allocate an edma ring (using a one entry "free list"). */
 	if (ering < 0) {
-		rc = gxio_mpipe_alloc_edma_rings(&context, 1, 0, 0);
+		rc = gxio_mpipe_alloc_edma_rings(&md->context, 1, 0, 0);
 		if (rc < 0) {
-			netdev_warn(dev, "gxio_mpipe_alloc_edma_rings: %d\n",
-				    rc);
+			netdev_warn(dev, "gxio_mpipe_alloc_edma_rings: "
+				    "mpipe[%d] %d\n", instance, rc);
 			goto fail_equeue;
 		}
 		ering = rc;
 	}
 
 	/* Initialize the equeue. */
-	rc = gxio_mpipe_equeue_init(equeue, &context, ering, echannel,
+	rc = gxio_mpipe_equeue_init(equeue, &md->context, ering, echannel,
 				    edescs, edescs_size, 0);
 	if (rc != 0) {
-		netdev_err(dev, "gxio_mpipe_equeue_init failed: %d\n", rc);
+		netdev_err(dev, "gxio_mpipe_equeue_init: mpipe[%d] %d\n",
+			   instance, rc);
 		goto fail_equeue;
 	}
 
@@ -1184,8 +1287,8 @@ static int tile_net_init_egress(struct net_device *dev, int echannel)
 	}
 
 	/* Done. */
-	egress_for_echannel[echannel].equeue = equeue;
-	egress_for_echannel[echannel].headers = headers;
+	md->egress_for_echannel[echannel].equeue = equeue;
+	md->egress_for_echannel[echannel].headers = headers;
 	return 0;
 
 fail_equeue:
@@ -1205,9 +1308,12 @@ fail:
 static int tile_net_link_open(struct net_device *dev, gxio_mpipe_link_t *link,
 			      const char *link_name)
 {
-	int rc = gxio_mpipe_link_open(link, &context, link_name, 0);
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
+	int rc = gxio_mpipe_link_open(link, &md->context, link_name, 0);
 	if (rc < 0) {
-		netdev_err(dev, "Failed to open '%s'\n", link_name);
+		netdev_err(dev, "Failed to open '%s', mpipe[%d], %d\n",
+			   link_name, instance, rc);
 		return rc;
 	}
 	if (jumbo_num != 0) {
@@ -1234,12 +1340,20 @@ static int tile_net_link_open(struct net_device *dev, gxio_mpipe_link_t *link,
 static int tile_net_open(struct net_device *dev)
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
-	int cpu, rc;
+	int cpu, rc, instance;
 
 	mutex_lock(&tile_net_devs_for_channel_mutex);
 
-	/* Do one-time initialization the first time any device is opened. */
-	if (ingress_irq < 0) {
+	/* Get the instance info. */
+	rc = gxio_mpipe_link_instance(dev->name);
+	if (rc < 0 || rc >= NR_MPIPE_MAX)
+		return -EIO;
+
+	priv->instance = rc;
+	instance = rc;
+	if (!mpipe_data[rc].context.mmio_fast_base) {
+		/* Do one-time initialization per instance the first time any
+		   device is opened. */
 		rc = tile_net_init_mpipe(dev);
 		if (rc != 0)
 			goto fail;
@@ -1270,7 +1384,7 @@ static int tile_net_open(struct net_device *dev)
 	if (rc != 0)
 		goto fail;
 
-	tile_net_devs_for_channel[priv->channel] = dev;
+	mpipe_data[instance].tile_net_devs_for_channel[priv->channel] = dev;
 
 	rc = tile_net_update(dev);
 	if (rc != 0)
@@ -1282,7 +1396,7 @@ static int tile_net_open(struct net_device *dev)
 	for_each_online_cpu(cpu) {
 		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
 		struct tile_net_tx_wake *tx_wake =
-			&info->tx_wake[priv->echannel];
+			&info->mpipe[instance].tx_wake[priv->echannel];
 
 		hrtimer_init(&tx_wake->timer, CLOCK_MONOTONIC,
 			     HRTIMER_MODE_REL);
@@ -1308,7 +1422,7 @@ fail:
 		priv->channel = -1;
 	}
 	priv->echannel = -1;
-	tile_net_devs_for_channel[priv->channel] = NULL;
+	mpipe_data[instance].tile_net_devs_for_channel[priv->channel] =	NULL;
 	mutex_unlock(&tile_net_devs_for_channel_mutex);
 
 	/* Don't return raw gxio error codes to generic Linux. */
@@ -1320,18 +1434,20 @@ static int tile_net_stop(struct net_device *dev)
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
 	int cpu;
+	int instance = priv->instance;
+	struct mpipe_data *md = &mpipe_data[instance];
 
 	for_each_online_cpu(cpu) {
 		struct tile_net_info *info = &per_cpu(per_cpu_info, cpu);
 		struct tile_net_tx_wake *tx_wake =
-			&info->tx_wake[priv->echannel];
+			&info->mpipe[instance].tx_wake[priv->echannel];
 
 		hrtimer_cancel(&tx_wake->timer);
 		netif_stop_subqueue(dev, cpu);
 	}
 
 	mutex_lock(&tile_net_devs_for_channel_mutex);
-	tile_net_devs_for_channel[priv->channel] = NULL;
+	md->tile_net_devs_for_channel[priv->channel] = NULL;
 	(void)tile_net_update(dev);
 	if (priv->loopify_channel >= 0) {
 		if (gxio_mpipe_link_close(&priv->loopify_link) != 0)
@@ -1351,7 +1467,9 @@ static int tile_net_stop(struct net_device *dev)
 
 gxio_mpipe_context_t *get_mpipe_context(int index)
 {
-	return ingress_irq < 0 ? NULL : &context;
+	if (!mpipe_data[index].context.mmio_fast_base)
+		return NULL;
+	return &mpipe_data[index].context;
 }
 EXPORT_SYMBOL_GPL(get_mpipe_context);
 
@@ -1547,6 +1665,8 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 		       struct sk_buff *skb, unsigned char *headers, s64 slot)
 {
 	struct skb_shared_info *sh = skb_shinfo(skb);
+	int instance = mpipe_instance(dev);
+	struct mpipe_data *md = &mpipe_data[instance];
 	unsigned int sh_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	unsigned int data_len = skb->len - sh_len;
 	unsigned int p_len = sh->gso_size;
@@ -1569,8 +1689,8 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 	edesc_head.xfer_size = sh_len;
 
 	/* This is only used to specify the TLB. */
-	edesc_head.stack_idx = first_buffer_stack;
-	edesc_body.stack_idx = first_buffer_stack;
+	edesc_head.stack_idx = md->first_buffer_stack;
+	edesc_body.stack_idx = md->first_buffer_stack;
 
 	/* Egress all the edescs. */
 	for (segment = 0; segment < sh->gso_segs; segment++) {
@@ -1645,8 +1765,11 @@ static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	struct tile_net_priv *priv = netdev_priv(dev);
 	int channel = priv->echannel;
-	struct tile_net_egress *egress = &egress_for_echannel[channel];
-	struct tile_net_comps *comps = info->comps_for_echannel[channel];
+	int instance = priv->instance;
+	struct mpipe_data *md = &mpipe_data[instance];
+	struct tile_net_egress *egress = &md->egress_for_echannel[channel];
+	struct tile_net_comps *comps =
+		info->mpipe[instance].comps_for_echannel[channel];
 	gxio_mpipe_equeue_t *equeue = egress->equeue;
 	unsigned long irqflags;
 	int num_edescs;
@@ -1710,10 +1833,13 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	struct tile_net_priv *priv = netdev_priv(dev);
-	struct tile_net_egress *egress = &egress_for_echannel[priv->echannel];
+	int instance = priv->instance;
+	struct mpipe_data *md = &mpipe_data[instance];
+	struct tile_net_egress *egress =
+		&md->egress_for_echannel[priv->echannel];
 	gxio_mpipe_equeue_t *equeue = egress->equeue;
 	struct tile_net_comps *comps =
-		info->comps_for_echannel[priv->echannel];
+		info->mpipe[instance].comps_for_echannel[priv->echannel];
 	unsigned int len = skb->len;
 	unsigned char *data = skb->data;
 	unsigned int num_edescs;
@@ -1730,7 +1856,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	num_edescs = tile_net_tx_frags(frags, skb, data, skb_headlen(skb));
 
 	/* This is only used to specify the TLB. */
-	edesc.stack_idx = first_buffer_stack;
+	edesc.stack_idx = md->first_buffer_stack;
 
 	/* Prepare the edescs. */
 	for (i = 0; i < num_edescs; i++) {
@@ -1764,7 +1890,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 		gxio_mpipe_equeue_put_at(equeue, edescs[i], slot++);
 
 	/* Store TX timestamp if needed. */
-	tile_tx_timestamp(skb);
+	tile_tx_timestamp(skb, instance);
 
 	/* Add a completion record. */
 	add_comp(equeue, comps, slot - 1, skb);
@@ -1846,9 +1972,13 @@ static int tile_net_set_mac_address(struct net_device *dev, void *p)
  */
 static void tile_net_netpoll(struct net_device *dev)
 {
-	disable_percpu_irq(ingress_irq);
-	tile_net_handle_ingress_irq(ingress_irq, NULL);
-	enable_percpu_irq(ingress_irq, 0);
+	int instance = mpipe_instance(dev);
+	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
+	struct mpipe_data *md = &mpipe_data[instance];
+
+	disable_percpu_irq(md->ingress_irq);
+	napi_schedule(&info->mpipe[instance].napi);
+	enable_percpu_irq(md->ingress_irq, 0);
 }
 #endif
 
@@ -1945,9 +2075,12 @@ static void tile_net_init_module_percpu(void *unused)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	int my_cpu = smp_processor_id();
+	int instance;
 
-	info->has_iqueue = false;
-
+	for (instance = 0; instance < NR_MPIPE_MAX; instance++) {
+		info->mpipe[instance].has_iqueue = false;
+		info->mpipe[instance].instance = instance;
+	}
 	info->my_cpu = my_cpu;
 
 	/* Initialize the egress timer. */
@@ -1964,6 +2097,8 @@ static int __init tile_net_init_module(void)
 
 	pr_info("Tilera Network Driver\n");
 
+	BUILD_BUG_ON(NR_MPIPE_MAX != 2);
+
 	mutex_init(&tile_net_devs_for_channel_mutex);
 
 	/* Initialize each CPU. */
diff --git a/drivers/net/ethernet/tile/tilegx_ptp.c b/drivers/net/ethernet/tile/tilegx_ptp.c
index a188463..035efcc 100644
--- a/drivers/net/ethernet/tile/tilegx_ptp.c
+++ b/drivers/net/ethernet/tile/tilegx_ptp.c
@@ -42,13 +42,14 @@ MODULE_LICENSE("GPL");
 
 
 struct mpipe_clock {
+	int index;
 	struct ptp_clock *ptp_clock;
 	gxio_mpipe_context_t *context;
 	struct ptp_clock_info caps;
 	struct mutex lock;
 };
 
-static struct mpipe_clock mpipe_clock;
+static struct mpipe_clock mpipe_clock[NR_MPIPE_MAX];
 
 extern gxio_mpipe_context_t *get_mpipe_context(int index);
 
@@ -58,7 +59,7 @@ extern gxio_mpipe_context_t *get_mpipe_context(int index);
 static inline int mpipe_context_check(struct mpipe_clock *clock)
 {
 	if (!clock->context) {
-		clock->context = get_mpipe_context(0);
+		clock->context = get_mpipe_context(clock->index);
 		if (!clock->context) {
 			pr_debug("Invalid mPIPE context.\n");
 			return -EIO;
@@ -176,23 +177,32 @@ static struct ptp_clock_info ptp_mpipe_caps = {
 
 static void __exit ptp_tilegx_exit(void)
 {
-	ptp_clock_unregister(mpipe_clock.ptp_clock);
-	mutex_destroy(&mpipe_clock.lock);
+	int i;
+
+	for (i = 0; i < NR_MPIPE_MAX; i++) {
+		ptp_clock_unregister(mpipe_clock[i].ptp_clock);
+		mutex_destroy(&mpipe_clock[i].lock);
+	}
 }
 
 
 static int __init ptp_tilegx_init(void)
 {
 	int err = 0;
-
-	mpipe_clock.context = NULL;
-	mpipe_clock.caps = ptp_mpipe_caps;
-	mutex_init(&mpipe_clock.lock);
-
-	mpipe_clock.ptp_clock = ptp_clock_register(&mpipe_clock.caps, NULL);
-	if (IS_ERR(mpipe_clock.ptp_clock)) {
-		err = PTR_ERR(mpipe_clock.ptp_clock);
-		pr_debug("Register ptp clock fail: %d\n", err);
+	int i;
+
+	for (i = 0; i < NR_MPIPE_MAX; i++) {
+		mpipe_clock[i].index = i;
+		mpipe_clock[i].context = NULL;
+		mpipe_clock[i].caps = ptp_mpipe_caps;
+		mutex_init(&mpipe_clock[i].lock);
+
+		mpipe_clock[i].ptp_clock =
+			ptp_clock_register(&mpipe_clock[i].caps, NULL);
+		if (IS_ERR(mpipe_clock[i].ptp_clock)) {
+			err = PTR_ERR(mpipe_clock[i].ptp_clock);
+			pr_debug("Register ptp clock %d fail: %d\n", i, err);
+		}
 	}
 
 	return err;
-- 
1.8.3.1
