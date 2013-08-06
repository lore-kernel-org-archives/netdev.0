From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 1/2] bonding: change the bond's vlan syncing functions with the standard ones
Date: Tue,  6 Aug 2013 12:40:15 +0200
Message-ID: <1375785616-5349-2-git-send-email-nikolay@redhat.com>
References: <1375785616-5349-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31431 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755965Ab3HFKnw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 06:43:52 -0400
In-Reply-To: <1375785616-5349-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>

Now we have vlan_vids_add/del_by_dev() which serve the same purpose as
bond's bond_add/del_vlans_on_slave() with the good side effect of
reverting the changes if one of the additions fails.
There's only 1 change in the behaviour of enslave: if adding of the
vlans to the slave fails, we'll fail the enslaving because otherwise we
might delete some vlan that wasn't added by the bonding.
The only way this may happen is with ENOMEM currently, so we're in trouble
anyway.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: Fail enslavement with an error message if syncing of vlans fails
because otherwise we might delete vlans that weren't added by us.

 drivers/net/bonding/bond_main.c | 37 +++++++------------------------------
 1 file changed, 7 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5697043..78b0aeb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -493,33 +493,6 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 	return 0;
 }
 
-static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
-{
-	struct vlan_entry *vlan;
-	int res;
-
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		res = vlan_vid_add(slave_dev, htons(ETH_P_8021Q),
-				   vlan->vlan_id);
-		if (res)
-			pr_warning("%s: Failed to add vlan id %d to device %s\n",
-				   bond->dev->name, vlan->vlan_id,
-				   slave_dev->name);
-	}
-}
-
-static void bond_del_vlans_from_slave(struct bonding *bond,
-				      struct net_device *slave_dev)
-{
-	struct vlan_entry *vlan;
-
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		if (!vlan->vlan_id)
-			continue;
-		vlan_vid_del(slave_dev, htons(ETH_P_8021Q), vlan->vlan_id);
-	}
-}
-
 /*------------------------------- Link status -------------------------------*/
 
 /*
@@ -1630,7 +1603,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		dev_mc_add(slave_dev, lacpdu_multicast);
 	}
 
-	bond_add_vlans_on_slave(bond, slave_dev);
+	if (vlan_vids_add_by_dev(slave_dev, bond_dev)) {
+		pr_err("%s: Error: Couldn't add bond vlan ids to %s\n",
+		       bond_dev->name, slave_dev->name);
+		goto err_close;
+	}
 
 	write_lock_bh(&bond->lock);
 
@@ -1806,7 +1783,7 @@ err_detach:
 	if (!USES_PRIMARY(bond->params.mode))
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
-	bond_del_vlans_from_slave(bond, slave_dev);
+	vlan_vids_del_by_dev(slave_dev, bond_dev);
 	write_lock_bh(&bond->lock);
 	bond_detach_slave(bond, new_slave);
 	if (bond->primary_slave == new_slave)
@@ -2002,7 +1979,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* must do this from outside any spinlocks */
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
-	bond_del_vlans_from_slave(bond, slave_dev);
+	vlan_vids_del_by_dev(slave_dev, bond_dev);
 
 	/* If the mode USES_PRIMARY, then this cases was handled above by
 	 * bond_change_active_slave(..., NULL)
-- 
1.8.1.4
