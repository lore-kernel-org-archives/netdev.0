From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v1 2/7] net: addr_list: add exclusive dev_uc_add and
	dev_mc_add
Date: Mon, 09 Apr 2012 15:00:23 -0700
Message-ID: <20120409220023.3288.59939.stgit@jf-dev1-dcblab>
References: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com, sri@us.ibm.com
To: roprabhu@cisco.com, mst@redhat.com, stephen.hemminger@vyatta.com,
	davem@davemloft.net, hadi@cyberus.ca, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29611 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab2DIWN1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 18:13:27 -0400
In-Reply-To: <20120409215419.3288.50790.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a dev_uc_add_excl() and dev_mc_add_excl() calls
similar to the original dev_{uc|mc}_add() except it sets
the global bit and returns -EEXIST for duplicat entires.

This is useful for drivers that support SR-IOV, macvlan
devices and any other devices that need to manage the
unicast and multicast lists.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |    2 +
 net/core/dev_addr_lists.c |   97 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 83 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 05822e5..b68a326 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2572,6 +2572,7 @@ extern int dev_addr_init(struct net_device *dev);
 
 /* Functions used for unicast addresses handling */
 extern int dev_uc_add(struct net_device *dev, unsigned char *addr);
+extern int dev_uc_add_excl(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_del(struct net_device *dev, unsigned char *addr);
 extern int dev_uc_sync(struct net_device *to, struct net_device *from);
 extern void dev_uc_unsync(struct net_device *to, struct net_device *from);
@@ -2581,6 +2582,7 @@ extern void dev_uc_init(struct net_device *dev);
 /* Functions used for multicast addresses handling */
 extern int dev_mc_add(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_add_global(struct net_device *dev, unsigned char *addr);
+extern int dev_mc_add_excl(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_del(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_del_global(struct net_device *dev, unsigned char *addr);
 extern int dev_mc_sync(struct net_device *to, struct net_device *from);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 29c07fe..5405e28 100644
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
+		    ha->type == NETDEV_HW_ADDR_T_UNICAST) {
+			err = -EEXIST;
+			goto out;
+		}
+	}
+	err = __hw_addr_create_ex(&dev->mc, addr, dev->addr_len,
+				  NETDEV_HW_ADDR_T_UNICAST, true);
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
