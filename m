From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v2 8/8] enic: do tx cleanup in napi poll
Date: Wed, 18 Jun 2014 13:08:08 +0530
Message-ID: <1403077088-4818-9-git-send-email-_govind@gmx.com>
References: <1403077088-4818-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:53165 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965070AbaFRHk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 03:40:58 -0400
In-Reply-To: <1403077088-4818-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Till now enic had been doing tx clean in isr.

Using napi infrastructure to move the tx clean up out of isr to softirq.
Now, wq isr schedules napi poll. In enic_poll_msix_wq we clean up the tx queus.

This is applicable only on MSIX. In INTx and MSI we use single napi to clean
both rx & tx queues.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |  2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c | 87 +++++++++++++++++------------
 2 files changed, 53 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index b9b9178..c8aa9fb 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -178,7 +178,7 @@ struct enic {
 	unsigned int rq_count;
 	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
-	struct napi_struct napi[ENIC_RQ_MAX];
+	struct napi_struct napi[ENIC_RQ_MAX + ENIC_WQ_MAX];
 
 	/* interrupt resource cache line section */
 	____cacheline_aligned struct vnic_intr intr[ENIC_INTR_MAX];
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index d4918ee..bd81008 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -316,40 +316,15 @@ static irqreturn_t enic_isr_msi(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t enic_isr_msix_rq(int irq, void *data)
+static irqreturn_t enic_isr_msix(int irq, void *data)
 {
 	struct napi_struct *napi = data;
 
-	/* schedule NAPI polling for RQ cleanup */
 	napi_schedule(napi);
 
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t enic_isr_msix_wq(int irq, void *data)
-{
-	struct enic *enic = data;
-	unsigned int cq;
-	unsigned int intr;
-	unsigned int wq_work_to_do = -1; /* no limit */
-	unsigned int wq_work_done;
-	unsigned int wq_irq;
-
-	wq_irq = (u32)irq - enic->msix_entry[enic_msix_wq_intr(enic, 0)].vector;
-	cq = enic_cq_wq(enic, wq_irq);
-	intr = enic_msix_wq_intr(enic, wq_irq);
-
-	wq_work_done = vnic_cq_service(&enic->cq[cq],
-		wq_work_to_do, enic_wq_service, NULL);
-
-	vnic_intr_return_credits(&enic->intr[intr],
-		wq_work_done,
-		1 /* unmask intr */,
-		1 /* reset intr timer */);
-
-	return IRQ_HANDLED;
-}
-
 static irqreturn_t enic_isr_msix_err(int irq, void *data)
 {
 	struct enic *enic = data;
@@ -1273,8 +1248,36 @@ int enic_busy_poll(struct napi_struct *napi)
 	return work_done;
 }
 #endif /* CONFIG_NET_RX_BUSY_POLL */
+static int enic_poll_msix_wq(struct napi_struct *napi, int budget)
+{
+	struct net_device *netdev = napi->dev;
+	struct enic *enic = netdev_priv(netdev);
+	unsigned int wq_index = (napi - &enic->napi[0]) - enic->rq_count;
+	struct vnic_wq *wq = &enic->wq[wq_index];
+	unsigned int cq;
+	unsigned int intr;
+	unsigned int wq_work_to_do = budget;
+	unsigned int wq_work_done;
+	unsigned int wq_irq;
+
+	wq_irq = wq->index;
+	cq = enic_cq_wq(enic, wq_irq);
+	intr = enic_msix_wq_intr(enic, wq_irq);
+	wq_work_done = vnic_cq_service(&enic->cq[cq], wq_work_to_do,
+				       enic_wq_service, NULL);
 
-static int enic_poll_msix(struct napi_struct *napi, int budget)
+	vnic_intr_return_credits(&enic->intr[intr], wq_work_done,
+				 0 /* don't unmask intr */,
+				 1 /* reset intr timer */);
+	if (wq_work_done < wq_work_to_do) {
+		napi_complete(napi);
+		vnic_intr_unmask(&enic->intr[intr]);
+	}
+
+	return wq_work_done;
+}
+
+static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
 	struct enic *enic = netdev_priv(netdev);
@@ -1399,17 +1402,19 @@ static int enic_request_intr(struct enic *enic)
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
 				"%.11s-rx-%d", netdev->name, i);
-			enic->msix[intr].isr = enic_isr_msix_rq;
+			enic->msix[intr].isr = enic_isr_msix;
 			enic->msix[intr].devid = &enic->napi[i];
 		}
 
 		for (i = 0; i < enic->wq_count; i++) {
+			int wq = enic_cq_wq(enic, i);
+
 			intr = enic_msix_wq_intr(enic, i);
 			snprintf(enic->msix[intr].devname,
 				sizeof(enic->msix[intr].devname),
 				"%.11s-tx-%d", netdev->name, i);
-			enic->msix[intr].isr = enic_isr_msix_wq;
-			enic->msix[intr].devid = enic;
+			enic->msix[intr].isr = enic_isr_msix;
+			enic->msix[intr].devid = &enic->napi[wq];
 		}
 
 		intr = enic_msix_err_intr(enic);
@@ -1585,7 +1590,9 @@ static int enic_open(struct net_device *netdev)
 		enic_busy_poll_init_lock(&enic->rq[i]);
 		napi_enable(&enic->napi[i]);
 	}
-
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX)
+		for (i = 0; i < enic->wq_count; i++)
+			napi_enable(&enic->napi[enic_cq_wq(enic, i)]);
 	enic_dev_enable(enic);
 
 	for (i = 0; i < enic->intr_count; i++)
@@ -1633,6 +1640,9 @@ static int enic_stop(struct net_device *netdev)
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX)
+		for (i = 0; i < enic->wq_count; i++)
+			napi_disable(&enic->napi[enic_cq_wq(enic, i)]);
 
 	if (!enic_is_dynamic(enic) && !enic_is_sriov_vf(enic))
 		enic_dev_del_station_addr(enic);
@@ -1752,13 +1762,14 @@ static void enic_poll_controller(struct net_device *netdev)
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < enic->rq_count; i++) {
 			intr = enic_msix_rq_intr(enic, i);
-			enic_isr_msix_rq(enic->msix_entry[intr].vector,
-				&enic->napi[i]);
+			enic_isr_msix(enic->msix_entry[intr].vector,
+				      &enic->napi[i]);
 		}
 
 		for (i = 0; i < enic->wq_count; i++) {
 			intr = enic_msix_wq_intr(enic, i);
-			enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);
+			enic_isr_msix(enic->msix_entry[intr].vector,
+				      &enic->napi[enic_cq_wq(enic, i)]);
 		}
 
 		break;
@@ -2159,6 +2170,9 @@ static void enic_dev_deinit(struct enic *enic)
 		napi_hash_del(&enic->napi[i]);
 		netif_napi_del(&enic->napi[i]);
 	}
+	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX)
+		for (i = 0; i < enic->wq_count; i++)
+			netif_napi_del(&enic->napi[enic_cq_wq(enic, i)]);
 
 	enic_free_vnic_resources(enic);
 	enic_clear_intr_mode(enic);
@@ -2229,9 +2243,12 @@ static int enic_dev_init(struct enic *enic)
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < enic->rq_count; i++) {
 			netif_napi_add(netdev, &enic->napi[i],
-				enic_poll_msix, 64);
+				enic_poll_msix_rq, NAPI_POLL_WEIGHT);
 			napi_hash_add(&enic->napi[i]);
 		}
+		for (i = 0; i < enic->wq_count; i++)
+			netif_napi_add(netdev, &enic->napi[enic_cq_wq(enic, i)],
+				       enic_poll_msix_wq, NAPI_POLL_WEIGHT);
 		break;
 	}
 
-- 
2.0.0
