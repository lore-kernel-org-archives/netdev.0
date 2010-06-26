From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][BUG-FIX] the problem of checksum checking in UDP protocol
Date: Sat, 26 Jun 2010 07:28:06 +0200
Message-ID: <1277530086.2481.15.camel@edumazet-laptop>
References: <4C19E634.3030703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:41386 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0FZF2O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 01:28:14 -0400
Received: by wwi17 with SMTP id 17so1505897wwi.19
        for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 22:28:12 -0700 (PDT)
In-Reply-To: <4C19E634.3030703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 juin 2010 =C3=A0 17:09 +0800, Shan Wei a =C3=A9crit :
> *Description of Problem*
> When received an UDP packet, if the length parameter in UDP header is=
 less than
> the actual length of payload(including 8 bytes UDP header), and check=
sum parameter
> is calculated including all payload, some NIC devices that supports h=
ardware checksum
> success to check checksum, and set ip_summed with CHECKSUM_UNNECESSAR=
Y flag.=20
> But If we turn off rx-checksumming offload, UDP protocol failed to ch=
eck the checksum.
>=20
> *Step to Reproduce*
> We need to download netwib&netwox tools and then install them only on=
 M1 node.
> On M1 node, execute the below steps.
>=20
>                   M1                                               M2
> 	+---------------------------+			+---------------------------+
> 	|                     eth1  |<---------------> 	|eth0               =
        |           =20
> 	|fe80::225:86ff:fe9d:3efa   |			|fe80::215:17ff:fe71:51f4   |
> 	+---------------------------+			+---------------------------+
>       =20
>   1.  netwox 149 -i fe80::215:17ff:fe71:51f4 -d eth1 -E 0:0:0:0:1:0 -=
e 0:15:17:71:51:f4 -I fe80::200:ff:fe00:100 -c 1
>       This step is to create neighbor cache for spurious source addre=
ss of fe80::200:ff:fe00:100.
>=20
>   2.  netwox 141 -d eth1 -a 0:0:0:0:1:0 -b 0:15:17:71:51:f4 -f 17 -g =
64 -h fe80::200:ff:fe00:100 -i fe80::215:17ff:fe71:51f4 \
>        -o 3333 -p 7 -q 0000000000000000000000000000000000000000000000=
00 -r 34525 -e 32 -s 16 -t 35126
>        This step is to construct an UDPv6 packet that length field(16=
 bytes) less than total payload length(32 bytes).
>=20
> The readable format of this packet that netwox shows.
> Ethernet________________________________________________________.
> | 00:00:00:00:01:00->00:15:17:71:51:F4 type:0x86DD              |
> |_______________________________________________________________|
> IP______________________________________________________________.
> |version| traffic class |              flow label               |
> |___6___|_______0_______|___________________0___________________|
> |        payload length         |  next header  |   hop limit   |
> |___________0x0020=3D32___________|____0x11=3D17____|______64_______|
> |                            source                             |
> |_____________________fe80::200:ff:fe00:100_____________________|
> |                          destination                          |
> |___________________fe80::215:17ff:fe71:51f4____________________|
> UDP_____________________________________________________________.
> |          source port          |       destination port        |
> |__________0x0D05=3D3333__________|___________0x0007=3D7____________|
> |            length             |           checksum            |
> |___________0x0010=3D16___________|_________0x8936=3D35126__________|
> 00 00 00 00  00 00 00 00  00 00 00 00  00 00 00 00  # ...............=
=2E
> 00 00 00 00  00 00 00 00                            # ........
>=20
>=20
> *Actual Results*
>   On M2 note, using ethtool to see the counter about rx_csum_offload.
>   #ethtool -S eth0 | grep csum
>   rx_csum_offload_good: 1
>   rx_csum_offload_errors: 0
>=20
>  #cat /proc/net/snmp6 | grep Udp6=20
>  Udp6InDatagrams                 	1
>  Udp6InErrors                    	0
>=20
> *Expected Results*
>  #ethtool -S eth0 | grep csum
>  rx_csum_offload_good: 0
>  rx_csum_offload_errors: 1
>=20
>  #cat /proc/net/snmp6 | grep Udp6=20
>  Udp6InDatagrams                 	0
>  Udp6InErrors                    	1
>  =20
> *The Reason*
> UDPv6 handles a received packet like this:
> 1. Confirm length of data
>    If length parameter in UDPv6 header is greater than skb->len(actua=
l data length added UDP header),
>    the packet will be dropped. If length parameter in UDPv6 header is=
 lower than skb->len, the data
>    will be trimmed to be equal to length parameter.
>=20
> 2. Then UDPv6 calculates checksum with 40 bytes IPv6 pseudo-header,8 =
bytes UDPv6 header, 8 bytes=20
>    Payload Data. Note that checksum(35126) in UDPv6 header includes 1=
6 bytes redundant data.
>=20
> NIC checks checksum with total data includes redundant data, So the c=
hecksum that hardware calculated
> is different from that UDP did.=20
>=20
> =20
> *The Solution*
> We have reported the problem to Intel E1000e developer, the reply fro=
m Ronciak John is that
> the driver code of e1000e is ok.=20
> About the discuss, see http://comments.gmane.org/gmane.linux.drivers.=
e1000.devel/7077
>=20
> For this case, UDP protocol should not trust the CHECKSUM_UNNECESSARY=
 flag set by driver.
> When UDP protocol received this kind of packet, if NIC hardware check=
ed successfully,
> we reset ip_summed with CHECKSUM_NONE, and UDP protocol checked check=
sum again.
> =20
> (This patch is not complete, it's just for my idea.)
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 1dd1aff..47f7e86 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -723,6 +723,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct u=
dp_table *udptable,
>                 if (ulen < skb->len) {
>                         if (pskb_trim_rcsum(skb, ulen))
>                                 goto short_packet;
> +
> +                       if (skb_csum_unnecessary(skb))
> +                               skb->ip_summed =3D CHECKSUM_NONE;
> +
>                         saddr =3D &ipv6_hdr(skb)->saddr;
>                         daddr =3D &ipv6_hdr(skb)->daddr;
>                         uh =3D udp_hdr(skb);
>=20

I really dont know if this fix is the right one.

pskb_trim_rcsum() already contains a check. Should this check be change=
d
to include yours ?

static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len=
)
{
	if (likely(len >=3D skb->len))
		return 0;
	if (skb->ip_summed =3D=3D CHECKSUM_COMPLETE)
		skb->ip_summed =3D CHECKSUM_NONE;
	return __pskb_trim(skb, len);
}



