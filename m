From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: send arp requests even if there's no route to them
Date: Fri, 28 Feb 2014 11:57:56 +0100
Message-ID: <1393585076-22786-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	=?UTF-8?q?Fran=C3=A7ois=20CACHEREUL?= <f.cachereul@alphalink.fr>,
	Zhenjie Chen <zhchen@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18434 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbaB1LCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 06:02:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're only sending arp requests if we have a route to the tar=
get
(and, thus, can find out the source ip address).

There are some use cases, however, where we don't want/need to set an i=
p
address (or set up a specific route) for bonding to use arp monitoring =
*for
traffic generation*. We can easily send arp probes (arp requests with s=
rc
ip =3D=3D 0) to generate arp broadcast responses from the target ip and=
 use
them for determining if the target is up.

This, obviously, won't work with arp validation - because we don't have=
 the
ip address set and, thus, will filter out the responses. So in that cas=
e -
print a warning.

CC: Fran=C3=A7ois CACHEREUL <f.cachereul@alphalink.fr>
CC: Zhenjie Chen <zhchen@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 12948b3..a217536 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2155,8 +2155,13 @@ static void bond_arp_send_all(struct bonding *bo=
nd, struct slave *slave)
 		rt =3D ip_route_output(dev_net(bond->dev), targets[i], 0,
 				     RTO_ONLINK, 0);
 		if (IS_ERR(rt)) {
-			pr_debug("%s: no route to arp_ip_target %pI4\n",
-				 bond->dev->name, &targets[i]);
+			/* there's no route to target - try to send arp
+			 * probe to generate any traffic (arp_validate=3D0)
+			 */
+			if (bond->params.arp_validate)
+				pr_warn("%s: no route to arp_ip_target %pI4 and arp_validate is se=
t\n",
+					bond->dev->name, &targets[i]);
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], 0, 0);
 			continue;
 		}
=20
--=20
1.8.4
