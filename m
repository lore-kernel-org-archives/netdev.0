From: anuradhak@cumulusnetworks.com
Subject: [PATCH net-next v2 2/3] virtio net: Handle proto_down state by setting the carrier off.
Date: Sat, 21 Mar 2015 21:06:57 -0700
Message-ID: <1426997218-27313-3-git-send-email-anuradhak@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, wkok@cumulusnetworks.com,
	anuradhak@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32784 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbbCVEHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 00:07:09 -0400
Received: by pabxg6 with SMTP id xg6so140055924pab.0
        for <netdev@vger.kernel.org>; Sat, 21 Mar 2015 21:07:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Applications such as MLAG can detect errors in the network which results
in IFF_PROTO_DOWN being set. This patch adds support for handling
proto_down for virtio drivers by turning off the carrier and stopping
netif processing.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 drivers/net/virtio_net.c |   78 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 74 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f1ff366..e396bf4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -767,6 +767,15 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
 	return received;
 }
 
+static inline bool is_virtnet_up(struct virtnet_info *vi)
+{
+	if ((vi->status & VIRTIO_NET_S_LINK_UP) &&
+	    !(vi->dev->flags & IFF_PROTO_DOWN))
+		return true;
+
+	return false;
+}
+
 #ifdef CONFIG_NET_RX_BUSY_POLL
 /* must be called with local_bh_disable()d */
 static int virtnet_busy_poll(struct napi_struct *napi)
@@ -776,7 +785,7 @@ static int virtnet_busy_poll(struct napi_struct *napi)
 	struct virtnet_info *vi = rq->vq->vdev->priv;
 	int r, received = 0, budget = 4;
 
-	if (!(vi->status & VIRTIO_NET_S_LINK_UP))
+	if (!is_virtnet_up(vi))
 		return LL_FLUSH_FAILED;
 
 	if (!napi_schedule_prep(napi))
@@ -1428,7 +1437,7 @@ static void virtnet_config_changed_work(struct work_struct *work)
 
 	vi->status = v;
 
-	if (vi->status & VIRTIO_NET_S_LINK_UP) {
+	if (is_virtnet_up(vi)) {
 		netif_carrier_on(vi->dev);
 		netif_tx_wake_all_queues(vi->dev);
 	} else {
@@ -1878,7 +1887,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		schedule_work(&vi->config_work);
 	} else {
 		vi->status = VIRTIO_NET_S_LINK_UP;
-		netif_carrier_on(dev);
+		if (is_virtnet_up(vi))
+			netif_carrier_on(dev);
 	}
 
 	pr_debug("virtnet: registered device %s with %d RX and TX vq's\n",
@@ -2027,7 +2037,67 @@ static struct virtio_driver virtio_net_driver = {
 #endif
 };
 
-module_virtio_driver(virtio_net_driver);
+/* virtio_netdev_event: handle netdev notifier chain events. */
+static int virtio_netdev_event(struct notifier_block *this,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct virtnet_info *vi;
+
+	if (dev->netdev_ops != &virtnet_netdev)
+		return NOTIFY_DONE;
+
+	vi = netdev_priv(dev);
+
+	switch (event) {
+	case NETDEV_CHANGE:
+		/* carrier state needs to be updated based on changes to
+		 * proto_down state
+		 */
+		if (is_virtnet_up(vi)) {
+			if (!netif_carrier_ok(dev)) {
+				netif_carrier_on(dev);
+				netif_tx_wake_all_queues(vi->dev);
+			}
+		} else {
+			if (netif_carrier_ok(dev)) {
+				netif_carrier_off(dev);
+				netif_tx_stop_all_queues(dev);
+			}
+		}
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block virtio_netdev_notifier = {
+	.notifier_call = virtio_netdev_event,
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	ret = register_virtio_driver(&virtio_net_driver);
+	if (ret)
+		goto done;
+
+	register_netdevice_notifier(&virtio_netdev_notifier);
+
+done:
+	return ret;
+}
+module_init(init);
+
+static void __exit fini(void)
+{
+	unregister_netdevice_notifier(&virtio_netdev_notifier);
+	unregister_virtio_driver(&virtio_net_driver);
+}
+module_exit(fini);
 
 MODULE_DEVICE_TABLE(virtio, id_table);
 MODULE_DESCRIPTION("Virtio network driver");
-- 
1.7.10.4
