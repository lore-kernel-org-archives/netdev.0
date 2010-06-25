From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.35] bonding: prevent netpoll over bonded interfaces
Date: Fri, 25 Jun 2010 15:50:44 -0400
Message-ID: <20100625195044.GQ7497@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, amwang@redhat.com, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932317Ab0FYTur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 15:50:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Support for netpoll over bonded interfaces was added here:

	commit f6dc31a85cd46a959bdd987adad14c3b645e03c1
	Author: WANG Cong <amwang@redhat.com>
	Date:   Thu May 6 00:48:51 2010 -0700

	    bonding: make bonding support netpoll

but it is bad enough that we should probably just disable netpoll over
bonding until some of the locking logic in the bonding driver is changed
or converted completely to RCU.  Simple actions like changing the active
slave in active-backup mode will hang the box if a high enough printk
debugging level is enabled.

Keeping the old code around will be good for anyone that wants to work
on it (and for after the RCU conversion), so I propose this small patch
rather than ripping it all out.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5e12462..c3d98dd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -168,7 +168,7 @@ static int arp_ip_count;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 static int lacp_fast;
-
+static int disable_netpoll = 1;
 
 const struct bond_parm_tbl bond_lacp_tbl[] = {
 {	"slow",		AD_LACP_SLOW},
@@ -1742,15 +1742,23 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	if (slaves_support_netpoll(bond_dev)) {
-		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
-		if (bond_dev->npinfo)
-			slave_dev->npinfo = bond_dev->npinfo;
-	} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
+	/*
+	 * Netpoll and bonding is broken, make sure it is not initialized
+	 * until it is fixed.
+	 */
+	if (disable_netpoll) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
-		pr_info("New slave device %s does not support netpoll\n",
-			slave_dev->name);
-		pr_info("Disabling netpoll support for %s\n", bond_dev->name);
+	} else {
+		if (slaves_support_netpoll(bond_dev)) {
+			bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+			if (bond_dev->npinfo)
+				slave_dev->npinfo = bond_dev->npinfo;
+		} else if (!(bond_dev->priv_flags & IFF_DISABLE_NETPOLL)) {
+			bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
+			pr_info("New slave device %s does not support netpoll\n",
+				slave_dev->name);
+			pr_info("Disabling netpoll support for %s\n", bond_dev->name);
+		}
 	}
 #endif
 	read_unlock(&bond->lock);
@@ -1950,8 +1958,11 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	read_lock_bh(&bond->lock);
-	if (slaves_support_netpoll(bond_dev))
-		bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
+
+	 /* Make sure netpoll over stays disabled until fixed. */
+	if (!disable_netpoll)
+		if (slaves_support_netpoll(bond_dev))
+				bond_dev->priv_flags &= ~IFF_DISABLE_NETPOLL;
 	read_unlock_bh(&bond->lock);
 	if (slave_dev->netdev_ops->ndo_netpoll_cleanup)
 		slave_dev->netdev_ops->ndo_netpoll_cleanup(slave_dev);
