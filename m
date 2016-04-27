From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: Re: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control flags to ip l2tp add tunnel
Date: Thu, 28 Apr 2016 01:06:30 +0800
Message-ID: <AFE6B2C1-93B5-4782-870D-2C6C81BF6F52@gmail.com>
References: <CAEwTi7SkMrgxpPi-EuC2UDiwv7L0-vdRAhtdAYLgnbnw5H-Eig@mail.gmail.com> <FD67CA88-0731-4DD7-AC78-5A4B922810D6@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36043 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbcD0RGc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 13:06:32 -0400
Received: by mail-pa0-f68.google.com with SMTP id i5so5548036pag.3
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 10:06:31 -0700 (PDT)
In-Reply-To: <FD67CA88-0731-4DD7-AC78-5A4B922810D6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> =D4=DA 2016=C4=EA4=D4=C227=C8=D5=A3=AC23:33=A3=ACWang Shanker <shanke=
rwangmiao@gmail.com> =D0=B4=B5=C0=A3=BA
>=20
>=20
>=20
>> =D4=DA 2016=C4=EA4=D4=C227=C8=D5=A3=AC20:21=A3=ACJames Chapman <jcha=
pman@katalix.com> =D0=B4=B5=C0=A3=BA
>>=20
>> On 26 April 2016 at 15:15, Wang Shanker <shankerwangmiao@gmail.com> =
wrote:
>>> Hi, all
>>>=20
>>> It=A1=AFs my first time to contribute to such an important open sou=
rce project. Things began when I upgraded my server, called "Server A",=
 form ubuntu 14.04 to 16.04, which is shipped with new kernel version, =
4.4. After upgrade, I soon found a l2tp tunnel between this server and =
another linux server, called "Server B", via ipv6 broke down. Here is t=
he network topology:
>>>=20
>>> +----------+                    +----------+
>>> | Server A | -- IPV6 Network -- | Server B |
>>> +----------+                    +----------+
>>>=20
>>> The l2tp tunnel was encapsulated in udp datagrams. All the configur=
ation was normal and could work after I reverted the kernel on Server A=
 to original version.
>>>=20
>>> Here is what i did to create the tunnel:
>>>=20
>>> ```
>>> on Server A:
>>>=20
>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::=
aaaa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086
>>> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_s=
ession_id 86
>>> ip l s l2tpeth0 up
>>>=20
>>> on Server B:
>>>=20
>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 local 2001:db8::a=
aaa remote 2001:db8::bbbb udp_sport 1086 udp_dport 1086
>>> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_s=
ession_id 86
>>> ip l s l2tpeth0 up
>>>=20
>>> ```
>>>=20
>>> When I used tcpdump to diagnose the problem, I got such result:
>>>=20
>>> ```
>>> on Server A:
>>>=20
>>> arping -i l2tpeth0 -0 1.2.3.4
>>>=20
>>> on Server B:
>>>=20
>>> tcpdump -i eth0 -n port 1086  -v
>>>=20
>>> 21:35:57.818810 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad =
udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>> 21:35:58.820572 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad =
udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>> 21:35:59.822216 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad =
udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>>=20
>>> ```
>>>=20
>>> After looking into kernel source, I found out that in this commit a=
 new feature to set udp6 checksum to zero in commit 6b649fe, which adde=
d `L2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_ATTR_UDP_ZERO_CSUM6_TX`.
>>>=20
>>> As a result, I added `udp_csum`, `udp6_csum_tx`, `udp6_csum_rx` con=
trol flags to `ip l2tp add tunnel` to control those attributes about ch=
ecksum.
>>>=20
>>> Using this to create the tunnel instead on Server A:
>>>=20
>>> ```
>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::=
aaaa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086 udp6_csum_tx on=
 udp6_csum_rx on
>>> ```
>>>=20
>>> I finally got:
>>>=20
>>> ```
>>> on Server A:
>>>=20
>>> arping -i l2tpeth0 -0 1.2.3.4
>>>=20
>>> on Server B:
>>>=20
>>> tcpdump -i eth0 -n port 1086  -v
>>>=20
>>> 22:07:03.844297 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp =
sum ok] UDP, length 54
>>> 22:07:04.845717 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp =
sum ok] UDP, length 54
>>> 22:07:05.847965 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (1=
7) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp =
sum ok] UDP, length 54
>>>=20
>>> tcpdump -i l2tpeth0 -v
>>>=20
>>> 22:10:35.691326 ARP, Ethernet (len 6), IPv4 (len 4), Request who-ha=
s 1.2.3.4 tell 0.0.0.0, length 28
>>> 22:10:36.693627 ARP, Ethernet (len 6), IPv4 (len 4), Request who-ha=
s 1.2.3.4 tell 0.0.0.0, length 28
>>> 22:10:37.695010 ARP, Ethernet (len 6), IPv4 (len 4), Request who-ha=
s 1.2.3.4 tell 0.0.0.0, length 28
>>> 22:10:38.697121 ARP, Ethernet (len 6), IPv4 (len 4), Request who-ha=
s 1.2.3.4 tell 0.0.0.0, length 28
>>>=20
>>> ```
>>>=20
>>> It seems to work. However, is it the real point that should be fixe=
d and does my patch fix it well? I need your suggestion.
>>=20
>> This seems reasonable to me. It is good to provide user control of
>> L2TP checksum options.
>>=20
>> However, there is a problem with your patch. The netlink attributes
>> you are accessing to control checksums are flags, not u8 values.
>=20
> I=A1=AFm not so familiar with kernel code. However, in `<linux/l2tp.h=
>` :=20
>=20
> ```
>=20
> /*
> * ATTR types defined for L2TP
> */
> enum {
> 	L2TP_ATTR_NONE,			/* no data */
> // ...
> 	L2TP_ATTR_IP6_DADDR,		/* struct in6_addr */
> 	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* u8 */
> 	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* u8 */
> // ...
>=20
> }
> ```
>=20
> isn=A1=AFt L2TP_ATTR_UDP_ZERO_CSUM6_TX a u8 value? Or should I use `a=
ddattr` instead of `addattr8`?=20
>=20
>>=20
>> Maybe the default checksum setting for such l2tp tunnels should be
>> changed in the l2tp kernel code to match the previous behaviour wher=
e
>> IPv6 checksums were disabled?
>=20
> I think so. However, I=A1=AFm confused with those code.
>=20
> From the name of the attrs `L2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_AT=
TR_UDP_ZERO_CSUM6_RX`, I=20
> can tell that when those flags are set, the checksum will be zero. Al=
so, according to the=20
> comment of commit 6b649fe in kernel source, =A1=B0Added new L2TP conf=
iguration options to allow=20
> TX and RX of zero checksums in IPv6. Default is not to use them.=A1=B1=
, checksums shouldn't have
> been zero by default. However, in fact, they are. I think there may b=
e some bugs in kernel
> source.=20

I think I=A1=AFve got the bug. Here is the patch for kernel

---
 net/l2tp/l2tp_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index afca2eb..6edfa99 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net *ne=
t,
                        memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
                               sizeof(udp_conf.peer_ip6));
                        udp_conf.use_udp6_tx_checksums =3D
-                           cfg->udp6_zero_tx_checksums;
+                         ! cfg->udp6_zero_tx_checksums;
                        udp_conf.use_udp6_rx_checksums =3D
-                           cfg->udp6_zero_rx_checksums;
+                         ! cfg->udp6_zero_rx_checksums;
                } else
 #endif
                {
--=20


>>=20
>>>=20
>>>=20
>>> ---
>>> ip/ipl2tp.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>>> 1 file changed, 45 insertions(+)
>>>=20
>>> diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
>>> index 3c8ee93..67a6482 100644
>>> --- a/ip/ipl2tp.c
>>> +++ b/ip/ipl2tp.c
>>> @@ -56,6 +56,8 @@ struct l2tp_parm {
>>>=20
>>>       uint16_t pw_type;
>>>       uint16_t mtu;
>>> +       int udp6_csum_tx:1;
>>> +       int udp6_csum_rx:1;
>>>       int udp_csum:1;
>>>       int recv_seq:1;
>>>       int send_seq:1;
>>> @@ -117,6 +119,9 @@ static int create_tunnel(struct l2tp_parm *p)
>>>       if (p->encap =3D=3D L2TP_ENCAPTYPE_UDP) {
>>>               addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local=
_udp_port);
>>>               addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_=
udp_port);
>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_CSUM, p->udp_=
csum);
>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_TX=
, p->udp6_csum_tx);
>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_RX=
, p->udp6_csum_rx);
>>>       }
>>>=20
>>>       if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
>>> @@ -282,6 +287,14 @@ static int get_response(struct nlmsghdr *n, vo=
id *arg)
>>>               p->l2spec_len =3D rta_getattr_u8(attrs[L2TP_ATTR_L2SP=
EC_LEN]);
>>>=20
>>>       p->udp_csum =3D !!attrs[L2TP_ATTR_UDP_CSUM];
>>> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
>>> +         p->udp6_csum_tx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZE=
RO_CSUM6_TX]);
>>> +       else
>>> +         p->udp6_csum_tx =3D 1;
>>> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
>>> +         p->udp6_csum_rx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZE=
RO_CSUM6_RX]);
>>> +       else
>>> +         p->udp6_csum_rx =3D 1;
>>>       if (attrs[L2TP_ATTR_COOKIE])
>>>               memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
>>>                      p->cookie_len =3D RTA_PAYLOAD(attrs[L2TP_ATTR_=
COOKIE]));
>>> @@ -470,6 +483,9 @@ static void usage(void)
>>>       fprintf(stderr, "          tunnel_id ID peer_tunnel_id ID\n")=
;
>>>       fprintf(stderr, "          [ encap { ip | udp } ]\n");
>>>       fprintf(stderr, "          [ udp_sport PORT ] [ udp_dport POR=
T ]\n");
>>> +       fprintf(stderr, "          [ udp_csum { on | off } ]\n");
>>> +       fprintf(stderr, "          [ udp6_csum_tx { on | off } ]\n"=
);
>>> +       fprintf(stderr, "          [ udp6_csum_rx { on | off } ]\n"=
);
>>>       fprintf(stderr, "Usage: ip l2tp add session [ name NAME ]\n")=
;
>>>       fprintf(stderr, "          tunnel_id ID\n");
>>>       fprintf(stderr, "          session_id ID peer_session_id ID\n=
");
>>> @@ -500,6 +516,8 @@ static int parse_args(int argc, char **argv, in=
t cmd, struct l2tp_parm *p)
>>>       /* Defaults */
>>>       p->l2spec_type =3D L2TP_L2SPECTYPE_DEFAULT;
>>>       p->l2spec_len =3D 4;
>>> +       p->udp6_csum_rx =3D 1;
>>> +       p->udp6_csum_tx =3D 1;
>>>=20
>>>       while (argc > 0) {
>>>               if (strcmp(*argv, "encap") =3D=3D 0) {
>>> @@ -569,6 +587,33 @@ static int parse_args(int argc, char **argv, i=
nt cmd, struct l2tp_parm *p)
>>>                       if (get_u16(&uval, *argv, 0))
>>>                               invarg("invalid port\n", *argv);
>>>                       p->peer_udp_port =3D uval;
>>> +               } else if (strcmp(*argv, "udp_csum") =3D=3D 0) {
>>> +                       NEXT_ARG();
>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>> +                               p->udp_csum =3D 1;
>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
>>> +                               p->udp_csum =3D 0;
>>> +                       } else {
>>> +                               invarg("invalid option for udp_csum=
\n", *argv);
>>> +                       }
>>> +               } else if (strcmp(*argv, "udp6_csum_rx") =3D=3D 0) =
{
>>> +                       NEXT_ARG();
>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>> +                               p->udp6_csum_rx =3D 1;
>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
>>> +                               p->udp6_csum_rx =3D 0;
>>> +                       } else {
>>> +                               invarg("invalid option for udp6_csu=
m_rx\n", *argv);
>>> +                       }
>>> +               } else if (strcmp(*argv, "udp6_csum_tx") =3D=3D 0) =
{
>>> +                       NEXT_ARG();
>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>> +                               p->udp6_csum_tx =3D 1;
>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
>>> +                               p->udp6_csum_tx =3D 0;
>>> +                       } else {
>>> +                               invarg("invalid option for udp6_csu=
m_tx\n", *argv);
>>> +                       }
>>>               } else if (strcmp(*argv, "offset") =3D=3D 0) {
>>>                       __u8 uval;
>>>=20
>>> --
>>> 2.5.2
