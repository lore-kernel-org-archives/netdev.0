From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 1/2] tun: handle ubuf refcount correctly when meet
 erros
Date: Wed, 30 Nov 2016 15:57:48 +0200
Message-ID: <20161130155735-mutt-send-email-mst@kernel.org>
References: <1480483072-14201-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        wangyunjian@huawei.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49196 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933080AbcK3N54 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:57:56 -0500
Content-Disposition: inline
In-Reply-To: <1480483072-14201-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 01:17:51PM +0800, Jason Wang wrote:
> We trigger uarg->callback() immediately after we decide do datacopy
> even if caller want to do zerocopy. This will cause the callback
> (vhost_net_zerocopy_callback) decrease the refcount. But when we meet
> an error afterwards, the error handling in vhost handle_tx() will try
> to decrease it again. This is wrong and fix this by delay the
> uarg->callback() until we're sure there's no errors.
> 
> Reported-by: wangyunjian <wangyunjian@huawei.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> The patch is needed for -stable.
> ---
>  drivers/net/tun.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 8093e39..db6acec 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1246,13 +1246,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  
>  	if (zerocopy)
>  		err = zerocopy_sg_from_iter(skb, from);
> -	else {
> +	else
>  		err = skb_copy_datagram_from_iter(skb, 0, from, len);
> -		if (!err && msg_control) {
> -			struct ubuf_info *uarg = msg_control;
> -			uarg->callback(uarg, false);
> -		}
> -	}
>  
>  	if (err) {
>  		this_cpu_inc(tun->pcpu_stats->rx_dropped);
> @@ -1298,6 +1293,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
>  		skb_shinfo(skb)->destructor_arg = msg_control;
>  		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
> +	} else if (msg_control) {
> +		struct ubuf_info *uarg = msg_control;
> +		uarg->callback(uarg, false);
>  	}
>  
>  	skb_reset_network_header(skb);
> -- 
> 2.7.4
