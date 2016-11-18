From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] af_packet: Use virtio_net_hdr_to_skb().
Date: Fri, 18 Nov 2016 11:35:27 -0500 (EST)
Message-ID: <20161118.113527.2164504813195182869.davem@davemloft.net>
References: <1479348402-126248-1-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarno@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752813AbcKRQfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 11:35:30 -0500
In-Reply-To: <1479348402-126248-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>
Date: Wed, 16 Nov 2016 18:06:42 -0800

> Use the common virtio_net_hdr_to_skb() instead of open coding it.
> Other call sites were changed by commit fd2a0437dc, but this one was
> missed, maybe because it is split in two parts of the source code.
> 
> Also fix other call sites to be more uniform.
> 
> Fixes: fd2a0437dc ("virtio_net: introduce virtio_net_hdr_{from,to}_skb")
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

This patch is doing many more things that just this.

Do not mix unrelated changes together:

> @@ -821,9 +821,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
>  		if (iov_iter_count(iter) < vnet_hdr_len)
>  			return -EINVAL;
>  
> -		ret = virtio_net_hdr_from_skb(skb, &vnet_hdr,
> -					      macvtap_is_little_endian(q));
> -		if (ret)
> +		if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
> +					    macvtap_is_little_endian(q)))
>  			BUG();
>  
>  		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=

This has nothing to do with modifying code to use vrtio_net_hdr_to_skb(), it
doesn't belong in this patch.

> @@ -1361,15 +1360,12 @@ static ssize_t tun_put_user(struct tun_struct *tun,
>  	}
>  
>  	if (vnet_hdr_sz) {
> -		struct virtio_net_hdr gso = { 0 }; /* no info leak */
> -		int ret;
> -
> +		struct virtio_net_hdr gso;

This is _extremely_ opaque.  The initializer is trying to prevent kernel memory
info leaks onto the network or into user space.

Maybe this transformation is valid but:

1) YOU DON'T EVEN MENTION IT IN YOUR COMMIT MESSAGE.

2) It's unrelated to this specific change, therefore it belongs in
   a separate change.

3) You don't explain that it is a valid transformation, not why.

It is extremely disappointing to catch unrelated, potentially far
reaching things embedded in a patch when I review it.

Please do not ever do this.

> @@ -98,4 +98,4 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
>  	return 0;
>  }
>  
> -#endif /* _LINUX_VIRTIO_BYTEORDER */
> +#endif /* _LINUX_VIRTIO_NET_H */

Another unrelated change.

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 11db0d6..09abb88 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1971,8 +1971,6 @@ static unsigned int run_filter(struct sk_buff *skb,
>  static int __packet_rcv_vnet(const struct sk_buff *skb,
>  			     struct virtio_net_hdr *vnet_hdr)
>  {
> -	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
> -

There is no way this belongs in this patch, and again you do not explain
why removing this initializer is valid.
