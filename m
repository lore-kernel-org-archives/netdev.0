From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Wed, 08 Jul 2015 19:39:58 +0200
Message-ID: <1436377198.3846.46.camel@stressinduktion.org>
References: <20150708163032.5b5df2ec@vostro>
	 <1436370752.3846.36.camel@stressinduktion.org>
	 <20150708191751.3fc42725@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:43938 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758790AbbGHRkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 13:40:02 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6D27920B82
	for <netdev@vger.kernel.org>; Wed,  8 Jul 2015 13:40:01 -0400 (EDT)
In-Reply-To: <20150708191751.3fc42725@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, 2015-07-08 at 19:17 +0300, Timo Teras wrote:
> On Wed, 08 Jul 2015 17:52:32 +0200
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > On Wed, 2015-07-08 at 16:30 +0300, Timo Teras wrote:
> > > This probably is due to the way how the xfrm+gre work together. On
> > > first packet, the gre tunnel driver updates pmtu for the inner 
> > > flow,
> > > which is expected to be honored always. And if the 'ttl' value is
> > > set for gre tunnel, no re-fragmentation is allowed as the inner 
> > > flow
> > > should know better. This does how the side effect that if the very
> > > first packet is large, it'll be dropped to 'learn' the pmtu. 
> > > 
> > > It's probably not possible to detect this kind of target easily, 
> > > as 
> > > the xfrm can be applied or not even on per inner target IP basis 
> > > (as
> > > then tunnel destination IP can be dynamic for nbma tunnels).
> > 
> > I am currently not sure if we actually have resolved the xfrm path 
> > at
> > the time we enter ip_forward, I actually thought we do. In this case
> > we should be able to use skb_dst->dst->path->header_len and 
> > substract
> > it before using it to fragment the packets. I hope it is so easy... 
> > :)
> 
> It is not. The inner skb just knows that it's going from ethX -> greX.
> And that's what contains the path MTU, and that's what ip_forward will
> use.
> 
> Only on gre_xmit it is resolved where the tunnel packet goes, and the
> xfrm resolved. Thus the update_pmtu work fully internally here.

Oh, yes, sorry, gre is not xfrm and doesn't propagate the information
towards the first routing lookup.

> > I would actually avoid telling anyone to enable using the path mtu
> > information in forwarding ever again.
> 
> The problem here is that pmtu framework is used internally to relay 
> the
> trusted stacking pmtu in addition to the from-the-wire learned pmtu.

Yes, and it is not easy to propagate this trusted state across all the
different mtu storage location we have (metrics, fnhe, etc...). I don't
know if it is worth the effort.

> > > So I wonder if ip_gre driver can workaround this somehow, by e.g.
> > > refragmenting if necessary. Or if we just should update the 
> > > sysctl's
> > > help text to say that this another scenario where it needs to be
> > > turned on.
> > 
> > If above idea does not work, we could simply add an option to gre
> > driver to set skb->ignore_df, but I don't like that much.
> 
> This is not acceptable. The gre driver has two operating modes: DF and
> non-DF mode (which is triggered by 'ttl inherit' or 'ttl <number>'
> option on tunnel creation). The DF mode intentionally sets DF on all
> tunnel packets so the pmtu is learned and relayed up the stack. In
> non-DF mode the tunnel packets DF is derived from encapsulated packet.
> 
> Basically this info could be used. If the target is gre1 in DF mode, 
> we
> should be trusting the pmtu. Otherwise the existing internal mechanism
> breaks.
> 
> Thoughts?

At least we know which interface the packet would leave. Should we
override this behavior on a per-interface basis?

(Although I am in favor of admins just correcting the mtu by hand and
documenting this as you proposed earlier. I really don't know if it is
worth the effort to propagate those information.).

Thanks,
Hannes
