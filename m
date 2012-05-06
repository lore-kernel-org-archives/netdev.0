From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 7/9] net: add skb_orphan_frags to copy aside frags with
 destructors
Date: Sun, 6 May 2012 16:54:17 +0300
Message-ID: <20120506135416.GA29007@redhat.com>
References: <1336056915.20716.96.camel@zakaz.uk.xensource.com>
 <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5390 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751537Ab2EFNyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2012 09:54:18 -0400
Content-Disposition: inline
In-Reply-To: <1336056971-7839-7-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 03:56:09PM +0100, Ian Campbell wrote:
> This should be used by drivers which need to hold on to an skb for an extended
> (perhaps unbounded) period of time. e.g. the tun driver which relies on
> userspace consuming the skb.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: mst@redhat.com
> ---
>  drivers/net/tun.c      |    1 +
>  include/linux/skbuff.h |   11 ++++++++
>  net/core/skbuff.c      |   68 ++++++++++++++++++++++++++++++++++-------------
>  3 files changed, 61 insertions(+), 19 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index bb8c72c..b53e04e 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -415,6 +415,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
>  	/* Orphan the skb - required as we might hang on to it
>  	 * for indefinite time. */
>  	skb_orphan(skb);
> +	skb_orphan_frags(skb, GFP_KERNEL);
>  
>  	/* Enqueue packet */
>  	skb_queue_tail(&tun->socket.sk->sk_receive_queue, skb);


BTW, didn't notice at the moment but there seem to be
a couple of other problems:

1. this is using GFP_KERNEL on xmit path.
2. And it's not just a question of passing in GFP_ATOMIC:
return status needs to be checked.
3. Scanning all frags just in case one of them has
a descructor also won't help performace :(

-- 
MST
