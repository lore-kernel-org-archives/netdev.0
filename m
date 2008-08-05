From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 2/2 respin] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Tue, 5 Aug 2008 06:34:23 +0000
Message-ID: <20080805063423.GA4407@ff.dom.local>
References: <20080804062813.GA4570@ff.dom.local> <20080803.234200.193697269.davem@davemloft.net> <20080804085734.GB12927@ff.dom.local> <20080804.231449.199557608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:18662 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbYHEG27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 02:28:59 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1763094wri.5
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 23:28:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080804.231449.199557608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 11:14:49PM -0700, David Miller wrote:
...
> After applying this I noticed that dst_input()'s usage of
> plain NET_XMIT_BYPASS was bogus, and after killing that
> there are no more references.
> 
> Thus I added the following commit.
> 
> commit cc6533e98a7f3cb7fce9d740da49195c7aa523a4
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Aug 4 23:04:08 2008 -0700
> 
>     net: Kill plain NET_XMIT_BYPASS.
>     
>     dst_input() was doing something completely absurd, looping
>     on skb->dst->input() if NET_XMIT_BYPASS was seen, but these
>     functions never return such an error.
>     
>     And as a result plain ole' NET_XMIT_BYPASS has no more
>     references and can be completely killed off.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index abbf5d5..488c56e 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -61,9 +61,6 @@ struct wireless_dev;
>  #define NET_XMIT_DROP		1	/* skb dropped			*/
>  #define NET_XMIT_CN		2	/* congestion notification	*/
>  #define NET_XMIT_POLICED	3	/* skb is shot by police	*/
> -#define NET_XMIT_BYPASS		4	/* packet does not leave via dequeue;
> -					   (TC use only - dev_queue_xmit
> -					   returns this as NET_XMIT_SUCCESS) */
>  #define NET_XMIT_MASK		0xFFFF	/* qdisc flags in net/sch_generic.h */
>  
>  /* Backlog congestion levels */
> diff --git a/include/net/dst.h b/include/net/dst.h
> index c5c318a..8a8b71e 100644
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -252,17 +252,7 @@ static inline int dst_output(struct sk_buff *skb)
>  /* Input packet from network to transport.  */
>  static inline int dst_input(struct sk_buff *skb)
>  {
> -	int err;
> -
> -	for (;;) {
> -		err = skb->dst->input(skb);
> -
> -		if (likely(err == 0))
> -			return err;
> -		/* Oh, Jamal... Seems, I will not forgive you this mess. :-) */
> -		if (unlikely(err != NET_XMIT_BYPASS))
> -			return err;
> -	}
> +	return skb->dst->input(skb);
>  }

NAK! You're not allowed to remove such a great comment!

BTW, I hope you've checked this enough, becouse I've some doubts
here: this NET_XMIT_BYPASS looks wrong here but maybe it was meant
to be some NET_RX_ code, like NET_RX_CN_HIGH?

Jarek P.
