From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 03/08]: Add device init callback
Date: Tue,  5 Jun 2007 16:23:33 +0200 (MEST)
Message-ID: <20070605142332.20372.26478.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64166 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764287AbXFEOXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:36 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Add device init callback

Move device initialization to ->init callback to fix an incorrect iflink
value in the initial NEWLINK message. Additionally this makes sure the
lockdep class is properly set before the device will be used.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c771a6df20db3f21062bbbf56f09f2a64535cb71
tree 7068db9a14adb06df077b6634318db72d0eb6c7d
parent 7286bd4222a1a9722b1d3b80988078b0af973a67
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 15:48:16 +0200

 net/8021q/vlan.c |  103 +++++++++++++++++++++++++++---------------------------
 1 files changed, 52 insertions(+), 51 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 87de961..c745530 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -256,6 +256,53 @@ static int unregister_vlan_dev(struct net_device *dev)
 	return ret;
 }
 
+/*
+ * vlan network devices have devices nesting below it, and are a special
+ * "super class" of normal network devices; split their locks off into a
+ * separate class since they always nest.
+ */
+static struct lock_class_key vlan_netdev_xmit_lock_key;
+
+static int vlan_dev_init(struct net_device *dev)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+
+	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
+	dev->flags  = real_dev->flags & ~IFF_UP;
+	dev->iflink = real_dev->ifindex;
+	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
+					  (1<<__LINK_STATE_DORMANT))) |
+		      (1<<__LINK_STATE_PRESENT);
+
+	/* need 4 bytes for extra VLAN header info,
+	 * hope the underlying device can handle it.
+	 */
+	dev->mtu = real_dev->mtu;
+
+	/* TODO: maybe just assign it to be ETHERNET? */
+	dev->type = real_dev->type;
+
+	memcpy(dev->broadcast, real_dev->broadcast, real_dev->addr_len);
+	memcpy(dev->dev_addr, real_dev->dev_addr, real_dev->addr_len);
+	dev->addr_len = real_dev->addr_len;
+
+	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+		dev->hard_header     = real_dev->hard_header;
+		dev->hard_header_len = real_dev->hard_header_len;
+		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
+		dev->rebuild_header  = real_dev->rebuild_header;
+	} else {
+		dev->hard_header     = vlan_dev_hard_header;
+		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
+		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
+		dev->rebuild_header  = vlan_dev_rebuild_header;
+	}
+	dev->hard_header_parse = real_dev->hard_header_parse;
+
+	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+	return 0;
+}
+
 static void vlan_setup(struct net_device *new_dev)
 {
 	SET_MODULE_OWNER(new_dev);
@@ -276,6 +323,7 @@ static void vlan_setup(struct net_device *new_dev)
 
 	/* set up method calls */
 	new_dev->change_mtu = vlan_dev_change_mtu;
+	new_dev->init = vlan_dev_init;
 	new_dev->open = vlan_dev_open;
 	new_dev->stop = vlan_dev_stop;
 	new_dev->set_mac_address = vlan_dev_set_mac_address;
@@ -304,14 +352,6 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 	}
 }
 
-/*
- * vlan network devices have devices nesting below it, and are a special
- * "super class" of normal network devices; split their locks off into a
- * separate class since they always nest.
- */
-static struct lock_class_key vlan_netdev_xmit_lock_key;
-
-
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns the device that was created, or NULL if there was
  *  an error of some kind.
@@ -405,52 +445,16 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
 #endif
-	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	new_dev->flags = real_dev->flags;
-	new_dev->flags &= ~IFF_UP;
-
-	new_dev->state = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
-					     (1<<__LINK_STATE_DORMANT))) |
-			 (1<<__LINK_STATE_PRESENT);
-
-	/* need 4 bytes for extra VLAN header info,
-	 * hope the underlying device can handle it.
-	 */
-	new_dev->mtu = real_dev->mtu;
-
-	/* TODO: maybe just assign it to be ETHERNET? */
-	new_dev->type = real_dev->type;
-
-	new_dev->hard_header_len = real_dev->hard_header_len;
-	if (!(real_dev->features & NETIF_F_HW_VLAN_TX)) {
-		/* Regular ethernet + 4 bytes (18 total). */
-		new_dev->hard_header_len += VLAN_HLEN;
-	}
-
-	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
-		     new_dev->priv,
-		     sizeof(struct vlan_dev_info));
-
-	memcpy(new_dev->broadcast, real_dev->broadcast, real_dev->addr_len);
-	memcpy(new_dev->dev_addr, real_dev->dev_addr, real_dev->addr_len);
-	new_dev->addr_len = real_dev->addr_len;
-
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
-		new_dev->hard_header = real_dev->hard_header;
-		new_dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
-		new_dev->rebuild_header = real_dev->rebuild_header;
-	} else {
-		new_dev->hard_header = vlan_dev_hard_header;
-		new_dev->hard_start_xmit = vlan_dev_hard_start_xmit;
-		new_dev->rebuild_header = vlan_dev_rebuild_header;
-	}
-	new_dev->hard_header_parse = real_dev->hard_header_parse;
 
 	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
 	VLAN_DEV_INFO(new_dev)->flags = 1;
 
+	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
+		     new_dev->priv,
+		     sizeof(struct vlan_dev_info));
+
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "About to go find the group for idx: %i\n",
 	       real_dev->ifindex);
@@ -459,9 +463,6 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	if (register_netdevice(new_dev))
 		goto out_free_newdev;
 
-	lockdep_set_class(&new_dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
-
-	new_dev->iflink = real_dev->ifindex;
 	vlan_transfer_operstate(real_dev, new_dev);
 	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
 
