From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: route cache flush??
Date: Fri, 03 Feb 2012 10:48:37 -0500
Message-ID: <4F2C01D5.5060902@earthlink.net>
References: <4F2BF63E.1@earthlink.net> <1328281515.2157.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:38246
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755214Ab2BCPsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 10:48:39 -0500
In-Reply-To: <1328281515.2157.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2012 10:05 AM, Eric Dumazet wrote:
> Le vendredi 03 f=C3=A9vrier 2012 =C3=A0 09:59 -0500, Stephen Clark a =
=C3=A9crit :
>   =20
>> Hello,
>>
>> I have been beating my head against the wall for 2 days trying to
>> figure why when I change a route and do a "ip route flush cache"
>> it still takes up to a minute for packets to start using the new
>> route.
>>
>> Is there a step I am missing?
>>
>> kernel is 2.6.32
>>
>>     =20
> Nothing comes to mind, please share more information ?
>
>   =20
Sure

I have a box "A" with 2 interfaces ips 2.2.2.1 and 3.3.3.1 going to=20
another box "B" that has 3 nics 2.2.2.254
3.3.3.254 and 1.1.1.254 there is a third box "C" with ip 1.1.1.1. Box B=
=20
is to simulate the net.

I have 2 vpns on box A going to box C. The default rt on A is=20
2.2.2.254.  If I don't do anything else routing wise
esp packet originated on 1.1.1.1 come 3.3.3.1 on box A but the response=
=20
packet from 3.3.3.1 goes out the
default route. This works OK in the lab but in the field the isps=20
generally drop packet that have a source address
that doesn't match their subnet.

So I have found on the net how to set up a simple rule to route packets=
=20
with src address 3.3.3.1 back out that interface.
$ ip r s
2.2.2.0/24 dev eth1  proto kernel  scope link  src 2.2.2.1
3.3.3.0/24 dev eth2  proto kernel  scope link  src 3.3.3.1
10.0.128.0/17 dev eth0  proto kernel  scope link  src 10.0.133.22
default via 2.2.2.254 dev eth1
L703103:~
$ ip r s table second
default via 3.3.3.254 dev eth2  src 3.3.3.1
L703103:~
$ ip rule list
0:      from all lookup local
200:    from 3.3.3.1 lookup second
32766:  from all lookup main
32767:  from all lookup default

So I run a script to disable the src route an flush the cache.$=20
date;sudo /usr/local/pgsql/storeproc/programs/src_rt_off.sh
=46ri Feb  3 10:20:16 EST 2012  --- notice the time.
++ id -un
+ '[' root '!=3D' root ']'
+ /sbin/ip route delete default table second
+ /sbin/ip rule delete table second
+ /sbin/ip route flush cache
+ /sbin/ip rule list
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default


This is a tcpdump of the interface with 3.3.3.1 ip address - I ran the=20
script at 10:20:16
Notice how long before response quit going out this interface and switc=
h=20
to the default
route. I see similar behavior when I reinstall the src route and flush=20
the cache.

10:20:19.102448 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x24e)=
,=20
length 116
10:20:19.103221 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x24e)=
,=20
length 116
10:20:19.498523 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x24f)=
,=20
length 116
10:20:19.498701 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x24f)=
,=20
length 116
10:20:30.704175 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x250)=
,=20
length 116
10:20:30.704357 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x250)=
,=20
length 116
10:20:34.217349 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x251)=
,=20
length 116
10:20:34.218150 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x251)=
,=20
length 116
10:20:34.333011 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x252)=
,=20
length 116
10:20:34.333795 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x252)=
,=20
length 116
10:20:40.826996 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x253)=
,=20
length 116
10:20:40.827775 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x253)=
,=20
length 116
10:20:41.412308 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x254)=
,=20
length 116
10:20:41.413081 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x254)=
,=20
length 116
10:20:41.910528 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x255)=
,=20
length 116
10:20:41.910711 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x255)=
,=20
length 116
10:20:42.413504 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x256)=
,=20
length 116
10:20:42.414260 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x256)=
,=20
length 116
10:20:43.413755 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x257)=
,=20
length 116
10:20:43.414510 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x257)=
,=20
length 116
10:20:44.413807 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x258)=
,=20
length 116
10:20:44.414560 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x258)=
,=20
length 116
10:20:49.468466 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x259)=
,=20
length 116
10:20:49.469267 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x259)=
,=20
length 116
10:20:49.576539 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x25a)=
,=20
length 116
10:20:49.577318 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25a)=
,=20
length 116
10:20:53.116021 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25b)=
,=20
length 116
10:20:53.116196 IP 3.3.3.1 > 1.1.1.1: ESP(spi=3D0x05690af9,seq=3D0x25b)=
,=20
length 116
10:21:04.320972 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25c)=
,=20
length 116<<<<<<<
10:21:04.720342 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25d)=
,=20
length 116
10:21:04.808653 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25e)=
,=20
length 116
10:21:08.422372 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x25f)=
,=20
length 116
10:21:09.423730 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x260)=
,=20
length 116
10:21:10.424971 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x261)=
,=20
length 116
10:21:11.425469 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x262)=
,=20
length 116
10:21:15.525572 IP 1.1.1.1 > 3.3.3.1: ESP(spi=3D0x021bd1a9,seq=3D0x263)=
,=20
length 116










--=20

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
