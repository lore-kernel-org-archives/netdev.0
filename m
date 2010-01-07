From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/7] Staging: Octeon Ethernet: Remove unused code.
Date: Thu,  7 Jan 2010 11:05:01 -0800
Message-ID: <1262891106-32146-2-git-send-email-ddaney@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17192 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753545Ab0AGTGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:06 -0500
In-Reply-To: <4B463005.8060505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused code, reindent, and join some spilt strings.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-defines.h |   10 ---
 drivers/staging/octeon/ethernet-mem.c     |   81 +++++++-----------------
 drivers/staging/octeon/ethernet-rx.c      |   77 +++++++---------------
 drivers/staging/octeon/ethernet-tx.c      |   99 -----------------------------
 drivers/staging/octeon/ethernet.c         |   31 ++-------
 drivers/staging/octeon/octeon-ethernet.h  |   41 ------------
 6 files changed, 55 insertions(+), 284 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index f13131b..6b8065f 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -41,9 +41,6 @@
  *      Tells the driver to populate the packet buffers with kernel skbuffs.
  *      This allows the driver to receive packets without copying them. It also
  *      means that 32bit userspace can't access the packet buffers.
- *  USE_32BIT_SHARED
- *      This define tells the driver to allocate memory for buffers from the
- *      32bit sahred region instead of the kernel memory space.
  *  USE_HW_TCPUDP_CHECKSUM
  *      Controls if the Octeon TCP/UDP checksum engine is used for packet
  *      output. If this is zero, the kernel will perform the checksum in
@@ -75,19 +72,12 @@
 #define CONFIG_CAVIUM_RESERVE32 0
 #endif
 
-#if CONFIG_CAVIUM_RESERVE32
-#define USE_32BIT_SHARED            1
-#define USE_SKBUFFS_IN_HW           0
-#define REUSE_SKBUFFS_WITHOUT_FREE  0
-#else
-#define USE_32BIT_SHARED            0
 #define USE_SKBUFFS_IN_HW           1
 #ifdef CONFIG_NETFILTER
 #define REUSE_SKBUFFS_WITHOUT_FREE  0
 #else
 #define REUSE_SKBUFFS_WITHOUT_FREE  1
 #endif
-#endif
 
 /* Max interrupts per second per core */
 #define INTERRUPT_LIMIT             10000
diff --git a/drivers/staging/octeon/ethernet-mem.c b/drivers/staging/octeon/ethernet-mem.c
index b595903..7090521 100644
--- a/drivers/staging/octeon/ethernet-mem.c
+++ b/drivers/staging/octeon/ethernet-mem.c
@@ -26,8 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
-#include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
 
@@ -107,42 +105,17 @@ static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
 	char *memory;
 	int freed = elements;
 
-	if (USE_32BIT_SHARED) {
-		extern uint64_t octeon_reserve32_memory;
-
-		memory =
-		    cvmx_bootmem_alloc_range(elements * size, 128,
-					     octeon_reserve32_memory,
-					     octeon_reserve32_memory +
-					     (CONFIG_CAVIUM_RESERVE32 << 20) -
-					     1);
-		if (memory == NULL)
-			panic("Unable to allocate %u bytes for FPA pool %d\n",
-			      elements * size, pool);
-
-		pr_notice("Memory range %p - %p reserved for "
-			  "hardware\n", memory,
-			  memory + elements * size - 1);
-
-		while (freed) {
-			cvmx_fpa_free(memory, pool, 0);
-			memory += size;
-			freed--;
-		}
-	} else {
-		while (freed) {
-			/* We need to force alignment to 128 bytes here */
-			memory = kmalloc(size + 127, GFP_ATOMIC);
-			if (unlikely(memory == NULL)) {
-				pr_warning("Unable to allocate %u bytes for "
-					   "FPA pool %d\n",
-				     elements * size, pool);
-				break;
-			}
-			memory = (char *)(((unsigned long)memory + 127) & -128);
-			cvmx_fpa_free(memory, pool, 0);
-			freed--;
+	while (freed) {
+		/* We need to force alignment to 128 bytes here */
+		memory = kmalloc(size + 127, GFP_ATOMIC);
+		if (unlikely(memory == NULL)) {
+			pr_warning("Unable to allocate %u bytes for FPA pool %d\n",
+				   elements * size, pool);
+			break;
 		}
+		memory = (char *)(((unsigned long)memory + 127) & -128);
+		cvmx_fpa_free(memory, pool, 0);
+		freed--;
 	}
 	return elements - freed;
 }
@@ -156,27 +129,21 @@ static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
  */
 static void cvm_oct_free_hw_memory(int pool, int size, int elements)
 {
-	if (USE_32BIT_SHARED) {
-		pr_warning("Warning: 32 shared memory is not freeable\n");
-	} else {
-		char *memory;
-		do {
-			memory = cvmx_fpa_alloc(pool);
-			if (memory) {
-				elements--;
-				kfree(phys_to_virt(cvmx_ptr_to_phys(memory)));
-			}
-		} while (memory);
+	char *memory;
+	do {
+		memory = cvmx_fpa_alloc(pool);
+		if (memory) {
+			elements--;
+			kfree(phys_to_virt(cvmx_ptr_to_phys(memory)));
+		}
+	} while (memory);
 
-		if (elements < 0)
-			pr_warning("Freeing of pool %u had too many "
-				   "buffers (%d)\n",
-			       pool, elements);
-		else if (elements > 0)
-			pr_warning("Warning: Freeing of pool %u is "
-				"missing %d buffers\n",
-			     pool, elements);
-	}
+	if (elements < 0)
+		pr_warning("Freeing of pool %u had too many buffers (%d)\n",
+			pool, elements);
+	else if (elements > 0)
+		pr_warning("Warning: Freeing of pool %u is missing %d buffers\n",
+			pool, elements);
 }
 
 int cvm_oct_mem_fill_fpa(int pool, int size, int elements)
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index 1b237b7..f63459a 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -33,10 +33,6 @@
 #include <linux/ip.h>
 #include <linux/string.h>
 #include <linux/prefetch.h>
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/seq_file.h>
-#include <linux/proc_fs.h>
 #include <net/dst.h>
 #ifdef CONFIG_XFRM
 #include <linux/xfrm.h>
@@ -292,39 +288,27 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 		 * buffer.
 		 */
 		if (likely(skb_in_hw)) {
-			/*
-			 * This calculation was changed in case the
-			 * skb header is using a different address
-			 * aliasing type than the buffer. It doesn't
-			 * make any differnece now, but the new one is
-			 * more correct.
-			 */
-			skb->data =
-			    skb->head + work->packet_ptr.s.addr -
-			    cvmx_ptr_to_phys(skb->head);
+			skb->data = skb->head + work->packet_ptr.s.addr - cvmx_ptr_to_phys(skb->head);
 			prefetch(skb->data);
 			skb->len = work->len;
 			skb_set_tail_pointer(skb, skb->len);
 			packet_not_copied = 1;
 		} else {
-
 			/*
 			 * We have to copy the packet. First allocate
 			 * an skbuff for it.
 			 */
 			skb = dev_alloc_skb(work->len);
 			if (!skb) {
-				DEBUGPRINT("Port %d failed to allocate "
-					   "skbuff, packet dropped\n",
-				     work->ipprt);
+				DEBUGPRINT("Port %d failed to allocate skbuff, packet dropped\n",
+					   work->ipprt);
 				cvm_oct_free_work(work);
 				continue;
 			}
 
 			/*
 			 * Check if we've received a packet that was
-			 * entirely stored in the work entry. This is
-			 * untested.
+			 * entirely stored in the work entry.
 			 */
 			if (unlikely(work->word2.s.bufs == 0)) {
 				uint8_t *ptr = work->packet_data;
@@ -343,15 +327,13 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 				/* No packet buffers to free */
 			} else {
 				int segments = work->word2.s.bufs;
-				union cvmx_buf_ptr segment_ptr =
-					work->packet_ptr;
+				union cvmx_buf_ptr segment_ptr = work->packet_ptr;
 				int len = work->len;
 
 				while (segments--) {
 					union cvmx_buf_ptr next_ptr =
-					    *(union cvmx_buf_ptr *)
-					    cvmx_phys_to_ptr(segment_ptr.s.
-							     addr - 8);
+					    *(union cvmx_buf_ptr *)cvmx_phys_to_ptr(segment_ptr.s.addr - 8);
+
 			/*
 			 * Octeon Errata PKI-100: The segment size is
 			 * wrong. Until it is fixed, calculate the
@@ -361,22 +343,18 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 			 * one: int segment_size =
 			 * segment_ptr.s.size;
 			 */
-					int segment_size =
-					    CVMX_FPA_PACKET_POOL_SIZE -
-					    (segment_ptr.s.addr -
-					     (((segment_ptr.s.addr >> 7) -
-					       segment_ptr.s.back) << 7));
-					/* Don't copy more than what is left
-					   in the packet */
+					int segment_size = CVMX_FPA_PACKET_POOL_SIZE -
+						(segment_ptr.s.addr - (((segment_ptr.s.addr >> 7) - segment_ptr.s.back) << 7));
+					/*
+					 * Don't copy more than what
+					 * is left in the packet.
+					 */
 					if (segment_size > len)
 						segment_size = len;
 					/* Copy the data into the packet */
 					memcpy(skb_put(skb, segment_size),
-					       cvmx_phys_to_ptr(segment_ptr.s.
-								addr),
+					       cvmx_phys_to_ptr(segment_ptr.s.addr),
 					       segment_size);
-					/* Reduce the amount of bytes left
-					   to copy */
 					len -= segment_size;
 					segment_ptr = next_ptr;
 				}
@@ -389,16 +367,15 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 			struct net_device *dev = cvm_oct_device[work->ipprt];
 			struct octeon_ethernet *priv = netdev_priv(dev);
 
-			/* Only accept packets for devices
-			   that are currently up */
+			/*
+			 * Only accept packets for devices that are
+			 * currently up.
+			 */
 			if (likely(dev->flags & IFF_UP)) {
 				skb->protocol = eth_type_trans(skb, dev);
 				skb->dev = dev;
 
-				if (unlikely
-				    (work->word2.s.not_IP
-				     || work->word2.s.IP_exc
-				     || work->word2.s.L4_error))
+				if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc || work->word2.s.L4_error))
 					skb->ip_summed = CHECKSUM_NONE;
 				else
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -415,14 +392,11 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 				}
 				netif_receive_skb(skb);
 			} else {
+				/* Drop any packet received for a device that isn't up */
 				/*
-				 * Drop any packet received for a
-				 * device that isn't up.
-				 */
-				/*
-				   DEBUGPRINT("%s: Device not up, packet dropped\n",
-				   dev->name);
-				 */
+				DEBUGPRINT("%s: Device not up, packet dropped\n",
+					   dev->name);
+				*/
 #ifdef CONFIG_64BIT
 				atomic64_add(1, (atomic64_t *)&priv->stats.rx_dropped);
 #else
@@ -435,9 +409,8 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 			 * Drop any packet received for a device that
 			 * doesn't exist.
 			 */
-			DEBUGPRINT("Port %d not controlled by Linux, packet "
-				   "dropped\n",
-			     work->ipprt);
+			DEBUGPRINT("Port %d not controlled by Linux, packet dropped\n",
+				   work->ipprt);
 			dev_kfree_skb_irq(skb);
 		}
 		/*
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 5352941..a3594bb 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -31,10 +31,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
 #include <linux/string.h>
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/seq_file.h>
-#include <linux/proc_fs.h>
 #include <net/dst.h>
 #ifdef CONFIG_XFRM
 #include <linux/xfrm.h>
@@ -529,101 +525,6 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
 }
 
 /**
- * Transmit a work queue entry out of the ethernet port. Both
- * the work queue entry and the packet data can optionally be
- * freed. The work will be freed on error as well.
- *
- * @dev:     Device to transmit out.
- * @work_queue_entry:
- *                Work queue entry to send
- * @do_free: True if the work queue entry and packet data should be
- *                freed. If false, neither will be freed.
- * @qos:     Index into the queues for this port to transmit on. This
- *                is used to implement QoS if their are multiple queues per
- *                port. This parameter must be between 0 and the number of
- *                queues per port minus 1. Values outside of this range will
- *                be change to zero.
- *
- * Returns Zero on success, negative on failure.
- */
-int cvm_oct_transmit_qos(struct net_device *dev, void *work_queue_entry,
-			 int do_free, int qos)
-{
-	unsigned long flags;
-	union cvmx_buf_ptr hw_buffer;
-	cvmx_pko_command_word0_t pko_command;
-	int dropped;
-	struct octeon_ethernet *priv = netdev_priv(dev);
-	cvmx_wqe_t *work = work_queue_entry;
-
-	if (!(dev->flags & IFF_UP)) {
-		DEBUGPRINT("%s: Device not up\n", dev->name);
-		if (do_free)
-			cvm_oct_free_work(work);
-		return -1;
-	}
-
-	/* The check on CVMX_PKO_QUEUES_PER_PORT_* is designed to completely
-	   remove "qos" in the event neither interface supports
-	   multiple queues per port */
-	if ((CVMX_PKO_QUEUES_PER_PORT_INTERFACE0 > 1) ||
-	    (CVMX_PKO_QUEUES_PER_PORT_INTERFACE1 > 1)) {
-		if (qos <= 0)
-			qos = 0;
-		else if (qos >= cvmx_pko_get_num_queues(priv->port))
-			qos = 0;
-	} else
-		qos = 0;
-
-	/* Start off assuming no drop */
-	dropped = 0;
-
-	local_irq_save(flags);
-	cvmx_pko_send_packet_prepare(priv->port, priv->queue + qos,
-				     CVMX_PKO_LOCK_CMD_QUEUE);
-
-	/* Build the PKO buffer pointer */
-	hw_buffer.u64 = 0;
-	hw_buffer.s.addr = work->packet_ptr.s.addr;
-	hw_buffer.s.pool = CVMX_FPA_PACKET_POOL;
-	hw_buffer.s.size = CVMX_FPA_PACKET_POOL_SIZE;
-	hw_buffer.s.back = work->packet_ptr.s.back;
-
-	/* Build the PKO command */
-	pko_command.u64 = 0;
-	pko_command.s.n2 = 1;	/* Don't pollute L2 with the outgoing packet */
-	pko_command.s.dontfree = !do_free;
-	pko_command.s.segs = work->word2.s.bufs;
-	pko_command.s.total_bytes = work->len;
-
-	/* Check if we can use the hardware checksumming */
-	if (unlikely(work->word2.s.not_IP || work->word2.s.IP_exc))
-		pko_command.s.ipoffp1 = 0;
-	else
-		pko_command.s.ipoffp1 = sizeof(struct ethhdr) + 1;
-
-	/* Send the packet to the output queue */
-	if (unlikely
-	    (cvmx_pko_send_packet_finish
-	     (priv->port, priv->queue + qos, pko_command, hw_buffer,
-	      CVMX_PKO_LOCK_CMD_QUEUE))) {
-		DEBUGPRINT("%s: Failed to send the packet\n", dev->name);
-		dropped = -1;
-	}
-	local_irq_restore(flags);
-
-	if (unlikely(dropped)) {
-		if (do_free)
-			cvm_oct_free_work(work);
-		priv->stats.tx_dropped++;
-	} else if (do_free)
-		cvmx_fpa_free(work, CVMX_FPA_WQE_POOL, DONT_WRITEBACK(1));
-
-	return dropped;
-}
-EXPORT_SYMBOL(cvm_oct_transmit_qos);
-
-/**
  * This function frees all skb that are currently queued for TX.
  *
  * @dev:    Device being shutdown
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 4cfd4b1..4e05426 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -104,14 +104,6 @@ MODULE_PARM_DESC(pow_send_list, "\n"
 	"\t\"eth2,spi3,spi7\" would cause these three devices to transmit\n"
 	"\tusing the pow_send_group.");
 
-static int disable_core_queueing = 1;
-module_param(disable_core_queueing, int, 0444);
-MODULE_PARM_DESC(disable_core_queueing, "\n"
-	"\tWhen set the networking core's tx_queue_len is set to zero.  This\n"
-	"\tallows packets to be sent without lock contention in the packet\n"
-	"\tscheduler resulting in some cases in improved throughput.\n");
-
-
 /*
  * The offset from mac_addr_base that should be used for the next port
  * that is configured.  By convention, if any mgmt ports exist on the
@@ -205,10 +197,6 @@ static __init void cvm_oct_configure_common_hw(void)
 		cvmx_helper_setup_red(num_packet_buffers / 4,
 				      num_packet_buffers / 8);
 
-	/* Enable the MII interface */
-	if (!octeon_is_simulation())
-		cvmx_write_csr(CVMX_SMIX_EN(0), 1);
-
 	/* Register an IRQ hander for to receive POW interrupts */
 	r = request_irq(OCTEON_IRQ_WORKQ0 + pow_receive_group,
 			cvm_oct_do_interrupt, IRQF_SHARED, "Ethernet",
@@ -689,7 +677,6 @@ static int __init cvm_oct_init_module(void)
 		if (dev) {
 			/* Initialize the device private structure. */
 			struct octeon_ethernet *priv = netdev_priv(dev);
-			memset(priv, 0, sizeof(struct octeon_ethernet));
 
 			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
 			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
@@ -700,19 +687,16 @@ static int __init cvm_oct_init_module(void)
 				skb_queue_head_init(&priv->tx_free_list[qos]);
 
 			if (register_netdev(dev) < 0) {
-				pr_err("Failed to register ethernet "
-					 "device for POW\n");
+				pr_err("Failed to register ethernet device for POW\n");
 				kfree(dev);
 			} else {
 				cvm_oct_device[CVMX_PIP_NUM_INPUT_PORTS] = dev;
-				pr_info("%s: POW send group %d, receive "
-					"group %d\n",
-				     dev->name, pow_send_group,
-				     pow_receive_group);
+				pr_info("%s: POW send group %d, receive group %d\n",
+					dev->name, pow_send_group,
+					pow_receive_group);
 			}
 		} else {
-			pr_err("Failed to allocate ethernet device "
-				 "for POW\n");
+			pr_err("Failed to allocate ethernet device for POW\n");
 		}
 	}
 
@@ -730,12 +714,9 @@ static int __init cvm_oct_init_module(void)
 			struct net_device *dev =
 			    alloc_etherdev(sizeof(struct octeon_ethernet));
 			if (!dev) {
-				pr_err("Failed to allocate ethernet device "
-					 "for port %d\n", port);
+				pr_err("Failed to allocate ethernet device for port %d\n", port);
 				continue;
 			}
-			if (disable_core_queueing)
-				dev->tx_queue_len = 0;
 
 			/* Initialize the device private structure. */
 			priv = netdev_priv(dev);
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 402a15b..208da27 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -68,47 +68,6 @@ struct octeon_ethernet {
  */
 int cvm_oct_free_work(void *work_queue_entry);
 
-/**
- * Transmit a work queue entry out of the ethernet port. Both
- * the work queue entry and the packet data can optionally be
- * freed. The work will be freed on error as well.
- *
- * @dev:     Device to transmit out.
- * @work_queue_entry:
- *                Work queue entry to send
- * @do_free: True if the work queue entry and packet data should be
- *                freed. If false, neither will be freed.
- * @qos:     Index into the queues for this port to transmit on. This
- *                is used to implement QoS if their are multiple queues per
- *                port. This parameter must be between 0 and the number of
- *                queues per port minus 1. Values outside of this range will
- *                be change to zero.
- *
- * Returns Zero on success, negative on failure.
- */
-int cvm_oct_transmit_qos(struct net_device *dev, void *work_queue_entry,
-			 int do_free, int qos);
-
-/**
- * Transmit a work queue entry out of the ethernet port. Both
- * the work queue entry and the packet data can optionally be
- * freed. The work will be freed on error as well. This simply
- * wraps cvmx_oct_transmit_qos() for backwards compatability.
- *
- * @dev:     Device to transmit out.
- * @work_queue_entry:
- *                Work queue entry to send
- * @do_free: True if the work queue entry and packet data should be
- *                freed. If false, neither will be freed.
- *
- * Returns Zero on success, negative on failure.
- */
-static inline int cvm_oct_transmit(struct net_device *dev,
-				   void *work_queue_entry, int do_free)
-{
-	return cvm_oct_transmit_qos(dev, work_queue_entry, do_free, 0);
-}
-
 extern int cvm_oct_rgmii_init(struct net_device *dev);
 extern void cvm_oct_rgmii_uninit(struct net_device *dev);
 extern int cvm_oct_rgmii_open(struct net_device *dev);
-- 
1.6.0.6

