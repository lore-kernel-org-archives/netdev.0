From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 14:38:03 +0100
Message-ID: <1208180283.3005.14.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
	 <1208167737.31695.32.camel@pmac.infradead.org>
	 <20080414125100.GA13564@bongo.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Hoyer <harald@redhat.com>, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: Marco d'Itri <md@Linux.IT>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:43656 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbYDNNih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 09:38:37 -0400
In-Reply-To: <20080414125100.GA13564@bongo.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-14 at 14:51 +0200, Marco d'Itri wrote: 
> On Apr 14, David Woodhouse <dwmw2@infradead.org> wrote:
> 
> > Actually it's a generic problem. It also occurs on OLPC, where the
> > libertas wireless device presents two interfaces with the same MAC
> And on some Sun systems as well.
> 
> > > Unconditionally adding a KERNEL key means that persistent names will
> > > break if a driver changes the base name (e.g. wlan* -> eth*).
> > Drivers shouldn't do that. It'll change the name of the device and may
> But they do...

And when they do, they change the name that userspace sees. Film at 11 :)

> > We could modify the libertas and gelic (and any other affected) drivers
> > to provide a dev_id, make sure it's exported in sysfs, and then use that
> > in the udev rules. Would that make you happy?
> Yes, I like not fixing just the symptoms. :-)

I wouldn't put it like that. We are looking for some way to tell the
difference between the two interfaces. If the kernel uses a different
basename (wlan%d vs. eth%d, or eth%d vs. msh%d), that's a fairly strong
hint about which is which -- and is fairly reliable to boot.

The dev_id provides _another_ strong hint which helps us tell which
device is which, but that doesn't mean that using the basename is wrong.

> > It has implications w.r.t. the autoconfigured IPv6 addresses of those
> > devices,
> How so?

The low 64 bits of the autoconfigured IPv6 address are derived from the
MAC address, so for example a MAC address of 00:50:43:28:0A:FC would
give you an IPv6 link-local address of fe80::250:43ff:fe28:afc -- and a
corresponding global address like 2001:8b0:10b:1:250:43ff:fe28:afc.

When you set dev_id to anything other than zero, that 'ff:fe' in the
middle changes. So with my patches, the mesh device on the same libertas
hardware becomes fe80::50:4300:128:afc -- using the newly-provided
dev_id (0x0001) instead of 0xFFFE.

See net/ipv6/addrconf.c for more details. But basically, it means we are
changing the public IPv6 addresses of the affected machines, just to
help udev tell the difference between the interfaces -- when in fact, it
already _could_ tell the difference, due to the kernel's choice of name.

We should do the dev_id thing in sysfs and udev anyway, because there
are cases where it's the right thing to do (like S390, where I think
it'll let us drop the existing hack we have, and probably also the Sun
hardware you mention).

But I don't think we should add dev_id to the gelic and libertas
drivers. We should just make write_net_rules consistently include the
KERNEL criterion -- even when $INTERFACE_NAME is set. It does it in all
other cases anyway, now.

> > > This workaround should be confined to the PS3 install media, there is
> > > no reason to add it to general-purpose distributions.
> > Our general-purpose distribution installs and runs on PS3. :)
> So if PS3 needs special hacks they should be special-cased to only by
> used on PS3 hardware.

It's not a problem which is limited to PS3.

-- 
dwmw2

