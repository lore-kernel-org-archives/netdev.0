From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net] sunvnet: set queue mapping when doing packet
 copies
Date: Thu, 29 Jan 2015 12:39:56 -0800
Message-ID: <1422563996.21689.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54CA8D33.6020006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:39359 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757873AbbA2Uj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 15:39:59 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so38519704iec.9
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 12:39:58 -0800 (PST)
In-Reply-To: <54CA8D33.6020006@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-29 at 14:42 -0500, David L Stevens wrote:
> This patch fixes a bug where vnet_skb_shape() didn't set the already-selected
> queue mapping when a packet copy was required. This results in using the
> wrong queue index for stops/starts, hung tx queues and watchdog timeouts
> under heavy load. It also transfers the destructor, truesize, and the owning
> socket for flow control (code adapted from skb_segment).
> 
> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> 
> --
> Changes since v1:
>  move truesize, destructor and socket per Eric Dumazet <eric.dumazet@gmail.com>
> 
> ---
>  drivers/net/ethernet/sun/sunvnet.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 2b719cc..0a1d3eb 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
> @@ -1123,6 +1123,16 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
>  			skb_shinfo(nskb)->gso_size = skb_shinfo(skb)->gso_size;
>  			skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
>  		}
> +		nskb->queue_mapping = skb->queue_mapping;
> +		/* Following permits correct back-pressure, for protocols
> +		 * using skb_set_owner_w().
> +		 * Idea is to transfer ownership from skb to nskb.
> +		 */
> +		if (skb->destructor == sock_wfree) {

Sorry, but you should remove this test.

(TCP uses another destructor, not sock_wfree())

All sent packets will support these swap() operations,
regardless of destructor.


> +			swap(nskb->truesize, skb->truesize);
> +			swap(nskb->destructor, skb->destructor);
> +			swap(nskb->sk, skb->sk);
> +		}
>  		dev_kfree_skb(skb);
>  		skb = nskb;
>  	}
