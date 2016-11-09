From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 16/17] net: hns: add multicast tcam table clear
Date: Wed, 9 Nov 2016 18:14:00 +0000
Message-ID: <20161109181401.913728-17-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

There is no clear operation before add a new multicast tcam table,
so the tcam table will be overflow when add more entries.

Reported-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h          |    3 +
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   11 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   12 +++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |    1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   79 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    3 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |    4 +
 7 files changed, 113 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index b0f0557..55c0334 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -426,6 +426,8 @@ enum hnae_media_type {
  *   get mac address
  * set_mac_addr()
  *   set mac address
+ * clr_mc_addr()
+ *   clear mcast tcam table
  * set_mc_addr()
  *   set multicast mode
  * set_mtu()
@@ -488,6 +490,7 @@ struct hnae_ae_ops {
 	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
 	int (*get_mac_addr)(struct hnae_handle *handle, void **p);
 	int (*set_mac_addr)(struct hnae_handle *handle, void *p);
+	int (*clr_mc_addr)(struct hnae_handle *handle);
 	int (*set_mc_addr)(struct hnae_handle *handle, void *addr);
 	int (*set_mtu)(struct hnae_handle *handle, int new_mtu);
 	void (*set_tso_stats)(struct hnae_handle *handle, int enable);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 193248f..366b25b 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -232,6 +232,16 @@ static int hns_ae_set_multicast_one(struct hnae_handle *handle, void *addr)
 	return ret;
 }
 
+static int hns_ae_clr_multicast(struct hnae_handle *handle)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	if (mac_cb->mac_type != HNAE_PORT_SERVICE)
+		return 0;
+
+	return hns_mac_clr_multicast(mac_cb, handle->vf_id);
+}
+
 static int hns_ae_set_mtu(struct hnae_handle *handle, int new_mtu)
 {
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
@@ -821,6 +831,7 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 	.set_promisc_mode = hns_ae_set_promisc_mode,
 	.set_mac_addr = hns_ae_set_mac_address,
 	.set_mc_addr = hns_ae_set_multicast_one,
+	.clr_mc_addr = hns_ae_clr_multicast,
 	.set_mtu = hns_ae_set_mtu,
 	.update_stats = hns_ae_update_stats,
 	.set_tso_stats = hns_ae_set_tso_stats,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index fc90260..266417d 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -330,6 +330,18 @@ int hns_mac_del_mac(struct hns_mac_cb *mac_cb, u32 vfn, char *mac)
 	return 0;
 }
 
+int hns_mac_clr_multicast(struct hns_mac_cb *mac_cb, int vfn)
+{
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	u8 port_num;
+	int ret = hns_mac_get_inner_port_num(mac_cb, vfn, &port_num);
+
+	if (ret)
+		return ret;
+
+	return hns_dsaf_clr_mac_mc_port(dsaf_dev, mac_cb->mac_id, port_num);
+}
+
 static void hns_mac_param_get(struct mac_params *param,
 			      struct hns_mac_cb *mac_cb)
 {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index ca7e175..d896452 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -461,5 +461,6 @@ int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en);
 int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 			       u8 vmid, u8 *port_num);
+int hns_mac_clr_multicast(struct hns_mac_cb *mac_cb, int vfn);
 
 #endif /* _HNS_DSAF_MAC_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 250e4a1..ebecbed 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -959,6 +959,16 @@ static void hns_dsaf_tcam_mc_invld(struct dsaf_device *dsaf_dev, u32 address)
 	spin_unlock_bh(&dsaf_dev->tcam_lock);
 }
 
+void hns_dsaf_tcam_addr_get(struct dsaf_drv_tbl_tcam_key *mac_key, u8 *addr)
+{
+	addr[0] = mac_key->high.bits.mac_0;
+	addr[1] = mac_key->high.bits.mac_1;
+	addr[2] = mac_key->high.bits.mac_2;
+	addr[3] = mac_key->high.bits.mac_3;
+	addr[4] = mac_key->low.bits.mac_4;
+	addr[5] = mac_key->low.bits.mac_5;
+}
+
 /**
  * hns_dsaf_tcam_uc_get - INT
  * @dsaf_id: dsa fabric id
@@ -1961,6 +1971,75 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 	return 0;
 }
 
+int hns_dsaf_clr_mac_mc_port(struct dsaf_device *dsaf_dev, u8 mac_id,
+			     u8 port_num)
+{
+	struct dsaf_drv_priv *priv = hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_soft_mac_tbl *soft_mac_entry;
+	struct dsaf_tbl_tcam_mcast_cfg mac_data;
+	int ret = 0, i;
+
+	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return 0;
+
+	for (i = 0; i < DSAF_TCAM_SUM - DSAFV2_MAC_FUZZY_TCAM_NUM; i++) {
+		u8 addr[ETH_ALEN];
+		u8 port;
+
+		soft_mac_entry = priv->soft_mac_tbl + i;
+
+		hns_dsaf_tcam_addr_get(&soft_mac_entry->tcam_key, addr);
+		port = dsaf_get_field(
+				soft_mac_entry->tcam_key.low.bits.port_vlan,
+				DSAF_TBL_TCAM_KEY_PORT_M,
+				DSAF_TBL_TCAM_KEY_PORT_S);
+		/* check valid tcam mc entry */
+		if (soft_mac_entry->index != DSAF_INVALID_ENTRY_IDX &&
+		    port == mac_id &&
+		    is_multicast_ether_addr(addr) &&
+		    !is_broadcast_ether_addr(addr)) {
+			const u32 empty_msk[DSAF_PORT_MSK_NUM] = {0};
+			struct dsaf_drv_mac_single_dest_entry mac_entry;
+
+			/* disable receiving of this multicast address for
+			 * the VF.
+			 */
+			ether_addr_copy(mac_entry.addr, addr);
+			mac_entry.in_vlan_id = dsaf_get_field(
+				soft_mac_entry->tcam_key.low.bits.port_vlan,
+				DSAF_TBL_TCAM_KEY_VLAN_M,
+				DSAF_TBL_TCAM_KEY_VLAN_S);
+			mac_entry.in_port_num = mac_id;
+			mac_entry.port_num = port_num;
+			if (hns_dsaf_del_mac_mc_port(dsaf_dev, &mac_entry)) {
+				ret = -EINVAL;
+				continue;
+			}
+
+			/* disable receiving of this multicast address for
+			 * the mac port if all VF are disable
+			 */
+			hns_dsaf_tcam_mc_get(dsaf_dev, i,
+					     (struct dsaf_tbl_tcam_data *)
+					     (&soft_mac_entry->tcam_key),
+					     &mac_data);
+			dsaf_set_bit(mac_data.tbl_mcast_port_msk[mac_id / 32],
+				     mac_id % 32, 0);
+			if (!memcmp(mac_data.tbl_mcast_port_msk, empty_msk,
+				    sizeof(u32) * DSAF_PORT_MSK_NUM)) {
+				mac_entry.port_num = mac_id;
+				if (hns_dsaf_del_mac_mc_port(dsaf_dev,
+							     &mac_entry)) {
+					ret = -EINVAL;
+					continue;
+				}
+			}
+		}
+	}
+
+	return ret;
+}
+
 /**
  * hns_dsaf_get_mac_uc_entry - get mac uc entry
  * @dsaf_dev: dsa fabric device struct pointer
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index c68555b..901037c 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -468,5 +468,8 @@ void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				  u32 *en);
 int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				 u32 en);
+int hns_dsaf_clr_mac_mc_port(struct dsaf_device *dsaf_dev,
+			     u8 mac_id, u8 port_num);
+
 
 #endif /* __HNS_DSAF_MAIN_H__ */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 60831a2..d22a39e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1511,6 +1511,10 @@ void hns_set_multicast_list(struct net_device *ndev)
 		return;
 	}
 
+	if (h->dev->ops->clr_mc_addr)
+		if (h->dev->ops->clr_mc_addr(h))
+			netdev_err(ndev, "clear multicast address fail\n");
+
 	if (h->dev->ops->set_mc_addr) {
 		netdev_for_each_mc_addr(ha, ndev)
 			if (h->dev->ops->set_mc_addr(h, ha->addr))
-- 
1.7.9.5
