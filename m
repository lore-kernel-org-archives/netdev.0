From: Igor Druzhinin <igor.druzhinin@citrix.com>
Subject: [PATCH v2 2/2] xen-netback: protect resource cleaning on XenBus disconnect
Date: Tue, 17 Jan 2017 20:49:38 +0000
Message-ID: <1484686178-76959-3-git-send-email-igor.druzhinin@citrix.com>
References: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Paul.Durrant@citrix.com>, <xen-devel@lists.xenproject.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Igor Druzhinin <igor.druzhinin@citrix.com>
To: <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484686178-76959-1-git-send-email-igor.druzhinin@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vif->lock is used to protect statistics gathering agents from using the
queue structure during cleaning.

Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>
---
 drivers/net/xen-netback/interface.c | 6 ++++--
 drivers/net/xen-netback/xenbus.c    | 2 ++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 41c69b3..c48252a 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -230,18 +230,18 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 {
 	struct xenvif *vif = netdev_priv(dev);
 	struct xenvif_queue *queue = NULL;
-	unsigned int num_queues = vif->num_queues;
 	unsigned long rx_bytes = 0;
 	unsigned long rx_packets = 0;
 	unsigned long tx_bytes = 0;
 	unsigned long tx_packets = 0;
 	unsigned int index;
 
+	spin_lock(&vif->lock);
 	if (vif->queues == NULL)
 		goto out;
 
 	/* Aggregate tx and rx stats from each queue */
-	for (index = 0; index < num_queues; ++index) {
+	for (index = 0; index < vif->num_queues; ++index) {
 		queue = &vif->queues[index];
 		rx_bytes += queue->stats.rx_bytes;
 		rx_packets += queue->stats.rx_packets;
@@ -250,6 +250,8 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
 	}
 
 out:
+	spin_unlock(&vif->lock);
+
 	vif->dev->stats.rx_bytes = rx_bytes;
 	vif->dev->stats.rx_packets = rx_packets;
 	vif->dev->stats.tx_bytes = tx_bytes;
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 3e99071..d82cd71 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -503,9 +503,11 @@ static void backend_disconnect(struct backend_info *be)
 		for (queue_index = 0; queue_index < be->vif->num_queues; ++queue_index)
 			xenvif_deinit_queue(&be->vif->queues[queue_index]);
 
+		spin_lock(&be->vif->lock);
 		vfree(be->vif->queues);
 		be->vif->num_queues = 0;
 		be->vif->queues = NULL;
+		spin_unlock(&be->vif->lock);
 
 		xenvif_disconnect_ctrl(be->vif);
 	}
-- 
1.8.3.1
