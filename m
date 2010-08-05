From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Thu, 5 Aug 2010 13:02:05 +0930
Message-ID: <201008051302.06045.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35858 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758684Ab0HEDcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 23:32:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I often use "ethtool -i" command to check what driver controls the
ehternet device.  But because current virtio_net driver doesn't
support "ethtool -i", it becomes the following:

        # ethtool -i eth3
        Cannot get driver information: Operation not supported

This patch simply adds the "ethtool -i" support. The following is the
result when using the virtio_net driver with my patch applied to.

        # ethtool -i eth3
        driver: virtio_net
        version: N/A
        firmware-version: N/A
        bus-info: virtio0

Personally, "-i" is one of the most frequently-used option, and most
network drivers support "ethtool -i", so I think virtio_net also
should do.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (use ARRAY_SIZE)
---
 drivers/net/virtio_net.c |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

Index: net-next.35/drivers/net/virtio_net.c
===================================================================
--- net-next.35.orig/drivers/net/virtio_net.c
+++ net-next.35/drivers/net/virtio_net.c
@@ -701,6 +701,19 @@ static int virtnet_close(struct net_devi
 	return 0;
 }
 
+static void virtnet_get_drvinfo(struct net_device *dev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct virtio_device *vdev = vi->vdev;
+
+	strncpy(drvinfo->driver, KBUILD_MODNAME, ARRAY_SIZE(drvinfo->driver));
+	strncpy(drvinfo->version, "N/A", ARRAY_SIZE(drvinfo->version));
+	strncpy(drvinfo->fw_version, "N/A", ARRAY_SIZE(drvinfo->fw_version));
+	strncpy(drvinfo->bus_info, dev_name(&vdev->dev),
+		ARRAY_SIZE(drvinfo->bus_info));
+}
+
 static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
@@ -813,6 +825,7 @@ static void virtnet_vlan_rx_kill_vid(str
 }
 
 static const struct ethtool_ops virtnet_ethtool_ops = {
+	.get_drvinfo = virtnet_get_drvinfo,
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
