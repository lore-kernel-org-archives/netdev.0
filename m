From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC ipsec-next 4/5] net: Prepare for IPsec GRO
Date: Wed, 4 Jan 2017 14:26:09 +0100
Message-ID: <20170104132609.GZ3541@gauss.secunet.com>
References: <1483518230-6777-1-git-send-email-steffen.klassert@secunet.com>
 <1483518230-6777-5-git-send-email-steffen.klassert@secunet.com>
 <1483533255.4337.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        "Sowmini Varadhan" <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34018 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030405AbdADN0S (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 08:26:18 -0500
Content-Disposition: inline
In-Reply-To: <1483533255.4337.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 04, 2017 at 04:34:15AM -0800, Eric Dumazet wrote:
> On Wed, 2017-01-04 at 09:23 +0100, Steffen Klassert wrote:
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index b53c0cf..a78cd90 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -749,7 +749,10 @@ struct sk_buff {
> >  #ifdef CONFIG_NET_SWITCHDEV
> >  	__u8			offload_fwd_mark:1;
> >  #endif
> > -	/* 2, 4 or 5 bit hole */
> > +#ifdef CONFIG_XFRM_OFFLOAD
> > +	__u8			xfrm_gro:1;
> 
> 
> 
> Arg, yet another skb bit.

I'm not particularly proud of this, but
I've seen no other options to keep this
information across the layers. This is
probably the reason for all these skb bits.

> 
> > +#endif
> > +	/* 1 to 5 bits hole */
> >  
> >  #ifdef CONFIG_NET_SCHED
> >  	__u16			tc_index;	/* traffic control index */
> > @@ -3698,6 +3701,15 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
> >  #endif
> >  }
> >  
> 
> >  
> > @@ -4843,7 +4853,12 @@ static int process_backlog(struct napi_struct *napi, int quota)
> >  
> >  		while ((skb = __skb_dequeue(&sd->process_queue))) {
> >  			rcu_read_lock();
> > -			__netif_receive_skb(skb);
> > +
> > +			if (skb_xfrm_gro(skb))
> > +				napi_gro_receive(napi, skb);
> > +			else
> > +				__netif_receive_skb(skb);
> > +
> 
> 
> But napi here is device independent. It is a fake NAPI, per cpu.
> 
> I am not sure of the various implications of using it at this point,
> this looks quite dangerous/invasive to me, compared to the gro_cells
> infra which was designed to have no impact on core code paths.
> 
> To me, the caller should call napi_gro_receive() skb, instead of letting
> core networking stack add this extra skb bit and extra conditional.

I had a quick look at the gro_cells, it looks like I could avoid
at least the extra codition with this.

I'll see if I get it to work with gro_cells, thanks for pointing
to it!
