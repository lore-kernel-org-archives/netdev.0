From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 10/11] IB/hns: Implement the add_gid/del_gid and optimize the GIDs management
Date: Wed, 23 Nov 2016 19:41:08 +0000
Message-ID: <20161123194109.420760-11-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shaobo Xu <xushaobo2@huawei.com>

IB core has implemented the calculation of GIDs and the management
of GID tables, and it is now responsible to supply query function
for GIDs. So the calculation of GIDs and the management of GID
tables in the RoCE driver is redundant.

The patch is to implement the add_gid/del_gid to set the GIDs in
the RoCE driver, remove the redundant calculation and management of
GIDs in the notifier call of the net device and the inet, and
update the query_gid.

Signed-off-by: Shaobo Xu <xushaobo2@huawei.com>
Reviewed-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_device.h |    2 -
 drivers/infiniband/hw/hns/hns_roce_main.c   |  270 +++++----------------------
 2 files changed, 48 insertions(+), 224 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 593a42a..9ef1cc3 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -429,8 +429,6 @@ struct hns_roce_ib_iboe {
 	struct net_device      *netdevs[HNS_ROCE_MAX_PORTS];
 	struct notifier_block	nb;
 	struct notifier_block	nb_inet;
-	/* 16 GID is shared by 6 port in v1 engine. */
-	union ib_gid		gid_table[HNS_ROCE_MAX_GID_NUM];
 	u8			phy_port[HNS_ROCE_MAX_PORTS];
 };
 
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 6770171..795ef97 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -35,52 +35,13 @@
 #include <rdma/ib_addr.h>
 #include <rdma/ib_smi.h>
 #include <rdma/ib_user_verbs.h>
+#include <rdma/ib_cache.h>
 #include "hns_roce_common.h"
 #include "hns_roce_device.h"
 #include "hns_roce_user.h"
 #include "hns_roce_hem.h"
 
 /**
- * hns_roce_addrconf_ifid_eui48 - Get default gid.
- * @eui: eui.
- * @vlan_id:  gid
- * @dev:  net device
- * Description:
- *    MAC convert to GID
- *        gid[0..7] = fe80 0000 0000 0000
- *        gid[8] = mac[0] ^ 2
- *        gid[9] = mac[1]
- *        gid[10] = mac[2]
- *        gid[11] = ff        (VLAN ID high byte (4 MS bits))
- *        gid[12] = fe        (VLAN ID low byte)
- *        gid[13] = mac[3]
- *        gid[14] = mac[4]
- *        gid[15] = mac[5]
- */
-static void hns_roce_addrconf_ifid_eui48(u8 *eui, u16 vlan_id,
-					 struct net_device *dev)
-{
-	memcpy(eui, dev->dev_addr, 3);
-	memcpy(eui + 5, dev->dev_addr + 3, 3);
-	if (vlan_id < 0x1000) {
-		eui[3] = vlan_id >> 8;
-		eui[4] = vlan_id & 0xff;
-	} else {
-		eui[3] = 0xff;
-		eui[4] = 0xfe;
-	}
-	eui[0] ^= 2;
-}
-
-static void hns_roce_make_default_gid(struct net_device *dev, union ib_gid *gid)
-{
-	memset(gid, 0, sizeof(*gid));
-	gid->raw[0] = 0xFE;
-	gid->raw[1] = 0x80;
-	hns_roce_addrconf_ifid_eui48(&gid->raw[8], 0xffff, dev);
-}
-
-/**
  * hns_get_gid_index - Get gid index.
  * @hr_dev: pointer to structure hns_roce_dev.
  * @port:  port, value range: 0 ~ MAX
@@ -96,30 +57,6 @@ int hns_get_gid_index(struct hns_roce_dev *hr_dev, u8 port, int gid_index)
 	return gid_index * hr_dev->caps.num_ports + port;
 }
 
-static int hns_roce_set_gid(struct hns_roce_dev *hr_dev, u8 port, int gid_index,
-		     union ib_gid *gid)
-{
-	struct device *dev = &hr_dev->pdev->dev;
-	u8 gid_idx = 0;
-
-	if (gid_index >= hr_dev->caps.gid_table_len[port]) {
-		dev_err(dev, "gid_index %d illegal, port %d gid range: 0~%d\n",
-			gid_index, port, hr_dev->caps.gid_table_len[port] - 1);
-		return -EINVAL;
-	}
-
-	gid_idx = hns_get_gid_index(hr_dev, port, gid_index);
-
-	if (!memcmp(gid, &hr_dev->iboe.gid_table[gid_idx], sizeof(*gid)))
-		return -EINVAL;
-
-	memcpy(&hr_dev->iboe.gid_table[gid_idx], gid, sizeof(*gid));
-
-	hr_dev->hw->set_gid(hr_dev, port, gid_index, gid);
-
-	return 0;
-}
-
 static void hns_roce_set_mac(struct hns_roce_dev *hr_dev, u8 port, u8 *addr)
 {
 	u8 phy_port;
@@ -147,15 +84,44 @@ static void hns_roce_set_mtu(struct hns_roce_dev *hr_dev, u8 port, int mtu)
 	hr_dev->hw->set_mtu(hr_dev, phy_port, tmp);
 }
 
-static void hns_roce_update_gids(struct hns_roce_dev *hr_dev, int port)
+static int hns_roce_add_gid(struct ib_device *device, u8 port_num,
+			    unsigned int index, const union ib_gid *gid,
+			    const struct ib_gid_attr *attr, void **context)
+{
+	struct hns_roce_dev *hr_dev = to_hr_dev(device);
+	u8 port = port_num - 1;
+	unsigned long flags;
+
+	if (port >= hr_dev->caps.num_ports)
+		return -EINVAL;
+
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	hr_dev->hw->set_gid(hr_dev, port, index, (union ib_gid *)gid);
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+
+	return 0;
+}
+
+static int hns_roce_del_gid(struct ib_device *device, u8 port_num,
+			    unsigned int index, void **context)
 {
-	struct ib_event event;
+	struct hns_roce_dev *hr_dev = to_hr_dev(device);
+	union ib_gid zgid = { {0} };
+	u8 port = port_num - 1;
+	unsigned long flags;
+
+	if (port >= hr_dev->caps.num_ports)
+		return -EINVAL;
 
-	/* Refresh gid in ib_cache */
-	event.device = &hr_dev->ib_dev;
-	event.element.port_num = port + 1;
-	event.event = IB_EVENT_GID_CHANGE;
-	ib_dispatch_event(&event);
+	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
+
+	hr_dev->hw->set_gid(hr_dev, port, index, &zgid);
+
+	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
+
+	return 0;
 }
 
 static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
@@ -164,8 +130,6 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 	struct device *dev = &hr_dev->pdev->dev;
 	struct net_device *netdev;
 	unsigned long flags;
-	union ib_gid gid;
-	int ret = 0;
 
 	netdev = hr_dev->iboe.netdevs[port];
 	if (!netdev) {
@@ -181,10 +145,6 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 	case NETDEV_REGISTER:
 	case NETDEV_CHANGEADDR:
 		hns_roce_set_mac(hr_dev, port, netdev->dev_addr);
-		hns_roce_make_default_gid(netdev, &gid);
-		ret = hns_roce_set_gid(hr_dev, port, 0, &gid);
-		if (!ret)
-			hns_roce_update_gids(hr_dev, port);
 		break;
 	case NETDEV_DOWN:
 		/*
@@ -197,7 +157,7 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 	}
 
 	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
-	return ret;
+	return 0;
 }
 
 static int hns_roce_netdev_event(struct notifier_block *self,
@@ -224,118 +184,17 @@ static int hns_roce_netdev_event(struct notifier_block *self,
 	return NOTIFY_DONE;
 }
 
-static void hns_roce_addr_event(int event, struct net_device *event_netdev,
-				struct hns_roce_dev *hr_dev, union ib_gid *gid)
-{
-	struct hns_roce_ib_iboe *iboe = NULL;
-	int gid_table_len = 0;
-	unsigned long flags;
-	union ib_gid zgid;
-	u8 gid_idx = 0;
-	u8 port = 0;
-	int i = 0;
-	int free;
-	struct net_device *real_dev = rdma_vlan_dev_real_dev(event_netdev) ?
-				      rdma_vlan_dev_real_dev(event_netdev) :
-				      event_netdev;
-
-	if (event != NETDEV_UP && event != NETDEV_DOWN)
-		return;
-
-	iboe = &hr_dev->iboe;
-	while (port < hr_dev->caps.num_ports) {
-		if (real_dev == iboe->netdevs[port])
-			break;
-		port++;
-	}
-
-	if (port >= hr_dev->caps.num_ports) {
-		dev_dbg(&hr_dev->pdev->dev, "can't find netdev\n");
-		return;
-	}
-
-	memset(zgid.raw, 0, sizeof(zgid.raw));
-	free = -1;
-	gid_table_len = hr_dev->caps.gid_table_len[port];
-
-	spin_lock_irqsave(&hr_dev->iboe.lock, flags);
-
-	for (i = 0; i < gid_table_len; i++) {
-		gid_idx = hns_get_gid_index(hr_dev, port, i);
-		if (!memcmp(gid->raw, iboe->gid_table[gid_idx].raw,
-			    sizeof(gid->raw)))
-			break;
-		if (free < 0 && !memcmp(zgid.raw,
-			iboe->gid_table[gid_idx].raw, sizeof(zgid.raw)))
-			free = i;
-	}
-
-	if (i >= gid_table_len) {
-		if (free < 0) {
-			spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
-			dev_dbg(&hr_dev->pdev->dev,
-				"gid_index overflow, port(%d)\n", port);
-			return;
-		}
-		if (!hns_roce_set_gid(hr_dev, port, free, gid))
-			hns_roce_update_gids(hr_dev, port);
-	} else if (event == NETDEV_DOWN) {
-		if (!hns_roce_set_gid(hr_dev, port, i, &zgid))
-			hns_roce_update_gids(hr_dev, port);
-	}
-
-	spin_unlock_irqrestore(&hr_dev->iboe.lock, flags);
-}
-
-static int hns_roce_inet_event(struct notifier_block *self, unsigned long event,
-			       void *ptr)
-{
-	struct in_ifaddr *ifa = ptr;
-	struct hns_roce_dev *hr_dev;
-	struct net_device *dev = ifa->ifa_dev->dev;
-	union ib_gid gid;
-
-	ipv6_addr_set_v4mapped(ifa->ifa_address, (struct in6_addr *)&gid);
-
-	hr_dev = container_of(self, struct hns_roce_dev, iboe.nb_inet);
-
-	hns_roce_addr_event(event, dev, hr_dev, &gid);
-
-	return NOTIFY_DONE;
-}
-
-static int hns_roce_setup_mtu_gids(struct hns_roce_dev *hr_dev)
+static int hns_roce_setup_mtu_mac(struct hns_roce_dev *hr_dev)
 {
-	struct in_ifaddr *ifa_list = NULL;
-	union ib_gid gid = {{0} };
-	u32 ipaddr = 0;
-	int index = 0;
-	int ret = 0;
-	u8 i = 0;
+	u8 i;
 
 	for (i = 0; i < hr_dev->caps.num_ports; i++) {
 		hns_roce_set_mtu(hr_dev, i,
 				 ib_mtu_enum_to_int(hr_dev->caps.max_mtu));
 		hns_roce_set_mac(hr_dev, i, hr_dev->iboe.netdevs[i]->dev_addr);
-
-		if (hr_dev->iboe.netdevs[i]->ip_ptr) {
-			ifa_list = hr_dev->iboe.netdevs[i]->ip_ptr->ifa_list;
-			index = 1;
-			while (ifa_list) {
-				ipaddr = ifa_list->ifa_address;
-				ipv6_addr_set_v4mapped(ipaddr,
-						       (struct in6_addr *)&gid);
-				ret = hns_roce_set_gid(hr_dev, i, index, &gid);
-				if (ret)
-					break;
-				index++;
-				ifa_list = ifa_list->ifa_next;
-			}
-			hns_roce_update_gids(hr_dev, i);
-		}
 	}
 
-	return ret;
+	return 0;
 }
 
 static int hns_roce_query_device(struct ib_device *ib_dev,
@@ -444,31 +303,6 @@ static enum rdma_link_layer hns_roce_get_link_layer(struct ib_device *device,
 static int hns_roce_query_gid(struct ib_device *ib_dev, u8 port_num, int index,
 			      union ib_gid *gid)
 {
-	struct hns_roce_dev *hr_dev = to_hr_dev(ib_dev);
-	struct device *dev = &hr_dev->pdev->dev;
-	u8 gid_idx = 0;
-	u8 port;
-
-	if (port_num < 1 || port_num > hr_dev->caps.num_ports ||
-	    index >= hr_dev->caps.gid_table_len[port_num - 1]) {
-		dev_err(dev,
-			"port_num %d index %d illegal! correct range: port_num 1~%d index 0~%d!\n",
-			port_num, index, hr_dev->caps.num_ports,
-			hr_dev->caps.gid_table_len[port_num - 1] - 1);
-		return -EINVAL;
-	}
-
-	port = port_num - 1;
-	gid_idx = hns_get_gid_index(hr_dev, port, index);
-	if (gid_idx >= HNS_ROCE_MAX_GID_NUM) {
-		dev_err(dev, "port_num %d index %d illegal! total gid num %d!\n",
-			port_num, index, HNS_ROCE_MAX_GID_NUM);
-		return -EINVAL;
-	}
-
-	memcpy(gid->raw, hr_dev->iboe.gid_table[gid_idx].raw,
-	       HNS_ROCE_GID_SIZE);
-
 	return 0;
 }
 
@@ -646,6 +480,8 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 	ib_dev->get_link_layer		= hns_roce_get_link_layer;
 	ib_dev->get_netdev		= hns_roce_get_netdev;
 	ib_dev->query_gid		= hns_roce_query_gid;
+	ib_dev->add_gid			= hns_roce_add_gid;
+	ib_dev->del_gid			= hns_roce_del_gid;
 	ib_dev->query_pkey		= hns_roce_query_pkey;
 	ib_dev->alloc_ucontext		= hns_roce_alloc_ucontext;
 	ib_dev->dealloc_ucontext	= hns_roce_dealloc_ucontext;
@@ -688,32 +524,22 @@ static int hns_roce_register_device(struct hns_roce_dev *hr_dev)
 		return ret;
 	}
 
-	ret = hns_roce_setup_mtu_gids(hr_dev);
+	ret = hns_roce_setup_mtu_mac(hr_dev);
 	if (ret) {
-		dev_err(dev, "roce_setup_mtu_gids failed!\n");
-		goto error_failed_setup_mtu_gids;
+		dev_err(dev, "setup_mtu_mac failed!\n");
+		goto error_failed_setup_mtu_mac;
 	}
 
 	iboe->nb.notifier_call = hns_roce_netdev_event;
 	ret = register_netdevice_notifier(&iboe->nb);
 	if (ret) {
 		dev_err(dev, "register_netdevice_notifier failed!\n");
-		goto error_failed_setup_mtu_gids;
-	}
-
-	iboe->nb_inet.notifier_call = hns_roce_inet_event;
-	ret = register_inetaddr_notifier(&iboe->nb_inet);
-	if (ret) {
-		dev_err(dev, "register inet addr notifier failed!\n");
-		goto error_failed_register_inetaddr_notifier;
+		goto error_failed_setup_mtu_mac;
 	}
 
 	return 0;
 
-error_failed_register_inetaddr_notifier:
-	unregister_netdevice_notifier(&iboe->nb);
-
-error_failed_setup_mtu_gids:
+error_failed_setup_mtu_mac:
 	ib_unregister_device(ib_dev);
 
 	return ret;
-- 
1.7.9.5
