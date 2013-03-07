From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Thu, 7 Mar 2013 15:52:35 +0000
Message-ID: <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
	 <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
	 <20130306.155323.344491888348815531.davem@davemloft.net>
	 <20130307102740.GB31105@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<wfp5p@virginia.edu>, <jasowang@redhat.com>,
	<junchangwang@gmail.com>, <greearb@candelatech.com>,
	<ivecera@redhat.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11582 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754154Ab3CGPxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 10:53:00 -0500
In-Reply-To: <20130307102740.GB31105@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 11:27 +0100, Veaceslav Falico wrote:
> On Wed, Mar 06, 2013 at 03:53:23PM -0500, David Miller wrote:
> >From: Ben Hutchings <bhutchings@solarflare.com>
> >Date: Wed, 6 Mar 2013 20:22:52 +0000
> >
> >> On Wed, 2013-03-06 at 20:06 +0100, Veaceslav Falico wrote:
> >>> When setting autoneg off (with any additional parameters, like
> >>> speed/duplex), 8139too doesn't do an interface reset, and thus doesn't
> >>> notify anyone that its speed/duplex might have changed (bonding and bridge
> >>> will not see the speed changes, per example).
> >>>
> >>> Verify if we've force_media and send notification manually, so that the
> >>> listeners have a chance to see the changes. It's quite ugly, however I
> >>> don't see anything better.
> >>
> >> Isn't this really a bug in mii_check_media()?  It shouldn't shortcut the
> >> calls to netif_carrier_{off,on}() just because mii->force_media is set.
> >
> >I think mii_check_media() is responsible for handling this too.
> 
> The mii_check_media() doesn't get called, AFAIK. The problem here is that,
> after we call ethtool -s eth0 autoneg off speed X, with eth0 being
> 8139too, the speed/autoneg options are changed via mii_ethtool_sset(),
> however the interface itself isn't down'ed/up'ed, and thus no NETDEV_
> notifications are sent.

Does the hardware not send link interrupts if autoneg is disabled?

> Other drivers either explicitly reset the interface after
> ethtool.set_settings() call (like netxen_nic using ndo_close()/ndo_open()),
> do it on the logic level (tg3) without involving mii_ethtool_sset(), or
> just reset on their own (e100 iirc), so that most of them are responsible
> for somehow triggering these events.
> 
> Silently changing speed can break things a bit - bonding relies on
> interface speeds for 802.3ad/alb/tlb/active-backup iirc, bridge relies on
> stp port cost etc. and they all get it via NETDEV_ notifications. So
> without them, they would end up with outdated data, per example (eth2 being
> 8139too):
[...]

Yes, I get it.  But on real hardware, changing speed/duplex is always
going to break the link if it's up.  The link change notification should
result in kernel and userland notifications via linkwatch_do_dev().

(If you're testing against QEMU rather than real hardware, there could
be a bug in the emulation of link interrupts.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
