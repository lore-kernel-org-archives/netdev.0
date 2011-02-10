From: Dan Williams <dcbw@redhat.com>
Subject: Re: [Bugme-new] [Bug 28532] New: Link state change detection
 problem on Moschip MCS7832 [mcs7830]
Date: Thu, 10 Feb 2011 13:58:05 -0600
Message-ID: <1297367886.17161.24.camel@dcbw.foobar.com>
References: <bug-28532-10286@https.bugzilla.kernel.org/>
	 <20110207151401.d1db088a.akpm@linux-foundation.org>
	 <20110208205247.GA4617@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, myxal.mxl@gmail.com
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab1BJT5z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Feb 2011 14:57:55 -0500
In-Reply-To: <20110208205247.GA4617@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-08 at 21:52 +0100, Andreas Mohr wrote:
> Hi,
> 
> > > I have a network adapter which uses the aforementioned driver and while
> > > checking for the link state via ethtool reports the correct state, many
> > > networking userspace utilities seem to have no clue about it (NM 0.8.1 starts
> > > dhclient BEFORE any cable is plugged) - and more importantly, don't notice when
> > > the cable is (dis)connected. Since there's not even a kernel message when
> > > (dis)connecting the cable, I suspect the driver does not implement Link state
> > > change detection at all. Is this accurate?
> 
> Ah, perhaps that is why as long as network-mangler is running, my

If the driver does not support link detection, NM can only assume that
the device always has a carrier.  NM actually just uses the 'carrier'
flag from netlink, and since drivers that don't support link detection
never set the carrier flag to 0, carrier is always 1 as seen by NM.  If
the device says it has a carrier, that means stuff that listens for that
(ie, NM, ifplugd, whatever) will try to configure IP on the device.

Drivers should really, really support link detection.

Dan

> .resume_reset() handler improvements (managing to keep an active interface
> even directly after resume) actually do _not_ work (since it seems it simply
> down:s the iface and that's it).
> I know that there is link info functionality in other drivers yet not
> as much in mcs7830.
> 
> Note that the mcs7830 driver still has a rather stubby appearance
> (many more "advanced" features are either weak or not available at all).
> 
> I've got a patch series sitting here to improve several parts
> (and waiting to cook a bit more), but I hadn't even identified the link issue.
> It appears that this would need fixing, presto.
> 
> > > LSCD works in Windows, where it's apparently implemented through periodic
> > > polling (judging by virtualbox's blinking USB icon).
> > > How is this situation normally handled? Is it kernel's job to do the polling?
> > > Or are userspace utilities expected to do this?
> 
> I'm afraid a painful solution would be to activate the .status callback
> for periodic USB status descriptor polling. I've got a
> half-implementation of that, however it's very painful in terms of
> obscene amounts of CPU wakeups.
> There _has_ to be a better solution...
> 
> Thank you for your (the OP's) report (and for my extra notification!),
> this seems very helpful!
> (I am determined to post related useful patches soon,
> especially since this card is in active use here)
> 
> Andreas Mohr
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


