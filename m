From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 04/05]: Use multicast list synchronization helpers
Date: Thu, 12 Jul 2007 20:13:46 +0200 (MEST)
Message-ID: <20070712181345.13849.60797.sendpatchset@localhost.localdomain>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54192 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755318AbXGLSNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:47 -0400
In-Reply-To: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Use multicast list synchronization helpers

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 30fed2136dc8c9baea5aada97fc6ce60e99fdbf9
tree 8919e11b22f621c4ab2a3cbb45e8d4431385a38f
parent 86de1244f4e8736a7bdfc28b899cc2ce5e36cf5c
author Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:57:37 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:57:37 +0200

 include/linux/if_vlan.h |    5 --
 net/8021q/vlan_dev.c    |  131 +----------------------------------------------
 2 files changed, 2 insertions(+), 134 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 7f71df4..f8443fd 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -127,11 +127,6 @@ struct vlan_dev_info {
                                         *   like DHCP that use packet-filtering and don't understand
                                         *   802.1Q
                                         */
-	struct dev_mc_list *old_mc_list;  /* old multi-cast list for the VLAN interface..
-                                           * we save this so we can tell what changes were
-                                           * made, in order to feed the right changes down
-                                           * to the real hardware...
-                                           */
 	struct net_device *real_dev;    /* the underlying device/interface */
 	unsigned char real_dev_addr[ETH_ALEN];
 	struct proc_dir_entry *dent;    /* Holds the proc data */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index dec7e62..4d2aa4d 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -612,90 +612,6 @@ void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
 	*result = VLAN_DEV_INFO(dev)->vlan_id;
 }
 
-static inline int vlan_dmi_equals(struct dev_mc_list *dmi1,
-				  struct dev_mc_list *dmi2)
-{
-	return ((dmi1->dmi_addrlen == dmi2->dmi_addrlen) &&
-		(memcmp(dmi1->dmi_addr, dmi2->dmi_addr, dmi1->dmi_addrlen) == 0));
-}
-
-/** dmi is a single entry into a dev_mc_list, a single node.  mc_list is
- *  an entire list, and we'll iterate through it.
- */
-static int vlan_should_add_mc(struct dev_mc_list *dmi, struct dev_mc_list *mc_list)
-{
-	struct dev_mc_list *idmi;
-
-	for (idmi = mc_list; idmi != NULL; ) {
-		if (vlan_dmi_equals(dmi, idmi)) {
-			if (dmi->dmi_users > idmi->dmi_users)
-				return 1;
-			else
-				return 0;
-		} else {
-			idmi = idmi->next;
-		}
-	}
-
-	return 1;
-}
-
-static inline void vlan_destroy_mc_list(struct dev_mc_list *mc_list)
-{
-	struct dev_mc_list *dmi = mc_list;
-	struct dev_mc_list *next;
-
-	while(dmi) {
-		next = dmi->next;
-		kfree(dmi);
-		dmi = next;
-	}
-}
-
-static void vlan_copy_mc_list(struct dev_mc_list *mc_list, struct vlan_dev_info *vlan_info)
-{
-	struct dev_mc_list *dmi, *new_dmi;
-
-	vlan_destroy_mc_list(vlan_info->old_mc_list);
-	vlan_info->old_mc_list = NULL;
-
-	for (dmi = mc_list; dmi != NULL; dmi = dmi->next) {
-		new_dmi = kmalloc(sizeof(*new_dmi), GFP_ATOMIC);
-		if (new_dmi == NULL) {
-			printk(KERN_ERR "vlan: cannot allocate memory. "
-			       "Multicast may not work properly from now.\n");
-			return;
-		}
-
-		/* Copy whole structure, then make new 'next' pointer */
-		*new_dmi = *dmi;
-		new_dmi->next = vlan_info->old_mc_list;
-		vlan_info->old_mc_list = new_dmi;
-	}
-}
-
-static void vlan_flush_mc_list(struct net_device *dev)
-{
-	struct dev_mc_list *dmi = dev->mc_list;
-
-	while (dmi) {
-		printk(KERN_DEBUG "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from vlan interface\n",
-		       dev->name,
-		       dmi->dmi_addr[0],
-		       dmi->dmi_addr[1],
-		       dmi->dmi_addr[2],
-		       dmi->dmi_addr[3],
-		       dmi->dmi_addr[4],
-		       dmi->dmi_addr[5]);
-		dev_mc_delete(dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-		dmi = dev->mc_list;
-	}
-
-	/* dev->mc_list is NULL by the time we get here. */
-	vlan_destroy_mc_list(VLAN_DEV_INFO(dev)->old_mc_list);
-	VLAN_DEV_INFO(dev)->old_mc_list = NULL;
-}
-
 int vlan_dev_open(struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
@@ -724,8 +640,7 @@ int vlan_dev_stop(struct net_device *dev)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 
-	vlan_flush_mc_list(dev);
-
+	dev_mc_unsync(real_dev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, -1);
 	if (dev->flags & IFF_PROMISC)
@@ -777,47 +692,5 @@ void vlan_change_rx_flags(struct net_device *dev, int change)
 /** Taken from Gleb + Lennert's VLAN code, and modified... */
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
-	struct dev_mc_list *dmi;
-	struct net_device *real_dev;
-
-	if (vlan_dev && (vlan_dev->priv_flags & IFF_802_1Q_VLAN)) {
-		/* Then it's a real vlan device, as far as we can tell.. */
-		real_dev = VLAN_DEV_INFO(vlan_dev)->real_dev;
-
-		/* looking for addresses to add to master's list */
-		for (dmi = vlan_dev->mc_list; dmi != NULL; dmi = dmi->next) {
-			if (vlan_should_add_mc(dmi, VLAN_DEV_INFO(vlan_dev)->old_mc_list)) {
-				dev_mc_add(real_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-				printk(KERN_DEBUG "%s: add %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address to master interface\n",
-				       vlan_dev->name,
-				       dmi->dmi_addr[0],
-				       dmi->dmi_addr[1],
-				       dmi->dmi_addr[2],
-				       dmi->dmi_addr[3],
-				       dmi->dmi_addr[4],
-				       dmi->dmi_addr[5]);
-			}
-		}
-
-		/* looking for addresses to delete from master's list */
-		for (dmi = VLAN_DEV_INFO(vlan_dev)->old_mc_list; dmi != NULL; dmi = dmi->next) {
-			if (vlan_should_add_mc(dmi, vlan_dev->mc_list)) {
-				/* if we think we should add it to the new list, then we should really
-				 * delete it from the real list on the underlying device.
-				 */
-				dev_mc_delete(real_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-				printk(KERN_DEBUG "%s: del %.2x:%.2x:%.2x:%.2x:%.2x:%.2x mcast address from master interface\n",
-				       vlan_dev->name,
-				       dmi->dmi_addr[0],
-				       dmi->dmi_addr[1],
-				       dmi->dmi_addr[2],
-				       dmi->dmi_addr[3],
-				       dmi->dmi_addr[4],
-				       dmi->dmi_addr[5]);
-			}
-		}
-
-		/* save multicast list */
-		vlan_copy_mc_list(vlan_dev->mc_list, VLAN_DEV_INFO(vlan_dev));
-	}
+	dev_mc_sync(VLAN_DEV_INFO(vlan_dev)->real_dev, vlan_dev);
 }
