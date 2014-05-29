From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH 1/2] net: Add support for device specific address
 syncing
Date: Wed, 28 May 2014 18:44:46 -0700
Message-ID: <20140529014446.21464.17118.stgit@ahduyck-cp2.jf.intel.com>
References: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: ssujith@cisco.com, neepatel@cisco.com, davem@davemloft.net,
	_govind@gmx.com, benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62310 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755348AbaE2Bo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2014 21:44:56 -0400
In-Reply-To: <20140529013440.21464.2499.stgit@ahduyck-cp2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change provides a function to be used in order to break the
ndo_set_rx_mode call into a set of address add and remove calls.  The code
is based on the implementation of dev_uc_sync/dev_mc_sync.  Since they
essentially do the same thing but with only one dev I simply named my
functions __dev_uc_sync/__dev_mc_sync.

I also implemented an unsync version of the functions as well to allow for
cleanup on close.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/netdevice.h |   73 +++++++++++++++++++++++++++++++++++++++
 net/core/dev_addr_lists.c |   85 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 158 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2db1610..774e539 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3003,6 +3003,15 @@ int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
 		   struct netdev_hw_addr_list *from_list, int addr_len);
 void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 		      struct netdev_hw_addr_list *from_list, int addr_len);
+int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
+		       struct net_device *dev,
+		       int (*sync)(struct net_device *, const unsigned char *),
+		       int (*unsync)(struct net_device *,
+				     const unsigned char *));
+void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
+			  struct net_device *dev,
+			  int (*unsync)(struct net_device *,
+					const unsigned char *));
 void __hw_addr_init(struct netdev_hw_addr_list *list);
 
 /* Functions used for device addresses handling */
@@ -3023,6 +3032,38 @@ void dev_uc_unsync(struct net_device *to, struct net_device *from);
 void dev_uc_flush(struct net_device *dev);
 void dev_uc_init(struct net_device *dev);
 
+/**
+ *  __dev_uc_sync - Synchonize device's unicast list
+ *  @dev:  device to sync
+ *  @sync: function to call if address should be added
+ *  @unsync: function to call if address should be removed
+ *
+ *  Add newly added addresses to the interface, and release
+ *  addresses that have been deleted.
+ **/
+static inline int __dev_uc_sync(struct net_device *dev,
+				int (*sync)(struct net_device *,
+					    const unsigned char *),
+				int (*unsync)(struct net_device *,
+					      const unsigned char *))
+{
+	return __hw_addr_sync_dev(&dev->uc, dev, sync, unsync);
+}
+
+/**
+ *  __dev_uc_unsync - Remove synchonized addresses from device
+ *  @dev:  device to sync
+ *  @unsync: function to call if address should be removed
+ *
+ *  Remove all addresses that were added to the device by dev_uc_sync().
+ **/
+static inline void __dev_uc_unsync(struct net_device *dev,
+				   int (*unsync)(struct net_device *,
+						 const unsigned char *))
+{
+	__hw_addr_unsync_dev(&dev->uc, dev, unsync);
+}
+
 /* Functions used for multicast addresses handling */
 int dev_mc_add(struct net_device *dev, const unsigned char *addr);
 int dev_mc_add_global(struct net_device *dev, const unsigned char *addr);
@@ -3035,6 +3076,38 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from);
 void dev_mc_flush(struct net_device *dev);
 void dev_mc_init(struct net_device *dev);
 
+/**
+ *  __dev_mc_sync - Synchonize device's multicast list
+ *  @dev:  device to sync
+ *  @sync: function to call if address should be added
+ *  @unsync: function to call if address should be removed
+ *
+ *  Add newly added addresses to the interface, and release
+ *  addresses that have been deleted.
+ **/
+static inline int __dev_mc_sync(struct net_device *dev,
+				int (*sync)(struct net_device *,
+					    const unsigned char *),
+				int (*unsync)(struct net_device *,
+					      const unsigned char *))
+{
+	return __hw_addr_sync_dev(&dev->mc, dev, sync, unsync);
+}
+
+/**
+ *  __dev_mc_unsync - Remove synchonized addresses from device
+ *  @dev:  device to sync
+ *  @unsync: function to call if address should be removed
+ *
+ *  Remove all addresses that were added to the device by dev_mc_sync().
+ **/
+static inline void __dev_mc_unsync(struct net_device *dev,
+				   int (*unsync)(struct net_device *,
+						 const unsigned char *))
+{
+	__hw_addr_unsync_dev(&dev->mc, dev, unsync);
+}
+
 /* Functions used for secondary unicast and multicast support */
 void dev_set_rx_mode(struct net_device *dev);
 void __dev_set_rx_mode(struct net_device *dev);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 329d579..b6b2306 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -225,6 +225,91 @@ void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 }
 EXPORT_SYMBOL(__hw_addr_unsync);
 
+/**
+ *  __hw_addr_sync_dev - Synchonize device's multicast list
+ *  @list: address list to syncronize
+ *  @dev:  device to sync
+ *  @sync: function to call if address should be added
+ *  @unsync: function to call if address should be removed
+ *
+ *  This funciton is intended to be called from the ndo_set_rx_mode
+ *  function of devices that require explicit address add/remove
+ *  notifications.  The unsync function may be NULL in which case
+ *  the addresses requiring removal will simply be removed without
+ *  any notification to the device.
+ **/
+int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
+		       struct net_device *dev,
+		       int (*sync)(struct net_device *, const unsigned char *),
+		       int (*unsync)(struct net_device *,
+				     const unsigned char *))
+{
+	struct netdev_hw_addr *ha, *tmp;
+	int err;
+
+	/* first go through and flush out any stale entries */
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (!ha->sync_cnt || ha->refcount != 1)
+			continue;
+
+		/* if unsync is defined and fails defer unsyncing address */
+		if (unsync && unsync(dev, ha->addr))
+			continue;
+
+		ha->sync_cnt--;
+		__hw_addr_del_entry(list, ha, false, false);
+	}
+
+	/* go through and sync new entries to the list */
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (ha->sync_cnt)
+			continue;
+
+		err = sync(dev, ha->addr);
+		if (err)
+			return err;
+
+		ha->sync_cnt++;
+		ha->refcount++;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(__hw_addr_sync_dev);
+
+/**
+ *  __hw_addr_unsync_dev - Remove synchonized addresses from device
+ *  @list: address list to remove syncronized addresses from
+ *  @dev:  device to sync
+ *  @unsync: function to call if address should be removed
+ *
+ *  Remove all addresses that were added to the device by __hw_addr_sync_dev().
+ *  This function is intended to be called from the ndo_stop or ndo_open
+ *  functions on devices that require explicit address add/remove
+ *  notifications.  If the unsync function pointer is NULL then this function
+ *  can be used to just reset the sync_cnt for the addresses in the list.
+ **/
+void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
+			  struct net_device *dev,
+			  int (*unsync)(struct net_device *,
+					const unsigned char *))
+{
+	struct netdev_hw_addr *ha, *tmp;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (!ha->sync_cnt)
+			continue;
+
+		/* if unsync is defined and fails defer unsyncing address */
+		if (unsync && unsync(dev, ha->addr))
+			continue;
+
+		ha->sync_cnt--;
+		__hw_addr_del_entry(list, ha, false, false);
+	}
+}
+EXPORT_SYMBOL(__hw_addr_unsync_dev);
+
 static void __hw_addr_flush(struct netdev_hw_addr_list *list)
 {
 	struct netdev_hw_addr *ha, *tmp;
