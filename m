From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] net: ieee802154: fix net_device reference release too
 early
Date: Thu, 18 May 2017 15:14:00 +0200
Message-ID: <20170518131359.GA3311@work>
References: <1495093807-11000-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aar@pengutronix.de, stefan@osg.samsung.com, davem@davemloft.net,
        linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: linzhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:40614
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755473AbdERNOM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 09:14:12 -0400
Content-Disposition: inline
In-Reply-To: <1495093807-11000-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On Thu, 2017-05-18 at 15:50, linzhang wrote:
> This patch fixes the kernel oops when release net_device reference in 
> advance. In function raw_sendmsg(i think the dgram_sendmsg has the same 
> problem), there is a race condition between dev_put and dev_queue_xmit
> when the device is gong that maybe lead to dev_queue_ximt to see
> an illegal net_device pointer.
> 

You have a test case to reproduce this oops? I fear I have not seen
one.

> So i think that dev_put should be behind of the dev_queue_xmit.
> 
> Also, explicit set skb->sk is needless, sock_alloc_send_skb is
> already set it.

You could have put this fixup in a different patch.

> Signed-off-by: linzhang <xiaolou4617@gmail.com>

This looks more like a username instead of a real name. If you have Lin
Zhang as you English real name that would be better here. :)

> ---
>  net/ieee802154/socket.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ieee802154/socket.c b/net/ieee802154/socket.c
> index eedba76..a60658c 100644
> --- a/net/ieee802154/socket.c
> +++ b/net/ieee802154/socket.c
> @@ -301,15 +301,14 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  		goto out_skb;
>  
>  	skb->dev = dev;
> -	skb->sk  = sk;
>  	skb->protocol = htons(ETH_P_IEEE802154);
>  
> -	dev_put(dev);
> -
>  	err = dev_queue_xmit(skb);
>  	if (err > 0)
>  		err = net_xmit_errno(err);
>  
> +	dev_put(dev);
> +
>  	return err ?: size;
>  
>  out_skb:
> @@ -690,15 +689,14 @@ static int dgram_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
>  		goto out_skb;
>  
>  	skb->dev = dev;
> -	skb->sk  = sk;
>  	skb->protocol = htons(ETH_P_IEEE802154);
>  
> -	dev_put(dev);
> -
>  	err = dev_queue_xmit(skb);
>  	if (err > 0)
>  		err = net_xmit_errno(err);
>  
> +	dev_put(dev);
> +
>  	return err ?: size;

Going to give this a test ride here now.

regards
Stefan Schmidt
