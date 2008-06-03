From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: PATCH: fix bridged 802.3ad bonding
Date: Tue, 3 Jun 2008 23:20:33 +0200
Message-ID: <20080603212033.GA2990@midget.suse.cz>
References: <20080603132106.GA3256@midget.suse.cz> <20080603094604.6a7dfe7d@extreme> <20080603193227.GA4050@midget.suse.cz> <20080603131326.1f70915e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:57800 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752267AbYFCVUe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 17:20:34 -0400
Content-Disposition: inline
In-Reply-To: <20080603131326.1f70915e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:13:26PM -0700, Stephen Hemminger wrote:
> On Tue, 3 Jun 2008 21:32:27 +0200
> Jiri Bohac <jbohac@suse.cz> wrote:

> > diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> > --- a/net/bridge/br_input.c
> > +++ b/net/bridge/br_input.c
> > @@ -136,6 +136,10 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
> >  		if (skb->protocol == htons(ETH_P_PAUSE))
> >  			goto drop;
> >  
> > +		/* Don't touch SLOW frames (LACP, etc.) */
> > +		if (skb->protocol == htons(ETH_P_SLOW))
> > +			return skb;
> > +
> >  		/* Process STP BPDU's through normal netif_receive_skb() path */
> >  		if (p->br->stp_enabled != BR_NO_STP) {
> >  			if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
> > 
> > The LACP frames always have the link-local destination MAC
> > address and so they are not handled by the bridge anyway. They
> > are only dropped, unless STP is turned on. So let's just not drop
> > the SLOW packets. Does this look better?
> > 
> 
> Better, but still have a couple of questions:
> 1) Do you want to processing frames when bridge port is in blocking
>    state (because STP detected a loop)?

Yes. When the bond is one of the bridged interfaces, the bridge
should not affect it at all, I think. I'm talking about this kind
of setup:

eth0--\
eth1---> bond0 ---- bridge
eth2--/             |  |
                    |  |
wlan1---------------   |
wlan2------------------

The bridge should treat bond0 just like any other bridged
interface (e.g. wlan1 or wlan2) and not influence its internal
functionality at all.

Whatever state the bridge is in, it should not influence the
bond's private communication (LACP). Of course, the bridge will
block traffic that arrives on the bond, but it should not block
control traffic that arrives on the physical slave interfaces
before it reaches the bond.

> 2) Do you want to process after netfilter processing to allow
>    some firewalling possiblity?

Again, the bonding works well when there is no bridging. I think
it should continue to work the same when the bond is added to a
brdidge. 

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

