From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 3/4] vxge: MSIX one shot mode
Date: Tue, 18 Jan 2011 19:02:21 -0600
Message-ID: <1295398942-4131-3-git-send-email-jon.mason@exar.com>
References: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>,
	Masroor Vettuparambil <masroor.vettuparambil@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60338 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906Ab1ASBCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 20:02:42 -0500
Received: by vws16 with SMTP id 16so131144vws.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 17:02:40 -0800 (PST)
In-Reply-To: <1295398942-4131-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To reduce the possibility of losing an interrupt in the handler due to a
race between an interrupt processing and disable/enable of interrupts,
enable MSIX one shot.

Also, add support for adaptive interrupt coalesing

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Masroor Vettuparambil <masroor.vettuparambil@exar.com>
---
 drivers/net/vxge/vxge-config.c  |   30 +++-----
 drivers/net/vxge/vxge-config.h  |   10 +++
 drivers/net/vxge/vxge-main.c    |  159 ++++++++++++++++++++++++++++++++++-----
 drivers/net/vxge/vxge-main.h    |   23 +++++-
 drivers/net/vxge/vxge-traffic.c |  116 ++++++++++++++++++++++++++--
 drivers/net/vxge/vxge-traffic.h |   14 +++-
 6 files changed, 302 insertions(+), 50 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index da35562..77097e3 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -2868,6 +2868,8 @@ __vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
 	ring->rxd_init = attr->rxd_init;
 	ring->rxd_term = attr->rxd_term;
 	ring->buffer_mode = config->buffer_mode;
+	ring->tim_rti_cfg1_saved = vp->vpath->tim_rti_cfg1_saved;
+	ring->tim_rti_cfg3_saved = vp->vpath->tim_rti_cfg3_saved;
 	ring->rxds_limit = config->rxds_limit;
 
 	ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
@@ -3511,6 +3513,8 @@ __vxge_hw_fifo_create(struct __vxge_hw_vpath_handle *vp,
 
 	/* apply "interrupts per txdl" attribute */
 	fifo->interrupt_type = VXGE_HW_FIFO_TXD_INT_TYPE_UTILZ;
+	fifo->tim_tti_cfg1_saved = vpath->tim_tti_cfg1_saved;
+	fifo->tim_tti_cfg3_saved = vpath->tim_tti_cfg3_saved;
 
 	if (fifo->config->intr)
 		fifo->interrupt_type = VXGE_HW_FIFO_TXD_INT_TYPE_PER_LIST;
@@ -4377,6 +4381,8 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 		}
 
 		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+		vpath->tim_tti_cfg1_saved = val64;
+
 		val64 = readq(&vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_TX]);
 
 		if (config->tti.uec_a != VXGE_HW_USE_FLASH_DEFAULT) {
@@ -4433,6 +4439,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 		}
 
 		writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_TX]);
+		vpath->tim_tti_cfg3_saved = val64;
 	}
 
 	if (config->ring.enable == VXGE_HW_RING_ENABLE) {
@@ -4481,6 +4488,8 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 		}
 
 		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_RX]);
+		vpath->tim_rti_cfg1_saved = val64;
+
 		val64 = readq(&vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_RX]);
 
 		if (config->rti.uec_a != VXGE_HW_USE_FLASH_DEFAULT) {
@@ -4537,6 +4546,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 		}
 
 		writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_RX]);
+		vpath->tim_rti_cfg3_saved = val64;
 	}
 
 	val64 = 0;
@@ -4555,26 +4565,6 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 	return status;
 }
 
-void vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
-{
-	struct __vxge_hw_virtualpath *vpath;
-	struct vxge_hw_vpath_reg __iomem *vp_reg;
-	struct vxge_hw_vp_config *config;
-	u64 val64;
-
-	vpath = &hldev->virtual_paths[vp_id];
-	vp_reg = vpath->vp_reg;
-	config = vpath->vp_config;
-
-	if (config->fifo.enable == VXGE_HW_FIFO_ENABLE &&
-	    config->tti.timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) {
-		config->tti.timer_ci_en = VXGE_HW_TIM_TIMER_CI_ENABLE;
-		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
-		val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
-		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
-	}
-}
-
 /*
  * __vxge_hw_vpath_initialize
  * This routine is the final phase of init which initializes the
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index e249e28..3c53aa7 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -682,6 +682,10 @@ struct __vxge_hw_virtualpath {
 	u32				vsport_number;
 	u32				max_kdfc_db;
 	u32				max_nofl_db;
+	u64				tim_tti_cfg1_saved;
+	u64				tim_tti_cfg3_saved;
+	u64				tim_rti_cfg1_saved;
+	u64				tim_rti_cfg3_saved;
 
 	struct __vxge_hw_ring *____cacheline_aligned ringh;
 	struct __vxge_hw_fifo *____cacheline_aligned fifoh;
@@ -921,6 +925,9 @@ struct __vxge_hw_ring {
 	u32					doorbell_cnt;
 	u32					total_db_cnt;
 	u64					rxds_limit;
+	u32					rtimer;
+	u64					tim_rti_cfg1_saved;
+	u64					tim_rti_cfg3_saved;
 
 	enum vxge_hw_status (*callback)(
 			struct __vxge_hw_ring *ringh,
@@ -1000,6 +1007,9 @@ struct __vxge_hw_fifo {
 	u32					per_txdl_space;
 	u32					vp_id;
 	u32					tx_intr_num;
+	u32					rtimer;
+	u64					tim_tti_cfg1_saved;
+	u64					tim_tti_cfg3_saved;
 
 	enum vxge_hw_status (*callback)(
 			struct __vxge_hw_fifo *fifo_handle,
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 9d4b0e8..6c33eab 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -371,9 +371,6 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 	struct vxge_hw_ring_rxd_info ext_info;
 	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
 		ring->ndev->name, __func__, __LINE__);
-	ring->pkts_processed = 0;
-
-	vxge_hw_ring_replenish(ringh);
 
 	do {
 		prefetch((char *)dtr + L1_CACHE_BYTES);
@@ -1588,6 +1585,36 @@ static int vxge_reset_vpath(struct vxgedev *vdev, int vp_id)
 	return ret;
 }
 
+/* Configure CI */
+static void vxge_config_ci_for_tti_rti(struct vxgedev *vdev)
+{
+	int i = 0;
+
+	/* Enable CI for RTI */
+	if (vdev->config.intr_type == MSI_X) {
+		for (i = 0; i < vdev->no_of_vpath; i++) {
+			struct __vxge_hw_ring *hw_ring;
+
+			hw_ring = vdev->vpaths[i].ring.handle;
+			vxge_hw_vpath_dynamic_rti_ci_set(hw_ring);
+		}
+	}
+
+	/* Enable CI for TTI */
+	for (i = 0; i < vdev->no_of_vpath; i++) {
+		struct __vxge_hw_fifo *hw_fifo = vdev->vpaths[i].fifo.handle;
+		vxge_hw_vpath_tti_ci_set(hw_fifo);
+		/*
+		 * For Inta (with or without napi), Set CI ON for only one
+		 * vpath. (Have only one free running timer).
+		 */
+		if ((vdev->config.intr_type == INTA) && (i == 0))
+			break;
+	}
+
+	return;
+}
+
 static int do_vxge_reset(struct vxgedev *vdev, int event)
 {
 	enum vxge_hw_status status;
@@ -1753,6 +1780,9 @@ static int do_vxge_reset(struct vxgedev *vdev, int event)
 		netif_tx_wake_all_queues(vdev->ndev);
 	}
 
+	/* configure CI */
+	vxge_config_ci_for_tti_rti(vdev);
+
 out:
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s:%d  Exiting...", __func__, __LINE__);
@@ -1793,22 +1823,29 @@ static void vxge_reset(struct work_struct *work)
  */
 static int vxge_poll_msix(struct napi_struct *napi, int budget)
 {
-	struct vxge_ring *ring =
-		container_of(napi, struct vxge_ring, napi);
+	struct vxge_ring *ring = container_of(napi, struct vxge_ring, napi);
+	int pkts_processed;
 	int budget_org = budget;
-	ring->budget = budget;
 
+	ring->budget = budget;
+	ring->pkts_processed = 0;
 	vxge_hw_vpath_poll_rx(ring->handle);
+	pkts_processed = ring->pkts_processed;
 
 	if (ring->pkts_processed < budget_org) {
 		napi_complete(napi);
+
 		/* Re enable the Rx interrupts for the vpath */
 		vxge_hw_channel_msix_unmask(
 				(struct __vxge_hw_channel *)ring->handle,
 				ring->rx_vector_no);
+		mmiowb();
 	}
 
-	return ring->pkts_processed;
+	/* We are copying and returning the local variable, in case if after
+	 * clearing the msix interrupt above, if the interrupt fires right
+	 * away which can preempt this NAPI thread */
+	return pkts_processed;
 }
 
 static int vxge_poll_inta(struct napi_struct *napi, int budget)
@@ -1824,6 +1861,7 @@ static int vxge_poll_inta(struct napi_struct *napi, int budget)
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		ring = &vdev->vpaths[i].ring;
 		ring->budget = budget;
+		ring->pkts_processed = 0;
 		vxge_hw_vpath_poll_rx(ring->handle);
 		pkts_processed += ring->pkts_processed;
 		budget -= ring->pkts_processed;
@@ -2054,6 +2092,7 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 					netdev_get_tx_queue(vdev->ndev, 0);
 			vpath->fifo.indicate_max_pkts =
 				vdev->config.fifo_indicate_max_pkts;
+			vpath->fifo.tx_vector_no = 0;
 			vpath->ring.rx_vector_no = 0;
 			vpath->ring.rx_csum = vdev->rx_csum;
 			vpath->ring.rx_hwts = vdev->rx_hwts;
@@ -2079,6 +2118,61 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 	return VXGE_HW_OK;
 }
 
+/**
+ *  adaptive_coalesce_tx_interrupts - Changes the interrupt coalescing
+ *  if the interrupts are not within a range
+ *  @fifo: pointer to transmit fifo structure
+ *  Description: The function changes boundary timer and restriction timer
+ *  value depends on the traffic
+ *  Return Value: None
+ */
+static void adaptive_coalesce_tx_interrupts(struct vxge_fifo *fifo)
+{
+	fifo->interrupt_count++;
+	if (jiffies > fifo->jiffies + HZ / 100) {
+		struct __vxge_hw_fifo *hw_fifo = fifo->handle;
+
+		fifo->jiffies = jiffies;
+		if (fifo->interrupt_count > VXGE_T1A_MAX_TX_INTERRUPT_COUNT &&
+		    hw_fifo->rtimer != VXGE_TTI_RTIMER_ADAPT_VAL) {
+			hw_fifo->rtimer = VXGE_TTI_RTIMER_ADAPT_VAL;
+			vxge_hw_vpath_dynamic_tti_rtimer_set(hw_fifo);
+		} else if (hw_fifo->rtimer != 0) {
+			hw_fifo->rtimer = 0;
+			vxge_hw_vpath_dynamic_tti_rtimer_set(hw_fifo);
+		}
+		fifo->interrupt_count = 0;
+	}
+}
+
+/**
+ *  adaptive_coalesce_rx_interrupts - Changes the interrupt coalescing
+ *  if the interrupts are not within a range
+ *  @ring: pointer to receive ring structure
+ *  Description: The function increases of decreases the packet counts within
+ *  the ranges of traffic utilization, if the interrupts due to this ring are
+ *  not within a fixed range.
+ *  Return Value: Nothing
+ */
+static void adaptive_coalesce_rx_interrupts(struct vxge_ring *ring)
+{
+	ring->interrupt_count++;
+	if (jiffies > ring->jiffies + HZ / 100) {
+		struct __vxge_hw_ring *hw_ring = ring->handle;
+
+		ring->jiffies = jiffies;
+		if (ring->interrupt_count > VXGE_T1A_MAX_INTERRUPT_COUNT &&
+		    hw_ring->rtimer != VXGE_RTI_RTIMER_ADAPT_VAL) {
+			hw_ring->rtimer = VXGE_RTI_RTIMER_ADAPT_VAL;
+			vxge_hw_vpath_dynamic_rti_rtimer_set(hw_ring);
+		} else if (hw_ring->rtimer != 0) {
+			hw_ring->rtimer = 0;
+			vxge_hw_vpath_dynamic_rti_rtimer_set(hw_ring);
+		}
+		ring->interrupt_count = 0;
+	}
+}
+
 /*
  *  vxge_isr_napi
  *  @irq: the irq of the device.
@@ -2139,24 +2233,39 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 
 #ifdef CONFIG_PCI_MSI
 
-static irqreturn_t
-vxge_tx_msix_handle(int irq, void *dev_id)
+static irqreturn_t vxge_tx_msix_handle(int irq, void *dev_id)
 {
 	struct vxge_fifo *fifo = (struct vxge_fifo *)dev_id;
 
+	adaptive_coalesce_tx_interrupts(fifo);
+
+	vxge_hw_channel_msix_mask((struct __vxge_hw_channel *)fifo->handle,
+				  fifo->tx_vector_no);
+
+	vxge_hw_channel_msix_clear((struct __vxge_hw_channel *)fifo->handle,
+				   fifo->tx_vector_no);
+
 	VXGE_COMPLETE_VPATH_TX(fifo);
 
+	vxge_hw_channel_msix_unmask((struct __vxge_hw_channel *)fifo->handle,
+				    fifo->tx_vector_no);
+
+	mmiowb();
+
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t
-vxge_rx_msix_napi_handle(int irq, void *dev_id)
+static irqreturn_t vxge_rx_msix_napi_handle(int irq, void *dev_id)
 {
 	struct vxge_ring *ring = (struct vxge_ring *)dev_id;
 
-	/* MSIX_IDX for Rx is 1 */
+	adaptive_coalesce_rx_interrupts(ring);
+
 	vxge_hw_channel_msix_mask((struct __vxge_hw_channel *)ring->handle,
-					ring->rx_vector_no);
+				  ring->rx_vector_no);
+
+	vxge_hw_channel_msix_clear((struct __vxge_hw_channel *)ring->handle,
+				   ring->rx_vector_no);
 
 	napi_schedule(&ring->napi);
 	return IRQ_HANDLED;
@@ -2173,14 +2282,20 @@ vxge_alarm_msix_handle(int irq, void *dev_id)
 		VXGE_HW_VPATH_MSIX_ACTIVE) + VXGE_ALARM_MSIX_ID;
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
+		/* Reduce the chance of loosing alarm interrupts by masking
+		 * the vector. A pending bit will be set if an alarm is
+		 * generated and on unmask the interrupt will be fired.
+		 */
 		vxge_hw_vpath_msix_mask(vdev->vpaths[i].handle, msix_id);
+		vxge_hw_vpath_msix_clear(vdev->vpaths[i].handle, msix_id);
+		mmiowb();
 
 		status = vxge_hw_vpath_alarm_process(vdev->vpaths[i].handle,
 			vdev->exec_mode);
 		if (status == VXGE_HW_OK) {
-
 			vxge_hw_vpath_msix_unmask(vdev->vpaths[i].handle,
-					msix_id);
+						  msix_id);
+			mmiowb();
 			continue;
 		}
 		vxge_debug_intr(VXGE_ERR,
@@ -2299,6 +2414,9 @@ static int vxge_enable_msix(struct vxgedev *vdev)
 			vpath->ring.rx_vector_no = (vpath->device_id *
 						VXGE_HW_VPATH_MSIX_ACTIVE) + 1;
 
+			vpath->fifo.tx_vector_no = (vpath->device_id *
+						VXGE_HW_VPATH_MSIX_ACTIVE);
+
 			vxge_hw_vpath_msix_set(vpath->handle, tim_msix_id,
 					       VXGE_ALARM_MSIX_ID);
 		}
@@ -2474,8 +2592,9 @@ INTA_MODE:
 			"%s:vxge:INTA", vdev->ndev->name);
 		vxge_hw_device_set_intr_type(vdev->devh,
 			VXGE_HW_INTR_MODE_IRQLINE);
-		vxge_hw_vpath_tti_ci_set(vdev->devh,
-			vdev->vpaths[0].device_id);
+
+		vxge_hw_vpath_tti_ci_set(vdev->vpaths[0].fifo.handle);
+
 		ret = request_irq((int) vdev->pdev->irq,
 			vxge_isr_napi,
 			IRQF_SHARED, vdev->desc[0], vdev);
@@ -2745,6 +2864,10 @@ static int vxge_open(struct net_device *dev)
 	}
 
 	netif_tx_start_all_queues(vdev->ndev);
+
+	/* configure CI */
+	vxge_config_ci_for_tti_rti(vdev);
+
 	goto out0;
 
 out2:
@@ -3804,7 +3927,7 @@ static void __devinit vxge_device_config_init(
 		break;
 
 	case MSI_X:
-		device_config->intr_mode = VXGE_HW_INTR_MODE_MSIX;
+		device_config->intr_mode = VXGE_HW_INTR_MODE_MSIX_ONE_SHOT;
 		break;
 	}
 
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 5746fed..40474f0 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -59,11 +59,13 @@
 #define VXGE_TTI_LTIMER_VAL	1000
 #define VXGE_T1A_TTI_LTIMER_VAL	80
 #define VXGE_TTI_RTIMER_VAL	0
+#define VXGE_TTI_RTIMER_ADAPT_VAL	10
 #define VXGE_T1A_TTI_RTIMER_VAL	400
 #define VXGE_RTI_BTIMER_VAL	250
 #define VXGE_RTI_LTIMER_VAL	100
 #define VXGE_RTI_RTIMER_VAL	0
-#define VXGE_FIFO_INDICATE_MAX_PKTS VXGE_DEF_FIFO_LENGTH
+#define VXGE_RTI_RTIMER_ADAPT_VAL	15
+#define VXGE_FIFO_INDICATE_MAX_PKTS	VXGE_DEF_FIFO_LENGTH
 #define VXGE_ISR_POLLING_CNT 	8
 #define VXGE_MAX_CONFIG_DEV	0xFF
 #define VXGE_EXEC_MODE_DISABLE	0
@@ -107,6 +109,14 @@
 #define RTI_T1A_RX_UFC_C	50
 #define RTI_T1A_RX_UFC_D	60
 
+/*
+ * The interrupt rate is maintained at 3k per second with the moderation
+ * parameters for most traffic but not all. This is the maximum interrupt
+ * count allowed per function with INTA or per vector in the case of
+ * MSI-X in a 10 millisecond time period. Enabled only for Titan 1A.
+ */
+#define VXGE_T1A_MAX_INTERRUPT_COUNT	100
+#define VXGE_T1A_MAX_TX_INTERRUPT_COUNT	200
 
 /* Milli secs timer period */
 #define VXGE_TIMER_DELAY		10000
@@ -247,6 +257,11 @@ struct vxge_fifo {
 	int tx_steering_type;
 	int indicate_max_pkts;
 
+	/* Adaptive interrupt moderation parameters used in T1A */
+	unsigned long interrupt_count;
+	unsigned long jiffies;
+
+	u32 tx_vector_no;
 	/* Tx stats */
 	struct vxge_fifo_stats stats;
 } ____cacheline_aligned;
@@ -271,6 +286,10 @@ struct vxge_ring {
 	 */
 	int driver_id;
 
+	/* Adaptive interrupt moderation parameters used in T1A */
+	unsigned long interrupt_count;
+	unsigned long jiffies;
+
 	/* copy of the flag indicating whether rx_csum is to be used */
 	u32 rx_csum:1,
 	    rx_hwts:1;
@@ -286,7 +305,7 @@ struct vxge_ring {
 
 	int vlan_tag_strip;
 	struct vlan_group *vlgrp;
-	int rx_vector_no;
+	u32 rx_vector_no;
 	enum vxge_hw_status last_status;
 
 	/* Rx stats */
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 4c10d6c..8674f33 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -218,6 +218,68 @@ exit:
 	return status;
 }
 
+void vxge_hw_vpath_tti_ci_set(struct __vxge_hw_fifo *fifo)
+{
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+	struct vxge_hw_vp_config *config;
+	u64 val64;
+
+	if (fifo->config->enable != VXGE_HW_FIFO_ENABLE)
+		return;
+
+	vp_reg = fifo->vp_reg;
+	config = container_of(fifo->config, struct vxge_hw_vp_config, fifo);
+
+	if (config->tti.timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) {
+		config->tti.timer_ci_en = VXGE_HW_TIM_TIMER_CI_ENABLE;
+		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+		val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		fifo->tim_tti_cfg1_saved = val64;
+		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+	}
+}
+
+void vxge_hw_vpath_dynamic_rti_ci_set(struct __vxge_hw_ring *ring)
+{
+	u64 val64 = ring->tim_rti_cfg1_saved;
+
+	val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+	ring->tim_rti_cfg1_saved = val64;
+	writeq(val64, &ring->vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_RX]);
+}
+
+void vxge_hw_vpath_dynamic_tti_rtimer_set(struct __vxge_hw_fifo *fifo)
+{
+	u64 val64 = fifo->tim_tti_cfg3_saved;
+	u64 timer = (fifo->rtimer * 1000) / 272;
+
+	val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(0x3ffffff);
+	if (timer)
+		val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(timer) |
+			VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_EVENT_SF(5);
+
+	writeq(val64, &fifo->vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_TX]);
+	/* tti_cfg3_saved is not updated again because it is
+	 * initialized at one place only - init time.
+	 */
+}
+
+void vxge_hw_vpath_dynamic_rti_rtimer_set(struct __vxge_hw_ring *ring)
+{
+	u64 val64 = ring->tim_rti_cfg3_saved;
+	u64 timer = (ring->rtimer * 1000) / 272;
+
+	val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(0x3ffffff);
+	if (timer)
+		val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(timer) |
+			VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_EVENT_SF(4);
+
+	writeq(val64, &ring->vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_RX]);
+	/* rti_cfg3_saved is not updated again because it is
+	 * initialized at one place only - init time.
+	 */
+}
+
 /**
  * vxge_hw_channel_msix_mask - Mask MSIX Vector.
  * @channeh: Channel for rx or tx handle
@@ -254,6 +316,23 @@ vxge_hw_channel_msix_unmask(struct __vxge_hw_channel *channel, int msix_id)
 }
 
 /**
+ * vxge_hw_channel_msix_clear - Unmask the MSIX Vector.
+ * @channel: Channel for rx or tx handle
+ * @msix_id:  MSI ID
+ *
+ * The function unmasks the msix interrupt for the given msix_id
+ * if configured in MSIX oneshot mode
+ *
+ * Returns: 0
+ */
+void vxge_hw_channel_msix_clear(struct __vxge_hw_channel *channel, int msix_id)
+{
+	__vxge_hw_pio_mem_write32_upper(
+		(u32) vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
+		&channel->common_reg->clr_msix_one_shot_vec[msix_id % 4]);
+}
+
+/**
  * vxge_hw_device_set_intr_type - Updates the configuration
  *		with new interrupt type.
  * @hldev: HW device handle.
@@ -2191,19 +2270,14 @@ vxge_hw_vpath_msix_set(struct __vxge_hw_vpath_handle *vp, int *tim_msix_id,
 	if (vpath->hldev->config.intr_mode ==
 					VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) {
 		__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(
+				VXGE_HW_ONE_SHOT_VECT0_EN_ONE_SHOT_VECT0_EN,
+				0, 32), &vp_reg->one_shot_vect0_en);
+		__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(
 				VXGE_HW_ONE_SHOT_VECT1_EN_ONE_SHOT_VECT1_EN,
 				0, 32), &vp_reg->one_shot_vect1_en);
-	}
-
-	if (vpath->hldev->config.intr_mode ==
-		VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) {
 		__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(
 				VXGE_HW_ONE_SHOT_VECT2_EN_ONE_SHOT_VECT2_EN,
 				0, 32), &vp_reg->one_shot_vect2_en);
-
-		__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(
-				VXGE_HW_ONE_SHOT_VECT3_EN_ONE_SHOT_VECT3_EN,
-				0, 32), &vp_reg->one_shot_vect3_en);
 	}
 }
 
@@ -2229,6 +2303,32 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw_vpath_handle *vp, int msix_id)
 }
 
 /**
+ * vxge_hw_vpath_msix_clear - Clear MSIX Vector.
+ * @vp: Virtual Path handle.
+ * @msix_id:  MSI ID
+ *
+ * The function clears the msix interrupt for the given msix_id
+ *
+ * Returns: 0,
+ * Otherwise, VXGE_HW_ERR_WRONG_IRQ if the msix index is out of range
+ * status.
+ * See also:
+ */
+void vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vp, int msix_id)
+{
+	struct __vxge_hw_device *hldev = vp->vpath->hldev;
+
+	if ((hldev->config.intr_mode == VXGE_HW_INTR_MODE_MSIX_ONE_SHOT))
+		__vxge_hw_pio_mem_write32_upper(
+			(u32) vxge_bVALn(vxge_mBIT((msix_id >> 2)), 0, 32),
+			&hldev->common_reg->clr_msix_one_shot_vec[msix_id % 4]);
+	else
+		__vxge_hw_pio_mem_write32_upper(
+			(u32) vxge_bVALn(vxge_mBIT((msix_id >> 2)), 0, 32),
+			&hldev->common_reg->clear_msix_mask_vect[msix_id % 4]);
+}
+
+/**
  * vxge_hw_vpath_msix_unmask - Unmask the MSIX Vector.
  * @vp: Virtual Path handle.
  * @msix_id:  MSI ID
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 8c3103f..760c319 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -2142,6 +2142,10 @@ void vxge_hw_device_clear_tx_rx(
  *  Virtual Paths
  */
 
+void vxge_hw_vpath_dynamic_rti_rtimer_set(struct __vxge_hw_ring *ring);
+
+void vxge_hw_vpath_dynamic_tti_rtimer_set(struct __vxge_hw_fifo *fifo);
+
 u32 vxge_hw_vpath_id(
 	struct __vxge_hw_vpath_handle *vpath_handle);
 
@@ -2245,6 +2249,8 @@ void
 vxge_hw_vpath_msix_mask(struct __vxge_hw_vpath_handle *vpath_handle,
 			int msix_id);
 
+void vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vp, int msix_id);
+
 void vxge_hw_device_flush_io(struct __vxge_hw_device *devh);
 
 void
@@ -2270,6 +2276,9 @@ void
 vxge_hw_channel_msix_unmask(struct __vxge_hw_channel *channelh, int msix_id);
 
 void
+vxge_hw_channel_msix_clear(struct __vxge_hw_channel *channelh, int msix_id);
+
+void
 vxge_hw_channel_dtr_try_complete(struct __vxge_hw_channel *channel,
 				 void **dtrh);
 
@@ -2282,7 +2291,8 @@ vxge_hw_channel_dtr_free(struct __vxge_hw_channel *channel, void *dtrh);
 int
 vxge_hw_channel_dtr_count(struct __vxge_hw_channel *channel);
 
-void
-vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id);
+void vxge_hw_vpath_tti_ci_set(struct __vxge_hw_fifo *fifo);
+
+void vxge_hw_vpath_dynamic_rti_ci_set(struct __vxge_hw_ring *ring);
 
 #endif
-- 
1.7.0.4

