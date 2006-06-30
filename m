From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 17:09:27 -0400
Message-ID: <1151701767.5270.289.camel@jzny2>
References: <1151623394.8922.27.camel@jzny2>
	 <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2>
	 <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2>
	 <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2>
	 <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
	 <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:32433 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932448AbWF3VJa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 17:09:30 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwQF5-0003vW-BP
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 17:09:35 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630171348.GI14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I think found the last patch you posted, comments below (I have to
run off soon):

On Fri, 2006-30-06 at 19:13 +0200, Thomas Graf wrote:

> There you go, leaves ifb broken as-is, at least prevents it
> from crashing randomly when the input_dev disappears.
> 

I hope the above comment does show up in the logs ;->

> [NET]: Use interface index to keep input device information
> 

> ===================================================================
> --- net-2.6.git.orig/include/net/pkt_cls.h
> +++ net-2.6.git/include/net/pkt_cls.h
> @@ -352,14 +352,19 @@ tcf_change_indev(struct tcf_proto *tp, c
>  static inline int
>  tcf_match_indev(struct sk_buff *skb, char *indev)
>  {
> +	int ret = 1;
> +
>  	if (indev[0]) {
> -		if  (!skb->input_dev)
> -			return 0;
> -		if (strcmp(indev, skb->input_dev->name))
> +		struct net_device *dev;
> +
> +		dev = dev_get_by_index(skb->iif);
> +		if  (!dev)
>  			return 0;
> +		ret = !strcmp(indev, dev->name);
> +		dev_put(dev);
>  	}
>  

[..]

> Index: net-2.6.git/drivers/net/ifb.c
> ===================================================================
> --- net-2.6.git.orig/drivers/net/ifb.c
> +++ net-2.6.git/drivers/net/ifb.c
> @@ -158,19 +158,23 @@ static int ifb_xmit(struct sk_buff *skb,
>  	stats->tx_packets++;
>  	stats->tx_bytes+=skb->len;
>  
> -	if (!from || !skb->input_dev) {
> +	if (!from || !skb->iif) {

Can you have something similar to what you did in
tcf_match_indev above?

i.e grab dev by skb->iif so as to increment refcount - if it doesnt
exist it becomes equivalent to !skb->input_dev and if it exists you drop
the ref inside the else below after changing input_dev 

>  		dev_kfree_skb(skb);
>  		stats->rx_dropped++;
>  		return ret;
>  	} else {
> +		struct net_device *iif;
>  		/* 
>  		 * note we could be going
>  		 * ingress -> egress or
>  		 * egress -> ingress
>  		*/
> -		skb->dev = skb->input_dev;
> -		skb->input_dev = dev;
> +		iif = __dev_get_by_index(skb->iif);
> +		if (!iif)
> +			goto dropped;
> +		skb->dev = iif;
> +		skb->iif = dev->ifindex;
>  		if (from & AT_INGRESS) {
>  			skb_pull(skb, skb->dev->hard_header_len);
>  		} else {
> -

cheers,
jamal

