From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH] net: Add support for device specific address syncing
Date: Wed, 14 May 2014 16:37:27 -0700
Message-ID: <20140514233444.29822.45400.stgit@ahduyck-cp2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net, jpirko@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24057 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbaENXh2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 19:37:28 -0400
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

I still have to do some testing on this patch, but I am looking to see if
this is the correct approach or if the community would prefer I take a
different one.

 include/linux/netdevice.h |   77 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev_addr_lists.c |   46 +++++++++++++++++++++++++++
 2 files changed, 123 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index adc4658..d2dabf4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2998,6 +2998,13 @@ int __hw_addr_sync(struct netdev_hw_addr_list *to_list,
 		   struct netdev_hw_addr_list *from_list, int addr_len);
 void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 		      struct netdev_hw_addr_list *from_list, int addr_len);
+int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
+		struct net_device *dev,
+		int (*sync)(struct net_device *, const unsigned char *),
+		int (*unsync)(struct net_device *, const unsigned char *));
+void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
+		struct net_device *dev,
+		int (*unsync)(struct net_device *, const unsigned char *));
 void __hw_addr_init(struct netdev_hw_addr_list *list);
 
 /* Functions used for device addresses handling */
@@ -3018,6 +3025,41 @@ void dev_uc_unsync(struct net_device *to, struct net_device *from);
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
+ *
+ *  This funciton is intended to be called from the ndo_set_rx_mode
+ *  function of devices that require explicit address add/remove
+ *  notifications.
+ **/
+static inline int __dev_uc_sync(struct net_device *dev,
+		int (*sync)(struct net_device *, const unsigned char *),
+		int (*unsync)(struct net_device *, const unsigned char *))
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
+ *  This function is intended to be called from the ndo_stop function on devices
+ *  that require explicit address add/remove notifications.
+ **/
+static inline void __dev_uc_unsync(struct net_device *dev,
+		   int (*unsync)(struct net_device *, const unsigned char *))
+{
+	__hw_addr_unsync_dev(&dev->uc, dev, unsync);
+}
+
 /* Functions used for multicast addresses handling */
 int dev_mc_add(struct net_device *dev, const unsigned char *addr);
 int dev_mc_add_global(struct net_device *dev, const unsigned char *addr);
@@ -3030,6 +3072,41 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from);
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
+ *
+ *  This funciton is intended to be called from the ndo_set_rx_mode
+ *  function of devices that require explicit address add/remove
+ *  notifications.
+ **/
+static inline int __dev_mc_sync(struct net_device *dev,
+		int (*sync)(struct net_device *, const unsigned char *),
+		int (*unsync)(struct net_device *, const unsigned char *))
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
+ *  This function is intended to be called from the ndo_stop function on devices
+ *  that require explicit address add/remove notifications.
+ **/
+static inline void __dev_mc_unsync(struct net_device *dev,
+		int (*unsync)(struct net_device *, const unsigned char *))
+{
+	__hw_addr_unsync_dev(&dev->mc, dev, unsync);
+}
+
 /* Functions used for secondary unicast and multicast support */
 void dev_set_rx_mode(struct net_device *dev);
 void __dev_set_rx_mode(struct net_device *dev);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 329d579..e6f0f55 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -225,6 +225,52 @@ void __hw_addr_unsync(struct netdev_hw_addr_list *to_list,
 }
 EXPORT_SYMBOL(__hw_addr_unsync);
 
+int __hw_addr_sync_dev(struct netdev_hw_addr_list *list,
+		struct net_device *dev,
+		int (*sync)(struct net_device *, const unsigned char *),
+		int (*unsync)(struct net_device *, const unsigned char *))
+{
+	struct netdev_hw_addr *ha, *tmp;
+	int err = 0;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (!ha->sync_cnt) {
+			err = sync(dev, ha->addr);
+			if (err)
+				break;
+			ha->sync_cnt++;
+			ha->refcount++;
+		} else if (ha->refcount == 1) {
+			err = unsync(dev, ha->addr);
+			if (!err) {
+				ha->sync_cnt--;
+				__hw_addr_del_entry(list, ha, false, false);
+			}
+		}
+	}
+	return err;
+}
+EXPORT_SYMBOL(__hw_addr_sync_dev);
+
+void __hw_addr_unsync_dev(struct netdev_hw_addr_list *list,
+		struct net_device *dev,
+		int (*unsync)(struct net_device *, const unsigned char *))
+{
+	struct netdev_hw_addr *ha, *tmp;
+	int err;
+
+	list_for_each_entry_safe(ha, tmp, &list->list, list) {
+		if (!ha->sync_cnt)
+			continue;
+		err = unsync(dev, ha->addr);
+		if (!err) {
+			ha->sync_cnt--;
+			__hw_addr_del_entry(list, ha, false, false);
+		}
+	}
+}
+EXPORT_SYMBOL(__hw_addr_unsync_dev);
+
 static void __hw_addr_flush(struct netdev_hw_addr_list *list)
 {
 	struct netdev_hw_addr *ha, *tmp;
