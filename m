From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control
 flags to ip l2tp add tunnel
Date: Wed, 27 Apr 2016 13:21:30 +0100
Message-ID: <CAEwTi7SkMrgxpPi-EuC2UDiwv7L0-vdRAhtdAYLgnbnw5H-Eig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Wang Shanker <shankerwangmiao@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:40206 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752220AbcD0M0u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 08:26:50 -0400
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id 2E1038E391
	for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 13:21:31 +0100 (BST)
Received: by mail-wm0-f50.google.com with SMTP id e201so36221092wme.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 05:21:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 April 2016 at 15:15, Wang Shanker <shankerwangmiao@gmail.com> wro=
te:
> Hi, all
>
> It=E2=80=99s my first time to contribute to such an important open so=
urce project. Things began when I upgraded my server, called "Server A"=
, form ubuntu 14.04 to 16.04, which is shipped with new kernel version,=
 4.4. After upgrade, I soon found a l2tp tunnel between this server and=
 another linux server, called "Server B", via ipv6 broke down. Here is =
the network topology:
>
>   +----------+                    +----------+
>   | Server A | -- IPV6 Network -- | Server B |
>   +----------+                    +----------+
>
> The l2tp tunnel was encapsulated in udp datagrams. All the configurat=
ion was normal and could work after I reverted the kernel on Server A t=
o original version.
>
> Here is what i did to create the tunnel:
>
> ```
> on Server A:
>
> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::aa=
aa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086
> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_ses=
sion_id 86
> ip l s l2tpeth0 up
>
> on Server B:
>
> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 local 2001:db8::aaa=
a remote 2001:db8::bbbb udp_sport 1086 udp_dport 1086
> ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_ses=
sion_id 86
> ip l s l2tpeth0 up
>
> ```
>
> When I used tcpdump to diagnose the problem, I got such result:
>
> ```
> on Server A:
>
> arping -i l2tpeth0 -0 1.2.3.4
>
> on Server B:
>
> tcpdump -i eth0 -n port 1086  -v
>
> 21:35:57.818810 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad ud=
p cksum 0x0000 -> 0x1140!] UDP, length 54
> 21:35:58.820572 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad ud=
p cksum 0x0000 -> 0x1140!] UDP, length 54
> 21:35:59.822216 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad ud=
p cksum 0x0000 -> 0x1140!] UDP, length 54
>
> ```
>
> After looking into kernel source, I found out that in this commit a n=
ew feature to set udp6 checksum to zero in commit 6b649fe, which added =
`L2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_ATTR_UDP_ZERO_CSUM6_TX`.
>
> As a result, I added `udp_csum`, `udp6_csum_tx`, `udp6_csum_rx` contr=
ol flags to `ip l2tp add tunnel` to control those attributes about chec=
ksum.
>
> Using this to create the tunnel instead on Server A:
>
> ```
> ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::aa=
aa local 2001:db8::bbbb udp_sport 1086 udp_dport 1086 udp6_csum_tx on u=
dp6_csum_rx on
> ```
>
> I finally got:
>
> ```
> on Server A:
>
> arping -i l2tpeth0 -0 1.2.3.4
>
> on Server B:
>
> tcpdump -i eth0 -n port 1086  -v
>
> 22:07:03.844297 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp su=
m ok] UDP, length 54
> 22:07:04.845717 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp su=
m ok] UDP, length 54
> 22:07:05.847965 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17)=
 payload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp su=
m ok] UDP, length 54
>
> tcpdump -i l2tpeth0 -v
>
> 22:10:35.691326 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has =
1.2.3.4 tell 0.0.0.0, length 28
> 22:10:36.693627 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has =
1.2.3.4 tell 0.0.0.0, length 28
> 22:10:37.695010 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has =
1.2.3.4 tell 0.0.0.0, length 28
> 22:10:38.697121 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has =
1.2.3.4 tell 0.0.0.0, length 28
>
> ```
>
> It seems to work. However, is it the real point that should be fixed =
and does my patch fix it well? I need your suggestion.

This seems reasonable to me. It is good to provide user control of
L2TP checksum options.

However, there is a problem with your patch. The netlink attributes
you are accessing to control checksums are flags, not u8 values.

Maybe the default checksum setting for such l2tp tunnels should be
changed in the l2tp kernel code to match the previous behaviour where
IPv6 checksums were disabled?

>
>
> ---
>  ip/ipl2tp.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
>
> diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
> index 3c8ee93..67a6482 100644
> --- a/ip/ipl2tp.c
> +++ b/ip/ipl2tp.c
> @@ -56,6 +56,8 @@ struct l2tp_parm {
>
>         uint16_t pw_type;
>         uint16_t mtu;
> +       int udp6_csum_tx:1;
> +       int udp6_csum_rx:1;
>         int udp_csum:1;
>         int recv_seq:1;
>         int send_seq:1;
> @@ -117,6 +119,9 @@ static int create_tunnel(struct l2tp_parm *p)
>         if (p->encap =3D=3D L2TP_ENCAPTYPE_UDP) {
>                 addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local=
_udp_port);
>                 addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_=
udp_port);
> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_CSUM, p->udp_cs=
um);
> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_TX, =
p->udp6_csum_tx);
> +               addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_RX, =
p->udp6_csum_rx);
>         }
>
>         if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
> @@ -282,6 +287,14 @@ static int get_response(struct nlmsghdr *n, void=
 *arg)
>                 p->l2spec_len =3D rta_getattr_u8(attrs[L2TP_ATTR_L2SP=
EC_LEN]);
>
>         p->udp_csum =3D !!attrs[L2TP_ATTR_UDP_CSUM];
> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
> +         p->udp6_csum_tx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZERO=
_CSUM6_TX]);
> +       else
> +         p->udp6_csum_tx =3D 1;
> +       if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
> +         p->udp6_csum_rx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZERO=
_CSUM6_RX]);
> +       else
> +         p->udp6_csum_rx =3D 1;
>         if (attrs[L2TP_ATTR_COOKIE])
>                 memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
>                        p->cookie_len =3D RTA_PAYLOAD(attrs[L2TP_ATTR_=
COOKIE]));
> @@ -470,6 +483,9 @@ static void usage(void)
>         fprintf(stderr, "          tunnel_id ID peer_tunnel_id ID\n")=
;
>         fprintf(stderr, "          [ encap { ip | udp } ]\n");
>         fprintf(stderr, "          [ udp_sport PORT ] [ udp_dport POR=
T ]\n");
> +       fprintf(stderr, "          [ udp_csum { on | off } ]\n");
> +       fprintf(stderr, "          [ udp6_csum_tx { on | off } ]\n");
> +       fprintf(stderr, "          [ udp6_csum_rx { on | off } ]\n");
>         fprintf(stderr, "Usage: ip l2tp add session [ name NAME ]\n")=
;
>         fprintf(stderr, "          tunnel_id ID\n");
>         fprintf(stderr, "          session_id ID peer_session_id ID\n=
");
> @@ -500,6 +516,8 @@ static int parse_args(int argc, char **argv, int =
cmd, struct l2tp_parm *p)
>         /* Defaults */
>         p->l2spec_type =3D L2TP_L2SPECTYPE_DEFAULT;
>         p->l2spec_len =3D 4;
> +       p->udp6_csum_rx =3D 1;
> +       p->udp6_csum_tx =3D 1;
>
>         while (argc > 0) {
>                 if (strcmp(*argv, "encap") =3D=3D 0) {
> @@ -569,6 +587,33 @@ static int parse_args(int argc, char **argv, int=
 cmd, struct l2tp_parm *p)
>                         if (get_u16(&uval, *argv, 0))
>                                 invarg("invalid port\n", *argv);
>                         p->peer_udp_port =3D uval;
> +               } else if (strcmp(*argv, "udp_csum") =3D=3D 0) {
> +                       NEXT_ARG();
> +                       if (strcmp(*argv, "on") =3D=3D 0) {
> +                               p->udp_csum =3D 1;
> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
> +                               p->udp_csum =3D 0;
> +                       } else {
> +                               invarg("invalid option for udp_csum\n=
", *argv);
> +                       }
> +               } else if (strcmp(*argv, "udp6_csum_rx") =3D=3D 0) {
> +                       NEXT_ARG();
> +                       if (strcmp(*argv, "on") =3D=3D 0) {
> +                               p->udp6_csum_rx =3D 1;
> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
> +                               p->udp6_csum_rx =3D 0;
> +                       } else {
> +                               invarg("invalid option for udp6_csum_=
rx\n", *argv);
> +                       }
> +               } else if (strcmp(*argv, "udp6_csum_tx") =3D=3D 0) {
> +                       NEXT_ARG();
> +                       if (strcmp(*argv, "on") =3D=3D 0) {
> +                               p->udp6_csum_tx =3D 1;
> +                       } else if (strcmp(*argv, "off") =3D=3D 0) {
> +                               p->udp6_csum_tx =3D 0;
> +                       } else {
> +                               invarg("invalid option for udp6_csum_=
tx\n", *argv);
> +                       }
>                 } else if (strcmp(*argv, "offset") =3D=3D 0) {
>                         __u8 uval;
>
> --
> 2.5.2
>
