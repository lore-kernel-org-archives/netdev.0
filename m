From: Chris Leech <christopher.leech@intel.com>
Subject: Re: Receive issues with bonding and vlans
Date: Mon, 12 Apr 2010 16:35:09 -0700
Message-ID: <20100412233509.GA32302@cleech-lnx.jf.intel.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <29849.1271113851@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6984 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321Ab0DLXfL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 19:35:11 -0400
Content-Disposition: inline
In-Reply-To: <29849.1271113851@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 04:10:51PM -0700, Jay Vosburgh wrote:
> 	Is the FCoE supposed to run over the inactive bonding slave?  Or
> am I misunderstanding what you're saying?  I had thought the LLDP, et
> al, special case in bonding was to permit, essentially, path discovery,
> not necessarily active use of the inactive slave.

That's what I'm trying to do, yes.  Mostly because it's a setup that
would work if you removed the FCoE traffic from the network data path,
and only converged at the driver level and below.  It's possible that
the answer is "don't do that".

> 	Not that this is necessarily bad; the "drop stuff on inactive
> slaves" is really there for duplicate suppression, but it also can
> uncover network topology issues, e.g., network layouts that won't work
> if the devices fail, but appear to work during testing because the
> "inactive" slave still receives traffic (it hasn't really failed).
> 
> >The problem is that it doesn't work for hardware accelerated VLAN
> >devices, because the VLAN receive paths have their own
> >skb_bond_should_drop calls that were not updated.
> >
> >From what I can tell, VLAN receives always end up going through
> >netif_receive_skb anyway, so skb_bond_should_drop gets called twice if
> >the frame isn't dropped the first time.  I think the bonding checks in
> >__vlan_hwaccel_rx and vlan_gro_common should just be removed.
> 
> 	I'm not so sure.  The checks in __vlan_hwaccel_rx are done with
> the original receiving device in skb->dev; by the time the packet gets
> to netif_receive_skb, the original slave the packet was received on has
> been lost (and replaced with the VLAN device).  Various things are
> interested in that, in particular the "arp_validate" and the "inactive
> slave drop" logic for bonding depend on knowing the real device the
> packet arrived on.
> 
> 	I note that the vlan accel logic doesn't change skb_iif to the
> VLAN device; it remains as the original device.  I suppose one
> alternative would be to convert the bonding drop, et al, logic to use
> skb_iif instead of skb->dev; if that works, then I think the VLAN core
> would not need to call skb_bond_should_drop, which in turn would be a
> bit more complicated as it would have to look up the dev from the
> skb_iif.  There's already some code in bonding that takes advantage of
> this property of the VLANs, so maybe this is the way to go.

Thanks, I'll take another look and see if I can come up with something
better.

> >I haven't quite figured out what I think the correct change for
> >null_or_bond is.  I suspect it involves not using NULL at all.  I can
> >see how it addresses the arp_ip_target on a VLAN issue, but this is also
> >changing the receive matching rules for other traffic in unexpected
> >ways.
> 
> 	I'll hazard a guess that something like this might do it:
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index b98ddc6..cc665bb 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2735,7 +2735,7 @@ ncls:
>  			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
>  		if (ptype->type == type && (ptype->dev == null_or_orig ||
>  		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
> -		     ptype->dev == null_or_bond)) {
> +		     (null_or_bond && (ptype->dev == null_or_bond))) {
>  			if (pt_prev)
>  				ret = deliver_skb(skb, pt_prev, orig_dev);
>  			pt_prev = ptype;
> 
> 
> 	I haven't tested this, but the theory is to only test against
> null_or_bond if null_or_bond isn't NULL, which is only the case for VLAN
> traffic over bonding.

Yes, that should do it.

	- Chris

