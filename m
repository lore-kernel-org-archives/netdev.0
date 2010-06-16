From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Wed, 16 Jun 2010 11:24:59 +0930
Message-ID: <201006161125.00297.rusty@rustcorp.com.au>
References: <4C11915E.6090201@jp.fujitsu.com> <201006151358.12071.rusty@rustcorp.com.au> <4C170D9E.5090407@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53559 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753653Ab0FPBzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jun 2010 21:55:08 -0400
In-Reply-To: <4C170D9E.5090407@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jun 2010 02:50:30 pm Taku Izumi wrote:
> Hi Rusty,
> 
> (2010/06/15 13:28), Rusty Russell wrote:
> > On Fri, 11 Jun 2010 10:59:02 am Taku Izumi wrote:
> >> This patch implements ethtool_ops.get_drvinfo interface of virtio_net driver.
> >>
> >> Signed-off-by: Taku Izumi<izumi.taku@jp.fujitsu.com>
> > 
> > Hi Taku!
> > 
> >     Does this have any useful effect?
> 
> I often use "ethtool -i" command to check what driver controls the ehternet device.
> But because current virtio_net driver doesn't support "ethtool -i", it becomes the
> following:
> 
> 	# ethtool -i eth3
> 	Cannot get driver information: Operation not supported
> 
> My patch simply adds the "ethtool -i" support. The following is the result when
> using the virtio_net driver with my patch applied to.
> 
> 	# ethtool -i eth3
> 	driver: virtio_net
> 	version: N/A
> 	firmware-version: N/A
> 	bus-info: virtio0
> 
> Personally, "-i" is one of the most frequently-used option, and
> most network drivers support "ethtool -i", so I think virtio_net also should do.

Thanks, Taku.

I put this explanation in the commit message, and changed 32 to ARRAY_SIZE().
It's queued for sending to DaveM for the next merge window.

Result below.

Thanks!
Rusty.

Subject: virtio_net: implements ethtool_ops.get_drvinfo
Date: Fri, 11 Jun 2010 10:29:02 +0900
From: Taku Izumi <izumi.taku@jp.fujitsu.com>

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
 0 files changed

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
