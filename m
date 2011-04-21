From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: rtnetlink and many VFs
Date: Thu, 21 Apr 2011 18:40:28 +0100
Message-ID: <1303407628.3165.30.camel@bwh-desktop>
References: <1303396576.3165.13.camel@bwh-desktop>
	 <43F901BD926A4E43B106BF17856F07550145FC7526@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:56164 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab1DURkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 13:40:32 -0400
In-Reply-To: <43F901BD926A4E43B106BF17856F07550145FC7526@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-04-21 at 10:02 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Ben Hutchings
> > Sent: Thursday, April 21, 2011 7:36 AM
> > To: David Miller
> > Cc: netdev; sf-linux-drivers
> > Subject: rtnetlink and many VFs
> > 
> > My colleagues have been working on SR-IOV support for sfc.  The hardware
> > supports up to 127 VFs per port.
> > 
> > If we configure all 127 VFs through the net device, an RTM_GETLINK dump
> > will need to include messages describing them, with a total size of:
> > 
> > 127 * (sizeof(struct ifla_vf_mac) + sizeof(struct ifla_vf_vlan) +
> >        sizeof(struct ifla_vf_tx_rate) + protocol overhead)
> > > 7112
> > 
> > These messages are nested within the message describing the device as a
> > whole, so they cannot be split.  The maximum size of an outgoing netlink
> > message, based on NLMSG_GOODSIZE, seems to be min(PAGE_SIZE, 8192).  So
> > when PAGE_SIZE = 4096 it is simply impossible to dump information about
> > such a device!
> > 
> > I think it needs to be made possible to grow a netlink skb during
> > generation of the first message.  Userspace may still be unable to
> > receive the large message but at least it has a chance.
> 
> I've been looking at this one too.  The limit seems to be about 40 or
> so in the most common case.

Right.  When Steve Hodgson investigated this here, he found that 46 VFs
would fit.

> My netlink fu is weak but I've been looking at the code in iproute2/ip
> and netlink to see what we can do about it.
> 
> As more VFs become possible it really needs a fix.  I was thinking
> about something along the lines of this:
> 
> # ip link show eth(x) vf (n)
> 
> Where eth(x) is the physical function that owns the VFs and (n) is the
> specific VF you want information for.  That way one could easily
> script something that loops through the VFs and gets the information
> for each.  This really becomes necessary when we start adding
> additional MAC and VLAN filters for each VF that need to be displayed.
> In that case you can only show a few VFs before you run out of space.

I think that what 'ip link show' is doing now seems to be perfectly
valid.  It allocates a 16K buffer which would be enough if netlink
didn't apply this PAGE_SIZE limit to single messages.

> In any case I've been working on an RFC patch for this and hope to
> have it soon.  I consider this a pretty serious limitation and one
> could even view it as a bug.

It is certainly a bug.  rtnetlink is the currently favoured API for
querying and configuring network device settings, but there are now
valid device settings that cannot be queried.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

