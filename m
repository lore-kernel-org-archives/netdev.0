From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 7/7] net: hns3: fix a bug about hns3_clean_tx_ring
Date: Mon, 23 Oct 2017 19:51:07 +0800
Message-ID: <1508759467-18397-8-git-send-email-lipeng321@huawei.com>
References: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508759467-18397-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value of hns3_clean_tx_ring means tx ring clean result.
Return true means clean complete and there is no more pakcet need
clean. Retrun false means there is packets need clean and napi need
poll again. The last return of hns3_clean_tx_ring is
"return !!budget" as budget will decrease when clean a buffer.

If there is no valid BD in TX ring, return 0 for hns3_clean_tx_ring
will cause napi poll again and never complete the napi poll. This
patch fixes the bug.

Fixes: 76ad4f0 (net: hns3: Add support of HNS3 Ethernet Driver for hip08 SoC)

Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 6 +++---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 06af3c8..537f6c3 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -1629,7 +1629,7 @@ static int is_valid_clean_head(struct hns3_enet_ring *ring, int h)
 	return u > c ? (h > c && h <= u) : (h > c || h <= u);
 }
 
-int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget)
+bool hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget)
 {
 	struct net_device *netdev = ring->tqp->handle->kinfo.netdev;
 	struct netdev_queue *dev_queue;
@@ -1640,7 +1640,7 @@ int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget)
 	rmb(); /* Make sure head is ready before touch any data */
 
 	if (is_ring_empty(ring) || head == ring->next_to_clean)
-		return 0; /* no data to poll */
+		return true; /* no data to poll */
 
 	if (!is_valid_clean_head(ring, head)) {
 		netdev_err(netdev, "wrong head (%d, %d-%d)\n", head,
@@ -1649,7 +1649,7 @@ int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget)
 		u64_stats_update_begin(&ring->syncp);
 		ring->stats.io_err_cnt++;
 		u64_stats_update_end(&ring->syncp);
-		return -EIO;
+		return true;
 	}
 
 	bytes = 0;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index 6228b26..58dc30b 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -594,7 +594,7 @@ static inline void hns3_write_reg(void __iomem *base, u32 reg, u32 value)
 
 void hns3_ethtool_set_ops(struct net_device *netdev);
 
-int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
+bool hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
 int hns3_init_all_ring(struct hns3_nic_priv *priv);
 int hns3_uninit_all_ring(struct hns3_nic_priv *priv);
 netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb, struct net_device *netdev);
-- 
1.9.1
