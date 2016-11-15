From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v5] cadence: Add LSO support.
Date: Tue, 15 Nov 2016 05:11:30 -0800
Message-ID: <1479215490.8455.122.camel@edumazet-glaptop3.roam.corp.google.com>
References: <BN3PR07MB2516C30913D2FB8D4788071AC9BC0@BN3PR07MB2516.namprd07.prod.outlook.com>
         <20161114.123038.1075174354580074536.davem@davemloft.net>
         <BN3PR07MB251641C606D02892E2196960C9BF0@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35433 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934339AbcKONLc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 08:11:32 -0500
In-Reply-To: <BN3PR07MB251641C606D02892E2196960C9BF0@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-15 at 07:07 +0000, Rafal Ozieblo wrote:
> > > > If UFO is in use it should not silently disable UDP checksums.
> > > > 
> > > > If you cannot support UFO with proper checksumming, then you cannot enable support for that feature.
> > > 
> > > According Cadence Gigabit Ethernet MAC documentation:
> > > 
> > > "Hardware will not calculate the UDP checksum or modify the UDP 
> > > checksum field. Therefore software must set a value of zero in the 
> > > checksum field in the UDP header (in the first payload buffer) to indicate to the receiver that the UDP datagram does not include a checksum."
> > > 
> > > It is hardware requirement.
> >
> > I do not doubt that it is a hardware restriction.
> >
> > But I am saying that you cannot enable this feature under Linux if this is how it operates on your hardware.
> 
> Would it be good to enable UFO conditionally with some internal define? Ex.:
> 
> +#ifdef MACB_ENABLE_UFO
> +#define MACB_NETIF_LSO         (NETIF_F_TSO | NETIF_F_UFO)
> +#else
> +#define MACB_NETIF_LSO         (NETIF_F_TSO)
> +#endif
> 
> I could add precise comment here that ufo is possible only without checksum.
> 
> Or maybe I could enable it from module_params or device-tree (like: drivers/net/ethernet/neterion/s2io.c).

No you can not do that.

1) That would violate UDP specs.
2) Module params are no longer accepted.
3) Comments in a driver source code would only help the driver
maintainer, not users to make their mind.

Only way would be to propagate the intent of the sender.

Only the sender application can decide to generate UDP checksums or not.

Your driver ndo_features_check() could then force software segmentation
fallback if the user did not asked to disable UDP checksums, and packet
is UFO.

(look for UDP_NO_CHECK6_TX, and SO_NO_CHECK )

Problem is complex, because the skb has no marker, only the socket has.

And socket state could change between packets, and packets can stay in
an intermediate qdisc before hitting device driver. So looking at
skb->sk from your ndo_features_check() would be racy.

What use case would you have precisely ?
