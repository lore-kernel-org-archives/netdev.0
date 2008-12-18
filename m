From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] ppp: fix segfaults introduced by netdev_priv changes
Date: Thu, 18 Dec 2008 10:15:28 +0800
Message-ID: <4949B240.7060102@cn.fujitsu.com>
References: <200812172202.mBHM2GHi012456@bert.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59413 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbYLRCPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 21:15:43 -0500
In-Reply-To: <200812172202.mBHM2GHi012456@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman said the following on 2008-12-18 6:02:
> This patch fixes a segfault in ppp_shutdown_interface() and
> ppp_destroy_interface() when a PPP connection is closed. I bisected
> the problem to the following commit:
> 
>   commit c8019bf3aff653cceb64f66489fc299ee5957b57
>   Author: Wang Chen <wangchen@cn.fujitsu.com>
>   Date:   Thu Nov 20 04:24:17 2008 -0800
> 
>     netdevice ppp: Convert directly reference of netdev->priv
>     
>     1. Use netdev_priv(dev) to replace dev->priv.
>     2. Alloc netdev's private data by alloc_netdev().
>     
>     Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 

Yes. My bad.
I should cc my previous patch to you ;)

>  static void ppp_shutdown_interface(struct ppp *ppp)
>  {
> -	struct net_device *dev;
> -
>  	mutex_lock(&all_ppp_mutex);
> -	ppp_lock(ppp);
> -	dev = ppp->dev;
> -	ppp->dev = NULL;
> -	ppp_unlock(ppp);
>  	/* This will call dev_close() for us. */
> -	if (dev) {
> -		unregister_netdev(dev);
> -		free_netdev(dev);
> -	}
> +	ppp_lock(ppp);
> +	if (!ppp->closing) {
> +		ppp->closing = 1;
> +		ppp_unlock(ppp);
> +		unregister_netdev(ppp->dev);
> +	} else
> +		ppp_unlock(ppp);
> +
>  	cardmap_set(&all_ppp_units, ppp->file.index, NULL);
>  	ppp->file.dead = 1;
>  	ppp->owner = NULL;
> @@ -2554,7 +2552,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
>  	if (ppp->xmit_pending)
>  		kfree_skb(ppp->xmit_pending);
>  
> -	kfree(ppp);
> +	free_netdev(ppp->dev);
>  }
>  

I have no comment on these changes, but
there is a path that calls only ppp_destroy_interface() no
ppp_shutdown_interface().
it's:
ppp_unregister_channel
    --->ppp_disconnect_channel()
        ---> ppp_destroy_interface()
>  /*
> @@ -2616,7 +2614,7 @@ ppp_connect_channel(struct channel *pch, int unit)
>  	if (pch->file.hdrlen > ppp->file.hdrlen)
>  		ppp->file.hdrlen = pch->file.hdrlen;
>  	hdrlen = pch->file.hdrlen + 2;	/* for protocol bytes */
> -	if (ppp->dev && hdrlen > ppp->dev->hard_header_len)
> +	if (hdrlen > ppp->dev->hard_header_len)
>  		ppp->dev->hard_header_len = hdrlen;
>  	list_add_tail(&pch->clist, &ppp->channels);
>  	++ppp->n_channels;

I don't understand this change.
Do you mean that in this place, ppp->dev will never be NULL?

B.R
Wang Chen

