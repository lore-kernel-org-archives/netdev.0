From: Kejian Yan <yankejian@huawei.com>
Subject: [PATCH net] net: hns: fix the bug about loopback
Date: Thu, 3 Mar 2016 20:02:59 +0800
Message-ID: <1457006579-236479-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:51321 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756687AbcCCLpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:45:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It will always be passed if the soc is tested the loopback cases. This
patch will fix this bug.

Signed-off-by: Kejian Yan <yankejian@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  8 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 37 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  6 ++++
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 40 ++++++++++++++--------
 5 files changed, 78 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index a0070d0..d4f92ed 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -675,8 +675,12 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 {
 	int ret;
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
 
 	switch (loop) {
+	case MAC_INTERNALLOOP_PHY:
+		ret = 0;
+		break;
 	case MAC_INTERNALLOOP_SERDES:
 		ret = hns_mac_config_sds_loopback(vf_cb->mac_cb, en);
 		break;
@@ -686,6 +690,10 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 	default:
 		ret = -EINVAL;
 	}
+
+	if (!ret)
+		hns_dsaf_set_inner_lb(mac_cb->dsaf_dev, mac_cb->mac_id, en);
+
 	return ret;
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 9439f04..dcf4e8a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -230,6 +230,30 @@ static void hns_dsaf_mix_def_qid_cfg(struct dsaf_device *dsaf_dev)
 	}
 }
 
+static void hns_dsaf_inner_qid_cfg(struct dsaf_device *dsaf_dev)
+{
+	u16 max_q_per_vf, max_vfn;
+	u32 q_id = 0, q_num_per_port;
+	u32 mac_id;
+
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
+		return;
+
+	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
+			       HNS_DSAF_COMM_SERVICE_NW_IDX,
+			       &max_vfn, &max_q_per_vf);
+	q_num_per_port = max_vfn * max_q_per_vf;
+
+	for (mac_id = 0, q_id = 0; mac_id < DSAF_SERVICE_NW_NUM; mac_id++) {
+		dsaf_set_dev_field(dsaf_dev,
+				   DSAFV2_SERDES_LBK_0_REG + 0x4 * mac_id,
+				   DSAFV2_SERDES_LBK_QID_M,
+				   DSAFV2_SERDES_LBK_QID_S,
+				   q_id);
+		q_id += q_num_per_port;
+	}
+}
+
 /**
  * hns_dsaf_sw_port_type_cfg - cfg sw type
  * @dsaf_id: dsa fabric id
@@ -691,6 +715,16 @@ void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
 	dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG, DSAF_CFG_MIX_MODE_S, !!en);
 }
 
+void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en)
+{
+	if (AE_IS_VER1(dsaf_dev->dsaf_ver) ||
+	    dsaf_dev->mac_cb[mac_id].mac_type == HNAE_PORT_DEBUG)
+		return;
+
+	dsaf_set_dev_bit(dsaf_dev, DSAFV2_SERDES_LBK_0_REG + 0x4 * mac_id,
+			 DSAFV2_SERDES_LBK_EN_B, !!en);
+}
+
 /**
  * hns_dsaf_tbl_stat_en - tbl
  * @dsaf_id: dsa fabric id
@@ -1022,6 +1056,9 @@ static void hns_dsaf_comm_init(struct dsaf_device *dsaf_dev)
 	/* set promisc def queue id */
 	hns_dsaf_mix_def_qid_cfg(dsaf_dev);
 
+	/* set inner loopback queue id */
+	hns_dsaf_inner_qid_cfg(dsaf_dev);
+
 	/* in non switch mode, set all port to access mode */
 	hns_dsaf_sw_port_type_cfg(dsaf_dev, DSAF_SW_PORT_TYPE_NON_VLAN);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 40205b9..5fea226 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -417,5 +417,6 @@ void hns_dsaf_get_strings(int stringset, u8 *data, int port);
 void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
 int hns_dsaf_get_regs_count(void);
 void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en);
+void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id, u32 en);
 
 #endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index f0c4f9b..3bb044b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -134,6 +134,7 @@
 #define DSAF_XGE_INT_STS_0_REG		0x1C0
 #define DSAF_PPE_INT_STS_0_REG		0x1E0
 #define DSAF_ROCEE_INT_STS_0_REG	0x200
+#define DSAFV2_SERDES_LBK_0_REG         0x220
 #define DSAF_PPE_QID_CFG_0_REG		0x300
 #define DSAF_SW_PORT_TYPE_0_REG		0x320
 #define DSAF_STP_PORT_TYPE_0_REG	0x340
@@ -857,6 +858,11 @@
 #define PPEV2_CFG_RSS_TBL_4N3_S	24
 #define PPEV2_CFG_RSS_TBL_4N3_M	(((1UL << 5) - 1) << PPEV2_CFG_RSS_TBL_4N3_S)
 
+#define DSAFV2_SERDES_LBK_EN_B  8
+#define DSAFV2_SERDES_LBK_QID_S 0
+#define DSAFV2_SERDES_LBK_QID_M \
+	(((1UL << DSAFV2_SERDES_LBK_EN_B) - 1) << DSAFV2_SERDES_LBK_QID_S)
+
 #define PPE_CNT_CLR_CE_B	0
 #define PPE_CNT_CLR_SNAP_EN_B	1
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index 3df2284..bd18813 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -295,8 +295,10 @@ static int __lb_setup(struct net_device *ndev,
 
 	switch (loop) {
 	case MAC_INTERNALLOOP_PHY:
-		if ((phy_dev) && (!phy_dev->is_c45))
+		if ((phy_dev) && (!phy_dev->is_c45)) {
 			ret = hns_nic_config_phy_loopback(phy_dev, 0x1);
+			ret |= h->dev->ops->set_loopback(h, loop, 0x1);
+		}
 		break;
 	case MAC_INTERNALLOOP_MAC:
 		if ((h->dev->ops->set_loopback) &&
@@ -372,6 +374,28 @@ static int __lb_up(struct net_device *ndev,
 	return 0;
 }
 
+static void __lb_fill_txt_skb_buff(struct net_device *ndev,
+				   struct sk_buff *skb)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+	u32 frame_size;
+
+	frame_size = skb->len;
+	memset(skb->data, 0xFF, frame_size);
+
+	if ((!AE_IS_VER1(priv->enet_ver)) &&
+	    (h->port_type == HNAE_PORT_SERVICE)) {
+		memcpy(skb->data, ndev->dev_addr, 6);
+		skb->data[5] += 0x1f;
+	}
+
+	frame_size &= ~1ul;
+	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
+	memset(&skb->data[frame_size / 2 + 10], 0xBE, frame_size / 2 - 11);
+	memset(&skb->data[frame_size / 2 + 12], 0xAF, frame_size / 2 - 13);
+}
+
 static void __lb_other_process(struct hns_nic_ring_data *ring_data,
 			       struct sk_buff *skb)
 {
@@ -384,18 +408,6 @@ static void __lb_other_process(struct hns_nic_ring_data *ring_data,
 	u32 i;
 	char buff[33]; /* 32B data and the last character '\0' */
 
-	if (!ring_data) { /* Just for doing create frame*/
-		frame_size = skb->len;
-		memset(skb->data, 0xFF, frame_size);
-		frame_size &= ~1ul;
-		memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
-		memset(&skb->data[frame_size / 2 + 10], 0xBE,
-		       frame_size / 2 - 11);
-		memset(&skb->data[frame_size / 2 + 12], 0xAF,
-		       frame_size / 2 - 13);
-		return;
-	}
-
 	ring = ring_data->ring;
 	ndev = ring_data->napi.dev;
 	if (is_tx_ring(ring)) { /* for tx queue reset*/
@@ -486,7 +498,7 @@ static int __lb_run_test(struct net_device *ndev,
 
 	/* place data into test skb */
 	(void)skb_put(skb, size);
-	__lb_other_process(NULL, skb);
+	__lb_fill_txt_skb_buff(ndev, skb);
 	skb->queue_mapping = NIC_LB_TEST_RING_ID;
 
 	lc = 1;
-- 
1.9.1
