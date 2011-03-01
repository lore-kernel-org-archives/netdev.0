From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] tile on-chip network driver: sync up with latest fixes
Date: Tue, 1 Mar 2011 12:49:53 -0500
Message-ID: <201103011935.p21JZTMq010330@farm-0010.internal.tilera.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Combine the "command" and "completion" locks into a single lock,
on each egress queue, to improve efficiency.

Support the use of 4KB pages in the "egress queue".

Delete the unused "duplicate ACK compression" code.

Filter "bad" (i.e. truncated) packets.

Avoid corrupting "dev->napi_list", by sequentializing modifications.

Deregister for incoming packets during stop, to reduce unexpected
interrupts.  Also, encourage active NAPI loops to complete before
we disable NAPI, which would otherwise crash.

Free any pending completions after shutting down LEPP.

Use a single, permanently registered, IRQ handler, to avoid situations
in which the IRQ handler was firing after being freed, and ignore any
"unexpected" interrupts.

Drop egress packets, instead of spinning, if the hardware cannot keep
up, or is disconnected.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/tile/tilepro.c |  867 +++++++++++++++++++++++---------------------
 1 files changed, 457 insertions(+), 410 deletions(-)

diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
index f901299..eb1b825 100644
--- a/drivers/net/tile/tilepro.c
+++ b/drivers/net/tile/tilepro.c
@@ -44,10 +44,6 @@
 #include <linux/tcp.h>
 
 
-/* There is no singlethread_cpu, so schedule work on the current cpu. */
-#define singlethread_cpu -1
-
-
 /*
  * First, "tile_net_init_module()" initializes all four "devices" which
  * can be used by linux.
@@ -73,15 +69,16 @@
  * return, knowing we will be called again later.  Otherwise, we
  * reenable the ingress interrupt, and call "napi_complete()".
  *
+ * HACK: Since disabling the ingress interrupt is not reliable, we
+ * ignore the interrupt if the global "active" flag is false.
+ *
  *
  * NOTE: The use of "native_driver" ensures that EPP exists, and that
- * "epp_sendv" is legal, and that "LIPP" is being used.
+ * we are using "LIPP" and "LEPP".
  *
  * NOTE: Failing to free completions for an arbitrarily long time
  * (which is defined to be illegal) does in fact cause bizarre
  * problems.  The "egress_timer" helps prevent this from happening.
- *
- * NOTE: The egress code can be interrupted by the interrupt handler.
  */
 
 
@@ -142,6 +139,7 @@
 MODULE_AUTHOR("Tilera");
 MODULE_LICENSE("GPL");
 
+
 /*
  * Queue of incoming packets for a specific cpu and device.
  *
@@ -177,7 +175,7 @@ struct tile_net_cpu {
 	struct tile_netio_queue queue;
 	/* Statistics. */
 	struct tile_net_stats_t stats;
-	/* ISSUE: Is this needed? */
+	/* True iff NAPI is enabled. */
 	bool napi_enabled;
 	/* True if this tile has succcessfully registered with the IPP. */
 	bool registered;
@@ -200,20 +198,20 @@ struct tile_net_cpu {
 struct tile_net_priv {
 	/* Our network device. */
 	struct net_device *dev;
-	/* The actual egress queue. */
-	lepp_queue_t *epp_queue;
-	/* Protects "epp_queue->cmd_tail" and "epp_queue->comp_tail" */
-	spinlock_t cmd_lock;
-	/* Protects "epp_queue->comp_head". */
-	spinlock_t comp_lock;
+	/* Pages making up the egress queue. */
+	struct page *eq_pages;
+	/* Address of the actual egress queue. */
+	lepp_queue_t *eq;
+	/* Protects "eq". */
+	spinlock_t eq_lock;
 	/* The hypervisor handle for this interface. */
 	int hv_devhdl;
 	/* The intr bit mask that IDs this device. */
 	u32 intr_id;
 	/* True iff "tile_net_open_aux()" has succeeded. */
-	int partly_opened;
-	/* True iff "tile_net_open_inner()" has succeeded. */
-	int fully_opened;
+	bool partly_opened;
+	/* True iff the device is "active". */
+	bool active;
 	/* Effective network cpus. */
 	struct cpumask network_cpus_map;
 	/* Number of network cpus. */
@@ -228,6 +226,10 @@ struct tile_net_priv {
 	struct tile_net_cpu *cpu[NR_CPUS];
 };
 
+/* Log2 of the number of small pages needed for the egress queue. */
+#define EQ_ORDER  get_order(sizeof(lepp_queue_t))
+/* Size of the egress queue's pages. */
+#define EQ_SIZE   (1 << (PAGE_SHIFT + EQ_ORDER))
 
 /*
  * The actual devices (xgbe0, xgbe1, gbe0, gbe1).
@@ -284,7 +286,11 @@ static void net_printk(char *fmt, ...)
  */
 static void dump_packet(unsigned char *data, unsigned long length, char *s)
 {
+	int my_cpu = smp_processor_id();
+
 	unsigned long i;
+	char buf[128];
+
 	static unsigned int count;
 
 	pr_info("dump_packet(data %p, length 0x%lx s %s count 0x%x)\n",
@@ -294,10 +300,12 @@ static void dump_packet(unsigned char *data, unsigned long length, char *s)
 
 	for (i = 0; i < length; i++) {
 		if ((i & 0xf) == 0)
-			sprintf(buf, "%8.8lx:", i);
+			sprintf(buf, "[%02d] %8.8lx:", my_cpu, i);
 		sprintf(buf + strlen(buf), " %2.2x", data[i]);
-		if ((i & 0xf) == 0xf || i == length - 1)
-			pr_info("%s\n", buf);
+		if ((i & 0xf) == 0xf || i == length - 1) {
+			strcat(buf, "\n");
+			pr_info("%s", buf);
+		}
 	}
 }
 #endif
@@ -356,9 +364,11 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 					   bool small)
 {
 	/* ISSUE: What should we use here? */
+	/* Without "jumbo", 2 + 1536 should be sufficient. */
 	unsigned int large_size = NET_IP_ALIGN + TILE_NET_MTU + 100;
 
-	/* Round up to ensure to avoid "false sharing" with last cache line. */
+	/* Avoid "false sharing" with last cache line. */
+	/* FIXME: This is already done by "dev_alloc_skb()". */
 	unsigned int buffer_size =
 		 (((small ? LIPP_SMALL_PACKET_SIZE : large_size) +
 		   CHIP_L2_LINE_SIZE() - 1) & -CHIP_L2_LINE_SIZE());
@@ -367,6 +377,12 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 	 * ISSUE: Since CPAs are 38 bits, and we can only encode the
 	 * high 31 bits in a "linux_buffer_t", the low 7 bits must be
 	 * zero, and thus, we must align the actual "va" mod 128.
+	 *
+	 * FIXME: We could change the underlying code to assume that
+	 * the low SIX bits are zero, and the 7th bit is one, and then
+	 * we would need to align mod 128 plus 64, which would be what
+	 * linux gives us anyway, in theory, and then we could make
+	 * LIPP_SMALL_PACKET_SIZE be 64, or maybe 196.
 	 */
 	const unsigned long align = 128;
 
@@ -375,11 +391,15 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 
 	struct sk_buff **skb_ptr;
 
-	/* Note that "dev_alloc_skb()" adds NET_SKB_PAD more bytes, */
+	/* Note that "dev_alloc_skb()" adds NET_SKB_PAD (32) more bytes, */
 	/* and also "reserves" that many bytes. */
-	/* ISSUE: Can we "share" the NET_SKB_PAD bytes with "skb_ptr"? */
+	/* ISSUE: We could "share" the NET_SKB_PAD bytes with "skb_ptr", */
+	/* but currently there is no real need, as NET_SKB_PAD is only 32. */
 	int len = sizeof(*skb_ptr) + align + buffer_size;
 
+	/* NOTE: Another 192 (256?) bytes may be used by "skb_shared_info" */
+	/* stored after the bytes.  This explains many things. */
+
 	while (1) {
 
 		/* Allocate (or fail). */
@@ -399,13 +419,24 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 		if (small)
 			break;
 
-		/* ISSUE: This has never been observed! */
 		/* Large buffers must not span a huge page. */
 		if (((((long)va & ~HPAGE_MASK) + 1535) & HPAGE_MASK) == 0)
 			break;
+		/* ISSUE: This appears to be "impossible". */
 		pr_err("Leaking unaligned linux buffer at %p.\n", va);
 	}
 
+#ifdef TILE_NET_PARANOIA
+#if CHIP_HAS_CBOX_HOME_MAP()
+	if (hash_default) {
+		HV_PTE pte = *virt_to_pte(current->mm, (unsigned long)va);
+		if (hv_pte_get_mode(pte) != HV_PTE_MODE_CACHE_HASH_L3)
+			panic("Non-HFH ingress buffer! VA=%p Mode=%d PTE=%llx",
+			      va, hv_pte_get_mode(pte), hv_pte_val(pte));
+	}
+#endif
+#endif
+
 	/* Skip two bytes to satisfy LIPP assumptions. */
 	/* Note that this aligns IP on a 16 byte boundary. */
 	/* ISSUE: Do this when the packet arrives? */
@@ -422,16 +453,6 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 	/* Make sure "skb_ptr" has been flushed. */
 	__insn_mf();
 
-#ifdef TILE_NET_PARANOIA
-#if CHIP_HAS_CBOX_HOME_MAP()
-	if (hash_default) {
-		HV_PTE pte = *virt_to_pte(current->mm, (unsigned long)va);
-		if (hv_pte_get_mode(pte) != HV_PTE_MODE_CACHE_HASH_L3)
-			panic("Non-coherent ingress buffer!");
-	}
-#endif
-#endif
-
 	/* Provide the new buffer. */
 	tile_net_provide_linux_buffer(info, va, small);
 
@@ -469,48 +490,64 @@ oops:
  * Grab some LEPP completions, and store them in "comps", of size
  * "comps_size", and return the number of completions which were
  * stored, so the caller can free them.
- *
- * If "pending" is not NULL, it will be set to true if there might
- * still be some pending completions caused by this tile, else false.
  */
-static unsigned int tile_net_lepp_grab_comps(struct net_device *dev,
+static unsigned int tile_net_lepp_grab_comps(lepp_queue_t *eq,
 					     struct sk_buff *comps[],
 					     unsigned int comps_size,
-					     bool *pending)
+					     unsigned int min_size)
 {
-	struct tile_net_priv *priv = netdev_priv(dev);
-
-	lepp_queue_t *eq = priv->epp_queue;
-
 	unsigned int n = 0;
 
-	unsigned int comp_head;
-	unsigned int comp_busy;
-	unsigned int comp_tail;
-
-	spin_lock(&priv->comp_lock);
-
-	comp_head = eq->comp_head;
-	comp_busy = eq->comp_busy;
-	comp_tail = eq->comp_tail;
+	unsigned int comp_head = eq->comp_head;
+	unsigned int comp_busy = eq->comp_busy;
 
 	while (comp_head != comp_busy && n < comps_size) {
 		comps[n++] = eq->comps[comp_head];
 		LEPP_QINC(comp_head);
 	}
 
-	if (pending != NULL)
-		*pending = (comp_head != comp_tail);
+	if (n < min_size)
+		return 0;
 
 	eq->comp_head = comp_head;
 
-	spin_unlock(&priv->comp_lock);
-
 	return n;
 }
 
 
 /*
+ * Free some comps, and return true iff there are still some pending.
+ */
+static bool tile_net_lepp_free_comps(struct net_device *dev, bool all)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	lepp_queue_t *eq = priv->eq;
+
+	struct sk_buff *olds[64];
+	unsigned int wanted = 64;
+	unsigned int i, n;
+	bool pending;
+
+	spin_lock(&priv->eq_lock);
+
+	if (all)
+		eq->comp_busy = eq->comp_tail;
+
+	n = tile_net_lepp_grab_comps(eq, olds, wanted, 0);
+
+	pending = (eq->comp_head != eq->comp_tail);
+
+	spin_unlock(&priv->eq_lock);
+
+	for (i = 0; i < n; i++)
+		kfree_skb(olds[i]);
+
+	return pending;
+}
+
+
+/*
  * Make sure the egress timer is scheduled.
  *
  * Note that we use "schedule if not scheduled" logic instead of the more
@@ -544,21 +581,11 @@ static void tile_net_handle_egress_timer(unsigned long arg)
 	struct tile_net_cpu *info = (struct tile_net_cpu *)arg;
 	struct net_device *dev = info->napi.dev;
 
-	struct sk_buff *olds[32];
-	unsigned int wanted = 32;
-	unsigned int i, nolds = 0;
-	bool pending;
-
 	/* The timer is no longer scheduled. */
 	info->egress_timer_scheduled = false;
 
-	nolds = tile_net_lepp_grab_comps(dev, olds, wanted, &pending);
-
-	for (i = 0; i < nolds; i++)
-		kfree_skb(olds[i]);
-
-	/* Reschedule timer if needed. */
-	if (pending)
+	/* Free comps, and reschedule timer if more are pending. */
+	if (tile_net_lepp_free_comps(dev, false))
 		tile_net_schedule_egress_timer(info);
 }
 
@@ -636,8 +663,39 @@ static bool is_dup_ack(char *s1, char *s2, unsigned int len)
 
 
 
+static void tile_net_discard_aux(struct tile_net_cpu *info, int index)
+{
+	struct tile_netio_queue *queue = &info->queue;
+	netio_queue_impl_t *qsp = queue->__system_part;
+	netio_queue_user_impl_t *qup = &queue->__user_part;
+
+	int index2_aux = index + sizeof(netio_pkt_t);
+	int index2 =
+		((index2_aux ==
+		  qsp->__packet_receive_queue.__last_packet_plus_one) ?
+		 0 : index2_aux);
+
+	netio_pkt_t *pkt = (netio_pkt_t *)((unsigned long) &qsp[1] + index);
+
+	/* Extract the "linux_buffer_t". */
+	unsigned int buffer = pkt->__packet.word;
+
+	/* Convert "linux_buffer_t" to "va". */
+	void *va = __va((phys_addr_t)(buffer >> 1) << 7);
+
+	/* Acquire the associated "skb". */
+	struct sk_buff **skb_ptr = va - sizeof(*skb_ptr);
+	struct sk_buff *skb = *skb_ptr;
+
+	kfree_skb(skb);
+
+	/* Consume this packet. */
+	qup->__packet_receive_read = index2;
+}
+
+
 /*
- * Like "tile_net_handle_packets()", but just discard packets.
+ * Like "tile_net_poll()", but just discard packets.
  */
 static void tile_net_discard_packets(struct net_device *dev)
 {
@@ -650,32 +708,8 @@ static void tile_net_discard_packets(struct net_device *dev)
 
 	while (qup->__packet_receive_read !=
 	       qsp->__packet_receive_queue.__packet_write) {
-
 		int index = qup->__packet_receive_read;
-
-		int index2_aux = index + sizeof(netio_pkt_t);
-		int index2 =
-			((index2_aux ==
-			  qsp->__packet_receive_queue.__last_packet_plus_one) ?
-			 0 : index2_aux);
-
-		netio_pkt_t *pkt = (netio_pkt_t *)
-			((unsigned long) &qsp[1] + index);
-
-		/* Extract the "linux_buffer_t". */
-		unsigned int buffer = pkt->__packet.word;
-
-		/* Convert "linux_buffer_t" to "va". */
-		void *va = __va((phys_addr_t)(buffer >> 1) << 7);
-
-		/* Acquire the associated "skb". */
-		struct sk_buff **skb_ptr = va - sizeof(*skb_ptr);
-		struct sk_buff *skb = *skb_ptr;
-
-		kfree_skb(skb);
-
-		/* Consume this packet. */
-		qup->__packet_receive_read = index2;
+		tile_net_discard_aux(info, index);
 	}
 }
 
@@ -704,7 +738,8 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 
 	netio_pkt_metadata_t *metadata = NETIO_PKT_METADATA(pkt);
 
-	/* Extract the packet size. */
+	/* Extract the packet size.  FIXME: Shouldn't the second line */
+	/* get subtracted?  Mostly moot, since it should be "zero". */
 	unsigned long len =
 		(NETIO_PKT_CUSTOM_LENGTH(pkt) +
 		 NET_IP_ALIGN - NETIO_PACKET_PADDING);
@@ -722,15 +757,6 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 	/* Compare to "NETIO_PKT_CUSTOM_DATA(pkt)". */
 	unsigned char *buf = va + NET_IP_ALIGN;
 
-#ifdef IGNORE_DUP_ACKS
-
-	static int other;
-	static int final;
-	static int keep;
-	static int skip;
-
-#endif
-
 	/* Invalidate the packet buffer. */
 	if (!hash_default)
 		__inv_buffer(buf, len);
@@ -745,16 +771,8 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 #ifdef TILE_NET_VERIFY_INGRESS
 	if (!NETIO_PKT_L4_CSUM_CORRECT_M(metadata, pkt) &&
 	    NETIO_PKT_L4_CSUM_CALCULATED_M(metadata, pkt)) {
-		/*
-		 * FIXME: This complains about UDP packets
-		 * with a "zero" checksum (bug 6624).
-		 */
-#ifdef TILE_NET_PANIC_ON_BAD
-		dump_packet(buf, len, "rx");
-		panic("Bad L4 checksum.");
-#else
+		/* Bug 6624: Includes UDP packets with a "zero" checksum. */
 		pr_warning("Bad L4 checksum on %d byte packet.\n", len);
-#endif
 	}
 	if (!NETIO_PKT_L3_CSUM_CORRECT_M(metadata, pkt) &&
 	    NETIO_PKT_L3_CSUM_CALCULATED_M(metadata, pkt)) {
@@ -769,24 +787,22 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		}
 		break;
 	case NETIO_PKT_STATUS_BAD:
-#ifdef TILE_NET_PANIC_ON_BAD
-		dump_packet(buf, len, "rx");
-		panic("Unexpected BAD packet.");
-#else
-		pr_warning("Unexpected BAD %d byte packet.\n", len);
-#endif
+		pr_warning("Unexpected BAD %ld byte packet.\n", len);
 	}
 #endif
 
 	filter = 0;
 
+	/* ISSUE: Filter TCP packets with "bad" checksums? */
+
 	if (!(dev->flags & IFF_UP)) {
 		/* Filter packets received before we're up. */
 		filter = 1;
+	} else if (NETIO_PKT_STATUS_M(metadata, pkt) == NETIO_PKT_STATUS_BAD) {
+		/* Filter "truncated" packets. */
+		filter = 1;
 	} else if (!(dev->flags & IFF_PROMISC)) {
-		/*
-		 * FIXME: Implement HW multicast filter.
-		 */
+		/* FIXME: Implement HW multicast filter. */
 		if (is_unicast_ether_addr(buf)) {
 			/* Filter packets not for our address. */
 			const u8 *mine = dev->dev_addr;
@@ -794,65 +810,6 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		}
 	}
 
-#ifdef IGNORE_DUP_ACKS
-
-	if (len != 66) {
-		/* FIXME: Must check "is_tcp_ack(buf, len)" somehow. */
-
-		other++;
-
-	} else if (index2 ==
-		   qsp->__packet_receive_queue.__packet_write) {
-
-		final++;
-
-	} else {
-
-		netio_pkt_t *pkt2 = (netio_pkt_t *)
-			((unsigned long) &qsp[1] + index2);
-
-		netio_pkt_metadata_t *metadata2 =
-			NETIO_PKT_METADATA(pkt2);
-
-		/* Extract the packet size. */
-		unsigned long len2 =
-			(NETIO_PKT_CUSTOM_LENGTH(pkt2) +
-			 NET_IP_ALIGN - NETIO_PACKET_PADDING);
-
-		if (len2 == 66 &&
-		    NETIO_PKT_FLOW_HASH_M(metadata, pkt) ==
-		    NETIO_PKT_FLOW_HASH_M(metadata2, pkt2)) {
-
-			/* Extract the "linux_buffer_t". */
-			unsigned int buffer2 = pkt2->__packet.word;
-
-			/* Convert "linux_buffer_t" to "va". */
-			void *va2 =
-				__va((phys_addr_t)(buffer2 >> 1) << 7);
-
-			/* Extract the packet data pointer. */
-			/* Compare to "NETIO_PKT_CUSTOM_DATA(pkt)". */
-			unsigned char *buf2 = va2 + NET_IP_ALIGN;
-
-			/* Invalidate the packet buffer. */
-			if (!hash_default)
-				__inv_buffer(buf2, len2);
-
-			if (is_dup_ack(buf, buf2, len)) {
-				skip++;
-				filter = 1;
-			} else {
-				keep++;
-			}
-		}
-	}
-
-	if (net_ratelimit())
-		pr_info("Other %d Final %d Keep %d Skip %d.\n",
-			other, final, keep, skip);
-
-#endif
-
 	if (filter) {
 
 		/* ISSUE: Update "drop" statistics? */
@@ -877,10 +834,7 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 		/* NOTE: This call also sets "skb->dev = dev". */
 		skb->protocol = eth_type_trans(skb, dev);
 
-		/* ISSUE: Discard corrupt packets? */
-		/* ISSUE: Discard packets with bad checksums? */
-
-		/* Avoid recomputing TCP/UDP checksums. */
+		/* Avoid recomputing "good" TCP/UDP checksums. */
 		if (NETIO_PKT_L4_CSUM_CORRECT_M(metadata, pkt))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
@@ -912,9 +866,14 @@ static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
 /*
  * Handle some packets for the given device on the current CPU.
  *
- * ISSUE: The "rotting packet" race condition occurs if a packet
- * arrives after the queue appears to be empty, and before the
- * hypervisor interrupt is re-enabled.
+ * If "tile_net_stop()" is called on some other tile while this
+ * function is running, we will return, hopefully before that
+ * other tile asks us to call "napi_disable()".
+ *
+ * The "rotting packet" race condition occurs if a packet arrives
+ * during the extremely narrow window between the queue appearing to
+ * be empty, and the ingress interrupt being re-enabled.  This happens
+ * a LOT under heavy network load.
  */
 static int tile_net_poll(struct napi_struct *napi, int budget)
 {
@@ -928,7 +887,7 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 
 	unsigned int work = 0;
 
-	while (1) {
+	while (priv->active) {
 		int index = qup->__packet_receive_read;
 		if (index == qsp->__packet_receive_queue.__packet_write)
 			break;
@@ -941,19 +900,24 @@ static int tile_net_poll(struct napi_struct *napi, int budget)
 
 	napi_complete(&info->napi);
 
-	/* Re-enable hypervisor interrupts. */
+	if (!priv->active)
+		goto done;
+
+	/* Re-enable the ingress interrupt. */
 	enable_percpu_irq(priv->intr_id);
 
-	/* HACK: Avoid the "rotting packet" problem. */
+	/* HACK: Avoid the "rotting packet" problem (see above). */
 	if (qup->__packet_receive_read !=
-	    qsp->__packet_receive_queue.__packet_write)
-		napi_schedule(&info->napi);
-
-	/* ISSUE: Handle completions? */
+	    qsp->__packet_receive_queue.__packet_write) {
+		/* ISSUE: Sometimes this returns zero, presumably */
+		/* because an interrupt was handled for this tile. */
+		(void)napi_reschedule(&info->napi);
+	}
 
 done:
 
-	tile_net_provide_needed_buffers(info);
+	if (priv->active)
+		tile_net_provide_needed_buffers(info);
 
 	return work;
 }
@@ -961,6 +925,12 @@ done:
 
 /*
  * Handle an ingress interrupt for the given device on the current cpu.
+ *
+ * ISSUE: Sometimes this gets called after "disable_percpu_irq()" has
+ * been called!  This is probably due to "pending hypervisor downcalls".
+ *
+ * ISSUE: Is there any race condition between the "napi_schedule()" here
+ * and the "napi_complete()" call above?
  */
 static irqreturn_t tile_net_handle_ingress_interrupt(int irq, void *dev_ptr)
 {
@@ -969,9 +939,15 @@ static irqreturn_t tile_net_handle_ingress_interrupt(int irq, void *dev_ptr)
 	int my_cpu = smp_processor_id();
 	struct tile_net_cpu *info = priv->cpu[my_cpu];
 
-	/* Disable hypervisor interrupt. */
+	/* Disable the ingress interrupt. */
 	disable_percpu_irq(priv->intr_id);
 
+	/* Ignore unwanted interrupts. */
+	if (!priv->active)
+		return IRQ_HANDLED;
+
+	/* ISSUE: Sometimes "info->napi_enabled" is false here. */
+
 	napi_schedule(&info->napi);
 
 	return IRQ_HANDLED;
@@ -1005,8 +981,7 @@ static int tile_net_open_aux(struct net_device *dev)
 	 */
 	{
 		int epp_home = hv_lotar_to_cpu(epp_lotar);
-		struct page *page = virt_to_page(priv->epp_queue);
-		homecache_change_page_home(page, 0, epp_home);
+		homecache_change_page_home(priv->eq_pages, EQ_ORDER, epp_home);
 	}
 
 	/*
@@ -1015,9 +990,9 @@ static int tile_net_open_aux(struct net_device *dev)
 	{
 		netio_ipp_address_t ea = {
 			.va = 0,
-			.pa = __pa(priv->epp_queue),
+			.pa = __pa(priv->eq),
 			.pte = hv_pte(0),
-			.size = PAGE_SIZE,
+			.size = EQ_SIZE,
 		};
 		ea.pte = hv_pte_set_lotar(ea.pte, epp_lotar);
 		ea.pte = hv_pte_set_mode(ea.pte, HV_PTE_MODE_CACHE_TILE_L3);
@@ -1043,7 +1018,7 @@ static int tile_net_open_aux(struct net_device *dev)
 
 
 /*
- * Register with hypervisor on each CPU.
+ * Register with hypervisor on the current CPU.
  *
  * Strangely, this function does important things even if it "fails",
  * which is especially common if the link is not up yet.  Hopefully
@@ -1092,7 +1067,8 @@ static void tile_net_register(void *dev_ptr)
 	priv->cpu[my_cpu] = info;
 
 	/*
-	 * Register ourselves with the IPP.
+	 * Register ourselves with LIPP.  This does a lot of stuff,
+	 * including invoking the LIPP registration code.
 	 */
 	ret = hv_dev_pwrite(priv->hv_devhdl, 0,
 			    (HV_VirtAddr)&config,
@@ -1101,8 +1077,11 @@ static void tile_net_register(void *dev_ptr)
 	PDEBUG("hv_dev_pwrite(NETIO_IPP_INPUT_REGISTER_OFF) returned %d\n",
 	       ret);
 	if (ret < 0) {
-		printk(KERN_DEBUG "hv_dev_pwrite NETIO_IPP_INPUT_REGISTER_OFF"
-		       " failure %d\n", ret);
+		if (ret != NETIO_LINK_DOWN) {
+			printk(KERN_DEBUG "hv_dev_pwrite "
+			       "NETIO_IPP_INPUT_REGISTER_OFF failure %d\n",
+			       ret);
+		}
 		info->link_down = (ret == NETIO_LINK_DOWN);
 		return;
 	}
@@ -1145,15 +1124,47 @@ static void tile_net_register(void *dev_ptr)
 			   NETIO_IPP_GET_FASTIO_OFF);
 	PDEBUG("hv_dev_pread(NETIO_IPP_GET_FASTIO_OFF) returned %d\n", ret);
 
-	netif_napi_add(dev, &info->napi, tile_net_poll, 64);
-
 	/* Now we are registered. */
 	info->registered = true;
 }
 
 
 /*
- * Unregister with hypervisor on each CPU.
+ * Deregister with hypervisor on the current CPU.
+ *
+ * This simply discards all our credits, so no more packets will be
+ * delivered to this tile.  There may still be packets in our queue.
+ *
+ * Also, disable the ingress interrupt.
+ */
+static void tile_net_deregister(void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+
+	/* Disable the ingress interrupt. */
+	disable_percpu_irq(priv->intr_id);
+
+	/* Do nothing else if not registered. */
+	if (info == NULL || !info->registered)
+		return;
+
+	{
+		struct tile_netio_queue *queue = &info->queue;
+		netio_queue_user_impl_t *qup = &queue->__user_part;
+
+		/* Discard all our credits. */
+		__netio_fastio_return_credits(qup->__fastio_index, -1);
+	}
+}
+
+
+/*
+ * Unregister with hypervisor on the current CPU.
+ *
+ * Also, disable the ingress interrupt.
  */
 static void tile_net_unregister(void *dev_ptr)
 {
@@ -1162,35 +1173,23 @@ static void tile_net_unregister(void *dev_ptr)
 	int my_cpu = smp_processor_id();
 	struct tile_net_cpu *info = priv->cpu[my_cpu];
 
-	int ret = 0;
+	int ret;
 	int dummy = 0;
 
-	/* Do nothing if never registered. */
-	if (info == NULL)
-		return;
+	/* Disable the ingress interrupt. */
+	disable_percpu_irq(priv->intr_id);
 
-	/* Do nothing if already unregistered. */
-	if (!info->registered)
+	/* Do nothing else if not registered. */
+	if (info == NULL || !info->registered)
 		return;
 
-	/*
-	 * Unregister ourselves with LIPP.
-	 */
+	/* Unregister ourselves with LIPP/LEPP. */
 	ret = hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
 			    sizeof(dummy), NETIO_IPP_INPUT_UNREGISTER_OFF);
-	PDEBUG("hv_dev_pwrite(NETIO_IPP_INPUT_UNREGISTER_OFF) returned %d\n",
-	       ret);
-	if (ret < 0) {
-		/* FIXME: Just panic? */
-		pr_err("hv_dev_pwrite NETIO_IPP_INPUT_UNREGISTER_OFF"
-		       " failure %d\n", ret);
-	}
+	if (ret < 0)
+		panic("Failed to unregister with LIPP/LEPP!\n");
 
-	/*
-	 * Discard all packets still in our NetIO queue.  Hopefully,
-	 * once the unregister call is complete, there will be no
-	 * packets still in flight on the IDN.
-	 */
+	/* Discard all packets still in our NetIO queue. */
 	tile_net_discard_packets(dev);
 
 	/* Reset state. */
@@ -1200,11 +1199,6 @@ static void tile_net_unregister(void *dev_ptr)
 	/* Cancel egress timer. */
 	del_timer(&info->egress_timer);
 	info->egress_timer_scheduled = false;
-
-	netif_napi_del(&info->napi);
-
-	/* Now we are unregistered. */
-	info->registered = false;
 }
 
 
@@ -1212,18 +1206,28 @@ static void tile_net_unregister(void *dev_ptr)
  * Helper function for "tile_net_stop()".
  *
  * Also used to handle registration failure in "tile_net_open_inner()",
- * when "fully_opened" is known to be false, and the various extra
- * steps in "tile_net_stop()" are not necessary.  ISSUE: It might be
- * simpler if we could just call "tile_net_stop()" anyway.
+ * when the various extra steps in "tile_net_stop()" are not necessary.
  */
 static void tile_net_stop_aux(struct net_device *dev)
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
+	int i;
 
 	int dummy = 0;
 
-	/* Unregister all tiles, so LIPP will stop delivering packets. */
+	/*
+	 * Unregister all tiles, so LIPP will stop delivering packets.
+	 * Also, delete all the "napi" objects (sequentially, to protect
+	 * "dev->napi_list").
+	 */
 	on_each_cpu(tile_net_unregister, (void *)dev, 1);
+	for_each_online_cpu(i) {
+		struct tile_net_cpu *info = priv->cpu[i];
+		if (info != NULL && info->registered) {
+			netif_napi_del(&info->napi);
+			info->registered = false;
+		}
+	}
 
 	/* Stop LIPP/LEPP. */
 	if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
@@ -1235,18 +1239,15 @@ static void tile_net_stop_aux(struct net_device *dev)
 
 
 /*
- * Disable ingress interrupts for the given device on the current cpu.
+ * Disable NAPI for the given device on the current cpu.
  */
-static void tile_net_disable_intr(void *dev_ptr)
+static void tile_net_stop_disable(void *dev_ptr)
 {
 	struct net_device *dev = (struct net_device *)dev_ptr;
 	struct tile_net_priv *priv = netdev_priv(dev);
 	int my_cpu = smp_processor_id();
 	struct tile_net_cpu *info = priv->cpu[my_cpu];
 
-	/* Disable hypervisor interrupt. */
-	disable_percpu_irq(priv->intr_id);
-
 	/* Disable NAPI if needed. */
 	if (info != NULL && info->napi_enabled) {
 		napi_disable(&info->napi);
@@ -1256,21 +1257,24 @@ static void tile_net_disable_intr(void *dev_ptr)
 
 
 /*
- * Enable ingress interrupts for the given device on the current cpu.
+ * Enable NAPI and the ingress interrupt for the given device
+ * on the current cpu.
+ *
+ * ISSUE: Only do this for "network cpus"?
  */
-static void tile_net_enable_intr(void *dev_ptr)
+static void tile_net_open_enable(void *dev_ptr)
 {
 	struct net_device *dev = (struct net_device *)dev_ptr;
 	struct tile_net_priv *priv = netdev_priv(dev);
 	int my_cpu = smp_processor_id();
 	struct tile_net_cpu *info = priv->cpu[my_cpu];
 
-	/* Enable hypervisor interrupt. */
-	enable_percpu_irq(priv->intr_id);
-
 	/* Enable NAPI. */
 	napi_enable(&info->napi);
 	info->napi_enabled = true;
+
+	/* Enable the ingress interrupt. */
+	enable_percpu_irq(priv->intr_id);
 }
 
 
@@ -1288,8 +1292,9 @@ static int tile_net_open_inner(struct net_device *dev)
 	int my_cpu = smp_processor_id();
 	struct tile_net_cpu *info;
 	struct tile_netio_queue *queue;
-	unsigned int irq;
+	int result = 0;
 	int i;
+	int dummy = 0;
 
 	/*
 	 * First try to register just on the local CPU, and handle any
@@ -1307,42 +1312,52 @@ static int tile_net_open_inner(struct net_device *dev)
 	/*
 	 * Now register everywhere else.  If any registration fails,
 	 * even for "link down" (which might not be possible), we
-	 * clean up using "tile_net_stop_aux()".
+	 * clean up using "tile_net_stop_aux()".  Also, add all the
+	 * "napi" objects (sequentially, to protect "dev->napi_list").
+	 * ISSUE: Only use "netif_napi_add()" for "network cpus"?
 	 */
 	smp_call_function(tile_net_register, (void *)dev, 1);
 	for_each_online_cpu(i) {
-		if (!priv->cpu[i]->registered) {
-			tile_net_stop_aux(dev);
-			return -EAGAIN;
-		}
+		struct tile_net_cpu *info = priv->cpu[i];
+		if (info->registered)
+			netif_napi_add(dev, &info->napi, tile_net_poll, 64);
+		else
+			result = -EAGAIN;
+	}
+	if (result != 0) {
+		tile_net_stop_aux(dev);
+		return result;
 	}
 
 	queue = &info->queue;
 
-	/*
-	 * Set the device intr bit mask.
-	 * The tile_net_register above sets per tile __intr_id.
-	 */
-	priv->intr_id = queue->__system_part->__intr_id;
-	BUG_ON(!priv->intr_id);
-
-	/*
-	 * Register the device interrupt handler.
-	 * The __ffs() function returns the index into the interrupt handler
-	 * table from the interrupt bit mask which should have one bit
-	 * and one bit only set.
-	 */
-	irq = __ffs(priv->intr_id);
-	tile_irq_activate(irq, TILE_IRQ_PERCPU);
-	BUG_ON(request_irq(irq, tile_net_handle_ingress_interrupt,
-			   0, dev->name, (void *)dev) != 0);
-
-	/* ISSUE: How could "priv->fully_opened" ever be "true" here? */
+	if (priv->intr_id == 0) {
+		unsigned int irq;
 
-	if (!priv->fully_opened) {
+		/*
+		 * Acquire the irq allocated by the hypervisor.  Every
+		 * queue gets the same irq.  The "__intr_id" field is
+		 * "1 << irq", so we use "__ffs()" to extract "irq".
+		 */
+		priv->intr_id = queue->__system_part->__intr_id;
+		BUG_ON(priv->intr_id == 0);
+		irq = __ffs(priv->intr_id);
 
-		int dummy = 0;
+		/*
+		 * Register the ingress interrupt handler for this
+		 * device, permanently.
+		 *
+		 * We used to call "free_irq()" in "tile_net_stop()",
+		 * and then re-register the handler here every time,
+		 * but that caused DNP errors in "handle_IRQ_event()"
+		 * because "desc->action" was NULL.  See bug 9143.
+		 */
+		tile_irq_activate(irq, TILE_IRQ_PERCPU);
+		BUG_ON(request_irq(irq, tile_net_handle_ingress_interrupt,
+				   0, dev->name, (void *)dev) != 0);
+	}
 
+	{
 		/* Allocate initial buffers. */
 
 		int max_buffers =
@@ -1359,18 +1374,21 @@ static int tile_net_open_inner(struct net_device *dev)
 		if (info->num_needed_small_buffers != 0 ||
 		    info->num_needed_large_buffers != 0)
 			panic("Insufficient memory for buffer stack!");
+	}
 
-		/* Start LIPP/LEPP and activate "ingress" at the shim. */
-		if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
-				  sizeof(dummy), NETIO_IPP_INPUT_INIT_OFF) < 0)
-			panic("Failed to activate the LIPP Shim!\n");
+	/* We are about to be active. */
+	priv->active = true;
 
-		priv->fully_opened = 1;
-	}
+	/* Make sure "active" is visible to all tiles. */
+	mb();
 
-	/* On each tile, enable the hypervisor to trigger interrupts. */
-	/* ISSUE: Do this before starting LIPP/LEPP? */
-	on_each_cpu(tile_net_enable_intr, (void *)dev, 1);
+	/* On each tile, enable NAPI and the ingress interrupt. */
+	on_each_cpu(tile_net_open_enable, (void *)dev, 1);
+
+	/* Start LIPP/LEPP and activate "ingress" at the shim. */
+	if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
+			  sizeof(dummy), NETIO_IPP_INPUT_INIT_OFF) < 0)
+		panic("Failed to activate the LIPP Shim!\n");
 
 	/* Start our transmit queue. */
 	netif_start_queue(dev);
@@ -1396,9 +1414,9 @@ static void tile_net_open_retry(struct work_struct *w)
 	 * ourselves to try again later; otherwise, tell Linux we now have
 	 * a working link.  ISSUE: What if the return value is negative?
 	 */
-	if (tile_net_open_inner(priv->dev))
-		schedule_delayed_work_on(singlethread_cpu, &priv->retry_work,
-					 TILE_NET_RETRY_INTERVAL);
+	if (tile_net_open_inner(priv->dev) != 0)
+		schedule_delayed_work(&priv->retry_work,
+				      TILE_NET_RETRY_INTERVAL);
 	else
 		netif_carrier_on(priv->dev);
 }
@@ -1412,8 +1430,8 @@ static void tile_net_open_retry(struct work_struct *w)
  * The open entry point is called when a network interface is made
  * active by the system (IFF_UP).  At this point all resources needed
  * for transmit and receive operations are allocated, the interrupt
- * handler is registered with the OS, the watchdog timer is started,
- * and the stack is notified that the interface is ready.
+ * handler is registered with the OS (if needed), the watchdog timer
+ * is started, and the stack is notified that the interface is ready.
  *
  * If the actual link is not available yet, then we tell Linux that
  * we have no carrier, and we keep checking until the link comes up.
@@ -1468,6 +1486,10 @@ static int tile_net_open(struct net_device *dev)
 #endif
 
 		priv->partly_opened = 1;
+
+	} else {
+		/* FIXME: Is this possible? */
+		/* printk("Already partly opened.\n"); */
 	}
 
 	/*
@@ -1487,57 +1509,17 @@ static int tile_net_open(struct net_device *dev)
 	 * and then remember to try again later.
 	 */
 	netif_carrier_off(dev);
-	schedule_delayed_work_on(singlethread_cpu, &priv->retry_work,
-				 TILE_NET_RETRY_INTERVAL);
+	schedule_delayed_work(&priv->retry_work, TILE_NET_RETRY_INTERVAL);
 
 	return 0;
 }
 
 
-/*
- * Disables a network interface.
- *
- * Returns 0, this is not allowed to fail.
- *
- * The close entry point is called when an interface is de-activated
- * by the OS.  The hardware is still under the drivers control, but
- * needs to be disabled.  A global MAC reset is issued to stop the
- * hardware, and all transmit and receive resources are freed.
- *
- * ISSUE: Can this can be called while "tile_net_poll()" is running?
- */
-static int tile_net_stop(struct net_device *dev)
+static int tile_net_drain_lipp_buffers(struct tile_net_priv *priv)
 {
-	struct tile_net_priv *priv = netdev_priv(dev);
-
-	bool pending = true;
-
-	PDEBUG("tile_net_stop()\n");
-
-	/* ISSUE: Only needed if not yet fully open. */
-	cancel_delayed_work_sync(&priv->retry_work);
-
-	/* Can't transmit any more. */
-	netif_stop_queue(dev);
-
-	/*
-	 * Disable hypervisor interrupts on each tile.
-	 */
-	on_each_cpu(tile_net_disable_intr, (void *)dev, 1);
-
-	/*
-	 * Unregister the interrupt handler.
-	 * The __ffs() function returns the index into the interrupt handler
-	 * table from the interrupt bit mask which should have one bit
-	 * and one bit only set.
-	 */
-	if (priv->intr_id)
-		free_irq(__ffs(priv->intr_id), dev);
-
-	/*
-	 * Drain all the LIPP buffers.
-	 */
+	int n = 0;
 
+	/* Drain all the LIPP buffers. */
 	while (true) {
 		int buffer;
 
@@ -1560,43 +1542,105 @@ static int tile_net_stop(struct net_device *dev)
 
 			kfree_skb(skb);
 		}
+
+		n++;
 	}
 
-	/* Stop LIPP/LEPP. */
-	tile_net_stop_aux(dev);
+	return n;
+}
+
+
+/*
+ * Disables a network interface.
+ *
+ * Returns 0, this is not allowed to fail.
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ *
+ * ISSUE: How closely does "netif_running(dev)" mirror "priv->active"?
+ *
+ * Before we are called by "__dev_close()", "netif_running()" will
+ * have been cleared, so no NEW calls to "tile_net_poll()" will be
+ * made by "netpoll_poll_dev()".
+ *
+ * Often, this can cause some tiles to still have packets in their
+ * queues, so we must call "tile_net_discard_packets()" later.
+ *
+ * Note that some other tile may still be INSIDE "tile_net_poll()",
+ * and in fact, many will be, if there is heavy network load.
+ *
+ * Calling "on_each_cpu(tile_net_stop_disable, (void *)dev, 1)" when
+ * any tile is still "napi_schedule()"'d will induce a horrible crash
+ * when "msleep()" is called.  This includes tiles which are inside
+ * "tile_net_poll()" which have not yet called "napi_complete()".
+ *
+ * So, we must first try to wait long enough for other tiles to finish
+ * with any current "tile_net_poll()" call, and, hopefully, to clear
+ * the "scheduled" flag.  ISSUE: It is unclear what happens to tiles
+ * which have called "napi_schedule()" but which had not yet tried to
+ * call "tile_net_poll()", or which exhausted their budget inside
+ * "tile_net_poll()" just before this function was called.
+ */
+static int tile_net_stop(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
 
+	PDEBUG("tile_net_stop()\n");
 
-	priv->fully_opened = 0;
+	/* Start discarding packets. */
+	priv->active = false;
 
+	/* Make sure "active" is visible to all tiles. */
+	mb();
 
 	/*
-	 * XXX: ISSUE: It appears that, in practice anyway, by the
-	 * time we get here, there are no pending completions.
+	 * On each tile, make sure no NEW packets get delivered, and
+	 * disable the ingress interrupt.
+	 *
+	 * Note that the ingress interrupt can fire AFTER this,
+	 * presumably due to packets which were recently delivered,
+	 * but it will have no effect.
 	 */
-	while (pending) {
+	on_each_cpu(tile_net_deregister, (void *)dev, 1);
 
-		struct sk_buff *olds[32];
-		unsigned int wanted = 32;
-		unsigned int i, nolds = 0;
+	/* Optimistically drain LIPP buffers. */
+	(void)tile_net_drain_lipp_buffers(priv);
 
-		nolds = tile_net_lepp_grab_comps(dev, olds,
-						 wanted, &pending);
+	/* ISSUE: Only needed if not yet fully open. */
+	cancel_delayed_work_sync(&priv->retry_work);
 
-		/* ISSUE: We have never actually seen this debug spew. */
-		if (nolds != 0)
-			pr_info("During tile_net_stop(), grabbed %d comps.\n",
-			       nolds);
+	/* Can't transmit any more. */
+	netif_stop_queue(dev);
 
-		for (i = 0; i < nolds; i++)
-			kfree_skb(olds[i]);
-	}
+	/* Disable NAPI on each tile. */
+	on_each_cpu(tile_net_stop_disable, (void *)dev, 1);
 
+	/*
+	 * Drain any remaining LIPP buffers.  NOTE: This "printk()"
+	 * has never been observed, but in theory it could happen.
+	 */
+	if (tile_net_drain_lipp_buffers(priv) != 0)
+		printk("Had to drain some extra LIPP buffers!\n");
+
+	/* Stop LIPP/LEPP. */
+	tile_net_stop_aux(dev);
+
+	/*
+	 * ISSUE: It appears that, in practice anyway, by the time we
+	 * get here, there are no pending completions, but just in case,
+	 * we free (all of) them anyway.
+	 */
+	while (tile_net_lepp_free_comps(dev, true))
+		/* loop */;
 
 	/* Wipe the EPP queue. */
-	memset(priv->epp_queue, 0, sizeof(lepp_queue_t));
+	memset(priv->eq, 0, sizeof(lepp_queue_t));
 
 	/* Evict the EPP queue. */
-	finv_buffer(priv->epp_queue, PAGE_SIZE);
+	finv_buffer(priv->eq, EQ_SIZE);
 
 	return 0;
 }
@@ -1742,17 +1786,15 @@ static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
 
 	unsigned long irqflags;
 
-	lepp_queue_t *eq = priv->epp_queue;
+	lepp_queue_t *eq = priv->eq;
 
-	struct sk_buff *olds[4];
-	unsigned int wanted = 4;
+	struct sk_buff *olds[8];
+	unsigned int wanted = 8;
 	unsigned int i, nolds = 0;
 
 	unsigned int cmd_head, cmd_tail, cmd_next;
 	unsigned int comp_tail;
 
-	unsigned int free_slots;
-
 
 	/* Paranoia. */
 	BUG_ON(skb->protocol != htons(ETH_P_IP));
@@ -1780,34 +1822,32 @@ static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
 
 	/* Enqueue the command. */
 
-	spin_lock_irqsave(&priv->cmd_lock, irqflags);
+	spin_lock_irqsave(&priv->eq_lock, irqflags);
 
 	/*
 	 * Handle completions if needed to make room.
 	 * HACK: Spin until there is sufficient room.
 	 */
-	free_slots = lepp_num_free_comp_slots(eq);
-	if (free_slots < 1) {
-spin:
-		nolds += tile_net_lepp_grab_comps(dev, olds + nolds,
-						  wanted - nolds, NULL);
-		if (lepp_num_free_comp_slots(eq) < 1)
-			goto spin;
+	if (lepp_num_free_comp_slots(eq) == 0) {
+		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 0);
+		if (nolds == 0) {
+busy:
+			spin_unlock_irqrestore(&priv->eq_lock, irqflags);
+			return NETDEV_TX_BUSY;
+		}
 	}
 
 	cmd_head = eq->cmd_head;
 	cmd_tail = eq->cmd_tail;
 
-	/* NOTE: The "gotos" below are untested. */
-
 	/* Prepare to advance, detecting full queue. */
 	cmd_next = cmd_tail + cmd_size;
 	if (cmd_tail < cmd_head && cmd_next >= cmd_head)
-		goto spin;
+		goto busy;
 	if (cmd_next > LEPP_CMD_LIMIT) {
 		cmd_next = 0;
 		if (cmd_next == cmd_head)
-			goto spin;
+			goto busy;
 	}
 
 	/* Copy the command. */
@@ -1823,14 +1863,18 @@ spin:
 	eq->comp_tail = comp_tail;
 
 	/* Flush before allowing LEPP to handle the command. */
+	/* ISSUE: Is this the optimal location for the flush? */
 	__insn_mf();
 
 	eq->cmd_tail = cmd_tail;
 
-	spin_unlock_irqrestore(&priv->cmd_lock, irqflags);
-
+	/* NOTE: Using "4" here is more efficient than "0" or "2", */
+	/* and, strangely, more efficient than pre-checking the number */
+	/* of available completions, and comparing it to 4. */
 	if (nolds == 0)
-		nolds = tile_net_lepp_grab_comps(dev, olds, wanted, NULL);
+		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 4);
+
+	spin_unlock_irqrestore(&priv->eq_lock, irqflags);
 
 	/* Handle completions. */
 	for (i = 0; i < nolds; i++)
@@ -1870,10 +1914,10 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 	unsigned int num_frags;
 
-	lepp_queue_t *eq = priv->epp_queue;
+	lepp_queue_t *eq = priv->eq;
 
-	struct sk_buff *olds[4];
-	unsigned int wanted = 4;
+	struct sk_buff *olds[8];
+	unsigned int wanted = 8;
 	unsigned int i, nolds = 0;
 
 	unsigned int cmd_size = sizeof(lepp_cmd_t);
@@ -1883,8 +1927,6 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 	lepp_cmd_t cmds[LEPP_MAX_FRAGS];
 
-	unsigned int free_slots;
-
 
 	/*
 	 * This is paranoia, since we think that if the link doesn't come
@@ -1905,7 +1947,8 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 	if (hash_default) {
 		HV_PTE pte = *virt_to_pte(current->mm, (unsigned long)data);
 		if (hv_pte_get_mode(pte) != HV_PTE_MODE_CACHE_HASH_L3)
-			panic("Non-coherent egress buffer!");
+			panic("Non-HFH egress buffer! VA=%p Mode=%d PTE=%llx",
+			      data, hv_pte_get_mode(pte), hv_pte_val(pte));
 	}
 #endif
 #endif
@@ -1958,37 +2001,35 @@ static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
 
 	/* Enqueue the commands. */
 
-	spin_lock_irqsave(&priv->cmd_lock, irqflags);
+	spin_lock_irqsave(&priv->eq_lock, irqflags);
 
 	/*
 	 * Handle completions if needed to make room.
 	 * HACK: Spin until there is sufficient room.
 	 */
-	free_slots = lepp_num_free_comp_slots(eq);
-	if (free_slots < 1) {
-spin:
-		nolds += tile_net_lepp_grab_comps(dev, olds + nolds,
-						  wanted - nolds, NULL);
-		if (lepp_num_free_comp_slots(eq) < 1)
-			goto spin;
+	if (lepp_num_free_comp_slots(eq) == 0) {
+		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 0);
+		if (nolds == 0) {
+busy:
+			spin_unlock_irqrestore(&priv->eq_lock, irqflags);
+			return NETDEV_TX_BUSY;
+		}
 	}
 
 	cmd_head = eq->cmd_head;
 	cmd_tail = eq->cmd_tail;
 
-	/* NOTE: The "gotos" below are untested. */
-
 	/* Copy the commands, or fail. */
 	for (i = 0; i < num_frags; i++) {
 
 		/* Prepare to advance, detecting full queue. */
 		cmd_next = cmd_tail + cmd_size;
 		if (cmd_tail < cmd_head && cmd_next >= cmd_head)
-			goto spin;
+			goto busy;
 		if (cmd_next > LEPP_CMD_LIMIT) {
 			cmd_next = 0;
 			if (cmd_next == cmd_head)
-				goto spin;
+				goto busy;
 		}
 
 		/* Copy the command. */
@@ -2005,14 +2046,18 @@ spin:
 	eq->comp_tail = comp_tail;
 
 	/* Flush before allowing LEPP to handle the command. */
+	/* ISSUE: Is this the optimal location for the flush? */
 	__insn_mf();
 
 	eq->cmd_tail = cmd_tail;
 
-	spin_unlock_irqrestore(&priv->cmd_lock, irqflags);
-
+	/* NOTE: Using "4" here is more efficient than "0" or "2", */
+	/* and, strangely, more efficient than pre-checking the number */
+	/* of available completions, and comparing it to 4. */
 	if (nolds == 0)
-		nolds = tile_net_lepp_grab_comps(dev, olds, wanted, NULL);
+		nolds = tile_net_lepp_grab_comps(eq, olds, wanted, 4);
+
+	spin_unlock_irqrestore(&priv->eq_lock, irqflags);
 
 	/* Handle completions. */
 	for (i = 0; i < nolds; i++)
@@ -2261,7 +2306,6 @@ static struct net_device *tile_net_dev_init(const char *name)
 	int ret;
 	struct net_device *dev;
 	struct tile_net_priv *priv;
-	struct page *page;
 
 	/*
 	 * Allocate the device structure.  This allocates "priv", calls
@@ -2285,23 +2329,21 @@ static struct net_device *tile_net_dev_init(const char *name)
 
 	INIT_DELAYED_WORK(&priv->retry_work, tile_net_open_retry);
 
-	spin_lock_init(&priv->cmd_lock);
-	spin_lock_init(&priv->comp_lock);
+	spin_lock_init(&priv->eq_lock);
 
-	/* Allocate "epp_queue". */
-	BUG_ON(get_order(sizeof(lepp_queue_t)) != 0);
-	page = alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
-	if (!page) {
+	/* Allocate "eq". */
+	priv->eq_pages = alloc_pages(GFP_KERNEL | __GFP_ZERO, EQ_ORDER);
+	if (!priv->eq_pages) {
 		free_netdev(dev);
 		return NULL;
 	}
-	priv->epp_queue = page_address(page);
+	priv->eq = page_address(priv->eq_pages);
 
 	/* Register the network device. */
 	ret = register_netdev(dev);
 	if (ret) {
 		pr_err("register_netdev %s failed %d\n", dev->name, ret);
-		free_page((unsigned long)priv->epp_queue);
+		__free_pages(priv->eq_pages, EQ_ORDER);
 		free_netdev(dev);
 		return NULL;
 	}
@@ -2310,7 +2352,7 @@ static struct net_device *tile_net_dev_init(const char *name)
 	ret = tile_net_get_mac(dev);
 	if (ret < 0) {
 		unregister_netdev(dev);
-		free_page((unsigned long)priv->epp_queue);
+		__free_pages(priv->eq_pages, EQ_ORDER);
 		free_netdev(dev);
 		return NULL;
 	}
@@ -2321,6 +2363,9 @@ static struct net_device *tile_net_dev_init(const char *name)
 
 /*
  * Module cleanup.
+ *
+ * FIXME: If compiled as a module, this module cannot be "unloaded",
+ * because the "ingress interrupt handler" is registered permanently.
  */
 static void tile_net_cleanup(void)
 {
@@ -2331,8 +2376,8 @@ static void tile_net_cleanup(void)
 			struct net_device *dev = tile_net_devs[i];
 			struct tile_net_priv *priv = netdev_priv(dev);
 			unregister_netdev(dev);
-			finv_buffer(priv->epp_queue, PAGE_SIZE);
-			free_page((unsigned long)priv->epp_queue);
+			finv_buffer(priv->eq, EQ_SIZE);
+			__free_pages(priv->eq_pages, EQ_ORDER);
 			free_netdev(dev);
 		}
 	}
@@ -2355,7 +2400,12 @@ static int tile_net_init_module(void)
 }
 
 
+module_init(tile_net_init_module);
+module_exit(tile_net_cleanup);
+
+
 #ifndef MODULE
+
 /*
  * The "network_cpus" boot argument specifies the cpus that are dedicated
  * to handle ingress packets.
@@ -2391,8 +2441,5 @@ static int __init network_cpus_setup(char *str)
 	return 0;
 }
 __setup("network_cpus=", network_cpus_setup);
-#endif
 
-
-module_init(tile_net_init_module);
-module_exit(tile_net_cleanup);
+#endif
-- 
1.6.5.2
