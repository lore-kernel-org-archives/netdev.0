From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.70+] vlan network device using alloc_netdev
Date: Mon, 9 Jun 2003 11:55:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609115543.42092c96.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change how vlan driver allocates private data so that it is like ether devices,
and will support later changes for delayed free.

diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	Mon Jun  9 11:43:20 2003
+++ b/net/8021q/vlan.c	Mon Jun  9 11:43:20 2003
@@ -334,6 +334,33 @@
 	return ret;
 }
 
+static void vlan_setup(struct net_device *new_dev)
+{
+	SET_MODULE_OWNER(new_dev);
+	    
+	/* new_dev->ifindex = 0;  it will be set when added to
+	 * the global list.
+	 * iflink is set as well.
+	 */
+	new_dev->get_stats = vlan_dev_get_stats;
+
+	/* Make this thing known as a VLAN device */
+	new_dev->priv_flags |= IFF_802_1Q_VLAN;
+				
+	/* Set us up to have no queue, as the underlying Hardware device
+	 * can do all the queueing we could want.
+	 */
+	new_dev->tx_queue_len = 0;
+
+	/* set up method calls */
+	new_dev->change_mtu = vlan_dev_change_mtu;
+	new_dev->open = vlan_dev_open;
+	new_dev->stop = vlan_dev_stop;
+	new_dev->set_mac_address = vlan_dev_set_mac_address;
+	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
+	new_dev->destructor = (void (*)(struct net_device *)) kfree;
+}
+
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns the device that was created, or NULL if there was
  *  an error of some kind.
@@ -344,8 +371,8 @@
 	struct vlan_group *grp;
 	struct net_device *new_dev;
 	struct net_device *real_dev; /* the ethernet device */
-	int malloc_size = 0;
 	int r;
+	char name[IFNAMSIZ];
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
@@ -403,21 +430,6 @@
 		goto out_unlock;
 	}
 
-	malloc_size = (sizeof(struct net_device));
-	new_dev = (struct net_device *) kmalloc(malloc_size, GFP_KERNEL);
-	VLAN_MEM_DBG("net_device malloc, addr: %p  size: %i\n",
-		     new_dev, malloc_size);
-
-	if (new_dev == NULL)
-		goto out_unlock;
-
-	memset(new_dev, 0, malloc_size);
-
-	/* Set us up to have no queue, as the underlying Hardware device
-	 * can do all the queueing we could want.
-	 */
-	new_dev->tx_queue_len = 0;
-
 	/* Gotta set up the fields for the device. */
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "About to allocate name, vlan_name_type: %i\n",
@@ -426,54 +438,44 @@
 	switch (vlan_name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
-		sprintf(new_dev->name, "%s.%.4i", real_dev->name, VLAN_ID);
+		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, VLAN_ID);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan5
 		 */
-		sprintf(new_dev->name, "vlan%i", VLAN_ID);
+		snprintf(name, IFNAMSIZ, "vlan%i", VLAN_ID);
 		break;
 	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 eth0.5
 		 */
-		sprintf(new_dev->name, "%s.%i", real_dev->name, VLAN_ID);
+		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, VLAN_ID);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan0005
 		 */
 	default:
-		sprintf(new_dev->name, "vlan%.4i", VLAN_ID);
+		snprintf(name, IFNAMSIZ, "vlan%.4i", VLAN_ID);
 	};
 		    
+	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
+			       vlan_setup);
+	if (new_dev == NULL)
+		goto out_unlock;
+
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
 #endif
-	/* set up method calls */
-	new_dev->init = vlan_dev_init;
-	new_dev->destructor = vlan_dev_destruct;
-	SET_MODULE_OWNER(new_dev);
-	    
-	/* new_dev->ifindex = 0;  it will be set when added to
-	 * the global list.
-	 * iflink is set as well.
-	 */
-	new_dev->get_stats = vlan_dev_get_stats;
-	    
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	new_dev->flags = real_dev->flags;
 	new_dev->flags &= ~IFF_UP;
 
-	/* Make this thing known as a VLAN device */
-	new_dev->priv_flags |= IFF_802_1Q_VLAN;
-				
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
 	 */
 	new_dev->mtu = real_dev->mtu;
-	new_dev->change_mtu = vlan_dev_change_mtu;
 
 	/* TODO: maybe just assign it to be ETHERNET? */
 	new_dev->type = real_dev->type;
@@ -484,24 +486,14 @@
 		new_dev->hard_header_len += VLAN_HLEN;
 	}
 
-	new_dev->priv = kmalloc(sizeof(struct vlan_dev_info),
-				GFP_KERNEL);
 	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
 		     new_dev->priv,
 		     sizeof(struct vlan_dev_info));
 	    
-	if (new_dev->priv == NULL)
-		goto out_free_newdev;
-
-	memset(new_dev->priv, 0, sizeof(struct vlan_dev_info));
-
 	memcpy(new_dev->broadcast, real_dev->broadcast, real_dev->addr_len);
 	memcpy(new_dev->dev_addr, real_dev->dev_addr, real_dev->addr_len);
 	new_dev->addr_len = real_dev->addr_len;
 
-	new_dev->open = vlan_dev_open;
-	new_dev->stop = vlan_dev_stop;
-
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		new_dev->hard_header = real_dev->hard_header;
 		new_dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
@@ -512,8 +504,6 @@
 		new_dev->rebuild_header = vlan_dev_rebuild_header;
 	}
 	new_dev->hard_header_parse = real_dev->hard_header_parse;
-	new_dev->set_mac_address = vlan_dev_set_mac_address;
-	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 
 	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
@@ -526,7 +516,7 @@
 #endif
 	    
 	if (register_netdevice(new_dev))
-		goto out_free_newdev_priv;
+		goto out_free_newdev;
 
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
@@ -572,9 +562,7 @@
 
 out_free_unregister:
 	unregister_netdev(new_dev);
-
-out_free_newdev_priv:
-	kfree(new_dev->priv);
+	goto out_put_dev;
 
 out_free_newdev:
 	kfree(new_dev);
diff -Nru a/net/8021q/vlan.h b/net/8021q/vlan.h
--- a/net/8021q/vlan.h	Mon Jun  9 11:43:20 2003
+++ b/net/8021q/vlan.h	Mon Jun  9 11:43:20 2003
@@ -65,8 +65,6 @@
 int vlan_dev_set_mac_address(struct net_device *dev, void* addr);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
-int vlan_dev_init(struct net_device* dev);
-void vlan_dev_destruct(struct net_device* dev);
 int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	Mon Jun  9 11:43:20 2003
+++ b/net/8021q/vlan_dev.c	Mon Jun  9 11:43:20 2003
@@ -766,28 +766,6 @@
 	vlan_flush_mc_list(dev);
 	return 0;
 }
-
-int vlan_dev_init(struct net_device *dev)
-{
-	/* TODO:  figure this out, maybe do nothing?? */
-	return 0;
-}
-
-void vlan_dev_destruct(struct net_device *dev)
-{
-	if (dev) {
-		vlan_flush_mc_list(dev);
-		if (dev->priv) {
-			if (VLAN_DEV_INFO(dev)->dent)
-				BUG();
-
-			kfree(dev->priv);
-			dev->priv = NULL;
-		}
-		kfree(dev);
-	}
-}
-
 /** Taken from Gleb + Lennert's VLAN code, and modified... */
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
