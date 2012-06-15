From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [net-next PATCH 01/02] net/ipv4: VTI support rx-path hook in
 xfrm4_mode_tunnel.
Date: Fri, 15 Jun 2012 07:46:36 +0200
Message-ID: <20120615054636.GW27795@secunet.com>
References: <20120614092559.GU27795@secunet.com>
 <766b5544-ace1-44b5-ac14-14d0e7702b4f@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Saurabh Mohan <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59982 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765Ab2FOFql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 01:46:41 -0400
Content-Disposition: inline
In-Reply-To: <766b5544-ace1-44b5-ac14-14d0e7702b4f@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 07:44:11PM -0700, Saurabh Mohan wrote:
> > +
> >  static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
> >  {
> > +	struct xfrm_tunnel *handler;
> >  	int err = -EINVAL;
> >  
> >  	if (XFRM_MODE_SKB_CB(skb)->protocol != IPPROTO_IPIP)
> > @@ -74,6 +142,10 @@ static int xfrm4_mode_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
> >  	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> >  		goto out;
> >  
> > +	/* The handlers do not consume the skb. */
> > +	for_each_input_rcu(rcv_notify_handlers, handler)
> > +		handler->handler(skb);
> 
> I'm not sure if this is the right place to add your handler.
> My understanding of an IPsec tunnel device would be to
> receive the packet first and then do IPsec processing.
> Here it happens the other way arround.
> 
> @SM: The intention is to get the packet post decrypt and post-esp-decap. Just like a GRE tunnel the rx-counters account for the payload and NOT the GRE header.
> 

Well, I think a virtual interface should behave similar
to physical interfaces. And a physical interface has to
receive the packet before it can be processed.

I looked into the old klips IPsec implementation.
They had virtual IPsec interfaces and they did it like 
that, update the statistics and the input device first
and process the packet then.
