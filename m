From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 5/7] Staging: Octeon Ethernet: Convert to NAPI.
Date: Thu,  7 Jan 2010 11:05:04 -0800
Message-ID: <1262891106-32146-5-git-send-email-ddaney@caviumnetworks.com>
References: <4B463005.8060505@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:17176 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457Ab0AGTGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:02 -0500
In-Reply-To: <4B463005.8060505@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the driver to be a reasonably well behaved NAPI citizen.

There is one NAPI instance per CPU shared between all input ports.  As
receive backlog increases, NAPI is scheduled on additional CPUs.

Receive buffer refill code factored out so it can also be called from
the periodic timer.  This is needed to recover from temporary buffer
starvation conditions.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-defines.h |   18 --
 drivers/staging/octeon/ethernet-rx.c      |  300 ++++++++++++++++++-----------
 drivers/staging/octeon/ethernet-rx.h      |   25 ++-
 drivers/staging/octeon/ethernet.c         |   52 ++---
 drivers/staging/octeon/octeon-ethernet.h  |    3 +
 5 files changed, 235 insertions(+), 163 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-defines.h b/drivers/staging/octeon/ethernet-defines.h
index 6b8065f..9c4910e 100644
--- a/drivers/staging/octeon/ethernet-defines.h
+++ b/drivers/staging/octeon/ethernet-defines.h
@@ -45,10 +45,6 @@
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
@@ -79,15 +75,8 @@
 #define REUSE_SKBUFFS_WITHOUT_FREE  1
 #endif
 
-/* Max interrupts per second per core */
-#define INTERRUPT_LIMIT             10000
-
-/* Don't limit the number of interrupts */
-/*#define INTERRUPT_LIMIT             0     */
 #define USE_HW_TCPUDP_CHECKSUM      1
 
-#define USE_MULTICORE_RECEIVE       1
-
 /* Enable Random Early Dropping under load */
 #define USE_RED                     1
 #define USE_ASYNC_IOBDMA            (CONFIG_CAVIUM_OCTEON_CVMSEG_SIZE > 0)
@@ -105,17 +94,10 @@
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
 
diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
index f63459a..b2e6ab6 100644
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
@@ -27,12 +27,14 @@
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
+#include <linux/smp.h>
 #include <net/dst.h>
 #ifdef CONFIG_XFRM
 #include <linux/xfrm.h>
@@ -44,8 +46,9 @@
 #include <asm/octeon/octeon.h>
 
 #include "ethernet-defines.h"
-#include "octeon-ethernet.h"
 #include "ethernet-mem.h"
+#include "ethernet-rx.h"
+#include "octeon-ethernet.h"
 #include "ethernet-util.h"
 
 #include "cvmx-helper.h"
@@ -57,56 +60,82 @@
 
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
@@ -195,19 +224,19 @@ static inline int cvm_oct_check_rcv_error(cvmx_wqe_t *work)
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
@@ -223,59 +252,63 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
@@ -391,6 +424,7 @@ void cvm_oct_tasklet_rx(unsigned long unused)
 #endif
 				}
 				netif_receive_skb(skb);
+				rx_count++;
 			} else {
 				/* Drop any packet received for a device that isn't up */
 				/*
@@ -432,47 +466,93 @@ void cvm_oct_tasklet_rx(unsigned long unused)
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
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 973178a..9f5b741 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -104,6 +104,16 @@ MODULE_PARM_DESC(pow_send_list, "\n"
 	"\t\"eth2,spi3,spi7\" would cause these three devices to transmit\n"
 	"\tusing the pow_send_group.");
 
+int max_rx_cpus = -1;
+module_param(max_rx_cpus, int, 0444);
+MODULE_PARM_DESC(max_rx_cpus, "\n"
+	"\t\tThe maximum number of CPUs to use for packet reception.\n"
+	"\t\tUse -1 to use all available CPUs.");
+
+int rx_napi_weight = 32;
+module_param(rx_napi_weight, int, 0444);
+MODULE_PARM_DESC(rx_napi_weight, "The NAPI WEIGHT parameter.");
+
 /*
  * The offset from mac_addr_base that should be used for the next port
  * that is configured.  By convention, if any mgmt ports exist on the
@@ -149,6 +159,15 @@ static void cvm_do_timer(unsigned long arg)
 	} else {
 		port = 0;
 		/*
+		 * FPA 0 may have been drained, try to refill it if we
+		 * need more than num_packet_buffers / 2, otherwise
+		 * normal receive processing will refill it.  If it
+		 * were drained, no packets could be received so
+		 * cvm_oct_napi_poll would never be invoked to do the
+		 * refill.
+		 */
+		cvm_oct_rx_refill_pool(num_packet_buffers / 2);
+		/*
 		 * All ports have been polled. Start the next iteration through
 		 * the ports in one second.
 		 */
@@ -161,7 +180,6 @@ static void cvm_do_timer(unsigned long arg)
  */
 static __init void cvm_oct_configure_common_hw(void)
 {
-	int r;
 	/* Setup the FPA */
 	cvmx_fpa_enable();
 	cvm_oct_mem_fill_fpa(CVMX_FPA_PACKET_POOL, CVMX_FPA_PACKET_POOL_SIZE,
@@ -176,17 +194,6 @@ static __init void cvm_oct_configure_common_hw(void)
 		cvmx_helper_setup_red(num_packet_buffers / 4,
 				      num_packet_buffers / 8);
 
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
@@ -616,7 +623,6 @@ static int __init cvm_oct_init_module(void)
 		cvm_oct_mac_addr_offset = 0;
 
 	cvm_oct_proc_initialize();
-	cvm_oct_rx_initialize();
 	cvm_oct_configure_common_hw();
 
 	cvmx_helper_initialize_packet_io_global();
@@ -781,25 +787,7 @@ static int __init cvm_oct_init_module(void)
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
index 203c6a9..40b6956 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -98,4 +98,7 @@ extern int pow_receive_group;
 extern char pow_send_list[];
 extern struct net_device *cvm_oct_device[];
 
+extern int max_rx_cpus;
+extern int rx_napi_weight;
+
 #endif
-- 
1.6.0.6

