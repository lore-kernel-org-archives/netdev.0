From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Mon, 10 Apr 2017 15:28:26 -0400
Message-ID: <20170410152826.580db268@plumbers-lap.home.lan>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:35355 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751514AbdDJT2b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 15:28:31 -0400
Received: by mail-qt0-f182.google.com with SMTP id n46so40061806qta.2
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 12:28:31 -0700 (PDT)
In-Reply-To: <20170409.133528.660876505013192371.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Apr 2017 13:35:28 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> This provides a generic non-optimized XDP implementation when the
> device driver does not provide an optimized one.
> 
> It is arguable that perhaps I should have required something like
> this as part of the initial XDP feature merge.
> 
> I believe this is critical for two reasons:
> 
> 1) Accessibility.  More people can play with XDP with less
>    dependencies.  Yes I know we have XDP support in virtio_net, but
>    that just creates another depedency for learning how to use this
>    facility.
> 
>    I wrote this to make life easier for the XDP newbies.
> 
> 2) As a model for what the expected semantics are.  If there is a pure
>    generic core implementation, it serves as a semantic example for
>    driver folks adding XDP support.
> 
> This is just a rough draft and is untested.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Agreed, XDP really needs this

> v2:
>  - Add some "fall through" comments in switch statements based
>    upon feedback from Andrew Lunn
>  - Use RCU for generic xdp_prog, thanks to Johannes Berg.
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cc07c3b..f8ff49c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1892,6 +1892,7 @@ struct net_device {
>  	struct lock_class_key	*qdisc_tx_busylock;
>  	struct lock_class_key	*qdisc_running_key;
>  	bool			proto_down;
> +	struct bpf_prog __rcu	*xdp_prog;
>  };
>  #define to_net_dev(d) container_of(d, struct net_device, dev)
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7efb417..ad6de2d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c

...
 
> +	if (static_key_false(&generic_xdp_needed)) {
> +		struct bpf_prog *xdp_prog = rcu_dereference(skb->dev->xdp_prog);
> +
> +		if (xdp_prog) {
> +			u32 act = netif_receive_generic_xdp(skb, xdp_prog);
> +
> +			if (act != XDP_PASS) {
> +				rcu_read_unlock();
> +				if (act == XDP_TX)
> +					dev_queue_xmit(skb);
> +				return NET_RX_DROP;
> +			}

Wouldn't it be cleaner if XDP returned an enumerated type and a
switch was used? Safer than allowing arbitrary int.
