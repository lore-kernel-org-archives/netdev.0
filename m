From: Wang Shanker <shankerwangmiao@gmail.com>
Subject: [PATCH] ip: add udp_csum, udp6_csum_tx, udp6_csum_rx control flags to  ip l2tp add tunnel
Date: Tue, 26 Apr 2016 22:15:31 +0800
Message-ID: <797477FE-9982-44B1-9C45-A2459FDF44C9@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35951 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317AbcDZOPe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 10:15:34 -0400
Received: by mail-pa0-f43.google.com with SMTP id bt5so6943150pac.3
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 07:15:33 -0700 (PDT)
Received: from ?IPv6:2402:f000:5:8301:a0d6:2a27:d94a:8091? ([2402:f000:5:8301:a0d6:2a27:d94a:8091])
        by smtp.gmail.com with ESMTPSA id c190sm22642425pfb.33.2016.04.26.07.15.31
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Tue, 26 Apr 2016 07:15:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

It=A1=AFs my first time to contribute to such an important open source =
project. Things began when I upgraded my server, called "Server A", for=
m ubuntu 14.04 to 16.04, which is shipped with new kernel version, 4.4.=
 After upgrade, I soon found a l2tp tunnel between this server and anot=
her linux server, called "Server B", via ipv6 broke down. Here is the n=
etwork topology:

  +----------+                    +----------+
  | Server A | -- IPV6 Network -- | Server B |
  +----------+                    +----------+
 =20
The l2tp tunnel was encapsulated in udp datagrams. All the configuratio=
n was normal and could work after I reverted the kernel on Server A to =
original version.

Here is what i did to create the tunnel:

```
on Server A:

ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::aaaa=
 local 2001:db8::bbbb udp_sport 1086 udp_dport 1086
ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_sessi=
on_id 86
ip l s l2tpeth0 up

on Server B:

ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 local 2001:db8::aaaa =
remote 2001:db8::bbbb udp_sport 1086 udp_dport 1086
ip l2tp add session name l2tpeth0 tunnel_id 86 session_id 86 peer_sessi=
on_id 86
ip l s l2tpeth0 up

```

When I used tcpdump to diagnose the problem, I got such result:

```
on Server A:

arping -i l2tpeth0 -0 1.2.3.4

on Server B:

tcpdump -i eth0 -n port 1086  -v

21:35:57.818810 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad udp =
cksum 0x0000 -> 0x1140!] UDP, length 54
21:35:58.820572 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad udp =
cksum 0x0000 -> 0x1140!] UDP, length 54
21:35:59.822216 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [bad udp =
cksum 0x0000 -> 0x1140!] UDP, length 54

```

After looking into kernel source, I found out that in this commit a new=
 feature to set udp6 checksum to zero in commit 6b649fe, which added `L=
2TP_ATTR_UDP_ZERO_CSUM6_TX` and `L2TP_ATTR_UDP_ZERO_CSUM6_TX`.

As a result, I added `udp_csum`, `udp6_csum_tx`, `udp6_csum_rx` control=
 flags to `ip l2tp add tunnel` to control those attributes about checks=
um.=20

Using this to create the tunnel instead on Server A:

```
ip l2tp add tunnel tunnel_id 86 peer_tunnel_id 86 remote 2001:db8::aaaa=
 local 2001:db8::bbbb udp_sport 1086 udp_dport 1086 udp6_csum_tx on udp=
6_csum_rx on
```

I finally got:

```
on Server A:

arping -i l2tpeth0 -0 1.2.3.4

on Server B:

tcpdump -i eth0 -n port 1086  -v

22:07:03.844297 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp sum =
ok] UDP, length 54
22:07:04.845717 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp sum =
ok] UDP, length 54
22:07:05.847965 IP6 (flowlabel 0x8f028, hlim 64, next-header UDP (17) p=
ayload length: 62) 2001:db8::aaaa.1086 > 2001:db8::bbbb.1086: [udp sum =
ok] UDP, length 54

tcpdump -i l2tpeth0 -v

22:10:35.691326 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 1.=
2.3.4 tell 0.0.0.0, length 28
22:10:36.693627 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 1.=
2.3.4 tell 0.0.0.0, length 28
22:10:37.695010 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 1.=
2.3.4 tell 0.0.0.0, length 28
22:10:38.697121 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 1.=
2.3.4 tell 0.0.0.0, length 28

```

It seems to work. However, is it the real point that should be fixed an=
d does my patch fix it well? I need your suggestion.


---
 ip/ipl2tp.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 45 insertions(+)

diff --git a/ip/ipl2tp.c b/ip/ipl2tp.c
index 3c8ee93..67a6482 100644
--- a/ip/ipl2tp.c
+++ b/ip/ipl2tp.c
@@ -56,6 +56,8 @@ struct l2tp_parm {
=20
 	uint16_t pw_type;
 	uint16_t mtu;
+	int udp6_csum_tx:1;
+	int udp6_csum_rx:1;
 	int udp_csum:1;
 	int recv_seq:1;
 	int send_seq:1;
@@ -117,6 +119,9 @@ static int create_tunnel(struct l2tp_parm *p)
 	if (p->encap =3D=3D L2TP_ENCAPTYPE_UDP) {
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_SPORT, p->local_udp_port);
 		addattr16(&req.n, 1024, L2TP_ATTR_UDP_DPORT, p->peer_udp_port);
+		addattr8 (&req.n, 1024, L2TP_ATTR_UDP_CSUM, p->udp_csum);
+		addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_TX, p->udp6_csum_tx=
);
+		addattr8 (&req.n, 1024, L2TP_ATTR_UDP_ZERO_CSUM6_RX, p->udp6_csum_rx=
);
 	}
=20
 	if (rtnl_talk(&genl_rth, &req.n, NULL, 0) < 0)
@@ -282,6 +287,14 @@ static int get_response(struct nlmsghdr *n, void *=
arg)
 		p->l2spec_len =3D rta_getattr_u8(attrs[L2TP_ATTR_L2SPEC_LEN]);
=20
 	p->udp_csum =3D !!attrs[L2TP_ATTR_UDP_CSUM];
+	if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
+	  p->udp6_csum_tx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZERO_CSUM6_T=
X]);
+	else
+	  p->udp6_csum_tx =3D 1;
+	if (attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
+	  p->udp6_csum_rx =3D rta_getattr_u8(attrs[L2TP_ATTR_UDP_ZERO_CSUM6_R=
X]);
+	else
+	  p->udp6_csum_rx =3D 1;
 	if (attrs[L2TP_ATTR_COOKIE])
 		memcpy(p->cookie, RTA_DATA(attrs[L2TP_ATTR_COOKIE]),
 		       p->cookie_len =3D RTA_PAYLOAD(attrs[L2TP_ATTR_COOKIE]));
@@ -470,6 +483,9 @@ static void usage(void)
 	fprintf(stderr, "          tunnel_id ID peer_tunnel_id ID\n");
 	fprintf(stderr, "          [ encap { ip | udp } ]\n");
 	fprintf(stderr, "          [ udp_sport PORT ] [ udp_dport PORT ]\n");
+	fprintf(stderr, "          [ udp_csum { on | off } ]\n");
+	fprintf(stderr, "          [ udp6_csum_tx { on | off } ]\n");
+	fprintf(stderr, "          [ udp6_csum_rx { on | off } ]\n");
 	fprintf(stderr, "Usage: ip l2tp add session [ name NAME ]\n");
 	fprintf(stderr, "          tunnel_id ID\n");
 	fprintf(stderr, "          session_id ID peer_session_id ID\n");
@@ -500,6 +516,8 @@ static int parse_args(int argc, char **argv, int cm=
d, struct l2tp_parm *p)
 	/* Defaults */
 	p->l2spec_type =3D L2TP_L2SPECTYPE_DEFAULT;
 	p->l2spec_len =3D 4;
+	p->udp6_csum_rx =3D 1;
+	p->udp6_csum_tx =3D 1;
=20
 	while (argc > 0) {
 		if (strcmp(*argv, "encap") =3D=3D 0) {
@@ -569,6 +587,33 @@ static int parse_args(int argc, char **argv, int c=
md, struct l2tp_parm *p)
 			if (get_u16(&uval, *argv, 0))
 				invarg("invalid port\n", *argv);
 			p->peer_udp_port =3D uval;
+		} else if (strcmp(*argv, "udp_csum") =3D=3D 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") =3D=3D 0) {
+				p->udp_csum =3D 1;
+			} else if (strcmp(*argv, "off") =3D=3D 0) {
+				p->udp_csum =3D 0;
+			} else {
+				invarg("invalid option for udp_csum\n", *argv);
+			}
+		} else if (strcmp(*argv, "udp6_csum_rx") =3D=3D 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") =3D=3D 0) {
+				p->udp6_csum_rx =3D 1;
+			} else if (strcmp(*argv, "off") =3D=3D 0) {
+				p->udp6_csum_rx =3D 0;
+			} else {
+				invarg("invalid option for udp6_csum_rx\n", *argv);
+			}
+		} else if (strcmp(*argv, "udp6_csum_tx") =3D=3D 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "on") =3D=3D 0) {
+				p->udp6_csum_tx =3D 1;
+			} else if (strcmp(*argv, "off") =3D=3D 0) {
+				p->udp6_csum_tx =3D 0;
+			} else {
+				invarg("invalid option for udp6_csum_tx\n", *argv);
+			}
 		} else if (strcmp(*argv, "offset") =3D=3D 0) {
 			__u8 uval;
=20
--=20
2.5.2
