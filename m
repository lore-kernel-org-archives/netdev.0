From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH RFC 5/6] net: orphan frags on receive
Date: Wed, 9 May 2012 14:54:52 +0100
Message-ID: <1336571692.25514.122.camel@zakaz.uk.xensource.com>
References: <cover.1336397823.git.mst@redhat.com>
	 <a3353f6235d877c6b2d300eb5a914dbc9b78824d.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:30337 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab2EINyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 09:54:54 -0400
In-Reply-To: <a3353f6235d877c6b2d300eb5a914dbc9b78824d.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:
> zero copy packets are normally sent to the outside
> network, but bridging, tun etc might loop them
> back to host networking stack. If this happens
> destructors will never be called, so orphan
> the frags immediately on receive.

I think this deceptively simply patch is actually the meat of the
series.

It's been a long time since I dug into the bridging code. Am I right
that this function is only reached when an SKB is going to be delivered
locally and not when forwarding to another port on the bridge?

Ian.

> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  net/core/dev.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a2be59f..c0cdc00 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1630,6 +1630,8 @@ static inline int deliver_skb(struct sk_buff *skb,
>  			      struct packet_type *pt_prev,
>  			      struct net_device *orig_dev)
>  {
> +	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> +		return -ENOMEM;
>  	atomic_inc(&skb->users);
>  	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
>  }
