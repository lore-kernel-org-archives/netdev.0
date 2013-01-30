From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V4] bond: have random dev address by default instead of zeroes
Date: Wed, 30 Jan 2013 11:08:11 +0100
Message-ID: <1359540491-768-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:45076 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688Ab3A3KPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:15:50 -0500
Received: by mail-we0-f176.google.com with SMTP id s43so1036192wey.7
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 02:15:49 -0800 (PST)
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
v3->v4:
- %s/get_dev_addr_from_first_slave/dev_addr_from_first/
v2->v3:
- call_netdevice_notifiers is called after dev_addr change.
- use bond->get_dev_addr_from_first_slave to know when to get addr from=
 the
  first slave
v1->v2:
- fixed assign value of bond_dev->addr_assign_type in bond_set_dev_addr=
()
- added note to patch description

 drivers/net/bonding/bond_main.c | 38 +++++++++++++++++++--------------=
-----
 drivers/net/bonding/bonding.h   |  1 +
 2 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 564cf42..b38c9bf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1320,14 +1320,15 @@ static void bond_netpoll_cleanup(struct net_dev=
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
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
 }
=20
 static netdev_features_t bond_fix_features(struct net_device *dev,
@@ -1628,10 +1629,8 @@ int bond_enslave(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
=20
 	/* If this is the first slave, then we need to set the master's hardw=
are
 	 * address to be the same as the slave's. */
-	if (is_zero_ether_addr(bond->dev->dev_addr))
-		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
-		       slave_dev->addr_len);
-
+	if (bond->dev_addr_from_first)
+		bond_set_dev_addr(bond->dev, slave_dev);
=20
 	new_slave =3D kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
@@ -2048,12 +2047,8 @@ int bond_release(struct net_device *bond_dev, st=
ruct net_device *slave_dev)
=20
 	if (bond->slave_cnt =3D=3D 0) {
 		bond_set_carrier(bond);
-
-		/* if the last slave was removed, zero the mac address
-		 * of the master so it will be set by the application
-		 * to the mac address of the first slave
-		 */
-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+		eth_hw_addr_random(bond_dev);
+		bond->dev_addr_from_first =3D true;
=20
 		if (bond_vlan_used(bond)) {
 			pr_warning("%s: Warning: clearing HW address of %s while it still h=
as VLANs.\n",
@@ -2234,11 +2229,8 @@ static int bond_release_all(struct net_device *b=
ond_dev)
 		write_lock_bh(&bond->lock);
 	}
=20
-	/* zero the mac address of the master so it will be
-	 * set by the application to the mac address of the
-	 * first slave
-	 */
-	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+	eth_hw_addr_random(bond_dev);
+	bond->dev_addr_from_first =3D true;
=20
 	if (bond_vlan_used(bond)) {
 		pr_warning("%s: Warning: clearing HW address of %s while it still ha=
s VLANs.\n",
@@ -3708,7 +3700,8 @@ static int bond_do_ioctl(struct net_device *bond_=
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
@@ -4858,6 +4851,13 @@ static int bond_init(struct net_device *bond_dev=
)
=20
 	bond_debug_register(bond);
=20
+	/* Ensure valid dev_addr */
+	if (is_zero_ether_addr(bond_dev->dev_addr) &&
+	    bond_dev->addr_assign_type =3D=3D NET_ADDR_PERM) {
+		eth_hw_addr_random(bond_dev);
+		bond->dev_addr_from_first =3D true;
+	}
+
 	__hw_addr_init(&bond->mc_list);
 	return 0;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bondin=
g.h
index 0d282d2..2baec24 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -248,6 +248,7 @@ struct bonding {
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
 #endif /* CONFIG_DEBUG_FS */
+	bool	dev_addr_from_first;
 };
=20
 static inline bool bond_vlan_used(struct bonding *bond)
--=20
1.8.1
