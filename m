From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] macvlan: proper multicast support
Date: Tue, 5 May 2009 11:00:51 -0700
Message-ID: <20090505110051.51851a77@nehalam>
References: <20090423091425.73ed544c@s6510>
	<49F1D5EF.3020306@trash.net>
	<20090424094808.74d401d8@nehalam>
	<20090427.025634.54725702.davem@davemloft.net>
	<4A003BFD.8050305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49397 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267AbZEESA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 14:00:57 -0400
In-Reply-To: <4A003BFD.8050305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 May 2009 15:15:41 +0200
Patrick McHardy <kaber@trash.net> wrote:

> David Miller wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Fri, 24 Apr 2009 09:48:08 -0700
> > 
> >> When using macvlan's multicast packets don't get properly passed between
> >> macvlan's which should be logically sharing the network.  Any multicast
> >> packet sent on a macvlan should show up lower device and all other macvlan's.
> >> Likewise a multicast packet sent on lower device should be received
> >> by all macvlan's.
> >>
> >> The following is one way to do it; build tested only.
> >>
> >> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> > I definitely want to see what Patrick thinks of this.
> 
>  From a functional POV the patch looks mostly fine to me, it seems
> to simulate the behaviour of a real network accurately to the point
> that you could probably create a loop by bridging two macvlans on
> the same physical network.
> 
> This part looks incorrect however:
> 
> >>  static int macvlan_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >>  {
> >>  	const struct macvlan_dev *vlan = netdev_priv(dev);
> >> +	const struct ethhdr *eth = eth_hdr(skb);
> >>  	unsigned int len = skb->len;
> >>  	int ret;
> >>  
> >>  	skb->dev = vlan->lowerdev;
> >> +	if (is_multicast_ether_addr(eth->h_dest)) {
> >> +		macvlan_broadcast(skb, vlan->port, vlan);
> >> +		macvlan_clone(skb, vlan->lowerdev);
> >> +	}
> >> +
> >>  	ret = dev_queue_xmit(skb);
> >>  
> 
> macvlan_clone() will netif_rx() the packet on the lower dev,
> which means it will get passed back to the macvlan receive
> hook for the same lower device. This will do two things:
> 
> - it will deliver the packet to all other macvlan devices on
>    the same physical device - which is fine but done twice with
>    the manual delivery
> 
> - it will deliver the packet to the originating macvlan device,
>    which is wrong
> 
> The first point is actually a good thing in my opinion, we need
> less special handling and ordering of the reception events is
> automatically correct.
> 
> The delivery to the originating device looks a bit harder, we
> don't know the originating macvlan device when the packet is
> delivered to the receive handler. I can't think of an easy way
> to fix this right now.
> 

Okay, I'll go back and fix that. Also forwarding between
macvlan's is needed if it is to be useful in full container mode.
