From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET 01/02]: Secondary unicast address support
Date: Wed, 20 Jun 2007 20:00:24 +0200 (MEST)
Message-ID: <20070620180019.6685.50688.sendpatchset@localhost.localdomain>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55002 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420AbXFTSAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 14:00:25 -0400
In-Reply-To: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETDEV]: Secondary unicast address support

Add support for configuring secondary unicast addresses on network devices.
Devices supporting this feature need to change their set_multicast_list
function to configure unicast filters as well and assign it to
dev->set_address_list instead of dev->set_multicast_list. Devices not
supporting this feature are put in promiscous mode when secondary unicast
addresses are present.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3f3f6e18b902ee177ecf5a108ba6ecbf1b5c9ba3
tree 8883aba620211e96d7419f96960cc596506cbeef
parent 890e2ae4ef5599ee34f280af4882f97c2dcfcb7b
author Patrick McHardy <kaber@trash.net> Wed, 20 Jun 2007 19:44:11 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 20 Jun 2007 19:44:11 +0200

 include/linux/netdevice.h |   17 ++++
 net/core/dev.c            |  172 +++++++++++++++++++++++++++++++++++++++++++--
 net/core/dev_mcast.c      |   34 +--------
 3 files changed, 185 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 868140d..a1cc2ea 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -191,6 +191,14 @@ struct dev_mc_list
 	int			dmi_gusers;
 };
 
+struct dev_uc_list
+{
+	struct dev_uc_list	*next;
+	__u8			duci_addr[MAX_ADDR_LEN];
+	unsigned char		duci_addrlen;
+	int			duci_users;
+};
+
 struct hh_cache
 {
 	struct hh_cache *hh_next;	/* Next entry			     */
@@ -389,7 +397,10 @@ struct net_device
 	unsigned short          dev_id;		/* for shared network cards */
 
 	struct dev_mc_list	*mc_list;	/* Multicast mac addresses	*/
+	struct dev_uc_list	*uc_list;	/* Secondary unicast mac addresses */
 	int			mc_count;	/* Number of installed mcasts	*/
+	int			uc_count;	/* Number of installed ucasts	*/
+	int			uc_promisc;
 	int			promiscuity;
 	int			allmulti;
 
@@ -493,6 +504,8 @@ struct net_device
 						void *saddr,
 						unsigned len);
 	int			(*rebuild_header)(struct sk_buff *skb);
+#define HAVE_ADDRESS_LIST
+	void			(*set_address_list)(struct net_device *dev);
 #define HAVE_MULTICAST			 
 	void			(*set_multicast_list)(struct net_device *dev);
 #define HAVE_SET_MAC_ADDR  		 
@@ -1006,6 +1019,10 @@ extern void		dev_mc_upload(struct net_device *dev);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern void		dev_mc_discard(struct net_device *dev);
+extern int 		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
+extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
+extern void		__dev_address_upload(struct net_device *dev);
+extern void		dev_address_upload(struct net_device *dev);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 5974e5b..4f4beb0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -943,7 +943,7 @@ int dev_open(struct net_device *dev)
 		/*
 		 *	Initialize multicasting status
 		 */
-		dev_mc_upload(dev);
+		dev_address_upload(dev);
 
 		/*
 		 *	Wakeup transmit queue engine
@@ -2522,6 +2522,163 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	return 0;
 }
 
+void __dev_address_upload(struct net_device *dev)
+{
+	/* Don't do anything till we up the interface
+	 * [dev_open will call this function so the list will
+	 * stay sane]
+	 */
+
+	if (!(dev->flags&IFF_UP))
+		return;
+
+	if (!netif_device_present(dev))
+	        return;
+
+	if (dev->set_address_list)
+		dev->set_address_list(dev);
+	else {
+		if (dev->uc_count > 0 && !dev->uc_promisc) {
+			dev_set_promiscuity(dev, 1);
+			dev->uc_promisc = 1;
+		} else if (dev->uc_count == 0 && dev->uc_promisc) {
+			dev_set_promiscuity(dev, -1);
+			dev->uc_promisc = 0;
+		}
+
+		if (dev->set_multicast_list)
+			dev->set_multicast_list(dev);
+	}
+}
+
+/**
+ *	dev_address_upload	- upload address lists to device
+ *	@dev: device
+ *
+ *	Upload unicast and multicast address lists to device.
+ *	When the device doesn't support unicast filtering it
+ *	is put in promiscous mode while addresses are present.
+ *
+ */
+void dev_address_upload(struct net_device *dev)
+{
+	netif_tx_lock_bh(dev);
+	__dev_address_upload(dev);
+	netif_tx_unlock_bh(dev);
+}
+
+/**
+ *	dev_unicast_delete	- Release secondary unicast address.
+ *	@dev: device
+ *
+ *	Release reference to a secondary unicast address and remove it
+ *	from the device if the reference count drop to zero.
+ *
+ */
+int dev_unicast_delete(struct net_device *dev, void *addr, int alen)
+{
+	int err = 0;
+	struct dev_uc_list *duci, **ducip;
+
+	netif_tx_lock_bh(dev);
+
+	for (ducip = &dev->uc_list; (duci = *ducip) != NULL;
+	     ducip = &duci->next) {
+		/*
+		 *	Find the entry we want to delete. The device could
+		 *	have variable length entries so check these too.
+		 */
+		if (memcmp(duci->duci_addr, addr, duci->duci_addrlen) == 0 &&
+		    alen == duci->duci_addrlen) {
+			if (--duci->duci_users)
+				goto done;
+
+			/*
+			 *	Last user. So delete the entry.
+			 */
+			*ducip = duci->next;
+			dev->uc_count--;
+
+			kfree(duci);
+
+			/*
+			 *	We have altered the list, so the card
+			 *	loaded filter is now wrong. Fix it
+			 */
+			__dev_address_upload(dev);
+
+			netif_tx_unlock_bh(dev);
+			return 0;
+		}
+	}
+	err = -ENOENT;
+done:
+	netif_tx_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_unicast_delete);
+
+/**
+ *	dev_unicast_add		- add a secondary unicast address
+ *	@dev: device
+ *
+ *	Add a secondary unicast address to the device or increase
+ *	the reference count if it already exists.
+ *
+ */
+int dev_unicast_add(struct net_device *dev, void *addr, int alen)
+{
+	int err = 0;
+	struct dev_uc_list *duci, *duci1;
+
+	duci1 = kmalloc(sizeof(*duci), GFP_ATOMIC);
+
+	netif_tx_lock_bh(dev);
+	for (duci = dev->uc_list; duci != NULL; duci = duci->next) {
+		if (memcmp(duci->duci_addr, addr, duci->duci_addrlen) == 0 &&
+		    duci->duci_addrlen == alen) {
+			duci->duci_users++;
+			goto done;
+		}
+	}
+
+	if ((duci = duci1) == NULL) {
+		netif_tx_unlock_bh(dev);
+		return -ENOMEM;
+	}
+	memcpy(duci->duci_addr, addr, alen);
+	duci->duci_addrlen = alen;
+	duci->next = dev->uc_list;
+	duci->duci_users = 1;
+	dev->uc_list = duci;
+	dev->uc_count++;
+
+	__dev_address_upload(dev);
+
+	netif_tx_unlock_bh(dev);
+	return 0;
+
+done:
+	netif_tx_unlock_bh(dev);
+	kfree(duci1);
+	return err;
+}
+EXPORT_SYMBOL(dev_unicast_add);
+
+void dev_unicast_discard(struct net_device *dev)
+{
+	netif_tx_lock_bh(dev);
+
+	while (dev->uc_list != NULL) {
+		struct dev_uc_list *tmp = dev->uc_list;
+		dev->uc_list = tmp->next;
+		kfree(tmp);
+	}
+	dev->uc_count = 0;
+
+	netif_tx_unlock_bh(dev);
+}
+
 /**
  *	dev_set_promiscuity	- update promiscuity count on a device
  *	@dev: device
@@ -2541,7 +2698,7 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
 	else
 		dev->flags |= IFF_PROMISC;
 	if (dev->flags != old_flags) {
-		dev_mc_upload(dev);
+		dev_address_upload(dev);
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
 							       "left");
@@ -2574,7 +2731,7 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 	if ((dev->allmulti += inc) == 0)
 		dev->flags &= ~IFF_ALLMULTI;
 	if (dev->flags ^ old_flags)
-		dev_mc_upload(dev);
+		dev_address_upload(dev);
 }
 
 unsigned dev_get_flags(const struct net_device *dev)
@@ -2617,10 +2774,10 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 				    IFF_ALLMULTI));
 
 	/*
-	 *	Load in the correct multicast list now the flags have changed.
+	 *	Load in the correct address list now the flags have changed.
 	 */
 
-	dev_mc_upload(dev);
+	dev_address_upload(dev);
 
 	/*
 	 *	Have we downed the interface. We handle IFF_UP ourselves
@@ -2633,7 +2790,7 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 		ret = ((old_flags & IFF_UP) ? dev_close : dev_open)(dev);
 
 		if (!ret)
-			dev_mc_upload(dev);
+			dev_address_upload(dev);
 	}
 
 	if (dev->flags & IFF_UP &&
@@ -3497,8 +3654,9 @@ void unregister_netdevice(struct net_device *dev)
 	raw_notifier_call_chain(&netdev_chain, NETDEV_UNREGISTER, dev);
 
 	/*
-	 *	Flush the multicast chain
+	 *	Flush the unicast and multicast chains
 	 */
+	dev_unicast_discard(dev);
 	dev_mc_discard(dev);
 
 	if (dev->uninit)
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 5a54053..45d616b 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -63,37 +63,9 @@
  *	We block accesses to device mc filters with netif_tx_lock.
  */
 
-/*
- *	Update the multicast list into the physical NIC controller.
- */
-
-static void __dev_mc_upload(struct net_device *dev)
-{
-	/* Don't do anything till we up the interface
-	 * [dev_open will call this function so the list will
-	 * stay sane]
-	 */
-
-	if (!(dev->flags&IFF_UP))
-		return;
-
-	/*
-	 *	Devices with no set multicast or which have been
-	 *	detached don't get set.
-	 */
-
-	if (dev->set_multicast_list == NULL ||
-	    !netif_device_present(dev))
-		return;
-
-	dev->set_multicast_list(dev);
-}
-
 void dev_mc_upload(struct net_device *dev)
 {
-	netif_tx_lock_bh(dev);
-	__dev_mc_upload(dev);
-	netif_tx_unlock_bh(dev);
+	dev_address_upload(dev);
 }
 
 /*
@@ -135,7 +107,7 @@ int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
 			 *	We have altered the list, so the card
 			 *	loaded filter is now wrong. Fix it
 			 */
-			__dev_mc_upload(dev);
+			__dev_address_upload(dev);
 
 			netif_tx_unlock_bh(dev);
 			return 0;
@@ -185,7 +157,7 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	dev->mc_list = dmi;
 	dev->mc_count++;
 
-	__dev_mc_upload(dev);
+	__dev_address_upload(dev);
 
 	netif_tx_unlock_bh(dev);
 	return 0;
