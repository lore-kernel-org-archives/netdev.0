From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Fri, 28 Nov 2008 10:52:33 +1030
Message-ID: <200811281052.33474.rusty@rustcorp.com.au>
References: <1227707891.9579.44.camel@blaa> <200811272300.58151.rusty@rustcorp.com.au> <1227794225.24571.36.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47458 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbYK1AWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 19:22:41 -0500
In-Reply-To: <1227794225.24571.36.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 28 November 2008 00:27:05 Mark McLoughlin wrote:
> Hi Rusty,
>
> On Thu, 2008-11-27 at 23:00 +1030, Rusty Russell wrote:
> > On Thursday 27 November 2008 00:28:11 Mark McLoughlin wrote:
> > > We don't really have a max tx packet size limit, so allow configuring
> > > the device with up to 64k tx MTU.
> >
> > Hi Mark,
> >
> > Just one comment: maybe we should be conservative and maybe limit to 1500
> > if the host doesn't offer any of the GSO or MRG_RXBUF features?
>
> That was actually what I was going to do until I thought about it a bit
> more and discussed it with Herbert.
>
> The virtio_net MTU only affects the transmit path, so there shouldn't be
> any issue with a host that doesn't support those features.

Not quite what I meant.  A minimal host can reasonably expect ethernet-fitting
packets.  If it supports GSO of course it must handle larger ones.  Otherwise
we should add YA feature bit or even a max-mtu field.

So, I was thinking something like this over your patch (I also removed the
used-once MAX and MIN definitions; I dislike gratuitous indirection):

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -480,26 +480,24 @@ static struct ethtool_ops virtnet_ethtoo
 	.set_sg = ethtool_op_set_sg,
 };
 
-#define MIN_MTU 68
-#define MAX_MTU 65535
-
 static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int max_mtu;
 
-	/* Only allow a large MTU if we know we have a chance
-	 * of also supporting that MTU on the receive side. */
-	if (vi->mergeable_rx_bufs || vi->big_packets)
-		max_mtu = MAX_MTU;
+	/* A host which can handle GSO must handle large packets. */
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_GSO)
+	    || virtio_has_feature(vi->vdev, VIRTIO_NET_F_HOST_TSO4)
+	    || virtio_has_feature(vi->vdev, VIRTIO_NET_F_HOST_TSO6)
+	    || virtio_has_feature(vi->vdev, VIRTIO_NET_F_HOST_UFO))
+		max_mtu = 65535;
 	else
 		max_mtu = ETH_DATA_LEN;
 
-	if (new_mtu < MIN_MTU || new_mtu > max_mtu)
+	if (new_mtu < 68 || new_mtu > max_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
-
 	return 0;
 }
 

