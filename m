From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: large tx MTU support
Date: Thu, 27 Nov 2008 13:57:05 +0000
Message-ID: <1227794225.24571.36.camel@blaa>
References: <1227707891.9579.44.camel@blaa>
	 <200811272300.58151.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:54351 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbYK0N63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 08:58:29 -0500
In-Reply-To: <200811272300.58151.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Thu, 2008-11-27 at 23:00 +1030, Rusty Russell wrote:
> On Thursday 27 November 2008 00:28:11 Mark McLoughlin wrote:
> > We don't really have a max tx packet size limit, so allow configuring
> > the device with up to 64k tx MTU.
> 
> Hi Mark,
> 
> Just one comment: maybe we should be conservative and maybe limit to 1500 if 
> the host doesn't offer any of the GSO or MRG_RXBUF features?

That was actually what I was going to do until I thought about it a bit
more and discussed it with Herbert.

The virtio_net MTU only affects the transmit path, so there shouldn't be
any issue with a host that doesn't support those features.

The MTU on the receive path is a different story - e.g. the host needs
to have a large enough buffer when reading from the tap fd and the guest
needs to have allocated large enough receive buffers. The former we
fixed recently in KVM (we used to only have a 64k buffer if built with
IFF_VNET_HDR support) and the latter is currently only true if either
GSO or MRG_RXBUF has been negotiated.

So, in summary - making change_mtu() check for GSO and MRG_RXBUF isn't
correct, but perhaps we could do it anyway so as to give the user a hint
that a large MTU isn't going to work on the receive path. If you feel
that's best, here's another version.

Cheers,
Mark.

From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: large tx MTU support

We don't really have a max tx packet size limit, so allow configuring
the device with up to 64k tx MTU.

On the receive path, we can only handle a large MTU if we negotiate
GSO or MRG_RXBUF with the host. In order to give the user some hint
as to this limitation, we also limit the transmit path to a smaller
MTU if neither of those features are available.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e6b5d6e..499c7a5 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -613,6 +613,29 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tso = ethtool_op_set_tso,
 };
 
+#define MIN_MTU 68
+#define MAX_MTU 65535
+
+static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int max_mtu;
+
+	/* Only allow a large MTU if we know we have a chance
+	 * of also supporting that MTU on the receive side. */
+	if (vi->mergeable_rx_bufs || vi->big_packets)
+		max_mtu = MAX_MTU;
+	else
+		max_mtu = ETH_DATA_LEN;
+
+	if (new_mtu < MIN_MTU || new_mtu > max_mtu)
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -628,6 +651,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	dev->open = virtnet_open;
 	dev->stop = virtnet_close;
 	dev->hard_start_xmit = start_xmit;
+	dev->change_mtu = virtnet_change_mtu;
 	dev->features = NETIF_F_HIGHDMA;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = virtnet_netpoll;
-- 
1.6.0.3

