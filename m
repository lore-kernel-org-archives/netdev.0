From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Tue, 7 Jun 2011 18:41:36 +0200
Message-ID: <20110607164136.GB5018@midget.suse.cz>
References: <20110603200738.GA24804@midget.suse.cz>
 <20110605.142823.1727360496050285755.davem@davemloft.net>
 <4DEE4107.1080706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	netdev@vger.kernel.org, pedro.netdev@dondevamos.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58450 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753992Ab1FGQli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 12:41:38 -0400
Content-Disposition: inline
In-Reply-To: <4DEE4107.1080706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2011 at 05:17:27PM +0200, Patrick McHardy wrote:
> On 05.06.2011 23:28, David Miller wrote:
> > I am pretty sure that the hardware device driver methods that
> > implement ndo_vlan_rx_add_vid() assume that the device is up.
> > Because most drivers completely reset the chip when the
> > interface is brought up and this will likely clear out the
> > VLAN ID tables in the chip.
> > 
> 
> Good point.
> 
> I don't think this approach works very well at all since
> some drivers don't do incremental updates, but iterate over
> the registered VLAN group when constructing filters. The
> group is not created until the first real VLAN device is
> registered however.
> 
> Based on a quick grep (may have missed some):
> 
> - via_velocity, mlx4, starfire: will do nothing
> 
> - benet, igb, vxge, igbvf, ixgbevf, e1000e: would oops on
>   rx_kill_vid due to unnecessary vlan_group_set_device()

which approach do you mean? David's or mine? I suppose you mean
David's, because I did not call rx_kill_vid().

> The assumption of the drivers that a VLAN group exists
> before the first VID is configured is reasonable in my
> opinion, a lot of them also don't even configure VLAN
> filtering until the VLAN group is registered.

So this is broken already since ad1afb00 :(
The assumption broke the bonding driver and this got fixed by
f35188fa, btw.

> So I think a good solution would be to make sure all
> drivers don't enable VLAN filtering before the first
> VLAN is actually registered and do the automatic
> registration of VID 0 once the first real VLAN device
> is created.

But this behaviour is not what was intended by ad1afb00.
The VID 0 needs to be registered by default, to make 8021p work.
Even without any real VLAN devices created.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

