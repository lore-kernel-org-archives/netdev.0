From: =?UTF-8?B?RnJhbsOnb2lzIENhY2hlcmV1bA==?= <f.cachereul@alphalink.fr>
Subject: [PATCH net] bonding: fix arp requests sends with isolated routes
Date: Fri, 14 Feb 2014 16:59:23 +0100
Message-ID: <52FE3D5B.6060103@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51819 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751790AbaBNQFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 11:05:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make arp_send_all() try to send arp packets through slave devices event
if no route to arp_ip_target is found. This is useful when the route
is in an isolated routing table with routing rule parameters like oif o=
r
iif in which case ip_route_output() return an error.
Thus, the arp packet is send without vlan and with the bond ip address
as sender.

Signed-off-by: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
---
This previously worked, the problem was added in 2.6.35 with vlan 0
added by default when the module 8021q is loaded. Before that no route
lookup was done if the bond device did not have any vlan. The problem
now exists event if the module 8021q is not loaded.

 drivers/net/bonding/bond_main.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 8676649..300e5b8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2168,17 +2168,19 @@ static void bond_arp_send_all(struct bonding *b=
ond, struct slave *slave)
 	for (i =3D 0; i < BOND_MAX_ARP_TARGETS && targets[i]; i++) {
 		pr_debug("basa: target %pI4\n", &targets[i]);
=20
+		vlan_id =3D 0;
+
 		/* Find out through which dev should the packet go */
 		rt =3D ip_route_output(dev_net(bond->dev), targets[i], 0,
 				     RTO_ONLINK, 0);
 		if (IS_ERR(rt)) {
 			pr_debug("%s: no route to arp_ip_target %pI4\n",
 				 bond->dev->name, &targets[i]);
-			continue;
+			/* no route found, trying with bond->dev */
+			addr =3D bond_confirm_addr(bond->dev, targets[i], 0);
+			goto rt_err_try;
 		}
=20
-		vlan_id =3D 0;
-
 		/* bond device itself */
 		if (rt->dst.dev =3D=3D bond->dev)
 			goto found;
@@ -2232,6 +2234,7 @@ static void bond_arp_send_all(struct bonding *bon=
d, struct slave *slave)
 found:
 		addr =3D bond_confirm_addr(rt->dst.dev, targets[i], 0);
 		ip_rt_put(rt);
+rt_err_try:
 		bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i],
 			      addr, vlan_id);
 	}
--=20
1.7.10.4
