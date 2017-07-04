From: Lin Yun Sheng <linyunsheng@huawei.com>
Subject: [PATCH net 1/3] net: hns: Add TX CSUM check when fill TX description
Date: Tue, 4 Jul 2017 18:47:31 +0800
Message-ID: <1499165253-184543-2-git-send-email-linyunsheng@huawei.com>
References: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>,
        <tremyfr@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499165253-184543-1-git-send-email-linyunsheng@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yunsheng Lin <linyunsheng@huawei.com>

If driver support checksum offload, should check netdev feature
before fill TX description and get CSUM err bit from RX
description. HNS driver do the check in RX derction but it doesn't
do the check in TX direction.

Signed-off-by: lipeng <lipeng321@huawei.com>
Reviewed-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yunsheng Lin <linyunsheng@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 36 +++++++++++++++++++--------
 drivers/net/ethernet/hisilicon/hns/hns_enet.h |  2 +-
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index c6700b9..b1e7224 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -40,12 +40,14 @@
 #define SKB_TMP_LEN(SKB) \
 	(((SKB)->transport_header - (SKB)->mac_header) + tcp_hdrlen(SKB))
 
-static void fill_v2_desc(struct hnae_ring *ring, void *priv,
+static void fill_v2_desc(struct hns_nic_ring_data *ring_data, void *priv,
 			 int size, dma_addr_t dma, int frag_end,
 			 int buf_num, enum hns_desc_type type, int mtu)
 {
+	struct hnae_ring *ring = ring_data->ring;
 	struct hnae_desc *desc = &ring->desc[ring->next_to_use];
 	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
+	struct net_device *ndev = ring_data->napi.dev;
 	struct iphdr *iphdr;
 	struct ipv6hdr *ipv6hdr;
 	struct sk_buff *skb;
@@ -90,8 +92,13 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 
 			if (skb->protocol == htons(ETH_P_IP)) {
 				iphdr = ip_hdr(skb);
-				hnae_set_bit(rrcfv, HNSV2_TXD_L3CS_B, 1);
-				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
+
+				if (ndev->features & NETIF_F_IP_CSUM) {
+					hnae_set_bit(rrcfv, HNSV2_TXD_L3CS_B,
+						     1);
+					hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B,
+						     1);
+				}
 
 				/* check for tcp/udp header */
 				if (iphdr->protocol == IPPROTO_TCP &&
@@ -105,7 +112,10 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 			} else if (skb->protocol == htons(ETH_P_IPV6)) {
 				hnae_set_bit(tvsvsn, HNSV2_TXD_IPV6_B, 1);
 				ipv6hdr = ipv6_hdr(skb);
-				hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B, 1);
+
+				if (ndev->features & NETIF_F_IPV6_CSUM)
+					hnae_set_bit(rrcfv, HNSV2_TXD_L4CS_B,
+						     1);
 
 				/* check for tcp/udp header */
 				if (ipv6hdr->nexthdr == IPPROTO_TCP &&
@@ -140,12 +150,14 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 };
 MODULE_DEVICE_TABLE(acpi, hns_enet_acpi_match);
 
-static void fill_desc(struct hnae_ring *ring, void *priv,
+static void fill_desc(struct hns_nic_ring_data *ring_data, void *priv,
 		      int size, dma_addr_t dma, int frag_end,
 		      int buf_num, enum hns_desc_type type, int mtu)
 {
+	struct hnae_ring *ring = ring_data->ring;
 	struct hnae_desc *desc = &ring->desc[ring->next_to_use];
 	struct hnae_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
+	struct net_device *ndev = ring_data->napi.dev;
 	struct sk_buff *skb;
 	__be16 protocol;
 	u32 ip_offset;
@@ -179,12 +191,14 @@ static void fill_desc(struct hnae_ring *ring, void *priv,
 				skb->protocol = protocol;
 			}
 
-			if (skb->protocol == htons(ETH_P_IP)) {
+			if (skb->protocol == htons(ETH_P_IP) &&
+			    (ndev->features & NETIF_F_IP_CSUM)) {
 				flag_ipoffset |= 1 << HNS_TXD_L3CS_B;
 				/* check for tcp/udp header */
 				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;
 
-			} else if (skb->protocol == htons(ETH_P_IPV6)) {
+			} else if (skb->protocol == htons(ETH_P_IPV6) &&
+				   (ndev->features & NETIF_F_IPV6_CSUM)) {
 				/* ipv6 has not l3 cs, check for L4 header */
 				flag_ipoffset |= 1 << HNS_TXD_L4CS_B;
 			}
@@ -275,7 +289,7 @@ static int hns_nic_maybe_stop_tso(
 	return 0;
 }
 
-static void fill_tso_desc(struct hnae_ring *ring, void *priv,
+static void fill_tso_desc(struct hns_nic_ring_data *ring_data, void *priv,
 			  int size, dma_addr_t dma, int frag_end,
 			  int buf_num, enum hns_desc_type type, int mtu)
 {
@@ -289,7 +303,7 @@ static void fill_tso_desc(struct hnae_ring *ring, void *priv,
 
 	/* when the frag size is bigger than hardware, split this frag */
 	for (k = 0; k < frag_buf_num; k++)
-		fill_v2_desc(ring, priv,
+		fill_v2_desc(ring_data, priv,
 			     (k == frag_buf_num - 1) ?
 					sizeoflast : BD_MAX_SEND_SIZE,
 			     dma + BD_MAX_SEND_SIZE * k,
@@ -339,7 +353,7 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 		ring->stats.sw_err_cnt++;
 		goto out_err_tx_ok;
 	}
-	priv->ops.fill_desc(ring, skb, size, dma, seg_num == 1 ? 1 : 0,
+	priv->ops.fill_desc(ring_data, skb, size, dma, seg_num == 1 ? 1 : 0,
 			    buf_num, DESC_TYPE_SKB, ndev->mtu);
 
 	/* fill the fragments */
@@ -352,7 +366,7 @@ int hns_nic_net_xmit_hw(struct net_device *ndev,
 			ring->stats.sw_err_cnt++;
 			goto out_map_frag_fail;
 		}
-		priv->ops.fill_desc(ring, skb_frag_page(frag), size, dma,
+		priv->ops.fill_desc(ring_data, skb_frag_page(frag), size, dma,
 				    seg_num - 1 == i ? 1 : 0, buf_num,
 				    DESC_TYPE_PAGE, ndev->mtu);
 	}
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.h b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
index 1b83232..da1afcc 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.h
@@ -46,7 +46,7 @@ struct hns_nic_ring_data {
 
 /* compatible the difference between two versions */
 struct hns_nic_ops {
-	void (*fill_desc)(struct hnae_ring *ring, void *priv,
+	void (*fill_desc)(struct hns_nic_ring_data *ring, void *priv,
 			  int size, dma_addr_t dma, int frag_end,
 			  int buf_num, enum hns_desc_type type, int mtu);
 	int (*maybe_stop_tx)(struct sk_buff **out_skb,
-- 
1.9.1
