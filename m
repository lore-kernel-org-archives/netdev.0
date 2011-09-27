From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: RFS issue: no HW filter for paused stream
Date: Wed, 28 Sep 2011 00:42:48 +0100
Message-ID: <1317166968.2845.45.camel@bwh-desktop>
References: <CAP7N4Kfd9TOPr_V6+R9yVtK80eGWbkAvPE8BStG0+WhvJHaLGg@mail.gmail.com>
	 <CAP7N4Kes9=VdRV8NHvk03SBg5GbohgdbGqKPABCfYbVyzZ+1ng@mail.gmail.com>
	 <CA+mtBx9K8MY+WcFZpQp_85rcf316jrPpNgzqSzgMLzy7TC6eXQ@mail.gmail.com>
	 <1316447572.2764.21.camel@bwh-desktop>
	 <4E783855.4020907@dev.mellanox.co.il>
	 <1316617742.2760.18.camel@bwh-desktop>  <4E7AD1A4.7000308@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, oren@mellanox.co.il,
	liranl@mellanox.co.il, netdev@vger.kernel.org,
	Diego Crupnicoff <Diego@Mellanox.com>
To: Amir Vadai <amirv@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21844 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343Ab1I0Xmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 19:42:51 -0400
In-Reply-To: <4E7AD1A4.7000308@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-09-22 at 09:11 +0300, Amir Vadai wrote:
> Looks good.
> and now the code is much clearer

Does that mean that this change *works* for you?

Ben.

[...]
> > But that means we never move the flow to a new CPU in the non-
> > accelerated case.  So maybe the proper change would be:
> >
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2652,10 +2652,7 @@ static struct rps_dev_flow *
> >   set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
> >   	    struct rps_dev_flow *rflow, u16 next_cpu)
> >   {
> > -	u16 tcpu;
> > -
> > -	tcpu = rflow->cpu = next_cpu;
> > -	if (tcpu != RPS_NO_CPU) {
> > +	if (next_cpu != RPS_NO_CPU) {
> >   #ifdef CONFIG_RFS_ACCEL
> >   		struct netdev_rx_queue *rxqueue;
> >   		struct rps_dev_flow_table *flow_table;
> > @@ -2683,16 +2680,16 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
> >   			goto out;
> >   		old_rflow = rflow;
> >   		rflow =&flow_table->flows[flow_id];
> > -		rflow->cpu = next_cpu;
> >   		rflow->filter = rc;
> >   		if (old_rflow->filter == rflow->filter)
> >   			old_rflow->filter = RPS_NO_FILTER;
> >   	out:
> >   #endif
> >   		rflow->last_qtail =
> > -			per_cpu(softnet_data, tcpu).input_queue_head;
> > +			per_cpu(softnet_data, next_cpu).input_queue_head;
> >   	}
> >
> > +	rflow->cpu = next_cpu;
> >   	return rflow;
> >   }
> >
> > --- END ---
> >

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
