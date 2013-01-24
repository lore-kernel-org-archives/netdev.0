From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V2] bond: have random dev address by default instead of zeroes
Date: Thu, 24 Jan 2013 21:01:24 +0100
Message-ID: <1359057684-6732-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:50731 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab3AXUBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 15:01:31 -0500
Received: by mail-we0-f171.google.com with SMTP id u3so3059574wey.2
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 12:01:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes more sense to have randomly generated address by default than to
have all zeroes. It also allows user to for example put the bond into
bridge without need to have any slaves in it.

Also note that this changes only behaviour of bonds with no slaves. Onc=
e
the first slave device is enslaved, its address will be used (no change
here).

Also, fix dev_assign_type values on the way.

Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---

v1->v2:
- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_addr=
()
- added note to patch description

 drivers/net/bonding/bond_main.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 564cf42..1d56ac9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1320,14 +1320,14 @@ static void bond_netpoll_cleanup(struct net_dev=
ice *bond_dev)
=20
 /*---------------------------------- IOCTL ---------------------------=
-------*/
=20
-static int bond_sethwaddr(struct net_device *bond_dev,
-			  struct net_device *slave_dev)
+static void bond_set_dev_addr(struct net_device *bond_dev,
+			      struct net_device *slave_dev)
 {
 	pr_debug("bond_dev=3D%p\n", bond_dev);
 	pr_debug("slave_dev=3D%p\n", slave_dev);
 	pr_debug("slave_dev->addr_len=3D%d\n", slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
-	return 0;
+	bond_dev->addr_assign_type =3D NET_ADDR_SET;
 }
=20
 static netdev_features_t bond_fix_features(struct net_device *dev,
@@ -1628,10 +1628,8 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
=20
 	/* If this is the first slave, then we need to set the master's hardw=
are
 	 * address to be the same as the slave's. */
-	if (is_zero_ether_addr(bond->dev->dev_addr))
-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
-		       slave_dev->addr_len);
-
+	if (bond->dev->addr_assign_type !=3D NET_ADDR_SET)
+		bond_set_dev_addr(bond->dev, slave_dev);
=20
 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
@@ -2049,11 +2047,11 @@ int bond_release(struct net_device *bond_dev, s=
truct net_device *slave_dev)
 	if (bond->slave_cnt =3D=3D 0) {
 		bond_set_carrier(bond);
=20
-		/* if the last slave was removed, zero the mac address
-		 * of the master so it will be set by the application
-		 * to the mac address of the first slave
+		/* If the last slave was removed, set random mac address
+		 * of the master so it will be set by bond_enslave()
+		 * to the mac address of the first slave.
 		 */
-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+		eth_hw_addr_random(bond_dev);
=20
 		if (bond_vlan_used(bond)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still h=
as VLANs.\n",
@@ -3708,7 +3706,8 @@ static int bond_do_ioctl(struct net_device *bond_=
dev, struct ifreq *ifr, int cmd
 			break;
 		case BOND_SETHWADDR_OLD:
 		case SIOCBONDSETHWADDR:
-			res =3D bond_sethwaddr(bond_dev, slave_dev);
+			bond_set_dev_addr(bond_dev, slave_dev);
+			res =3D 0;
 			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
@@ -4858,6 +4857,11 @@ static int bond_init(struct net_device *bond_dev=
)
=20
 	bond_debug_register(bond);
=20
+	/* Ensure valid dev_addr */
+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM)
+		eth_hw_addr_random(bond_dev);
+
 	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
--=20
1.8.1
