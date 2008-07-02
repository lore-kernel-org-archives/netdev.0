From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH 3/4] tun: Allow GSO using virtio_net_hdr
Date: Tue, 01 Jul 2008 22:13:59 -0700
Message-ID: <486B0E97.3040303@qualcomm.com>
References: <200806260028.07883.rusty@rustcorp.com.au> <200806260029.40267.rusty@rustcorp.com.au> <200806260030.38293.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, markmc@redhat.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:20546 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbYGBFNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2008 01:13:48 -0400
In-Reply-To: <200806260030.38293.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Rusty Russell wrote:
> Add a IFF_VNET_HDR flag.  This uses the same ABI as virtio_net (ie. prepending
> struct virtio_net_hdr to packets) to indicate GSO and checksum information.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  drivers/net/tun.c      |   90 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/if_tun.h |    2 +
>  2 files changed, 91 insertions(+), 1 deletion(-)
> 
> diff -r d94590c1550a drivers/net/tun.c
> --- a/drivers/net/tun.c	Thu Jun 26 00:21:11 2008 +1000
> +++ b/drivers/net/tun.c	Thu Jun 26 00:21:59 2008 +1000
> @@ -63,6 +63,7 @@
>  #include <linux/if_tun.h>
>  #include <linux/crc32.h>
>  #include <linux/nsproxy.h>
> +#include <linux/virtio_net.h>
>  #include <net/net_namespace.h>
>  #include <net/netns/generic.h>
>  
> @@ -283,12 +284,24 @@ static __inline__ ssize_t tun_get_user(s
>  	struct tun_pi pi = { 0, __constant_htons(ETH_P_IP) };
>  	struct sk_buff *skb;
>  	size_t len = count, align = 0;
> +	struct virtio_net_hdr gso = { 0 };
>  
>  	if (!(tun->flags & TUN_NO_PI)) {
>  		if ((len -= sizeof(pi)) > count)
>  			return -EINVAL;
>  
>  		if(memcpy_fromiovec((void *)&pi, iv, sizeof(pi)))
> +			return -EFAULT;
> +	}
> +
> +	if (tun->flags & TUN_VNET_HDR) {
> +		if ((len -= sizeof(gso)) > count)
> +			return -EINVAL;
> +
> +		if (gso.hdr_len > len)
> +			return -EINVAL;
> +
> +		if (memcpy_fromiovec((void *)&gso, iv, sizeof(gso)))
>  			return -EFAULT;
>  	}

Unless I'm missing something the 'if (gso.hdr_len > len)' must be after
memcpy_fromiovec().

> @@ -322,8 +335,45 @@ static __inline__ ssize_t tun_get_user(s
>  		break;
>  	};
>  
> -	if (tun->flags & TUN_NOCHECKSUM)
> +	if (gso.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
> +		if (!skb_partial_csum_set(skb, gso.csum_start,
> +					  gso.csum_offset)) {
> +			tun->dev->stats.rx_dropped++;
> +			kfree_skb(skb);
> +			return -EINVAL;
> +		}
> +	} else if (tun->flags & TUN_NOCHECKSUM)
>  		skb->ip_summed = CHECKSUM_UNNECESSARY;
> +
> +	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
> +		pr_debug("GSO!\n");
> +		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
> +		case VIRTIO_NET_HDR_GSO_TCPV4:
> +			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> +			break;
> +		case VIRTIO_NET_HDR_GSO_TCPV6:
> +			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> +			break;
> +		default:
> +			tun->dev->stats.rx_dropped++;
> +			kfree_skb(skb);
> +			return -EINVAL;
> +		}

We should use stats.rx_frame_errors instead of stats.rx_dropped to indicated
that we dropped it because something was wrong with the framing (headers,
etc). Applies to both of the cases above.

> +
> +		if (gso.gso_type & VIRTIO_NET_HDR_GSO_ECN)
> +			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
> +
> +		skb_shinfo(skb)->gso_size = gso.gso_size;
> +		if (skb_shinfo(skb)->gso_size == 0) {
> +			tun->dev->stats.rx_dropped++;
> +			kfree_skb(skb);
> +			return -EINVAL;
> +		}
Same here.

Everything else looks good.

Max

