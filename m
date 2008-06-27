From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 4/4] lguest: Use GSO/IFF_VNET_HDR extensions on tun/tap
Date: Fri, 27 Jun 2008 13:50:44 +1000
Message-ID: <200806271350.44608.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806261440.43984.rusty@rustcorp.com.au> <4863DCF9.20100@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, markmc@redhat.com,
	netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52453 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbYF0Duu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 23:50:50 -0400
In-Reply-To: <4863DCF9.20100@codemonkey.ws>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 27 June 2008 04:16:25 Anthony Liguori wrote:
> Rusty Russell wrote:
> > On Thursday 26 June 2008 05:07:18 Anthony Liguori wrote:
> >> Rusty Russell wrote:
> >>> +	add_feature(dev, VIRTIO_NET_F_GUEST_CSUM);
> >>
> >> You set this feature, but I never see the virtio-net driver acknowledge
> >> the feature.
>
> I still don't see GUEST_CSUM ever get referenced in virtio_net.c.
> What's the intention of this feature bit?  Could I be missing a
> virtio_net patch?  I'm using the latest bits in Linus' tree.

It says that the guest can does csum offload.  It's not advertised in the 
current Linus tree (it got snuck in by Mark after the large-packets patches 
still sitting in my tree).  It should be tho, since the driver can handle it.  
See patch at end.

> >>   Curiously, my implementation with KVM is struggling
> >> because UDP packet checksums are not correct so the DHCP client is
> >> ignoring them.  If I disable CSUM offload, things it works fine (using
> >> the virtio-net header).  The problem is only host=>guest, guest=>host is
> >> fine.
> >
> > OK, found this: wrong args to skb_partial_csum_set.  It was found by Mark
> > McLoughlin before, I just lost the fix when I extracted this into a
> > separate patch.  I chose to move the call to skb_partial_csum_set(),
> > rather than use his fix (which assumed a tap not tun device).
>
> This still doesn't fix the problem.  I can manually assign an IP address
> and even do netperf runs but I cannot get a dhcp address (dhclient is
> picky about the udp csum).

I'll retest this when I'm back home with my machines.  Perhaps it's something 
to do with the csum issue.

> Also, when I exit KVM, QEMU zombies and I notice:
>
> Message from syslogd@squirrel at Jun 26 13:02:07 ...
>  kernel: unregister_netdevice: waiting for tap0 to become free. Usage
> count = 3

That seems odd; there is a leak in the vringfd interface which I know about, 
but this looks like a GSO packet from the tun device is sticking around 
somehow.

Cheers,
Rusty.

Subject: virtio_net: Set VIRTIO_NET_F_GUEST_CSUM feature
Date: Fri, 13 Jun 2008 14:27:34 +0100
From: Mark McLoughlin <markmc@redhat.com>

We can handle receiving partial csums, so set the
appropriate feature bit.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -550,7 +550,8 @@ static struct virtio_device_id id_table[
 };
 
 static unsigned int features[] = {
-	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
+	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GUEST_CSUM,
+	VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
 };

