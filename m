From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] dummy: allow report link status and change it via sysfs
Date: Fri, 29 Jul 2011 17:27:33 +0200
Message-ID: <1311953253-25059-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38007 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751299Ab1G2P1j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2011 11:27:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/dummy.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 39cf9b9..fc39c24 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -37,9 +37,57 @@
 #include <linux/rtnetlink.h>
 #include <net/rtnetlink.h>
 #include <linux/u64_stats_sync.h>
+#include <linux/ethtool.h>
 
 static int numdummies = 1;
 
+static ssize_t dummy_show_link(struct device *d,
+			       struct device_attribute *attr,
+			       char *buf)
+{
+	struct net_device *dev = to_net_dev(d);
+
+	return sprintf(buf, "%d\n", netif_carrier_ok(dev) ? 1 : 0);
+}
+
+static ssize_t dummy_store_link(struct device *d,
+				struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct net_device *dev = to_net_dev(d);
+	int new_value;
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		pr_err("%s: no link value specified.\n", dev->name);
+		return -EINVAL;
+	}
+	switch (new_value) {
+	case 0:
+		netif_carrier_off(dev);
+		break;
+	case 1:
+		netif_carrier_on(dev);
+		break;
+	default:
+		pr_info("%s: Ignoring invalid link value %d.\n",
+			dev->name, new_value);
+	}
+	return count;
+}
+
+static DEVICE_ATTR(link, S_IRUGO | S_IWUSR,
+		   dummy_show_link, dummy_store_link);
+
+static struct attribute *per_dummy_attrs[] = {
+	&dev_attr_link.attr,
+	NULL,
+};
+
+static struct attribute_group dummy_group = {
+	.name = "dummy",
+	.attrs = per_dummy_attrs,
+};
+
 static int dummy_set_address(struct net_device *dev, void *p)
 {
 	struct sockaddr *sa = p;
@@ -103,6 +151,7 @@ static int dummy_dev_init(struct net_device *dev)
 	if (!dev->dstats)
 		return -ENOMEM;
 
+	dev->sysfs_groups[0] = &dummy_group;
 	return 0;
 }
 
@@ -121,12 +170,17 @@ static const struct net_device_ops dummy_netdev_ops = {
 	.ndo_get_stats64	= dummy_get_stats64,
 };
 
+static const struct ethtool_ops dummy_ethtool_ops = {
+	.get_link		= ethtool_op_get_link,
+};
+
 static void dummy_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &dummy_netdev_ops;
+	dev->ethtool_ops = &dummy_ethtool_ops;
 	dev->destructor = dummy_dev_free;
 
 	/* Fill in device structure with ethernet-generic values. */
-- 
1.7.6

