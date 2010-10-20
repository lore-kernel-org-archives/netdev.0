From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 1/5] enic: Add support for multiple hardware
	receive queues
Date: Wed, 20 Oct 2010 13:16:59 -0700
Message-ID: <20101020201658.26870.94910.stgit@savbu-pc100.cisco.com>
References: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:26189 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab0JTUQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 16:16:59 -0400
In-Reply-To: <20101020201609.26870.80308.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Add support for multiple hardware receive queues. The ingress traffic is hashed into one of the receive queues based on IP or TCP or both headers. The max no. of receive queues supported is 8.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |   28 +--
 drivers/net/enic/enic_main.c |  373 +++++++++++++++++++++++++++++++++---------
 drivers/net/enic/enic_res.c  |   49 +++---
 drivers/net/enic/enic_res.h  |    2 
 drivers/net/enic/vnic_rss.h  |   40 +++++
 5 files changed, 368 insertions(+), 124 deletions(-)
 create mode 100644 drivers/net/enic/vnic_rss.h


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index ae62320..c91d364 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -28,10 +28,11 @@
 #include "vnic_intr.h"
 #include "vnic_stats.h"
 #include "vnic_nic.h"
+#include "vnic_rss.h"
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.2a"
+#define DRV_VERSION		"1.4.1.6"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
@@ -41,25 +42,6 @@
 #define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
 #define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
 
-enum enic_cq_index {
-	ENIC_CQ_RQ,
-	ENIC_CQ_WQ,
-};
-
-enum enic_intx_intr_index {
-	ENIC_INTX_WQ_RQ,
-	ENIC_INTX_ERR,
-	ENIC_INTX_NOTIFY,
-};
-
-enum enic_msix_intr_index {
-	ENIC_MSIX_RQ,
-	ENIC_MSIX_WQ,
-	ENIC_MSIX_ERR,
-	ENIC_MSIX_NOTIFY,
-	ENIC_MSIX_MAX,
-};
-
 struct enic_msix_entry {
 	int requested;
 	char devname[IFNAMSIZ];
@@ -90,8 +72,8 @@ struct enic {
 	struct vnic_dev *vdev;
 	struct timer_list notify_timer;
 	struct work_struct reset;
-	struct msix_entry msix_entry[ENIC_MSIX_MAX];
-	struct enic_msix_entry msix[ENIC_MSIX_MAX];
+	struct msix_entry msix_entry[ENIC_INTR_MAX];
+	struct enic_msix_entry msix[ENIC_INTR_MAX];
 	u32 msg_enable;
 	spinlock_t devcmd_lock;
 	u8 mac_addr[ETH_ALEN];
@@ -118,7 +100,7 @@ struct enic {
 	int (*rq_alloc_buf)(struct vnic_rq *rq);
 	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
-	struct napi_struct napi;
+	struct napi_struct napi[ENIC_RQ_MAX];
 
 	/* interrupt resource cache line section */
 	____cacheline_aligned struct vnic_intr intr[ENIC_INTR_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a1f92f1..dcfc541 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -122,6 +122,51 @@ static int enic_is_dynamic(struct enic *enic)
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
 }
 
+static inline unsigned int enic_cq_rq(struct enic *enic, unsigned int rq)
+{
+	return rq;
+}
+
+static inline unsigned int enic_cq_wq(struct enic *enic, unsigned int wq)
+{
+	return enic->rq_count + wq;
+}
+
+static inline unsigned int enic_legacy_io_intr(void)
+{
+	return 0;
+}
+
+static inline unsigned int enic_legacy_err_intr(void)
+{
+	return 1;
+}
+
+static inline unsigned int enic_legacy_notify_intr(void)
+{
+	return 2;
+}
+
+static inline unsigned int enic_msix_rq_intr(struct enic *enic, unsigned int rq)
+{
+	return rq;
+}
+
+static inline unsigned int enic_msix_wq_intr(struct enic *enic, unsigned int wq)
+{
+	return enic->rq_count + wq;
+}
+
+static inline unsigned int enic_msix_err_intr(struct enic *enic)
+{
+	return enic->rq_count + enic->wq_count;
+}
+
+static inline unsigned int enic_msix_notify_intr(struct enic *enic)
+{
+	return enic->rq_count + enic->wq_count + 1;
+}
+
 static int enic_get_settings(struct net_device *netdev,
 	struct ethtool_cmd *ecmd)
 {
@@ -306,6 +351,7 @@ static int enic_set_coalesce(struct net_device *netdev,
 	struct enic *enic = netdev_priv(netdev);
 	u32 tx_coalesce_usecs;
 	u32 rx_coalesce_usecs;
+	unsigned int i, intr;
 
 	tx_coalesce_usecs = min_t(u32,
 		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
@@ -319,7 +365,8 @@ static int enic_set_coalesce(struct net_device *netdev,
 		if (tx_coalesce_usecs != rx_coalesce_usecs)
 			return -EINVAL;
 
-		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_INTX_WQ_RQ],
+		intr = enic_legacy_io_intr();
+		vnic_intr_coalescing_timer_set(&enic->intr[intr],
 			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
 		break;
 	case VNIC_DEV_INTR_MODE_MSI:
@@ -330,10 +377,18 @@ static int enic_set_coalesce(struct net_device *netdev,
 			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
-		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_MSIX_WQ],
-			INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
-		vnic_intr_coalescing_timer_set(&enic->intr[ENIC_MSIX_RQ],
-			INTR_COALESCE_USEC_TO_HW(rx_coalesce_usecs));
+		for (i = 0; i < enic->wq_count; i++) {
+			intr = enic_msix_wq_intr(enic, i);
+			vnic_intr_coalescing_timer_set(&enic->intr[intr],
+				INTR_COALESCE_USEC_TO_HW(tx_coalesce_usecs));
+		}
+
+		for (i = 0; i < enic->rq_count; i++) {
+			intr = enic_msix_rq_intr(enic, i);
+			vnic_intr_coalescing_timer_set(&enic->intr[intr],
+				INTR_COALESCE_USEC_TO_HW(rx_coalesce_usecs));
+		}
+
 		break;
 	default:
 		break;
@@ -482,34 +537,37 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 {
 	struct net_device *netdev = data;
 	struct enic *enic = netdev_priv(netdev);
+	unsigned int io_intr = enic_legacy_io_intr();
+	unsigned int err_intr = enic_legacy_err_intr();
+	unsigned int notify_intr = enic_legacy_notify_intr();
 	u32 pba;
 
-	vnic_intr_mask(&enic->intr[ENIC_INTX_WQ_RQ]);
+	vnic_intr_mask(&enic->intr[io_intr]);
 
 	pba = vnic_intr_legacy_pba(enic->legacy_pba);
 	if (!pba) {
-		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
+		vnic_intr_unmask(&enic->intr[io_intr]);
 		return IRQ_NONE;	/* not our interrupt */
 	}
 
-	if (ENIC_TEST_INTR(pba, ENIC_INTX_NOTIFY)) {
-		vnic_intr_return_all_credits(&enic->intr[ENIC_INTX_NOTIFY]);
+	if (ENIC_TEST_INTR(pba, notify_intr)) {
+		vnic_intr_return_all_credits(&enic->intr[notify_intr]);
 		enic_notify_check(enic);
 	}
 
-	if (ENIC_TEST_INTR(pba, ENIC_INTX_ERR)) {
-		vnic_intr_return_all_credits(&enic->intr[ENIC_INTX_ERR]);
+	if (ENIC_TEST_INTR(pba, err_intr)) {
+		vnic_intr_return_all_credits(&enic->intr[err_intr]);
 		enic_log_q_error(enic);
 		/* schedule recovery from WQ/RQ error */
 		schedule_work(&enic->reset);
 		return IRQ_HANDLED;
 	}
 
-	if (ENIC_TEST_INTR(pba, ENIC_INTX_WQ_RQ)) {
-		if (napi_schedule_prep(&enic->napi))
-			__napi_schedule(&enic->napi);
+	if (ENIC_TEST_INTR(pba, io_intr)) {
+		if (napi_schedule_prep(&enic->napi[0]))
+			__napi_schedule(&enic->napi[0]);
 	} else {
-		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
+		vnic_intr_unmask(&enic->intr[io_intr]);
 	}
 
 	return IRQ_HANDLED;
@@ -535,17 +593,17 @@ static irqreturn_t enic_isr_msi(int irq, void *data)
 	 * writes).
 	 */
 
-	napi_schedule(&enic->napi);
+	napi_schedule(&enic->napi[0]);
 
 	return IRQ_HANDLED;
 }
 
 static irqreturn_t enic_isr_msix_rq(int irq, void *data)
 {
-	struct enic *enic = data;
+	struct napi_struct *napi = data;
 
 	/* schedule NAPI polling for RQ cleanup */
-	napi_schedule(&enic->napi);
+	napi_schedule(napi);
 
 	return IRQ_HANDLED;
 }
@@ -553,13 +611,15 @@ static irqreturn_t enic_isr_msix_rq(int irq, void *data)
 static irqreturn_t enic_isr_msix_wq(int irq, void *data)
 {
 	struct enic *enic = data;
+	unsigned int cq = enic_cq_wq(enic, 0);
+	unsigned int intr = enic_msix_wq_intr(enic, 0);
 	unsigned int wq_work_to_do = -1; /* no limit */
 	unsigned int wq_work_done;
 
-	wq_work_done = vnic_cq_service(&enic->cq[ENIC_CQ_WQ],
+	wq_work_done = vnic_cq_service(&enic->cq[cq],
 		wq_work_to_do, enic_wq_service, NULL);
 
-	vnic_intr_return_credits(&enic->intr[ENIC_MSIX_WQ],
+	vnic_intr_return_credits(&enic->intr[intr],
 		wq_work_done,
 		1 /* unmask intr */,
 		1 /* reset intr timer */);
@@ -570,8 +630,9 @@ static irqreturn_t enic_isr_msix_wq(int irq, void *data)
 static irqreturn_t enic_isr_msix_err(int irq, void *data)
 {
 	struct enic *enic = data;
+	unsigned int intr = enic_msix_err_intr(enic);
 
-	vnic_intr_return_all_credits(&enic->intr[ENIC_MSIX_ERR]);
+	vnic_intr_return_all_credits(&enic->intr[intr]);
 
 	enic_log_q_error(enic);
 
@@ -584,8 +645,9 @@ static irqreturn_t enic_isr_msix_err(int irq, void *data)
 static irqreturn_t enic_isr_msix_notify(int irq, void *data)
 {
 	struct enic *enic = data;
+	unsigned int intr = enic_msix_notify_intr(enic);
 
-	vnic_intr_return_all_credits(&enic->intr[ENIC_MSIX_NOTIFY]);
+	vnic_intr_return_all_credits(&enic->intr[intr]);
 	enic_notify_check(enic);
 
 	return IRQ_HANDLED;
@@ -1409,8 +1471,8 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 			(vlan_tci & CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_MASK)) {
 
 			if (netdev->features & NETIF_F_GRO)
-				vlan_gro_receive(&enic->napi, enic->vlan_group,
-					vlan_tci, skb);
+				vlan_gro_receive(&enic->napi[q_number],
+					enic->vlan_group, vlan_tci, skb);
 			else
 				vlan_hwaccel_receive_skb(skb,
 					enic->vlan_group, vlan_tci);
@@ -1418,12 +1480,11 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		} else {
 
 			if (netdev->features & NETIF_F_GRO)
-				napi_gro_receive(&enic->napi, skb);
+				napi_gro_receive(&enic->napi[q_number], skb);
 			else
 				netif_receive_skb(skb);
 
 		}
-
 	} else {
 
 		/* Buffer overflow
@@ -1447,7 +1508,11 @@ static int enic_rq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 
 static int enic_poll(struct napi_struct *napi, int budget)
 {
-	struct enic *enic = container_of(napi, struct enic, napi);
+	struct net_device *netdev = napi->dev;
+	struct enic *enic = netdev_priv(netdev);
+	unsigned int cq_rq = enic_cq_rq(enic, 0);
+	unsigned int cq_wq = enic_cq_wq(enic, 0);
+	unsigned int intr = enic_legacy_io_intr();
 	unsigned int rq_work_to_do = budget;
 	unsigned int wq_work_to_do = -1; /* no limit */
 	unsigned int  work_done, rq_work_done, wq_work_done;
@@ -1456,10 +1521,10 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	/* Service RQ (first) and WQ
 	 */
 
-	rq_work_done = vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
+	rq_work_done = vnic_cq_service(&enic->cq[cq_rq],
 		rq_work_to_do, enic_rq_service, NULL);
 
-	wq_work_done = vnic_cq_service(&enic->cq[ENIC_CQ_WQ],
+	wq_work_done = vnic_cq_service(&enic->cq[cq_wq],
 		wq_work_to_do, enic_wq_service, NULL);
 
 	/* Accumulate intr event credits for this polling
@@ -1470,7 +1535,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	work_done = rq_work_done + wq_work_done;
 
 	if (work_done > 0)
-		vnic_intr_return_credits(&enic->intr[ENIC_INTX_WQ_RQ],
+		vnic_intr_return_credits(&enic->intr[intr],
 			work_done,
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
@@ -1491,7 +1556,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		 */
 
 		napi_complete(napi);
-		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
+		vnic_intr_unmask(&enic->intr[intr]);
 	}
 
 	return rq_work_done;
@@ -1499,7 +1564,11 @@ static int enic_poll(struct napi_struct *napi, int budget)
 
 static int enic_poll_msix(struct napi_struct *napi, int budget)
 {
-	struct enic *enic = container_of(napi, struct enic, napi);
+	struct net_device *netdev = napi->dev;
+	struct enic *enic = netdev_priv(netdev);
+	unsigned int rq = (napi - &enic->napi[0]);
+	unsigned int cq = enic_cq_rq(enic, rq);
+	unsigned int intr = enic_msix_rq_intr(enic, rq);
 	unsigned int work_to_do = budget;
 	unsigned int work_done;
 	int err;
@@ -1507,7 +1576,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	/* Service RQ
 	 */
 
-	work_done = vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
+	work_done = vnic_cq_service(&enic->cq[cq],
 		work_to_do, enic_rq_service, NULL);
 
 	/* Return intr event credits for this polling
@@ -1516,12 +1585,12 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	 */
 
 	if (work_done > 0)
-		vnic_intr_return_credits(&enic->intr[ENIC_MSIX_RQ],
+		vnic_intr_return_credits(&enic->intr[intr],
 			work_done,
 			0 /* don't unmask intr */,
 			0 /* don't reset intr timer */);
 
-	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
+	err = vnic_rq_fill(&enic->rq[rq], enic->rq_alloc_buf);
 
 	/* Buffer allocation failed. Stay in polling mode
 	 * so we can try to fill the ring again.
@@ -1537,7 +1606,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		 */
 
 		napi_complete(napi);
-		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
+		vnic_intr_unmask(&enic->intr[intr]);
 	}
 
 	return work_done;
@@ -1579,7 +1648,7 @@ static void enic_free_intr(struct enic *enic)
 static int enic_request_intr(struct enic *enic)
 {
 	struct net_device *netdev = enic->netdev;
-	unsigned int i;
+	unsigned int i, intr;
 	int err = 0;
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
@@ -1598,27 +1667,38 @@ static int enic_request_intr(struct enic *enic)
 
 	case VNIC_DEV_INTR_MODE_MSIX:
 
-		sprintf(enic->msix[ENIC_MSIX_RQ].devname,
-			"%.11s-rx-0", netdev->name);
-		enic->msix[ENIC_MSIX_RQ].isr = enic_isr_msix_rq;
-		enic->msix[ENIC_MSIX_RQ].devid = enic;
+		for (i = 0; i < enic->rq_count; i++) {
+			intr = enic_msix_rq_intr(enic, i);
+			sprintf(enic->msix[intr].devname,
+				"%.11s-rx-%d", netdev->name, i);
+			enic->msix[intr].isr = enic_isr_msix_rq;
+			enic->msix[intr].devid = &enic->napi[i];
+		}
 
-		sprintf(enic->msix[ENIC_MSIX_WQ].devname,
-			"%.11s-tx-0", netdev->name);
-		enic->msix[ENIC_MSIX_WQ].isr = enic_isr_msix_wq;
-		enic->msix[ENIC_MSIX_WQ].devid = enic;
+		for (i = 0; i < enic->wq_count; i++) {
+			intr = enic_msix_wq_intr(enic, i);
+			sprintf(enic->msix[intr].devname,
+				"%.11s-tx-%d", netdev->name, i);
+			enic->msix[intr].isr = enic_isr_msix_wq;
+			enic->msix[intr].devid = enic;
+		}
 
-		sprintf(enic->msix[ENIC_MSIX_ERR].devname,
+		intr = enic_msix_err_intr(enic);
+		sprintf(enic->msix[intr].devname,
 			"%.11s-err", netdev->name);
-		enic->msix[ENIC_MSIX_ERR].isr = enic_isr_msix_err;
-		enic->msix[ENIC_MSIX_ERR].devid = enic;
+		enic->msix[intr].isr = enic_isr_msix_err;
+		enic->msix[intr].devid = enic;
 
-		sprintf(enic->msix[ENIC_MSIX_NOTIFY].devname,
+		intr = enic_msix_notify_intr(enic);
+		sprintf(enic->msix[intr].devname,
 			"%.11s-notify", netdev->name);
-		enic->msix[ENIC_MSIX_NOTIFY].isr = enic_isr_msix_notify;
-		enic->msix[ENIC_MSIX_NOTIFY].devid = enic;
+		enic->msix[intr].isr = enic_isr_msix_notify;
+		enic->msix[intr].devid = enic;
+
+		for (i = 0; i < ARRAY_SIZE(enic->msix); i++)
+			enic->msix[i].requested = 0;
 
-		for (i = 0; i < ARRAY_SIZE(enic->msix); i++) {
+		for (i = 0; i < enic->intr_count; i++) {
 			err = request_irq(enic->msix_entry[i].vector,
 				enic->msix[i].isr, 0,
 				enic->msix[i].devname,
@@ -1664,10 +1744,12 @@ static int enic_dev_notify_set(struct enic *enic)
 	spin_lock(&enic->devcmd_lock);
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
-		err = vnic_dev_notify_set(enic->vdev, ENIC_INTX_NOTIFY);
+		err = vnic_dev_notify_set(enic->vdev,
+			enic_legacy_notify_intr());
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
-		err = vnic_dev_notify_set(enic->vdev, ENIC_MSIX_NOTIFY);
+		err = vnic_dev_notify_set(enic->vdev,
+			enic_msix_notify_intr(enic));
 		break;
 	default:
 		err = vnic_dev_notify_set(enic->vdev, -1 /* no intr */);
@@ -1762,7 +1844,10 @@ static int enic_open(struct net_device *netdev)
 	enic_set_multicast_list(netdev);
 
 	netif_wake_queue(netdev);
-	napi_enable(&enic->napi);
+
+	for (i = 0; i < enic->rq_count; i++)
+		napi_enable(&enic->napi[i]);
+
 	enic_dev_enable(enic);
 
 	for (i = 0; i < enic->intr_count; i++)
@@ -1797,7 +1882,10 @@ static int enic_stop(struct net_device *netdev)
 	del_timer_sync(&enic->notify_timer);
 
 	enic_dev_disable(enic);
-	napi_disable(&enic->napi);
+
+	for (i = 0; i < enic->rq_count; i++)
+		napi_disable(&enic->napi[i]);
+
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 	enic_dev_del_station_addr(enic);
@@ -1857,11 +1945,16 @@ static void enic_poll_controller(struct net_device *netdev)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_dev *vdev = enic->vdev;
+	unsigned int i, intr;
 
 	switch (vnic_dev_get_intr_mode(vdev)) {
 	case VNIC_DEV_INTR_MODE_MSIX:
-		enic_isr_msix_rq(enic->pdev->irq, enic);
-		enic_isr_msix_wq(enic->pdev->irq, enic);
+		for (i = 0; i < enic->rq_count; i++) {
+			intr = enic_msix_rq_intr(enic, i);
+			enic_isr_msix_rq(enic->msix_entry[intr].vector, enic);
+		}
+		intr = enic_msix_wq_intr(enic, i);
+		enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);
 		break;
 	case VNIC_DEV_INTR_MODE_MSI:
 		enic_isr_msi(enic->pdev->irq, enic);
@@ -1936,19 +2029,73 @@ static int enic_dev_hang_reset(struct enic *enic)
 	return err;
 }
 
-static int enic_set_niccfg(struct enic *enic)
+static int enic_set_rsskey(struct enic *enic)
+{
+	u64 rss_key_buf_pa;
+	union vnic_rss_key *rss_key_buf_va = NULL;
+	union vnic_rss_key rss_key = {
+		.key[0].b = {85, 67, 83, 97, 119, 101, 115, 111, 109, 101},
+		.key[1].b = {80, 65, 76, 79, 117, 110, 105, 113, 117, 101},
+		.key[2].b = {76, 73, 78, 85, 88, 114, 111, 99, 107, 115},
+		.key[3].b = {69, 78, 73, 67, 105, 115, 99, 111, 111, 108},
+	};
+	int err;
+
+	rss_key_buf_va = pci_alloc_consistent(enic->pdev,
+		sizeof(union vnic_rss_key), &rss_key_buf_pa);
+	if (!rss_key_buf_va)
+		return -ENOMEM;
+
+	memcpy(rss_key_buf_va, &rss_key, sizeof(union vnic_rss_key));
+
+	spin_lock(&enic->devcmd_lock);
+	err = enic_set_rss_key(enic,
+		rss_key_buf_pa,
+		sizeof(union vnic_rss_key));
+	spin_unlock(&enic->devcmd_lock);
+
+	pci_free_consistent(enic->pdev, sizeof(union vnic_rss_key),
+		rss_key_buf_va, rss_key_buf_pa);
+
+	return err;
+}
+
+static int enic_set_rsscpu(struct enic *enic, u8 rss_hash_bits)
+{
+	u64 rss_cpu_buf_pa;
+	union vnic_rss_cpu *rss_cpu_buf_va = NULL;
+	unsigned int i;
+	int err;
+
+	rss_cpu_buf_va = pci_alloc_consistent(enic->pdev,
+		sizeof(union vnic_rss_cpu), &rss_cpu_buf_pa);
+	if (!rss_cpu_buf_va)
+		return -ENOMEM;
+
+	for (i = 0; i < (1 << rss_hash_bits); i++)
+		(*rss_cpu_buf_va).cpu[i/4].b[i%4] = i % enic->rq_count;
+
+	spin_lock(&enic->devcmd_lock);
+	err = enic_set_rss_cpu(enic,
+		rss_cpu_buf_pa,
+		sizeof(union vnic_rss_cpu));
+	spin_unlock(&enic->devcmd_lock);
+
+	pci_free_consistent(enic->pdev, sizeof(union vnic_rss_cpu),
+		rss_cpu_buf_va, rss_cpu_buf_pa);
+
+	return err;
+}
+
+static int enic_set_niccfg(struct enic *enic, u8 rss_default_cpu,
+	u8 rss_hash_type, u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable)
 {
-	const u8 rss_default_cpu = 0;
-	const u8 rss_hash_type = 0;
-	const u8 rss_hash_bits = 0;
-	const u8 rss_base_cpu = 0;
-	const u8 rss_enable = 0;
 	const u8 tso_ipid_split_en = 0;
 	const u8 ig_vlan_strip_en = 1;
 	int err;
 
-	/* Enable VLAN tag stripping.  RSS not enabled (yet).
-	 */
+	/* Enable VLAN tag stripping.
+	*/
 
 	spin_lock(&enic->devcmd_lock);
 	err = enic_set_nic_cfg(enic,
@@ -1961,6 +2108,35 @@ static int enic_set_niccfg(struct enic *enic)
 	return err;
 }
 
+static int enic_set_rss_nic_cfg(struct enic *enic)
+{
+	struct device *dev = enic_get_dev(enic);
+	const u8 rss_default_cpu = 0;
+	const u8 rss_hash_type = NIC_CFG_RSS_HASH_TYPE_IPV4 |
+		NIC_CFG_RSS_HASH_TYPE_TCP_IPV4 |
+		NIC_CFG_RSS_HASH_TYPE_IPV6 |
+		NIC_CFG_RSS_HASH_TYPE_TCP_IPV6;
+	const u8 rss_hash_bits = 7;
+	const u8 rss_base_cpu = 0;
+	u8 rss_enable = ENIC_SETTING(enic, RSS) && (enic->rq_count > 1);
+
+	if (rss_enable) {
+		if (!enic_set_rsskey(enic)) {
+			if (enic_set_rsscpu(enic, rss_hash_bits)) {
+				rss_enable = 0;
+				dev_warn(dev, "RSS disabled, "
+					"Failed to set RSS cpu indirection table.");
+			}
+		} else {
+			rss_enable = 0;
+			dev_warn(dev, "RSS disabled, Failed to set RSS key.\n");
+		}
+	}
+
+	return enic_set_niccfg(enic, rss_default_cpu, rss_hash_type,
+		rss_hash_bits, rss_base_cpu, rss_enable);
+}
+
 static int enic_dev_hang_notify(struct enic *enic)
 {
 	int err;
@@ -1998,7 +2174,7 @@ static void enic_reset(struct work_struct *work)
 	enic_dev_hang_reset(enic);
 	enic_reset_multicast_list(enic);
 	enic_init_vnic_resources(enic);
-	enic_set_niccfg(enic);
+	enic_set_rss_nic_cfg(enic);
 	enic_dev_set_ig_vlan_rewrite_mode(enic);
 	enic_open(enic->netdev);
 
@@ -2007,12 +2183,12 @@ static void enic_reset(struct work_struct *work)
 
 static int enic_set_intr_mode(struct enic *enic)
 {
-	unsigned int n = 1;
+	unsigned int n = min_t(unsigned int, enic->rq_count, ENIC_RQ_MAX);
 	unsigned int m = 1;
 	unsigned int i;
 
 	/* Set interrupt mode (INTx, MSI, MSI-X) depending
-	 * system capabilities.
+	 * on system capabilities.
 	 *
 	 * Try MSI-X first
 	 *
@@ -2025,21 +2201,47 @@ static int enic_set_intr_mode(struct enic *enic)
 	for (i = 0; i < n + m + 2; i++)
 		enic->msix_entry[i].entry = i;
 
-	if (enic->config.intr_mode < 1 &&
+	/* Use multiple RQs if RSS is enabled
+	 */
+
+	if (ENIC_SETTING(enic, RSS) &&
+	    enic->config.intr_mode < 1 &&
 	    enic->rq_count >= n &&
 	    enic->wq_count >= m &&
 	    enic->cq_count >= n + m &&
-	    enic->intr_count >= n + m + 2 &&
-	    !pci_enable_msix(enic->pdev, enic->msix_entry, n + m + 2)) {
+	    enic->intr_count >= n + m + 2) {
 
-		enic->rq_count = n;
-		enic->wq_count = m;
-		enic->cq_count = n + m;
-		enic->intr_count = n + m + 2;
+		if (!pci_enable_msix(enic->pdev, enic->msix_entry, n + m + 2)) {
 
-		vnic_dev_set_intr_mode(enic->vdev, VNIC_DEV_INTR_MODE_MSIX);
+			enic->rq_count = n;
+			enic->wq_count = m;
+			enic->cq_count = n + m;
+			enic->intr_count = n + m + 2;
 
-		return 0;
+			vnic_dev_set_intr_mode(enic->vdev,
+				VNIC_DEV_INTR_MODE_MSIX);
+
+			return 0;
+		}
+	}
+
+	if (enic->config.intr_mode < 1 &&
+	    enic->rq_count >= 1 &&
+	    enic->wq_count >= m &&
+	    enic->cq_count >= 1 + m &&
+	    enic->intr_count >= 1 + m + 2) {
+		if (!pci_enable_msix(enic->pdev, enic->msix_entry, 1 + m + 2)) {
+
+			enic->rq_count = 1;
+			enic->wq_count = m;
+			enic->cq_count = 1 + m;
+			enic->intr_count = 1 + m + 2;
+
+			vnic_dev_set_intr_mode(enic->vdev,
+				VNIC_DEV_INTR_MODE_MSIX);
+
+			return 0;
+		}
 	}
 
 	/* Next try MSI
@@ -2149,7 +2351,11 @@ static const struct net_device_ops enic_netdev_ops = {
 
 static void enic_dev_deinit(struct enic *enic)
 {
-	netif_napi_del(&enic->napi);
+	unsigned int i;
+
+	for (i = 0; i < enic->rq_count; i++)
+		netif_napi_del(&enic->napi[i]);
+
 	enic_free_vnic_resources(enic);
 	enic_clear_intr_mode(enic);
 }
@@ -2158,6 +2364,7 @@ static int enic_dev_init(struct enic *enic)
 {
 	struct device *dev = enic_get_dev(enic);
 	struct net_device *netdev = enic->netdev;
+	unsigned int i;
 	int err;
 
 	/* Get vNIC configuration
@@ -2202,7 +2409,7 @@ static int enic_dev_init(struct enic *enic)
 		goto err_out_free_vnic_resources;
 	}
 
-	err = enic_set_niccfg(enic);
+	err = enic_set_rss_nic_cfg(enic);
 	if (err) {
 		dev_err(dev, "Failed to config nic, aborting\n");
 		goto err_out_free_vnic_resources;
@@ -2217,10 +2424,12 @@ static int enic_dev_init(struct enic *enic)
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	default:
-		netif_napi_add(netdev, &enic->napi, enic_poll, 64);
+		netif_napi_add(netdev, &enic->napi[0], enic_poll, 64);
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
-		netif_napi_add(netdev, &enic->napi, enic_poll_msix, 64);
+		for (i = 0; i < enic->rq_count; i++)
+			netif_napi_add(netdev, &enic->napi[i],
+				enic_poll_msix, 64);
 		break;
 	}
 
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 19a276c..f111a37 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -35,6 +35,7 @@
 #include "vnic_intr.h"
 #include "vnic_stats.h"
 #include "vnic_nic.h"
+#include "vnic_rss.h"
 #include "enic_res.h"
 #include "enic.h"
 
@@ -93,13 +94,14 @@ int enic_get_vnic_config(struct enic *enic)
 		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
 		c->intr_timer_usec);
 
-	dev_info(enic_get_dev(enic), "vNIC MAC addr %pM wq/rq %d/%d\n",
-		enic->mac_addr, c->wq_desc_count, c->rq_desc_count);
-	dev_info(enic_get_dev(enic), "vNIC mtu %d csum tx/rx %d/%d "
-		"tso/lro %d/%d intr timer %d usec\n",
-		c->mtu, ENIC_SETTING(enic, TXCSUM),
-		ENIC_SETTING(enic, RXCSUM), ENIC_SETTING(enic, TSO),
-		ENIC_SETTING(enic, LRO), c->intr_timer_usec);
+	dev_info(enic_get_dev(enic),
+		"vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
+		enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
+	dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
+		"tso/lro %d/%d intr timer %d usec rss %d\n",
+		ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
+		ENIC_SETTING(enic, TSO), ENIC_SETTING(enic, LRO),
+		c->intr_timer_usec, ENIC_SETTING(enic, RSS));
 
 	return 0;
 }
@@ -148,6 +150,22 @@ int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	return vnic_dev_cmd(enic->vdev, CMD_NIC_CFG, &a0, &a1, wait);
 }
 
+int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len)
+{
+	u64 a0 = (u64)key_pa, a1 = len;
+	int wait = 1000;
+
+	return vnic_dev_cmd(enic->vdev, CMD_RSS_KEY, &a0, &a1, wait);
+}
+
+int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len)
+{
+	u64 a0 = (u64)cpu_pa, a1 = len;
+	int wait = 1000;
+
+	return vnic_dev_cmd(enic->vdev, CMD_RSS_CPU, &a0, &a1, wait);
+}
+
 void enic_free_vnic_resources(struct enic *enic)
 {
 	unsigned int i;
@@ -164,18 +182,11 @@ void enic_free_vnic_resources(struct enic *enic)
 
 void enic_get_res_counts(struct enic *enic)
 {
-	enic->wq_count = min_t(int,
-		vnic_dev_get_res_count(enic->vdev, RES_TYPE_WQ),
-		ENIC_WQ_MAX);
-	enic->rq_count = min_t(int,
-		vnic_dev_get_res_count(enic->vdev, RES_TYPE_RQ),
-		ENIC_RQ_MAX);
-	enic->cq_count = min_t(int,
-		vnic_dev_get_res_count(enic->vdev, RES_TYPE_CQ),
-		ENIC_CQ_MAX);
-	enic->intr_count = min_t(int,
-		vnic_dev_get_res_count(enic->vdev, RES_TYPE_INTR_CTRL),
-		ENIC_INTR_MAX);
+	enic->wq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_WQ);
+	enic->rq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_RQ);
+	enic->cq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_CQ);
+	enic->intr_count = vnic_dev_get_res_count(enic->vdev,
+		RES_TYPE_INTR_CTRL);
 
 	dev_info(enic_get_dev(enic),
 		"vNIC resources avail: wq %d rq %d cq %d intr %d\n",
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 3c59f54..83bd172 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -137,6 +137,8 @@ int enic_del_vlan(struct enic *enic, u16 vlanid);
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable, u8 tso_ipid_split_en,
 	u8 ig_vlan_strip_en);
+int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len);
+int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len);
 void enic_get_res_counts(struct enic *enic);
 void enic_init_vnic_resources(struct enic *enic);
 int enic_alloc_vnic_resources(struct enic *);
diff --git a/drivers/net/enic/vnic_rss.h b/drivers/net/enic/vnic_rss.h
new file mode 100644
index 0000000..fa421ba
--- /dev/null
+++ b/drivers/net/enic/vnic_rss.h
@@ -0,0 +1,40 @@
+/*
+ * Copyright 2008-2010 Cisco Systems, Inc.  All rights reserved.
+ * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef _VNIC_RSS_H_
+#define _VNIC_RSS_H_
+
+/* RSS key array */
+union vnic_rss_key {
+	struct {
+		u8 b[10];
+		u8 b_pad[6];
+	} key[4];
+	u64 raw[8];
+};
+
+/* RSS cpu array */
+union vnic_rss_cpu {
+	struct {
+		u8 b[4] ;
+		u8 b_pad[4];
+	} cpu[32];
+	u64 raw[32];
+};
+
+#endif /* _VNIC_RSS_H_ */

