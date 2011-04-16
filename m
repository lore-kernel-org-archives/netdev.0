From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle
 NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS
Date: Sat, 16 Apr 2011 03:53:56 +0100
Message-ID: <1302922436.5282.839.camel@localhost>
References: <1302911271.2845.41.camel@bwh-desktop> <22334.1302913805@death>
	 <4DA8F627.5090109@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:19220 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab1DPCyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 22:54:01 -0400
In-Reply-To: <4DA8F627.5090109@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-15 at 21:51 -0400, Brian Haley wrote:
> On 04/15/2011 08:30 PM, Jay Vosburgh wrote:
> > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > 
> >> It is undesirable for the bonding driver to be poking into higher
> >> level protocols, and notifiers provide a way to avoid that.  This does
> >> mean removing the ability to configure reptitition of gratuitous ARPs
> >> and unsolicited NAs.
> > 
> > 	In principle I think this is a good thing (getting rid of some
> > of those dependencies, duplicated code, etc).
> > 
> > 	However, the removal of the multiple grat ARP and NAs may be an
> > issue for some users.  I don't know that we can just remove this (along
> > with its API) without going through the feature removal process.
> 
> Right, I don't know how many people are using these, they might not be
> happy, especially since specifying an unknown parameter will cause a
> module load to fail:
> 
> --> modprobe bonding foobar=27
> FATAL: Error inserting bonding (/lib/modules/2.6.32-31-generic/kernel/drivers/net/bonding/bonding.ko): Unknown symbol in module, or unknown parameter (see dmesg)
> 
> When these params are stuffed in /etc/modprobe.d/options, a reboot to
> a kernel without them will cause some swearing :)

Yes, this is a problem.

If the feature of repeated advertismenets is implemented in ipv4/ipv6
then we could propagate the parameters there, logging a warning, up to
some deprecation deadline.

> BTW, if this is accepted you need to update the documentation as well.
> 
> > 	As I recall, the multiple gratuitous ARP stuff was added for
> > Infiniband, because it is dependent on the grat ARP for a smooth
> > failover.
> > 
> > 	There is also currently logic to check the linkwatch link state
> > to wait for the link to go up prior to sending a grat ARP; this is also
> > for IB.
> > 
> > 	Brian Haley added the unsolicited NAs; I've added him to the cc
> > so perhaps he (or somebody else) can comment on the necessity of keeping
> > the ability to send multiple NAs.
> 
> I added it because in an IPv6-only environment I was seeing really long
> failover times on bonds.  I believe this was a customer-reported issue, so
> there *might* be someone setting it, but I think my testing always showed
> one was enough to wake-up the switch.
> 
> Is it useful to call netdev_bonding_change() multiple times from within
> bond_change_active_slave(), like MAX(arp, na) times?

We can't wait around to do that.  And it would be abusing the notifier
based on assumptions about what other components do, which I'm trying to
get away from.

> One comment below...
[...]
> Does your change also cover this case with multiple VLAN IDs?  Is that covered in
> the vlan.c code below?
[...]

Should do.  I didn't specifically test multiple VLAN IDs but I'm looping
over them.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

