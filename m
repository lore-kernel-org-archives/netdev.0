From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix vlan_gro_frags vs netpoll and bonding paths
Date: Sat, 28 Aug 2010 11:44:33 +0200
Message-ID: <20100828094433.GA3110@del.dom.local>
References: <20100827205042.GA13844@del.dom.local>
 <20100828001337.GA1955@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61042 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab0H1Joj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 05:44:39 -0400
Received: by fxm13 with SMTP id 13so2453364fxm.19
        for <netdev@vger.kernel.org>; Sat, 28 Aug 2010 02:44:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100828001337.GA1955@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 28, 2010 at 08:13:37AM +0800, Herbert Xu wrote:
> On Fri, Aug 27, 2010 at 10:50:42PM +0200, Jarek Poplawski wrote:
> > After positive netpoll_rx_on() check in vlan_gro_receive() there is
> > skipped part of the "common" GRO_NORMAL path, especially "pull:" in
> > dev_gro_receive(), where at least eth header should be copied for
> > entirely paged skbs. So, eth_type_trans() can read zeroed header only.
> 
> Right, thanks for catching this.
> 
> > diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> > index 01ddb04..58289fe 100644
> > --- a/net/8021q/vlan_core.c
> > +++ b/net/8021q/vlan_core.c
> > @@ -139,13 +139,19 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
> >  	if (!skb)
> >  		return GRO_DROP;
> >  
> > -	if (netpoll_rx_on(skb)) {
> > -		skb->protocol = eth_type_trans(skb, skb->dev);
> > +	/*
> > +	 * Complete the eth header here, mainly for skb_bond_should_drop(),
> > +	 * and for netpoll_rx_on() btw.
> > +	 */
> > +	skb_gro_pull_in(skb);
> > +	skb->protocol = eth_type_trans(skb, skb->dev);
> > +	skb_gro_pull(skb, -ETH_HLEN);
> 
> But this code should go into the netpoll (i.e., slow-path) case
> only so as not to impede performance.

I'm not sure I can understand. What about skb_bond_should_drop()
mentioned in the comments? IMHO we have to impede performance a bit
(and treat it similarly to non-fragmented path) just to fix it, and
consider optimization of this bonding call later.

> 
> Also, we need to fix this for the non-VLAN case as well.

But the only other non-VLAN case I know was fixed already...

Cheers,
Jarek P.
