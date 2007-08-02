From: Brandon Philips <brandon@suse.de>
Subject: [patch 2/5][RFC] Update net core to use devres.
Date: Thu, 2 Aug 2007 15:45:27 -0700
Message-ID: <20070802224527.GD5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48680 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156AbXHBWpc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 18:45:32 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 5DF3821714
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2007 00:45:30 +0200 (CEST)
Content-Disposition: inline; filename="ether-core-devres.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* netdev_pci_remove_one() can replace simple pci device remove
  functions

* devm_alloc_netdev() is like alloc_netdev but allocates memory using devres.

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 include/linux/etherdevice.h |    5 ++
 include/linux/netdevice.h   |    7 ++
 net/core/dev.c              |  109 +++++++++++++++++++++++++++++++++++++++-----
 net/ethernet/eth.c          |    8 +++
 4 files changed, 119 insertions(+), 10 deletions(-)

Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -656,6 +656,7 @@ extern int		dev_queue_xmit(struct sk_buf
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
+extern void		netdev_pci_remove_one(struct pci_dev *pdev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
@@ -1085,8 +1086,14 @@ extern void		ether_setup(struct net_devi
 extern struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *),
 				       unsigned int queue_count);
+extern struct net_device *devm_alloc_netdev_mq(struct device *dev,
+				       int sizeof_priv, const char *name,
+				       void (*setup)(struct net_device *),
+				       unsigned int queue_count);
 #define alloc_netdev(sizeof_priv, name, setup) \
 	alloc_netdev_mq(sizeof_priv, name, setup, 1)
+#define devm_alloc_netdev(dev, sizeof_priv, name, setup) \
+	devm_alloc_netdev_mq(dev, sizeof_priv, name, setup, 1)
 extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
Index: linux-2.6/net/core/dev.c
===================================================================
--- linux-2.6.orig/net/core/dev.c
+++ linux-2.6/net/core/dev.c
@@ -89,6 +89,7 @@
 #include <linux/interrupt.h>
 #include <linux/if_ether.h>
 #include <linux/netdevice.h>
+#include <linux/pci.h>
 #include <linux/etherdevice.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
@@ -3658,18 +3659,51 @@ static struct net_device_stats *internal
 }
 
 /**
- *	alloc_netdev_mq - allocate network device
- *	@sizeof_priv:	size of private data to allocate space for
- *	@name:		device name format string
- *	@setup:		callback to initialize device
- *	@queue_count:	the number of subqueues to allocate
+ * devm_free_netdev - wrapper around free_netdev for devres
+ */
+static void devm_free_netdev(struct device *gendev, void *res)
+{
+	struct net_device *dev = dev_get_drvdata(gendev);
+	free_netdev(dev);
+}
+
+/**
+ * register_netdev_devres - register netdev with a managed device
+ * @dev:	devres managed device responsible for the memory
+ * @netdev:		pointer to netdev to be managed
  *
- *	Allocates a struct net_device with private data area for driver use
- *	and performs basic initialization.  Also allocates subquue structs
- *	for each queue on the device at the end of the netdevice.
+ * Registers @netdev to the device @dev and calls free_netdev automatically when the
+ * device disappears
  */
-struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *), unsigned int queue_count)
+static inline void * register_netdev_devres(struct device *gendev,
+						struct net_device *dev)
+{
+	struct net_device **p;
+
+	/* 0 size because we don't need it. The net_device is already alloc'd
+	 * in alloc_netdev_mq.  We can't use devm_kzalloc in alloc_netdeev_mq
+	 * because a net_device cannot be free'd directly as it can be a
+	 * kobject.  See free_netdev.
+	 */
+	p = devres_alloc(devm_free_netdev, 0, GFP_KERNEL);
+
+	if (unlikely(!p))
+		return NULL;
+
+	*p = dev;
+	devres_add(gendev, p);
+
+	return dev;
+}
+
+/**
+ *	__alloc_netdev_mq - does the work to allocate a network device
+ *	@dev:		devres managed device responsible for mem.
+ *			NULL if unmanaged
+ */
+struct net_device *__alloc_netdev_mq(struct device *gendev, int sizeof_priv,
+		const char *name, void (*setup)(struct net_device *),
+		unsigned int queue_count)
 {
 	void *p;
 	struct net_device *dev;
@@ -3706,8 +3740,43 @@ struct net_device *alloc_netdev_mq(int s
 	dev->get_stats = internal_stats;
 	setup(dev);
 	strcpy(dev->name, name);
+
+	/* If we are given a device then manage this netdev with devres */
+	if (gendev != NULL)
+		return register_netdev_devres(gendev, dev);
+
 	return dev;
 }
+
+/**
+ *	alloc_netdev_mq - alloc_netdev_mq for devres managed devices
+ *	@dev:		devres managed device responsible for mem.
+ */
+struct net_device *devm_alloc_netdev_mq(struct device *dev, int sizeof_priv, const
+				char *name, void (*setup)(struct net_device *),
+				unsigned int queue_count)
+{
+	return __alloc_netdev_mq(dev, sizeof_priv, name, setup, queue_count);
+}
+EXPORT_SYMBOL(devm_alloc_netdev_mq);
+
+/**
+ *	alloc_netdev_mq - allocate network device
+ *	@sizeof_priv:	size of private data to allocate space for
+ *	@name:		device name format string
+ *	@setup:		callback to initialize device
+ *	@queue_count:	the number of subqueues to allocate
+ *
+ *	Allocates a struct net_device with private data area for driver use
+ *	and performs basic initialization.  Also allocates subquue structs
+ *	for each queue on the device at the end of the netdevice.
+ */
+struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
+				void (*setup)(struct net_device *),
+				unsigned int queue_count)
+{
+	return __alloc_netdev_mq(NULL, sizeof_priv, name, setup, queue_count);
+}
 EXPORT_SYMBOL(alloc_netdev_mq);
 
 /**
@@ -3737,6 +3806,26 @@ void free_netdev(struct net_device *dev)
 #endif
 }
 
+#ifdef CONFIG_PCI
+/**
+ * netdev_pci_remove_one - free network device
+ * @pdev: pci_dev of the device to remove
+ *
+ * Simple remove function for pci network devices with no teardown besides
+ * resource deallocation.
+ */
+void netdev_pci_remove_one(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	if (netdev) {
+		unregister_netdev(netdev);
+		pci_set_drvdata(pdev, NULL);
+	}
+}
+EXPORT_SYMBOL(netdev_pci_remove_one);
+#endif
+
+
 /* Synchronize with packet receive processing. */
 void synchronize_net(void)
 {
Index: linux-2.6/include/linux/etherdevice.h
===================================================================
--- linux-2.6.orig/include/linux/etherdevice.h
+++ linux-2.6/include/linux/etherdevice.h
@@ -40,7 +40,12 @@ extern int		eth_header_cache(struct neig
 					 struct hh_cache *hh);
 
 extern struct net_device *alloc_etherdev_mq(int sizeof_priv, unsigned int queue_count);
+extern struct net_device *devm_alloc_etherdev_mq(struct device *dev,
+					      int sizeof_priv,
+					      unsigned int queue_count);
 #define alloc_etherdev(sizeof_priv) alloc_etherdev_mq(sizeof_priv, 1)
+#define devm_alloc_etherdev(dev, sizeof_priv) \
+	devm_alloc_etherdev_mq(dev, sizeof_priv, 1)
 
 /**
  * is_zero_ether_addr - Determine if give Ethernet address is all zeros.
Index: linux-2.6/net/ethernet/eth.c
===================================================================
--- linux-2.6.orig/net/ethernet/eth.c
+++ linux-2.6/net/ethernet/eth.c
@@ -337,3 +337,11 @@ struct net_device *alloc_etherdev_mq(int
 	return alloc_netdev_mq(sizeof_priv, "eth%d", ether_setup, queue_count);
 }
 EXPORT_SYMBOL(alloc_etherdev_mq);
+
+struct net_device *devm_alloc_etherdev_mq(struct device *dev, int sizeof_priv,
+						unsigned int queue_count)
+{
+	return devm_alloc_netdev_mq(dev, sizeof_priv, "eth%d", ether_setup,
+				    queue_count);
+}
+EXPORT_SYMBOL(devm_alloc_etherdev_mq);

-- 
