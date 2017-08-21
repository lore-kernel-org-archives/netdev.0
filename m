From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 3/6] mpls: add VPLS entry points
Date: Mon, 21 Aug 2017 17:55:25 +0200
Message-ID: <20170821155525.GW773745@eidolon>
References: <20170816170202.456851-1-equinox@diac24.net>
 <20170816170202.456851-4-equinox@diac24.net>
 <268e2bb8-b35b-61ed-1e23-59200f67c621@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eidolon.nox.tf ([185.142.180.128]:36690 "EHLO eidolon.nox.tf"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753245AbdHUPz1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 11:55:27 -0400
Content-Disposition: inline
In-Reply-To: <268e2bb8-b35b-61ed-1e23-59200f67c621@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 04:01:15PM +0200, Amine Kherbouche wrote:
> On 08/16/2017 07:01 PM, David Lamparter wrote:
> > This wires up the neccessary calls for VPLS into the MPLS forwarding
> > pieces.  Since CONFIG_MPLS_VPLS doesn't exist yet in Kconfig, it'll
> > never be enabled, so we're on the stubs for now.
[...]
> > +	if (rt->rt_payload_type == MPT_VPLS)
> > +		return vpls_rcv(skb, dev, pt, rt, hdr, orig_dev);
> 
> you should get the ret value of vpls_rcv() and increment stats if error 
> occurs.

An error in vpls_rcv() is not a receive error on the outer device's MPLS
layer;  the packet was received correctly (and counted for that at the
beginning of mpls_forward()) and dispatched onto an appropriately
configured VPLS device.  vpls_rcv() counts its own stats on the inner
device.

[...]
> > +static inline int vpls_rcv(skb, in_dev, pt, rt, hdr, orig_dev)
> > +{
> > +	kfree_skb(skb);
> > +	return NET_RX_DROP;
> 
> just return NET_RX_DROP;

This is not correct;  the skb ownership is passed down to vpls_rcv(),
which itself will pass it on via netif_rx().  This is also why the call
in mpls_forward() does *not* "goto drop", instead directly returning.
vpls_rcv() consumes the skb in all cases.  Doing this the other way
around would incur extra overhead through a skb_clone() in vpls_rcv()
before giving it to netif_rx().

Note that the vpls_rcv() dummy function in this patch can't be called
because the kernel will refuse to install a VPLS route into the label
table (the is_vpls_device() check will be 0).  The dummy is just to keep
the code tidy.

[...]
> > +#endif
> s/ #endif/#endif /* CONFIG_MPLS_VPLS *//

Fixed in next ver (along with the bugged prototype reported by the
build bot.)

Cheers,


-David
