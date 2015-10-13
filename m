From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next] net:hisilicon: supports promisc mode
Date: Tue, 13 Oct 2015 09:53:45 +0800
Message-ID: <1444701225-52153-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <liguozhu@huawei.com>, <yisen.zhuang@huawei.com>,
	<huangdaode@hisilicon.com>, <yankejian@huawei.com>,
	<davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  this patch adds support to set promisc mode. it configs the queue on
init seq  when it is on promisc mode.and being enabled or disabled promisc
mode by upper level user.

Signed-off-by: yankejian <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  6 +++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 27 ++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h  |  2 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 17 +++++++++++++-
 7 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 5edd8cd..dd4aa1b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -429,6 +429,7 @@ struct hnae_ae_ops {
 	void (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
 	int (*set_coalesce_frames)(struct hnae_handle *handle,
 				   u32 coalesce_frames);
+	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
 	int (*get_mac_addr)(struct hnae_handle *handle, void **p);
 	int (*set_mac_addr)(struct hnae_handle *handle, void *p);
 	int (*set_mc_addr)(struct hnae_handle *handle, void *addr);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index a2c72f8..1a16c03 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -392,6 +392,11 @@ static int hns_ae_set_autoneg(struct hnae_handle *handle, u8 enable)
 	return hns_mac_set_autoneg(hns_get_mac_cb(handle), enable);
 }
 
+static void hns_ae_set_promisc_mode(struct hnae_handle *handle, u32 en)
+{
+	hns_dsaf_set_promisc_mode(hns_ae_get_dsaf_dev(handle->dev), en);
+}
+
 static int hns_ae_get_autoneg(struct hnae_handle *handle)
 {
 	u32     auto_neg;
@@ -748,6 +753,7 @@ static struct hnae_ae_ops hns_dsaf_ops = {
 	.get_rx_max_coalesced_frames = hns_ae_get_rx_max_coalesced_frames,
 	.set_coalesce_usecs = hns_ae_set_coalesce_usecs,
 	.set_coalesce_frames = hns_ae_set_coalesce_frames,
+	.set_promisc_mode = hns_ae_set_promisc_mode,
 	.set_mac_addr = hns_ae_set_mac_address,
 	.set_mc_addr = hns_ae_set_multicast_one,
 	.set_mtu = hns_ae_set_mtu,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 26ae6c6..ffc2604 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -217,6 +217,25 @@ hns_dsaf_ppe_qid_cfg(struct dsaf_device *dsaf_dev, u32 qid_cfg)
 	}
 }
 
+static void hns_dsaf_mix_def_qid_cfg(struct dsaf_device *dsaf_dev)
+{
+	u16 max_q_per_vf, max_vfn;
+	u32 q_id, q_num_per_port;
+	u32 i;
+
+	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
+			       HNS_DSAF_COMM_SERVICE_NW_IDX,
+			       &max_vfn, &max_q_per_vf);
+	q_num_per_port = max_vfn * max_q_per_vf;
+
+	for (i = 0, q_id = 0; i < DSAF_SERVICE_NW_NUM; i++) {
+		dsaf_set_dev_field(dsaf_dev,
+				   DSAF_MIX_DEF_QID_0_REG + 0x0004 * i,
+				   0xff, 0, q_id);
+		q_id += q_num_per_port;
+	}
+}
+
 /**
  * hns_dsaf_sw_port_type_cfg - cfg sw type
  * @dsaf_id: dsa fabric id
@@ -592,6 +611,11 @@ static void hns_dsaf_tbl_tcam_data_ucast_pul(
 	dsaf_write_dev(dsaf_dev, DSAF_TBL_PUL_0_REG, o_tbl_pul);
 }
 
+void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en)
+{
+	dsaf_set_dev_bit(dsaf_dev, DSAF_CFG_0_REG, DSAF_CFG_MIX_MODE_S, !!en);
+}
+
 /**
  * hns_dsaf_tbl_stat_en - tbl
  * @dsaf_id: dsa fabric id
@@ -920,6 +944,9 @@ static void hns_dsaf_comm_init(struct dsaf_device *dsaf_dev)
 	/* set 22 queue per tx ppe engine, only used in switch mode */
 	hns_dsaf_ppe_qid_cfg(dsaf_dev, DSAF_DEFAUTL_QUEUE_NUM_PER_PPE);
 
+	/* set promisc def queue id */
+	hns_dsaf_mix_def_qid_cfg(dsaf_dev);
+
 	/* in non switch mode, set all port to access mode */
 	hns_dsaf_sw_port_type_cfg(dsaf_dev, DSAF_SW_PORT_TYPE_NON_VLAN);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 315b07e..b2b9348 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -423,5 +423,6 @@ void hns_dsaf_get_strings(int stringset, u8 *data, int port);
 
 void hns_dsaf_get_regs(struct dsaf_device *ddev, u32 port, void *data);
 int hns_dsaf_get_regs_count(void);
+void hns_dsaf_set_promisc_mode(struct dsaf_device *dsaf_dev, u32 en);
 
 #endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 05ea244..4db32c6 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -575,8 +575,8 @@ int hns_rcb_set_coalesced_frames(struct dsaf_device *dsaf_dev,
  *@max_vfn : max vfn number
  *@max_q_per_vf:max ring number per vm
  */
-static void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
-				   u16 *max_vfn, u16 *max_q_per_vf)
+void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
+			    u16 *max_vfn, u16 *max_q_per_vf)
 {
 	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
 		switch (dsaf_mode) {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
index c7db613..3a2afe2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -107,6 +107,8 @@ int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
 void hns_rcb_start(struct hnae_queue *q, u32 val);
 void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
 void hns_rcb_common_init_commit_hw(struct rcb_common_cb *rcb_common);
+void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, int comm_index,
+			    u16 *max_vfn, u16 *max_q_per_vf);
 
 void hns_rcb_ring_enable_hw(struct hnae_queue *q, u32 val);
 void hns_rcb_int_clr_hw(struct hnae_queue *q, u32 flag);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index ce7f2e0..6f9091c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1161,6 +1161,21 @@ void hns_set_multicast_list(struct net_device *ndev)
 	}
 }
 
+void hns_nic_set_rx_mode(struct net_device *ndev)
+{
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	if (h->dev->ops->set_promisc_mode) {
+		if (ndev->flags & IFF_PROMISC)
+			h->dev->ops->set_promisc_mode(h, 1);
+		else
+			h->dev->ops->set_promisc_mode(h, 0);
+	}
+
+	hns_set_multicast_list(ndev);
+}
+
 struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
 					      struct rtnl_link_stats64 *stats)
 {
@@ -1220,7 +1235,7 @@ static const struct net_device_ops hns_nic_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = hns_nic_poll_controller,
 #endif
-	.ndo_set_rx_mode = hns_set_multicast_list,
+	.ndo_set_rx_mode = hns_nic_set_rx_mode,
 };
 
 static void hns_nic_update_link_status(struct net_device *netdev)
-- 
1.9.1
