From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control
 flags to ip l2tp add tunnel
Date: Thu, 28 Apr 2016 15:50:47 +0100
Message-ID: <CAEwTi7SyKKh4de6TKYiuypWfOhzOCeD6k2uTLUfCmzQmvsNHWw@mail.gmail.com>
References: <CAEwTi7SkMrgxpPi-EuC2UDiwv7L0-vdRAhtdAYLgnbnw5H-Eig@mail.gmail.com>
	<FD67CA88-0731-4DD7-AC78-5A4B922810D6@gmail.com>
	<AFE6B2C1-93B5-4782-870D-2C6C81BF6F52@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wang Shanker <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40250 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752668AbcD1Ouw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 10:50:52 -0400
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 620868E017
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:50:48 +0100 (BST)
Received: by mail-wm0-f53.google.com with SMTP id g17so45766772wme.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 07:50:48 -0700 (PDT)
In-Reply-To: <AFE6B2C1-93B5-4782-870D-2C6C81BF6F52@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, that looks like the problem.

The comments in l2tp.h which indicate that the csum attributes are u8
values are wrong. Code in net/l2tp/l2tp_netlink.c accesses these
attributes using nla_get_flag().

Please submit a patch to fix l2tp_tunnel_sock_create(). Include good
change notes and your signed-off-by tag so that it gets reviewed. See
Documentation/SubmittingPatches if you haven't submitted a kernel
patch here before.

On 27 April 2016 at 18:06, Wang Shanker <shankerwangmiao@gmail.com> wro=
te:
>
>
>> =E5=9C=A8 2016=E5=B9=B44=E6=9C=8827=E6=97=A5=EF=BC=8C23:33=EF=BC=8CW=
ang Shanker <shankerwangmiao@gmail.com> =E5=86=99=E9=81=93=EF=BC=9A
>>
>>
>>
>>> =E5=9C=A8 2016=E5=B9=B44=E6=9C=8827=E6=97=A5=EF=BC=8C20:21=EF=BC=8C=
James Chapman <jchapman@katalix.com> =E5=86=99=E9=81=93=EF=BC=9A
>>>
>>> On 26 April 2016 at 15:15, Wang Shanker <shankerwangmiao@gmail.com>=
 wrote:
>>>> Hi, all
>>>>
>>>> It=E2=80=99s my first time to contribute to such an important open=
 source project. Things began when I upgraded my server, called "Server=
 A", form ubuntu 14.04 to 16.04, which is shipped with new kernel versi=
on, 4.4. After upgrade, I soon found a l2tp tunnel between this server =
and another linux server, called "Server B", via ipv6 broke down. Here =
is the network topology:
>>>>
>>>> +----------+                    +----------+
>>>> | Server A | -- IPV6 Network -- | Server B |
>>>> +----------+                    +----------+
>>>>
>>>> The l2tp tunnel was encapsulated in udp datagrams. All the configu=
ration was normal and could work after I reverted the kernel on Server =
A to original version.
>>>>
>>>> Here is what i did to create the tunnel:
>>>>
>>>> ```
>>>> on Server A:
>>>>
>>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8:=
:aaaa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086
>>>> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_=
session_id 86
>>>> ip l s l2tpeth0 up
>>>>
>>>> on Server B:
>>>>
>>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 local 2001:db8::=
aaaa remote 2001:db8::bbbb udp_sport 1086 udp_dport 1086
>>>> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_=
session_id 86
>>>> ip l s l2tpeth0 up
>>>>
>>>> ```
>>>>
>>>> When I used tcpdump to diagnose the problem, I got such result:
>>>>
>>>> ```
>>>> on Server A:
>>>>
>>>> arping -i l2tpeth0 -0 1.2.3.4
>>>>
>>>> on Server B:
>>>>
>>>> tcpdump -i eth0 -n port 1086  -v
>>>>
>>>> 21:35:57.818810 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad=
 udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>>> 21:35:58.820572 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad=
 udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>>> 21:35:59.822216 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad=
 udp cksum 0x0000 -> 0x1140!] UDP, length 54
>>>>
>>>> ```
>>>>
>>>> After looking into kernel source, I found out that in this commit =
a new feature to set udp6 checksum to zero in commit 6b649fe, which add=
ed `L2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_ATTR_UDP_ZERO_CSUM6_TX`.
>>>>
>>>> As a result, I added `udp_csum`, `udp6_csum_tx`, `udp6_csum_rx` co=
ntrol flags to `ip l2tp add tunnel` to control those attributes about c=
hecksum.
>>>>
>>>> Using this to create the tunnel instead on Server A:
>>>>
>>>> ```
>>>> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8:=
:aaaa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086 udp6_csum_tx o=
n udp6_csum_rx on
>>>> ```
>>>>
>>>> I finally got:
>>>>
>>>> ```
>>>> on Server A:
>>>>
>>>> arping -i l2tpeth0 -0 1.2.3.4
>>>>
>>>> on Server B:
>>>>
>>>> tcpdump -i eth0 -n port 1086  -v
>>>>
>>>> 22:07:03.844297 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp=
 sum ok] UDP, length 54
>>>> 22:07:04.845717 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp=
 sum ok] UDP, length 54
>>>> 22:07:05.847965 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (=
17) payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp=
 sum ok] UDP, length 54
>>>>
>>>> tcpdump -i l2tpeth0 -v
>>>>
>>>> 22:10:35.691326 ARP, Ethernet (len 6), IPv4 (len 4), Request who-h=
as 1.2.3.4 tell 0.0.0.0, length 28
>>>> 22:10:36.693627 ARP, Ethernet (len 6), IPv4 (len 4), Request who-h=
as 1.2.3.4 tell 0.0.0.0, length 28
>>>> 22:10:37.695010 ARP, Ethernet (len 6), IPv4 (len 4), Request who-h=
as 1.2.3.4 tell 0.0.0.0, length 28
>>>> 22:10:38.697121 ARP, Ethernet (len 6), IPv4 (len 4), Request who-h=
as 1.2.3.4 tell 0.0.0.0, length 28
>>>>
>>>> ```
>>>>
>>>> It seems to work. However, is it the real point that should be fix=
ed and does my patch fix it well? I need your suggestion.
>>>
>>> This seems reasonable to me. It is good to provide user control of
>>> L2TP checksum options.
>>>
>>> However, there is a problem with your patch. The netlink attributes
>>> you are accessing to control checksums are flags, not u8 values.
>>
>> I=E2=80=99m not so familiar with kernel code. However, in `<linux/l2=
tp.h>` :
>>
>> ```
>>
>> /*
>> * ATTR types defined for L2TP
>> */
>> enum {
>>       L2TP_ATTR_NONE,                 /* no data */
>> // ...
>>       L2TP_ATTR_IP6_DADDR,            /* struct in6_addr */
>>       L2TP_ATTR_UDP_ZERO_CSUM6_TX,    /* u8 */
>>       L2TP_ATTR_UDP_ZERO_CSUM6_RX,    /* u8 */
>> // ...
>>
>> }
>> ```
>>
>> isn=E2=80=99t L2TP_ATTR_UDP_ZERO_CSUM6_TX a u8 value? Or should I us=
e `addattr` instead of `addattr8`?
>>
>>>
>>> Maybe the default checksum setting for such l2tp tunnels should be
>>> changed in the l2tp kernel code to match the previous behaviour whe=
re
>>> IPv6 checksums were disabled?
>>
>> I think so. However, I=E2=80=99m confused with those code.
>>
>> From the name of the attrs `L2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_A=
TTR_UDP_ZERO_CSUM6_RX`, I
>> can tell that when those flags are set, the checksum will be zero. A=
lso, according to the
>> comment of commit 6b649fe in kernel source, =E2=80=9CAdded new L2TP =
configuration options to allow
>> TX and RX of zero checksums in IPv6. Default is not to use them.=E2=80=
=9D, checksums shouldn't have
>> been zero by default. However, in fact, they are. I think there may =
be some bugs in kernel
>> source.
>
> I think I=E2=80=99ve got the bug. Here is the patch for kernel
>
> ---
>  net/l2tp/l2tp_core.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index afca2eb..6edfa99 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1376,9 +1376,9 @@ static int l2tp_tunnel_sock_create(struct net *=
net,
>                         memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
>                                sizeof(udp_conf.peer_ip6));
>                         udp_conf.use_udp6_tx_checksums =3D
> -                           cfg->udp6_zero_tx_checksums;
> +                         ! cfg->udp6_zero_tx_checksums;
>                         udp_conf.use_udp6_rx_checksums =3D
> -                           cfg->udp6_zero_rx_checksums;
> +                         ! cfg->udp6_zero_rx_checksums;
>                 } else
>  #endif
>                 {
> --
>
>
>>>
>>>>
>>>>
>>>> ---
>>>> ip/ipl2tp.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>>>> 1 file changed, 45 insertions(+)
>>>>
>>>> diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
>>>> index 3c8ee93..67a6482 100644
>>>> --- a/ip/ipl2tp.c
>>>> +++ b/ip/ipl2tp.c
>>>> @@ -56,6 +56,8 @@ struct l2tp_parm {
>>>>
>>>>       uint16_t pw_type;
>>>>       uint16_t mtu;
>>>> +       int udp6_csum_tx:1;
>>>> +       int udp6_csum_rx:1;
>>>>       int udp_csum:1;
>>>>       int recv_seq:1;
>>>>       int send_seq:1;
>>>> @@ -117,6 +119,9 @@ static int create_tunnel(struct l2tp_parm *p)
>>>>       if (p->encap =3D=3D L2TP_ENCAPTYPE_UDP) {
>>>>               addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->loca=
l_udp_port);
>>>>               addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer=
_udp_port);
>>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_CSUM, p->udp=
_csum);
>>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_T=
X, p->udp6_csum_tx);
>>>> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_R=
X, p->udp6_csum_rx);
>>>>       }
>>>>
>>>>       if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
>>>> @@ -282,6 +287,14 @@ static int get_response(struct nlmsghdr *n, v=
oid *arg)
>>>>               p->l2spec_len =3D rta_getattr_u8(attrs[L2TP_ATTR_L2S=
PEC_LEN]);
>>>>
>>>>       p->udp_csum =3D !!attrs[L2TP_ATTR_UDP_CSUM];
>>>> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
>>>> +         p->udp6_csum_tx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_Z=
ERO_CSUM6_TX]);
>>>> +       else
>>>> +         p->udp6_csum_tx =3D 1;
>>>> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
>>>> +         p->udp6_csum_rx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_Z=
ERO_CSUM6_RX]);
>>>> +       else
>>>> +         p->udp6_csum_rx =3D 1;
>>>>       if (attrs[L2TP_ATTR_COOKIE])
>>>>               memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
>>>>                      p->cookie_len =3D RTA_PAYLOAD(attrs[L2TP_ATTR=
_COOKIE]));
>>>> @@ -470,6 +483,9 @@ static void usage(void)
>>>>       fprintf(stderr, "          tunnel_id ID peer_tunnel_id ID\n"=
);
>>>>       fprintf(stderr, "          [ encap { ip | udp } ]\n");
>>>>       fprintf(stderr, "          [ udp_sport PORT ] [ udp_dport PO=
RT ]\n");
>>>> +       fprintf(stderr, "          [ udp_csum { on | off } ]\n");
>>>> +       fprintf(stderr, "          [ udp6_csum_tx { on | off } ]\n=
");
>>>> +       fprintf(stderr, "          [ udp6_csum_rx { on | off } ]\n=
");
>>>>       fprintf(stderr, "Usage: ip l2tp add session [ name NAME ]\n"=
);
>>>>       fprintf(stderr, "          tunnel_id ID\n");
>>>>       fprintf(stderr, "          session_id ID peer_session_id ID\=
n");
>>>> @@ -500,6 +516,8 @@ static int parse_args(int argc, char **argv, i=
nt cmd, struct l2tp_parm *p)
>>>>       /* Defaults */
>>>>       p->l2spec_type =3D L2TP_L2SPECTYPE_DEFAULT;
>>>>       p->l2spec_len =3D 4;
>>>> +       p->udp6_csum_rx =3D 1;
>>>> +       p->udp6_csum_tx =3D 1;
>>>>
>>>>       while (argc > 0) {
>>>>               if (strcmp(*argv, "encap") =3D=3D 0) {
>>>> @@ -569,6 +587,33 @@ static int parse_args(int argc, char **argv, =
int cmd, struct l2tp_parm *p)
>>>>                       if (get_u16(&uval, *argv, 0))
>>>>                               invarg("invalid port\n", *argv);
>>>>                       p->peer_udp_port =3D uval;
>>>> +               } else if (strcmp(*argv, "udp_csum") =3D=3D 0) {
>>>> +                       NEXT_ARG();
>>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>>> +                               p->udp_csum =3D 1;
>>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) =
{
>>>> +                               p->udp_csum =3D 0;
>>>> +                       } else {
>>>> +                               invarg("invalid option for udp_csu=
m\n", *argv);
>>>> +                       }
>>>> +               } else if (strcmp(*argv, "udp6_csum_rx") =3D=3D 0)=
 {
>>>> +                       NEXT_ARG();
>>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>>> +                               p->udp6_csum_rx =3D 1;
>>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) =
{
>>>> +                               p->udp6_csum_rx =3D 0;
>>>> +                       } else {
>>>> +                               invarg("invalid option for udp6_cs=
um_rx\n", *argv);
>>>> +                       }
>>>> +               } else if (strcmp(*argv, "udp6_csum_tx") =3D=3D 0)=
 {
>>>> +                       NEXT_ARG();
>>>> +                       if (strcmp(*argv, "on") =3D=3D 0) {
>>>> +                               p->udp6_csum_tx =3D 1;
>>>> +                       } else if (strcmp(*argv, "off") =3D=3D 0) =
{
>>>> +                               p->udp6_csum_tx =3D 0;
>>>> +                       } else {
>>>> +                               invarg("invalid option for udp6_cs=
um_tx\n", *argv);
>>>> +                       }
>>>>               } else if (strcmp(*argv, "offset") =3D=3D 0) {
>>>>                       __u8 uval;
>>>>
>>>> --
>>>> 2.5.2
>
