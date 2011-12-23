From: Chris Boot <bootc@bootc.net>
Subject: Re: igb + balance-rr + bridge + IPv6 = no go without promiscuous
 mode
Date: Fri, 23 Dec 2011 10:56:57 +0000
Message-ID: <4EF45E79.6020803@bootc.net>
References: <4EF44CEE.5020704@bootc.net> <CAADHFRBWR0JJNmPzQA3=40s5a6fZ3TJEoC0aWzo+3wXruEZC5A@mail.gmail.com> <4EF454C7.8020305@bootc.net> <4EF45C7D.8090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yuna.grokhost.net ([87.117.228.63]:52997 "EHLO
	yuna.grokhost.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754069Ab1LWK47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 05:56:59 -0500
In-Reply-To: <4EF45C7D.8090409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/12/2011 10:48, Nicolas de Peslo=C3=BCan wrote:
> [ Forwarded to netdev, because two previous e-mail erroneously sent i=
n=20
> HTML ]
>
> Le 23/12/2011 11:15, Chris Boot a =C3=A9crit :
>> On 23/12/2011 09:52, Nicolas de Peslo=C3=BCan wrote:
>>>
>>>
>>> Le 23 d=C3=A9c. 2011 10:42, "Chris Boot" <bootc@bootc.net=20
>>> <mailto:bootc@bootc.net>> a =C3=A9crit :
>>> >
>>> > Hi folks,
>>> >
>>> > As per Eric Dumazet and Dave Miller, I'm opening up a separate=20
>>> thread on this issue.
>>> >
>>> > I have two identical servers in a cluster for running KVM virtual=
=20
>>> machines. They each have a
>>> single connection to the Internet (irrelevant for this) and two=20
>>> gigabit connections between each
>>> other for cluster replication, etc... These two connections are in =
a=20
>>> balance-rr bonded connection,
>>> which is itself member of a bridge that the VMs attach to. I'm=20
>>> running v3.2-rc6-140-gb9e26df on
>>> Debian Wheezy.
>>> >
>>> > When the bridge is brought up, IPv4 works fine but IPv6 does not.=
=20
>>> I can use neither the
>>> automatic link-local on the brid ge nor the static global address I=
=20
>>> assign. Neither machine can
>>> perform neighbour discovery over the link until I put the bond=20
>>> members (eth0 and eth1) into
>>> promiscuous mode.  I can do this either with tcpdump or 'ip link se=
t=20
>>> dev ethX promisc on' and this
>>> is enough to make the link spring to life.
>>>
>>> For as far as I remember, setting bond0 to promisc should set the=20
>>> bonding member to promisc too.
>>> And inserting bond0 into br0 should set bond0 to promisc... So=20
>>> everything should be in promisc
>>> mode anyway... but you shoudn't have to do it by hand.
>>>
>>
>> Sorry, I should have added that I tried this. Setting bond0 or br0 t=
o=20
>> promisc has no effect. I
>> discovered this by running tcpdump on br0 first, then bond0, then=20
>> eventually each bond member in
>> turn. Only at the last stage did things jump to life.
>>
>>> >
>>> > This cluster is not currently live so I can easily test patches=20
>>> and various configurations.
>>>
>>> Can you try to remove the bonding part, connecting eth0 and eth1=20
>>> directly to br0 and see if it
>>> works better? (This is a test ony. I perfectly understand that you=20
>>> would loose balance-rr in this
>>> setup.)
>>>
>>
>> Good call. Let's see.
>>
>> I took br0 and bond0 apart, took eth0 and eth1 out of enforced=20
>> promisc mode, then manually built a
>> br0 with eth0 in only so I didn't cause a network loop. Adding eth0=20
>> to br0 did not make it go into
>> promisc mode, but IPv6 does work over this setup. I also made sure i=
p=20
>> -6 neigh was empty on both
>> machines before I started.
>>
>> I then decided to try the test with just the bond0 in balance-rr=20
>> mode. Once again I took everything
>> down and ensured no promisc mode and no ip -6 neigh. I noticed bond0=
=20
>> wasn't getting a link-local and
>> I found out for some reason=20
>> /proc/sys/net/ipv6/conf/bond0/disable_ipv6 was set on both servers s=
o I
>> set it to 0. That brought things to life.
>>
>> So then I put it all back together again and it didn't work. I once=20
>> again noticed disable_ipv6 was
>> set on the bond0 interfaces, now part of the bridge. Toggling this o=
n=20
>> the _bond_ interface made
>> things work again.
>>
>> What's setting disable_ipv6? Should this be having an impact if the=20
>> port is part of a bridge?

Hmm, as a further update... I brought up my VMs on the bridge with=20
disable_ipv6 turned off. The VMs on one host couldn't see what was on=20
the other side of the bridge (on the other server) until I turned=20
promisc back on manually. So it's not entirely disable_ipv6's fault.

Chris

--=20
Chris Boot
bootc@bootc.net
