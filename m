From: Alexandre DERUMIER <aderumier@odiso.com>
Subject: Re: kernel 4.2 : "bridge vlan" command return empty result (works
 with kernel 4.1.3)
Date: Thu, 17 Sep 2015 05:36:56 +0200 (CEST)
Message-ID: <1679804272.62090915.1442461016457.JavaMail.zimbra@oxygem.tv>
References: <1167950469.57377315.1442338762965.JavaMail.zimbra@oxygem.tv> <55F86B4A.7090001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailpro.odiso.net ([89.248.209.98]:60137 "EHLO
	mailpro.odiso.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbbIQDg6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 23:36:58 -0400
In-Reply-To: <55F86B4A.7090001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>he problem went away on my box with the following patch. I=20
>>will submit an official patch in a bit.

Hi, I confirm that your patch fix the problem for me too.

Regards,

Alexandre
----- Mail original -----
De: "roopa" <roopa@cumulusnetworks.com>
=C3=80: "aderumier" <aderumier@odiso.com>
Cc: "netdev" <netdev@vger.kernel.org>, "Scott Feldman" <sfeldma@cumulus=
networks.com>
Envoy=C3=A9: Mardi 15 Septembre 2015 21:02:34
Objet: Re: kernel 4.2 : "bridge vlan" command return empty result (work=
s with kernel 4.1.3)

On 9/15/15, 10:39 AM, Alexandre DERUMIER wrote:=20
> Hi,=20
>=20
> since kernel 4.2, "bridge vlan" command return empty result.=20
>=20
>=20
> kernel 4.1.3=20
> ------------=20
> # bridge vlan=20
> port vlan ids=20
> eth0 1 PVID Egress Untagged=20
> 90=20
> 91=20
> 92=20
> 93=20
> 94=20
> 95=20
> 96=20
> 97=20
> 98=20
> 99=20
> 100=20
>=20
> vmbr0 1 PVID Egress Untagged=20
> 94=20
>=20
>=20
>=20
> kernel 4.2=20
> ----------------=20
> # bridge vlan=20
> port vlan ids=20
>=20
>=20
>=20
> Note that vlans are correctly working,it seem that is just the displa=
y.=20
>=20
> tcpdump -e -i vmbr0=20
>=20
> 19:38:08.005055 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (=
oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ether=
type IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 3=
39613, win 5523, length 0=20
> 19:38:08.007730 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (=
oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ether=
type IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 3=
42145, win 5568, length 0=20
> 19:38:08.010977 00:08:7c:bd:ae:40 (oui Unknown) > 00:18:8b:7c:c8:37 (=
oui Unknown), ethertype 802.1Q (0x8100), length 64: vlan 94, p 0, ether=
type IPv4, 172.20.0.17.52299 > kvmtest2.odiso.net.ssh: Flags [.], ack 3=
44677, win 5614, length 0=20
> 19:3=20
I was able to reproduce this when there is a bond in the system.=20

Looks like this was due to 85fdb956726ff2a ("switchdev: cut over to new=
=20
switchdev_port_bridge_getlink").=20
When CONFIG_SWITCHDEV is off, nodes that use switchdev api for=20
ndo_bridge_getlink (example, bonds, teams, rocker) can return=20
-EOPNOTSUPP. The problem went away on my box with the following patch. =
I=20
will submit an official patch in a bit.=20
Do you have a bond in your system ?.=20

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c=20
index 01ced4a..bdb3842 100644=20
--- a/net/core/rtnetlink.c=20
+++ b/net/core/rtnetlink.c=20
@@ -3013,6 +3013,7 @@ static int rtnl_bridge_getlink(struct sk_buff=20
*skb, struct=20
u32 portid =3D NETLINK_CB(cb->skb).portid;=20
u32 seq =3D cb->nlh->nlmsg_seq;=20
u32 filter_mask =3D 0;=20
+ int err;=20

if (nlmsg_len(cb->nlh) > sizeof(struct ifinfomsg)) {=20
struct nlattr *extfilt;=20
@@ -3033,20 +3034,25 @@ static int rtnl_bridge_getlink(struct sk_buff=20
*skb, stru=20
struct net_device *br_dev =3D=20
netdev_master_upper_dev_get(dev);=20

if (br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {=20
- if (idx >=3D cb->args[0] &&=20
- br_dev->netdev_ops->ndo_bridge_getlink(=20
- skb, portid, seq, dev, filter_mask,=20
- NLM_F_MULTI) < 0)=20
- break;=20
+ if (idx >=3D cb->args[0]) {=20
+ err =3D=20
br_dev->netdev_ops->ndo_bridge_getlink(=20
+ skb, portid, seq, dev,=20
+ filter_mask, NLM_F_MULTI);=20
+ if ( err < 0 && err !=3D -EOPNOTSUPP)=20
+ break;=20
+ }=20
idx++;=20
}=20

if (ops->ndo_bridge_getlink) {=20
- if (idx >=3D cb->args[0] &&=20
- ops->ndo_bridge_getlink(skb, portid, seq, dev,=20
- filter_mask,=20
- NLM_F_MULTI) < 0)=20
- break;=20
+ if (idx >=3D cb->args[0]) {=20
+ err =3D ops->ndo_bridge_getlink(skb, portid,=20
+ seq, dev,=20
+ filter_mask,=20
+ NLM_F_MULTI);=20
+ if ( err < 0 && err !=3D -EOPNOTSUPP)=20
+ break;=20
+ }=20
idx++;=20
}=20
}=20
