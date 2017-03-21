From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2] net: virtio_net: use new api ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 23:24:24 +0100
Message-ID: <1490135064-23411-1-git-send-email-tremyfr@gmail.com>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: mst@redhat.com, jasowang@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35402 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933134AbdCUWYe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 18:24:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- remove comment about the missing hardware,
  I've tested this change with qemu

 drivers/net/virtio_net.c |   50 +++++++++++++++++++++++++++------------------
 1 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ea9890d..b0d241d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1636,47 +1636,57 @@ static void virtnet_get_channels(struct net_device *dev,
 }
 
 /* Check if the user is trying to change anything besides speed/duplex */
-static bool virtnet_validate_ethtool_cmd(const struct ethtool_cmd *cmd)
+static bool
+virtnet_validate_ethtool_cmd(const struct ethtool_link_ksettings *cmd)
 {
-	struct ethtool_cmd diff1 = *cmd;
-	struct ethtool_cmd diff2 = {};
+	struct ethtool_link_ksettings diff1 = *cmd;
+	struct ethtool_link_ksettings diff2 = {};
 
 	/* cmd is always set so we need to clear it, validate the port type
 	 * and also without autonegotiation we can ignore advertising
 	 */
-	ethtool_cmd_speed_set(&diff1, 0);
-	diff2.port = PORT_OTHER;
-	diff1.advertising = 0;
-	diff1.duplex = 0;
-	diff1.cmd = 0;
+	diff1.base.speed = 0;
+	diff2.base.port = PORT_OTHER;
+	ethtool_link_ksettings_zero_link_mode(&diff1, advertising);
+	diff1.base.duplex = 0;
+	diff1.base.cmd = 0;
+	diff1.base.link_mode_masks_nwords = 0;
 
-	return !memcmp(&diff1, &diff2, sizeof(diff1));
+	return !memcmp(&diff1.base, &diff2.base, sizeof(diff1.base)) &&
+		bitmap_empty(diff1.link_modes.supported,
+			     __ETHTOOL_LINK_MODE_MASK_NBITS) &&
+		bitmap_empty(diff1.link_modes.advertising,
+			     __ETHTOOL_LINK_MODE_MASK_NBITS) &&
+		bitmap_empty(diff1.link_modes.lp_advertising,
+			     __ETHTOOL_LINK_MODE_MASK_NBITS);
 }
 
-static int virtnet_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int virtnet_set_link_ksettings(struct net_device *dev,
+				      const struct ethtool_link_ksettings *cmd)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	u32 speed;
 
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
 	/* don't allow custom speed and duplex */
 	if (!ethtool_validate_speed(speed) ||
-	    !ethtool_validate_duplex(cmd->duplex) ||
+	    !ethtool_validate_duplex(cmd->base.duplex) ||
 	    !virtnet_validate_ethtool_cmd(cmd))
 		return -EINVAL;
 	vi->speed = speed;
-	vi->duplex = cmd->duplex;
+	vi->duplex = cmd->base.duplex;
 
 	return 0;
 }
 
-static int virtnet_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int virtnet_get_link_ksettings(struct net_device *dev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 
-	ethtool_cmd_speed_set(cmd, vi->speed);
-	cmd->duplex = vi->duplex;
-	cmd->port = PORT_OTHER;
+	cmd->base.speed = vi->speed;
+	cmd->base.duplex = vi->duplex;
+	cmd->base.port = PORT_OTHER;
 
 	return 0;
 }
@@ -1696,8 +1706,8 @@ static void virtnet_init_settings(struct net_device *dev)
 	.set_channels = virtnet_set_channels,
 	.get_channels = virtnet_get_channels,
 	.get_ts_info = ethtool_op_get_ts_info,
-	.get_settings = virtnet_get_settings,
-	.set_settings = virtnet_set_settings,
+	.get_link_ksettings = virtnet_get_link_ksettings,
+	.set_link_ksettings = virtnet_set_link_ksettings,
 };
 
 static void virtnet_freeze_down(struct virtio_device *vdev)
-- 
1.7.4.4
