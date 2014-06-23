From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next v3 7/8] enic: add low latency socket busy_poll support
Date: Mon, 23 Jun 2014 16:08:04 +0530
Message-ID: <1403519885-4908-8-git-send-email-_govind@gmx.com>
References: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53014 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666AbaFWKlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 06:41:17 -0400
In-Reply-To: <1403519885-4908-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for low latency busy_poll.

* Introduce drivers ndo_busy_poll function enic_busy_poll, which is called by
socket waiting for data.

* Introduce locking between napi_poll nad busy_poll

* enic_busy_poll cleans up all the rx pkts possible. While in busy_poll, rq
holds the state ENIC_POLL_STATE_POLL. While in napi_poll, rq holds the state
ENIC_POLL_STATE_NAPI.

* in napi_poll we return if we are in busy_poll. Incase of INTx & msix, we just
service wq and return if busy_poll is going on.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |  85 ++++++++++++++++---
 drivers/net/ethernet/cisco/enic/vnic_rq.h   | 122 ++++++++++++++++++++++++++++
 2 files changed, 195 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 5448df2..d4918ee 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -42,6 +42,9 @@
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+#include <net/busy_poll.h>
+#endif
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -1053,10 +1056,12 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		if (vlan_stripped)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
 
-		if (netdev->features & NETIF_F_GRO)
-			napi_gro_receive(&enic->napi[q_number], skb);
-		else
+		skb_mark_napi_id(skb, &enic->napi[rq->index]);
+		if (enic_poll_busy_polling(rq) ||
+		    !(netdev->features & NETIF_F_GRO))
 			netif_receive_skb(skb);
+		else
+			napi_gro_receive(&enic->napi[q_number], skb);
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_intr_update_pkt_size(&cq->pkt_size_counter,
 						  bytes_written);
@@ -1093,16 +1098,22 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	unsigned int  work_done, rq_work_done = 0, wq_work_done;
 	int err;
 
-	/* Service RQ (first) and WQ
-	 */
+	wq_work_done = vnic_cq_service(&enic->cq[cq_wq], wq_work_to_do,
+				       enic_wq_service, NULL);
+
+	if (!enic_poll_lock_napi(&enic->rq[cq_rq])) {
+		if (wq_work_done > 0)
+			vnic_intr_return_credits(&enic->intr[intr],
+						 wq_work_done,
+						 0 /* dont unmask intr */,
+						 0 /* dont reset intr timer */);
+		return rq_work_done;
+	}
 
 	if (budget > 0)
 		rq_work_done = vnic_cq_service(&enic->cq[cq_rq],
 			rq_work_to_do, enic_rq_service, NULL);
 
-	wq_work_done = vnic_cq_service(&enic->cq[cq_wq],
-		wq_work_to_do, enic_wq_service, NULL);
-
 	/* Accumulate intr event credits for this polling
 	 * cycle.  An intr event is the completion of a
 	 * a WQ or RQ packet.
@@ -1134,6 +1145,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
+	enic_poll_unlock_napi(&enic->rq[cq_rq]);
 
 	return rq_work_done;
 }
@@ -1234,6 +1246,34 @@ static void enic_set_rx_cpu_rmap(struct enic *enic)
 
 #endif /* CONFIG_RFS_ACCEL */
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+int enic_busy_poll(struct napi_struct *napi)
+{
+	struct net_device *netdev = napi->dev;
+	struct enic *enic = netdev_priv(netdev);
+	unsigned int rq = (napi - &enic->napi[0]);
+	unsigned int cq = enic_cq_rq(enic, rq);
+	unsigned int intr = enic_msix_rq_intr(enic, rq);
+	unsigned int work_to_do = -1; /* clean all pkts possible */
+	unsigned int work_done;
+
+	if (!enic_poll_lock_poll(&enic->rq[rq]))
+		return LL_FLUSH_BUSY;
+	work_done = vnic_cq_service(&enic->cq[cq], work_to_do,
+				    enic_rq_service, NULL);
+
+	if (work_done > 0)
+		vnic_intr_return_credits(&enic->intr[intr],
+					 work_done, 0, 0);
+	vnic_rq_fill(&enic->rq[rq], enic_rq_alloc_buf);
+	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+		enic_calc_int_moderation(enic, &enic->rq[rq]);
+	enic_poll_unlock_poll(&enic->rq[rq]);
+
+	return work_done;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 static int enic_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
@@ -1245,6 +1285,8 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	unsigned int work_done = 0;
 	int err;
 
+	if (!enic_poll_lock_napi(&enic->rq[rq]))
+		return work_done;
 	/* Service RQ
 	 */
 
@@ -1290,6 +1332,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 			enic_set_int_moderation(enic, &enic->rq[rq]);
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
+	enic_poll_unlock_napi(&enic->rq[rq]);
 
 	return work_done;
 }
@@ -1538,8 +1581,10 @@ static int enic_open(struct net_device *netdev)
 
 	netif_tx_wake_all_queues(netdev);
 
-	for (i = 0; i < enic->rq_count; i++)
+	for (i = 0; i < enic->rq_count; i++) {
+		enic_busy_poll_init_lock(&enic->rq[i]);
 		napi_enable(&enic->napi[i]);
+	}
 
 	enic_dev_enable(enic);
 
@@ -1578,8 +1623,13 @@ static int enic_stop(struct net_device *netdev)
 
 	enic_dev_disable(enic);
 
-	for (i = 0; i < enic->rq_count; i++)
+	local_bh_disable();
+	for (i = 0; i < enic->rq_count; i++) {
 		napi_disable(&enic->napi[i]);
+		while (!enic_poll_lock_napi(&enic->rq[i]))
+			mdelay(1);
+	}
+	local_bh_enable();
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
@@ -2070,6 +2120,9 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= enic_busy_poll,
+#endif
 };
 
 static const struct net_device_ops enic_netdev_ops = {
@@ -2093,14 +2146,19 @@ static const struct net_device_ops enic_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
+#ifdef CONFIG_NET_RX_BUSY_POLL
+	.ndo_busy_poll		= enic_busy_poll,
+#endif
 };
 
 static void enic_dev_deinit(struct enic *enic)
 {
 	unsigned int i;
 
-	for (i = 0; i < enic->rq_count; i++)
+	for (i = 0; i < enic->rq_count; i++) {
+		napi_hash_del(&enic->napi[i]);
 		netif_napi_del(&enic->napi[i]);
+	}
 
 	enic_free_vnic_resources(enic);
 	enic_clear_intr_mode(enic);
@@ -2166,11 +2224,14 @@ static int enic_dev_init(struct enic *enic)
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	default:
 		netif_napi_add(netdev, &enic->napi[0], enic_poll, 64);
+		napi_hash_add(&enic->napi[0]);
 		break;
 	case VNIC_DEV_INTR_MODE_MSIX:
-		for (i = 0; i < enic->rq_count; i++)
+		for (i = 0; i < enic->rq_count; i++) {
 			netif_napi_add(netdev, &enic->napi[i],
 				enic_poll_msix, 64);
+			napi_hash_add(&enic->napi[i]);
+		}
 		break;
 	}
 
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
index ee7bc95..8111d52 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
@@ -85,6 +85,21 @@ struct vnic_rq {
 	struct vnic_rq_buf *to_clean;
 	void *os_buf_head;
 	unsigned int pkts_outstanding;
+#ifdef CONFIG_NET_RX_BUSY_POLL
+#define ENIC_POLL_STATE_IDLE		0
+#define ENIC_POLL_STATE_NAPI		(1 << 0) /* NAPI owns this poll */
+#define ENIC_POLL_STATE_POLL		(1 << 1) /* poll owns this poll */
+#define ENIC_POLL_STATE_NAPI_YIELD	(1 << 2) /* NAPI yielded this poll */
+#define ENIC_POLL_STATE_POLL_YIELD	(1 << 3) /* poll yielded this poll */
+#define ENIC_POLL_YIELD			(ENIC_POLL_STATE_NAPI_YIELD |	\
+					 ENIC_POLL_STATE_POLL_YIELD)
+#define ENIC_POLL_LOCKED		(ENIC_POLL_STATE_NAPI |		\
+					 ENIC_POLL_STATE_POLL)
+#define ENIC_POLL_USER_PEND		(ENIC_POLL_STATE_POLL |		\
+					 ENIC_POLL_STATE_POLL_YIELD)
+	unsigned int bpoll_state;
+	spinlock_t bpoll_lock;
+#endif /* CONFIG_NET_RX_BUSY_POLL */
 };
 
 static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
@@ -197,6 +212,113 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 	return 0;
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+static inline void enic_busy_poll_init_lock(struct vnic_rq *rq)
+{
+	spin_lock_init(&rq->bpoll_lock);
+	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
+}
+
+static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
+{
+	bool rc = true;
+
+	spin_lock(&rq->bpoll_lock);
+	if (rq->bpoll_state & ENIC_POLL_LOCKED) {
+		WARN_ON(rq->bpoll_state & ENIC_POLL_STATE_NAPI);
+		rq->bpoll_state |= ENIC_POLL_STATE_NAPI_YIELD;
+		rc = false;
+	} else {
+		rq->bpoll_state = ENIC_POLL_STATE_NAPI;
+	}
+	spin_unlock(&rq->bpoll_lock);
+
+	return rc;
+}
+
+static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
+{
+	bool rc = false;
+
+	spin_lock(&rq->bpoll_lock);
+	WARN_ON(rq->bpoll_state &
+		(ENIC_POLL_STATE_POLL | ENIC_POLL_STATE_NAPI_YIELD));
+	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
+		rc = true;
+	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
+	spin_unlock(&rq->bpoll_lock);
+
+	return rc;
+}
+
+static inline bool enic_poll_lock_poll(struct vnic_rq *rq)
+{
+	bool rc = true;
+
+	spin_lock_bh(&rq->bpoll_lock);
+	if (rq->bpoll_state & ENIC_POLL_LOCKED) {
+		rq->bpoll_state |= ENIC_POLL_STATE_POLL_YIELD;
+		rc = false;
+	} else {
+		rq->bpoll_state |= ENIC_POLL_STATE_POLL;
+	}
+	spin_unlock_bh(&rq->bpoll_lock);
+
+	return rc;
+}
+
+static inline bool enic_poll_unlock_poll(struct vnic_rq *rq)
+{
+	bool rc = false;
+
+	spin_lock_bh(&rq->bpoll_lock);
+	WARN_ON(rq->bpoll_state & ENIC_POLL_STATE_NAPI);
+	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
+		rc = true;
+	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
+	spin_unlock_bh(&rq->bpoll_lock);
+
+	return rc;
+}
+
+static inline bool enic_poll_busy_polling(struct vnic_rq *rq)
+{
+	WARN_ON(!(rq->bpoll_state & ENIC_POLL_LOCKED));
+	return rq->bpoll_state & ENIC_POLL_USER_PEND;
+}
+
+#else
+
+static inline void enic_busy_poll_init_lock(struct vnic_rq *rq)
+{
+}
+
+static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
+{
+	return true;
+}
+
+static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
+{
+	return false;
+}
+
+static inline bool enic_poll_lock_poll(struct vnic_rq *rq)
+{
+	return false;
+}
+
+static inline bool enic_poll_unlock_poll(struct vnic_rq *rq)
+{
+	return false;
+}
+
+static inline bool enic_poll_ll_polling(struct vnic_rq *rq)
+{
+	return false;
+}
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 void vnic_rq_free(struct vnic_rq *rq);
 int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
-- 
2.0.0
