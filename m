From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove support for per driver
 ndo_busy_poll()
Date: Fri, 03 Feb 2017 17:28:53 -0500 (EST)
Message-ID: <20170203.172853.2189881865706510657.davem@davemloft.net>
References: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170203.171820.956894207079399896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdBCW2z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 17:28:55 -0500
In-Reply-To: <20170203.171820.956894207079399896.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Feb 2017 17:18:20 -0500 (EST)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Feb 2017 18:43:28 -0800
> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> We added generic support for busy polling in NAPI layer in linux-4.5
>> 
>> No network driver uses ndo_busy_poll() anymore, we can get rid
>> of the pointer in struct net_device_ops, and its use in sk_busy_loop()
>> 
>> Saves NETIF_F_BUSY_POLL features bit.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Actually, one more driver needs converting, "enic".

I did a quick and dirty conversion:

====================
>From 7a655c6324a8968ea2f027bf3660c87c42ac3de4 Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 3 Feb 2017 17:28:21 -0500
Subject: [PATCH] enic: Remove local ndo_busy_poll() implementation.

We do polling generically these days.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 66 ++----------------------
 drivers/net/ethernet/cisco/enic/vnic_rq.h   | 78 -----------------------------
 2 files changed, 5 insertions(+), 139 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 91e42be..c009f6d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -43,10 +43,8 @@
 #ifdef CONFIG_RFS_ACCEL
 #include <linux/cpu_rmap.h>
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-#include <net/busy_poll.h>
-#endif
 #include <linux/crash_dump.h>
+#include <net/busy_poll.h>
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -1191,8 +1189,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
 
 		skb_mark_napi_id(skb, &enic->napi[rq->index]);
-		if (enic_poll_busy_polling(rq) ||
-		    !(netdev->features & NETIF_F_GRO))
+		if (!(netdev->features & NETIF_F_GRO))
 			netif_receive_skb(skb);
 		else
 			napi_gro_receive(&enic->napi[q_number], skb);
@@ -1296,15 +1293,6 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	wq_work_done = vnic_cq_service(&enic->cq[cq_wq], wq_work_to_do,
 				       enic_wq_service, NULL);
 
-	if (!enic_poll_lock_napi(&enic->rq[cq_rq])) {
-		if (wq_work_done > 0)
-			vnic_intr_return_credits(&enic->intr[intr],
-						 wq_work_done,
-						 0 /* dont unmask intr */,
-						 0 /* dont reset intr timer */);
-		return budget;
-	}
-
 	if (budget > 0)
 		rq_work_done = vnic_cq_service(&enic->cq[cq_rq],
 			rq_work_to_do, enic_rq_service, NULL);
@@ -1323,7 +1311,6 @@ static int enic_poll(struct napi_struct *napi, int budget)
 			0 /* don't reset intr timer */);
 
 	err = vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
-	enic_poll_unlock_napi(&enic->rq[cq_rq], napi);
 
 	/* Buffer allocation failed. Stay in polling
 	 * mode so we can try to fill the ring again.
@@ -1390,34 +1377,6 @@ static void enic_set_rx_cpu_rmap(struct enic *enic)
 
 #endif /* CONFIG_RFS_ACCEL */
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int enic_busy_poll(struct napi_struct *napi)
-{
-	struct net_device *netdev = napi->dev;
-	struct enic *enic = netdev_priv(netdev);
-	unsigned int rq = (napi - &enic->napi[0]);
-	unsigned int cq = enic_cq_rq(enic, rq);
-	unsigned int intr = enic_msix_rq_intr(enic, rq);
-	unsigned int work_to_do = -1; /* clean all pkts possible */
-	unsigned int work_done;
-
-	if (!enic_poll_lock_poll(&enic->rq[rq]))
-		return LL_FLUSH_BUSY;
-	work_done = vnic_cq_service(&enic->cq[cq], work_to_do,
-				    enic_rq_service, NULL);
-
-	if (work_done > 0)
-		vnic_intr_return_credits(&enic->intr[intr],
-					 work_done, 0, 0);
-	vnic_rq_fill(&enic->rq[rq], enic_rq_alloc_buf);
-	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
-		enic_calc_int_moderation(enic, &enic->rq[rq]);
-	enic_poll_unlock_poll(&enic->rq[rq]);
-
-	return work_done;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 static int enic_poll_msix_wq(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
@@ -1459,8 +1418,6 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 	unsigned int work_done = 0;
 	int err;
 
-	if (!enic_poll_lock_napi(&enic->rq[rq]))
-		return budget;
 	/* Service RQ
 	 */
 
@@ -1493,7 +1450,6 @@ static int enic_poll_msix_rq(struct napi_struct *napi, int budget)
 		 */
 		enic_calc_int_moderation(enic, &enic->rq[rq]);
 
-	enic_poll_unlock_napi(&enic->rq[rq], napi);
 	if (work_done < work_to_do) {
 
 		/* Some work done, but not enough to stay in polling,
@@ -1751,10 +1707,9 @@ static int enic_open(struct net_device *netdev)
 
 	netif_tx_wake_all_queues(netdev);
 
-	for (i = 0; i < enic->rq_count; i++) {
-		enic_busy_poll_init_lock(&enic->rq[i]);
+	for (i = 0; i < enic->rq_count; i++)
 		napi_enable(&enic->napi[i]);
-	}
+
 	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX)
 		for (i = 0; i < enic->wq_count; i++)
 			napi_enable(&enic->napi[enic_cq_wq(enic, i)]);
@@ -1798,13 +1753,8 @@ static int enic_stop(struct net_device *netdev)
 
 	enic_dev_disable(enic);
 
-	for (i = 0; i < enic->rq_count; i++) {
+	for (i = 0; i < enic->rq_count; i++)
 		napi_disable(&enic->napi[i]);
-		local_bh_disable();
-		while (!enic_poll_lock_napi(&enic->rq[i]))
-			mdelay(1);
-		local_bh_enable();
-	}
 
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
@@ -2335,9 +2285,6 @@ static const struct net_device_ops enic_netdev_dynamic_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= enic_busy_poll,
-#endif
 };
 
 static const struct net_device_ops enic_netdev_ops = {
@@ -2361,9 +2308,6 @@ static const struct net_device_ops enic_netdev_ops = {
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= enic_rx_flow_steer,
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= enic_busy_poll,
-#endif
 };
 
 static void enic_dev_deinit(struct enic *enic)
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
index b9c82f1..0413103 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
@@ -92,9 +92,6 @@ struct vnic_rq {
 	struct vnic_rq_buf *to_clean;
 	void *os_buf_head;
 	unsigned int pkts_outstanding;
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	atomic_t bpoll_state;
-#endif /* CONFIG_NET_RX_BUSY_POLL */
 };
 
 static inline unsigned int vnic_rq_desc_avail(struct vnic_rq *rq)
@@ -207,81 +204,6 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 	return 0;
 }
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static inline void enic_busy_poll_init_lock(struct vnic_rq *rq)
-{
-	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
-}
-
-static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
-{
-	int rc = atomic_cmpxchg(&rq->bpoll_state, ENIC_POLL_STATE_IDLE,
-				ENIC_POLL_STATE_NAPI);
-
-	return (rc == ENIC_POLL_STATE_IDLE);
-}
-
-static inline void enic_poll_unlock_napi(struct vnic_rq *rq,
-					 struct napi_struct *napi)
-{
-	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_NAPI);
-	napi_gro_flush(napi, false);
-	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
-}
-
-static inline bool enic_poll_lock_poll(struct vnic_rq *rq)
-{
-	int rc = atomic_cmpxchg(&rq->bpoll_state, ENIC_POLL_STATE_IDLE,
-				ENIC_POLL_STATE_POLL);
-
-	return (rc == ENIC_POLL_STATE_IDLE);
-}
-
-
-static inline void enic_poll_unlock_poll(struct vnic_rq *rq)
-{
-	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_POLL);
-	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
-}
-
-static inline bool enic_poll_busy_polling(struct vnic_rq *rq)
-{
-	return atomic_read(&rq->bpoll_state) & ENIC_POLL_STATE_POLL;
-}
-
-#else
-
-static inline void enic_busy_poll_init_lock(struct vnic_rq *rq)
-{
-}
-
-static inline bool enic_poll_lock_napi(struct vnic_rq *rq)
-{
-	return true;
-}
-
-static inline bool enic_poll_unlock_napi(struct vnic_rq *rq,
-					 struct napi_struct *napi)
-{
-	return false;
-}
-
-static inline bool enic_poll_lock_poll(struct vnic_rq *rq)
-{
-	return false;
-}
-
-static inline bool enic_poll_unlock_poll(struct vnic_rq *rq)
-{
-	return false;
-}
-
-static inline bool enic_poll_ll_polling(struct vnic_rq *rq)
-{
-	return false;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 void vnic_rq_free(struct vnic_rq *rq);
 int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 	unsigned int desc_count, unsigned int desc_size);
-- 
2.4.11
