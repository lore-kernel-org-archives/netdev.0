From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 20:51:04 +0400
Message-ID: <4E932278.8010802@msgid.tls.msk.ru>
References: <4E90212D.8030009@msgid.tls.msk.ru> <1318091046.5276.22.camel@edumazet-laptop> <4E9097C0.2030307@gmail.com> <20111010101954.GB2840382@jupiter.n2.diac24.net> <4E9307CB.4050704@msgid.tls.msk.ru> <1318259152.3227.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111010151343.GB3260852@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, jeffrey.t.kirsher@intel.com,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:54966 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab1JJQvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 12:51:06 -0400
In-Reply-To: <20111010151343.GB3260852@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

10.10.2011 19:13, David Lamparter wrote:
> On Mon, Oct 10, 2011 at 05:05:52PM +0200, Eric Dumazet wrote:
>>> When pinging this NIC from another machine over VLAN5, I see
>>> ARP packets coming to it, gets recognized and replies going
>>> back, all on vlan 5.  But on the other side, replies comes
>>> WITHOUT a VLAN tag!
>>>
>>> From this NIC's point of view, capturing on whole ethX:
>>>
>>> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 60: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.48.11.2 tell 10.48.11.1, length 42
>>> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 28
>>>
>>> From the partner point of view, also on whole ethX:
>>>
>>> 00:1f:c6:ef:e5:1b > ff:ff:ff:ff:ff:ff, ethertype 802.1Q (0x8100), length 46: vlan 5, p 0, ethertype ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 10.48.11.2 tell 10.48.11.1, length 28
>>> 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype ARP (0x0806), length 60: Ethernet (len 6), IPv4 (len 4), Reply 10.48.11.2 is-at 00:90:27:30:6d:1c, length 46
>>>
>>> So, the tag gets eaten somewhere along the way... ;)
> 
> Hmm. Looks like broken VLAN TX offload, but the driver doesn't even
> implement VLAN offload. Maybe it's broken in its non-implementation...
> 
> Your "partner" is a known-good setup and can be assumed to be working
> correctly? This is over a crossover cable, no evil switches involved?

There are just two machines involved, both connected to the
same _switch_ - no, it is not over cross-over cable.  It's a
good idea to test one, I'll try it tomorrow (will insert a
second "known good" nic into another machine).

The second machine, the "partner", has this NIC:

02:00.0 Ethernet controller: Atheros Communications L1 Gigabit Ethernet (rev b0)

and it is a known-good implementation - it worked with and without vlan
tags (we had a weird mixed tagged/untagged setup) for over 2 years without
any issues, and which works now as well - it's our main server which is
in two VLANs, connected to an interface marked as tagged in the switch.
It communicates with the other machine when that other machine uses
already mentioned VIA RhineIII NIC - which I used to replace this non-working
E100.

So it's 2 machines, one with 2 nics - VIA Rhine (working) and e100 (non-working),
both connected to two "tagged" ports in the switch.  And another, with atl1 NIC,
also connected to a "tagged" port in the switch.

>>> And I can't really recreate the situation which I had - I know
>>> some packets were flowing, so at least ARP worked.  Now it
>>> does not work anymore.
>>
>> What the 'partner' setup looks like ?
>>
>> ip link
>> ip addr
>> ip ro

> 'local' setup too please :)

The setup is quite complex - there are numerous tunnels and virtual
interfaces.  Here are the relevant parts. (Note that `ip addr'
includes information present in `ip link'):

The "Partner" machine, with just one NIC, atl1, ip addr:

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff

3: tls-vlan@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master tls-br state UP
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
Our main vlan, LAN, #1.

4: tls-br: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
    inet 192.168.177.15/26 brd 192.168.177.63 scope global tls-br
A bridge that connects this VLAN#1 and other stuff (virtual machines etc)

6: dmz-vlan@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master dmz-br state UP
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
That's DMZ segment, VLAN#2
...

21: test@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
    inet 10.48.11.1/24 scope global test

This is vlan#5, my test vlan.


The machine with two (working, via-rhine, and non-working, e100):

2: ethx: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff
This is via-rhine, with the MAC address of E100 -- the one which works.

13: eth-tls@ethx: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff
    inet 192.168.177.5/26 brd 192.168.177.63 scope global eth-tls
Our main VLAN#1 (here it's w/o bridge)

14: eth-dmz@ethx: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff
    inet 192.168.177.225/29 brd 192.168.177.231 scope global eth-dmz
DMZ VLAN#2

4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff

The non-working e100.  Here it has the same MAC address as ethx above,
because I explicitly changed ethx to have this MAC, since the $ISP has
it hardcoded for our port on their side.  The tests were done with the
two addresses being original as set up by the hardware, and later on
I also tried to set this MAC to be 00:90:27:30:6d:1d (note the last
digit) - all the same result, packets sent over the iface above shows
on the receiving side as having no vlan tag.

24: test@eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff
    inet 10.48.11.2/24 scope global test

And finally this is the test vlan#5.

tcpdump was run on eth2 here and on eth0 on the first machine.

On both machines tcpdump is of version 4.1.1.

Here's offload information for e100 nic:

# ethtool -k eth2
Offload parameters for eth2:
rx-checksumming: off
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off

It supports (or appears to) some offloading, in particular I
can enable GSO offload, and it even works somehow.


Now, I enabled another pair of VLAN interfaces on these two NICs,
with VLAN#6, and configured both ports in the switch to be parts
of VLAN6 too (tagged).  And voila, everything now works in there.

Two ifaces added, "partner", atl1:

22: test6@eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:1f:c6:ef:e5:1b brd ff:ff:ff:ff:ff:ff
    inet 10.48.6.1/24 scope global test6

this e100:

25: test6@eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
    link/ether 00:90:27:30:6d:1c brd ff:ff:ff:ff:ff:ff
    inet 10.48.6.2/24 scope global test6

Yesterday, the vlan ID where it didn't work was #4, and in #1 it all -
apparently - worked.

I created 2 more pairs of VLAN interfaces and added to the swithc --
it all works just fine.  Here:

# x=8; ip link add link eth2 name test$x type vlan id $x; ip addr add 10.48.$x.2/24 dev test$x; ip link set test$x up

(That's on the e100 side, similar was on atl1 side).  x=6, x=7 and x=8
works just fine.  x=5 does not, ARP replies arrives without VLAN tag
to the atl1 side.

Ok.  So now I can reproduce the initial problem.

So, `ping -s 1469' from atl1 side, so that the resulting packet side
is 1497 bytes (1468 is the largest size that works) -- the packets
does not arrive at e100 side at all - it's 100% quiet in tcpdump there.

When pinging from e100 side and tcpdump'ing on atl1 side (replies does
not come back to e100):

20:49:33.322646 00:90:27:30:6d:1c > 00:1f:c6:ef:e5:1b, ethertype 802.1Q (0x8100), length 1515: vlan 8, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto ICMP (1), length 1497)
    10.48.8.2 > 10.48.8.1: ICMP echo request, id 5785, seq 72, length 1477
20:49:33.322691 00:1f:c6:ef:e5:1b > 00:90:27:30:6d:1c, ethertype 802.1Q (0x8100), length 1515: vlan 8, p 0, ethertype IPv4, (tos 0x0, ttl 64, id 23781, offset 0, flags [none], proto ICMP (1), length 1497)
    10.48.8.1 > 10.48.8.2: ICMP echo reply, id 5785, seq 72, length 1477

So it appears that on e100 side, the _receive_ buffer is too small
somehow.

I'll do some more experiments with VLAN#5 tomorrow, in a clean environment
(maybe using direct cable connection - not cross-over, since GigE should
autodetect this stuff (hopefully)).

Thanks!

/mjt
