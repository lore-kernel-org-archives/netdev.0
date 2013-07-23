From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 06/13] tile: support jumbo frames in the tilegx network driver
Date: Tue, 23 Jul 2013 16:05:48 -0400
Message-ID: <c771786187acf6f712420dc7d604e7ad115226f3.1374609949.git.cmetcalf@tilera.com>
References: <cover.1374609948.git.cmetcalf@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1374609948.git.cmetcalf@tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/gxio/iorpc_mpipe.c         |  47 +++++
 arch/tile/gxio/mpipe.c               |  18 +-
 arch/tile/include/gxio/iorpc_mpipe.h |   4 +
 arch/tile/include/gxio/mpipe.h       | 101 +++++++++-
 drivers/net/ethernet/tile/tilegx.c   | 349 +++++++++++++++++++----------------
 5 files changed, 352 insertions(+), 167 deletions(-)

diff --git a/arch/tile/gxio/iorpc_mpipe.c b/arch/tile/gxio/iorpc_mpipe.c
index ad48e71..fb0af69 100644
--- a/arch/tile/gxio/iorpc_mpipe.c
+++ b/arch/tile/gxio/iorpc_mpipe.c
@@ -387,6 +387,27 @@ int gxio_mpipe_link_close_aux(gxio_mpipe_context_t * context, int mac)
 
 EXPORT_SYMBOL(gxio_mpipe_link_close_aux);
 
+struct link_set_attr_aux_param {
+	int mac;
+	uint32_t attr;
+	int64_t val;
+};
+
+int gxio_mpipe_link_set_attr_aux(gxio_mpipe_context_t * context, int mac,
+				 uint32_t attr, int64_t val)
+{
+	struct link_set_attr_aux_param temp;
+	struct link_set_attr_aux_param *params = &temp;
+
+	params->mac = mac;
+	params->attr = attr;
+	params->val = val;
+
+	return hv_dev_pwrite(context->fd, 0, (HV_VirtAddr) params,
+			     sizeof(*params), GXIO_MPIPE_OP_LINK_SET_ATTR_AUX);
+}
+
+EXPORT_SYMBOL(gxio_mpipe_link_set_attr_aux);
 
 struct get_timestamp_aux_param {
 	uint64_t sec;
@@ -454,6 +475,32 @@ int gxio_mpipe_adjust_timestamp_aux(gxio_mpipe_context_t * context,
 
 EXPORT_SYMBOL(gxio_mpipe_adjust_timestamp_aux);
 
+struct config_edma_ring_blks_param {
+	unsigned int ering;
+	unsigned int max_blks;
+	unsigned int min_snf_blks;
+	unsigned int db;
+};
+
+int gxio_mpipe_config_edma_ring_blks(gxio_mpipe_context_t * context,
+				     unsigned int ering, unsigned int max_blks,
+				     unsigned int min_snf_blks, unsigned int db)
+{
+	struct config_edma_ring_blks_param temp;
+	struct config_edma_ring_blks_param *params = &temp;
+
+	params->ering = ering;
+	params->max_blks = max_blks;
+	params->min_snf_blks = min_snf_blks;
+	params->db = db;
+
+	return hv_dev_pwrite(context->fd, 0, (HV_VirtAddr) params,
+			     sizeof(*params),
+			     GXIO_MPIPE_OP_CONFIG_EDMA_RING_BLKS);
+}
+
+EXPORT_SYMBOL(gxio_mpipe_config_edma_ring_blks);
+
 struct adjust_timestamp_freq_param {
 	int32_t ppb;
 };
diff --git a/arch/tile/gxio/mpipe.c b/arch/tile/gxio/mpipe.c
index e71c633..0567cf0 100644
--- a/arch/tile/gxio/mpipe.c
+++ b/arch/tile/gxio/mpipe.c
@@ -383,7 +383,7 @@ EXPORT_SYMBOL_GPL(gxio_mpipe_iqueue_init);
 
 int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 			   gxio_mpipe_context_t *context,
-			   unsigned int edma_ring_id,
+			   unsigned int ering,
 			   unsigned int channel,
 			   void *mem, unsigned int mem_size,
 			   unsigned int mem_flags)
@@ -394,7 +394,7 @@ int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 	/* Offset used to read number of completed commands. */
 	MPIPE_EDMA_POST_REGION_ADDR_t offset;
 
-	int result = gxio_mpipe_init_edma_ring(context, edma_ring_id, channel,
+	int result = gxio_mpipe_init_edma_ring(context, ering, channel,
 					       mem, mem_size, mem_flags);
 	if (result < 0)
 		return result;
@@ -405,7 +405,7 @@ int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 	offset.region =
 		MPIPE_MMIO_ADDR__REGION_VAL_EDMA -
 		MPIPE_MMIO_ADDR__REGION_VAL_IDMA;
-	offset.ring = edma_ring_id;
+	offset.ring = ering;
 
 	__gxio_dma_queue_init(&equeue->dma_queue,
 			      context->mmio_fast_base + offset.word,
@@ -413,6 +413,9 @@ int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 	equeue->edescs = mem;
 	equeue->mask_num_entries = num_entries - 1;
 	equeue->log2_num_entries = __builtin_ctz(num_entries);
+	equeue->context = context;
+	equeue->ering = ering;
+	equeue->channel = channel;
 
 	return 0;
 }
@@ -543,3 +546,12 @@ int gxio_mpipe_link_close(gxio_mpipe_link_t *link)
 }
 
 EXPORT_SYMBOL_GPL(gxio_mpipe_link_close);
+
+int gxio_mpipe_link_set_attr(gxio_mpipe_link_t *link, uint32_t attr,
+			     int64_t val)
+{
+	return gxio_mpipe_link_set_attr_aux(link->context, link->mac, attr,
+					    val);
+}
+
+EXPORT_SYMBOL_GPL(gxio_mpipe_link_set_attr);
diff --git a/arch/tile/include/gxio/iorpc_mpipe.h b/arch/tile/include/gxio/iorpc_mpipe.h
index 6961ec2..19801e4 100644
--- a/arch/tile/include/gxio/iorpc_mpipe.h
+++ b/arch/tile/include/gxio/iorpc_mpipe.h
@@ -44,10 +44,12 @@
 #define GXIO_MPIPE_OP_REGISTER_CLIENT_MEMORY IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x1210)
 #define GXIO_MPIPE_OP_LINK_OPEN_AUX    IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1211)
 #define GXIO_MPIPE_OP_LINK_CLOSE_AUX   IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1212)
+#define GXIO_MPIPE_OP_LINK_SET_ATTR_AUX IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1213)
 
 #define GXIO_MPIPE_OP_GET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121e)
 #define GXIO_MPIPE_OP_SET_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x121f)
 #define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_AUX IORPC_OPCODE(IORPC_FORMAT_NONE_NOUSER, 0x1220)
+#define GXIO_MPIPE_OP_CONFIG_EDMA_RING_BLKS IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1221)
 #define GXIO_MPIPE_OP_ADJUST_TIMESTAMP_FREQ IORPC_OPCODE(IORPC_FORMAT_NONE, 0x1222)
 #define GXIO_MPIPE_OP_ARM_POLLFD       IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9000)
 #define GXIO_MPIPE_OP_CLOSE_POLLFD     IORPC_OPCODE(IORPC_FORMAT_KERNEL_POLLFD, 0x9001)
@@ -115,6 +117,8 @@ int gxio_mpipe_link_open_aux(gxio_mpipe_context_t * context,
 
 int gxio_mpipe_link_close_aux(gxio_mpipe_context_t * context, int mac);
 
+int gxio_mpipe_link_set_attr_aux(gxio_mpipe_context_t * context, int mac,
+				 uint32_t attr, int64_t val);
 
 int gxio_mpipe_get_timestamp_aux(gxio_mpipe_context_t * context, uint64_t * sec,
 				 uint64_t * nsec, uint64_t * cycles);
diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
index 57f5ca2..6b99d35 100644
--- a/arch/tile/include/gxio/mpipe.h
+++ b/arch/tile/include/gxio/mpipe.h
@@ -810,7 +810,7 @@ extern int gxio_mpipe_alloc_edma_rings(gxio_mpipe_context_t *context,
 /* Initialize an eDMA ring, using the given memory and size.
  *
  * @param context An initialized mPIPE context.
- * @param ring The eDMA ring index.
+ * @param ering The eDMA ring index.
  * @param channel The channel to use.  This must be one of the channels
  * associated with the context's set of open links.
  * @param mem A physically contiguous region of memory to be filled
@@ -823,10 +823,37 @@ extern int gxio_mpipe_alloc_edma_rings(gxio_mpipe_context_t *context,
  * ::GXIO_ERR_INVAL_MEMORY_SIZE on failure.
  */
 extern int gxio_mpipe_init_edma_ring(gxio_mpipe_context_t *context,
-				     unsigned int ring, unsigned int channel,
+				     unsigned int ering, unsigned int channel,
 				     void *mem, size_t mem_size,
 				     unsigned int mem_flags);
 
+/* Set the "max_blks", "min_snf_blks", and "db" fields of
+ * ::MPIPE_EDMA_RG_INIT_DAT_THRESH_t for a given edma ring.
+ *
+ * The global pool of dynamic blocks will be automatically adjusted.
+ *
+ * This function should not be called after any egress has been done
+ * on the edma ring.
+ *
+ * Most applications should just use gxio_mpipe_equeue_set_snf_size().
+ *
+ * @param context An initialized mPIPE context.
+ * @param ering The eDMA ring index.
+ * @param max_blks The number of blocks to dedicate to the ring
+ * (normally min_snf_blks + 1).  Must be greater than min_snf_blocks.
+ * @param min_snf_blks The number of blocks which must be stored
+ * prior to starting to send the packet (normally 12).
+ * @param db Whether to allow use of dynamic blocks by the ring
+ * (normally 1).
+ *
+ * @return 0 on success, negative on error.
+ */
+extern int gxio_mpipe_config_edma_ring_blks(gxio_mpipe_context_t *context,
+					    unsigned int ering,
+					    unsigned int max_blks,
+					    unsigned int min_snf_blks,
+					    unsigned int db);
+
 /*****************************************************************
  *                      Classifier Program                        *
  ******************************************************************/
@@ -1288,15 +1315,39 @@ typedef struct {
 	/* The log2() of the number of entries. */
 	unsigned long log2_num_entries;
 
+	/* The context. */
+	gxio_mpipe_context_t *context;
+
+	/* The ering. */
+	unsigned int ering;
+
+	/* The channel. */
+	unsigned int channel;
+
 } gxio_mpipe_equeue_t;
 
 /* Initialize an "equeue".
  *
- * Takes the equeue plus the same args as gxio_mpipe_init_edma_ring().
+ * This function uses gxio_mpipe_init_edma_ring() to initialize the
+ * underlying edma_ring using the provided arguments.
+ *
+ * @param equeue An egress queue to be initialized.
+ * @param context An initialized mPIPE context.
+ * @param ering The eDMA ring index.
+ * @param channel The channel to use.  This must be one of the channels
+ * associated with the context's set of open links.
+ * @param mem A physically contiguous region of memory to be filled
+ * with a ring of ::gxio_mpipe_edesc_t structures.
+ * @param mem_size Number of bytes in the ring.  Must be 512, 2048,
+ * 8192 or 65536, times 16 (i.e. sizeof(gxio_mpipe_edesc_t)).
+ * @param mem_flags ::gxio_mpipe_mem_flags_e memory flags.
+ *
+ * @return 0 on success, ::GXIO_MPIPE_ERR_BAD_EDMA_RING or
+ * ::GXIO_ERR_INVAL_MEMORY_SIZE on failure.
  */
 extern int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 				  gxio_mpipe_context_t *context,
-				  unsigned int edma_ring_id,
+				  unsigned int ering,
 				  unsigned int channel,
 				  void *mem, unsigned int mem_size,
 				  unsigned int mem_flags);
@@ -1494,6 +1545,37 @@ static inline int gxio_mpipe_equeue_is_complete(gxio_mpipe_equeue_t *equeue,
 					    completion_slot, update);
 }
 
+/* Set the snf (store and forward) size for an equeue.
+ *
+ * The snf size for an equeue defaults to 1536, and encodes the size
+ * of the largest packet for which egress is guaranteed to avoid
+ * transmission underruns and/or corrupt checksums under heavy load.
+ *
+ * The snf size affects a global resource pool which cannot support,
+ * for example, all 24 equeues each requesting an snf size of 8K.
+ *
+ * To ensure that jumbo packets can be egressed properly, the snf size
+ * should be set to the size of the largest possible packet, which
+ * will usually be limited by the size of the app's largest buffer.
+ *
+ * This is a convenience wrapper around
+ * gxio_mpipe_config_edma_ring_blks().
+ *
+ * This function should not be called after any egress has been done
+ * on the equeue.
+ *
+ * @param equeue An egress queue initialized via gxio_mpipe_equeue_init().
+ * @param size The snf size, in bytes.
+ * @return Zero on success, negative error otherwise.
+ */
+static inline int gxio_mpipe_equeue_set_snf_size(gxio_mpipe_equeue_t *equeue,
+						 size_t size)
+{
+	int blks = (size + 127) / 128;
+	return gxio_mpipe_config_edma_ring_blks(equeue->context, equeue->ering,
+						blks + 1, blks, 1);
+}
+
 /*****************************************************************
  *                        Link Management                         *
  ******************************************************************/
@@ -1697,6 +1779,17 @@ static inline int gxio_mpipe_link_channel(gxio_mpipe_link_t *link)
 	return link->channel;
 }
 
+/* Set a link attribute.
+ *
+ * @param link A properly initialized link state object.
+ * @param attr An attribute from the set of @ref gxio_mpipe_link_attrs.
+ * @param val New value of the attribute.
+ * @return 0 if the attribute was successfully set, or a negative error
+ *  code.
+ */
+extern int gxio_mpipe_link_set_attr(gxio_mpipe_link_t *link, uint32_t attr,
+				    int64_t val);
+
 ///////////////////////////////////////////////////////////////////
 //                             Timestamp                         //
 ///////////////////////////////////////////////////////////////////
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index 3d4406c..8d1f748 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -76,6 +76,9 @@
 
 #define MAX_FRAGS (MAX_SKB_FRAGS + 1)
 
+/* The "kinds" of buffer stacks (small/large/jumbo). */
+#define MAX_KINDS 3
+
 /* Size of completions data to allocate.
  * ISSUE: Probably more than needed since we don't use all the channels.
  */
@@ -141,10 +144,8 @@ struct tile_net_info {
 	/* NAPI flags. */
 	bool napi_added;
 	bool napi_enabled;
-	/* Number of small sk_buffs which must still be provided. */
-	unsigned int num_needed_small_buffers;
-	/* Number of large sk_buffs which must still be provided. */
-	unsigned int num_needed_large_buffers;
+	/* Number of buffers (by kind) which must still be provided. */
+	unsigned int num_needed_buffers[MAX_KINDS];
 	/* A timer for handling egress completions. */
 	struct hrtimer egress_timer;
 	/* True if "egress_timer" is scheduled. */
@@ -200,24 +201,25 @@ static DEFINE_PER_CPU(struct tile_net_info, per_cpu_info);
 /* The "context" for all devices. */
 static gxio_mpipe_context_t context;
 
-/* Buffer sizes and mpipe enum codes for buffer stacks.
+/* The buffer size enums for each buffer stack.
  * See arch/tile/include/gxio/mpipe.h for the set of possible values.
+ * We avoid the "10384" size because it can induce "false chaining"
+ * on "cut-through" jumbo packets.
  */
-#define BUFFER_SIZE_SMALL_ENUM GXIO_MPIPE_BUFFER_SIZE_128
-#define BUFFER_SIZE_SMALL 128
-#define BUFFER_SIZE_LARGE_ENUM GXIO_MPIPE_BUFFER_SIZE_1664
-#define BUFFER_SIZE_LARGE 1664
+static gxio_mpipe_buffer_size_enum_t buffer_size_enums[MAX_KINDS] = {
+	GXIO_MPIPE_BUFFER_SIZE_128,
+	GXIO_MPIPE_BUFFER_SIZE_1664,
+	GXIO_MPIPE_BUFFER_SIZE_16384
+};
 
-/* The small/large "buffer stacks". */
-static int small_buffer_stack = -1;
-static int large_buffer_stack = -1;
+/* The actual memory allocated for the buffer stacks. */
+static void *buffer_stack_vas[MAX_KINDS];
 
-/* Amount of memory allocated for each buffer stack. */
-static size_t buffer_stack_size;
+/* The amount of memory allocated for each buffer stack. */
+static size_t buffer_stack_bytes[MAX_KINDS];
 
-/* The actual memory allocated for the buffer stacks. */
-static void *small_buffer_stack_va;
-static void *large_buffer_stack_va;
+/* The first buffer stack index (small = +0, large = +1, jumbo = +2). */
+static int first_buffer_stack = -1;
 
 /* The buckets. */
 static int first_bucket = -1;
@@ -238,6 +240,9 @@ static char *loopify_link_name;
 /* If "tile_net.custom" was specified, this is non-NULL. */
 static char *custom_str;
 
+/* If "tile_net.jumbo=NUM" was specified, this is "NUM". */
+static uint jumbo_num;
+
 /* The "tile_net.cpus" argument specifies the cpus that are dedicated
  * to handle ingress packets.
  *
@@ -292,6 +297,12 @@ MODULE_PARM_DESC(loopify, "name the device to use loop0/1 for ingress/egress");
 module_param_named(custom, custom_str, charp, 0444);
 MODULE_PARM_DESC(custom, "indicates a (heavily) customized classifier");
 
+/* The "tile_net.jumbo" argument causes us to support "jumbo" packets,
+ * and to allocate the given number of "jumbo" buffers.
+ */
+module_param_named(jumbo, jumbo_num, uint, 0444);
+MODULE_PARM_DESC(jumbo, "the number of buffers to support jumbo packets");
+
 /* Atomically update a statistics field.
  * Note that on TILE-Gx, this operation is fire-and-forget on the
  * issuing core (single-cycle dispatch) and takes only a few cycles
@@ -305,15 +316,15 @@ static void tile_net_stats_add(unsigned long value, unsigned long *field)
 }
 
 /* Allocate and push a buffer. */
-static bool tile_net_provide_buffer(bool small)
+static bool tile_net_provide_buffer(int kind)
 {
-	int stack = small ? small_buffer_stack : large_buffer_stack;
+	gxio_mpipe_buffer_size_enum_t bse = buffer_size_enums[kind];
+	size_t bs = gxio_mpipe_buffer_size_enum_to_buffer_size(bse);
 	const unsigned long buffer_alignment = 128;
 	struct sk_buff *skb;
 	int len;
 
-	len = sizeof(struct sk_buff **) + buffer_alignment;
-	len += (small ? BUFFER_SIZE_SMALL : BUFFER_SIZE_LARGE);
+	len = sizeof(struct sk_buff **) + buffer_alignment + bs;
 	skb = dev_alloc_skb(len);
 	if (skb == NULL)
 		return false;
@@ -328,7 +339,7 @@ static bool tile_net_provide_buffer(bool small)
 	/* Make sure "skb" and the back-pointer have been flushed. */
 	wmb();
 
-	gxio_mpipe_push_buffer(&context, stack,
+	gxio_mpipe_push_buffer(&context, first_buffer_stack + kind,
 			       (void *)va_to_tile_io_addr(skb->data));
 
 	return true;
@@ -369,24 +380,19 @@ static void tile_net_pop_all_buffers(int stack)
 static void tile_net_provide_needed_buffers(void)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
-
-	while (info->num_needed_small_buffers != 0) {
-		if (!tile_net_provide_buffer(true))
-			goto oops;
-		info->num_needed_small_buffers--;
-	}
-
-	while (info->num_needed_large_buffers != 0) {
-		if (!tile_net_provide_buffer(false))
-			goto oops;
-		info->num_needed_large_buffers--;
+	int kind;
+
+	for (kind = 0; kind < MAX_KINDS; kind++) {
+		while (info->num_needed_buffers[kind] != 0) {
+			if (!tile_net_provide_buffer(kind)) {
+				/* Add info to the allocation failure dump. */
+				pr_notice("Tile %d still needs some buffers\n",
+					  info->my_cpu);
+				return;
+			}
+			info->num_needed_buffers[kind]--;
+		}
 	}
-
-	return;
-
-oops:
-	/* Add a description to the page allocation failure dump. */
-	pr_notice("Tile %d still needs some buffers\n", info->my_cpu);
 }
 
 /* Get RX timestamp, and store it in the skb. */
@@ -462,10 +468,12 @@ static void tile_net_receive_skb(struct net_device *dev, struct sk_buff *skb,
 	tile_net_stats_add(len, &priv->stats.rx_bytes);
 
 	/* Need a new buffer. */
-	if (idesc->size == BUFFER_SIZE_SMALL_ENUM)
-		info->num_needed_small_buffers++;
+	if (idesc->size == buffer_size_enums[0])
+		info->num_needed_buffers[0]++;
+	else if (idesc->size == buffer_size_enums[1])
+		info->num_needed_buffers[1]++;
 	else
-		info->num_needed_large_buffers++;
+		info->num_needed_buffers[2]++;
 }
 
 /* Handle a packet.  Return true if "processed", false if "filtered". */
@@ -473,28 +481,28 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 {
 	struct tile_net_info *info = &__get_cpu_var(per_cpu_info);
 	struct net_device *dev = tile_net_devs_for_channel[idesc->channel];
+	struct tile_net_priv *priv = netdev_priv(dev);
 	uint8_t l2_offset;
 	void *va;
 	void *buf;
 	unsigned long len;
 	bool filter;
 
-	/* Drop packets for which no buffer was available.
-	 * NOTE: This happens under heavy load.
+	/* Drop packets for which no buffer was available (which can
+	 * happen under heavy load), or for which the me/tr/ce flags
+	 * are set (which can happen for jumbo cut-through packets,
+	 * or with a customized classifier).
 	 */
-	if (idesc->be) {
-		struct tile_net_priv *priv = netdev_priv(dev);
-		tile_net_stats_add(1, &priv->stats.rx_dropped);
-		gxio_mpipe_iqueue_consume(&info->iqueue, idesc);
-		if (net_ratelimit())
-			pr_info("Dropping packet (insufficient buffers).\n");
-		return false;
+	if (idesc->be || idesc->me || idesc->tr || idesc->ce) {
+		if (dev)
+			tile_net_stats_add(1, &priv->stats.rx_errors);
+		goto drop;
 	}
 
 	/* Get the "l2_offset", if allowed. */
 	l2_offset = custom_str ? 0 : gxio_mpipe_idesc_get_l2_offset(idesc);
 
-	/* Get the raw buffer VA (includes "headroom"). */
+	/* Get the VA (including NET_IP_ALIGN bytes of "headroom"). */
 	va = tile_io_addr_to_va((unsigned long)(long)idesc->va);
 
 	/* Get the actual packet start/length. */
@@ -506,7 +514,10 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 
 	filter = filter_packet(dev, buf);
 	if (filter) {
-		gxio_mpipe_iqueue_drop(&info->iqueue, idesc);
+		if (dev)
+			tile_net_stats_add(1, &priv->stats.rx_dropped);
+	drop:
+		gxio_mpipe_iqueue_drop(&info->mpipe[instance].iqueue, idesc);
 	} else {
 		struct sk_buff *skb = mpipe_buf_to_skb(va);
 
@@ -516,7 +527,7 @@ static bool tile_net_handle_packet(gxio_mpipe_idesc_t *idesc)
 		tile_net_receive_skb(dev, skb, idesc, len);
 	}
 
-	gxio_mpipe_iqueue_consume(&info->iqueue, idesc);
+	gxio_mpipe_iqueue_consume(&info->mpipe[instance].iqueue, idesc);
 	return !filter;
 }
 
@@ -758,86 +769,95 @@ static int tile_net_update(struct net_device *dev)
 	return 0;
 }
 
-/* Allocate and initialize mpipe buffer stacks, and register them in
- * the mPIPE TLBs, for both small and large packet sizes.
- * This routine supports tile_net_init_mpipe(), below.
- */
-static int init_buffer_stacks(struct net_device *dev, int num_buffers)
+/* Initialize a buffer stack. */
+static int create_buffer_stack(struct net_device *dev,
+			       int kind, size_t num_buffers)
 {
 	pte_t hash_pte = pte_set_home((pte_t) { 0 }, PAGE_HOME_HASH);
-	int rc;
+	size_t needed = gxio_mpipe_calc_buffer_stack_bytes(num_buffers);
+	int stack_idx = first_buffer_stack + kind;
+	void* va;
+	int i, rc;
 
-	/* Compute stack bytes; we round up to 64KB and then use
-	 * alloc_pages() so we get the required 64KB alignment as well.
+	/* Round up to 64KB and then use alloc_pages() so we get the
+	 * required 64KB alignment.
 	 */
-	buffer_stack_size =
-		ALIGN(gxio_mpipe_calc_buffer_stack_bytes(num_buffers),
-		      64 * 1024);
+	buffer_stack_bytes[kind] = ALIGN(needed, 64 * 1024);
 
-	/* Allocate two buffer stack indices. */
-	rc = gxio_mpipe_alloc_buffer_stacks(&context, 2, 0, 0);
-	if (rc < 0) {
-		netdev_err(dev, "gxio_mpipe_alloc_buffer_stacks failed: %d\n",
-			   rc);
-		return rc;
-	}
-	small_buffer_stack = rc;
-	large_buffer_stack = rc + 1;
-
-	/* Allocate the small memory stack. */
-	small_buffer_stack_va =
-		alloc_pages_exact(buffer_stack_size, GFP_KERNEL);
-	if (small_buffer_stack_va == NULL) {
+	va = alloc_pages_exact(buffer_stack_bytes[kind], GFP_KERNEL);
+	if (va == NULL) {
 		netdev_err(dev,
-			   "Could not alloc %zd bytes for buffer stacks\n",
-			   buffer_stack_size);
+			   "Could not alloc %zd bytes for buffer stack %d\n",
+			   buffer_stack_bytes[kind], kind);
 		return -ENOMEM;
 	}
-	rc = gxio_mpipe_init_buffer_stack(&context, small_buffer_stack,
-					  BUFFER_SIZE_SMALL_ENUM,
-					  small_buffer_stack_va,
-					  buffer_stack_size, 0);
+
+	/* Initialize the buffer stack. */
+	rc = gxio_mpipe_init_buffer_stack(&context, stack_idx,
+					  buffer_size_enums[kind],
+					  va, buffer_stack_bytes[kind], 0);
 	if (rc != 0) {
 		netdev_err(dev, "gxio_mpipe_init_buffer_stack: %d\n", rc);
+		free_pages_exact(va, buffer_stack_bytes[kind]);
 		return rc;
 	}
-	rc = gxio_mpipe_register_client_memory(&context, small_buffer_stack,
+
+	buffer_stack_vas[kind] = va;
+
+	rc = gxio_mpipe_register_client_memory(&context, stack_idx,
 					       hash_pte, 0);
 	if (rc != 0) {
-		netdev_err(dev,
-			   "gxio_mpipe_register_buffer_memory failed: %d\n",
-			   rc);
+		netdev_err(dev, "gxio_mpipe_register_client_memory: %d\n", rc);
 		return rc;
 	}
 
-	/* Allocate the large buffer stack. */
-	large_buffer_stack_va =
-		alloc_pages_exact(buffer_stack_size, GFP_KERNEL);
-	if (large_buffer_stack_va == NULL) {
-		netdev_err(dev,
-			   "Could not alloc %zd bytes for buffer stacks\n",
-			   buffer_stack_size);
-		return -ENOMEM;
-	}
-	rc = gxio_mpipe_init_buffer_stack(&context, large_buffer_stack,
-					  BUFFER_SIZE_LARGE_ENUM,
-					  large_buffer_stack_va,
-					  buffer_stack_size, 0);
-	if (rc != 0) {
-		netdev_err(dev, "gxio_mpipe_init_buffer_stack failed: %d\n",
-			   rc);
-		return rc;
+	/* Provide initial buffers. */
+	for (i = 0; i < num_buffers; i++) {
+		if (!tile_net_provide_buffer(kind)) {
+			netdev_err(dev, "Cannot allocate initial sk_bufs!\n");
+			return -ENOMEM;
+		}
 	}
-	rc = gxio_mpipe_register_client_memory(&context, large_buffer_stack,
-					       hash_pte, 0);
-	if (rc != 0) {
-		netdev_err(dev,
-			   "gxio_mpipe_register_buffer_memory failed: %d\n",
-			   rc);
+
+	return 0;
+}
+
+/* Allocate and initialize mpipe buffer stacks, and register them in
+ * the mPIPE TLBs, for small, large, and (possibly) jumbo packet sizes.
+ * This routine supports tile_net_init_mpipe(), below.
+ */
+static int init_buffer_stacks(struct net_device *dev,
+			      int network_cpus_count)
+{
+	int num_kinds = MAX_KINDS - (jumbo_num == 0);
+	size_t num_buffers;
+	int rc;
+
+	/* Allocate the buffer stacks. */
+	rc = gxio_mpipe_alloc_buffer_stacks(&context, num_kinds, 0, 0);
+	if (rc < 0) {
+		netdev_err(dev, "gxio_mpipe_alloc_buffer_stacks: %d\n", rc);
 		return rc;
 	}
+	first_buffer_stack = rc;
 
-	return 0;
+	/* Enough small/large buffers to (normally) avoid buffer errors. */
+	num_buffers =
+		network_cpus_count * (IQUEUE_ENTRIES + TILE_NET_BATCH);
+
+	/* Allocate the small memory stack. */
+	if (rc >= 0)
+		rc = create_buffer_stack(dev, 0, num_buffers);
+
+	/* Allocate the large buffer stack. */
+	if (rc >= 0)
+		rc = create_buffer_stack(dev, 1, num_buffers);
+
+	/* Allocate the jumbo buffer stack if needed. */
+	if (rc >= 0 && jumbo_num != 0)
+		rc = create_buffer_stack(dev, 2, jumbo_num);
+
+	return rc;
 }
 
 /* Allocate per-cpu resources (memory for completions and idescs).
@@ -976,13 +996,14 @@ static int tile_net_setup_interrupts(struct net_device *dev)
 /* Undo any state set up partially by a failed call to tile_net_init_mpipe. */
 static void tile_net_init_mpipe_fail(void)
 {
-	int cpu;
+	int kind, cpu;
 
 	/* Do cleanups that require the mpipe context first. */
-	if (small_buffer_stack >= 0)
-		tile_net_pop_all_buffers(small_buffer_stack);
-	if (large_buffer_stack >= 0)
-		tile_net_pop_all_buffers(large_buffer_stack);
+	for (kind = 0; kind < MAX_KINDS; kind++) {
+		if (buffer_stack_vas[kind] != NULL) {
+			tile_net_pop_all_buffers(first_buffer_stack + kind);
+		}
+	}
 
 	/* Destroy mpipe context so the hardware no longer owns any memory. */
 	gxio_mpipe_destroy(&context);
@@ -997,15 +1018,15 @@ static void tile_net_init_mpipe_fail(void)
 		info->iqueue.idescs = NULL;
 	}
 
-	if (small_buffer_stack_va)
-		free_pages_exact(small_buffer_stack_va, buffer_stack_size);
-	if (large_buffer_stack_va)
-		free_pages_exact(large_buffer_stack_va, buffer_stack_size);
+	for (kind = 0; kind < MAX_KINDS; kind++) {
+		if (buffer_stack_vas[kind] != NULL) {
+			free_pages_exact(buffer_stack_vas[kind],
+					 buffer_stack_bytes[kind]);
+			buffer_stack_vas[kind] = NULL;
+		}
+	}
 
-	small_buffer_stack_va = NULL;
-	large_buffer_stack_va = NULL;
-	large_buffer_stack = -1;
-	small_buffer_stack = -1;
+	first_buffer_stack = -1;
 	first_bucket = -1;
 }
 
@@ -1020,7 +1041,7 @@ static void tile_net_init_mpipe_fail(void)
  */
 static int tile_net_init_mpipe(struct net_device *dev)
 {
-	int i, num_buffers, rc;
+	int rc;
 	int cpu;
 	int first_ring, ring;
 	struct timespec ts;
@@ -1042,27 +1063,10 @@ static int tile_net_init_mpipe(struct net_device *dev)
 	gxio_mpipe_set_timestamp(&context, &ts);
 
 	/* Set up the buffer stacks. */
-	num_buffers =
-		network_cpus_count * (IQUEUE_ENTRIES + TILE_NET_BATCH);
-	rc = init_buffer_stacks(dev, num_buffers);
+	rc = init_buffer_stacks(dev, network_cpus_count);
 	if (rc != 0)
 		goto fail;
 
-	/* Provide initial buffers. */
-	rc = -ENOMEM;
-	for (i = 0; i < num_buffers; i++) {
-		if (!tile_net_provide_buffer(true)) {
-			netdev_err(dev, "Cannot allocate initial sk_bufs!\n");
-			goto fail;
-		}
-	}
-	for (i = 0; i < num_buffers; i++) {
-		if (!tile_net_provide_buffer(false)) {
-			netdev_err(dev, "Cannot allocate initial sk_bufs!\n");
-			goto fail;
-		}
-	}
-
 	/* Allocate one NotifRing for each network cpu. */
 	rc = gxio_mpipe_alloc_notif_rings(&context, network_cpus_count, 0, 0);
 	if (rc < 0) {
@@ -1104,13 +1108,13 @@ fail:
  */
 static int tile_net_init_egress(struct net_device *dev, int echannel)
 {
+	static int ering = -1;
 	struct page *headers_page, *edescs_page, *equeue_page;
 	gxio_mpipe_edesc_t *edescs;
 	gxio_mpipe_equeue_t *equeue;
 	unsigned char *headers;
 	int headers_order, edescs_order, equeue_order;
 	size_t edescs_size;
-	int edma;
 	int rc = -ENOMEM;
 
 	/* Only initialize once. */
@@ -1151,25 +1155,37 @@ static int tile_net_init_egress(struct net_device *dev, int echannel)
 	}
 	equeue = pfn_to_kaddr(page_to_pfn(equeue_page));
 
-	/* Allocate an edma ring.  Note that in practice this can't
-	 * fail, which is good, because we will leak an edma ring if so.
-	 */
-	rc = gxio_mpipe_alloc_edma_rings(&context, 1, 0, 0);
-	if (rc < 0) {
-		netdev_warn(dev, "gxio_mpipe_alloc_edma_rings failed: %d\n",
-			    rc);
-		goto fail_equeue;
+	/* Allocate an edma ring (using a one entry "free list"). */
+	if (ering < 0) {
+		rc = gxio_mpipe_alloc_edma_rings(&context, 1, 0, 0);
+		if (rc < 0) {
+			netdev_warn(dev, "gxio_mpipe_alloc_edma_rings: %d\n",
+				    rc);
+			goto fail_equeue;
+		}
+		ering = rc;
 	}
-	edma = rc;
 
 	/* Initialize the equeue. */
-	rc = gxio_mpipe_equeue_init(equeue, &context, edma, echannel,
+	rc = gxio_mpipe_equeue_init(equeue, &context, ering, echannel,
 				    edescs, edescs_size, 0);
 	if (rc != 0) {
 		netdev_err(dev, "gxio_mpipe_equeue_init failed: %d\n", rc);
 		goto fail_equeue;
 	}
 
+	/* Don't reuse the ering later. */
+	ering = -1;
+
+	if (jumbo_num != 0) {
+		/* Make sure "jumbo" packets can be egressed safely. */
+		if (gxio_mpipe_equeue_set_snf_size(equeue, 10368) < 0) {
+			/* ISSUE: There is no "gxio_mpipe_equeue_destroy()". */
+			netdev_warn(dev, "Jumbo packets may not be egressed"
+				    " properly on channel %d\n", echannel);
+		}
+	}
+
 	/* Done. */
 	egress_for_echannel[echannel].equeue = equeue;
 	egress_for_echannel[echannel].headers = headers;
@@ -1197,6 +1213,17 @@ static int tile_net_link_open(struct net_device *dev, gxio_mpipe_link_t *link,
 		netdev_err(dev, "Failed to open '%s'\n", link_name);
 		return rc;
 	}
+	if (jumbo_num != 0) {
+		u32 attr = GXIO_MPIPE_LINK_RECEIVE_JUMBO;
+		rc = gxio_mpipe_link_set_attr(link, attr, 1);
+		if (rc != 0) {
+			netdev_err(dev,
+				   "Cannot receive jumbo packets on '%s'\n",
+				   link_name);
+			gxio_mpipe_link_close(link);
+			return rc;
+		}
+	}
 	rc = gxio_mpipe_link_channel(link);
 	if (rc < 0 || rc >= TILE_NET_CHANNELS) {
 		netdev_err(dev, "gxio_mpipe_link_channel bad value: %d\n", rc);
@@ -1546,8 +1573,8 @@ static void tso_egress(struct net_device *dev, gxio_mpipe_equeue_t *equeue,
 	edesc_head.xfer_size = sh_len;
 
 	/* This is only used to specify the TLB. */
-	edesc_head.stack_idx = large_buffer_stack;
-	edesc_body.stack_idx = large_buffer_stack;
+	edesc_head.stack_idx = first_buffer_stack;
+	edesc_body.stack_idx = first_buffer_stack;
 
 	/* Egress all the edescs. */
 	for (segment = 0; segment < sh->gso_segs; segment++) {
@@ -1707,7 +1734,7 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	num_edescs = tile_net_tx_frags(frags, skb, data, skb_headlen(skb));
 
 	/* This is only used to specify the TLB. */
-	edesc.stack_idx = large_buffer_stack;
+	edesc.stack_idx = first_buffer_stack;
 
 	/* Prepare the edescs. */
 	for (i = 0; i < num_edescs; i++) {
@@ -1796,7 +1823,9 @@ static struct net_device_stats *tile_net_get_stats(struct net_device *dev)
 /* Change the MTU. */
 static int tile_net_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if ((new_mtu < 68) || (new_mtu > 1500))
+	if (new_mtu < 68)
+		return -EINVAL;
+	if (new_mtu > ((jumbo_num != 0) ? 9000 : 1500))
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
-- 
1.8.3.1
