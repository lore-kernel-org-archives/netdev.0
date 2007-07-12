From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 03/05]: Fix promiscous/allmulti synchronization races
Date: Thu, 12 Jul 2007 20:13:44 +0200 (MEST)
Message-ID: <20070712181343.13849.57866.sendpatchset@localhost.localdomain>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54189 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755425AbXGLSNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:45 -0400
In-Reply-To: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Fix promiscous/allmulti synchronization races

The set_multicast_list function may be called without holding the rtnl
mutex, resulting in races when changing the underlying device's promiscous
and allmulti state. Use the change_rx_mode hook, which is always invoked
under the rtnl.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 86de1244f4e8736a7bdfc28b899cc2ce5e36cf5c
tree 1379e7ae0b054d4f1390b0d1960aecee9ece37e6
parent 934ee4749ce12cb9b868a98fd3822cf5cdfa8208
author Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:57:34 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:57:34 +0200

 include/linux/if_vlan.h |    2 --
 net/8021q/vlan.c        |    1 +
 net/8021q/vlan.h        |    1 +
 net/8021q/vlan_dev.c    |   38 ++++++++++++++++++++------------------
 4 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 61a57dc..7f71df4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -132,8 +132,6 @@ struct vlan_dev_info {
                                            * made, in order to feed the right changes down
                                            * to the real hardware...
                                            */
-	int old_allmulti;               /* similar to above. */
-	int old_promiscuity;            /* similar to above. */
 	struct net_device *real_dev;    /* the underlying device/interface */
 	unsigned char real_dev_addr[ETH_ALEN];
 	struct proc_dir_entry *dent;    /* Holds the proc data */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index abb9900..39bdcc2 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -373,6 +373,7 @@ void vlan_setup(struct net_device *new_dev)
 	new_dev->open = vlan_dev_open;
 	new_dev->stop = vlan_dev_stop;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
+	new_dev->change_rx_flags = vlan_change_rx_flags;
 	new_dev->destructor = free_netdev;
 	new_dev->do_ioctl = vlan_dev_ioctl;
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 62ce1c5..7df5b29 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -69,6 +69,7 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 			   u32 flag, short flag_val);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
+void vlan_change_rx_flags(struct net_device *dev, int change);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index d4a62d1..dec7e62 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -712,6 +712,11 @@ int vlan_dev_open(struct net_device *dev)
 	}
 	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, 1);
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(real_dev, 1);
+
 	return 0;
 }
 
@@ -721,6 +726,11 @@ int vlan_dev_stop(struct net_device *dev)
 
 	vlan_flush_mc_list(dev);
 
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, -1);
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(real_dev, -1);
+
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
 
@@ -754,34 +764,26 @@ int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
+void vlan_change_rx_flags(struct net_device *dev, int change)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+
+	if (change & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+	if (change & IFF_PROMISC)
+		dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
+}
+
 /** Taken from Gleb + Lennert's VLAN code, and modified... */
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
 	struct dev_mc_list *dmi;
 	struct net_device *real_dev;
-	int inc;
 
 	if (vlan_dev && (vlan_dev->priv_flags & IFF_802_1Q_VLAN)) {
 		/* Then it's a real vlan device, as far as we can tell.. */
 		real_dev = VLAN_DEV_INFO(vlan_dev)->real_dev;
 
-		/* compare the current promiscuity to the last promisc we had.. */
-		inc = vlan_dev->promiscuity - VLAN_DEV_INFO(vlan_dev)->old_promiscuity;
-		if (inc) {
-			printk(KERN_INFO "%s: dev_set_promiscuity(master, %d)\n",
-			       vlan_dev->name, inc);
-			dev_set_promiscuity(real_dev, inc); /* found in dev.c */
-			VLAN_DEV_INFO(vlan_dev)->old_promiscuity = vlan_dev->promiscuity;
-		}
-
-		inc = vlan_dev->allmulti - VLAN_DEV_INFO(vlan_dev)->old_allmulti;
-		if (inc) {
-			printk(KERN_INFO "%s: dev_set_allmulti(master, %d)\n",
-			       vlan_dev->name, inc);
-			dev_set_allmulti(real_dev, inc); /* dev.c */
-			VLAN_DEV_INFO(vlan_dev)->old_allmulti = vlan_dev->allmulti;
-		}
-
 		/* looking for addresses to add to master's list */
 		for (dmi = vlan_dev->mc_list; dmi != NULL; dmi = dmi->next) {
 			if (vlan_should_add_mc(dmi, VLAN_DEV_INFO(vlan_dev)->old_mc_list)) {
