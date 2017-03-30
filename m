From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 07/19] net: hns: Optimize hns_nic_common_poll for better performance
Date: Thu, 30 Mar 2017 16:30:54 +0100
Message-ID: <20170330153106.14344-8-salil.mehta@huawei.com>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([45.249.212.188]:4857 "EHLO
        dggrg02-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S934700AbdC3Pct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 11:32:49 -0400
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

After polling less than buget packages, we need check again. If
there are still some packages, we call napi_schedule add softirq
queue, this is not better way. So we return buget value instead
of napi_schedule.

Signed-off-by: lipeng <lipeng321@huawei.com>
reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 50 ++++++++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h |  2 +-
 2 files changed, 31 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 646f601..a083660 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -861,7 +861,7 @@ static int hns_nic_rx_poll_one(struct hns_nic_ring_data *ring_data,
 	return recv_pkts;
 }
 
-static void hns_nic_rx_fini_pro(struct hns_nic_ring_data *ring_data)
+static bool hns_nic_rx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
 	int num = 0;
@@ -875,22 +875,23 @@ static void hns_nic_rx_fini_pro(struct hns_nic_ring_data *ring_data)
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
 			ring_data->ring, 1);
 
-		napi_schedule(&ring_data->napi);
+		return false;
+	} else {
+		return true;
 	}
 }
 
-static void hns_nic_rx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
+static bool hns_nic_rx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
-	int num = 0;
+	int num;
 
 	num = readl_relaxed(ring->io_base + RCB_REG_FBDNUM);
 
-	if (num == 0)
-		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-			ring, 0);
+	if (!num)
+		return true;
 	else
-		napi_schedule(&ring_data->napi);
+		return false;
 }
 
 static inline void hns_nic_reclaim_one_desc(struct hnae_ring *ring,
@@ -991,7 +992,7 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 	return 0;
 }
 
-static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
+static bool hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
 	int head;
@@ -1004,20 +1005,21 @@ static void hns_nic_tx_fini_pro(struct hns_nic_ring_data *ring_data)
 		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
 			ring_data->ring, 1);
 
-		napi_schedule(&ring_data->napi);
+		return false;
+	} else {
+		return true;
 	}
 }
 
-static void hns_nic_tx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
+static bool hns_nic_tx_fini_pro_v2(struct hns_nic_ring_data *ring_data)
 {
 	struct hnae_ring *ring = ring_data->ring;
 	int head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 
 	if (head == ring->next_to_clean)
-		ring_data->ring->q->handle->dev->ops->toggle_ring_irq(
-			ring, 0);
+		return true;
 	else
-		napi_schedule(&ring_data->napi);
+		return false;
 }
 
 static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
@@ -1044,15 +1046,23 @@ static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
 
 static int hns_nic_common_poll(struct napi_struct *napi, int budget)
 {
+	int clean_complete = 0;
 	struct hns_nic_ring_data *ring_data =
 		container_of(napi, struct hns_nic_ring_data, napi);
-	int clean_complete = ring_data->poll_one(
-				ring_data, budget, ring_data->ex_process);
+	struct hnae_ring *ring = ring_data->ring;
 
-	if (clean_complete >= 0 && clean_complete < budget) {
-		napi_complete(napi);
-		ring_data->fini_process(ring_data);
-		return 0;
+try_again:
+	clean_complete += ring_data->poll_one(
+				ring_data, budget - clean_complete,
+				ring_data->ex_process);
+
+	if (clean_complete < budget) {
+		if (ring_data->fini_process(ring_data)) {
+			napi_complete(napi);
+			ring->q->handle->dev->ops->toggle_ring_irq(ring, 0);
+		} else {
+			goto try_again;
+		}
 	}
 
 	return clean_complete;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index fff8f8a..1b83232 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -41,7 +41,7 @@ struct hns_nic_ring_data {
 	int queue_index;
 	int (*poll_one)(struct hns_nic_ring_data *, int, void *);
 	void (*ex_process)(struct hns_nic_ring_data *, struct sk_buff *);
-	void (*fini_process)(struct hns_nic_ring_data *);
+	bool (*fini_process)(struct hns_nic_ring_data *);
 };
 
 /* compatible the difference between two versions */
-- 
2.7.4
