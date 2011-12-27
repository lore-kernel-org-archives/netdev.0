From: Chris Boot <bootc@bootc.net>
Subject: Re: igb + balance-rr + bridge + IPv6 = no go without promiscuous
 mode
Date: Tue, 27 Dec 2011 21:53:00 +0000
Message-ID: <4EFA3E3C.4020706@bootc.net>
References: <4EF44CEE.5020704@bootc.net> <CAADHFRBWR0JJNmPzQA3=40s5a6fZ3TJEoC0aWzo+3wXruEZC5A@mail.gmail.com> <4EF454C7.8020305@bootc.net> <4EF45C7D.8090409@gmail.com> <4EF45E79.6020803@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yuna.grokhost.net ([87.117.228.63]:54776 "EHLO
	yuna.grokhost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab1L0Vwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 16:52:54 -0500
In-Reply-To: <4EF45E79.6020803@bootc.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/12/2011 10:56, Chris Boot wrote:
> On 23/12/2011 10:48, Nicolas de Peslo=C3=BCan wrote:
>> [ Forwarded to netdev, because two previous e-mail erroneously sent =
in
>> HTML ]
>>
>> Le 23/12/2011 11:15, Chris Boot a =C3=A9crit :
>>> On 23/12/2011 09:52, Nicolas de Peslo=C3=BCan wrote:
>>>>
>>>>
>>>> Le 23 d=C3=A9c. 2011 10:42, "Chris Boot" <bootc@bootc.net
>>>> <mailto:bootc@bootc.net>> a =C3=A9crit :
>>>> >
>>>> > Hi folks,
>>>> >
>>>> > As per Eric Dumazet and Dave Miller, I'm opening up a separate
>>>> thread on this issue.
>>>> >
>>>> > I have two identical servers in a cluster for running KVM virtua=
l
>>>> machines. They each have a
>>>> single connection to the Internet (irrelevant for this) and two
>>>> gigabit connections between each
>>>> other for cluster replication, etc... These two connections are in=
 a
>>>> balance-rr bonded connection,
>>>> which is itself member of a bridge that the VMs attach to. I'm
>>>> running v3.2-rc6-140-gb9e26df on
>>>> Debian Wheezy.
>>>> >
>>>> > When the bridge is brought up, IPv4 works fine but IPv6 does not=
=2E
>>>> I can use neither the
>>>> automatic link-local on the brid ge nor the static global address =
I
>>>> assign. Neither machine can
>>>> perform neighbour discovery over the link until I put the bond
>>>> members (eth0 and eth1) into
>>>> promiscuous mode. I can do this either with tcpdump or 'ip link se=
t
>>>> dev ethX promisc on' and this
>>>> is enough to make the link spring to life.
>>>>
>>>> For as far as I remember, setting bond0 to promisc should set the
>>>> bonding member to promisc too.
>>>> And inserting bond0 into br0 should set bond0 to promisc... So
>>>> everything should be in promisc
>>>> mode anyway... but you shoudn't have to do it by hand.
>>>>
>>>
>>> Sorry, I should have added that I tried this. Setting bond0 or br0 =
to
>>> promisc has no effect. I
>>> discovered this by running tcpdump on br0 first, then bond0, then
>>> eventually each bond member in
>>> turn. Only at the last stage did things jump to life.
>>>
>>>> >
>>>> > This cluster is not currently live so I can easily test patches
>>>> and various configurations.
>>>>
>>>> Can you try to remove the bonding part, connecting eth0 and eth1
>>>> directly to br0 and see if it
>>>> works better? (This is a test ony. I perfectly understand that you
>>>> would loose balance-rr in this
>>>> setup.)
>>>>
>>>
>>> Good call. Let's see.
>>>
>>> I took br0 and bond0 apart, took eth0 and eth1 out of enforced
>>> promisc mode, then manually built a
>>> br0 with eth0 in only so I didn't cause a network loop. Adding eth0
>>> to br0 did not make it go into
>>> promisc mode, but IPv6 does work over this setup. I also made sure =
ip
>>> -6 neigh was empty on both
>>> machines before I started.
>>>
>>> I then decided to try the test with just the bond0 in balance-rr
>>> mode. Once again I took everything
>>> down and ensured no promisc mode and no ip -6 neigh. I noticed bond=
0
>>> wasn't getting a link-local and
>>> I found out for some reason
>>> /proc/sys/net/ipv6/conf/bond0/disable_ipv6 was set on both servers =
so I
>>> set it to 0. That brought things to life.
>>>
>>> So then I put it all back together again and it didn't work. I once
>>> again noticed disable_ipv6 was
>>> set on the bond0 interfaces, now part of the bridge. Toggling this =
on
>>> the _bond_ interface made
>>> things work again.
>>>
>>> What's setting disable_ipv6? Should this be having an impact if the
>>> port is part of a bridge?
>
> Hmm, as a further update... I brought up my VMs on the bridge with
> disable_ipv6 turned off. The VMs on one host couldn't see what was on
> the other side of the bridge (on the other server) until I turned
> promisc back on manually. So it's not entirely disable_ipv6's fault.

Hi,

I don't want this to get lost around the Christmas break, so I'm just=20
resending it. I'm still seeing the same behaviour as before.

 From above:

>>>> For as far as I remember, setting bond0 to promisc should set the
>>>> bonding member to promisc too.
>>>> And inserting bond0 into br0 should set bond0 to promisc... So
>>>> everything should be in promisc
>>>> mode anyway... but you shoudn't have to do it by hand.

This definitely doesn't happen, at least according to 'ip link show |=20
grep PROMISC'.

Chris

--=20
Chris Boot
bootc@bootc.net
