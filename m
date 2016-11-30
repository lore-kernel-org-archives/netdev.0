From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net 2/2] macvtap: handle ubuf refcount correctly when
 meet erros
Date: Wed, 30 Nov 2016 15:58:05 +0200
Message-ID: <20161130155758-mutt-send-email-mst@kernel.org>
References: <1480483072-14201-1-git-send-email-jasowang@redhat.com>
 <1480483072-14201-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        wangyunjian@huawei.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756914AbcK3N6J (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:58:09 -0500
Content-Disposition: inline
In-Reply-To: <1480483072-14201-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 01:17:52PM +0800, Jason Wang wrote:
> We trigger uarg->callback() immediately after we decide do datacopy
> even if caller want to do zerocopy. This will cause the callback
> (vhost_net_zerocopy_callback) decrease the refcount. But when we meet
> an error afterwards, the error handling in vhost handle_tx() will try
> to decrease it again. This is wrong and fix this by delay the
> uarg->callback() until we're sure there's no errors.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> The patch is needed for -stable.
> ---
>  drivers/net/macvtap.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index bceca28..7869b06 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -742,13 +742,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  
>  	if (zerocopy)
>  		err = zerocopy_sg_from_iter(skb, from);
> -	else {
> +	else
>  		err = skb_copy_datagram_from_iter(skb, 0, from, len);
> -		if (!err && m && m->msg_control) {
> -			struct ubuf_info *uarg = m->msg_control;
> -			uarg->callback(uarg, false);
> -		}
> -	}
>  
>  	if (err)
>  		goto err_kfree;
> @@ -779,7 +774,11 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
>  		skb_shinfo(skb)->destructor_arg = m->msg_control;
>  		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
>  		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
> +	} else if (m && m->msg_control) {
> +		struct ubuf_info *uarg = m->msg_control;
> +		uarg->callback(uarg, false);
>  	}
> +
>  	if (vlan) {
>  		skb->dev = vlan->dev;
>  		dev_queue_xmit(skb);
> -- 
> 2.7.4
