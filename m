From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 2/8] net: addr_list: add exclusive dev_uc_add and
	dev_mc_add
Date: Wed, 11 Apr 2012 23:57:19 -0700
Message-ID: <20120412065719.3112.49294.stgit@jf-dev1-dcblab>
References: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8445 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757468Ab2DLHKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 03:10:24 -0400
In-Reply-To: <20120412064858.3112.65818.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a dev_uc_add_excl() and dev_mc_add_excl() calls
similar to the original dev_{uc|mc}_add() except it sets
the global bit and returns -EEXIST for duplicat entires.

This is useful for drivers that support SR-IOV, macvlan
devices and any other devices that need to manage the
unicast and multicast lists.

v2: fix typo UNICAST should be MULTICAST in dev_mc_add_excl()

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |    2 +
 net/core/dev_addr_lists.c |   97 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 83 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7600c61..3f738ca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2569,6 +2569,7 @@ extern int dev_addr_init(struct net_device *dev);
 
 /* Functions used for unicast addresses handling */
 extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_add_excl(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_sync(struct net_device *to, struct net_device *from);
 extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
@@ -2578,6 +2579,7 @@ extern void dev_uc_init(struct net_device *dev);
 /* Functions used for multicast addresses handling */
 extern int dev_mc_add(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_add_global(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_add_excl(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_del(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_del_global(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_sync(struct net_device *to, struct net_device *from);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 626698f..c4cc2bc 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -21,12 +21,35 @@
  * General list handling functions
  */
 
+static int __hw_addr_create_ex(struct netdev_hw_addr_list *list,
+			       unsigned char *addr, int addr_len,
+			       unsigned char addr_type, bool global)
+{
+	struct netdev_hw_addr *ha;
+	int alloc_size;
+
+	alloc_size = sizeof(*ha);
+	if (alloc_size < L1_CACHE_BYTES)
+		alloc_size = L1_CACHE_BYTES;
+	ha = kmalloc(alloc_size, GFP_ATOMIC);
+	if (!ha)
+		return -ENOMEM;
+	memcpy(ha->addr, addr, addr_len);
+	ha->type = addr_type;
+	ha->refcount = 1;
+	ha->global_use = global;
+	ha->synced = false;
+	list_add_tail_rcu(&ha->list, &list->list);
+	list->count++;
+
+	return 0;
+}
+
 static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 			    unsigned char *addr, int addr_len,
 			    unsigned char addr_type, bool global)
 {
 	struct netdev_hw_addr *ha;
-	int alloc_size;
 
 	if (addr_len > MAX_ADDR_LEN)
 		return -EINVAL;
@@ -46,21 +69,7 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
 		}
 	}
 
-
-	alloc_size = sizeof(*ha);
-	if (alloc_size < L1_CACHE_BYTES)
-		alloc_size = L1_CACHE_BYTES;
-	ha = kmalloc(alloc_size, GFP_ATOMIC);
-	if (!ha)
-		return -ENOMEM;
-	memcpy(ha->addr, addr, addr_len);
-	ha->type = addr_type;
-	ha->refcount = 1;
-	ha->global_use = global;
-	ha->synced = false;
-	list_add_tail_rcu(&ha->list, &list->list);
-	list->count++;
-	return 0;
+	return __hw_addr_create_ex(list, addr, addr_len, addr_type, global);
 }
 
 static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
@@ -377,6 +386,34 @@ EXPORT_SYMBOL(dev_addr_del_multiple);
  */
 
 /**
+ *	dev_uc_add_excl - Add a global secondary unicast address
+ *	@dev: device
+ *	@addr: address to add
+ */
+int dev_uc_add_excl(struct net_device *dev, unsigned char *addr)
+{
+	struct netdev_hw_addr *ha;
+	int err;
+
+	netif_addr_lock_bh(dev);
+	list_for_each_entry(ha, &dev->uc.list, list) {
+		if (!memcmp(ha->addr, addr, dev->addr_len) &&
+		    ha->type == NETDEV_HW_ADDR_T_UNICAST) {
+			err = -EEXIST;
+			goto out;
+		}
+	}
+	err = __hw_addr_create_ex(&dev->uc, addr, dev->addr_len,
+				  NETDEV_HW_ADDR_T_UNICAST, true);
+	if (!err)
+		__dev_set_rx_mode(dev);
+out:
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_uc_add_excl);
+
+/**
  *	dev_uc_add - Add a secondary unicast address
  *	@dev: device
  *	@addr: address to add
@@ -501,6 +538,34 @@ EXPORT_SYMBOL(dev_uc_init);
  * Multicast list handling functions
  */
 
+/**
+ *	dev_mc_add_excl - Add a global secondary multicast address
+ *	@dev: device
+ *	@addr: address to add
+ */
+int dev_mc_add_excl(struct net_device *dev, unsigned char *addr)
+{
+	struct netdev_hw_addr *ha;
+	int err;
+
+	netif_addr_lock_bh(dev);
+	list_for_each_entry(ha, &dev->mc.list, list) {
+		if (!memcmp(ha->addr, addr, dev->addr_len) &&
+		    ha->type == NETDEV_HW_ADDR_T_MULTICAST) {
+			err = -EEXIST;
+			goto out;
+		}
+	}
+	err = __hw_addr_create_ex(&dev->mc, addr, dev->addr_len,
+				  NETDEV_HW_ADDR_T_MULTICAST, true);
+	if (!err)
+		__dev_set_rx_mode(dev);
+out:
+	netif_addr_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_mc_add_excl);
+
 static int __dev_mc_add(struct net_device *dev, unsigned char *addr,
 			bool global)
 {
