From: Seblu <seblu@seblu.net>
Subject: Re: bnx2 vlan issue
Date: Thu, 17 Mar 2011 19:02:18 +0100
Message-ID: <AANLkTi=rOjHZt_F01UfunrTm=2r1BO5QGFDeV9XyKX4G@mail.gmail.com>
References: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39016 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab1CQSCi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 14:02:38 -0400
Received: by qwk3 with SMTP id 3so2275214qwk.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 11:02:38 -0700 (PDT)
In-Reply-To: <AANLkTik0BOuDj5wmfHabZx_OzXDROtDLR2qtqUqQu4ko@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 3:51 PM, Seblu <seblu@seblu.net> wrote:
> Good Afternoon Gentleman,
>
> I've an issue with a 2.6.38 (vanilla) on a debian unstable distro. I
> attached an lspci and lshw about hardware. I also attached debian
> network config file.
>
> My host is a host kvm which run vm on different networks (vlan). I
> have 2 1Gbit/s card (eth0, eth1) and 1 10Gbit/s card (eth2).
> I use bonding (bond0) mode 1 on the 1Gbit/s cards.
>
> vlan 14 and 15 are only availlable trought 1G cards. Same tagging on
> both cards in switch. 14 is untagged (need for pxe) and 15 is tagged.
>
> Every network on my host is in a bridge. Eg:
> vlan 15 is in br15 by bond0.15 as member,
> vlan 14 is in br14 by bond0 as member,
> vlan 20 is in br20 by eth2.20
>
> The issue is simple, packets from vlan 15 which are tagged are not
> visible on bond0.15 but in bond0 (see capture). Like if there is no
> vlan.
>
>
> in dmesg in see something like : "8021q: adding VLAN 0 to HW filter o=
n
> device bond0".
> Maybe there is something wrong with hardware filtering?
>
> I don't find a way to disable hw vlan filtering.
> # ethtool -K eth1 rxvlan off
> Cannot set device flag settings: Invalid argument
>
> I found a way to make thing work and don't work by one command.
> # rmmod bonding
> # ifdown br14
> # ifdown br15
> # ifup --force bond0
> # ifup --force bond0.15
> # ifup --force br15
> =3D> i can ping my ip on 15 working
> if i make ifup --force br14, i lost connectivity on vlan 15.
>
> I don't have isssue when bond0 is not member of br14. So vlan on
> bonding seems to be broken.
>
I done more test this afternoon.

I set an ip on bond0, ip on bond0.15 is still pingeable.
I created a bridge. Until I don't add bond0 in my bridge, bond0.15 is
still pingeable.



Now is see a relation with a similar issue come with 2.6.37. This becom=
e
eth0 =3D> network 1
eth0.42 =3D>  network 2
br0 =3D> eth0 + eth1 (network1)

Since 2.6.37, eth0.42 (network2) become unavailable, and it is only
possible to do something like:
br0 =3D> eth0 + eth1 (network1)
br0.42 =3D> network 2

To conclude:
add a bonding interface in a bridge, kill vlan setted on it.
add a real interface in a bridge, kill vlan setted on it.

So, i don't see how we can restore a per bridge vlan. Why do you
remove this possibility in 2.6.37?

--=20
S=E9bastien Luttringer
www.seblu.net
