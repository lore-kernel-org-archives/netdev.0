From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V4 net-next 08/18] net: hns: Replace netif_tx_lock to ring spin lock
Date: Sat, 1 Apr 2017 12:03:38 +0100
Message-ID: <20170401110348.15908-9-salil.mehta@huawei.com>
References: <20170401110348.15908-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170401110348.15908-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lipeng <lipeng321@huawei.com>

netif_tx_lock is a global spin lock, it will take affect
in all rings in the netdevice. In tx_poll_one process, it can
only lock the current ring, in this case, we define a spin lock
in hnae_ring struct for it.

Signed-off-by: lipeng <lipeng321@huawei.com>
reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.c     |  1 +
 drivers/net/ethernet/hisilicon/hns/hnae.h     |  3 +++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 21 +++++++++++----------
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
index 78af663..513c257 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.c
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
@@ -196,6 +196,7 @@ hnae_init_ring(struct hnae_queue *q, struct hnae_ring *ring, int flags)
 
 	ring->q = q;
 	ring->flags = flags;
+	spin_lock_init(&ring->lock);
 	assert(!ring->desc && !ring->desc_cb && !ring->desc_dma_addr);
 
 	/* not matter for tx or rx ring, the ntc and ntc start from 0 */
diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index c66581d..859c536 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -275,6 +275,9 @@ struct hnae_ring {
 	/* statistic */
 	struct ring_stats stats;
 
+	/* ring lock for poll one */
+	spinlock_t lock;
+
 	dma_addr_t desc_dma_addr;
 	u32 buf_size;       /* size for hnae_desc->addr, preset by AE */
 	u16 desc_num;       /* total number of desc */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 57b4d59..e39c794 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -922,12 +922,13 @@ static int is_valid_clean_head(struct hnae_ring *ring, int h)
 
 /* netif_tx_lock will turn down the performance, set only when necessary */
 #ifdef CONFIG_NET_POLL_CONTROLLER
-#define NETIF_TX_LOCK(ndev) netif_tx_lock(ndev)
-#define NETIF_TX_UNLOCK(ndev) netif_tx_unlock(ndev)
+#define NETIF_TX_LOCK(ring) spin_lock(&ring->lock)
+#define NETIF_TX_UNLOCK(ring) spin_unlock(&ring->lock)
 #else
-#define NETIF_TX_LOCK(ndev)
-#define NETIF_TX_UNLOCK(ndev)
+#define NETIF_TX_LOCK(ring)
+#define NETIF_TX_UNLOCK(ring)
 #endif
+
 /* reclaim all desc in one budget
  * return error or number of desc left
  */
@@ -941,13 +942,13 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 	int head;
 	int bytes, pkts;
 
-	NETIF_TX_LOCK(ndev);
+	NETIF_TX_LOCK(ring);
 
 	head = readl_relaxed(ring->io_base + RCB_REG_HEAD);
 	rmb(); /* make sure head is ready before touch any data */
 
 	if (is_ring_empty(ring) || head == ring->next_to_clean) {
-		NETIF_TX_UNLOCK(ndev);
+		NETIF_TX_UNLOCK(ring);
 		return 0; /* no data to poll */
 	}
 
@@ -955,7 +956,7 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 		netdev_err(ndev, "wrong head (%d, %d-%d)\n", head,
 			   ring->next_to_use, ring->next_to_clean);
 		ring->stats.io_err_cnt++;
-		NETIF_TX_UNLOCK(ndev);
+		NETIF_TX_UNLOCK(ring);
 		return -EIO;
 	}
 
@@ -967,7 +968,7 @@ static int hns_nic_tx_poll_one(struct hns_nic_ring_data *ring_data,
 		prefetch(&ring->desc_cb[ring->next_to_clean]);
 	}
 
-	NETIF_TX_UNLOCK(ndev);
+	NETIF_TX_UNLOCK(ring);
 
 	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
 	netdev_tx_completed_queue(dev_queue, pkts, bytes);
@@ -1028,7 +1029,7 @@ static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
 	int head;
 	int bytes, pkts;
 
-	NETIF_TX_LOCK(ndev);
+	NETIF_TX_LOCK(ring);
 
 	head = ring->next_to_use; /* ntu :soft setted ring position*/
 	bytes = 0;
@@ -1036,7 +1037,7 @@ static void hns_nic_tx_clr_all_bufs(struct hns_nic_ring_data *ring_data)
 	while (head != ring->next_to_clean)
 		hns_nic_reclaim_one_desc(ring, &bytes, &pkts);
 
-	NETIF_TX_UNLOCK(ndev);
+	NETIF_TX_UNLOCK(ring);
 
 	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
 	netdev_tx_reset_queue(dev_queue);
-- 
2.7.4
