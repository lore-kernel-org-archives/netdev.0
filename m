From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v2 2/2] virtio_net: add ethtool support for set and get of settings
Date: Tue,  2 Feb 2016 15:33:40 +0100
Message-ID: <1454423620-2855-3-git-send-email-razor@blackwall.org>
References: <1454423620-2855-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34370 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381AbcBBOdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:33:47 -0500
Received: by mail-wm0-f66.google.com with SMTP id p63so2700312wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 06:33:47 -0800 (PST)
In-Reply-To: <1454423620-2855-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch allows the user to set and retrieve speed and duplex of the
virtio_net device via ethtool. Having this functionality is very helpful
for simulating different environments and also enables the virtio_net
device to participate in operations where proper speed and duplex are
required (e.g. currently bonding lacp mode requires full duplex). Custom
speed and duplex are not allowed, the user-supplied settings are validated
before applying.

Example:
$ ethtool eth1
Settings for eth1:
...
	Speed: Unknown!
	Duplex: Unknown! (255)
$ ethtool -s eth1 speed 1000 duplex full
$ ethtool eth1
Settings for eth1:
...
	Speed: 1000Mb/s
	Duplex: Full

Based on a patch by Roopa Prabhu.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: use the new ethtool speed/duplex validation functions and allow half
duplex to be set

 drivers/net/virtio_net.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 767ab11a6e9f..88fdb162c5f5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -146,6 +146,10 @@ struct virtnet_info {
 	virtio_net_ctrl_ack ctrl_status;
 	u8 ctrl_promisc;
 	u8 ctrl_allmulti;
+
+	/* Ethtool settings */
+	u8 duplex;
+	u32 speed;
 };
 
 struct padded_vnet_hdr {
@@ -1376,6 +1380,39 @@ static void virtnet_get_channels(struct net_device *dev,
 	channels->other_count = 0;
 }
 
+static int virtnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u32 speed = ethtool_cmd_speed(cmd);
+
+	/* don't allow custom speed and duplex */
+	if (!ethtool_validate_speed(speed) ||
+	    !ethtool_validate_duplex(cmd->duplex))
+		return -EINVAL;
+	vi->speed = speed;
+	vi->duplex = cmd->duplex;
+
+	return 0;
+}
+
+static int virtnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	ethtool_cmd_speed_set(cmd, vi->speed);
+	cmd->duplex = vi->duplex;
+
+	return 0;
+}
+
+static void virtnet_init_settings(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	vi->speed = SPEED_UNKNOWN;
+	vi->duplex = DUPLEX_UNKNOWN;
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
 	.get_drvinfo = virtnet_get_drvinfo,
 	.get_link = ethtool_op_get_link,
@@ -1383,6 +1420,8 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_channels = virtnet_set_channels,
 	.get_channels = virtnet_get_channels,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_settings = virtnet_get_settings,
+	.set_settings = virtnet_set_settings,
 };
 
 #define MIN_MTU 68
@@ -1855,6 +1894,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
 	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
 
+	virtnet_init_settings(dev);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-- 
2.4.3
