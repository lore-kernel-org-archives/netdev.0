From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 12/18]: Split up device checks
Date: Wed, 13 Jun 2007 18:50:58 +0200 (MEST)
Message-ID: <20070613165055.7780.71274.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35957 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758898AbXFMQvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:00 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Split up device checks

Move the checks of the underlying device to a seperate function.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8defb0af6d2f31cfa6180b0b4c83124f5d90cb32
tree a460163ea31c953a60b894a24051deee5f401006
parent db130c75de212df303702758f553a7f4349ae56a
author Patrick McHardy <kaber@trash.net> Wed, 06 Jun 2007 14:46:43 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:32 +0200

 net/8021q/vlan.c |   56 +++++++++++++++++++++++++++++++-----------------------
 1 files changed, 32 insertions(+), 24 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 1b9dc5e..1e33dbb 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -410,57 +410,65 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 	}
 }
 
-/*  Attach a VLAN device to a mac address (ie Ethernet Card).
- *  Returns the device that was created, or NULL if there was
- *  an error of some kind.
- */
-static struct net_device *register_vlan_device(struct net_device *real_dev,
-					       unsigned short VLAN_ID)
+static int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
 {
-	struct vlan_group *grp, *ngrp = NULL;
-	struct net_device *new_dev;
-	char name[IFNAMSIZ];
-
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
-		__FUNCTION__, eth_IF_name, VLAN_ID);
-#endif
-
-	if (VLAN_ID >= VLAN_VID_MASK)
-		goto out_ret_null;
-
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		printk(VLAN_DBG "%s: VLANs not supported on %s.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
 	    !real_dev->vlan_rx_register) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    (!real_dev->vlan_rx_add_vid || !real_dev->vlan_rx_kill_vid)) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+		return -EOPNOTSUPP;
 	}
 
 	/* The real device must be up and operating in order to
 	 * assosciate a VLAN device with it.
 	 */
 	if (!(real_dev->flags & IFF_UP))
-		goto out_ret_null;
+		return -ENETDOWN;
 
-	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
+	if (__find_vlan_dev(real_dev, vlan_id) != NULL) {
 		/* was already registered. */
 		printk(VLAN_DBG "%s: ALREADY had VLAN registered\n", __FUNCTION__);
-		goto out_ret_null;
+		return -EEXIST;
 	}
 
+	return 0;
+}
+
+/*  Attach a VLAN device to a mac address (ie Ethernet Card).
+ *  Returns the device that was created, or NULL if there was
+ *  an error of some kind.
+ */
+static struct net_device *register_vlan_device(struct net_device *real_dev,
+					       unsigned short VLAN_ID)
+{
+	struct vlan_group *grp, *ngrp = NULL;
+	struct net_device *new_dev;
+	char name[IFNAMSIZ];
+
+#ifdef VLAN_DEBUG
+	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
+		__FUNCTION__, eth_IF_name, VLAN_ID);
+#endif
+
+	if (VLAN_ID >= VLAN_VID_MASK)
+		goto out_ret_null;
+
+	if (vlan_check_real_dev(real_dev, VLAN_ID) < 0)
+		goto out_ret_null;
+
 	/* Gotta set up the fields for the device. */
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "About to allocate name, vlan_name_type: %i\n",
