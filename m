From: Lijun Ou <oulijun@huawei.com>
Subject: [PATCH v11 13/22] IB/hns: Add interface of the protocol stack registration
Date: Sat, 2 Jul 2016 17:39:15 +0800
Message-ID: <1467452364-66522-14-git-send-email-oulijun@huawei.com>
References: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
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
In-Reply-To: <1467452364-66522-1-git-send-email-oulijun@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch mainly added the function module which netif notify
registered the protocol stack. It includes interface functions
as follows:
    1. The executive called interface of RoCE when the netlink
       event that registered protocol stack was generated
    2. The executive called interface of RoCE when ip address
       that registered protocol stack was changed.
In addition that, it will free the relative resource when RoCE
is removed.

Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
Signed-off-by: Lijun Ou <oulijun@huawei.com>
---
PATCH v11:
- No change over the PATCH v10

PATCH v10:
This fixes the same questions with the comments given by Leon
Romanovsky over the [PATCH v9 11/22]:
  Link: https://lkml.org/lkml/2016/6/9/53

PATCH v9/v8/v7/v6:
- No change over the PATCH v5

 PATCH v5:
- The initial patch which was redesigned based on the second patch
  in PATCH v4
---
---
 drivers/infiniband/hw/hns/hns_roce_device.h |   3 +
 drivers/infiniband/hw/hns/hns_roce_main.c   | 209 ++++++++++++++++++++++++++++
 2 files changed, 212 insertions(+)

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 634b586..0c835ad 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -248,7 +248,10 @@ struct hns_roce_qp {
 };
 
 struct hns_roce_ib_iboe {
+	spinlock_t		lock;
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
+	struct notifier_block	nb;
+	struct notifier_block	nb_inet;
 	/* 16 GID is shared by 6 port in v1 engine. */
 	union ib_gid		gid_table[HNS_ROCE_MAX_GID_NUM];
 	u8			phy_port[HNS_ROCE_MAX_PORTS];
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index a9dc408..4348669 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -40,6 +40,46 @@
 #include "hns_roce_hem.h"
 
 /**
+ * hns_roce_addrconf_ifid_eui48 - Get default gid.
+ * @eui: eui.
+ * @vlan_id:  gid
+ * @dev:  net device
+ * Description:
+ *    MAC convert to GID
+ *        gid[0..7] = fe80 0000 0000 0000
+ *        gid[8] = mac[0] ^ 2
+ *        gid[9] = mac[1]
+ *        gid[10] = mac[2]
+ *        gid[11] = ff        (VLAN ID high byte (4 MS bits))
+ *        gid[12] = fe        (VLAN ID low byte)
+ *        gid[13] = mac[3]
+ *        gid[14] = mac[4]
+ *        gid[15] = mac[5]
+ */
+static void hns_roce_addrconf_ifid_eui48(u8 *eui, u16 vlan_id,
+					 struct net_device *dev)
+{
+	memcpy(eui, dev->dev_addr, 3);
+	memcpy(eui + 5, dev->dev_addr + 3, 3);
+	if (vlan_id < 0x1000) {
+		eui[3] = vlan_id >> 8;
+		eui[4] = vlan_id & 0xff;
+	} else {
+		eui[3] = 0xff;
+		eui[4] = 0xfe;
+	}
+	eui[0] ^= 2;
+}
+
+static void hns_roce_make_default_gid(struct net_device *dev, union ib_gid *gid)
+{
+	memset(gid, 0, sizeof(*gid));
+	gid->raw[0] = 0xFE;
+	gid->raw[1] = 0x80;
+	hns_roce_addrconf_ifid_eui48(&gid->raw[8], 0xffff, dev);
+}
+
+/**
  * hns_get_gid_index - Get gid index.
  * @hr_dev: pointer to structure hns_roce_dev.
  * @port:  port, value range: 0 ~ MAX
@@ -117,6 +157,152 @@ static void hns_roce_update_gids(struct hns_roce_dev *hr_dev, int port)
 	ib_dispatch_event(&event);
 }
 
+static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
+			   unsigned long event)
+{
+	struct device *dev = &hr_dev->pdev->dev;
+	struct net_device *netdev;
+	unsigned long flags;
+	union ib_gid gid;
+	int ret = 0;
+
+	netdev = hr_dev->iboe.netdevs[port];
+	if (!netdev) {
+		dev_err(dev, "port(%d) can't find netdev\n", port);
+		return -ENODEV;
+	}
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_CHANGE:
+	case NETDEV_REGISTER:
+	case NETDEV_CHANGEADDR:
+		hns_roce_set_mac(hr_dev, port, netdev->dev_addr);
+		hns_roce_make_default_gid(netdev, &gid);
+		ret = hns_roce_set_gid(hr_dev, port, 0, &gid);
+		if (!ret)
+			hns_roce_update_gids(hr_dev, port);
+		break;
+	case NETDEV_DOWN:
+		/*
+		* In v1 engine, only support all ports closed together.
+		*/
+		break;
+	default:
+		dev_dbg(dev, "NETDEV event = 0x%x!\n", (u32)(event));
+		break;
+	}
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+	return ret;
+}
+
+static int hns_roce_netdev_event(struct notifier_block *self,
+				 unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct hns_roce_ib_iboe *iboe = NULL;
+	struct hns_roce_dev *hr_dev = NULL;
+	u8 port = 0;
+	int ret = 0;
+
+	hr_dev = container_of(self, struct hns_roce_dev, iboe.nb);
+	iboe = &hr_dev->iboe;
+
+	for (port = 0; port < hr_dev->caps.num_ports; port++) {
+		if (dev == iboe->netdevs[port]) {
+			ret = handle_en_event(hr_dev, port, event);
+			if (ret)
+				return NOTIFY_DONE;
+			break;
+		}
+	}
+
+	return NOTIFY_DONE;
+}
+
+static void hns_roce_addr_event(int event, struct net_device *event_netdev,
+				struct hns_roce_dev *hr_dev, union ib_gid *gid)
+{
+	struct hns_roce_ib_iboe *iboe = NULL;
+	int gid_table_len = 0;
+	unsigned long flags;
+	union ib_gid zgid;
+	u8 gid_idx = 0;
+	u8 port = 0;
+	int i = 0;
+	int free;
+	struct net_device *real_dev = rdma_vlan_dev_real_dev(event_netdev) ?
+				      rdma_vlan_dev_real_dev(event_netdev) :
+				      event_netdev;
+
+	if (event != NETDEV_UP && event != NETDEV_DOWN)
+		return;
+
+	iboe = &hr_dev->iboe;
+	while (port < hr_dev->caps.num_ports) {
+		if (real_dev == iboe->netdevs[port])
+			break;
+		port++;
+	}
+
+	if (port >= hr_dev->caps.num_ports) {
+		dev_dbg(&hr_dev->pdev->dev, "can't find netdev\n");
+		return;
+	}
+
+	memset(zgid.raw, 0, sizeof(zgid.raw));
+	free = -1;
+	gid_table_len = hr_dev->caps.gid_table_len[port];
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	for (i = 0; i < gid_table_len; i++) {
+		gid_idx = hns_get_gid_index(hr_dev, port, i);
+		if (!memcmp(gid->raw, iboe->gid_table[gid_idx].raw,
+			    sizeof(gid->raw)))
+			break;
+		if (free < 0 && !memcmp(zgid.raw,
+			iboe->gid_table[gid_idx].raw, sizeof(zgid.raw)))
+			free = i;
+	}
+
+	if (i >= gid_table_len) {
+		if (free < 0) {
+			spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+			dev_dbg(&hr_dev->pdev->dev,
+				"gid_index overflow, port(%d)\n", port);
+			return;
+		}
+		if (!hns_roce_set_gid(hr_dev, port, free, gid))
+			hns_roce_update_gids(hr_dev, port);
+	} else if (event == NETDEV_DOWN) {
+		if (!hns_roce_set_gid(hr_dev, port, i, &zgid))
+			hns_roce_update_gids(hr_dev, port);
+	}
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+}
+
+static int hns_roce_inet_event(struct notifier_block *self, unsigned long event,
+			       void *ptr)
+{
+	struct in_ifaddr *ifa = ptr;
+	struct hns_roce_dev *hr_dev;
+	struct net_device *dev = ifa->ifa_dev->dev;
+	union ib_gid gid;
+
+	ipv6_addr_set_v4mapped(ifa->ifa_address, (struct in6_addr *)&gid);
+
+	hr_dev = container_of(self, struct hns_roce_dev, iboe.nb_inet);
+
+	hns_roce_addr_event(event, dev, hr_dev, &gid);
+
+	return NOTIFY_DONE;
+}
+
 static int hns_roce_setup_mtu_gids(struct hns_roce_dev *hr_dev)
 {
 	struct in_ifaddr *ifa_list = NULL;
@@ -153,6 +339,10 @@ static int hns_roce_setup_mtu_gids(struct hns_roce_dev *hr_dev)
 
 static void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)
 {
+	struct hns_roce_ib_iboe *iboe = &hr_dev->iboe;
+
+	unregister_inetaddr_notifier(&iboe->nb_inet);
+	unregister_netdevice_notifier(&iboe->nb);
 	ib_unregister_device(&hr_dev->ib_dev);
 }
 
@@ -189,8 +379,27 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		goto error_failed_setup_mtu_gids;
 	}
 
+	spin_lock_init(&iboe->lock);
+
+	iboe->nb.notifier_call = hns_roce_netdev_event;
+	ret = register_netdevice_notifier(&iboe->nb);
+	if (ret) {
+		dev_err(dev, "register_netdevice_notifier failed!\n");
+		goto error_failed_setup_mtu_gids;
+	}
+
+	iboe->nb_inet.notifier_call = hns_roce_inet_event;
+	ret = register_inetaddr_notifier(&iboe->nb_inet);
+	if (ret) {
+		dev_err(dev, "register inet addr notifier failed!\n");
+		goto error_failed_register_inetaddr_notifier;
+	}
+
 	return 0;
 
+error_failed_register_inetaddr_notifier:
+	unregister_netdevice_notifier(&iboe->nb);
+
 error_failed_setup_mtu_gids:
 	ib_unregister_device(ib_dev);
 
-- 
1.9.1
