From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 17/17] net: hns: add the support to add/remove the ucast entry to/from table
Date: Wed, 9 Nov 2016 18:14:01 +0000
Message-ID: <20161109181401.913728-18-salil.mehta@huawei.com>
References: <20161109181401.913728-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:56871 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932242AbcKIUea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 15:34:30 -0500
In-Reply-To: <20161109181401.913728-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kejian Yan <yankejian@huawei.com>

This patch adds the support to add or remove the unicast entries
to the table and remove from the table.

Reported-by: Daode Huang <huangdaode@hisilicon.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h          |    8 ++++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |   24 ++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   40 ++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |    4 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |   49 ++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    4 ++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |   26 +++++++++++
 7 files changed, 155 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 55c0334..09602f1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -430,6 +430,10 @@ enum hnae_media_type {
  *   clear mcast tcam table
  * set_mc_addr()
  *   set multicast mode
+ * add_uc_addr()
+ *   add ucast address
+ * rm_uc_addr()
+ *   remove ucast address
  * set_mtu()
  *   set mtu
  * update_stats()
@@ -490,6 +494,10 @@ struct hnae_ae_ops {
 	void (*set_promisc_mode)(struct hnae_handle *handle, u32 en);
 	int (*get_mac_addr)(struct hnae_handle *handle, void **p);
 	int (*set_mac_addr)(struct hnae_handle *handle, void *p);
+	int (*add_uc_addr)(struct hnae_handle *handle,
+			   const unsigned char *addr);
+	int (*rm_uc_addr)(struct hnae_handle *handle,
+			  const unsigned char *addr);
 	int (*clr_mc_addr)(struct hnae_handle *handle);
 	int (*set_mc_addr)(struct hnae_handle *handle, void *addr);
 	int (*set_mtu)(struct hnae_handle *handle, int new_mtu);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 366b25b..0a9cdf0 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -199,6 +199,28 @@ static int hns_ae_set_mac_address(struct hnae_handle *handle, void *p)
 	return 0;
 }
 
+static int hns_ae_add_uc_address(struct hnae_handle *handle,
+				 const unsigned char *addr)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	if (mac_cb->mac_type != HNAE_PORT_SERVICE)
+		return -ENOSPC;
+
+	return hns_mac_add_uc_addr(mac_cb, handle->vf_id, addr);
+}
+
+static int hns_ae_rm_uc_address(struct hnae_handle *handle,
+				const unsigned char *addr)
+{
+	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
+
+	if (mac_cb->mac_type != HNAE_PORT_SERVICE)
+		return -ENOSPC;
+
+	return hns_mac_rm_uc_addr(mac_cb, handle->vf_id, addr);
+}
+
 static int hns_ae_set_multicast_one(struct hnae_handle *handle, void *addr)
 {
 	int ret;
@@ -830,6 +852,8 @@ static int hns_ae_set_rss(struct hnae_handle *handle, const u32 *indir,
 	.get_coalesce_range = hns_ae_get_coalesce_range,
 	.set_promisc_mode = hns_ae_set_promisc_mode,
 	.set_mac_addr = hns_ae_set_mac_address,
+	.add_uc_addr = hns_ae_add_uc_address,
+	.rm_uc_addr = hns_ae_rm_uc_address,
 	.set_mc_addr = hns_ae_set_multicast_one,
 	.clr_mc_addr = hns_ae_clr_multicast,
 	.set_mtu = hns_ae_set_mtu,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 266417d..3239d27 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -263,6 +263,46 @@ int hns_mac_change_vf_addr(struct hns_mac_cb *mac_cb,
 	return 0;
 }
 
+int hns_mac_add_uc_addr(struct hns_mac_cb *mac_cb, u8 vf_id,
+			const unsigned char *addr)
+{
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+	int ret;
+
+	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return -ENOSPC;
+
+	memset(&mac_entry, 0, sizeof(mac_entry));
+	memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+	mac_entry.in_port_num = mac_cb->mac_id;
+	ret = hns_mac_get_inner_port_num(mac_cb, vf_id, &mac_entry.port_num);
+	if (ret)
+		return ret;
+
+	return hns_dsaf_set_mac_uc_entry(dsaf_dev, &mac_entry);
+}
+
+int hns_mac_rm_uc_addr(struct hns_mac_cb *mac_cb, u8 vf_id,
+		       const unsigned char *addr)
+{
+	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
+	struct dsaf_drv_mac_single_dest_entry mac_entry;
+	int ret;
+
+	if (HNS_DSAF_IS_DEBUG(dsaf_dev))
+		return -ENOSPC;
+
+	memset(&mac_entry, 0, sizeof(mac_entry));
+	memcpy(mac_entry.addr, addr, sizeof(mac_entry.addr));
+	mac_entry.in_port_num = mac_cb->mac_id;
+	ret = hns_mac_get_inner_port_num(mac_cb, vf_id, &mac_entry.port_num);
+	if (ret)
+		return ret;
+
+	return hns_dsaf_rm_mac_addr(dsaf_dev, &mac_entry);
+}
+
 int hns_mac_set_multi(struct hns_mac_cb *mac_cb,
 		      u32 port_num, char *addr, bool enable)
 {
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index d896452..2bb3d1e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -461,6 +461,10 @@ int hns_cpld_led_set_id(struct hns_mac_cb *mac_cb,
 void hns_mac_set_promisc(struct hns_mac_cb *mac_cb, u8 en);
 int hns_mac_get_inner_port_num(struct hns_mac_cb *mac_cb,
 			       u8 vmid, u8 *port_num);
+int hns_mac_add_uc_addr(struct hns_mac_cb *mac_cb, u8 vf_id,
+			const unsigned char *addr);
+int hns_mac_rm_uc_addr(struct hns_mac_cb *mac_cb, u8 vf_id,
+		       const unsigned char *addr);
 int hns_mac_clr_multicast(struct hns_mac_cb *mac_cb, int vfn);
 
 #endif /* _HNS_DSAF_MAC_H */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index ebecbed..90dbda7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -1598,6 +1598,55 @@ int hns_dsaf_set_mac_uc_entry(
 	return 0;
 }
 
+int hns_dsaf_rm_mac_addr(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_mac_single_dest_entry *mac_entry)
+{
+	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
+	struct dsaf_tbl_tcam_ucast_cfg mac_data;
+	struct dsaf_drv_tbl_tcam_key mac_key;
+
+	/* mac addr check */
+	if (!is_valid_ether_addr(mac_entry->addr)) {
+		dev_err(dsaf_dev->dev, "rm_uc_addr %s Mac %pM err!\n",
+			dsaf_dev->ae_dev.name, mac_entry->addr);
+		return -EINVAL;
+	}
+
+	/* config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, mac_entry->in_vlan_id,
+			     mac_entry->in_port_num, mac_entry->addr);
+
+	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
+	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
+		/* can not find the tcam entry, return 0 */
+		dev_info(dsaf_dev->dev,
+			 "rm_uc_addr no tcam, %s Mac key(%#x:%#x)\n",
+			 dsaf_dev->ae_dev.name,
+			 mac_key.high.val, mac_key.low.val);
+		return 0;
+	}
+
+	dev_dbg(dsaf_dev->dev,
+		"rm_uc_addr, %s Mac key(%#x:%#x) entry_index%d\n",
+		dsaf_dev->ae_dev.name, mac_key.high.val,
+		mac_key.low.val, entry_index);
+
+	hns_dsaf_tcam_uc_get(
+			dsaf_dev, entry_index,
+			(struct dsaf_tbl_tcam_data *)&mac_key,
+			&mac_data);
+
+	/* unicast entry not used locally should not clear */
+	if (mac_entry->port_num != mac_data.tbl_ucast_out_port)
+		return -EFAULT;
+
+	return hns_dsaf_del_mac_entry(dsaf_dev,
+				      mac_entry->in_vlan_id,
+				      mac_entry->in_port_num,
+				      mac_entry->addr);
+}
+
 /**
  * hns_dsaf_set_mac_mc_entry - set mac mc-entry
  * @dsaf_dev: dsa fabric device struct pointer
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index 901037c..cef6bf4 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -468,6 +468,10 @@ void hns_dsaf_get_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				  u32 *en);
 int hns_dsaf_set_rx_mac_pause_en(struct dsaf_device *dsaf_dev, int mac_id,
 				 u32 en);
+int hns_dsaf_rm_mac_addr(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_drv_mac_single_dest_entry *mac_entry);
+
 int hns_dsaf_clr_mac_mc_port(struct dsaf_device *dsaf_dev,
 			     u8 mac_id, u8 port_num);
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index d22a39e..776d81e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1493,6 +1493,29 @@ static netdev_features_t hns_nic_fix_features(
 	return features;
 }
 
+static int hns_nic_uc_sync(struct net_device *netdev, const unsigned char *addr)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	if (h->dev->ops->add_uc_addr)
+		return h->dev->ops->add_uc_addr(h, addr);
+
+	return 0;
+}
+
+static int hns_nic_uc_unsync(struct net_device *netdev,
+			     const unsigned char *addr)
+{
+	struct hns_nic_priv *priv = netdev_priv(netdev);
+	struct hnae_handle *h = priv->ae_handle;
+
+	if (h->dev->ops->rm_uc_addr)
+		return h->dev->ops->rm_uc_addr(h, addr);
+
+	return 0;
+}
+
 /**
  * nic_set_multicast_list - set mutl mac address
  * @netdev: net device
@@ -1535,6 +1558,9 @@ void hns_nic_set_rx_mode(struct net_device *ndev)
 	}
 
 	hns_set_multicast_list(ndev);
+
+	if (__dev_uc_sync(ndev, hns_nic_uc_sync, hns_nic_uc_unsync))
+		netdev_err(ndev, "sync uc address fail\n");
 }
 
 struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
-- 
1.7.9.5
