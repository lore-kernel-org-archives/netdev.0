From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Fri, 28 Apr 2017 13:54:51 +0200
Message-ID: <59032D8B.1010801@aoifes.com>
References: <58F9FD64.80506@aoifes.com> <20170425082741.59428876@xeon-e3>
 <5901DE9F.1070005@aoifes.com> <20170427130450.GL17172@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-02-2.dondominio.net ([31.214.176.35]:59836 "EHLO
        smtp-relay-02-2.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756255AbdD1Lyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 07:54:55 -0400
In-Reply-To: <20170427130450.GL17172@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/17 15:04, Andrew Lunn wrote:
> On Thu, Apr 27, 2017 at 02:05:51PM +0200, Rafa Corvillo wrote:
>> On 25/04/17 17:27, Stephen Hemminger wrote:
>>> On Fri, 21 Apr 2017 14:39:00 +0200
>>> Rafa Corvillo <rafael.corvillo@aoifes.com> wrote:
>>>
>>>> We are working in an ARMv7 embedded system running kernel 4.9 (LEDE build).
>>>> It is an imx6 board with 2 ethernet interfaces. One of them is connected to
>>>> a Marvell switch.
>>>>
>>>> The schema of the system is the following:
>>>>
>
> Hi Rafa
>
> Your ASCII art got messed up somewhere. Is this the correct
> reconstruction?

Yes, this is the schema.

>
>     +-------------------+ eth0
>     |                   +--+
>     |                   |  |
>     | Embedded system   +--+
>     |                   |
>     |      ARMv7        |
>     |                   | Marvell 88E8057(sky2)     +-------------+
>     |                   +--+                     +--+             +--+ eth1
>     |                   |  +---------------------+  |             |  +------+
>     |                   +--+      CPU port       +--+ mv88e6176   +--+
>     +------+--+---------+                           |             |
> emulated  |  |                                     |             |
> GPIO      +--+                                  +--+             +--+ eth2
> MDIO       +-----------------------------------+   |             |  +------+
>                                  MDIO            +--+             +--+
>                                                     +-------------+
>
> I assume you are using DSA? Since this is LEDE, it could be swconfig,
> but the bridge configuration you mentioned would not make sense for
> swconfig.

Yes, we use DSA driver. We don't use swconfig to configure the Marvell 
switch. Our board has two ethernet interfaces (eth0 and marvell) using 
sky2 driver. The marvell interface is connected to an external Marvell 
switch (mv88e6176) with four ethernet ports (but we only use two of 
them, eth1 and eth2). The Marvell switch is configured with the MDIO 
protocol, that we emulate through GPIOS (mdio-gpio kernel module), and 
the DSA driver is used to works with the Marvell switch.

We have the ethernet interfaces in the same bridge:

config interface 'lan'
         option type 'bridge'
         option ifname 'eth0 eth1 eth2'
         option proto 'static'
         option ipaddr '192.168.1.100'
         option netmask '255.255.255.0'
         option ip6assign '60'

root@LEDE:/# brctl show
bridge name     bridge id               STP enabled     interfaces
br-lan          7fff.00d01274f069       no              eth0
                                                         eth1
                                                         eth2
root@LEDE:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN 
group default qlen 1
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
     inet 127.0.0.1/8 scope host lo
        valid_lft forever preferred_lft forever
     inet6 ::1/128 scope host
        valid_lft forever preferred_lft forever
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel 
master br-lan state DOWN group default qlen 1000
     link/ether 00:d0:12:74:f0:69 brd ff:ff:ff:ff:ff:ff
3: ifb0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default 
qlen 32
     link/ether be:80:bc:5e:63:c3 brd ff:ff:ff:ff:ff:ff
4: ifb1: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default 
qlen 32
     link/ether 0a:1d:8d:06:e3:5d brd ff:ff:ff:ff:ff:ff
5: gre0@NONE: <NOARP> mtu 1476 qdisc noop state DOWN group default qlen 1
     link/gre 0.0.0.0 brd 0.0.0.0
6: gretap0@NONE: <BROADCAST,MULTICAST> mtu 1462 qdisc noop state DOWN 
group default qlen 1000
     link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:ff
7: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN 
group default qlen 1000
     link/ether e2:0b:10:b8:b7:b0 brd ff:ff:ff:ff:ff:ff
8: teql0: <NOARP> mtu 1500 qdisc noop state DOWN group default qlen 100
     link/void
9: can0: <NOARP,ECHO> mtu 16 qdisc noop state DOWN group default qlen 10
     link/can
10: marvell: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel 
state UP group default qlen 1000
     link/ether aa:64:73:91:09:a9 brd ff:ff:ff:ff:ff:ff
     inet6 fe80::a864:73ff:fe91:9a9/64 scope link
        valid_lft forever preferred_lft forever
11: eth1@marvell: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc 
noqueue master br-lan switchid 00000000 state LOWERLAYERDOWN group 
default qlen 1000
     link/ether aa:64:73:91:09:a9 brd ff:ff:ff:ff:ff:ff
12: eth2@marvell: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc 
noqueue master br-lan switchid 00000000 state UP group default qlen 1000
     link/ether aa:64:73:91:09:a9 brd ff:ff:ff:ff:ff:ff
13: eth3@marvell: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 
00000000 state DOWN group default qlen 1000
     link/ether aa:64:73:91:09:a9 brd ff:ff:ff:ff:ff:ff
14: eth4@marvell: <BROADCAST,MULTICAST> mtu 1500 qdisc noop switchid 
00000000 state DOWN group default qlen 1000
     link/ether aa:64:73:91:09:a9 brd ff:ff:ff:ff:ff:ff
15: br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
state UP group default qlen 1000
     link/ether 00:d0:12:74:f0:69 brd ff:ff:ff:ff:ff:ff
     inet 192.168.1.100/24 brd 192.168.1.255 scope global br-lan
        valid_lft forever preferred_lft forever
     inet6 fd7b:a43b:e93e::1/60 scope global noprefixroute
        valid_lft forever preferred_lft forever
     inet6 fe80::2d0:12ff:fe74:f069/64 scope link
        valid_lft forever preferred_lft forever


We have this configuration working on a kernel 4.1 and including patches 
to upgrade dsa/mv88e6xxx to kernel version 4.3 (5acf4d0, Wed, 27 May 
2015 15:32:15 -0700) "[PATCH] blk: rq_data_dir() should not return a 
boolean."

>
>>>> If I connect the eth1/eth2, the link is up and I can do ping through it.
>>>> But, once
>>>> I start sending a heavy traffic load the link fails and the kernel sends the
>>>> following messages:
>>>>
>>>> [   48.557140] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.564964] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.572110] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.579263] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.586417] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.593573] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   48.600718] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   54.877567] net_ratelimit: 6 callbacks suppressed
>>>> [   54.882293] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>> [   61.413552] sky2 0000:04:00.0 marvell: rx error, status 0x5f20010
>>>> length 1518
>>>
>>> The status error bits are in sky2.h
>>> 0x5f20010 is
>>>       05f2 frame length => 1522
>>>       0010 Too long err
>>>
>>> That means the packet was longer than the configured MTU.
>>> You are probably getting packets with VLAN tag but have not configured
>>> a VLAN.
>
> Since you are using DSA, you will have DSA tags enabled on frames
> to/from the switch. This adds an extra 8 byte header in the frame.  My
> guess is, it is this header, not the VLAN tag which is causing you MTU
> issues.

But it is strange because, as I have said above, we have the same 
configuration working properly on a kernel 4.1 (with OpenWrt), and we 
have the MTU set to 1500.

>
> I think this is the first time i've seen sky2 used in a DSA
> setup. mv643xx or mvneta is generally what is used, when using Marvell
> chipsets. These drivers are more lenient about MTU, and are happy to
> pass frames with additional headers.
>

We use the mv88e6xxx (as our switch is mv88e6176) and it depends on DSA 
driver in the kernel (isn't it?).

>> Thanks for the information. I have increased the MTU value to 1550
>> (workaround) and it works if sends traffic (with iperf) from my
>> computer to the unit. But, if I send traffic outside the unit, I get
>> a new error message and link goes down:
>
> Changing the MTU like this is not a good fix. It will allow you to
> receive frames which are bigger, but it also means the local network
> stack will generate bigger frames to be transmitted. You probably need
> to modify the sky2 driver to allow it to receive frames bigger than
> the interface MTU, by about 8 bytes.

Should the DSA driver remove the DSA tags before pass the frames to sky2 
interface?

>
>> [ 4901.032989] sky2 0000:04:00.0 marvell: tx timeout
>> [ 4904.722670] sky2 0000:04:00.0 marvell: Link is up at 1000 Mbps,
>> full duplex, flow control both
>
> Between the sky2 and the switch, do you have two back-to-back PHYs or
> are you connecting the RGMII interfaces together?

I think that we have two back-to-back PHYs, but I am going to double 
check this with the hardware team.

Thanks,
Rafa

>
>      Andrew
>
