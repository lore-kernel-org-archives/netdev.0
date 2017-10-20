From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: [PATCH net-next 1/2] net: hns3: Refactor the skb receiving and transmitting function
Date: Fri, 20 Oct 2017 10:19:21 +0800
Message-ID: <1508465962-60176-2-git-send-email-linyunsheng@huawei.com>
References: <1508465962-60176-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508465962-60176-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch refactors the skb receiving and transmitting functions
and export them in order to support the ethtool's mac loopback
selftest.

Signed-off-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 17 ++++++++++++-----
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  4 ++++
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 8fa4e65..8383d67 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -900,8 +900,7 @@ static void hns_nic_dma_unmap(struct hns3_enet_ring *ring, int next_to_use_orig)
 	}
 }
 
-static netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb,
-				     struct net_device *netdev)
+netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct hns3_nic_priv *priv = netdev_priv(netdev);
 	struct hns3_nic_ring_data *ring_data =
@@ -1943,6 +1942,11 @@ static void hns3_rx_checksum(struct hns3_enet_ring *ring, struct sk_buff *skb,
 	}
 }
 
+static void hns3_rx_skb(struct hns3_enet_ring *ring, struct sk_buff *skb)
+{
+	napi_gro_receive(&ring->tqp_vector->napi, skb);
+}
+
 static int hns3_handle_rx_bd(struct hns3_enet_ring *ring,
 			     struct sk_buff **out_skb, int *out_bnum)
 {
@@ -2077,7 +2081,9 @@ static int hns3_handle_rx_bd(struct hns3_enet_ring *ring,
 	return 0;
 }
 
-static int hns3_clean_rx_ring(struct hns3_enet_ring *ring, int budget)
+int hns3_clean_rx_ring(
+		struct hns3_enet_ring *ring, int budget,
+		void (*rx_fn)(struct hns3_enet_ring *, struct sk_buff *))
 {
 #define RCB_NOF_ALLOC_RX_BUFF_ONCE 16
 	struct net_device *netdev = ring->tqp->handle->kinfo.netdev;
@@ -2115,7 +2121,7 @@ static int hns3_clean_rx_ring(struct hns3_enet_ring *ring, int budget)
 
 		/* Do update ip stack process */
 		skb->protocol = eth_type_trans(skb, netdev);
-		(void)napi_gro_receive(&ring->tqp_vector->napi, skb);
+		rx_fn(ring, skb);
 
 		recv_pkts++;
 	}
@@ -2258,7 +2264,8 @@ static int hns3_nic_common_poll(struct napi_struct *napi, int budget)
 	rx_budget = max(budget / tqp_vector->num_tqps, 1);
 
 	hns3_for_each_ring(ring, tqp_vector->rx_group) {
-		int rx_cleaned = hns3_clean_rx_ring(ring, rx_budget);
+		int rx_cleaned = hns3_clean_rx_ring(ring, rx_budget,
+						    hns3_rx_skb);
 
 		if (rx_cleaned >= rx_budget)
 			clean_complete = false;
diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
index 6659989..6228b26 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
@@ -597,6 +597,10 @@ static inline void hns3_write_reg(void __iomem *base, u32 reg, u32 value)
 int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget);
 int hns3_init_all_ring(struct hns3_nic_priv *priv);
 int hns3_uninit_all_ring(struct hns3_nic_priv *priv);
+netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb, struct net_device *netdev);
+int hns3_clean_rx_ring(
+		struct hns3_enet_ring *ring, int budget,
+		void (*rx_fn)(struct hns3_enet_ring *, struct sk_buff *));
 
 #ifdef CONFIG_HNS3_DCB
 void hns3_dcbnl_setup(struct hnae3_handle *handle);
-- 
1.9.1
