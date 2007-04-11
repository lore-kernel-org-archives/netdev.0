From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [GIT PULL] bridge update for 2.6.22
Date: Wed, 11 Apr 2007 10:05:05 -0700
Message-ID: <20070411100505.0b4fb14e@freekitty>
References: <20070409135552.5eee2bc8@dxpl.pdx.osdl.net>
	<461C6FF2.2000700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym@pandora.be>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52700 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbXDKRFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 13:05:14 -0400
In-Reply-To: <461C6FF2.2000700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Apr 2007 07:19:46 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> > index a260679..8a55276 100644
> > --- a/net/bridge/br_input.c
> > +++ b/net/bridge/br_input.c
> >  	if (unlikely(is_link_local(dest))) {
> >  		skb->pkt_type = PACKET_HOST;
> > -		return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > -			       NULL, br_handle_local_finish) != 0;
> > +
> > +		return (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > +				NULL, br_handle_local_finish) == 0) ? skb : NULL;
> >  	}
> 
> 
> I Just want to note, this is broken in multiple ways (not by this
> patch, it was already broken before). When a packet is stolen or
> queued, NF_HOOK will return 0, but the packet is not owned by the
> caller anymore, so we have a potential use-after-free. Additionally
> the okfn owns the skb and needs to make sure it continues its path,
> which br_handle_local_finish doesn't do, resulting in leaks and
> broken queueing. The fix looks quite ugly, bf_handle_local_finish
> would need to pass the skb back to netif_receive_skb just after the
> handle_bridge call.

That wouldn't work because it would still think the packet is coming
in on a bridge port and recurse into the bridge hook.  For normal
local traffic the bridge input path changes the device from originating
device to the bridge pseudo-device. That won't work for this case
because then all packets would look as if they came from
bridge pseudo-device which confuse STP and other protocols.

Maybe this whole link local stuff can be reworked.  Originally
it went direct to STP code, but this meant we dropped all other
types. The user level RSTP code (not done yet), originally was
going to use LLC, but it turned out to be crap so it will use AF_PACKET bound
to the 802_2 type, so it doesn't really care if all packets arrive on
the bridge pseudo-device. The kernel STP code 
can be fixed to look at skb->orig_dev instead.

 
> All this is not a problem for mainline currently since ebtables
> doesn't support QUEUE yet, but since its mentioned on the TODO
> list and in any case is incorrect use of NF_HOOK it feels worth
> mentioning.
> 


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
