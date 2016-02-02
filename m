From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next v4 2/2] virtio_net: add ethtool support for set and get of settings
Date: Wed,  3 Feb 2016 00:36:37 +0100
Message-ID: <1454456197-7826-3-git-send-email-razor@blackwall.org>
References: <1454456197-7826-1-git-send-email-razor@blackwall.org>
Cc: mst@redhat.com, roopa@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34537 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204AbcBBXgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 18:36:44 -0500
Received: by mail-wm0-f68.google.com with SMTP id p63so4694908wmp.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 15:36:44 -0800 (PST)
In-Reply-To: <1454456197-7826-1-git-send-email-razor@blackwall.org>
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
v3: return error if the user tries to change anything besides speed/duplex
as per Michael's comment
We have to zero-out advertising as it gets set automatically by ethtool if
setting speed and duplex together.
v4: Set port type to PORT_OTHER

 drivers/net/virtio_net.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 767ab11a6e9f..3acffc82960a 100644
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
@@ -1376,6 +1380,57 @@ static void virtnet_get_channels(struct net_device *dev,
 	channels->other_count = 0;
 }
 
+/* Check if the user is trying to change anything besides speed/duplex */
+static bool virtnet_validate_ethtool_cmd(const struct ethtool_cmd *cmd)
+{
+	struct ethtool_cmd diff1 = *cmd;
+	struct ethtool_cmd diff2 = {};
+
+	/* advertising and cmd are usually set */
+	ethtool_cmd_speed_set(&diff1, 0);
+	diff1.advertising = 0;
+	diff1.duplex = 0;
+	diff1.cmd = 0;
+
+	return !memcmp(&diff1, &diff2, sizeof(diff1));
+}
+
+static int virtnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u32 speed;
+
+	speed = ethtool_cmd_speed(cmd);
+	/* don't allow custom speed and duplex */
+	if (!ethtool_validate_speed(speed) ||
+	    !ethtool_validate_duplex(cmd->duplex) ||
+	    !virtnet_validate_ethtool_cmd(cmd))
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
+	cmd->port = PORT_OTHER;
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
@@ -1383,6 +1438,8 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 	.set_channels = virtnet_set_channels,
 	.get_channels = virtnet_get_channels,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_settings = virtnet_get_settings,
+	.set_settings = virtnet_set_settings,
 };
 
 #define MIN_MTU 68
@@ -1855,6 +1912,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
 	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
 
+	virtnet_init_settings(dev);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
-- 
2.4.3
