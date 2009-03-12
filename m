From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Fri, 13 Mar 2009 10:17:11 +1030
Message-ID: <200903131017.11572.rusty@rustcorp.com.au>
References: <200903121946.24847.rusty@rustcorp.com.au> <20090312.055235.56926675.davem@davemloft.net> <200903130809.49523.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50173 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbZCLXrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 19:47:18 -0400
In-Reply-To: <200903130809.49523.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 March 2009 08:09:49 Rusty Russell wrote:
> On Thursday 12 March 2009 23:22:35 David Miller wrote:
> > If the link is always on, you should make that explicit by providing
> > a link state handler, and making sure it always returns true.
> 
> "If".  We've discussed adding a virtio_net feature to indicate link status,
> which implies that it's *not* always on.

Actually, I've changed my mind.

Unlike a device which *has* a carrier which we can't detect, there's no
virtio_net "device" which can turn off link (not kvm/qemu, not lguest) without
the pending VIRTIO_NET_S_LINK feature.

Here's the patch for Dave's tree; the q. is do we want to put Pantelis' patch
in 2.6.29 and stable?

Rusty.

Subject: virtio_net: set carrier on by default.

Impact: fix carrier detection, older NetworkManager

This is actually two fixes:
1) If the virtio_net device doesn't support carrier, the answer is
   "yes".  This is because before the status feature there was no way
   of turning the link off in any host implementation, and it also helps
   (older) NetworkManager versions to see the device.

2) We should start with carrier on: virtnet_update_status() does nothing
   if the status hasn't changed (ie. doesn't call netif_carrier_on()).

Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -795,7 +795,10 @@ static int virtnet_probe(struct virtio_d
 		goto unregister;
 	}
 
+	/* If we have no carrier info, the answer is "always on". */
 	vi->status = VIRTIO_NET_S_LINK_UP;
+	netif_carrier_on(vi->dev);
+
 	virtnet_update_status(vi);
 
 	pr_debug("virtnet: registered device %s\n", dev->name);

