From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 4/6] vlan: Optimize multiple unregistration
Date: Tue, 27 Oct 2009 18:06:49 +0100
Message-ID: <4AE728A9.2080209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36643 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267AbZJ0RHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:07:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use unregister_netdevice_many() to speedup master device unregister.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/if_vlan.h |    1 
 net/8021q/vlan.c        |   49 +++++++++++++++++++++++++-------------
 net/core/dev.c          |    1 
 3 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8898cbe..71a4870 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -85,6 +85,7 @@ struct vlan_group {
 					    * the vlan is attached to.
 					    */
 	unsigned int		nr_vlans;
+	int			killall;
 	struct hlist_node	hlist;	/* linked list */
 	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
 	struct rcu_head		rcu;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 6b5c9dd..511afe7 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -159,11 +159,12 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
-	vlan_group_set_device(grp, vlan_id, NULL);
 	grp->nr_vlans--;
 
-	synchronize_net();
-
+	if (!grp->killall) {
+		vlan_group_set_device(grp, vlan_id, NULL);
+		synchronize_net();
+	}
 	unregister_netdevice_queue(dev, head);
 
 	/* If the group is now empty, kill off the group. */
@@ -183,6 +184,34 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
+void unregister_vlan_dev_alls(struct vlan_group *grp)
+{
+	LIST_HEAD(list);
+	int i;
+	struct net_device *vlandev;
+	struct vlan_group save;
+
+	memcpy(&save, grp, sizeof(save));
+	memset(&grp->vlan_devices_arrays, 0, sizeof(grp->vlan_devices_arrays));
+	grp->killall = 1;
+
+	synchronize_net();
+
+	/* Delete all VLANs for this dev. */
+	for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+		vlandev = vlan_group_get_device(&save, i);
+		if (!vlandev)
+			continue;
+
+		unregister_vlan_dev(vlandev, &list);
+		if (grp->nr_vlans == 0)
+			break;
+	}
+	unregister_netdevice_many(&list);
+	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
+		kfree(save.vlan_devices_arrays[i]);
+}
+
 static void vlan_transfer_operstate(const struct net_device *dev,
 				    struct net_device *vlandev)
 {
@@ -524,19 +553,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_UNREGISTER:
-		/* Delete all VLANs for this dev. */
-		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
-			/* unregistration of last vlan destroys group, abort
-			 * afterwards */
-			if (grp->nr_vlans == 1)
-				i = VLAN_GROUP_ARRAY_LEN;
-
-			unregister_vlan_dev(vlandev, NULL);
-		}
+		unregister_vlan_dev_alls(grp);
 		break;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index dedacd8..82a3bb9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5303,6 +5303,7 @@ void unregister_netdevice_many(struct list_head *head)
 			net_set_todo(dev);
 	}
 }
+EXPORT_SYMBOL(unregister_netdevice_many);
 
 /**
  *	unregister_netdev - remove device from the kernel
