From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 4/5] net: Prepare for IPsec GRO
Date: Mon, 9 Jan 2017 10:59:35 +0100
Message-ID: <20170109095935.GD3541@gauss.secunet.com>
References: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
 <1483518230-6777-5-git-send-email-steffen.klassert@secunet.com>
 <1483533255.4337.16.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170104132609.GZ3541@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37662 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdAIJ7o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 04:59:44 -0500
Content-Disposition: inline
In-Reply-To: <20170104132609.GZ3541@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 02:26:09PM +0100, Steffen Klassert wrote:
> On Wed, Jan 04, 2017 at 04:34:15AM -0800, Eric Dumazet wrote:
> > >  
> > > @@ -4843,7 +4853,12 @@ static int process_backlog(struct napi_struct *napi, int quota)
> > >  
> > >  		while ((skb = __skb_dequeue(&sd->process_queue))) {
> > >  			rcu_read_lock();
> > > -			__netif_receive_skb(skb);
> > > +
> > > +			if (skb_xfrm_gro(skb))
> > > +				napi_gro_receive(napi, skb);
> > > +			else
> > > +				__netif_receive_skb(skb);
> > > +
> > 
> > 
> > But napi here is device independent. It is a fake NAPI, per cpu.
> > 
> > I am not sure of the various implications of using it at this point,
> > this looks quite dangerous/invasive to me, compared to the gro_cells
> > infra which was designed to have no impact on core code paths.
> > 
> > To me, the caller should call napi_gro_receive() skb, instead of letting
> > core networking stack add this extra skb bit and extra conditional.
> 
> I had a quick look at the gro_cells, it looks like I could avoid
> at least the extra codition with this.

On a second view, it does not look so promising. I don't
have a netdevice where I can hang this off. Looks like I
need such a fake per cpu NAPI as the backlog is. I could
create my own one, then I would not have to add this
condition to core networking.
