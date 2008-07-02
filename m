From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/4] tun: Allow GSO using virtio_net_hdr
Date: Wed, 2 Jul 2008 17:00:35 +1000
Message-ID: <200807021700.36130.rusty@rustcorp.com.au>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260030.38293.rusty@rustcorp.com.au> <486B0E97.3040303@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60337 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759027AbYGBHBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2008 03:01:20 -0400
In-Reply-To: <486B0E97.3040303@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 02 July 2008 15:13:59 Max Krasnyansky wrote:
> Rusty Russell wrote:
> > Add a IFF_VNET_HDR flag.  This uses the same ABI as virtio_net (ie.
> > prepending struct virtio_net_hdr to packets) to indicate GSO and checksum
> > information.
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> > ---
> >  drivers/net/tun.c      |   90
> > ++++++++++++++++++++++++++++++++++++++++++++++++- include/linux/if_tun.h
> > |    2 +
> >  2 files changed, 91 insertions(+), 1 deletion(-)
> >
> > diff -r d94590c1550a drivers/net/tun.c
> > --- a/drivers/net/tun.c	Thu Jun 26 00:21:11 2008 +1000
> > +++ b/drivers/net/tun.c	Thu Jun 26 00:21:59 2008 +1000
> > @@ -63,6 +63,7 @@
> >  #include <linux/if_tun.h>
> >  #include <linux/crc32.h>
> >  #include <linux/nsproxy.h>
> > +#include <linux/virtio_net.h>
> >  #include <net/net_namespace.h>
> >  #include <net/netns/generic.h>
> >
> > @@ -283,12 +284,24 @@ static __inline__ ssize_t tun_get_user(s
> >  	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
> >  	struct sk_buff *skb;
> >  	size_t len = count, align = 0;
> > +	struct virtio_net_hdr gso = { 0 };
> >
> >  	if (!(tun->flags & TUN_NO_PI)) {
> >  		if ((len -= sizeof(pi)) > count)
> >  			return -EINVAL;
> >
> >  		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
> > +			return -EFAULT;
> > +	}
> > +
> > +	if (tun->flags & TUN_VNET_HDR) {
> > +		if ((len -= sizeof(gso)) > count)
> > +			return -EINVAL;
> > +
> > +		if (gso.hdr_len > len)
> > +			return -EINVAL;
> > +
> > +		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
> >  			return -EFAULT;
> >  	}
>
> Unless I'm missing something the 'if (gso.hdr_len > len)' must be after
> memcpy_fromiovec().

Yes, this was fixed in a followup... there was another bug picked up by markmc 
too in this patch.

> > +		case VIRTIO_NET_HDR_GSO_TCPV6:
> > +			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> > +			break;
> > +		default:
> > +			tun->dev->stats.rx_dropped++;
> > +			kfree_skb(skb);
> > +			return -EINVAL;
> > +		}
>
> We should use stats.rx_frame_errors instead of stats.rx_dropped to
> indicated that we dropped it because something was wrong with the framing
> (headers, etc). Applies to both of the cases above.

OK, done (all three).  Will repost.

Thanks,
Rusty.
