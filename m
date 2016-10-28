From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 2/4] net: Add sysfs value to determine queue
 traffic class
Date: Fri, 28 Oct 2016 11:43:49 -0400
Message-ID: <20161028154325.67826.19139.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, tom@herbertland.com,
        davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50318 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761935AbcJ1Voc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 17:44:32 -0400
In-Reply-To: <20161028154126.67826.76735.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sysfs attribute for a Tx queue that allows us to determine the
traffic class for a given queue.  This will allow us to more easily
determine this in the future.  It is needed as XPS will take the traffic
class for a group of queues into account in order to avoid pulling traffic
from one traffic class into another.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

v2: Added this patch to the series.

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   17 +++++++++++++++++
 net/core/net-sysfs.c      |   20 +++++++++++++++++++-
 3 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d045432..b60a156 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1920,6 +1920,7 @@ int netdev_set_prio_tc_map(struct net_device *dev, u8 prio, u8 tc)
 	return 0;
 }
 
+int netdev_txq_to_tc(struct net_device *dev, unsigned int txq);
 void netdev_reset_tc(struct net_device *dev);
 int netdev_set_tc_queue(struct net_device *dev, u8 tc, u16 count, u16 offset);
 int netdev_set_num_tc(struct net_device *dev, u8 num_tc);
diff --git a/net/core/dev.c b/net/core/dev.c
index d4d45bf..08ed625 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1948,6 +1948,23 @@ static void netif_setup_tc(struct net_device *dev, unsigned int txq)
 	}
 }
 
+int netdev_txq_to_tc(struct net_device *dev, unsigned int txq)
+{
+	if (dev->num_tc) {
+		struct netdev_tc_txq *tc = &dev->tc_to_txq[0];
+		int i;
+
+		for (i = 0; i < TC_MAX_QUEUE; i++, tc++) {
+			if ((txq - tc->offset) < tc->count)
+				return i;
+		}
+
+		return -1;
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_XPS
 static DEFINE_MUTEX(xps_map_mutex);
 #define xmap_dereference(P)		\
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 6e4f347..c4e4e7d 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1021,7 +1021,6 @@ static ssize_t show_trans_timeout(struct netdev_queue *queue,
 	return sprintf(buf, "%lu", trans_timeout);
 }
 
-#ifdef CONFIG_XPS
 static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 {
 	struct net_device *dev = queue->dev;
@@ -1033,6 +1032,21 @@ static unsigned int get_netdev_queue_index(struct netdev_queue *queue)
 	return i;
 }
 
+static ssize_t show_traffic_class(struct netdev_queue *queue,
+				  struct netdev_queue_attribute *attribute,
+				  char *buf)
+{
+	struct net_device *dev = queue->dev;
+	int index = get_netdev_queue_index(queue);
+	int tc = netdev_txq_to_tc(dev, index);
+
+	if (tc < 0)
+		return -EINVAL;
+
+	return sprintf(buf, "%u\n", tc);
+}
+
+#ifdef CONFIG_XPS
 static ssize_t show_tx_maxrate(struct netdev_queue *queue,
 			       struct netdev_queue_attribute *attribute,
 			       char *buf)
@@ -1075,6 +1089,9 @@ static ssize_t set_tx_maxrate(struct netdev_queue *queue,
 static struct netdev_queue_attribute queue_trans_timeout =
 	__ATTR(tx_timeout, S_IRUGO, show_trans_timeout, NULL);
 
+static struct netdev_queue_attribute queue_traffic_class =
+	__ATTR(traffic_class, S_IRUGO, show_traffic_class, NULL);
+
 #ifdef CONFIG_BQL
 /*
  * Byte queue limits sysfs structures and functions.
@@ -1260,6 +1277,7 @@ static ssize_t store_xps_map(struct netdev_queue *queue,
 
 static struct attribute *netdev_queue_default_attrs[] = {
 	&queue_trans_timeout.attr,
+	&queue_traffic_class.attr,
 #ifdef CONFIG_XPS
 	&xps_cpus_attribute.attr,
 	&queue_tx_maxrate.attr,
