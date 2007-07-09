From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding / ipv6: no addrconf for slaves separately from master
Date: Mon, 09 Jul 2007 10:42:47 -0700
Message-ID: <22567.1184002967@death>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39835 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747AbXGIRm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 13:42:59 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l69HgtqZ004452
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 13:42:55 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l69HgtdJ476934
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 13:42:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l69HgskL021887
	for <netdev@vger.kernel.org>; Mon, 9 Jul 2007 13:42:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	At present, when a device is enslaved to bonding, if ipv6 is
active then addrconf will be initated on the slave (because it is closed
then opened during the enslavement processing).  This causes DAD and RS
packets to be sent from the slave.  These packets in turn can confuse
switches that perform ipv6 snooping, causing them to incorrectly update
their forwarding tables (if, e.g., the slave being added is an inactve
backup that won't be used right away) and direct traffic away from the
active slave to a backup slave (where the incoming packets will be
dropped).

	This patch alters the behavior so that addrconf will only run on
the master device itself.  I believe this is logically correct, as it
prevents slaves from having an IPv6 identity independent from the
master.  This is consistent with the IPv4 behavior for bonding.

	This is accomplished by (a) having bonding set IFF_SLAVE sooner
in the enslavement processing than currently occurs (before open, not
after), and (b) having ipv6 addrconf ignore UP and CHANGE events on
slave devices.

	The eql driver also uses the IFF_SLAVE flag.  I inspected eql,
and I believe this change is reasonable for its usage of IFF_SLAVE, but
I did not test it.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6287ffb..2bb70e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1390,6 +1390,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_free;
 	}
 
+	res = netdev_set_master(slave_dev, bond_dev);
+	if (res) {
+		dprintk("Error %d calling netdev_set_master\n", res);
+		goto err_close;
+	}
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
@@ -1397,12 +1402,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_restore_mac;
 	}
 
-	res = netdev_set_master(slave_dev, bond_dev);
-	if (res) {
-		dprintk("Error %d calling netdev_set_master\n", res);
-		goto err_close;
-	}
-
 	new_slave->dev = slave_dev;
 	slave_dev->priv_flags |= IFF_BONDING;
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f96ed76..79b79f3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2268,6 +2268,9 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
+		if (dev->flags & IFF_SLAVE)
+			break;
+
 		if (event == NETDEV_UP) {
 			if (!netif_carrier_ok(dev)) {
 				/* device is not ready yet. */
