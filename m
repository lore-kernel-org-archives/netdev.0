From: Chris Leech <christopher.leech@intel.com>
Subject: [VLAN] set_rx_mode support for unicast address list
Date: Thu, 24 Jan 2008 08:07:48 -0800
Message-ID: <20080124160738.11781.23745.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Chris Leech <christopher.leech@intel.com>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3906 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbYAXQHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 11:07:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reuse the existing logic for multicast list synchronization for the unicast
address list. The core of dev_mc_sync/unsync are split out as
__dev_addr_sync/unsync and moved from dev_mcast.c to dev.c.  These are then
used to implement dev_unicast_sync/unsync as well.

I'm working on cleaning up Intel's FCoE stack, which generates new MAC
addresses from the fibre channel device id assigned by the fabric as per the
current draft specification in T11.  When using such a protocol in a VLAN
environment it would be nice to not always be forced into promiscuous mode,
assuming the underlying Ethernet driver supports multiple unicast addresses as
well.

Signed-off-by: Chris Leech <christopher.leech@intel.com>
---

 include/linux/netdevice.h |    4 ++
 net/8021q/vlan_dev.c      |    7 ++-
 net/core/dev.c            |   96 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev_mcast.c      |   39 ++----------------
 4 files changed, 110 insertions(+), 36 deletions(-)


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b0813c3..047d432 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1414,12 +1414,16 @@ extern void		dev_set_rx_mode(struct net_device *dev);
 extern void		__dev_set_rx_mode(struct net_device *dev);
 extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
 extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
+extern int		dev_unicast_sync(struct net_device *to, struct net_device *from);
+extern void		dev_unicast_unsync(struct net_device *to, struct net_device *from);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
 extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
 extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
 extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
+extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
+extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 8059fa4..77f04e4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -563,6 +563,7 @@ static int vlan_dev_stop(struct net_device *dev)
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
 	dev_mc_unsync(real_dev, dev);
+	dev_unicast_unsync(real_dev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, -1);
 	if (dev->flags & IFF_PROMISC)
@@ -634,9 +635,10 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 		dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
 }
 
-static void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
+static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
 {
 	dev_mc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
+	dev_unicast_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
 }
 
 /*
@@ -702,7 +704,8 @@ void vlan_setup(struct net_device *dev)
 	dev->open		= vlan_dev_open;
 	dev->stop		= vlan_dev_stop;
 	dev->set_mac_address	= vlan_dev_set_mac_address;
-	dev->set_multicast_list	= vlan_dev_set_multicast_list;
+	dev->set_rx_mode	= vlan_dev_set_rx_mode;
+	dev->set_multicast_list	= vlan_dev_set_rx_mode;
 	dev->change_rx_flags	= vlan_dev_change_rx_flags;
 	dev->do_ioctl		= vlan_dev_ioctl;
 	dev->destructor		= free_netdev;
diff --git a/net/core/dev.c b/net/core/dev.c
index c9c593e..edaff27 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2962,6 +2962,102 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 }
 EXPORT_SYMBOL(dev_unicast_add);
 
+int __dev_addr_sync(struct dev_addr_list **to, int *to_count,
+		    struct dev_addr_list **from, int *from_count)
+{
+	struct dev_addr_list *da, *next;
+	int err = 0;
+
+	da = *from;
+	while (da != NULL) {
+		next = da->next;
+		if (!da->da_synced) {
+			err = __dev_addr_add(to, to_count,
+					     da->da_addr, da->da_addrlen, 0);
+			if (err < 0)
+				break;
+			da->da_synced = 1;
+			da->da_users++;
+		} else if (da->da_users == 1) {
+			__dev_addr_delete(to, to_count,
+					  da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(from, from_count,
+					  da->da_addr, da->da_addrlen, 0);
+		}
+		da = next;
+	}
+	return err;
+}
+
+void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
+		       struct dev_addr_list **from, int *from_count)
+{
+	struct dev_addr_list *da, *next;
+
+	da = *from;
+	while (da != NULL) {
+		next = da->next;
+		if (da->da_synced) {
+			__dev_addr_delete(to, to_count,
+					  da->da_addr, da->da_addrlen, 0);
+			da->da_synced = 0;
+			__dev_addr_delete(from, from_count,
+					  da->da_addr, da->da_addrlen, 0);
+		}
+		da = next;
+	}
+}
+
+/**
+ *	dev_unicast_sync - Synchronize device's unicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Add newly added addresses to the destination device and release
+ *	addresses that have no users left. The source device must be
+ *	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_rx_mode
+ *	function of layered software devices.
+ */
+int dev_unicast_sync(struct net_device *to, struct net_device *from)
+{
+	int err = 0;
+
+	netif_tx_lock_bh(to);
+	err = __dev_addr_sync(&to->uc_list, &to->uc_count,
+			      &from->uc_list, &from->uc_count);
+	if (!err)
+		__dev_set_rx_mode(to);
+	netif_tx_unlock_bh(to);
+	return err;
+}
+EXPORT_SYMBOL(dev_unicast_sync);
+
+/**
+ *	dev_unicast_unsync - Remove synchronized addresses from the destination
+ *			     device
+ *	@to: destination device
+ *	@from: source device
+ *
+ *	Remove all addresses that were added to the destination device by
+ *	dev_unicast_sync(). This function is intended to be called from the
+ *	dev->stop function of layered software devices.
+ */
+void dev_unicast_unsync(struct net_device *to, struct net_device *from)
+{
+	netif_tx_lock_bh(from);
+	netif_tx_lock_bh(to);
+
+	__dev_addr_unsync(&to->uc_list, &to->uc_count,
+			  &from->uc_list, &from->uc_count);
+	__dev_set_rx_mode(to);
+
+	netif_tx_unlock_bh(to);
+	netif_tx_unlock_bh(from);
+}
+EXPORT_SYMBOL(dev_unicast_unsync);
+
 static void __dev_addr_discard(struct dev_addr_list **list)
 {
 	struct dev_addr_list *tmp;
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index cadbfbf..cec5825 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -113,32 +113,15 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
  * 	locked by netif_tx_lock_bh.
  *
  *	This function is intended to be called from the dev->set_multicast_list
- *	function of layered software devices.
+ *	or dev->set_rx_mode function of layered software devices.
  */
 int dev_mc_sync(struct net_device *to, struct net_device *from)
 {
-	struct dev_addr_list *da, *next;
 	int err = 0;
 
 	netif_tx_lock_bh(to);
-	da = from->mc_list;
-	while (da != NULL) {
-		next = da->next;
-		if (!da->da_synced) {
-			err = __dev_addr_add(&to->mc_list, &to->mc_count,
-					     da->da_addr, da->da_addrlen, 0);
-			if (err < 0)
-				break;
-			da->da_synced = 1;
-			da->da_users++;
-		} else if (da->da_users == 1) {
-			__dev_addr_delete(&to->mc_list, &to->mc_count,
-					  da->da_addr, da->da_addrlen, 0);
-			__dev_addr_delete(&from->mc_list, &from->mc_count,
-					  da->da_addr, da->da_addrlen, 0);
-		}
-		da = next;
-	}
+	err = __dev_addr_sync(&to->mc_list, &to->mc_count,
+			      &from->mc_list, &from->mc_count);
 	if (!err)
 		__dev_set_rx_mode(to);
 	netif_tx_unlock_bh(to);
@@ -160,23 +143,11 @@ EXPORT_SYMBOL(dev_mc_sync);
  */
 void dev_mc_unsync(struct net_device *to, struct net_device *from)
 {
-	struct dev_addr_list *da, *next;
-
 	netif_tx_lock_bh(from);
 	netif_tx_lock_bh(to);
 
-	da = from->mc_list;
-	while (da != NULL) {
-		next = da->next;
-		if (da->da_synced) {
-			__dev_addr_delete(&to->mc_list, &to->mc_count,
-					  da->da_addr, da->da_addrlen, 0);
-			da->da_synced = 0;
-			__dev_addr_delete(&from->mc_list, &from->mc_count,
-					  da->da_addr, da->da_addrlen, 0);
-		}
-		da = next;
-	}
+	__dev_addr_unsync(&to->mc_list, &to->mc_count,
+			  &from->mc_list, &from->mc_count);
 	__dev_set_rx_mode(to);
 
 	netif_tx_unlock_bh(to);

