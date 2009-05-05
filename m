From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: duplicate arp request problem with bonding driver
Date: Tue, 05 May 2009 07:53:44 -0700
Message-ID: <27031.1241535224@death.nxdomain.ibm.com>
References: <9a2da8520905050632sa9a4935md668387339c748a0@mail.gmail.com> <9a2da8520905050645s31c62a9bhdd0a5b60ae9ce52c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Deepjyoti Kakati <dkakati73@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41520 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbZEEOyJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 10:54:09 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n45EpY3n007678
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 08:51:34 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n45ErrKs214574
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 08:53:53 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n45Erhi8006278
	for <netdev@vger.kernel.org>; Tue, 5 May 2009 08:53:51 -0600
In-reply-to: <9a2da8520905050645s31c62a9bhdd0a5b60ae9ce52c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Deepjyoti Kakati <dkakati73@gmail.com> wrote:

> I am having the following issue with a fedora10 (2.6.27) type install=
ation.
>
>setup: my bonding and vlan topology
> ----------------------------------------------------
>
>qemu(eth0)-----tap0-----bridge0----bond3.vlan----bond3
>                                                                   |--=
---bond2
>                                                                   |
>    + ---{eth3, eth4}
>                                                                   |
>             in
>                                                                   |
>    balance-rr mode}
>  =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0|
>                                                                   |
>
>bond1--+{eth1, eth2}
>
>in balance-rr mode}
>
>bond3 enslaves the bond2 & bond1 in primary-backup bonding mode. I am
>using miimon on all of bond1,2,3 interfaces
>
>eth1,eth2 connect to switch1 via a etherchannel
>eth3, eth4 connect to switch2 via a etherchannel
>all these four ports allow the same vlans.
>
>now I desired to put my qemu virtual machine eth0 into a particular vl=
an so
>created the bond3.vlan and hooked it into the bridge.
>
>problem:
>------------
>from the qemu I ping a IP address of a router beyond the two switches.
>
>the ARP request goes out of bond1 which is the active_slave
>
>due to same vlans, the ARP request =C2=A0floods back into my box via t=
he {eth3,eth4}
>from the other switch.
>
>my version of kernel is supposed to have the bonding driver fix which
>discards broadcasts/multicasts except a few cases for the inactive sla=
ve of a
>primary-backup pair.(the skb_bond work)
>
>but a tcpdump on the bridge0 or bond3.vlan indicates this 2nd arp
>request pkt is also being seen - apparently bond3 isnt dropping them.

	Your problem is ultimately because nesting of bonds does not
quite work.  Bonding does not really process incoming packets in the
usual sense; there's just a minimal check to assign the packet to the
proper device, and a check to see if it should be dropped.  This check
is done one time only, for the bottommost level of bond (the one to
which the receiving device is enslaved to).  For the VLAN case, the VLA=
N
input processing will immediately thereafter assign the packet to the
VLAN device.

	My question for you is: what do you want to achieve with this
type of topology?  There are going to be a few issues with it, other
than what you've found already.  For one, the active-backup won't fail
over until all slaves of the active bond (bond1 or bond2) have failed.

	I'm not sure what your workload is, but I would rarely recommend
using balance-rr for anything (it often leads to out of order packet
delivery).  I would hazard to guess that you're trying to optimize a
single TCP/IP stream's throughput, and balance-rr will do that to a
degree, at the expense of overall throughput.

	In your case, if the interconnects between switch1 and switch2
and the final destinations are not all faster than the eth1 - eth4
devices, you ultimately won't have any increase in throughput, because
the switch uplinks will be limiting the available bandwidth.  If the
interconnects are all faster, and the final destinations are running
etherchannel or the like, you'll see out of order delivery.  Your singl=
e
stream may see roughly a 50% increase in throughput for TCP/IP (for two
slaves of the same speed, i.e., 1.5 Gb/sec for two 1 Gb/sec slaves) but
at a lower efficiency.

	My usual recommendation for this type of configuration is to use
802.3ad mode, particularly with a recent kernel with changes to 802.3ad
to support the recent ad_select option:

ad_select

        Specifies the 802.3ad aggregation selection logic to use.  The
        possible values and their effects are:

        stable or 0

                The active aggregator is chosen by largest aggregate
                bandwidth.

                Reselection of the active aggregator occurs only when a=
ll
                slaves of the active aggregator are down or the active
                aggregator has no slaves.

                This is the default value.

        bandwidth or 1

                The active aggregator is chosen by largest aggregate
                bandwidth.  Reselection occurs if:

                - A slave is added to or removed from the bond

                - Any slave's link state changes

                - Any slave's 802.3ad association state changes

                - The bond's adminstrative state changes to up

        count or 2

                The active aggregator is chosen by the largest number o=
f
                ports (slaves).  Reselection occurs as described under =
the
                "bandwidth" setting, above.

        The bandwidth and count selection policies permit failover of
        802.3ad aggregations when partial failure of the active aggrega=
tor
        occurs.  This keeps the aggregator with the highest availabilit=
y
        (either in bandwidth or in number of ports) active at all times=
=2E

        This option was added in bonding version 3.4.0.


	Setting this option to "bandwidth" or "count" permits 802.3ad to
be configured for "gang failover," e.g.:

			bond0
	eth0	eth1	eth2	eth3
	!	!	!	!
	[switch 1]	[switch 2]


	In this case, (eth0, eth1) and (eth2, eth3) will be put together
into aggregators, and one will be selected automatically to be the
active aggregator.  Should either slave of the active aggregator fail,
the ad_select policy will cause a reselection of the active aggregator.
This, in the end, should keep the "best" aggregator active at all times=
=2E

	This does require the switches to support 802.3ad, but that's
fairly common these days.  802.3ad does not support a round-robin type
of transmit policy, so if you are heavily dependent on that, this may
not work for you.

	I don't follow Fedora development, so I don't know if their
current kernels support this option or not.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
