From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net 04/19] net: hns: Change the TX queue selection algorithm
Date: Thu, 30 Mar 2017 16:30:51 +0100
Message-ID: <20170330153106.14344-5-salil.mehta@huawei.com>
References: <20170330153106.14344-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        lipeng <lipeng321@huawei.com>,
        Weiwei Deng <dengweiwei@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:4920 "EHLO
        dggrg03-dlp.huawei.com" rhost-flags-OK-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S934458AbdC3Pct (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 11:32:49 -0400
In-Reply-To: <20170330153106.14344-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: lipeng <lipeng321@huawei.com>

This patch changes the TX queue selection algorithm from default
to based on tuple {sport,dport,sip,dip}/indirection table
similar to used during RX with Receive Side Scaling.

Signed-off-by: lipeng <lipeng321@huawei.com>
Signed-off-by: Weiwei Deng <dengweiwei@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |  2 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  5 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 63 +++++++++++++++++++++++
 3 files changed, 70 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 8016854..85df7c7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -545,6 +545,8 @@ struct hnae_handle {
 	int vf_id;
 	u32 eport_id;
 	u32 dport_id;	/* v2 tx bd should fill the dport_id */
+	u32 *rss_key;
+	u32 *rss_indir_table;
 	enum hnae_port_type port_type;
 	enum hnae_media_type media_type;
 	struct list_head node;    /* list to hnae_ae_dev->handle_list */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 0a9cdf0..abafa25 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -80,6 +80,7 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	struct hnae_handle *ae_handle;
 	struct ring_pair_cb *ring_pair_cb;
 	struct hnae_vf_cb *vf_cb;
+	struct hns_ppe_cb *ppe_cb;
 
 	dsaf_dev = hns_ae_get_dsaf_dev(dev);
 
@@ -127,11 +128,15 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	vf_cb->port_index = port_id;
 	vf_cb->mac_cb = dsaf_dev->mac_cb[port_id];
 
+	ppe_cb = hns_get_ppe_cb(ae_handle);
+
 	ae_handle->phy_if = vf_cb->mac_cb->phy_if;
 	ae_handle->phy_dev = vf_cb->mac_cb->phy_dev;
 	ae_handle->if_support = vf_cb->mac_cb->if_support;
 	ae_handle->port_type = vf_cb->mac_cb->mac_type;
 	ae_handle->media_type = vf_cb->mac_cb->media_type;
+	ae_handle->rss_key = ppe_cb->rss_key;
+	ae_handle->rss_indir_table = ppe_cb->rss_indir_table;
 	ae_handle->dport_id = port_id;
 
 	return ae_handle;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 73ec8c8..646f601 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -40,6 +40,8 @@
 #define SKB_TMP_LEN(SKB) \
 	(((SKB)->transport_header - (SKB)->mac_header) + tcp_hdrlen(SKB))
 
+#define INVALID_TX_RING    0xffff
+
 static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 			 int size, dma_addr_t dma, int frag_end,
 			 int buf_num, enum hns_desc_type type, int mtu)
@@ -1657,17 +1659,78 @@ static void hns_nic_get_stats64(struct net_device *ndev,
 	stats->tx_compressed = ndev->stats.tx_compressed;
 }
 
+static u32 hns_calc_tx_rss(u32 sip, u32 dip, u32 sport, u32 dport, u32 *rss_key)
+{
+	u32 rss = 0;
+	int i;
+	u32 port;
+
+	port = (sport << 16) | dport;
+
+	for (i = 0; i < 32; i++)
+		if (sip & (1 << (31 - i)))
+			rss ^= (rss_key[9] << i) |
+				(u32)((u64)rss_key[8] >> (32 - i));
+
+	for (i = 0; i < 32; i++)
+		if (dip & (1 << (31 - i)))
+			rss ^= (rss_key[8] << i) |
+				(u32)((u64)rss_key[7] >> (32 - i));
+
+	for (i = 0; i < 32; i++)
+		if (port & (1 << (31 - i)))
+			rss ^= (rss_key[7] << i) |
+				(u32)((u64)rss_key[6] >> (32 - i));
+
+	return rss;
+}
+
+/* if tcp or udp, then calc tx ring index */
+static u16 hns_calc_tx_ring_idx(struct hns_nic_priv *priv,
+				struct sk_buff *skb)
+{
+	struct hnae_handle *handle;
+	struct iphdr *iphdr;
+	struct tcphdr *tcphdr;
+	u32 rss;
+	int protocol;
+	u16 ring = INVALID_TX_RING;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		iphdr = ip_hdr(skb);
+		protocol = iphdr->protocol;
+		if (protocol == IPPROTO_TCP) {
+			/* because tcp and udp dest and src port is same */
+			tcphdr = tcp_hdr(skb);
+			handle = priv->ae_handle;
+			rss = hns_calc_tx_rss(ntohl(iphdr->daddr),
+					      ntohl(iphdr->saddr),
+					      ntohs(tcphdr->dest),
+					      ntohs(tcphdr->source),
+					      handle->rss_key);
+			ring = handle->rss_indir_table[rss & 0xff] & 0xf;
+		}
+	}
+
+	return ring;
+}
+
 static u16
 hns_nic_select_queue(struct net_device *ndev, struct sk_buff *skb,
 		     void *accel_priv, select_queue_fallback_t fallback)
 {
 	struct ethhdr *eth_hdr = (struct ethhdr *)skb->data;
 	struct hns_nic_priv *priv = netdev_priv(ndev);
+	u16 ring;
 
 	/* fix hardware broadcast/multicast packets queue loopback */
 	if (!AE_IS_VER1(priv->enet_ver) &&
 	    is_multicast_ether_addr(eth_hdr->h_dest))
 		return 0;
+
+	ring = hns_calc_tx_ring_idx(priv, skb);
+	if (ring != INVALID_TX_RING)
+		return ring;
 	else
 		return fallback(ndev, skb);
 }
-- 
2.7.4
