From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v8 12/22] IB/hns: Set mtu and gid support
Date: Wed, 25 May 2016 23:05:15 +0800
Message-ID: <1464188725-42805-13-git-send-email-oulijun@huawei.com>
References: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<oulijun@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464188725-42805-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly set mtu and gid resource. These resource
will be used to set up network transmission in nodes.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_common.h |  16 ++++
 drivers/infiniband/hw/hns/hns_roce_device.h |  12 +++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  64 +++++++++++++++
 drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   1 +
 drivers/infiniband/hw/hns/hns_roce_main.c   | 123 ++++++++++++++++++++++++++++
 5 files changed, 216 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_common.h b/drivers/infiniband/hw/hns/hns_roce_common.h
index 73c6220..60d361c 100644
--- a/drivers/infiniband/hw/hns/hns_roce_common.h
+++ b/drivers/infiniband/hw/hns/hns_roce_common.h
@@ -156,6 +156,14 @@
 
 #define ROCEE_BT_CMD_H_ROCEE_BT_CMD_HW_SYNS_S 31
 
+#define ROCEE_SMAC_H_ROCEE_SMAC_H_S 0
+#define ROCEE_SMAC_H_ROCEE_SMAC_H_M   \
+	(((1UL << 16) - 1) << ROCEE_SMAC_H_ROCEE_SMAC_H_S)
+
+#define ROCEE_SMAC_H_ROCEE_PORT_MTU_S 16
+#define ROCEE_SMAC_H_ROCEE_PORT_MTU_M   \
+	(((1UL << 4) - 1) << ROCEE_SMAC_H_ROCEE_PORT_MTU_S)
+
 #define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S 0
 #define ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_M   \
 	(((1UL << 2) - 1) << ROCEE_CAEP_AEQC_AEQE_SHIFT_CAEP_AEQC_STATE_S)
@@ -196,8 +204,16 @@
 #define ROCEE_SYS_IMAGE_GUID_L_REG		0xC
 #define ROCEE_SYS_IMAGE_GUID_H_REG		0x10
 
+#define ROCEE_PORT_GID_L_0_REG			0x50
+#define ROCEE_PORT_GID_ML_0_REG			0x54
+#define ROCEE_PORT_GID_MH_0_REG			0x58
+#define ROCEE_PORT_GID_H_0_REG			0x5C
+
 #define ROCEE_BT_CMD_H_REG			0x204
 
+#define ROCEE_SMAC_L_0_REG			0x240
+#define ROCEE_SMAC_H_0_REG			0x244
+
 #define ROCEE_CAEP_AEQE_CONS_IDX_REG		0x3AC
 #define ROCEE_CAEP_CEQC_CONS_IDX_0_REG		0x3BC
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index fa906c1..5b714bf 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -44,6 +44,8 @@
 
 #define DRV_NAME "hns_roce"
 
+#define MAC_ADDR_OCTET_NUM			6
+
 #define HNS_ROCE_BA_SIZE			(32 * 4096)
 
 #define HNS_ROCE_MAX_IRQ_NUM			34
@@ -54,6 +56,7 @@
 #define HNS_ROCE_AEQE_OF_VEC_NUM		1
 
 #define HNS_ROCE_MAX_PORTS			6
+#define HNS_ROCE_MAX_GID_NUM			16
 
 /* Address shift 12bit with the special hardware address operation of RoCEE */
 #define ADDR_SHIFT_12				12
@@ -266,6 +269,8 @@ struct hns_roce_qp {
 
 struct hns_roce_ib_iboe {
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
+	/* 16 GID is shared by 6 port in v1 engine. */
+	union ib_gid		gid_table[HNS_ROCE_MAX_GID_NUM];
 	u8			phy_port[HNS_ROCE_MAX_PORTS];
 };
 
@@ -340,6 +345,11 @@ struct hns_roce_hw {
 	void (*hw_profile)(struct hns_roce_dev *hr_dev);
 	int (*hw_init)(struct hns_roce_dev *hr_dev);
 	void (*hw_uninit)(struct hns_roce_dev *hr_dev);
+	void (*set_gid)(struct hns_roce_dev *hr_dev, u8 port, int gid_index,
+			union ib_gid *gid);
+	void (*set_mac)(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr);
+	void (*set_mtu)(struct hns_roce_dev *hr_dev, u8 phy_port,
+			enum ib_mtu mtu);
 	void	*priv;
 };
 
@@ -357,6 +367,7 @@ struct hns_roce_dev {
 	struct hns_roce_caps	caps;
 	struct radix_tree_root  qp_table_tree;
 
+	unsigned char	dev_addr[HNS_ROCE_MAX_PORTS][MAC_ADDR_OCTET_NUM];
 	u64                     fw_ver;
 	u64			sys_image_guid;
 	u32                     vendor_id;
@@ -426,6 +437,7 @@ void hns_roce_bitmap_free_range(struct hns_roce_bitmap *bitmap,
 void hns_roce_cq_completion(struct hns_roce_dev *hr_dev, u32 cqn);
 void hns_roce_cq_event(struct hns_roce_dev *hr_dev, u32 cqn, int event_type);
 void hns_roce_qp_event(struct hns_roce_dev *hr_dev, u32 qpn, int event_type);
+int hns_get_gid_index(struct hns_roce_dev *hr_dev, u8 port, int gid_index);
 
 extern struct hns_roce_hw hns_roce_hw_v1;
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 9cd6c1a..29c6903 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -619,9 +619,73 @@ void hns_roce_v1_uninit(struct hns_roce_dev *hr_dev)
 	hns_roce_db_free(hr_dev);
 }
 
+void hns_roce_v1_set_gid(struct hns_roce_dev *hr_dev, u8 port, int gid_index,
+			 union ib_gid *gid)
+{
+	u32 *p = NULL;
+	u8 gid_idx = 0;
+
+	gid_idx = hns_get_gid_index(hr_dev, port, gid_index);
+
+	p = (u32 *)&gid->raw[0];
+	roce_raw_write(*p, hr_dev->reg_base + ROCEE_PORT_GID_L_0_REG +
+		       (HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[4];
+	roce_raw_write(*p, hr_dev->reg_base + ROCEE_PORT_GID_ML_0_REG +
+		       (HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[8];
+	roce_raw_write(*p, hr_dev->reg_base + ROCEE_PORT_GID_MH_0_REG +
+		       (HNS_ROCE_V1_GID_NUM * gid_idx));
+
+	p = (u32 *)&gid->raw[0xc];
+	roce_raw_write(*p, hr_dev->reg_base + ROCEE_PORT_GID_H_0_REG +
+		       (HNS_ROCE_V1_GID_NUM * gid_idx));
+}
+
+void hns_roce_v1_set_mac(struct hns_roce_dev *hr_dev, u8 phy_port, u8 *addr)
+{
+	u32 reg_smac_l;
+	u16 reg_smac_h;
+	u16 *p_h;
+	u32 *p;
+	u32 val;
+
+	p = (u32 *)(&addr[0]);
+	reg_smac_l = *p;
+	roce_raw_write(reg_smac_l, hr_dev->reg_base + ROCEE_SMAC_L_0_REG +
+		       PHY_PORT_OFFSET * phy_port);
+
+	val = roce_readl(hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+			 phy_port * PHY_PORT_OFFSET);
+	p_h = (u16 *)(&addr[4]);
+	reg_smac_h  = *p_h;
+	roce_set_field(val, ROCEE_SMAC_H_ROCEE_SMAC_H_M,
+		       ROCEE_SMAC_H_ROCEE_SMAC_H_S, reg_smac_h);
+	roce_writel(val, hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+		    phy_port * PHY_PORT_OFFSET);
+}
+
+void hns_roce_v1_set_mtu(struct hns_roce_dev  *hr_dev, u8 phy_port,
+			 enum ib_mtu mtu)
+{
+	u32 val;
+
+	val = roce_readl(hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+			 phy_port * PHY_PORT_OFFSET);
+	roce_set_field(val, ROCEE_SMAC_H_ROCEE_PORT_MTU_M,
+		       ROCEE_SMAC_H_ROCEE_PORT_MTU_S, mtu);
+	roce_writel(val, hr_dev->reg_base + ROCEE_SMAC_H_0_REG +
+		    phy_port * PHY_PORT_OFFSET);
+}
+
 struct hns_roce_hw hns_roce_hw_v1 = {
 	.reset = hns_roce_v1_reset,
 	.hw_profile = hns_roce_v1_profile,
 	.hw_init = hns_roce_v1_init,
 	.hw_uninit = hns_roce_v1_uninit,
+	.set_gid = hns_roce_v1_set_gid,
+	.set_mac = hns_roce_v1_set_mac,
+	.set_mtu = hns_roce_v1_set_mtu,
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
index f538734..afd65b4 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.h
@@ -107,6 +107,7 @@
 
 #define HNS_ROCE_ODB_EXTEND_MODE	1
 
+#define PHY_PORT_OFFSET			0x8
 #define ALL_PORT_VAL_OPEN		0x3f
 #define POL_TIME_INTERVAL_VAL		0x80
 #define SLEEP_TIME_INTERVAL		20
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 788fe69..5cfd9cf 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -62,6 +62,118 @@
 #include "hns_roce_device.h"
 #include "hns_roce_icm.h"
 
+/**
+ * hns_get_gid_index - Get gid index.
+ * @hr_dev: pointer to structure hns_roce_dev.
+ * @port:  port, value range: 0 ~ MAX
+ * @gid_index:  gid_index, value range: 0 ~ MAX
+ * Description:
+ *    N ports shared gids, allocation method as follow:
+ *		GID[0][0], GID[1][0],.....GID[N - 1][0],
+ *		GID[0][0], GID[1][0],.....GID[N - 1][0],
+ *		And so on
+ */
+int hns_get_gid_index(struct hns_roce_dev *hr_dev, u8 port, int gid_index)
+{
+	return gid_index * hr_dev->caps.num_ports + port;
+}
+
+int hns_roce_set_gid(struct hns_roce_dev *hr_dev, u8 port, int gid_index,
+		     union ib_gid *gid)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	u8 gid_idx = 0;
+
+	if (gid_index >= hr_dev->caps.gid_table_len[port]) {
+		dev_err(dev, "gid_index %d illegal, port %d gid range: 0~%d\n",
+			gid_index, port, hr_dev->caps.gid_table_len[port] - 1);
+		return -EINVAL;
+	}
+
+	gid_idx = hns_get_gid_index(hr_dev, port, gid_index);
+
+	if (!memcmp(gid, &hr_dev->iboe.gid_table[gid_idx], sizeof(*gid)))
+		return -EINVAL;
+
+	memcpy(&hr_dev->iboe.gid_table[gid_idx], gid, sizeof(*gid));
+
+	hr_dev->hw->set_gid(hr_dev, port, gid_index, gid);
+
+	return 0;
+}
+
+void hns_roce_set_mac(struct hns_roce_dev *hr_dev, u8 port, u8 *addr)
+{
+	u8 phy_port;
+	u32 i = 0;
+
+	if (!memcmp(hr_dev->dev_addr[port], addr, MAC_ADDR_OCTET_NUM))
+		return;
+
+	for (i = 0; i < MAC_ADDR_OCTET_NUM; i++)
+		hr_dev->dev_addr[port][i] = addr[i];
+
+	phy_port = hr_dev->iboe.phy_port[port];
+	hr_dev->hw->set_mac(hr_dev, phy_port, addr);
+}
+
+void hns_roce_set_mtu(struct hns_roce_dev *hr_dev, u8 port, int mtu)
+{
+	u8 phy_port = hr_dev->iboe.phy_port[port];
+	enum ib_mtu tmp;
+
+	tmp = iboe_get_mtu(mtu);
+	if (!tmp)
+		tmp = IB_MTU_256;
+
+	hr_dev->hw->set_mtu(hr_dev, phy_port, tmp);
+}
+
+void hns_roce_update_gids(struct hns_roce_dev *hr_dev, int port)
+{
+	struct ib_event event;
+
+	/* Refresh gid in ib_cache */
+	event.device = &hr_dev->ib_dev;
+	event.element.port_num = port + 1;
+	event.event = IB_EVENT_GID_CHANGE;
+	ib_dispatch_event(&event);
+}
+
+int hns_roce_setup_mtu_gids(struct hns_roce_dev  *hr_dev)
+{
+	struct in_ifaddr *ifa_list = NULL;
+	union ib_gid gid = {{0} };
+	u32 ipaddr = 0;
+	int index = 0;
+	int ret = 0;
+	u8 i = 0;
+
+	for (i = 0; i < hr_dev->caps.num_ports; i++) {
+		hns_roce_set_mtu(hr_dev, i,
+				 ib_mtu_enum_to_int(hr_dev->caps.max_mtu));
+		hns_roce_set_mac(hr_dev, i, hr_dev->iboe.netdevs[i]->dev_addr);
+
+		if (hr_dev->iboe.netdevs[i]->ip_ptr) {
+			ifa_list = hr_dev->iboe.netdevs[i]->ip_ptr->ifa_list;
+			index = 1;
+			while (ifa_list) {
+				ipaddr = ifa_list->ifa_address;
+				ipv6_addr_set_v4mapped(ipaddr,
+						       (struct in6_addr *)&gid);
+				ret = hns_roce_set_gid(hr_dev, i, index, &gid);
+				if (ret)
+					break;
+				index++;
+				ifa_list = ifa_list->ifa_next;
+			}
+			hns_roce_update_gids(hr_dev, i);
+		}
+	}
+
+	return ret;
+}
+
 void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
 {
 	ib_unregister_device(&hr_dev->ib_dev);
@@ -94,7 +206,18 @@ int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		return ret;
 	}
 
+	ret = hns_roce_setup_mtu_gids(hr_dev);
+	if (ret) {
+		dev_err(dev, "roce_setup_mtu_gids failed!\n");
+		goto _error_failed_setup_mtu_gids;
+	}
+
 	return 0;
+
+_error_failed_setup_mtu_gids:
+	ib_unregister_device(ib_dev);
+
+	return ret;
 }
 
 int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
-- 
1.9.1
