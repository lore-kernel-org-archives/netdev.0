From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] netdev: storage address support
Date: Fri, 24 Apr 2009 01:03:50 -0700
Message-ID: <20090424080349.30460.73770.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org,
	Chris Leech <christopher.leech@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:52965
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbZDXIEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 04:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Leech <christopher.leech@intel.com>

Fibre Channel over Ethernet (FCoE) uses a second MAC address dedicated to FCoE
traffic on an Ethernet link.  There are two supported addressing modes,
negotiated at fabric discovery time with the gateway switch or Fibre Channel
Forwarder (FCF).

1) Fabric Provided MAC Address (FPMA)
The MAC address is dynamically generated from the assigned FC ID.  The FCoE
stack supports this today and adds the address to the device with the
dev_unicast_add() API.

2) Server Provided MAC Address (SPMA)
The server indicates to the FCF the address it would like to use for FCoE
traffic.  It's expected that SPMA capable interfaces will have a storage
dedicated MAC address programed into EPROM, flash, or other non-volatile
storage which the driver will be able to provide to the FCoE stack.

This adds a net_device_ops function to query a driver for a dedicated storage
address.

If ndo_get_storage_address is implemented, then the address will also be
exposed as a sysfs attribute.  In order to do that, a new optional attrs group
is added to the net_device, with the visibility of each attribute protected by
a call to netdev_show_optional_attr().

Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/netdevice.h |    3 ++-
 net/core/net-sysfs.c      |   41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3116745..3964ca6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -602,6 +602,7 @@ struct net_device_ops {
 	int			(*ndo_fcoe_ddp_done)(struct net_device *dev,
 						     u16 xid);
 #endif
+	void *			(*ndo_get_storage_address)(struct net_device *dev);
 };
 
 /*
@@ -846,7 +847,7 @@ struct net_device
 	/* class/net/name entry */
 	struct device		dev;
 	/* space for optional statistics and wireless sysfs groups */
-	struct attribute_group  *sysfs_groups[3];
+	struct attribute_group  *sysfs_groups[4];
 
 	/* rtnetlink link ops */
 	const struct rtnl_link_ops *rtnl_link_ops;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 2da59a0..da68ae6 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -266,6 +266,46 @@ static struct device_attribute net_class_attributes[] = {
 	{}
 };
 
+static ssize_t show_storage_address(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	struct net_device *net = to_net_dev(dev);
+	const struct net_device_ops *ops = net->netdev_ops;
+	u8 addr[MAX_ADDR_LEN];
+
+	if (!ops->ndo_get_storage_address)
+		return -EINVAL;
+	if (dev_isalive(net)) {
+		memcpy(addr, ops->ndo_get_storage_address(net), net->addr_len);
+		return sysfs_format_mac(buf, addr, net->addr_len);
+	}
+	return -EINVAL;
+}
+
+DEVICE_ATTR(storage_address, S_IRUGO, show_storage_address, NULL);
+
+static struct attribute *optional_attrs[] = {
+	&dev_attr_storage_address.attr,
+	NULL
+};
+
+static mode_t netdev_show_optional_attr(struct kobject *kobj,
+					struct attribute *attr, int i)
+{
+	struct device *dev = container_of(kobj, struct device, kobj);
+	struct net_device *net = to_net_dev(dev);
+	const struct net_device_ops *ops = net->netdev_ops;
+
+	if (attr == &dev_attr_storage_address.attr)
+		return ops->ndo_get_storage_address ? S_IRUGO : 0;
+	return 0;
+}
+
+static struct attribute_group optional_group = {
+	.is_visible = netdev_show_optional_attr,
+	.attrs = optional_attrs,
+};
+
 /* Show a given an attribute in the statistics group */
 static ssize_t netstat_show(const struct device *d,
 			    struct device_attribute *attr, char *buf,
@@ -502,6 +542,7 @@ int netdev_register_kobject(struct net_device *net)
 
 #ifdef CONFIG_SYSFS
 	*groups++ = &netstat_group;
+	*groups++ = &optional_group;
 
 #ifdef CONFIG_WIRELESS_EXT_SYSFS
 	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)

