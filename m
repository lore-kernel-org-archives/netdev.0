From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] tun: use sk_fullsock() before reading
 sk->sk_tsflags
Date: Sun, 11 Oct 2015 09:06:03 +0300
Message-ID: <20151011090544-mutt-send-email-mst@redhat.com>
References: <1444430541.27760.109.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54445 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbbJKGGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Oct 2015 02:06:08 -0400
Content-Disposition: inline
In-Reply-To: <1444430541.27760.109.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2015 at 03:42:21PM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> timewait or request sockets are small and do not contain sk->sk_tsflags
> 
> Without this fix, we might read garbage, and crash later in
> 
> __skb_complete_tx_timestamp()
>  -> sock_queue_err_skb()
> 
> (These pseudo sockets do not have an error queue either)
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>


Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  Note this bug also exists on net tree for timewait sockets but only
>  in exceptional conditions (routing glitches and IP early demux)
> 
>  drivers/net/tun.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 976aa9704297..b1878faea397 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -858,7 +858,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>  		goto drop;
>  
> -	if (skb->sk) {
> +	if (skb->sk && sk_fullsock(skb->sk)) {
>  		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
>  		sw_tx_timestamp(skb);
>  	}
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
