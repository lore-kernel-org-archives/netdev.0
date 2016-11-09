From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 02/17] net: hns: add fuzzy match of tcam table for hns
Date: Wed, 9 Nov 2016 18:13:46 +0000
Message-ID: <20161109181401.913728-3-salil.mehta@huawei.com>
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

Since there is not enough tcam table entries for vlan and multicast
address, HNSv2 needs to add support of fuzzy matching of TCAM tables.
To add fuzzy match of TCAM, we Add the property to mask the bits to
be fuzzy matched

Signed-off-by: Kejian Yan <yankejian@huawei.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |   16 ++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |    8 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  140 ++++++++++++++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |    6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |    2 +
 5 files changed, 118 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 55cbb6c..2d64f53 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -335,8 +335,7 @@ static void hns_mac_param_get(struct mac_params *param,
 {
 	param->vaddr = (void *)mac_cb->vaddr;
 	param->mac_mode = hns_get_enet_interface(mac_cb);
-	memcpy(param->addr, mac_cb->addr_entry_idx[0].addr,
-	       MAC_NUM_OCTETS_PER_ADDR);
+	ether_addr_copy(param->addr, mac_cb->addr_entry_idx[0].addr);
 	param->mac_id = mac_cb->mac_id;
 	param->dev = mac_cb->dev;
 }
@@ -353,8 +352,7 @@ static int hns_mac_port_config_bc_en(struct hns_mac_cb *mac_cb,
 {
 	int ret;
 	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
-	u8 addr[MAC_NUM_OCTETS_PER_ADDR]
-		= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	u8 addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct dsaf_drv_mac_single_dest_entry mac_entry;
 
 	/* directy return ok in debug network mode */
@@ -389,8 +387,7 @@ int hns_mac_vm_config_bc_en(struct hns_mac_cb *mac_cb, u32 vmid, bool enable)
 	int ret;
 	struct dsaf_device *dsaf_dev = mac_cb->dsaf_dev;
 	u8 port_num;
-	u8 addr[MAC_NUM_OCTETS_PER_ADDR]
-		= {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+	u8 addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 	struct mac_entry_idx *uc_mac_entry;
 	struct dsaf_drv_mac_single_dest_entry mac_entry;
 
@@ -868,6 +865,13 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 		}
 	}
 
+	if (fwnode_property_read_u8_array(mac_cb->fw_port, "mc-mac-mask",
+					  mac_cb->mc_mask, ETH_ALEN)) {
+		dev_warn(mac_cb->dev,
+			 "no mc-mac-mask property, set to default value.\n");
+		eth_broadcast_addr(mac_cb->mc_mask);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index d3a1f72..1d941d5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -56,9 +56,6 @@
 /*check mac addr multicast*/
 #define MAC_IS_MULTICAST(p)	((*((u8 *)((p) + 0)) & 0x01) ? (1) : (0))
 
-/**< Number of octets (8-bit bytes) in an ethernet address */
-#define MAC_NUM_OCTETS_PER_ADDR 6
-
 struct mac_priv {
 	void *mac;
 };
@@ -189,7 +186,7 @@ struct mac_statistics {
 
 /*mac para struct ,mac get param from nic or dsaf when initialize*/
 struct mac_params {
-	char addr[MAC_NUM_OCTETS_PER_ADDR];
+	char addr[ETH_ALEN];
 	void *vaddr; /*virtual address*/
 	struct device *dev;
 	u8 mac_id;
@@ -214,7 +211,7 @@ struct mac_info {
 };
 
 struct mac_entry_idx {
-	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u8 addr[ETH_ALEN];
 	u16 vlan_id:12;
 	u16 valid:1;
 	u16 qos:3;
@@ -317,6 +314,7 @@ struct hns_mac_cb {
 	u8 __iomem *serdes_vaddr;
 	struct regmap *serdes_ctrl;
 	struct regmap *cpld_ctrl;
+	char mc_mask[ETH_ALEN];
 	u32 cpld_ctrl_reg;
 	u32 port_rst_off;
 	u32 port_mode_off;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index 8ea3d95..64f45ee 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -591,6 +591,16 @@ static void hns_dsaf_voq_bp_all_thrd_cfg(struct dsaf_device *dsaf_dev)
 	}
 }
 
+static void hns_dsaf_tbl_tcam_match_cfg(
+	struct dsaf_device *dsaf_dev,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_data)
+{
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MATCH_CFG_L_REG,
+		       ptbl_tcam_data->tbl_tcam_data_low);
+	dsaf_write_dev(dsaf_dev, DSAF_TBL_TCAM_MATCH_CFG_H_REG,
+		       ptbl_tcam_data->tbl_tcam_data_high);
+}
+
 /**
  * hns_dsaf_tbl_tcam_data_cfg - tbl
  * @dsaf_id: dsa fabric id
@@ -894,15 +904,16 @@ static void hns_dsaf_tcam_uc_cfg(
 }
 
 /**
- * hns_dsaf_tcam_mc_cfg - INT
- * @dsaf_id: dsa fabric id
- * @address,
- * @ptbl_tcam_data,
- * @ptbl_tcam_mcast,
+ * hns_dsaf_tcam_mc_cfg - cfg the tcam for mc
+ * @dsaf_dev: dsa fabric device struct pointer
+ * @address: tcam index
+ * @ptbl_tcam_data: tcam data struct pointer
+ * @ptbl_tcam_mcast: tcam mask struct pointer, it must be null for HNSv1
  */
 static void hns_dsaf_tcam_mc_cfg(
 	struct dsaf_device *dsaf_dev, u32 address,
 	struct dsaf_tbl_tcam_data *ptbl_tcam_data,
+	struct dsaf_tbl_tcam_data *ptbl_tcam_mask,
 	struct dsaf_tbl_tcam_mcast_cfg *ptbl_tcam_mcast)
 {
 	spin_lock_bh(&dsaf_dev->tcam_lock);
@@ -913,7 +924,11 @@ static void hns_dsaf_tcam_mc_cfg(
 	hns_dsaf_tbl_tcam_data_cfg(dsaf_dev, ptbl_tcam_data);
 	/*Write Tcam Mcast*/
 	hns_dsaf_tbl_tcam_mcast_cfg(dsaf_dev, ptbl_tcam_mcast);
-	/*Write Plus*/
+	/* Write Match Data */
+	if (ptbl_tcam_mask)
+		hns_dsaf_tbl_tcam_match_cfg(dsaf_dev, ptbl_tcam_mask);
+
+	/* Write Puls */
 	hns_dsaf_tbl_tcam_data_mcast_pul(dsaf_dev);
 
 	spin_unlock_bh(&dsaf_dev->tcam_lock);
@@ -1625,7 +1640,7 @@ int hns_dsaf_set_mac_mc_entry(
 
 	hns_dsaf_tcam_mc_cfg(
 		dsaf_dev, entry_index,
-		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+		(struct dsaf_tbl_tcam_data *)(&mac_key), NULL, &mac_data);
 
 	/* config software entry */
 	soft_mac_entry += entry_index;
@@ -1636,6 +1651,16 @@ int hns_dsaf_set_mac_mc_entry(
 	return 0;
 }
 
+static void hns_dsaf_mc_mask_bit_clear(char *dst, const char *src)
+{
+	u16 *a = (u16 *)dst;
+	const u16 *b = (const u16 *)src;
+
+	a[0] &= b[0];
+	a[1] &= b[1];
+	a[2] &= b[2];
+}
+
 /**
  * hns_dsaf_add_mac_mc_port - add mac mc-port
  * @dsaf_dev: dsa fabric device struct pointer
@@ -1646,11 +1671,14 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 {
 	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
 	struct dsaf_drv_tbl_tcam_key mac_key;
+	struct dsaf_drv_tbl_tcam_key mask_key;
+	struct dsaf_tbl_tcam_data *pmask_key = NULL;
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
-	struct dsaf_drv_priv *priv =
-	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_priv *priv = hns_dsaf_dev_priv(dsaf_dev);
 	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
-	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+	struct dsaf_tbl_tcam_data tcam_data;
+	u8 mc_addr[ETH_ALEN];
+	u8 *mc_mask;
 	int mskid;
 
 	/*chechk mac addr */
@@ -1660,14 +1688,28 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 		return -EINVAL;
 	}
 
+	ether_addr_copy(mc_addr, mac_entry->addr);
+	mc_mask = dsaf_dev->mac_cb[mac_entry->in_port_num]->mc_mask;
+	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		/* prepare for key data setting */
+		hns_dsaf_mc_mask_bit_clear(mc_addr, mc_mask);
+
+		/* config key mask */
+		hns_dsaf_set_mac_key(dsaf_dev, &mask_key,
+				     0x0,
+				     0xff,
+				     mc_mask);
+		pmask_key = (struct dsaf_tbl_tcam_data *)(&mask_key);
+	}
+
 	/*config key */
 	hns_dsaf_set_mac_key(
 		dsaf_dev, &mac_key, mac_entry->in_vlan_id,
-		mac_entry->in_port_num, mac_entry->addr);
+		mac_entry->in_port_num, mc_addr);
 
 	memset(&mac_data, 0, sizeof(struct dsaf_tbl_tcam_mcast_cfg));
 
-	/*check exist? */
+	/* check if the tcam is exist */
 	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
 	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
 		/*if hasnot , find a empty*/
@@ -1681,11 +1723,11 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 			return -EINVAL;
 		}
 	} else {
-		/*if exist, add in */
-		hns_dsaf_tcam_mc_get(
-			dsaf_dev, entry_index,
-			(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+		/* if exist, add in */
+		hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data,
+				     &mac_data);
 	}
+
 	/* config hardware entry */
 	if (mac_entry->port_num < DSAF_SERVICE_NW_NUM) {
 		mskid = mac_entry->port_num;
@@ -1708,9 +1750,12 @@ int hns_dsaf_add_mac_mc_port(struct dsaf_device *dsaf_dev,
 		dsaf_dev->ae_dev.name, mac_key.high.val,
 		mac_key.low.val, entry_index);
 
-	hns_dsaf_tcam_mc_cfg(
-		dsaf_dev, entry_index,
-		(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+	tcam_data.tbl_tcam_data_high = mac_key.high.val;
+	tcam_data.tbl_tcam_data_low = mac_key.low.val;
+
+	/* config mc entry with mask */
+	hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index, &tcam_data,
+			     pmask_key, &mac_data);
 
 	/*config software entry */
 	soft_mac_entry += entry_index;
@@ -1782,15 +1827,18 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 {
 	u16 entry_index = DSAF_INVALID_ENTRY_IDX;
 	struct dsaf_drv_tbl_tcam_key mac_key;
-	struct dsaf_drv_priv *priv =
-	    (struct dsaf_drv_priv *)hns_dsaf_dev_priv(dsaf_dev);
+	struct dsaf_drv_priv *priv = hns_dsaf_dev_priv(dsaf_dev);
 	struct dsaf_drv_soft_mac_tbl *soft_mac_entry = priv->soft_mac_tbl;
 	u16 vlan_id;
 	u8 in_port_num;
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
-	struct dsaf_drv_tbl_tcam_key tmp_mac_key;
+	struct dsaf_tbl_tcam_data tcam_data;
 	int mskid;
 	const u8 empty_msk[sizeof(mac_data.tbl_mcast_port_msk)] = {0};
+	struct dsaf_drv_tbl_tcam_key mask_key;
+	struct dsaf_tbl_tcam_data *pmask_key = NULL;
+	u8 mc_addr[ETH_ALEN];
+	u8 *mc_mask;
 
 	if (!(void *)mac_entry) {
 		dev_err(dsaf_dev->dev,
@@ -1798,10 +1846,6 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		return -EINVAL;
 	}
 
-	/*get key info*/
-	vlan_id = mac_entry->in_vlan_id;
-	in_port_num = mac_entry->in_port_num;
-
 	/*check mac addr */
 	if (MAC_IS_ALL_ZEROS(mac_entry->addr)) {
 		dev_err(dsaf_dev->dev, "del_port failed, addr %pM!\n",
@@ -1809,11 +1853,28 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		return -EINVAL;
 	}
 
-	/*config key */
-	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, vlan_id, in_port_num,
-			     mac_entry->addr);
+	/* always mask vlan_id field */
+	ether_addr_copy(mc_addr, mac_entry->addr);
+	mc_mask = dsaf_dev->mac_cb[mac_entry->in_port_num]->mc_mask;
 
-	/*check is exist? */
+	if (!AE_IS_VER1(dsaf_dev->dsaf_ver)) {
+		/* prepare for key data setting */
+		hns_dsaf_mc_mask_bit_clear(mc_addr, mc_mask);
+
+		/* config key mask */
+		hns_dsaf_set_mac_key(dsaf_dev, &mask_key, 0x00, 0xff, mc_addr);
+
+		pmask_key = (struct dsaf_tbl_tcam_data *)(&mask_key);
+	}
+
+	/* get key info */
+	vlan_id = mac_entry->in_vlan_id;
+	in_port_num = mac_entry->in_port_num;
+
+	/* config key */
+	hns_dsaf_set_mac_key(dsaf_dev, &mac_key, vlan_id, in_port_num, mc_addr);
+
+	/* check if the tcam entry is exist */
 	entry_index = hns_dsaf_find_soft_mac_entry(dsaf_dev, &mac_key);
 	if (entry_index == DSAF_INVALID_ENTRY_IDX) {
 		/*find none */
@@ -1829,10 +1890,8 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		dsaf_dev->ae_dev.name, mac_key.high.val,
 		mac_key.low.val, entry_index);
 
-	/*read entry*/
-	hns_dsaf_tcam_mc_get(
-		dsaf_dev, entry_index,
-		(struct dsaf_tbl_tcam_data *)(&tmp_mac_key), &mac_data);
+	/* read entry */
+	hns_dsaf_tcam_mc_get(dsaf_dev, entry_index, &tcam_data, &mac_data);
 
 	/*del the port*/
 	if (mac_entry->port_num < DSAF_SERVICE_NW_NUM) {
@@ -1857,10 +1916,13 @@ int hns_dsaf_del_mac_mc_port(struct dsaf_device *dsaf_dev,
 		/* del soft entry */
 		soft_mac_entry += entry_index;
 		soft_mac_entry->index = DSAF_INVALID_ENTRY_IDX;
-	} else { /* not zer, just del port, updata*/
-		hns_dsaf_tcam_mc_cfg(
-			dsaf_dev, entry_index,
-			(struct dsaf_tbl_tcam_data *)(&mac_key), &mac_data);
+	} else { /* not zero, just del port, update */
+		tcam_data.tbl_tcam_data_high = mac_key.high.val;
+		tcam_data.tbl_tcam_data_low = mac_key.low.val;
+
+		hns_dsaf_tcam_mc_cfg(dsaf_dev, entry_index,
+				     &tcam_data,
+				     pmask_key, &mac_data);
 	}
 
 	return 0;
@@ -1976,7 +2038,7 @@ int hns_dsaf_get_mac_entry_by_index(
 
 	struct dsaf_tbl_tcam_mcast_cfg mac_data;
 	struct dsaf_tbl_tcam_ucast_cfg mac_uc_data;
-	char mac_addr[MAC_NUM_OCTETS_PER_ADDR] = {0};
+	char mac_addr[ETH_ALEN] = {0};
 
 	if (entry_index >= DSAF_TCAM_SUM) {
 		/* find none, del error */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
index c494fc5..f832a32 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
@@ -35,8 +35,6 @@
 
 #define DSAF_CFG_READ_CNT   30
 
-#define MAC_NUM_OCTETS_PER_ADDR 6
-
 #define DSAF_DUMP_REGS_NUM 504
 #define DSAF_STATIC_NUM 28
 #define DSAF_V2_STATIC_NUM	44
@@ -165,7 +163,7 @@ enum dsaf_mode {
 /*mac entry, mc or uc entry*/
 struct dsaf_drv_mac_single_dest_entry {
 	/* mac addr, match the entry*/
-	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u8 addr[ETH_ALEN];
 	u16 in_vlan_id; /* value of VlanId */
 
 	/* the vld input port num, dsaf-mode fix 0, */
@@ -179,7 +177,7 @@ struct dsaf_drv_mac_single_dest_entry {
 /*only mc entry*/
 struct dsaf_drv_mac_multi_dest_entry {
 	/* mac addr, match the entry*/
-	u8 addr[MAC_NUM_OCTETS_PER_ADDR];
+	u8 addr[ETH_ALEN];
 	u16 in_vlan_id;
 	/* this mac addr output port,*/
 	/*	bit0-bit5 means Port0-Port5(1bit is vld)**/
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index 878950a..6826b28 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -297,6 +297,8 @@
 #define DSAF_TBL_LKUP_NUM_I_0_REG		0x50C0
 #define DSAF_TBL_LKUP_NUM_O_0_REG		0x50E0
 #define DSAF_TBL_UCAST_BCAST_MIS_INFO_0_0_REG	0x510C
+#define DSAF_TBL_TCAM_MATCH_CFG_H_REG		0x5130
+#define DSAF_TBL_TCAM_MATCH_CFG_L_REG		0x5134
 
 #define DSAF_INODE_FIFO_WL_0_REG		0x6000
 #define DSAF_ONODE_FIFO_WL_0_REG		0x6020
-- 
1.7.9.5
