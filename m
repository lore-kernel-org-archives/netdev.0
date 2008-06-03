From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 14:43:50 -0700
Message-ID: <20080603144350.3263542c@extreme>
References: <20080603132106.GA3256@midget.suse.cz>
	<20080603094604.6a7dfe7d@extreme>
	<20080603193227.GA4050@midget.suse.cz>
	<20080603131326.1f70915e@extreme>
	<18105.1212528128@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52605 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352AbYFCVoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 17:44:17 -0400
In-Reply-To: <18105.1212528128@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jun 2008 14:22:08 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> 
> >On Tue, 3 Jun 2008 21:32:27 +0200
> >Jiri Bohac <jbohac@suse.cz> wrote:
> [...]
> >> But I think I found a much nicer fix for the problem:
> >> 
> >> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> >> --- a/net/bridge/br_input.c
> >> +++ b/net/bridge/br_input.c
> >> @@ -136,6 +136,10 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
> >>  		if (skb->protocol == htons(ETH_P_PAUSE))
> >>  			goto drop;
> >>  
> >> +		/* Don't touch SLOW frames (LACP, etc.) */
> >> +		if (skb->protocol == htons(ETH_P_SLOW))
> >> +			return skb;
> >> +
> >>  		/* Process STP BPDU's through normal netif_receive_skb() path */
> >>  		if (p->br->stp_enabled != BR_NO_STP) {
> >>  			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> >> 
> >> The LACP frames always have the link-local destination MAC
> >> address and so they are not handled by the bridge anyway. They
> >> are only dropped, unless STP is turned on. So let's just not drop
> >> the SLOW packets. Does this look better?
> >> 
> >
> >Better, but still have a couple of questions:
> >1) Do you want to processing frames when bridge port is in blocking
> >   state (because STP detected a loop)?
> 
> 	I believe so.  If I'm reading correctly, the layout is something
> like:
> 
> bridge -> bond0 -> [ eth0, eth1, etc ]
> 
> 	so bonding needs to see the LACPDUs in order to decide which
> subset of the slaves (eth0, eth1, etc) should be active and which should
> not.  That, in turn, may affect the topology of the network.  In other
> words, the presence or absence of a loop is determined by the set of
> interfaces (or, really, the location of the peer of that set) made
> active by link aggregation.  For 802.3ad, the set of active slaves
> (active aggregator) will always connect to the same peer, but link
> failures could move the active aggregator from one peer to a different
> peer.
> 
> 	This seems to agree with my (brief) examination of standards and
> documentation: 802.3ad doesn't really say much about STP, 802.1d 6.5.1
> discusses link aggregation a bit, in particular:
> 
> a) For a MAC entity that contains a Link Aggregation sublayer, the value
> of MAC_Enabled is directly determined by the value of the aAggAdminState
> attribute (30.7.1.13 in IEEE Std 802.3-2002), and the value of
> MAC_Operational is directly determined by the value of the aAggOperState
> attribute (30.7.1.13 in IEEE Std 802.3).
> 
> 	suggests that the aggregation is treated as a unit (I'm not that
> familiar with 802.1d, so I could be misreading it here).
> 
> 	Lastly, Cisco's Etherchannel implementation treats a LACP
> aggregation as a single bridge port.
> 
> 	Thoughts?
> 

I think the LACP frames need to be filterable. Otherwise, you open
yourself up to problems with spoofed frames. See the security attack
on STP from a couple of years ago.

