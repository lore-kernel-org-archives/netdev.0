From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/3] Staging: Octeon Ethernet: Clean up and convert to NAPI.
Date: Wed,  6 Jan 2010 16:57:15 -0800
Message-ID: <1262825836-9457-2-git-send-email-ddaney@caviumnetworks.com>
References: <4B4530F3.1070701@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:11034 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932757Ab0AGA5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 19:57:46 -0500
In-Reply-To: <4B4530F3.1070701@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the driver to be a reasonably well behaved NAPI citizen.  Also
clean up memory allocation and tx buffer accounding code.  Remove some
configuration #defines and other unused code that are not applicable
to the in-tree driver.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/Kconfig            |    1 +
 drivers/staging/octeon/ethernet-defines.h |   28 ---
 drivers/staging/octeon/ethernet-mem.c     |   89 +++-----
 drivers/staging/octeon/ethernet-rx.c      |  377 ++++++++++++++++------------
 drivers/staging/octeon/ethernet-rx.h      |   25 ++-
 drivers/staging/octeon/ethernet-tx.c      |  273 +++++++++------------
 drivers/staging/octeon/ethernet-tx.h      |   27 +--
 drivers/staging/octeon/ethernet.c         |  150 +++++-------
 drivers/staging/octeon/octeon-ethernet.h  |   48 +---
 9 files changed, 443 insertions(+), 575 deletions(-)

diff --git a/drivers/staging/octeon/Kconfig b/drivers/staging/octeon/Kconfig
index 638ad6b..579b8f1 100644
--- a/drivers/staging/octeon/Kconfig
+++ b/drivers/staging/octeon/Kconfig
@@ -3,6 +3,7 @@ config OCTEON_ETHERNET
 	depends on CPU_CAVIUM_OCTEON
 	select PHYLIB
 	select MDIO_OCTEON
+	select HIGH_RES_TIMERS
 	help
 	  This driver supports the builtin ethernet ports on Cavium
 	  Networks' products in the Octeon family. This driver supports the
diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index f13131b..9c4910e 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -41,17 +41,10 @@
  *      Tells the driver to populate the packet buffers with kernel skbuffs.
  *      This allows the driver to receive packets without copying them. It also
  *      means that 32bit userspace can't access the packet buffers.
- *  USE_32BIT_SHARED
- *      This define tells the driver to allocate memory for buffers from the
- *      32bit sahred region instead of the kernel memory space.
  *  USE_HW_TCPUDP_CHECKSUM
  *      Controls if the Octeon TCP/UDP checksum engine is used for packet
  *      output. If this is zero, the kernel will perform the checksum in
  *      software.
- *  USE_MULTICORE_RECEIVE
- *      Process receive interrupts on multiple cores. This spreads the network
- *      load across the first 8 processors. If ths is zero, only one core
- *      processes incomming packets.
  *  USE_ASYNC_IOBDMA
  *      Use asynchronous IO access to hardware. This uses Octeon's asynchronous
  *      IOBDMAs to issue IO accesses without stalling. Set this to zero
@@ -75,29 +68,15 @@
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
-
-/* Max interrupts per second per core */
-#define INTERRUPT_LIMIT             10000
 
-/* Don't limit the number of interrupts */
-/*#define INTERRUPT_LIMIT             0     */
 #define USE_HW_TCPUDP_CHECKSUM      1
 
-#define USE_MULTICORE_RECEIVE       1
-
 /* Enable Random Early Dropping under load */
 #define USE_RED                     1
 #define USE_ASYNC_IOBDMA            (CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE > 0)
@@ -115,17 +94,10 @@
 /* Use this to not have FPA frees control L2 */
 /*#define DONT_WRITEBACK(x)         0   */
 
-/* Maximum number of packets to process per interrupt. */
-#define MAX_RX_PACKETS 120
 /* Maximum number of SKBs to try to free per xmit packet. */
 #define MAX_SKB_TO_FREE 10
 #define MAX_OUT_QUEUE_DEPTH 1000
 
-#ifndef CONFIG_SMP
-#undef USE_MULTICORE_RECEIVE
-#define USE_MULTICORE_RECEIVE 0
-#endif
-
 #define IP_PROTOCOL_TCP             6
 #define IP_PROTOCOL_UDP             0x11
 
diff --git a/drivers/staging/octeon/ethernet-mem.c b/drivers/staging/octeon/ethernet-mem.c
index b595903..b59cd16 100644
--- a/drivers/staging/octeon/ethernet-mem.c
+++ b/drivers/staging/octeon/ethernet-mem.c
@@ -26,8 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
-#include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
 
@@ -47,7 +45,7 @@ static int cvm_oct_fill_hw_skbuff(int pool, int size, int elements)
 	int freed = elements;
 	while (freed) {
 
-		struct sk_buff *skb = dev_alloc_skb(size + 128);
+		struct sk_buff *skb = dev_alloc_skb(size + 256);
 		if (unlikely(skb == NULL)) {
 			pr_warning
 			    ("Failed to allocate skb for hardware pool %d\n",
@@ -55,7 +53,7 @@ static int cvm_oct_fill_hw_skbuff(int pool, int size, int elements)
 			break;
 		}
 
-		skb_reserve(skb, 128 - (((unsigned long)skb->data) & 0x7f));
+		skb_reserve(skb, 256 - (((unsigned long)skb->data) & 0x7f));
 		*(struct sk_buff **)(skb->data - sizeof(void *)) = skb;
 		cvmx_fpa_free(skb->data, pool, DONT_WRITEBACK(size / 128));
 		freed--;
@@ -107,42 +105,15 @@ static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
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
+		memory = kmalloc(size, GFP_ATOMIC);
+		if (unlikely(memory == NULL)) {
+			pr_warning("Unable to allocate %u bytes for FPA pool %d\n",
+				elements * size, pool);
+			break;
 		}
+		cvmx_fpa_free(memory, pool, 0);
+		freed--;
 	}
 	return elements - freed;
 }
@@ -156,33 +127,29 @@ static int cvm_oct_fill_hw_memory(int pool, int size, int elements)
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
+		pr_warning("Freeing of pool %u had too many "
+			"buffers (%d)\n",
+			pool, elements);
+	else if (elements > 0)
+		pr_warning("Warning: Freeing of pool %u is "
+			"missing %d buffers\n",
+			pool, elements);
 }
 
 int cvm_oct_mem_fill_fpa(int pool, int size, int elements)
 {
 	int freed;
-	if (USE_SKBUFFS_IN_HW)
+	if (USE_SKBUFFS_IN_HW && pool == CVMX_FPA_PACKET_POOL)
 		freed = cvm_oct_fill_hw_skbuff(pool, size, elements);
 	else
 		freed = cvm_oct_fill_hw_memory(pool, size, elements);
@@ -191,7 +158,7 @@ int cvm_oct_mem_fill_fpa(int pool, int size, int elements)
 
 void cvm_oct_mem_empty_fpa(int pool, int size, int elements)
 {
-	if (USE_SKBUFFS_IN_HW)
+	if (USE_SKBUFFS_IN_HW && pool == CVMX_FPA_PACKET_POOL)
 		cvm_oct_free_hw_skbuff(pool, size, elements);
 	else
 		cvm_oct_free_hw_memory(pool, size, elements);
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index 1b237b7..20906c6 100644
--- a/drivers/staging/octeon/ethernet-rx.c
+++ b/drivers/staging/octeon/ethernet-rx.c
@@ -4,7 +4,7 @@
  * Contact: support@caviumnetworks.com
  * This file is part of the OCTEON SDK
  *
- * Copyright (c) 2003-2007 Cavium Networks
+ * Copyright (c) 2003-2010 Cavium Networks
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
@@ -27,16 +27,14 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/cache.h>
+#include <linux/cpumask.h>
 #include <linux/netdevice.h>
 #include <linux/init.h>
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
 #include <linux/string.h>
 #include <linux/prefetch.h>
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/seq_file.h>
-#include <linux/proc_fs.h>
+#include <linux/smp.h>
 #include <net/dst.h>
 #ifdef CONFIG_XFRM
 #include <linux/xfrm.h>
@@ -48,8 +46,9 @@
 #include <asm/octeon/octeon.h>
 
 #include "ethernet-defines.h"
-#include "octeon-ethernet.h"
 #include "ethernet-mem.h"
+#include "ethernet-rx.h"
+#include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
 #include "cvmx-helper.h"
@@ -61,56 +60,82 @@
 
 #include "cvmx-gmxx-defs.h"
 
-struct cvm_tasklet_wrapper {
-	struct tasklet_struct t;
-};
+struct cvm_napi_wrapper {
+	struct napi_struct napi;
+} ____cacheline_aligned_in_smp;
 
-/*
- * Aligning the tasklet_struct on cachline boundries seems to decrease
- * throughput even though in theory it would reduce contantion on the
- * cache lines containing the locks.
- */
+static struct cvm_napi_wrapper cvm_oct_napi[NR_CPUS] __cacheline_aligned_in_smp;
 
-static struct cvm_tasklet_wrapper cvm_oct_tasklet[NR_CPUS];
+struct cvm_oct_core_state {
+	int baseline_cores;
+	/*
+	 * The number of additional cores that could be processing
+	 * input packtes.
+	 */
+	atomic_t available_cores;
+	cpumask_t cpu_state;
+} ____cacheline_aligned_in_smp;
 
-/**
- * Interrupt handler. The interrupt occurs whenever the POW
- * transitions from 0->1 packets in our group.
- *
- * @cpl:
- * @dev_id:
- * @regs:
- * Returns
- */
-irqreturn_t cvm_oct_do_interrupt(int cpl, void *dev_id)
+static struct cvm_oct_core_state core_state __cacheline_aligned_in_smp;
+
+static void cvm_oct_enable_napi(void *_)
 {
-	/* Acknowledge the interrupt */
-	if (INTERRUPT_LIMIT)
-		cvmx_write_csr(CVMX_POW_WQ_INT, 1 << pow_receive_group);
-	else
-		cvmx_write_csr(CVMX_POW_WQ_INT, 0x10001 << pow_receive_group);
-	preempt_disable();
-	tasklet_schedule(&cvm_oct_tasklet[smp_processor_id()].t);
-	preempt_enable();
-	return IRQ_HANDLED;
+	int cpu = smp_processor_id();
+	napi_schedule(&cvm_oct_napi[cpu].napi);
+}
+
+static void cvm_oct_enable_one_cpu(void)
+{
+	int v;
+	int cpu;
+
+	/* Check to see if more CPUs are available for receive processing... */
+	v = atomic_sub_if_positive(1, &core_state.available_cores);
+	if (v < 0)
+		return;
+
+	/* ... if a CPU is available, Turn on NAPI polling for that CPU.  */
+	for_each_online_cpu(cpu) {
+		if (!cpu_test_and_set(cpu, core_state.cpu_state)) {
+			v = smp_call_function_single(cpu, cvm_oct_enable_napi,
+						     NULL, 0);
+			if (v)
+				panic("Can't enable NAPI.");
+			break;
+		}
+	}
+}
+
+static void cvm_oct_no_more_work(void)
+{
+	int cpu = smp_processor_id();
+
+	/*
+	 * CPU zero is special.  It always has the irq enabled when
+	 * waiting for incoming packets.
+	 */
+	if (cpu == 0) {
+		enable_irq(OCTEON_IRQ_WORKQ0 + pow_receive_group);
+		return;
+	}
+
+	cpu_clear(cpu, core_state.cpu_state);
+	atomic_add(1, &core_state.available_cores);
 }
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
 /**
- * This is called when the kernel needs to manually poll the
- * device. For Octeon, this is simply calling the interrupt
- * handler. We actually poll all the devices, not just the
- * one supplied.
+ * Interrupt handler. The interrupt occurs whenever the POW
+ * has packets in our group.
  *
- * @dev:    Device to poll. Unused
  */
-void cvm_oct_poll_controller(struct net_device *dev)
+static irqreturn_t cvm_oct_do_interrupt(int cpl, void *dev_id)
 {
-	preempt_disable();
-	tasklet_schedule(&cvm_oct_tasklet[smp_processor_id()].t);
-	preempt_enable();
+	/* Disable the IRQ and start napi_poll. */
+	disable_irq_nosync(OCTEON_IRQ_WORKQ0 + pow_receive_group);
+	cvm_oct_enable_napi(NULL);
+
+	return IRQ_HANDLED;
 }
-#endif
 
 /**
  * This is called on receive errors, and determines if the packet
@@ -199,19 +224,19 @@ static inline int cvm_oct_check_rcv_error(cvmx_wqe_t *work)
 }
 
 /**
- * Tasklet function that is scheduled on a core when an interrupt occurs.
+ * The NAPI poll function.
  *
- * @unused:
+ * @napi: The NAPI instance, or null if called from cvm_oct_poll_controller
+ * @budget: Maximum number of packets to receive.
  */
-void cvm_oct_tasklet_rx(unsigned long unused)
+static int cvm_oct_napi_poll(struct napi_struct *napi, int budget)
 {
-	const int coreid = cvmx_get_core_num();
-	uint64_t old_group_mask;
-	uint64_t old_scratch;
-	int rx_count = 0;
-	int number_to_free;
-	int num_freed;
-	int packet_not_copied;
+	const int	coreid = cvmx_get_core_num();
+	uint64_t	old_group_mask;
+	uint64_t	old_scratch;
+	int		rx_count = 0;
+	int		did_work_request = 0;
+	int		packet_not_copied;
 
 	/* Prefetch cvm_oct_device since we know we need it soon */
 	prefetch(cvm_oct_device);
@@ -227,59 +252,63 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 	cvmx_write_csr(CVMX_POW_PP_GRP_MSKX(coreid),
 		       (old_group_mask & ~0xFFFFull) | 1 << pow_receive_group);
 
-	if (USE_ASYNC_IOBDMA)
+	if (USE_ASYNC_IOBDMA) {
 		cvmx_pow_work_request_async(CVMX_SCR_SCRATCH, CVMX_POW_NO_WAIT);
+		did_work_request = 1;
+	}
 
-	while (1) {
+	while (rx_count < budget) {
 		struct sk_buff *skb = NULL;
+		struct sk_buff **pskb = NULL;
 		int skb_in_hw;
 		cvmx_wqe_t *work;
 
-		if (USE_ASYNC_IOBDMA) {
+		if (USE_ASYNC_IOBDMA && did_work_request)
 			work = cvmx_pow_work_response_async(CVMX_SCR_SCRATCH);
-		} else {
-			if ((INTERRUPT_LIMIT == 0)
-			    || likely(rx_count < MAX_RX_PACKETS))
-				work =
-				    cvmx_pow_work_request_sync
-				    (CVMX_POW_NO_WAIT);
-			else
-				work = NULL;
-		}
+		else
+			work = cvmx_pow_work_request_sync(CVMX_POW_NO_WAIT);
+
 		prefetch(work);
-		if (work == NULL)
+		did_work_request = 0;
+		if (work == NULL) {
+			union cvmx_pow_wq_int wq_int;
+			wq_int.u64 = 0;
+			wq_int.s.iq_dis = 1 << pow_receive_group;
+			wq_int.s.wq_int = 1 << pow_receive_group;
+			cvmx_write_csr(CVMX_POW_WQ_INT, wq_int.u64);
 			break;
+		}
+		pskb = (struct sk_buff **)(cvm_oct_get_buffer_ptr(work->packet_ptr) - sizeof(void *));
+		prefetch(pskb);
 
-		/*
-		 * Limit each core to processing MAX_RX_PACKETS
-		 * packets without a break.  This way the RX can't
-		 * starve the TX task.
-		 */
-		if (USE_ASYNC_IOBDMA) {
-
-			if ((INTERRUPT_LIMIT == 0)
-			    || likely(rx_count < MAX_RX_PACKETS))
-				cvmx_pow_work_request_async_nocheck
-				    (CVMX_SCR_SCRATCH, CVMX_POW_NO_WAIT);
-			else {
-				cvmx_scratch_write64(CVMX_SCR_SCRATCH,
-						     0x8000000000000000ull);
-				cvmx_pow_tag_sw_null_nocheck();
-			}
+		if (USE_ASYNC_IOBDMA && rx_count < (budget - 1)) {
+			cvmx_pow_work_request_async_nocheck(CVMX_SCR_SCRATCH, CVMX_POW_NO_WAIT);
+			did_work_request = 1;
+		}
+
+		if (rx_count == 0) {
+			/*
+			 * First time through, see if there is enough
+			 * work waiting to merit waking another
+			 * CPU.
+			 */
+			union cvmx_pow_wq_int_cntx counts;
+			int backlog;
+			int cores_in_use = core_state.baseline_cores - atomic_read(&core_state.available_cores);
+			counts.u64 = cvmx_read_csr(CVMX_POW_WQ_INT_CNTX(pow_receive_group));
+			backlog = counts.s.iq_cnt + counts.s.ds_cnt;
+			if (backlog > budget * cores_in_use && napi != NULL)
+				cvm_oct_enable_one_cpu();
 		}
 
 		skb_in_hw = USE_SKBUFFS_IN_HW && work->word2.s.bufs == 1;
 		if (likely(skb_in_hw)) {
-			skb =
-			    *(struct sk_buff
-			      **)(cvm_oct_get_buffer_ptr(work->packet_ptr) -
-				  sizeof(void *));
+			skb = *pskb;
 			prefetch(&skb->head);
 			prefetch(&skb->len);
 		}
 		prefetch(cvm_oct_device[work->ipprt]);
 
-		rx_count++;
 		/* Immediately throw away all packets with receive errors */
 		if (unlikely(work->word2.snoip.rcv_error)) {
 			if (cvm_oct_check_rcv_error(work))
@@ -292,39 +321,27 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
@@ -343,15 +360,13 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
@@ -361,22 +376,17 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
+					int segment_size = CVMX_FPA_PACKET_POOL_SIZE - (segment_ptr.s.addr - (((segment_ptr.s.addr >> 7) - segment_ptr.s.back) << 7));
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
@@ -389,16 +399,15 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
@@ -413,16 +422,15 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 					atomic_add(skb->len, (atomic_t *)&priv->stats.rx_bytes);
 #endif
 				}
+
 				netif_receive_skb(skb);
+				rx_count++;
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
@@ -435,9 +443,8 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
@@ -459,47 +466,93 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 			cvm_oct_free_work(work);
 		}
 	}
-
 	/* Restore the original POW group mask */
 	cvmx_write_csr(CVMX_POW_PP_GRP_MSKX(coreid), old_group_mask);
 	if (USE_ASYNC_IOBDMA) {
 		/* Restore the scratch area */
 		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
 	}
+	cvm_oct_rx_refill_pool(0);
 
-	if (USE_SKBUFFS_IN_HW) {
-		/* Refill the packet buffer pool */
-		number_to_free =
-		    cvmx_fau_fetch_and_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, 0);
-
-		if (number_to_free > 0) {
-			cvmx_fau_atomic_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE,
-					      -number_to_free);
-			num_freed =
-			    cvm_oct_mem_fill_fpa(CVMX_FPA_PACKET_POOL,
-						 CVMX_FPA_PACKET_POOL_SIZE,
-						 number_to_free);
-			if (num_freed != number_to_free) {
-				cvmx_fau_atomic_add32
-				    (FAU_NUM_PACKET_BUFFERS_TO_FREE,
-				     number_to_free - num_freed);
-			}
-		}
+	if (rx_count < budget && napi != NULL) {
+		/* No more work */
+		napi_complete(napi);
+		cvm_oct_no_more_work();
 	}
+	return rx_count;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * This is called when the kernel needs to manually poll the
+ * device.
+ *
+ * @dev:    Device to poll. Unused
+ */
+void cvm_oct_poll_controller(struct net_device *dev)
+{
+	cvm_oct_napi_poll(NULL, 16);
 }
+#endif
 
 void cvm_oct_rx_initialize(void)
 {
 	int i;
-	/* Initialize all of the tasklets */
-	for (i = 0; i < NR_CPUS; i++)
-		tasklet_init(&cvm_oct_tasklet[i].t, cvm_oct_tasklet_rx, 0);
+	struct net_device *dev_for_napi = NULL;
+	union cvmx_pow_wq_int_thrx int_thr;
+	union cvmx_pow_wq_int_pc int_pc;
+
+	for (i = 0; i < TOTAL_NUMBER_OF_PORTS; i++) {
+		if (cvm_oct_device[i]) {
+			dev_for_napi = cvm_oct_device[i];
+			break;
+		}
+	}
+
+	if (NULL == dev_for_napi)
+		panic("No net_devices were allocated.");
+
+	if (max_rx_cpus > 1  && max_rx_cpus < num_online_cpus())
+		atomic_set(&core_state.available_cores, max_rx_cpus);
+	else
+		atomic_set(&core_state.available_cores, num_online_cpus());
+	core_state.baseline_cores = atomic_read(&core_state.available_cores);
+
+	core_state.cpu_state = CPU_MASK_NONE;
+	for_each_possible_cpu(i) {
+		netif_napi_add(dev_for_napi, &cvm_oct_napi[i].napi,
+			       cvm_oct_napi_poll, rx_napi_weight);
+		napi_enable(&cvm_oct_napi[i].napi);
+	}
+	/* Register an IRQ hander for to receive POW interrupts */
+	i = request_irq(OCTEON_IRQ_WORKQ0 + pow_receive_group,
+			cvm_oct_do_interrupt, 0, "Ethernet", cvm_oct_device);
+
+	if (i)
+		panic("Could not acquire Ethernet IRQ %d\n",
+		      OCTEON_IRQ_WORKQ0 + pow_receive_group);
+
+	disable_irq_nosync(OCTEON_IRQ_WORKQ0 + pow_receive_group);
+
+	int_thr.u64 = 0;
+	int_thr.s.tc_en = 1;
+	int_thr.s.tc_thr = 1;
+	/* Enable POW interrupt when our port has at least one packet */
+	cvmx_write_csr(CVMX_POW_WQ_INT_THRX(pow_receive_group), int_thr.u64);
+
+	int_pc.u64 = 0;
+	int_pc.s.pc_thr = 5;
+	cvmx_write_csr(CVMX_POW_WQ_INT_PC, int_pc.u64);
+
+
+	/* Scheduld NAPI now.  This will indirectly enable interrupts. */
+	cvm_oct_enable_one_cpu();
 }
 
 void cvm_oct_rx_shutdown(void)
 {
 	int i;
-	/* Shutdown all of the tasklets */
-	for (i = 0; i < NR_CPUS; i++)
-		tasklet_kill(&cvm_oct_tasklet[i].t);
+	/* Shutdown all of the NAPIs */
+	for_each_possible_cpu(i)
+		netif_napi_del(&cvm_oct_napi[i].napi);
 }
diff --git a/drivers/staging/octeon/ethernet-rx.h b/drivers/staging/octeon/ethernet-rx.h
index a9b72b8..a0743b8 100644
--- a/drivers/staging/octeon/ethernet-rx.h
+++ b/drivers/staging/octeon/ethernet-rx.h
@@ -24,10 +24,29 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium Networks for more information
 *********************************************************************/
+#include "cvmx-fau.h"
 
-irqreturn_t cvm_oct_do_interrupt(int cpl, void *dev_id);
 void cvm_oct_poll_controller(struct net_device *dev);
-void cvm_oct_tasklet_rx(unsigned long unused);
-
 void cvm_oct_rx_initialize(void);
 void cvm_oct_rx_shutdown(void);
+
+static inline void cvm_oct_rx_refill_pool(int fill_threshold)
+{
+	int number_to_free;
+	int num_freed;
+	/* Refill the packet buffer pool */
+	number_to_free =
+		cvmx_fau_fetch_and_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, 0);
+
+	if (number_to_free > fill_threshold) {
+		cvmx_fau_atomic_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE,
+				      -number_to_free);
+		num_freed = cvm_oct_mem_fill_fpa(CVMX_FPA_PACKET_POOL,
+						 CVMX_FPA_PACKET_POOL_SIZE,
+						 number_to_free);
+		if (num_freed != number_to_free) {
+			cvmx_fau_atomic_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE,
+					number_to_free - num_freed);
+		}
+	}
+}
diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
index 5352941..28e2de6 100644
--- a/drivers/staging/octeon/ethernet-tx.c
+++ b/drivers/staging/octeon/ethernet-tx.c
@@ -4,7 +4,7 @@
  * Contact: support@caviumnetworks.com
  * This file is part of the OCTEON SDK
  *
- * Copyright (c) 2003-2007 Cavium Networks
+ * Copyright (c) 2003-2010 Cavium Networks
  *
  * This file is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License, Version 2, as
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
@@ -68,6 +64,49 @@
 #define GET_SKBUFF_QOS(skb) 0
 #endif
 
+
+static inline int32_t cvm_oct_adjust_skb_to_free(int32_t skb_to_free, int fau)
+{
+	int32_t undo;
+	undo = skb_to_free > 0 ? MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
+	if (undo > 0)
+		cvmx_fau_atomic_add32(fau, -undo);
+	skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ? MAX_SKB_TO_FREE : -skb_to_free;
+	return skb_to_free;
+}
+
+void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv)
+{
+	int32_t skb_to_free;
+	int qos, queues_per_port;
+	queues_per_port = cvmx_pko_get_num_queues(priv->port);
+	/* Drain any pending packets in the free list */
+	for (qos = 0; qos < queues_per_port; qos++) {
+		if (skb_queue_len(&priv->tx_free_list[qos]) == 0)
+			continue;
+		skb_to_free = cvmx_fau_fetch_and_add32(priv->fau+qos*4, MAX_SKB_TO_FREE);
+		skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau+qos*4);
+
+		while (skb_to_free > 0) {
+			dev_kfree_skb_any(skb_dequeue(&priv->tx_free_list[qos]));
+			skb_to_free--;
+		}
+	}
+}
+
+enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer)
+{
+	struct octeon_ethernet *priv = container_of(timer, struct octeon_ethernet, tx_restart_timer);
+	struct net_device *dev = cvm_oct_device[priv->port];
+
+	cvm_oct_free_tx_skbs(priv);
+
+	if (netif_queue_stopped(dev))
+		netif_wake_queue(dev);
+
+	return HRTIMER_NORESTART;
+}
+
 /**
  * Packet transmit
  *
@@ -81,13 +120,13 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	union cvmx_buf_ptr hw_buffer;
 	uint64_t old_scratch;
 	uint64_t old_scratch2;
-	int dropped;
 	int qos;
-	int queue_it_up;
+	enum {QUEUE_CORE, QUEUE_HW, QUEUE_DROP} queue_type;
 	struct octeon_ethernet *priv = netdev_priv(dev);
+	struct sk_buff *to_free_list;
 	int32_t skb_to_free;
-	int32_t undo;
 	int32_t buffers_to_free;
+	unsigned long flags;
 #if REUSE_SKBUFFS_WITHOUT_FREE
 	unsigned char *fpa_head;
 #endif
@@ -98,9 +137,6 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	prefetch(priv);
 
-	/* Start off assuming no drop */
-	dropped = 0;
-
 	/*
 	 * The check on CVMX_PKO_QUEUES_PER_PORT_* is designed to
 	 * completely remove "qos" in the event neither interface
@@ -190,7 +226,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * shown a 25% increase in performance under some loads.
 	 */
 #if REUSE_SKBUFFS_WITHOUT_FREE
-	fpa_head = skb->head + 128 - ((unsigned long)skb->head & 0x7f);
+	fpa_head = skb->head + 256 - ((unsigned long)skb->head & 0x7f);
 	if (unlikely(skb->data < fpa_head)) {
 		/*
 		 * printk("TX buffer beginning can't meet FPA
@@ -251,7 +287,7 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	pko_command.s.reg0 = 0;
 	pko_command.s.dontfree = 0;
 
-	hw_buffer.s.back = (skb->data - fpa_head) >> 7;
+	hw_buffer.s.back = ((unsigned long)skb->data >> 7) - ((unsigned long)fpa_head >> 7);
 	*(struct sk_buff **)(fpa_head - sizeof(void *)) = skb;
 
 	/*
@@ -272,9 +308,9 @@ int cvm_oct_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb->tc_verd = 0;
 #endif /* CONFIG_NET_CLS_ACT */
 #endif /* CONFIG_NET_SCHED */
+#endif /* REUSE_SKBUFFS_WITHOUT_FREE */
 
 dont_put_skbuff_in_hw:
-#endif /* REUSE_SKBUFFS_WITHOUT_FREE */
 
 	/* Check if we can use the hardware checksumming */
 	if (USE_HW_TCPUDP_CHECKSUM && (skb->protocol == htons(ETH_P_IP)) &&
@@ -299,18 +335,7 @@ dont_put_skbuff_in_hw:
 		    cvmx_fau_fetch_and_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, 0);
 	}
 
-	/*
-	 * We try to claim MAX_SKB_TO_FREE buffers.  If there were not
-	 * that many available, we have to un-claim (undo) any that
-	 * were in excess.  If skb_to_free is positive we will free
-	 * that many buffers.
-	 */
-	undo = skb_to_free > 0 ?
-		MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
-	if (undo > 0)
-		cvmx_fau_atomic_add32(priv->fau+qos*4, -undo);
-	skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ?
-		MAX_SKB_TO_FREE : -skb_to_free;
+	skb_to_free = cvm_oct_adjust_skb_to_free(skb_to_free, priv->fau+qos*4);
 
 	/*
 	 * If we're sending faster than the receive can free them then
@@ -321,60 +346,79 @@ dont_put_skbuff_in_hw:
 		pko_command.s.reg0 = priv->fau + qos * 4;
 	}
 
-	cvmx_pko_send_packet_prepare(priv->port, priv->queue + qos,
-				     CVMX_PKO_LOCK_CMD_QUEUE);
+	if (pko_command.s.dontfree)
+		queue_type = QUEUE_CORE;
+	else
+		queue_type = QUEUE_HW;
+
+	spin_lock_irqsave(&priv->tx_free_list[qos].lock, flags);
 
 	/* Drop this packet if we have too many already queued to the HW */
-	if (unlikely
-	    (skb_queue_len(&priv->tx_free_list[qos]) >= MAX_OUT_QUEUE_DEPTH)) {
-		/*
-		   DEBUGPRINT("%s: Tx dropped. Too many queued\n", dev->name);
-		 */
-		dropped = 1;
+	if (unlikely(skb_queue_len(&priv->tx_free_list[qos]) >= MAX_OUT_QUEUE_DEPTH)) {
+		if (dev->tx_queue_len != 0) {
+			netif_stop_queue(dev);
+			hrtimer_start(&priv->tx_restart_timer,
+				      priv->tx_restart_interval, HRTIMER_MODE_REL);
+		} else {
+			/* If not using normal queueing.  */
+			queue_type = QUEUE_DROP;
+			goto skip_xmit;
+		}
 	}
+
+	cvmx_pko_send_packet_prepare(priv->port, priv->queue + qos,
+				     CVMX_PKO_LOCK_NONE);
+
 	/* Send the packet to the output queue */
-	else if (unlikely
-		 (cvmx_pko_send_packet_finish
-		  (priv->port, priv->queue + qos, pko_command, hw_buffer,
-		   CVMX_PKO_LOCK_CMD_QUEUE))) {
+	if (unlikely(cvmx_pko_send_packet_finish(priv->port,
+						 priv->queue + qos,
+						 pko_command, hw_buffer,
+						 CVMX_PKO_LOCK_NONE))) {
 		DEBUGPRINT("%s: Failed to send the packet\n", dev->name);
-		dropped = 1;
+		queue_type = QUEUE_DROP;
 	}
+skip_xmit:
+	to_free_list = NULL;
 
-	if (USE_ASYNC_IOBDMA) {
-		/* Restore the scratch area */
-		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
-		cvmx_scratch_write64(CVMX_SCR_SCRATCH + 8, old_scratch2);
+	switch (queue_type) {
+	case QUEUE_DROP:
+		skb->next = to_free_list;
+		to_free_list = skb;
+		priv->stats.tx_dropped++;
+		break;
+	case QUEUE_HW:
+		cvmx_fau_atomic_add32(FAU_NUM_PACKET_BUFFERS_TO_FREE, -1);
+		break;
+	case QUEUE_CORE:
+		__skb_queue_tail(&priv->tx_free_list[qos], skb);
+		break;
+	default:
+		BUG();
 	}
 
-	queue_it_up = 0;
-	if (unlikely(dropped)) {
-		dev_kfree_skb_any(skb);
-		priv->stats.tx_dropped++;
-	} else {
-		if (USE_SKBUFFS_IN_HW) {
-			/* Put this packet on the queue to be freed later */
-			if (pko_command.s.dontfree)
-				queue_it_up = 1;
-			else
-				cvmx_fau_atomic_add32
-				    (FAU_NUM_PACKET_BUFFERS_TO_FREE, -1);
-		} else {
-			/* Put this packet on the queue to be freed later */
-			queue_it_up = 1;
-		}
+	while (skb_to_free > 0) {
+		struct sk_buff *t = __skb_dequeue(&priv->tx_free_list[qos]);
+		t->next = to_free_list;
+		to_free_list = t;
+		skb_to_free--;
 	}
 
-	if (queue_it_up) {
-		spin_lock(&priv->tx_free_list[qos].lock);
-		__skb_queue_tail(&priv->tx_free_list[qos], skb);
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 0);
-		spin_unlock(&priv->tx_free_list[qos].lock);
-	} else {
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 1);
+	spin_unlock_irqrestore(&priv->tx_free_list[qos].lock, flags);
+
+	/* Do the actual freeing outside of the lock. */
+	while (to_free_list) {
+		struct sk_buff *t = to_free_list;
+		to_free_list = to_free_list->next;
+		dev_kfree_skb_any(t);
 	}
 
-	return 0;
+	if (USE_ASYNC_IOBDMA) {
+		/* Restore the scratch area */
+		cvmx_scratch_write64(CVMX_SCR_SCRATCH, old_scratch);
+		cvmx_scratch_write64(CVMX_SCR_SCRATCH + 8, old_scratch2);
+	}
+
+	return NETDEV_TX_OK;
 }
 
 /**
@@ -529,101 +573,6 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev)
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
diff --git a/drivers/staging/octeon/ethernet-tx.h b/drivers/staging/octeon/ethernet-tx.h
index c0bebf7..b628d8c 100644
--- a/drivers/staging/octeon/ethernet-tx.h
+++ b/drivers/staging/octeon/ethernet-tx.h
@@ -30,28 +30,5 @@ int cvm_oct_xmit_pow(struct sk_buff *skb, struct net_device *dev);
 int cvm_oct_transmit_qos(struct net_device *dev, void *work_queue_entry,
 			 int do_free, int qos);
 void cvm_oct_tx_shutdown(struct net_device *dev);
-
-/**
- * Free dead transmit skbs.
- *
- * @priv:		The driver data
- * @skb_to_free:	The number of SKBs to free (free none if negative).
- * @qos:		The queue to free from.
- * @take_lock:		If true, acquire the skb list lock.
- */
-static inline void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv,
-					int skb_to_free,
-					int qos, int take_lock)
-{
-	/* Free skbuffs not in use by the hardware.  */
-	if (skb_to_free > 0) {
-		if (take_lock)
-			spin_lock(&priv->tx_free_list[qos].lock);
-		while (skb_to_free > 0) {
-			dev_kfree_skb(__skb_dequeue(&priv->tx_free_list[qos]));
-			skb_to_free--;
-		}
-		if (take_lock)
-			spin_unlock(&priv->tx_free_list[qos].lock);
-	}
-}
+void cvm_oct_free_tx_skbs(struct octeon_ethernet *priv);
+enum hrtimer_restart cvm_oct_restart_tx(struct hrtimer *timer);
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 4cfd4b1..2fc1e8e 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -104,12 +104,15 @@ MODULE_PARM_DESC(pow_send_list, "\n"
 	"\t\"eth2,spi3,spi7\" would cause these three devices to transmit\n"
 	"\tusing the pow_send_group.");
 
-static int disable_core_queueing = 1;
-module_param(disable_core_queueing, int, 0444);
-MODULE_PARM_DESC(disable_core_queueing, "\n"
-	"\tWhen set the networking core's tx_queue_len is set to zero.  This\n"
-	"\tallows packets to be sent without lock contention in the packet\n"
-	"\tscheduler resulting in some cases in improved throughput.\n");
+int max_rx_cpus = -1;
+module_param(max_rx_cpus, int, 0444);
+MODULE_PARM_DESC(max_rx_cpus, "\n"
+	"\t\tThe maximum number of CPUs to use for packet reception.\n"
+	"\t\tUse -1 to use all available CPUs.");
+
+int rx_napi_weight = 32;
+module_param(rx_napi_weight, int, 0444);
+MODULE_PARM_DESC(rx_napi_weight, "The NAPI WEIGHT parameter.");
 
 
 /*
@@ -139,50 +142,38 @@ struct net_device *cvm_oct_device[TOTAL_NUMBER_OF_PORTS];
  */
 static void cvm_do_timer(unsigned long arg)
 {
-	int32_t skb_to_free, undo;
-	int queues_per_port;
-	int qos;
-	struct octeon_ethernet *priv;
 	static int port;
-
-	if (port >= CVMX_PIP_NUM_INPUT_PORTS) {
+	if (port < CVMX_PIP_NUM_INPUT_PORTS) {
+		if (cvm_oct_device[port]) {
+			struct octeon_ethernet *priv = netdev_priv(cvm_oct_device[port]);
+			if (priv->poll)
+				priv->poll(cvm_oct_device[port]);
+			cvm_oct_free_tx_skbs(priv);
+			cvm_oct_device[port]->netdev_ops->ndo_get_stats(cvm_oct_device[port]);
+		}
+		port++;
 		/*
-		 * All ports have been polled. Start the next
-		 * iteration through the ports in one second.
+		 * Poll the next port in a 50th of a second.  This
+		 * spreads the polling of ports out a little bit.
 		 */
+		mod_timer(&cvm_oct_poll_timer, jiffies + HZ/50);
+	} else {
 		port = 0;
+		/*
+		 * FPA 0 may have been drained, try to refill it if we
+		 * need more than num_packet_buffers / 2, otherwise
+		 * normal receive processing will refill it.  If it
+		 * were drained, no packets could be received so
+		 * cvm_oct_napi_poll would never be invoked to do the
+		 * refill.
+		 */
+		cvm_oct_rx_refill_pool(num_packet_buffers / 2);
+		/*
+		 * All ports have been polled. Start the next iteration through
+		 * the ports in one second.
+		 */
 		mod_timer(&cvm_oct_poll_timer, jiffies + HZ);
-		return;
 	}
-	if (!cvm_oct_device[port])
-		goto out;
-
-	priv = netdev_priv(cvm_oct_device[port]);
-	if (priv->poll)
-		priv->poll(cvm_oct_device[port]);
-
-	queues_per_port = cvmx_pko_get_num_queues(port);
-	/* Drain any pending packets in the free list */
-	for (qos = 0; qos < queues_per_port; qos++) {
-		if (skb_queue_len(&priv->tx_free_list[qos]) == 0)
-			continue;
-		skb_to_free = cvmx_fau_fetch_and_add32(priv->fau + qos * 4,
-						       MAX_SKB_TO_FREE);
-		undo = skb_to_free > 0 ?
-			MAX_SKB_TO_FREE : skb_to_free + MAX_SKB_TO_FREE;
-		if (undo > 0)
-			cvmx_fau_atomic_add32(priv->fau+qos*4, -undo);
-		skb_to_free = -skb_to_free > MAX_SKB_TO_FREE ?
-			MAX_SKB_TO_FREE : -skb_to_free;
-		cvm_oct_free_tx_skbs(priv, skb_to_free, qos, 1);
-	}
-	cvm_oct_device[port]->netdev_ops->ndo_get_stats(cvm_oct_device[port]);
-
-out:
-	port++;
-	/* Poll the next port in a 50th of a second.
-	   This spreads the polling of ports out a little bit */
-	mod_timer(&cvm_oct_poll_timer, jiffies + HZ / 50);
 }
 
 /**
@@ -190,7 +181,6 @@ out:
  */
 static __init void cvm_oct_configure_common_hw(void)
 {
-	int r;
 	/* Setup the FPA */
 	cvmx_fpa_enable();
 	cvm_oct_mem_fill_fpa(CVMX_FPA_PACKET_POOL, CVMX_FPA_PACKET_POOL_SIZE,
@@ -205,21 +195,6 @@ static __init void cvm_oct_configure_common_hw(void)
 		cvmx_helper_setup_red(num_packet_buffers / 4,
 				      num_packet_buffers / 8);
 
-	/* Enable the MII interface */
-	if (!octeon_is_simulation())
-		cvmx_write_csr(CVMX_SMIX_EN(0), 1);
-
-	/* Register an IRQ hander for to receive POW interrupts */
-	r = request_irq(OCTEON_IRQ_WORKQ0 + pow_receive_group,
-			cvm_oct_do_interrupt, IRQF_SHARED, "Ethernet",
-			cvm_oct_device);
-
-#if defined(CONFIG_SMP) && 0
-	if (USE_MULTICORE_RECEIVE) {
-		irq_set_affinity(OCTEON_IRQ_WORKQ0 + pow_receive_group,
-				 cpu_online_mask);
-	}
-#endif
 }
 
 /**
@@ -649,7 +624,6 @@ static int __init cvm_oct_init_module(void)
 		cvm_oct_mac_addr_offset = 0;
 
 	cvm_oct_proc_initialize();
-	cvm_oct_rx_initialize();
 	cvm_oct_configure_common_hw();
 
 	cvmx_helper_initialize_packet_io_global();
@@ -689,7 +663,18 @@ static int __init cvm_oct_init_module(void)
 		if (dev) {
 			/* Initialize the device private structure. */
 			struct octeon_ethernet *priv = netdev_priv(dev);
-			memset(priv, 0, sizeof(struct octeon_ethernet));
+
+			hrtimer_init(&priv->tx_restart_timer,
+				     CLOCK_MONOTONIC,
+				     HRTIMER_MODE_REL);
+			priv->tx_restart_timer.function = cvm_oct_restart_tx;
+
+			/*
+			 * Default for 10GE 5000nS enough time to
+			 * transmit about 100 64byte packtes.  1GE
+			 * interfaces will get 50000nS below.
+			 */
+			priv->tx_restart_interval = ktime_set(0, 5000);
 
 			dev->netdev_ops = &cvm_oct_pow_netdev_ops;
 			priv->imode = CVMX_HELPER_INTERFACE_MODE_DISABLED;
@@ -700,19 +685,16 @@ static int __init cvm_oct_init_module(void)
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
 
@@ -730,12 +712,10 @@ static int __init cvm_oct_init_module(void)
 			struct net_device *dev =
 			    alloc_etherdev(sizeof(struct octeon_ethernet));
 			if (!dev) {
-				pr_err("Failed to allocate ethernet device "
-					 "for port %d\n", port);
+				pr_err("Failed to allocate ethernet device for port %d\n",
+				       port);
 				continue;
 			}
-			if (disable_core_queueing)
-				dev->tx_queue_len = 0;
 
 			/* Initialize the device private structure. */
 			priv = netdev_priv(dev);
@@ -776,6 +756,7 @@ static int __init cvm_oct_init_module(void)
 
 			case CVMX_HELPER_INTERFACE_MODE_SGMII:
 				dev->netdev_ops = &cvm_oct_sgmii_netdev_ops;
+				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 
@@ -787,6 +768,7 @@ static int __init cvm_oct_init_module(void)
 			case CVMX_HELPER_INTERFACE_MODE_RGMII:
 			case CVMX_HELPER_INTERFACE_MODE_GMII:
 				dev->netdev_ops = &cvm_oct_rgmii_netdev_ops;
+				priv->tx_restart_interval = ktime_set(0, 50000);
 				strcpy(dev->name, "eth%d");
 				break;
 			}
@@ -807,25 +789,7 @@ static int __init cvm_oct_init_module(void)
 		}
 	}
 
-	if (INTERRUPT_LIMIT) {
-		/*
-		 * Set the POW timer rate to give an interrupt at most
-		 * INTERRUPT_LIMIT times per second.
-		 */
-		cvmx_write_csr(CVMX_POW_WQ_INT_PC,
-			       octeon_bootinfo->eclock_hz / (INTERRUPT_LIMIT *
-							     16 * 256) << 8);
-
-		/*
-		 * Enable POW timer interrupt. It will count when
-		 * there are packets available.
-		 */
-		cvmx_write_csr(CVMX_POW_WQ_INT_THRX(pow_receive_group),
-			       0x1ful << 24);
-	} else {
-		/* Enable POW interrupt when our port has at least one packet */
-		cvmx_write_csr(CVMX_POW_WQ_INT_THRX(pow_receive_group), 0x1001);
-	}
+	cvm_oct_rx_initialize();
 
 	/* Enable the poll timer for checking RGMII status */
 	init_timer(&cvm_oct_poll_timer);
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 402a15b..40b6956 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -31,6 +31,8 @@
 #ifndef OCTEON_ETHERNET_H
 #define OCTEON_ETHERNET_H
 
+#include <linux/hrtimer.h>
+
 /**
  * This is the definition of the Ethernet driver's private
  * driver state stored in netdev_priv(dev).
@@ -57,6 +59,8 @@ struct octeon_ethernet {
 	uint64_t link_info;
 	/* Called periodically to check link status */
 	void (*poll) (struct net_device *dev);
+	struct hrtimer		tx_restart_timer;
+	ktime_t			tx_restart_interval;
 };
 
 /**
@@ -68,47 +72,6 @@ struct octeon_ethernet {
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
@@ -135,4 +98,7 @@ extern int pow_receive_group;
 extern char pow_send_list[];
 extern struct net_device *cvm_oct_device[];
 
+extern int max_rx_cpus;
+extern int rx_napi_weight;
+
 #endif
-- 
1.6.0.6

