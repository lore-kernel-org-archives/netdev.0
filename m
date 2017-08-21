From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Mon, 21 Aug 2017 20:33:12 +0800
Message-ID: <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
References: <20170819063854.27010-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Koichiro Den <den@klaipeden.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36758 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753763AbdHUMdV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 08:33:21 -0400
In-Reply-To: <20170819063854.27010-1-den@klaipeden.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月19日 14:38, Koichiro Den wrote:
> Facing the possible unbounded delay relying on freeing on xmit path,
> we also better to invoke and clear the upper layer zerocopy callback
> beforehand to keep them from waiting for unbounded duration in vain.
> For instance, this removes the possible deadlock in the case that the
> upper layer is a zerocopy-enabled vhost-net.
> This does not apply if napi_tx is enabled since it will be called in
> reasonale time.
>
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> ---
>   drivers/net/virtio_net.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 4302f313d9a7..f7deaa5b7b50 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1290,6 +1290,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
>   
>   	/* Don't wait up for transmitted skbs to be freed. */
>   	if (!use_napi) {
> +		if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
> +			struct ubuf_info *uarg;
> +			uarg = skb_shinfo(skb)->destructor_arg;
> +			if (uarg->callback)
> +			    uarg->callback(uarg, true);
> +			skb_shinfo(skb)->destructor_arg = NULL;
> +			skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
> +		}
>   		skb_orphan(skb);
>   		nf_reset(skb);
>   	}


Interesting, deadlock could be treated as a a radical case of the 
discussion here https://patchwork.kernel.org/patch/3787671/.

git grep tells more similar skb_orphan() cases. Do we need to change 
them all (or part)?

Actually, we may meet similar issues at many other places (e.g netem). 
Need to consider a complete solution for this. Figuring out all places 
that could delay a packet is a method.

Thanks
