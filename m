From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] Fix AF_PACKET ABI breakage in 4.2
Date: Thu, 24 Sep 2015 12:55:19 +0300
Message-ID: <20150924095519.GA12444@redhat.com>
References: <1443019470.74600.6.camel@infradead.org>
 <20150923.110926.1369752430685358746.davem@davemloft.net>
 <1443033908.74600.21.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gkurz-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1443033908.74600.21.camel-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2015 at 07:45:08PM +0100, David Woodhouse wrote:
> Commit 7d82410950aa ("virtio: add explicit big-endian support to memory
> accessors") accidentally changed the virtio_net header used by
> AF_PACKET with PACKET_VNET_HDR from host-endian to big-endian.
> 
> Since virtio_legacy_is_little_endian() is a very long identifier,
> define a VIO_LE macro and use that throughout the code instead of the
> hard-coded 'false' for little-endian.
> 
> This restores the ABI to match 4.1 and earlier kernels, and makes my
> test program work again.
> 
> Signed-off-by: David Woodhouse <David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>


I'm fine with this patch

Acked-by: Michael S. Tsirkin <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

but if you want to re-work it along the lines suggested
by Greg, that's also fine with me.

> ---
> On Wed, 2015-09-23 at 11:09 -0700, David Miller wrote:
> > > +#define VIO_LE virtio_legacy_is_little_endian()
> > 
> > When you define a shorthand macro, the defines to a function call,
> > make the macro have parenthesis too.
> 
> In which case I suppose it also wants to be lower-case. Although
> "function call" is a bit strong since it's effectively just a constant.
> I'm still wondering if it'd be nicer just to use (__force u16) instead.
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 7b8e39a..aa4b15c 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -230,6 +230,8 @@ struct packet_skb_cb {
>  	} sa;
>  };
>  
> +#define vio_le() virtio_legacy_is_little_endian()
> +
>  #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
>  
>  #define GET_PBDQC_FROM_RB(x)	((struct tpacket_kbdq_core *)(&(x)->prb_bdqc))
> @@ -2680,15 +2682,15 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  			goto out_unlock;
>  
>  		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
> -		    (__virtio16_to_cpu(false, vnet_hdr.csum_start) +
> -		     __virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2 >
> -		      __virtio16_to_cpu(false, vnet_hdr.hdr_len)))
> -			vnet_hdr.hdr_len = __cpu_to_virtio16(false,
> -				 __virtio16_to_cpu(false, vnet_hdr.csum_start) +
> -				__virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2);
> +		    (__virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
> +		     __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2 >
> +		      __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len)))
> +			vnet_hdr.hdr_len = __cpu_to_virtio16(vio_le(),
> +				 __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start) +
> +				__virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset) + 2);
>  
>  		err = -EINVAL;
> -		if (__virtio16_to_cpu(false, vnet_hdr.hdr_len) > len)
> +		if (__virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len) > len)
>  			goto out_unlock;
>  
>  		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
> @@ -2731,7 +2733,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  	hlen = LL_RESERVED_SPACE(dev);
>  	tlen = dev->needed_tailroom;
>  	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
> -			       __virtio16_to_cpu(false, vnet_hdr.hdr_len),
> +			       __virtio16_to_cpu(vio_le(), vnet_hdr.hdr_len),
>  			       msg->msg_flags & MSG_DONTWAIT, &err);
>  	if (skb == NULL)
>  		goto out_unlock;
> @@ -2778,8 +2780,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  
>  	if (po->has_vnet_hdr) {
>  		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
> -			u16 s = __virtio16_to_cpu(false, vnet_hdr.csum_start);
> -			u16 o = __virtio16_to_cpu(false, vnet_hdr.csum_offset);
> +			u16 s = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_start);
> +			u16 o = __virtio16_to_cpu(vio_le(), vnet_hdr.csum_offset);
>  			if (!skb_partial_csum_set(skb, s, o)) {
>  				err = -EINVAL;
>  				goto out_free;
> @@ -2787,7 +2789,7 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
>  		}
>  
>  		skb_shinfo(skb)->gso_size =
> -			__virtio16_to_cpu(false, vnet_hdr.gso_size);
> +			__virtio16_to_cpu(vio_le(), vnet_hdr.gso_size);
>  		skb_shinfo(skb)->gso_type = gso_type;
>  
>  		/* Header must be checked, and gso_segs computed. */
> @@ -3161,9 +3163,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>  
>  			/* This is a hint as to how much should be linear. */
>  			vnet_hdr.hdr_len =
> -				__cpu_to_virtio16(false, skb_headlen(skb));
> +				__cpu_to_virtio16(vio_le(), skb_headlen(skb));
>  			vnet_hdr.gso_size =
> -				__cpu_to_virtio16(false, sinfo->gso_size);
> +				__cpu_to_virtio16(vio_le(), sinfo->gso_size);
>  			if (sinfo->gso_type & SKB_GSO_TCPV4)
>  				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
>  			else if (sinfo->gso_type & SKB_GSO_TCPV6)
> @@ -3181,9 +3183,9 @@ static int packet_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>  
>  		if (skb->ip_summed == CHECKSUM_PARTIAL) {
>  			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
> -			vnet_hdr.csum_start = __cpu_to_virtio16(false,
> +			vnet_hdr.csum_start = __cpu_to_virtio16(vio_le(),
>  					  skb_checksum_start_offset(skb));
> -			vnet_hdr.csum_offset = __cpu_to_virtio16(false,
> +			vnet_hdr.csum_offset = __cpu_to_virtio16(vio_le(),
>  							 skb->csum_offset);
>  		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
>  			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
> 
> -- 
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org                              Intel Corporation
> 
