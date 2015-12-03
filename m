From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V7 net-next 3/5] net:hns: Add Hip06 "TSO(TCP Segment Offload)" support HNS Driver
Date: Thu, 3 Dec 2015 12:17:55 +0000
Message-ID: <1449145077-9400-4-git-send-email-salil.mehta@huawei.com>
References: <1449145077-9400-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <paul.gortmaker@windriver.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>, <arnd@arndb.de>,
	<liguozhu@hisilicon.com>, <yisen.zhuang@huawei.com>,
	<dingtianhong@huawei.com>, <zhangfei.gao@linaro.org>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<salil.mehta@huawei.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449145077-9400-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the support of "TSO (TCP Segment Offload)" feature
provided by the Hip06 ethernet hardware to the HNS ethernet
driver.

Enabling this feature would help offload the TCP Segmentation
process to the Hip06 ethernet hardware. This eventually would help
in saving precious cpu cycles.

Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
Signed-off-by: lisheng <lisheng011@huawei.com>
---

PATCH V7/V6:
- No change over previous patch.

PATCH V5:
- Minor styling change

PATCH V4/V3/V2:
- No change over the initial patch floated patch for TSO

PATCH V1:
- Initial support of TSO feature in Hip06 SoC in HNS driver
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |    1 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |    8 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |    5 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h |    2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |    1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     |   82 ++++++++++++++++++++-
 6 files changed, 95 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 76dd715..d1f3316 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -474,6 +474,7 @@ struct hnae_ae_ops {
 	int (*set_mac_addr)(struct hnae_handle *handle, void *p);
 	int (*set_mc_addr)(struct hnae_handle *handle, void *addr);
 	int (*set_mtu)(struct hnae_handle *handle, int new_mtu);
+	void (*set_tso_stats)(struct hnae_handle *handle, int enable);
 	void (*update_stats)(struct hnae_handle *handle,
 			     struct net_device_stats *net_stats);
 	void (*get_stats)(struct hnae_handle *handle, u64 *data);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 77e1735..77c6edb 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -277,6 +277,13 @@ static int hns_ae_set_mtu(struct hnae_handle *handle, int new_mtu)
 	return hns_mac_set_mtu(mac_cb, new_mtu);
 }
 
+static void hns_ae_set_tso_stats(struct hnae_handle *handle, int enable)
+{
+	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
+
+	hns_ppe_set_tso_enable(ppe_cb, enable);
+}
+
 static int hns_ae_start(struct hnae_handle *handle)
 {
 	int ret;
@@ -824,6 +831,7 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 	.set_mc_addr = hns_ae_set_multicast_one,
 	.set_mtu = hns_ae_set_mtu,
 	.update_stats = hns_ae_update_stats,
+	.set_tso_stats = hns_ae_set_tso_stats,
 	.get_stats = hns_ae_get_stats,
 	.get_strings = hns_ae_get_strings,
 	.get_sset_count = hns_ae_get_sset_count,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 7af0858..b5e4c44 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -19,6 +19,11 @@
 
 #include "hns_dsaf_ppe.h"
 
+void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value)
+{
+	dsaf_set_dev_bit(ppe_cb, PPEV2_CFG_TSO_EN_REG, 0, !!value);
+}
+
 void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
 			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM])
 {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
index dac8532..0f5cb69 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.h
@@ -113,7 +113,7 @@ void hns_ppe_get_regs(struct hns_ppe_cb *ppe_cb, void *data);
 
 void hns_ppe_get_strings(struct hns_ppe_cb *ppe_cb, int stringset, u8 *data);
 void hns_ppe_get_stats(struct hns_ppe_cb *ppe_cb, u64 *data);
-
+void hns_ppe_set_tso_enable(struct hns_ppe_cb *ppe_cb, u32 value);
 void hns_ppe_set_rss_key(struct hns_ppe_cb *ppe_cb,
 			 const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM]);
 void hns_ppe_set_indir_table(struct hns_ppe_cb *ppe_cb,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index b070d57..98c163e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -317,6 +317,7 @@
 #define PPE_CFG_TAG_GEN_REG			0x90
 #define PPE_CFG_PARSE_TAG_REG			0x94
 #define PPE_CFG_PRO_CHECK_EN_REG		0x98
+#define PPEV2_CFG_TSO_EN_REG                    0xA0
 #define PPE_INTEN_REG				0x100
 #define PPE_RINT_REG				0x104
 #define PPE_INTSTS_REG				0x108
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 0ca7fa9..c025a71 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -223,6 +223,71 @@ static int hns_nic_maybe_stop_tx(
 	return 0;
 }
 
+static int hns_nic_maybe_stop_tso(
+	struct sk_buff **out_skb, int *bnum, struct hnae_ring *ring)
+{
+	int i;
+	int size;
+	int buf_num;
+	int frag_num;
+	struct sk_buff *skb = *out_skb;
+	struct sk_buff *new_skb = NULL;
+	struct skb_frag_struct *frag;
+
+	size = skb_headlen(skb);
+	buf_num = (size + BD_MAX_SEND_SIZE - 1) / BD_MAX_SEND_SIZE;
+
+	frag_num = skb_shinfo(skb)->nr_frags;
+	for (i = 0; i < frag_num; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		size = skb_frag_size(frag);
+		buf_num += (size + BD_MAX_SEND_SIZE - 1) / BD_MAX_SEND_SIZE;
+	}
+
+	if (unlikely(buf_num > ring->max_desc_num_per_pkt)) {
+		buf_num = (skb->len + BD_MAX_SEND_SIZE - 1) / BD_MAX_SEND_SIZE;
+		if (ring_space(ring) < buf_num)
+			return -EBUSY;
+		/* manual split the send packet */
+		new_skb = skb_copy(skb, GFP_ATOMIC);
+		if (!new_skb)
+			return -ENOMEM;
+		dev_kfree_skb_any(skb);
+		*out_skb = new_skb;
+
+	} else if (ring_space(ring) < buf_num) {
+		return -EBUSY;
+	}
+
+	*bnum = buf_num;
+	return 0;
+}
+
+static void fill_tso_desc(struct hnae_ring *ring, void *priv,
+			  int size, dma_addr_t dma, int frag_end,
+			  int buf_num, enum hns_desc_type type, int mtu)
+{
+	int frag_buf_num;
+	int sizeoflast;
+	int k;
+
+	frag_buf_num = (size + BD_MAX_SEND_SIZE - 1) / BD_MAX_SEND_SIZE;
+	sizeoflast = size % BD_MAX_SEND_SIZE;
+	sizeoflast = sizeoflast ? sizeoflast : BD_MAX_SEND_SIZE;
+
+	/* when the frag size is bigger than hardware, split this frag */
+	for (k = 0; k < frag_buf_num; k++)
+		fill_v2_desc(ring, priv,
+			     (k == frag_buf_num - 1) ?
+					sizeoflast : BD_MAX_SEND_SIZE,
+			     dma + BD_MAX_SEND_SIZE * k,
+			     frag_end && (k == frag_buf_num - 1) ? 1 : 0,
+			     buf_num,
+			     (type == DESC_TYPE_SKB && !k) ?
+					DESC_TYPE_SKB : DESC_TYPE_PAGE,
+			     mtu);
+}
+
 int hns_nic_net_xmit_hw(struct net_device *ndev,
 			struct sk_buff *skb,
 			struct hns_nic_ring_data *ring_data)
@@ -1637,6 +1702,7 @@ static void hns_nic_uninit_ring_data(struct hns_nic_priv *priv)
 static void hns_nic_set_priv_ops(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
 
 	if (AE_IS_VER1(priv->enet_ver)) {
 		priv->ops.fill_desc = fill_desc;
@@ -1644,8 +1710,17 @@ static void hns_nic_set_priv_ops(struct net_device *netdev)
 		priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
 	} else {
 		priv->ops.get_rxd_bnum = get_v2rx_desc_bnum;
-		priv->ops.fill_desc = fill_v2_desc;
-		priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
+		if ((netdev->features & NETIF_F_TSO) ||
+		    (netdev->features & NETIF_F_TSO6)) {
+			priv->ops.fill_desc = fill_tso_desc;
+			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tso;
+			/* This chip only support 7*4096 */
+			netif_set_gso_max_size(netdev, 7 * 4096);
+			h->dev->ops->set_tso_stats(h, 1);
+		} else {
+			priv->ops.fill_desc = fill_v2_desc;
+			priv->ops.maybe_stop_tx = hns_nic_maybe_stop_tx;
+		}
 	}
 }
 
@@ -1758,9 +1833,10 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 
 	switch (priv->enet_ver) {
 	case AE_VERSION_2:
+		ndev->features |= NETIF_F_TSO | NETIF_F_TSO6;
 		ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
-			NETIF_F_GRO;
+			NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6;
 		break;
 	default:
 		break;
-- 
1.7.9.5
