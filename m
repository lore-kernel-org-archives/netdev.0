From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 3 Aug 2007 14:44:09 +0100
Message-ID: <20070803144409.3f95c91d@oldman.hamilton.local>
References: <20070802224206.GB5181@ifup.org>
	<20070803095857.5fb3f368@oldman.hamilton.local>
	<20070803102645.GO13674@htj.dyndns.org>
	<20070803120745.2d89c221@oldman.hamilton.local>
	<46B31270.7090503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brandon Philips <brandon@ifup.org>, netdev@vger.kernel.org,
	teheo@suse.de
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49157 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760408AbXHCNnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 09:43:52 -0400
In-Reply-To: <46B31270.7090503@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 03 Aug 2007 20:33:04 +0900
Tejun Heo <htejun@gmail.com> wrote:

> Hello,
> 
> Stephen Hemminger wrote:
> >> Skimming through drivers... via-rhine doesn't disable PCI device on
> >> init failure path but does so on removal.  sky2 doesn't free
> >> consistent memory if sky2_init() fails.  acenic calls iounmap() with
> >> NULL parameter which I'm not sure whether it's safe or not.  natsemi
> >> doesn't disable PCI device on failure or removal.
> > 
> > Did you report these to the developers?
> 
> Just skimmed through.  I'm pretty sure Brandon will pick those up later.
> 
> >> Devres makes low level drivers simpler, easier to get right and
> >> maintain.  Writing new drivers becomes easier too.  So, why not?
> >>
> >>> Network devices seem to work fine thanks, and the resource requirements
> >>> are different. If ain't broke, don't fix it.
> >> Care to enlighten me on how the resource requirments are different
> >> from ATA drivers?
> > 
> > I was thinking of the hot remove (no mod ref counts) and lingering
> > /sys open issues.  ATA drivers use ref counts.
> 
> I guess the hot removing is done by severing netdev from the actual
> device, right?  I don't see how that affects usage of devres on network
> drivers.  Am I missing something?

The issue is that device may be removed at any time. So you can't rely
on module ref counts to save you. And netdevice structure must still
linger after module is removed, till dev ref count goes to zero.

> On a separate note, can you explain lingering /sys open issue to me a
> bit?  With recent sysfs changes, sysfs nodes are disconnected
> immediately on deletion.  Would that make any difference to netdevs?

Examples are in Documentation/networking/netdevices.txt

> > My take on devres is that it is similar to talloc() for device drivers.
> > Not a bad idea in itself, but the real advantage of hierarchical allocation
> > is that it makes exception handling easier if things are layered deeply.
> 
> Yeah, devres made layering easier in libata, especially SFF stuff.
> Dunno how much of that is applicable to netdev but, with or without
> layering, it'll be a nice cleanup and I don't see much negative side.
> Conversion would take some work and bugs might be introduced in the
> process as with any changes but the good thing about devres is that
> you're very likely to get failure/release paths right if you get the
> init path right, and if you get the init path wrong, it will stand out
> like a sore thumb - easy to spot, easy to fix.
> 
> So, I think using devres on net drivers is a good idea, well, for that
> matter, for any driver, but me being the devres writer, that isn't
> really surprising, is it?
> 
> Thanks.
> 
> -- 
> tejun
