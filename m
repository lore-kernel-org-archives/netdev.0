From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH] 8139too: send NETDEV_CHANGE manually when autoneg is
 disabled
Date: Thu, 7 Mar 2013 17:35:37 +0100
Message-ID: <20130307163537.GA21810@redhat.com>
References: <1362596784-19443-1-git-send-email-vfalico@redhat.com>
 <1362601372.3126.23.camel@bwh-desktop.uk.solarflarecom.com>
 <20130306.155323.344491888348815531.davem@davemloft.net>
 <20130307102740.GB31105@redhat.com>
 <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	wfp5p@virginia.edu, jasowang@redhat.com, junchangwang@gmail.com,
	greearb@candelatech.com, ivecera@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057Ab3CGQgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 11:36:02 -0500
Content-Disposition: inline
In-Reply-To: <1362671555.2936.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 03:52:35PM +0000, Ben Hutchings wrote:
>On Thu, 2013-03-07 at 11:27 +0100, Veaceslav Falico wrote:
>> On Wed, Mar 06, 2013 at 03:53:23PM -0500, David Miller wrote:
>> >From: Ben Hutchings <bhutchings@solarflare.com>
>> >Date: Wed, 6 Mar 2013 20:22:52 +0000
>> >
>> >> On Wed, 2013-03-06 at 20:06 +0100, Veaceslav Falico wrote:
>> >>> When setting autoneg off (with any additional parameters, like
>> >>> speed/duplex), 8139too doesn't do an interface reset, and thus doesn't
>> >>> notify anyone that its speed/duplex might have changed (bonding and bridge
>> >>> will not see the speed changes, per example).
>> >>>
>> >>> Verify if we've force_media and send notification manually, so that the
>> >>> listeners have a chance to see the changes. It's quite ugly, however I
>> >>> don't see anything better.
>> >>
>> >> Isn't this really a bug in mii_check_media()?  It shouldn't shortcut the
>> >> calls to netif_carrier_{off,on}() just because mii->force_media is set.
>> >
>> >I think mii_check_media() is responsible for handling this too.
>>
>> The mii_check_media() doesn't get called, AFAIK. The problem here is that,
>> after we call ethtool -s eth0 autoneg off speed X, with eth0 being
>> 8139too, the speed/autoneg options are changed via mii_ethtool_sset(),
>> however the interface itself isn't down'ed/up'ed, and thus no NETDEV_
>> notifications are sent.
>
>Does the hardware not send link interrupts if autoneg is disabled?

Yes, it doesn't send them when the autoneg off is set.

>
>> Other drivers either explicitly reset the interface after
>> ethtool.set_settings() call (like netxen_nic using ndo_close()/ndo_open()),
>> do it on the logic level (tg3) without involving mii_ethtool_sset(), or
>> just reset on their own (e100 iirc), so that most of them are responsible
>> for somehow triggering these events.
>>
>> Silently changing speed can break things a bit - bonding relies on
>> interface speeds for 802.3ad/alb/tlb/active-backup iirc, bridge relies on
>> stp port cost etc. and they all get it via NETDEV_ notifications. So
>> without them, they would end up with outdated data, per example (eth2 being
>> 8139too):
>[...]
>
>Yes, I get it.  But on real hardware, changing speed/duplex is always
>going to break the link if it's up.  The link change notification should
>result in kernel and userland notifications via linkwatch_do_dev().
>
>(If you're testing against QEMU rather than real hardware, there could
>be a bug in the emulation of link interrupts.)

It's real hardware:

[    4.339413] 8139cp 0000:10:09.0: This (id 10ec:8139 rev 10) is not an 8139C+ compatible chip, use 8139too
[    4.348210] 8139too: 8139too Fast Ethernet driver 0.9.28
[    4.350017] 8139too 0000:10:09.0 eth2: RealTek RTL8139 at 0xffffc90004574100, 00:14:d1:1f:b9:49, IRQ 21

darkmag:~#ethtool eth2
Settings for eth2:
<snip>
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full 
                                 100baseT/Half 100baseT/Full 
         Advertised pause frame use: No
         Advertised auto-negotiation: Yes
         Link partner advertised link modes:  10baseT/Half 10baseT/Full 
                                              100baseT/Half 100baseT/Full 
         Link partner advertised pause frame use: Symmetric
         Link partner advertised auto-negotiation: Yes
         Speed: 100Mb/s
         Duplex: Full
<snip>
darkmag:~#dmesg | tail -n 10 | grep 8139too
[  164.019622] 8139too 0000:10:09.0 eth2: link up, 100Mbps, full-duplex, lpa 0x45E1
darkmag:~#ethtool -s eth2 autoneg off speed 10
darkmag:~#dmesg | tail -n 10 | grep 8139too
[  164.019622] 8139too 0000:10:09.0 eth2: link up, 100Mbps, full-duplex, lpa 0x45E1
darkmag:~#ethtool eth2
Settings for eth2:
<snip>
         Supports auto-negotiation: Yes
         Advertised link modes:  Not reported
         Advertised pause frame use: No
         Advertised auto-negotiation: No
         Speed: 10Mb/s
         Duplex: Full

And, obviously, bonding's not updated:

darkmag:~#grep 'Interface\|Speed' /proc/net/bonding/bond0 
Slave Interface: eth0
Speed: 100 Mbps
Slave Interface: eth2
Speed: 100 Mbps

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
