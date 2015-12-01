From: kan.liang@intel.com
Subject: [RFC 3/4] net: support per queue rx_usecs in sysfs
Date: Tue,  1 Dec 2015 08:01:31 +0000
Message-ID: <1448956892-15509-3-git-send-email-kan.liang@intel.com>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
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
	id S1751894AbbLATnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 14:43:20 -0500
In-Reply-To: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Network devices usually have many queues. Each queue has its own
rx_usecs options. Currently, we can only set all the queues with same
value by ethtool. This patch expose the rx_usecs in sysfs. So the user
can set/get per queue coalesce parameter rx_usecs by sysfs.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 Documentation/networking/scaling.txt |  4 ++++
 include/linux/netdevice.h            |  8 ++++++++
 net/core/net-sysfs.c                 | 36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+)

diff --git a/Documentation/networking/scaling.txt b/Documentation/networking/scaling.txt
index 636192d..218429c 100644
--- a/Documentation/networking/scaling.txt
+++ b/Documentation/networking/scaling.txt
@@ -440,6 +440,10 @@ TX queue absolute delay timer can be set to a microseconds value with
 
 /sys/class/net/<dev>/queues/tx-<n>/tx_usecs
 
+RX queue absolute delay timer can be set to a microseconds value with
+
+/sys/class/net/<dev>/queues/rx-<n>/rx_usecs
+
 For the device which doesn't support per queue interrupt moderation,
 it shows "N/A".
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9db5c57..45a0054 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1063,6 +1063,10 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  * 				      int index, u32 val);
  * void (*ndo_get_per_queue_tx_usecs)(struct net_device *dev, int index);
  * 	This function is used to set/get per queue coalesce parameter tx_usecs.
+ * void (*ndo_set_per_queue_rx_usecs)(struct net_device *dev,
+ * 				      int index, u32 val);
+ * void (*ndo_get_per_queue_rx_usecs)(struct net_device *dev, int index);
+ * 	This function is used to set/get per queue coalesce parameter rx_usecs.
  *
  */
 struct net_device_ops {
@@ -1244,6 +1248,10 @@ struct net_device_ops {
 							      int index, u32 val);
 	u32			(*ndo_get_per_queue_tx_usecs)(struct net_device *dev,
 							      int index);
+	void			(*ndo_set_per_queue_rx_usecs)(struct net_device *dev,
+							      int index, u32 val);
+	u32			(*ndo_get_per_queue_rx_usecs)(struct net_device *dev,
+							      int index);
 };
 
 /**
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 48016b8..ab08b2b 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -831,11 +831,47 @@ static struct rx_queue_attribute rps_dev_flow_table_cnt_attribute =
 	    show_rps_dev_flow_table_cnt, store_rps_dev_flow_table_cnt);
 #endif /* CONFIG_RPS */
 
+static ssize_t rx_usecs_show(struct netdev_rx_queue *queue,
+			     struct rx_queue_attribute *attribute, char *buf)
+{
+	struct net_device *dev = queue->dev;
+	int index = queue - dev->_rx;
+	u32 val;
+
+	if (dev->netdev_ops->ndo_get_per_queue_rx_usecs) {
+		val = dev->netdev_ops->ndo_get_per_queue_rx_usecs(dev, index);
+		return sprintf(buf, "%u\n", val);
+	}
+	return sprintf(buf, "N/A\n");
+}
+
+static ssize_t rx_usecs_store(struct netdev_rx_queue *queue,
+			      struct rx_queue_attribute *attribute,
+			      const char *buf, size_t len)
+{
+	struct net_device *dev = queue->dev;
+	int index = queue - dev->_rx;
+	u32 val, ret;
+
+	ret = kstrtouint(buf, 0, &val);
+	if (ret < 0)
+		return -EINVAL;
+
+	if (dev->netdev_ops->ndo_set_per_queue_rx_usecs)
+		dev->netdev_ops->ndo_set_per_queue_rx_usecs(dev, index, val);
+
+	return len;
+}
+
+static struct rx_queue_attribute rx_usecs_attribute =
+	__ATTR(rx_usecs, S_IRUGO | S_IWUSR, rx_usecs_show, rx_usecs_store);
+
 static struct attribute *rx_queue_default_attrs[] = {
 #ifdef CONFIG_RPS
 	&rps_cpus_attribute.attr,
 	&rps_dev_flow_table_cnt_attribute.attr,
 #endif
+	&rx_usecs_attribute.attr,
 	NULL
 };
 
-- 
1.7.11.7
