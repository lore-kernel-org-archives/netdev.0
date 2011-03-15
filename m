From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Tue, 15 Mar 2011 18:36:34 +0200
Message-ID: <4D7F9592.5050408@iki.fi>
References: <998769.91206.qm@web39301.mail.mud.yahoo.com> <1300203277.2927.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Doug Kehn <rdkehn@yahoo.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64941 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351Ab1COQgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 12:36:44 -0400
Received: by wwa36 with SMTP id 36so960689wwa.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 09:36:42 -0700 (PDT)
In-Reply-To: <1300203277.2927.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/15/2011 05:34 PM, Eric Dumazet wrote:
> Le lundi 14 mars 2011 =C3=A0 16:34 -0700, Doug Kehn a =C3=A9crit :
>> I'm running kernel version 2.6.36 on ARM XSCALE (big-endian) and mul=
ticast over a multipoint GRE tunnel isn't working.  For my architecture=
, this worked on 2.6.26.8.  For x86, multicast over a multipoint GRE tu=
nnel worked with kernel version 2.6.31 but failed with version 2.6.35. =
 Multicast over a multipoint GRE tunnel fails because ipgre_header() fa=
ils the 'if (iph->daddr)' check and reutrns -t->hlen.  ipgre_header() i=
s being called, from neigh_connected_output(), with a non-null daddr; t=
he contents of daddr is zero.
>>
>> Reverting the ip_gre.c patch posted in http://marc.info/?l=3Dlinux-n=
etdev&m=3D126762491525281&w=3D2 resolves the problem.  (Reviewing the H=
EAD of net-next-2.6 it appears that ipgre_header() remains unchanged fr=
om 2.6.36.)
>>
>> The configuration used to discover/diagnose the problem:
>>
>> ip tunnel add tun1 mode gre key 11223344 ttl 64 csum remote any
>> ip link set dev tun1 up
>> ip link set dev tun1 multicast on
>> ip addr flush dev tun1
>> ip addr add 10.40.92.114/24 broadcast 10.40.92.255 dev tun1
>>
>> 12: tun1: <MULTICAST,NOARP,UP,10000> mtu 1468 qdisc noqueue
>>     link/gre 0.0.0.0 brd 0.0.0.0
>>     inet 10.40.92.114/24 brd 10.40.92.255 scope global tun1
>>
>> Then attempt:
>> ping -I tun1 224.0.0.9
>>
>> Are additional configuration steps now required for multicast over m=
ultipoint GRE tunnel or is ipgre_header() in error?
>=20
> Hi Doug
>=20
> CC Timo Teras <timo.teras@iki.fi>
>=20
> I would do a partial revert of Timo patch, but this means initial
> concern should be addressed ?
>=20
> (Timo mentioned :=20
> 	If the NOARP packets are not dropped, ipgre_tunnel_xmit() will
> 	take rt->rt_gateway (=3D NBMA IP) and use that for route
> 	look up (and may lead to bogus xfrm acquires).)
>=20
>=20
> Is the following works for you ?

I have memory that _header() is called with daddr being valid pointer,
but pointing to zero memory. So basically my situation would break with
this.

The above configuration would be fixable by setting broadcast to tun1
interface explicitly. But I'm not sure if the above configuration is
somehow different that it'd need to work.

Basically how things work on send path is:
 1. arp_constructor maps multicast address to NUD_NOARP
 2. arp_mc_map in turn copies dev->broadcast to haddr
    (so you get the ip packet pointing to zero ip)
    - i assumed normally gre tunnels would have the
      broadcast address set
 3. ipgre_tunnel_xmit checks for daddr=3D=3D0 and uses the
    rt_gateway then, which would map to the multicast
    address

So I assume that the above ping command not working would end up sendin=
g
gre encapsulated packet where both the inner and outer IP address is th=
e
same multicast address?

Looks like my patch also broke the default behaviour that if one has
such GRE tunnel, and you send unicast packets, it would default the lin=
k
destination to be same as the inner destination. Not sure if this would
be useful.

So basically my situation is undistinguishable from the above one. The
only difference is that the above problems only with multicast, and I'm
having with unicast.

I think the fundamental problem is that arp_mc_map maps the multicast
address to zeroes (due to device broadcast being zero).

Could we instead maybe do something like:

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 7927589..372448a 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -215,6 +215,12 @@ int arp_mc_map(__be32 addr, u8 *haddr, struct
net_device *dev, int dir)
        case ARPHRD_INFINIBAND:
                ip_ib_mc_map(addr, dev->broadcast, haddr);
                return 0;
+       case ARPHRD_IPGRE:
+               if (dev->broadcast)
+                       memcpy(haddr, dev->broadcast, dev->addr_len);
+               else
+                       memcpy(haddr, &addr, sizeof(addr));
+               return 0;
        default:
                if (dir) {
                        memcpy(haddr, dev->broadcast, dev->addr_len);


