From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: Re: [pve-devel] bridge vlan range, kernel 4.1 : "message truncated"
 warning when too much vlans defined
Date: Thu, 10 Sep 2015 08:40:26 +0200 (CEST)
Message-ID: <972878625.39892449.1441867226052.JavaMail.zimbra@oxygem.tv>
References: <1522237479.23555412.1438194289391.JavaMail.zimbra@oxygem.tv> <E4CD12F19ABA0C4D8729E087A761DC350F536639@ORSMSX101.amr.corp.intel.com> <999679133.23642075.1438234304221.JavaMail.zimbra@oxygem.tv>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "Arad, Ronen" <ronen.arad@intel.com>,
	roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:44946 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbbIJGrj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 02:47:39 -0400
In-Reply-To: <999679133.23642075.1438234304221.JavaMail.zimbra@oxygem.tv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This still not fixed in iproute 4.2.

Is they any plan to increase the rtnl_dump_filter buffer size soon ?

Regards,

Alexandre Derumier


----- Mail original -----
De: "aderumier" <aderumier@odiso.com>
=C3=80: "Arad, Ronen" <ronen.arad@intel.com>
Cc: "netdev" <netdev@vger.kernel.org>, "pve-devel" <pve-devel@pve.proxm=
ox.com>
Envoy=C3=A9: Jeudi 30 Juillet 2015 07:31:44
Objet: Re: [pve-devel] bridge vlan range, kernel 4.1 : "message truncat=
ed" warning when too much vlans defined

Thanks Ronen,=20

I have tested=20

- char buf[16384];=20
+ char buf[3*16384];=20


and It's working fine to handle 4096 vlans numbers.=20

(The problem was really the number of vlans ids defined,=20
could be 1 interface with 2-4095vlans, or 100 interfaces with same 2-40=
95vlans).=20

With this buffer size it's working fine=20


Thanks for the fast reply.=20

Regards,=20

Alexadre=20

----- Mail original -----=20
De: "Arad, Ronen" <ronen.arad@intel.com>=20
=C3=80: "aderumier" <aderumier@odiso.com>, "netdev" <netdev@vger.kernel=
=2Eorg>=20
Cc: "pve-devel" <pve-devel@pve.proxmox.com>=20
Envoy=C3=A9: Jeudi 30 Juillet 2015 04:03:06=20
Objet: RE: bridge vlan range, kernel 4.1 : "message truncated" warning =
when too much vlans defined=20

The easiest fix is in iproute2.=20
Increasing the buffer size used in rtnl_dump_filter_l 3x empirically re=
solves the=20
issue.=20

The root-cause is due to the buffer size calculation of dump request in=
 the=20
kernel. It is based on the total number of VLANs and does not account f=
or=20
compressed vlan requests.=20
The flag argument is not propagated to get size functions.=20

=46ixing the size calculation in the kernel would work most of the time=
 but would=20
=46ail when the number of ranges (and/or non-contiguous VLANs) exceeds =
~1800.=20

Therefore, fixing the size calculation in the kernel does not worth the=
=20
Effort. Fixing iproute2 seems the easy way to overcome the issue.=20

diff --git a/lib/libnetlink.c b/lib/libnetlink.c=20
index 901236e..25c1c02 100644=20
--- a/lib/libnetlink.c=20
+++ b/lib/libnetlink.c=20
@@ -198,7 +198,7 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,=20
=2Emsg_iov =3D &iov,=20
=2Emsg_iovlen =3D 1,=20
};=20
- char buf[16384];=20
+ char buf[3*16384];=20
int dump_intr =3D 0;=20
iov.iov_base =3D buf;=20

Ronen=20

>-----Original Message-----=20
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g] On=20
>Behalf Of Alexandre DERUMIER=20
>Sent: Wednesday, July 29, 2015 11:25 AM=20
>To: netdev=20
>Cc: pve-devel=20
>Subject: bridge vlan range, kernel 4.1 : "message truncated" warning w=
hen too=20
>much vlans defined=20
>=20
>Hi,=20
>=20
>I'm currently testing vlan range on bridge filtering with kernel 4.1.=20
>=20
>=20
>If I defined too much vlans, or too big vlan range,=20
>I have a warning "message truncated", even if I'm using "-c"=20
>=20
>=20
># bridge -c vlan=20
>Message truncated=20
>port vlan ids=20
>eth2 1 PVID Egress Untagged=20
>=20
>bond0 1 PVID Egress Untagged=20
>2-1850=20
>=20
>vmbr0 1 PVID Egress Untagged=20
>94=20
>=20
>=20
>or=20
># bridge -c vlan=20
>Message truncated=20
>port vlan ids=20
>eth2 1 PVID Egress Untagged=20
>2-900=20
>bond0 1 PVID Egress Untagged=20
>2-900=20
>=20
>vmbr0 1 PVID Egress Untagged=20
>94=20
>=20
>=20
>=20
>Also, more important, this is also impact "ip", and truncate the outpu=
t=20
>=20
>#ip link=20
>=20
>Message truncated=20
>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mo=
de=20
>DEFAULT group default=20
>link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00=20
>2: eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 9000 qdisc pfifo_fast=
 master=20
>vmbr1 state DOWN mode DEFAULT group default qlen 1000=20
>link/ether 00:15:17:80:29:e6 brd ff:ff:ff:ff:ff:ff=20
>3: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEF=
AULT=20
>group default qlen 1000=20
>link/ether 00:15:17:80:29:e7 brd ff:ff:ff:ff:ff:ff=20
>4: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq mas=
ter=20
>bond0 state UP mode DEFAULT group default qlen 1000=20
>link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff=20
>5: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast m=
aster=20
>ovs-system state UP mode DEFAULT group default qlen 1000=20
>link/ether 68:05:ca:09:c3:7c brd ff:ff:ff:ff:ff:ff=20
>6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc pfifo_fast m=
aster=20
>ovs-system state UP mode DEFAULT group default qlen 1000=20
>link/ether 68:05:ca:09:c3:7d brd ff:ff:ff:ff:ff:ff=20
>7: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq mas=
ter=20
>bond0 state UP mode DEFAULT group default qlen 1000=20
>link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff=20
>8: ovs-system@NONE: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DO=
WN mode=20
>DEFAULT group default=20
>link/ether 7e:dd:5d:ea:ef:26 brd ff:ff:ff:ff:ff:ff=20
>9: vmbr10@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noque=
ue state=20
>UNKNOWN mode DEFAULT group default=20
>link/ether 68:05:ca:09:c3:7d brd ff:ff:ff:ff:ff:ff=20
>10: bond1@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noque=
ue state=20
>UNKNOWN mode DEFAULT group default=20
>link/ether 8a:c3:da:b0:9d:87 brd ff:ff:ff:ff:ff:ff=20
>11: bond0@NONE: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdis=
c=20
>noqueue master vmbr0 state UP mode DEFAULT group default=20
>link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff=20
>12: vmbr0@NONE: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noque=
ue state=20
>UP mode DEFAULT group default=20
>link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff=20
>13: vmbr0.94@vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc n=
oqueue=20
>state UP mode DEFAULT group default=20
>link/ether 00:1a:a0:3c:98:c5 brd ff:ff:ff:ff:ff:ff=20
>=20
>---->should have more interfaces here=20
>=20
>=20
>Is it a known bug ?=20
>=20
>=20
>=20
>Regards,=20
>=20
>Alexandre Derumier=20
>=20
>--=20
>To unsubscribe from this list: send the line "unsubscribe netdev" in=20
>the body of a message to majordomo@vger.kernel.org=20
>More majordomo info at http://vger.kernel.org/majordomo-info.html=20
_______________________________________________=20
pve-devel mailing list=20
pve-devel@pve.proxmox.com=20
http://pve.proxmox.com/cgi-bin/mailman/listinfo/pve-devel=20
