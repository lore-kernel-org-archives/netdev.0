From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [net-next, 2/3] bonding: change the bond's vlan syncing
 functions with the standard ones
Date: Mon, 5 Aug 2013 23:56:39 +0200
Message-ID: <20130805215639.GA14280@redhat.com>
References: <1375709304-16778-3-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754717Ab3HEV4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:56:52 -0400
Content-Disposition: inline
In-Reply-To: <1375709304-16778-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 05, 2013 at 03:28:23PM +0200, nikolay@redhat.com wrote:
>From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>
>Now we have vlan_vids_add/del_by_dev() which serve the same purpose as
>bond's bond_add/del_vlans_on_slave() with the good side effect of
>reverting the changes if one of the additions fails.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>
>---
>drivers/net/bonding/bond_main.c | 35 +++++------------------------------
> 1 file changed, 5 insertions(+), 30 deletions(-)

-25, awesome, great one :)

Acked-by: Veaceslav Falico <vfalico@redhat.com>

>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 5df8bcd..ed1d261 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -521,33 +521,6 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
> 	return __bond_vlan_rx_kill_vid(bond_dev, proto, vid);
> }
>
>-static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
>-{
>-	struct vlan_entry *vlan;
>-	int res;
>-
>-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>-		res = vlan_vid_add(slave_dev, htons(ETH_P_8021Q),
>-				   vlan->vlan_id);
>-		if (res)
>-			pr_warning("%s: Failed to add vlan id %d to device %s\n",
>-				   bond->dev->name, vlan->vlan_id,
>-				   slave_dev->name);
>-	}
>-}
>-
>-static void bond_del_vlans_from_slave(struct bonding *bond,
>-				      struct net_device *slave_dev)
>-{
>-	struct vlan_entry *vlan;
>-
>-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
>-		if (!vlan->vlan_id)
>-			continue;
>-		vlan_vid_del(slave_dev, htons(ETH_P_8021Q), vlan->vlan_id);
>-	}
>-}
>-
> /*------------------------------- Link status -------------------------------*/
>
> /*
>@@ -1656,7 +1629,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 		dev_mc_add(slave_dev, lacpdu_multicast);
> 	}
>
>-	bond_add_vlans_on_slave(bond, slave_dev);
>+	if (vlan_vids_add_by_dev(slave_dev, bond_dev))
>+		pr_warn("%s: couldn't add bond vlan ids to %s",
>+			bond_dev->name, slave_dev->name);
>
> 	write_lock_bh(&bond->lock);
>
>@@ -1832,7 +1807,7 @@ err_detach:
> 	if (!USES_PRIMARY(bond->params.mode))
> 		bond_hw_addr_flush(bond_dev, slave_dev);
>
>-	bond_del_vlans_from_slave(bond, slave_dev);
>+	vlan_vids_del_by_dev(slave_dev, bond_dev);
> 	write_lock_bh(&bond->lock);
> 	bond_detach_slave(bond, new_slave);
> 	if (bond->primary_slave == new_slave)
>@@ -2028,7 +2003,7 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	/* must do this from outside any spinlocks */
> 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
>
>-	bond_del_vlans_from_slave(bond, slave_dev);
>+	vlan_vids_del_by_dev(slave_dev, bond_dev);
>
> 	/* If the mode USES_PRIMARY, then this cases was handled above by
> 	 * bond_change_active_slave(..., NULL)
