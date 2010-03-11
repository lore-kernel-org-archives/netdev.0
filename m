From: Brian Haley <brian.haley@hp.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Wed, 10 Mar 2010 21:09:32 -0500
Message-ID: <4B9850DC.9060703@hp.com>
References: <20091229084929.54912c0c@pluto.restena.lu> <1262077540.12520.4.camel@localhost> <20091229145403.39f82773@pluto.restena.lu> <1262149691.2788.63.camel@localhost> <20100219091034.5fbb0165@pluto.restena.lu> <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com> <20100223131508.4c6cb866@neptune.home> <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com> <20100302081051.3d1b1c53@pluto.restena.lu> <20100302092020.52cfcd0e@pluto.restena.lu> <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com> <4B90189B.2040801@hp.com> <4B98268D.2020206@hp.com> <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>,
	Benjamin Li <benli@broadcom.com>,
	NetDEV <netdev@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:37768 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab0CKCKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 21:10:06 -0500
In-Reply-To: <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> On Wed, 2010-03-10 at 15:09 -0800, Brian Haley wrote:
>> Brian Haley wrote:
>>> Hi Michael,
>>>
>>> Michael Chan wrote:
>>>> Do we have timers running in this environment?  The timer in the bnx2
>>>> driver, bnx2_timer(), needs to run to provide a heart beat to the
>>>> firmware.  In netpoll mode without timer interrupts, if we are regularly
>>>> calling the NAPI poll function, it should also be able to provide the
>>>> heartbeat.  Without the heartbeat, the firmware will reset the chip and
>>>> result in the NETDEV WATCHDOG.
>>> We have also been seeing watchdog timeouts with bnx2, below is a
>>> stack trace with Benjamin's debug patch applied.  Normally we were
>>> only seeing them under heavy load, but this one was at boot.  We haven't
>>> tried the latest firmware/driver from 2.6.33 yet.  You can contact me
>>> offline if you need more detailed info.
>> Following-up since I have more info on this issue.
>>
>> I'm able to cause a netdev_watchdog timeout by changing the coalesce
>> settings on my bnx2, I built a little test program for it:
> 
> Do you run this program in a loop?  How quickly do you see the NETDEV
> WATCHDOG?

It's run once, and we see it almost immediately after ETHTOOL_SCOALESCE.

>> 	ecoal.rx_coalesce_usecs = 0;
>> 	ecoal.rx_max_coalesced_frames = 1;
>> 	ecoal.rx_coalesce_usecs_irq = 0;
>> 	ecoal.rx_max_coalesced_frames_irq = 1;
> 
> These rx settings should be ok.  Did you change the tx settings?  If the
> tx settings are all zeros, you won't get any TX interrupts and you can
> get a NETDEV WATCHDOG.

We did the read, so the TX should be what it was originally.

> Run ethtool -c eth0 to see what the tx settings are.  Thanks.

# ethtool -c eth0
Coalesce parameters for eth0:
Adaptive RX: off  TX: off
stats-block-usecs: 999936
sample-interval: 0
pkt-rate-low: 0
pkt-rate-high: 0

rx-usecs: 0
rx-frames: 1
rx-usecs-irq: 0
rx-frames-irq: 1

tx-usecs: 80
tx-frames: 20
tx-usecs-irq: 18
tx-frames-irq: 2

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 0
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

If I run 'ethtool -c eth0' after the watchdog triggers either the NIC
or system completely hangs.

-Brian
