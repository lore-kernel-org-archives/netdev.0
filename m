From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH net 3/6] net: hns: fixed portid bug in sending manage pkt
Date: Fri, 4 Mar 2016 11:05:39 +0800
Message-ID: <1457060742-165202-4-git-send-email-huangdaode@hisilicon.com>
References: <1457060742-165202-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<huangdaode@hisilicon.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457060742-165202-1-git-send-email-huangdaode@hisilicon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In V2 chip, when sending mamagement packets, the driver should
config the port id to BD descs.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         | 3 +++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 4 ++++
 3 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 1cbcb9f..11a3f97 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -147,6 +147,8 @@ enum hnae_led_state {
 
 #define HNSV2_TXD_BUFNUM_S 0
 #define HNSV2_TXD_BUFNUM_M (0x7 << HNSV2_TXD_BUFNUM_S)
+#define HNSV2_TXD_PORTID_S	4
+#define HNSV2_TXD_PORTID_M	(0X7 << HNSV2_TXD_PORTID_S)
 #define HNSV2_TXD_RI_B   1
 #define HNSV2_TXD_L4CS_B   2
 #define HNSV2_TXD_L3CS_B   3
@@ -516,6 +518,7 @@ struct hnae_handle {
 	int q_num;
 	int vf_id;
 	u32 eport_id;
+	u32 dport_id;	/*v2 tx bd should fill the dport_id*/
 	enum hnae_port_type port_type;
 	struct list_head node;    /* list to hnae_ae_dev->handle_list */
 	struct hnae_buf_ops *bops; /* operation for the buffer */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index a0070d0..ea2561a 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -175,6 +175,7 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	ae_handle->phy_node = vf_cb->mac_cb->phy_node;
 	ae_handle->if_support = vf_cb->mac_cb->if_support;
 	ae_handle->port_type = vf_cb->mac_cb->mac_type;
+	ae_handle->dport_id = port_idx;
 
 	return ae_handle;
 vf_id_err:
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 6250a42..b45dcc2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -69,6 +69,10 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 	hnae_set_bit(rrcfv, HNSV2_TXD_VLD_B, 1);
 	hnae_set_field(bn_pid, HNSV2_TXD_BUFNUM_M, 0, buf_num - 1);
 
+	/*fill port_id in the tx bd for sending management pkts*/
+	hnae_set_field(bn_pid, HNSV2_TXD_PORTID_M,
+		       HNSV2_TXD_PORTID_S, ring->q->handle->dport_id);
+
 	if (type == DESC_TYPE_SKB) {
 		skb = (struct sk_buff *)priv;
 
-- 
1.9.1
