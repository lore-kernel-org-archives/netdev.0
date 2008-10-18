From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] bonding: prevent MTU changes in slave devices
Date: Fri, 17 Oct 2008 21:32:57 -0700
Message-ID: <20081018043323.724189700@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52218 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750858AbYJREf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:35:57 -0400
Content-Disposition: inline; filename=bonding-mtu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check in bonding driver disallow changing MTU of one slave.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/bonding/bond_main.c	2008-10-17 18:59:48.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-10-17 19:02:58.000000000 -0700
@@ -3572,19 +3572,14 @@ static int bond_slave_netdev_event(unsig
 		}
 		break;
 	case NETDEV_CHANGEMTU:
-		/*
-		 * TODO: Should slaves be allowed to
-		 * independently alter their MTU?  For
-		 * an active-backup bond, slaves need
-		 * not be the same type of device, so
-		 * MTUs may vary.  For other modes,
-		 * slaves arguably should have the
-		 * same MTUs. To do this, we'd need to
-		 * take over the slave's change_mtu
-		 * function for the duration of their
-		 * servitude.
+		/* Can not independently change MTU of slave devices
+		 * NOTIFY_BAD causes EPERM in orignal change mtu call
+		 * NB: called on unwind as well
 		 */
+		if (slave_dev->mtu != bond_dev->mtu)
+			return NOTIFY_BAD;
 		break;
+
 	case NETDEV_CHANGENAME:
 		/*
 		 * TODO: handle changing the primary's name
@@ -4132,6 +4127,7 @@ static int bond_change_mtu(struct net_de
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *stop_at;
+	int old_mtu = bond_dev->mtu;
 	int res = 0;
 	int i;
 
@@ -4152,7 +4148,7 @@ static int bond_change_mtu(struct net_de
 	 * list, but without holding a lock around the actual
 	 * call to the base driver.
 	 */
-
+	bond_dev->mtu = new_mtu;
 	bond_for_each_slave(bond, slave, i) {
 		dprintk("s %p s->p %p c_m %p\n", slave,
 			slave->prev, slave->dev->change_mtu);
@@ -4173,11 +4169,12 @@ static int bond_change_mtu(struct net_de
 		}
 	}
 
-	bond_dev->mtu = new_mtu;
 
 	return 0;
 
 unwind:
+	bond_dev->mtu = old_mtu;
+
 	/* unwind from head to the slave that failed */
 	stop_at = slave;
 	bond_for_each_slave_from_to(bond, slave, i, bond->first_slave, stop_at) {

-- 

