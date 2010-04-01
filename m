From: Amerigo Wang <amwang@redhat.com>
Subject: [Patch V2] bonding: fix potential deadlock in bond_uninit()
Date: Thu, 1 Apr 2010 02:06:28 -0400
Message-ID: <20100401061014.4815.7341.sendpatchset@localhost.localdomain>
Cc: Jiri Pirko <jpirko@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Amerigo Wang <amwang@redhat.com>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284Ab0DAGGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 02:06:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


bond_uninit() is invoked with rtnl_lock held, when it does destroy_workqueue()
which will potentially flush all works in this workqueue, if we hold rtnl_lock
again in the work function, it will deadlock.

So move destroy_workqueue() to destructor where rtnl_lock is not held any more,
suggested by Eric.

Signed-off-by: WANG Cong <amwang@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>

---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5b92fbf..9f0aaa2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4450,6 +4450,14 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_vlan_rx_kill_vid	= bond_vlan_rx_kill_vid,
 };
 
+static void bond_destructor(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
+	free_netdev(bond_dev);
+}
+
 static void bond_setup(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -4470,7 +4478,7 @@ static void bond_setup(struct net_device *bond_dev)
 	bond_dev->ethtool_ops = &bond_ethtool_ops;
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = free_netdev;
+	bond_dev->destructor = bond_destructor;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4542,9 +4550,6 @@ static void bond_uninit(struct net_device *bond_dev)
 
 	bond_remove_proc_entry(bond);
 
-	if (bond->wq)
-		destroy_workqueue(bond->wq);
-
 	netif_addr_lock_bh(bond_dev);
 	bond_mc_list_destroy(bond);
 	netif_addr_unlock_bh(bond_dev);
