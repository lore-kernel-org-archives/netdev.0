From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 11/18]: Clean up unregister_vlan_dev
Date: Sun, 20 Jan 2008 18:11:32 +0100 (MET)
Message-ID: <20080120171132.7980.16660.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62363 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754491AbYATRLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:33 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Clean up unregister_vlan_dev

Save two levels of indentation by aborting on error conditions,
remove unnecessary initialization to NULL and remove two obvious
comments.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9f39c0253f370dae13a81cda9cf119052bb11750
tree d27c1417f8f19e0aff3833b6a631453c509c787e
parent 9829059db87d43bb24e82683e6bb4ed4a655fc39
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 net/8021q/vlan.c |   72 ++++++++++++++++++++++++------------------------------
 1 files changed, 32 insertions(+), 40 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 006d9a9..ad34e4a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -142,63 +142,55 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 static int unregister_vlan_dev(struct net_device *real_dev,
 			       unsigned short vlan_id)
 {
-	struct net_device *dev = NULL;
+	struct net_device *dev;
 	int real_dev_ifindex = real_dev->ifindex;
 	struct vlan_group *grp;
-	int i, ret;
+	unsigned int i;
+	int ret;
 
-	/* sanity check */
 	if (vlan_id >= VLAN_VID_MASK)
 		return -EINVAL;
 
 	ASSERT_RTNL();
 	grp = __vlan_find_group(real_dev_ifindex);
+	if (!grp)
+		return -ENOENT;
 
-	ret = 0;
-
-	if (grp) {
-		dev = vlan_group_get_device(grp, vlan_id);
-		if (dev) {
-			/* Remove proc entry */
-			vlan_proc_rem_dev(dev);
-
-			/* Take it out of our own structures, but be sure to
-			 * interlock with HW accelerating devices or SW vlan
-			 * input packet processing.
-			 */
-			if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-				real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
+	dev = vlan_group_get_device(grp, vlan_id);
+	if (!dev)
+		return -ENOENT;
 
-			vlan_group_set_device(grp, vlan_id, NULL);
-			synchronize_net();
+	vlan_proc_rem_dev(dev);
 
+	/* Take it out of our own structures, but be sure to interlock with
+	 * HW accelerating devices or SW vlan input packet processing.
+	 */
+	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+		real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
 
-			/* Caller unregisters (and if necessary, puts)
-			 * VLAN device, but we get rid of the reference to
-			 * real_dev here.
-			 */
-			dev_put(real_dev);
+	vlan_group_set_device(grp, vlan_id, NULL);
+	synchronize_net();
 
-			/* If the group is now empty, kill off the
-			 * group.
-			 */
-			for (i = 0; i < VLAN_VID_MASK; i++)
-				if (vlan_group_get_device(grp, i))
-					break;
+	/* Caller unregisters (and if necessary, puts) VLAN device, but we
+	 * get rid of the reference to real_dev here.
+	 */
+	dev_put(real_dev);
 
-			if (i == VLAN_VID_MASK) {
-				if (real_dev->features & NETIF_F_HW_VLAN_RX)
-					real_dev->vlan_rx_register(real_dev, NULL);
+	/* If the group is now empty, kill off the group. */
+	ret = 0;
+	for (i = 0; i < VLAN_VID_MASK; i++)
+		if (vlan_group_get_device(grp, i))
+			break;
 
-				hlist_del_rcu(&grp->hlist);
+	if (i == VLAN_VID_MASK) {
+		if (real_dev->features & NETIF_F_HW_VLAN_RX)
+			real_dev->vlan_rx_register(real_dev, NULL);
 
-				/* Free the group, after all cpu's are done. */
-				call_rcu(&grp->rcu, vlan_rcu_free);
+		hlist_del_rcu(&grp->hlist);
 
-				grp = NULL;
-				ret = 1;
-			}
-		}
+		/* Free the group, after all cpu's are done. */
+		call_rcu(&grp->rcu, vlan_rcu_free);
+		ret = 1;
 	}
 
 	return ret;
