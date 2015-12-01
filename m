From: kan.liang@intel.com
Subject: [RFC 1/4] net: support per queue tx_usecs in sysfs
Date: Tue,  1 Dec 2015 08:01:29 +0000
Message-ID: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, john.r.fastabend@intel.com,
	ogerlitz@mellanox.com, edumazet@google.com, jiri@mellanox.com,
	sfeldma@gmail.com, gospo@cumulusnetworks.com,
	sasha.levin@oracle.com, f.fainelli@gmail.com, dsahern@gmail.com,
	tj@kernel.org, cascardo@redhat.com, corbet@lwn.net,
	Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4404 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750894AbbLATnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 14:43:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Network devices usually have many queues. Each queue has its own
tx_usecs options. Currently, we can only set all the queues with same
value by ethtool. This patch expose the tx_usecs in sysfs. So the user
can set/get per queue coalesce parameter tx_usecs by sysfs.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 Documentation/networking/scaling.txt | 12 ++++++++++++
 include/linux/netdevice.h            |  8 ++++++++
 net/core/net-sysfs.c                 | 38 ++++++++++++++++++++++++++++++++++++
 3 files changed, 58 insertions(+)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 59f4db2..636192d 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -431,6 +431,18 @@ a max-rate attribute is supported, by setting a Mbps value to
 
 A value of zero means disabled, and this is the default.
 
+Per Queue interrupt moderation:
+=============================
+
+The interrupt moderation mechanism, which implemented by HW, employs
+a series of timers to limit the number of interrupts it generates.
+TX queue absolute delay timer can be set to a microseconds value with
+
+/sys/class/net/<dev>/queues/tx-<n>/tx_usecs
+
+For the device which doesn't support per queue interrupt moderation,
+it shows "N/A".
+
 Further Information
 ===================
 RPS and RFS were introduced in kernel 2.6.35. XPS was incorporated into
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7d2d1d7..9db5c57 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1059,6 +1059,10 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	This function is used to get egress tunnel information for given skb.
  *	This is useful for retrieving outer tunnel header parameters while
  *	sampling packet.
+ * void (*ndo_set_per_queue_tx_usecs)(struct net_device *dev,
+ * 				      int index, u32 val);
+ * void (*ndo_get_per_queue_tx_usecs)(struct net_device *dev, int index);
+ * 	This function is used to set/get per queue coalesce parameter tx_usecs.
  *
  */
 struct net_device_ops {
@@ -1236,6 +1240,10 @@ struct net_device_ops {
 							 bool proto_down);
 	int			(*ndo_fill_metadata_dst)(struct net_device *dev,
 						       struct sk_buff *skb);
+	void			(*ndo_set_per_queue_tx_usecs)(struct net_device *dev,
+							      int index, u32 val);
+	u32			(*ndo_get_per_queue_tx_usecs)(struct net_device *dev,
+							      int index);
 };
 
 /**
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index f88a62a..48016b8 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1239,12 +1239,50 @@ static struct netdev_queue_attribute xps_cpus_attribute =
     __ATTR(xps_cpus, S_IRUGO | S_IWUSR, show_xps_map, store_xps_map);
 #endif /* CONFIG_XPS */
 
+static ssize_t tx_usecs_show(struct netdev_queue *queue,
+			     struct netdev_queue_attribute *attr,
+			     char *buf)
+{
+	struct net_device *dev = queue->dev;
+	int index = queue - dev->_tx;
+	u32 val;
+
+	if (dev->netdev_ops->ndo_get_per_queue_tx_usecs) {
+		val = dev->netdev_ops->ndo_get_per_queue_tx_usecs(dev, index);
+		return sprintf(buf, "%u\n", val);
+	}
+
+	return sprintf(buf, "N/A\n");
+}
+
+static ssize_t tx_usecs_store(struct netdev_queue *queue,
+			      struct netdev_queue_attribute *attr,
+			      const char *buf, size_t len)
+{
+	struct net_device *dev = queue->dev;
+	int index = queue - dev->_tx;
+	u32 val, ret;
+
+	ret = kstrtouint(buf, 0, &val);
+	if (ret < 0)
+		return -EINVAL;
+
+	if (dev->netdev_ops->ndo_set_per_queue_tx_usecs)
+		dev->netdev_ops->ndo_set_per_queue_tx_usecs(dev, index, val);
+
+	return len;
+}
+
+static struct netdev_queue_attribute tx_usecs_attribute =
+    __ATTR(tx_usecs, S_IRUGO | S_IWUSR, tx_usecs_show, tx_usecs_store);
+
 static struct attribute *netdev_queue_default_attrs[] = {
 	&queue_trans_timeout.attr,
 #ifdef CONFIG_XPS
 	&xps_cpus_attribute.attr,
 	&queue_tx_maxrate.attr,
 #endif
+	&tx_usecs_attribute.attr,
 	NULL
 };
 
-- 
1.7.11.7
