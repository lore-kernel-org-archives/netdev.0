From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: the future of ethtool
Date: Tue, 16 Nov 2010 00:10:30 +0000
Message-ID: <1289866230.2586.65.camel@bwh-desktop>
References: <4CE18CEA.5080502@garzik.org>
	 <1289852326.2586.32.camel@bwh-desktop> <20101115124428.7b857ccb@nehalam>
	 <1289855642.2586.38.camel@bwh-desktop> <20101115131453.16958d68@nehalam>
	 <1289857936.2586.51.camel@bwh-desktop> <4CE1B8FD.3000007@garzik.org>
	 <20101115233335.GB24292@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23310 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906Ab0KPAKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 19:10:33 -0500
In-Reply-To: <20101115233335.GB24292@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-11-15 at 18:33 -0500, Thomas Graf wrote:
> On Mon, Nov 15, 2010 at 05:49:33PM -0500, Jeff Garzik wrote:
> > s/only//   I don't think Stephen is suggesting sending _some_ ops
> > through netlink and others through old-ioctl.  That's just silly.
> > Any new netlink interface should transit all existing ETHTOOL_xxx
> > commands/structures.
> > 
> > But presumably, one would have the ability to send multiple
> > ETHTOOL_xxx bundled together into a single netlink transaction,
> > facilitating the kernel's calling of struct ethtool_ops'
> > 	->begin()
> > 	... first operation specified by userspace via netlink ...
> > 	... second operation specified by userspace via netlink ...
> > 	... etc.
> > 	->end()
> > 
> > The underlying struct ethtool_ops remains unchanged; you're only
> > changing the transit method.
> > 
> > Thus, the ethtool userspace utility would switch entirely to
> > netlink, while the ioctl processing code remains for binary
> > compatibility.
> > 
> > Or... ethtool userspace utility could remain unchanged, and a new
> > 'nictool' utility provides the same features but with (a) a new CLI
> > and (b) exclusively uses netlink rather than ioctl.
> 
> I actually have code for this including userspace. I never submitted
> it because I wasn't confident it is the way to go since it literally
> duplicates all ethtool code in the kernel.
> 
> There is one major problem with bundling multiple requests though. If
> one change request fails but other changes have been committed already
> we can't really undo them without causing lots of races. We have to
> leave the device in a somewhat inconsistent state. It's even difficult
> to tell what has been comitted and what hasn't. It also makes error
> reporting more difficult as a -ERANGE error code could apply to any
> of the values to be changed.
[...]

I think it's hopeless to make this truly transactional.  Unless the
ethtool core maintains all the settings in one giant structure and
passes them over to the driver to check and apply then there is no way
driver authors are going to get it right in general.  And if the ethtool
core does that then, as you say, error reporting is going to be
terrible.  There will be even more need to go look in the kernel log to
see the driver's explanation of why the settings are invalid which was
too long to fit in this margin^Wreturn code.

I would expect to treat each operation in a multiple-set as conditional
on the success of all previous operations.  ethtool or other utilities
should then take care to put operations in a sensible order (e.g. enable
TX checksum before TSO, if those remain separate operations).  Error
reporting in the core is then as simple as reporting how many operations
were successful plus the error code for the one that failed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

