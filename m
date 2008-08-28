From: Karen Xie <kxie@chelsio.com>
Subject: [PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for iSCSI
Date: Wed, 27 Aug 2008 21:21:57 -0700
Message-ID: <200808280421.m7S4LvAB006456@localhost.localdomain>
Cc: jgarzik@pobox.com, davem@davemloft.net, michaelc@cs.wisc.edu,
	swise@opengridcomputing.com, rdreier@cisco.com, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, divy@chelsio.com,
	dm@chelsio.com, leedom@chelsio.com, kxie@chelsio.com
To: netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 1/4 2.6.28] cxgb3 - manage a private ip address for iSCSI

From: Karen Xie <kxie@chelsio.com>

Create a per port sysfs entry to pass an IP address to the NIC driver, and a control call for the iSCSI driver to grab it.
The IP address is required in both drivers to manage ARP requests and connection set up.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h        |    1 +
 drivers/net/cxgb3/cxgb3_ctl_defs.h |    7 +++++
 drivers/net/cxgb3/cxgb3_main.c     |   46 ++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/cxgb3_offload.c  |    6 +++++
 4 files changed, 60 insertions(+), 0 deletions(-)


diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index 2711404..adc2f13 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -64,6 +64,7 @@ struct port_info {
 	struct link_config link_config;
 	struct net_device_stats netstats;
 	int activity;
+	__be32 iscsi_ipv4addr;
 };
 
 enum {				/* adapter flags */
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/cxgb3/cxgb3_ctl_defs.h
index 6ad9240..2bf5027 100644
--- a/drivers/net/cxgb3/cxgb3_ctl_defs.h
+++ b/drivers/net/cxgb3/cxgb3_ctl_defs.h
@@ -57,6 +57,7 @@ enum {
 	RDMA_GET_MIB		= 19,
 
 	GET_RX_PAGE_INFO	= 50,
+	GET_ISCSI_IPV4ADDR	= 51,
 };
 
 /*
@@ -86,6 +87,12 @@ struct iff_mac {
 	u16 vlan_tag;
 };
 
+/* Structure used to request a port's iSCSI IPv4 address */
+struct iscsi_ipv4addr {
+	struct net_device *dev;		/* the net_device */
+	__be32 ipv4addr;		/* the return iSCSI IPv4 address */
+};
+
 struct pci_dev;
 
 /*
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 5447f3e..4f72c06 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -34,6 +34,7 @@
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
+#include <linux/inet.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
@@ -687,6 +688,47 @@ static struct attribute *offload_attrs[] = {
 
 static struct attribute_group offload_attr_group = {.attrs = offload_attrs };
 
+static ssize_t iscsi_ipv4addr_attr_show(struct device *d, char *buf)
+{
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+	__be32 a = pi->iscsi_ipv4addr;
+
+	return sprintf(buf, NIPQUAD_FMT "\n", NIPQUAD(a));
+}
+
+static ssize_t iscsi_ipv4addr_attr_store(struct device *d,
+				       const char *buf, size_t len)
+{
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+
+	pi->iscsi_ipv4addr = in_aton(buf);
+	return len;
+}
+
+#define ISCSI_IPADDR_ATTR(name) \
+static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
+			   char *buf) \
+{ \
+	return iscsi_ipv4addr_attr_show(d, buf); \
+} \
+static ssize_t store_##name(struct device *d, struct device_attribute *attr, \
+			    const char *buf, size_t len) \
+{ \
+	return iscsi_ipv4addr_attr_store(d, buf, len); \
+} \
+static DEVICE_ATTR(name, S_IRUGO | S_IWUSR, show_##name, store_##name)
+
+ISCSI_IPADDR_ATTR(iscsi_ipv4addr);
+
+static struct attribute *iscsi_offload_attrs[] = {
+	&dev_attr_iscsi_ipv4addr.attr,
+	NULL
+};
+
+static struct attribute_group iscsi_offload_attr_group = {
+	.attrs = iscsi_offload_attrs
+};
+
 /*
  * Sends an sk_buff to an offload queue driver
  * after dealing with any active network taps.
@@ -1078,6 +1120,7 @@ static int cxgb_open(struct net_device *dev)
 		if (err)
 			printk(KERN_WARNING
 			       "Could not initialize offload capabilities\n");
+		sysfs_create_group(&dev->dev.kobj, &iscsi_offload_attr_group);
 	}
 
 	link_start(dev);
@@ -1100,6 +1143,9 @@ static int cxgb_close(struct net_device *dev)
 	netif_carrier_off(dev);
 	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
 
+	if (is_offload(adapter) && !ofld_disable)
+		sysfs_remove_group(&dev->dev.kobj, &iscsi_offload_attr_group);
+
 	spin_lock(&adapter->work_lock);	/* sync with update task */
 	clear_bit(pi->port_id, &adapter->open_device_map);
 	spin_unlock(&adapter->work_lock);
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index c5b3de1..f8f4faa 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -407,6 +407,12 @@ static int cxgb_offload_ctl(struct t3cdev *tdev, unsigned int req, void *data)
 		rx_page_info->page_size = tp->rx_pg_size;
 		rx_page_info->num = tp->rx_num_pgs;
 		break;
+	case GET_ISCSI_IPV4ADDR: {
+		struct iscsi_ipv4addr *p = data;
+		struct port_info *pi = netdev_priv(p->dev);
+		p->ipv4addr = pi->iscsi_ipv4addr;
+		break;
+	}
 	default:
 		return -EOPNOTSUPP;
 	}
