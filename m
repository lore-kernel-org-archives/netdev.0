From: Jan Stancek <jstancek@redhat.com>
Subject: bridge is not forwaring ICMP6 neighbor solicitation to KVM guest
Date: Mon, 3 Mar 2014 14:47:15 -0500 (EST)
Message-ID: <2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linus.luessing@web.de, netdev@vger.kernel.org,
	Florian Westphal <fwestpha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:45057 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaCCTrQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 14:47:16 -0500
In-Reply-To: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a host A running 3.14.0-rc5 with one KVM guest, where network
is set up to use bridge:
# brctl show
bridge name     bridge id               STP enabled     interfaces
br1             8000.0023aeed1a00       no              eno1
                                                        vnet0
virbr0          8000.000000000000       yes

I'm seeing an issue where bridge (sometimes) stops forwarding ICMP6
neighbor solicitation packets to KVM guest and as result KVM guest does=
n't
respond with neighbor advertisement.

I was trying to narrow down conditions when this happens and eventually
came to following packet sent by other host B on same network:

Ethernet II, Src: Hewlett-_47:93:1c (00:21:5a:47:93:1c), Dst: IPv6mcast=
_00:00:00:01 (33:33:00:00:00:01)
    Destination: IPv6mcast_00:00:00:01 (33:33:00:00:00:01)
        Address: IPv6mcast_00:00:00:01 (33:33:00:00:00:01)
        .... ..1. .... .... .... .... =3D LG bit: Locally administered =
address (this is NOT the factory default)
        .... ...1 .... .... .... .... =3D IG bit: Group address (multic=
ast/broadcast)
    Source: Hewlett-_47:93:1c (00:21:5a:47:93:1c)
        Address: Hewlett-_47:93:1c (00:21:5a:47:93:1c)
        .... ..0. .... .... .... .... =3D LG bit: Globally unique addre=
ss (factory default)
        .... ...0 .... .... .... .... =3D IG bit: Individual address (u=
nicast)
    Type: IPv6 (0x86dd)
Internet Protocol Version 6, Src: 100:0:600:0:78fb:100:: (100:0:600:0:7=
8fb:100::), Dst: ff02::1 (ff02::1)
    0110 .... =3D Version: 6
        [0110 .... =3D This field makes the filter "ip.version =3D=3D 6=
" possible: 6]
    .... 0000 0000 .... .... .... .... .... =3D Traffic class: 0x000000=
00
        .... 0000 00.. .... .... .... .... .... =3D Differentiated Serv=
ices Field: Default (0x00000000)
        .... .... ..0. .... .... .... .... .... =3D ECN-Capable Transpo=
rt (ECT): Not set
        .... .... ...0 .... .... .... .... .... =3D ECN-CE: Not set
    .... .... .... 0000 0000 0000 0000 0000 =3D Flowlabel: 0x00000000
    Payload length: 32
    Next header: IPv6 hop-by-hop option (0)
    Hop limit: 1
    Source: 100:0:600:0:78fb:100:: (100:0:600:0:78fb:100::)
    Destination: ff02::1 (ff02::1)
    Hop-by-Hop Option
        Next header: ICMPv6 (58)
        Length: 0 (8 bytes)
        IPv6 Option (Router Alert)
            Type: Router Alert (5)
            Length: 2
            Router Alert: MLD (0)
        IPv6 Option (Pad1)
            Type: Pad1 (0)
            Pad1
        IPv6 Option (Pad1)
            Type: Pad1 (0)
            Pad1
Internet Control Message Protocol v6
    Type: Multicast Listener Query (130)
    Code: 0
    Checksum: 0xf9c5 [correct]
    Maximum Response Delay [ms]: 1000
    Reserved: 0000
    Multicast Address: :: (::)

The reason I think this packet is related is because when I send same e=
xact
packet I'm often hitting same issue - bridge stops forwarding ICMP6 nei=
gh.
solicitation packets to KVM guest.

My current way to reproduce this is:
0. host B IP / MAC is: 2620:52:0:1040:221:5aff:fe47:931c / 00:21:5a:47:=
93:1c
   guest IP / MAC is: 2620:52:0:1040:5056:ff:fe00:29 / 52:56:00:00:00:2=
9
1. host B is sending neigh solicit packets every 5 seconds with KVM gue=
st IP
   using ns6 from ipv6toolkit: http://www.si6networks.com/tools/ipv6too=
lkit/
   with parameters:
   --src-address=3D2620:52:0:1040:221:5aff:fe47:931c --dst-address=3Dff=
02::1:ff00:0029
   -t 2620:52:0:1040:5056:ff:fe00:29 --link-src-address=3D00:21:5a:47:9=
3:1c
   --source-lla-opt=3D00:21:5a:47:93:1c --link-dst-address=3D33:33:ff:0=
0:00:29
   tcpdump running on guest can see both solicit and advertisement pack=
ets
2. wait ~5 minutes
3. host B sends Multicast Listener Query packet described above
4. tcpdump running on guest is no longer seeing any neigh solicit packe=
ts

I also found out that issue goes away if I do any of following:
1. disable CONFIG_BRIDGE_IGMP_SNOOPING=3Dy
2. echo 0 > /sys/devices/virtual/net/br1/bridge/multicast_snooping
3. make following change:
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index ef66365..8ccc0bf 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1562,8 +1562,8 @@ static int br_multicast_ipv6_rcv(struct net_bridg=
e *br,
                return 0;

        /* Prevent flooding this packet if there is no listener present=
 */
-       if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
-               BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;
+/*     if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
+               BR_INPUT_SKB_CB(skb)->mrouters_only =3D 1;*/

        if (ip6h->nexthdr !=3D IPPROTO_HOPOPTS ||
            ip6h->payload_len =3D=3D 0)

Change above makes me suspect following patch:
  commit 3c3769e63301fd92fcaf51870c371583dd0282ce
  Author: Linus L=C3=83=C2=BCssing <linus.luessing@web.de>
  Date:   Wed Sep 4 02:13:39 2013 +0200
    bridge: apply multicast snooping to IPv6 link-local, too

Please let me know if I can assist in any way to help resolve this.

Regards,
Jan
