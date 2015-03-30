From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: RE: [RFC] Handling device free after a packet is passed to the network stack
Date: Mon, 30 Mar 2015 08:19:47 -0600
Message-ID: <004401d06af4$94620280$bd260780$@codeaurora.org>
References: <f3c7672edb978d520f12d72cb41d1e4d.squirrel@www.codeaurora.org> <1427510968.25985.159.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "'Eric Dumazet'" <eric.dumazet@gmail.com>,
	<subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:53738 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751923AbbC3OTu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 10:19:50 -0400
In-Reply-To: <1427510968.25985.159.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Eric Dumazet
> Sent: Friday, March 27, 2015 8:49 PM
> To: subashab@codeaurora.org
> Cc: netdev@vger.kernel.org
> Subject: Re: [RFC] Handling device free after a packet is passed to the
> network stack
> 
> On Fri, 2015-03-27 at 19:57 +0000, subashab@codeaurora.org wrote:
> > We have been coming across a couple of scenarios where the device is
> > freed and the corresponding packets which were already queued up the
> > stack encounter crashes when they find that contents of skb->dev are
> > no longer valid.
> >
> > Specifically, we have observed an instance where a cpu hotplug occurs
> > along with the network driver module unloading. When the packets are
> > being queued up the stack using netif_rx_ni from dev_cpu_callback,
> > get_rps_cpus crashes as it encounters invalid data at skb->dev since
> > it would have been freed.
> >
> > We would like to know if the kernel provides some mechanisms to
> > safeguard against such scenarios.
> 
> This is supposed to be handled in flush_backlog() (net/core/dev.c)

It looks like this only takes care of packets in the softnet_data queues (or am I missing something). Wouldn't we run into similar issues if the packet were stuck in, for example, TCP OFO socket queue (not sure if anything tries to access skb->dev after that)? Or perhaps some other queue which may later try to dereference skb->dev. 
 

It seems to me that the only way to be absolutely sure that there is no reference on this net_device would be to have the drivers dev_hold() before earch netif_rx/netif_rx_ni/netif_receive_skb; and then later have __kfree_skb() do a dev_put().

Of course, this approach has a number of issues:
- 2 extra operations per packet
- Anything holding onto an SKB can prevent a net_device from deregistering/freeing
- requires skbs to have a valid dev before they can be freed (or we simply null check this field in __kfree_skb())

> Maybe you hit some race condition in on_each_cpu().
> 
> Really, I do not think we have tested such stress conditions ever.
> 
> cpu hotplug was very unstable 2 years ago (last time I tried it, this
> was constantly failing outside of networking land)
> 
> I would try following patch, although I am not sure what would prevent
> dev_cpu_callback() being called too late.
> 
> diff --git a/net/core/dev.c b/net/core/dev.c index
> a0408d497dae04e7caa145f05c915b058aa2d356..fa74887adfe10709bce55ccf1e34d6
> 5c6b7a8fba 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7149,11 +7149,17 @@ static int dev_cpu_callback(struct
> notifier_block *nfb,
> 
>  	/* Process offline CPU's input_pkt_queue */
>  	while ((skb = __skb_dequeue(&oldsd->process_queue))) {
> -		netif_rx_ni(skb);
> +		if (skb->dev->reg_state != NETREG_REGISTERED)
> +			kfree_skb(skb);
> +		else
> +			netif_rx_ni(skb);
>  		input_queue_head_incr(oldsd);
>  	}
>  	while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
> -		netif_rx_ni(skb);
> +		if (skb->dev->reg_state != NETREG_REGISTERED)
> +			kfree_skb(skb);
> +		else
> +			netif_rx_ni(skb);
>  		input_queue_head_incr(oldsd);
>  	}
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
