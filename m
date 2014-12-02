From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification until
 after ndo_uninit()
Date: Tue, 2 Dec 2014 10:07:46 +0000
Message-ID: <20141202100746.GA13717@casper.infradead.org>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35654 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbaLBKHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 05:07:51 -0500
Content-Disposition: inline
In-Reply-To: <1417499650-29176-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/14 at 09:54pm, Mahesh Bandewar wrote:
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2220,8 +2220,16 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
>  	return skb->len;
>  }
>  
> -void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
> -		  gfp_t flags)
> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
> +{
> +	struct net *net = dev_net(dev);
> +
> +	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
> +}
> +EXPORT_SYMBOL(rtmsg_ifinfo_send);
> +
> +struct sk_buff *rtmsg_ifinfo(int type, struct net_device *dev,
> +			     unsigned int change, gfp_t flags, bool fill_only)
>  {
>  	struct net *net = dev_net(dev);
>  	struct sk_buff *skb;
> @@ -2239,11 +2247,15 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>  		kfree_skb(skb);
>  		goto errout;
>  	}
> +	if (fill_only)
> +	    return skb;
> +
>  	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
> -	return;
> +	return NULL;
>  errout:
>  	if (err < 0)
>  		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
> +	return NULL;
>  }

I think it would be cleaner to introduce a new function, for example
rtmsg_ifinfo_build_skb() which is called from rtmsg_ifinfo(). The
single caller that requires delayed sending can use the build skb
function directly and then send it off.
