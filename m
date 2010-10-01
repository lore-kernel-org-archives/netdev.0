From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next2.6] net: dynamic ingress_queue allocation
Date: Fri, 01 Oct 2010 07:45:06 -0400
Message-ID: <1285933506.3553.176.camel@bigi>
References: <1285689517.3154.76.camel@edumazet-laptop>
	 <20100928180447.GA1880@del.dom.local>  <1285757817.3561.2.camel@bigi>
	 <1285887509.2705.33.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:65238 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756584Ab0JALpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 07:45:11 -0400
Received: by qyk9 with SMTP id 9so829809qyk.19
        for <netdev@vger.kernel.org>; Fri, 01 Oct 2010 04:45:10 -0700 (PDT)
In-Reply-To: <1285887509.2705.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-10-01 at 00:58 +0200, Eric Dumazet wrote:
> Hi Jamal
> 
> Here is the dynamic allocation I promised. I lightly tested it, could
> you review it please ?
> Thanks !
> 
> [PATCH net-next2.6] net: dynamic ingress_queue allocation
> 
> ingress being not used very much, and net_device->ingress_queue being
> quite a big object (128 or 256 bytes), use a dynamic allocation if
> needed (tc qdisc add dev eth0 ingress ...)

I agree with the principle that it is valuable in making it dynamic for
people who dont want it; but, but (like my kid would say, sniff, sniff)
you are making me sad saying it is not used very much ;-> It is used
very much in my world. My friend Jarek uses it;->


> +#ifdef CONFIG_NET_CLS_ACT

I think appropriately this should be NET_SCH_INGRESS (everywhere else as
well).

> +static inline struct netdev_queue *dev_ingress_queue(struct net_device *dev)
> +{
> +#ifdef CONFIG_NET_CLS_ACT
> +	return dev->ingress_queue;
> +#else
> +	return NULL;
> +#endif

Above, if you just returned dev->ingress_queue wouldnt it always be 
NULL if it was not allocated?


> @@ -2737,7 +2734,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
>  					 struct packet_type **pt_prev,
>  					 int *ret, struct net_device *orig_dev)
>  {
> -	if (skb->dev->ingress_queue.qdisc == &noop_qdisc)
> +	struct netdev_queue *rxq = dev_ingress_queue(skb->dev);
> +
> +	if (!rxq || rxq->qdisc == &noop_qdisc)
>  		goto out;

I stared at above a little longer since this is the only fast path
affected; is it a few more cycles now for people who love ingress?

> @@ -690,6 +693,8 @@ static int qdisc_graft(struct net_device *dev, struct Qdisc *parent,
>  		    (new && new->flags & TCQ_F_INGRESS)) {
>  			num_q = 1;
>  			ingress = 1;
> +			if (!dev_ingress_queue(dev))
> +				return -ENOENT;
>  		}
>  

The above looks clever but worries me because it changes the old flow.
If you have time,  the following tests will alleviate my fears

1) compile support for ingress and add/delete ingress qdisc
2) Dont compile support and add/delete ingress qdisc
3) Compile ingress as a module and add/delete ingress qdisc


Other than that excellent work Eric. And you can add my
Acked/reviewed-by etc.

BTW, did i say i like your per-cpu stats stuff? It applies nicely to
qdiscs, actions etc ;->

cheers,
jamal

