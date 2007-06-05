From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 03/10]: Move some device intialization code to dev->init callback
Date: Tue,  5 Jun 2007 16:36:55 +0200 (MEST)
Message-ID: <20070605143654.23717.16259.sendpatchset@localhost.localdomain>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64422 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763483AbXFEOg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:36:56 -0400
In-Reply-To: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Move some device intialization code to dev->init callback

Move some device initialization code to new dev->init callback to make
it shareable with netlink. Additionally this fixes a minor bug, dev->iflink
is set after registration, which causes an incorrect value in the initial
netlink message.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ffed416aac143a9431c7d9d6b3214288809eb89a
tree 5c4be92ecd9fddaac6899d5a704398ba95c9bdcb
parent 9f146bc68a86cb588f3150894b3af5646cfb4fdc
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200

 net/8021q/vlan.c |   98 +++++++++++++++++++++++++++---------------------------
 1 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 788324a..7da8210 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -291,6 +291,53 @@ static int unregister_vlan_device(struct net_device *dev)
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
@@ -311,6 +358,7 @@ static void vlan_setup(struct net_device *new_dev)
 
 	/* set up method calls */
 	new_dev->change_mtu = vlan_dev_change_mtu;
+	new_dev->init = vlan_dev_init;
 	new_dev->open = vlan_dev_open;
 	new_dev->stop = vlan_dev_stop;
 	new_dev->set_mac_address = vlan_dev_set_mac_address;
@@ -339,14 +387,6 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
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
@@ -437,47 +477,10 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
-#endif
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
 	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
 		     new_dev->priv,
 		     sizeof(struct vlan_dev_info));
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
+#endif
 
 	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
@@ -492,9 +495,6 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 	if (register_netdevice(new_dev))
 		goto out_free_newdev;
 
-	lockdep_set_class(&new_dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
-
-	new_dev->iflink = real_dev->ifindex;
 	vlan_transfer_operstate(real_dev, new_dev);
 	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
 
