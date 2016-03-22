From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH V2 net 02/10] net: hns: fixed portid bug in sending manage pkt
Date: Tue, 22 Mar 2016 16:06:23 +0800
Message-ID: <1458633991-64313-3-git-send-email-Yisen.Zhuang@huawei.com>
References: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <yankejian@huawei.com>, <huangdaode@hisilicon.com>,
	<salil.mehta@huawei.com>, <lisheng011@huawei.com>,
	<lipeng321@huawei.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<sergei.shtylyov@cogentembedded.com>, <xieqianqian@huawei.com>,
	<andrew@lunn.ch>, <ivecera@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458633991-64313-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sheng Li <lisheng011@huawei.com>

In chip V2, the default value of port id in tx BD is Zero. If it is not
configurated to the other value, all management packets will be sent out
from port0. So port_id in the tx BD needs to be updated when sending a
management packet.

In V2 chip, when sending mamagement packets, the driver should
config the port id to BD descs.

Signed-off-by: Sheng Li <lisheng011@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         | 3 +++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c | 1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c     | 6 +++++-
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 1cbcb9f..37d0cce 100644
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
+	u32 dport_id;	/* v2 tx bd should fill the dport_id */
 	enum hnae_port_type port_type;
 	struct list_head node;    /* list to hnae_ae_dev->handle_list */
 	struct hnae_buf_ops *bops; /* operation for the buffer */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index d4f92ed..90352d6 100644
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
index ef84bd7..ef517af 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -66,10 +66,14 @@ static void fill_v2_desc(struct hnae_ring *ring, void *priv,
 	desc->addr = cpu_to_le64(dma);
 	desc->tx.send_size = cpu_to_le16((u16)size);
 
-	/*config bd buffer end */
+	/* config bd buffer end */
 	hnae_set_bit(rrcfv, HNSV2_TXD_VLD_B, 1);
 	hnae_set_field(bn_pid, HNSV2_TXD_BUFNUM_M, 0, buf_num - 1);
 
+	/* fill port_id in the tx bd for sending management pkts */
+	hnae_set_field(bn_pid, HNSV2_TXD_PORTID_M,
+		       HNSV2_TXD_PORTID_S, ring->q->handle->dport_id);
+
 	if (type == DESC_TYPE_SKB) {
 		skb = (struct sk_buff *)priv;
 
-- 
1.9.1
