From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sunvnet: set queue mapping when doing packet copies
Date: Thu, 29 Jan 2015 10:12:26 -0800
Message-ID: <1422555146.21689.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54C90AED.7040404@oracle.com> <54CA63E6.3020603@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:37090 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755716AbbA2SNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 13:13:49 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so13846303igk.1
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 10:13:48 -0800 (PST)
In-Reply-To: <54CA63E6.3020603@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 11:46 -0500, David L Stevens wrote:
> [resending this since it never appeared on netdev yesterday]
> 
> This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
>  queue mapping when a packet copy was required. This results in using the
>  wrong queue index for stops/starts, hung tx queues and watchdog timeouts
>  under heavy load.
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  drivers/net/ethernet/sun/sunvnet.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 2b719cc..2b10b85 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -1123,6 +1123,7 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
>  			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
>  			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
>  		}
> +		nskb->queue_mapping = skb->queue_mapping;
>  		dev_kfree_skb(skb);
>  		skb = nskb;
>  	}

Note that vnet_skb_shape() also drops the skb -> sk assocation.

-> That removes flow control, a single socket can fill TX ring buffer.
TCP Small queue is also disabled.

I would try add before the dev_kfree_skb(skb) :

swap(nskb->sk, skb->sk);
swap(nskb->truesize, skb->truesize);
