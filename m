From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Sun, 06 Jun 2010 15:08:21 +0200
Message-ID: <1275829701.3615.54.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37150 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756655Ab0FFNI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jun 2010 09:08:27 -0400
In-Reply-To: <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-04 at 10:34 +0200, Kay Sievers wrote:

> >> Assuming that hwsim is th parent of the network interface, it should
> >> us a "struct bus_type" not a "struct class" for the subsystem it
> >> assigns the devices to.
> >
> > It's all virtual, so yeah, I guess it is the parent? It currently
> > creates a virtual struct device in the hwsim class and assigns that to
> > the netdev parent indirectly via the wiphy or something like that.
> >
> >> Classes should not be used for anything completely simple, at best not
> >> be used at all, they are just too simple. We never know about future
> >> requirements, which usually all go wrong with the non-extendable class
> >> logic.
> >>
> >> The difference in the code to switch from class to bus should be minimal.
> >
> > Does that mean cfg80211 (net/wireless/) should also not use a struct
> > class? I'm not familiar with any of these details, mind helping me out?
> 
> Everything that might ever have a child device, or might ever need a
> sysfs attribute gobal to the subsystem must convert to a bus.
> 
> Actually there is not much reason to ever use "struct class" today.
> The layout for classes in /sys is not extendable like it is for buses
> which put all devices in a devices/ subdir and have the main subsystem
> directory to add custom things.

Ok, I don't get it.

For hwsim, we create entirely virtual "struct device"s. I think we just
need that so userspace like network-manager doesn't get completely
confused. BUT: device_create() needs a struct class parameter as the
first parameter. So should we have a virtual class _and_ a virtual bus??

Similarly for wireless itself (net/wireless/), we use
device_initialize() and set up the dev.class and dev.platform_data (not
sure why platform data?) since this is a virtual abstraction. Basically
we want to show in sysfs that

physical device
  +--- (virtual) wireless phy device 1
     +--- netdev 1
     +--- netdev 2
     +--- netdev 3
  +--- (virtual) wireless phy device 2
     +--- netdev 4

Although the second wireless phy device is only done by ath9k and will
be removed soon. Still we should show that those netdevs all belong to
the given wireless phy device.

So ... what should I do? How can I do device_create/device_initialize
without a struct class? And why a bus instead? It's not like there are
devices that need to be discovered and bound to it etc.

johannes

