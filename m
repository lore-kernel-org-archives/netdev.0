From: Deepjyoti Kakati <dkakati73@gmail.com>
Subject: Re: duplicate arp request problem with bonding driver
Date: Wed, 6 May 2009 08:49:20 +0530
Message-ID: <9a2da8520905052019t5a2c07f2i2799722825c43f86@mail.gmail.com>
References: <9a2da8520905050632sa9a4935md668387339c748a0@mail.gmail.com>
	 <9a2da8520905050645s31c62a9bhdd0a5b60ae9ce52c@mail.gmail.com>
	 <27031.1241535224@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:9616 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753094AbZEFDTV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 23:19:21 -0400
Received: by qw-out-2122.google.com with SMTP id 5so4008972qwd.37
        for <netdev@vger.kernel.org>; Tue, 05 May 2009 20:19:21 -0700 (PDT)
In-Reply-To: <27031.1241535224@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks for your detailed reply Jay.

the idea with my topology was to have a bandwidth of 2 Gbps
(2xeth ports) available at all times to redundant switches.

                         bond3 (primary-backup)
                        /       \
                     bond1  bond2 (aggregated)
                      !    !     !    !
                     e1 e2   e2 e4


but as you pointed out the primary->backup failover wont occur
until all slaves have failed apart from the issue with nesting of
bonds.

no particular reason why I selected balance-rr mode, it just was
the default. my switches being cisco catalysts, I will try out your
suggestion about the single level bonding and 802.3ad mode.


-Deepjyoti

On Tue, May 5, 2009 at 8:23 PM, Jay Vosburgh <fubar@us.ibm.com> wrote:

>
> =A0 =A0 =A0 =A0Your problem is ultimately because nesting of bonds do=
es not
> quite work. =A0Bonding does not really process incoming packets in th=
e
> usual sense; there's just a minimal check to assign the packet to the
> proper device, and a check to see if it should be dropped. =A0This ch=
eck
> is done one time only, for the bottommost level of bond (the one to
> which the receiving device is enslaved to). =A0For the VLAN case, the=
 VLAN
> input processing will immediately thereafter assign the packet to the
> VLAN device.
>
> =A0 =A0 =A0 =A0My question for you is: what do you want to achieve wi=
th this
> type of topology? =A0There are going to be a few issues with it, othe=
r
> than what you've found already. =A0For one, the active-backup won't f=
ail
> over until all slaves of the active bond (bond1 or bond2) have failed=
=2E
>
> =A0 =A0 =A0 =A0I'm not sure what your workload is, but I would rarely=
 recommend
> using balance-rr for anything (it often leads to out of order packet
> delivery). =A0I would hazard to guess that you're trying to optimize =
a
> single TCP/IP stream's throughput, and balance-rr will do that to a
> degree, at the expense of overall throughput.
>
> =A0 =A0 =A0 =A0In your case, if the interconnects between switch1 and=
 switch2
> and the final destinations are not all faster than the eth1 - eth4
> devices, you ultimately won't have any increase in throughput, becaus=
e
> the switch uplinks will be limiting the available bandwidth. =A0If th=
e
> interconnects are all faster, and the final destinations are running
> etherchannel or the like, you'll see out of order delivery. =A0Your s=
ingle
> stream may see roughly a 50% increase in throughput for TCP/IP (for t=
wo
> slaves of the same speed, i.e., 1.5 Gb/sec for two 1 Gb/sec slaves) b=
ut
> at a lower efficiency.
>
> =A0 =A0 =A0 =A0My usual recommendation for this type of configuration=
 is to use
> 802.3ad mode, particularly with a recent kernel with changes to 802.3=
ad
> to support the recent ad_select option:
>
> ad_select
>
> =A0 =A0 =A0 =A0Specifies the 802.3ad aggregation selection logic to u=
se. =A0The
> =A0 =A0 =A0 =A0possible values and their effects are:
>
> =A0 =A0 =A0 =A0stable or 0
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0The active aggregator is chosen by lar=
gest aggregate
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bandwidth.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Reselection of the active aggregator o=
ccurs only when all
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slaves of the active aggregator are do=
wn or the active
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0aggregator has no slaves.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0This is the default value.
>
> =A0 =A0 =A0 =A0bandwidth or 1
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0The active aggregator is chosen by lar=
gest aggregate
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bandwidth. =A0Reselection occurs if:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- A slave is added to or removed from =
the bond
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- Any slave's link state changes
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- Any slave's 802.3ad association stat=
e changes
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0- The bond's adminstrative state chang=
es to up
>
> =A0 =A0 =A0 =A0count or 2
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0The active aggregator is chosen by the=
 largest number of
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ports (slaves). =A0Reselection occurs =
as described under the
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"bandwidth" setting, above.
>
> =A0 =A0 =A0 =A0The bandwidth and count selection policies permit fail=
over of
> =A0 =A0 =A0 =A0802.3ad aggregations when partial failure of the activ=
e aggregator
> =A0 =A0 =A0 =A0occurs. =A0This keeps the aggregator with the highest =
availability
> =A0 =A0 =A0 =A0(either in bandwidth or in number of ports) active at =
all times.
>
> =A0 =A0 =A0 =A0This option was added in bonding version 3.4.0.
>
>
> =A0 =A0 =A0 =A0Setting this option to "bandwidth" or "count" permits =
802.3ad to
> be configured for "gang failover," e.g.:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0
> =A0 =A0 =A0 =A0eth0 =A0 =A0eth1 =A0 =A0eth2 =A0 =A0eth3
> =A0 =A0 =A0 =A0! =A0 =A0 =A0 ! =A0 =A0 =A0 ! =A0 =A0 =A0 !
> =A0 =A0 =A0 =A0[switch 1] =A0 =A0 =A0[switch 2]
>
>
> =A0 =A0 =A0 =A0In this case, (eth0, eth1) and (eth2, eth3) will be pu=
t together
> into aggregators, and one will be selected automatically to be the
> active aggregator. =A0Should either slave of the active aggregator fa=
il,
> the ad_select policy will cause a reselection of the active aggregato=
r.
> This, in the end, should keep the "best" aggregator active at all tim=
es.
>
> =A0 =A0 =A0 =A0This does require the switches to support 802.3ad, but=
 that's
> fairly common these days. =A0802.3ad does not support a round-robin t=
ype
> of transmit policy, so if you are heavily dependent on that, this may
> not work for you.
>
> =A0 =A0 =A0 =A0I don't follow Fedora development, so I don't know if =
their
> current kernels support this option or not.
>
> =A0 =A0 =A0 =A0-J
>
> ---
> =A0 =A0 =A0 =A0-Jay Vosburgh, IBM Linux Technology Center, fubar@us.i=
bm.com
>
