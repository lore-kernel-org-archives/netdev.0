From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Thu, 7 Mar 2013 19:10:33 +0000
Message-ID: <1362683433.2936.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
	 <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130306.155323.344491888348815531.davem@davemloft.net>
	 <20130307102740.GB31105@redhat.com>
	 <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130307163537.GA21810@redhat.com>
	 <1362675261.2936.18.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130307183803.GB21810@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<wfp5p@virginia.edu>, <jasowang@redhat.com>,
	<junchangwang@gmail.com>, <greearb@candelatech.com>,
	<ivecera@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60608 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932724Ab3CGTKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 14:10:49 -0500
In-Reply-To: <20130307183803.GB21810@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 19:38 +0100, Veaceslav Falico wrote:
> On Thu, Mar 07, 2013 at 04:54:21PM +0000, Ben Hutchings wrote:
> >On Thu, 2013-03-07 at 17:35 +0100, Veaceslav Falico wrote:
> >> On Thu, Mar 07, 2013 at 03:52:35PM +0000, Ben Hutchings wrote:
> >> >On Thu, 2013-03-07 at 11:27 +0100, Veaceslav Falico wrote:
[...]
> >> >> Silently changing speed can break things a bit - bonding relies on
> >> >> interface speeds for 802.3ad/alb/tlb/active-backup iirc, bridge relies on
> >> >> stp port cost etc. and they all get it via NETDEV_ notifications. So
> >> >> without them, they would end up with outdated data, per example (eth2 being
> >> >> 8139too):
> >> >[...]
> >> >
> >> >Yes, I get it.  But on real hardware, changing speed/duplex is always
> >> >going to break the link if it's up.  The link change notification should
> >> >result in kernel and userland notifications via linkwatch_do_dev().
> >> >
> >> >(If you're testing against QEMU rather than real hardware, there could
> >> >be a bug in the emulation of link interrupts.)
> >>
> >> It's real hardware:
> >>
> >> [    4.339413] 8139cp 0000:10:09.0: This (id 10ec:8139 rev 10) is not an 8139C+ compatible chip, use 8139too
> >> [    4.348210] 8139too: 8139too Fast Ethernet driver 0.9.28
> >> [    4.350017] 8139too 0000:10:09.0 eth2: RealTek RTL8139 at 0xffffc90004574100, 00:14:d1:1f:b9:49, IRQ 21
> >[...]
> >
> >OK.  But it's generally not enough to send a 'something changed'
> >notification; the driver actually has to update the link state.  MAybe
> >in your test you reconfigure the other end of the link too, or it's
> >smart enough to do parallel detect.  But in general, changing the link
> >speed is going to change the link state, and the TX scheduler needs to
> >enabled or disabled accordingly.
> 
> Sorry, I think I didn't explain it clearly. The driver *does* notify
> about link changes even when it has autonegotiation disabled.
> 
> The only thing that doesn't work is the notification when someone changes
> it via ethtool. In the same moment.

The link *should* go down (assuming it was up before) because you likely
have a speed mismatch and won't be able to pass traffic.  I don't know
whether this is possible for the hardware to detect immediately; maybe a
PHY reset will ensure that it is detected.

[...]
> Other drivers, after setting autoneg off, usually ifdown/ifup the interface
> manually, and thus everything gets updated. That is another way to fix this
> driver - to issue ->ndo_stop(); ->ndo_open(); (as netxen_nic/qlcnic/etc
> do), but I think that just issuing a notification that we've changed the
> state, without flapping, is better.

The link *should* flap, though doing a full stop/start is likely
unnecessary.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
