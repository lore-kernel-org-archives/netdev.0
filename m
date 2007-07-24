From: bphilips@suse.de
Subject: [PATCH 1/2][RFC] Update net core to use devres.
Date: Tue, 24 Jul 2007 15:39:52 -0700
Message-ID: <11853167964115-git-send-email-bphilips@suse.de>
References: <11853167931415-git-send-email-bphilips@suse.de>
Cc: Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39229 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756134AbXGXWkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 18:40:00 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 0585E21951
	for <netdev@vger.kernel.org>; Wed, 25 Jul 2007 00:40:00 +0200 (CEST)
In-Reply-To: <11853167931415-git-send-email-bphilips@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* netdev_pci_remove_one() can replace simple pci device remove
  functions

* devm_alloc_netdev() is like alloc_netdev but allocates memory using devres.
  alloc_netdev() can be removed once all drivers use devres.

Applies against 2.6.22

Signed-off-by: Brandon Philips <bphilips@suse.de>

---
 include/linux/etherdevice.h |    2 +
 include/linux/netdevice.h   |    5 ++++
 net/core/dev.c              |   48 ++++++++++++++++++++++++++++++++++++++++----
 net/ethernet/eth.c          |    6 +++++
 4 files changed, 57 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -622,6 +622,7 @@ extern int		dev_queue_xmit(struct sk_buf
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
+extern void		netdev_pci_remove_one(struct pci_dev *pdev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
@@ -992,6 +993,10 @@ static inline void netif_tx_disable(stru
 extern void		ether_setup(struct net_device *dev);
 
 /* Support for loadable net-drivers */
+
+extern struct net_device *devm_alloc_netdev(struct device *dev,
+					    int sizeof_priv, const char *name,
+					    void (*setup)(struct net_device *));
 extern struct net_device *alloc_netdev(int sizeof_priv, const char *name,
 				       void (*setup)(struct net_device *));
 extern int		register_netdev(struct net_device *dev);
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
@@ -3343,7 +3344,8 @@ static struct net_device_stats *internal
 }
 
 /**
- *	alloc_netdev - allocate network device
+ *	__alloc_netdev - allocate network device
+ *	@dev:		managed device responsible for mem; NULL if not managed
  *	@sizeof_priv:	size of private data to allocate space for
  *	@name:		device name format string
  *	@setup:		callback to initialize device
@@ -3351,8 +3353,8 @@ static struct net_device_stats *internal
  *	Allocates a struct net_device with private data area for driver use
  *	and performs basic initialization.
  */
-struct net_device *alloc_netdev(int sizeof_priv, const char *name,
-		void (*setup)(struct net_device *))
+struct net_device *__alloc_netdev(struct device *gendev, int sizeof_priv,
+		const char *name, void (*setup)(struct net_device *))
 {
 	void *p;
 	struct net_device *dev;
@@ -3364,7 +3366,11 @@ struct net_device *alloc_netdev(int size
 	alloc_size = (sizeof(*dev) + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
 	alloc_size += sizeof_priv + NETDEV_ALIGN_CONST;
 
-	p = kzalloc(alloc_size, GFP_KERNEL);
+	if (dev == NULL)
+		p = kzalloc(alloc_size, GFP_KERNEL);
+	else
+		p = devm_kzalloc(gendev, alloc_size, GFP_KERNEL);
+
 	if (!p) {
 		printk(KERN_ERR "alloc_netdev: Unable to allocate device.\n");
 		return NULL;
@@ -3382,8 +3388,23 @@ struct net_device *alloc_netdev(int size
 	strcpy(dev->name, name);
 	return dev;
 }
+
+struct net_device *devm_alloc_netdev(struct device *dev, int sizeof_priv, const
+				char *name, void (*setup)(struct net_device *))
+{
+	return __alloc_netdev(dev, sizeof_priv, name, setup);
+}
+EXPORT_SYMBOL(devm_alloc_netdev);
+
+struct net_device *alloc_netdev(int sizeof_priv, const char *name,
+				void (*setup)(struct net_device *))
+{
+	return __alloc_netdev(NULL, sizeof_priv, name, setup);
+}
 EXPORT_SYMBOL(alloc_netdev);
 
+
+
 /**
  *	free_netdev - free network device
  *	@dev: device
@@ -3411,6 +3432,25 @@ void free_netdev(struct net_device *dev)
 #endif
 }
 
+/**
+ *	free_netdev - free network device
+ *	@dev: device
+ *
+ *	This function does the last stage of destroying an allocated device
+ * 	interface. The reference to the device object is released.
+ *	If this is the last reference then it will be freed.
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
+
+
 /* Synchronize with packet receive processing. */
 void synchronize_net(void)
 {
Index: linux-2.6/include/linux/etherdevice.h
===================================================================
--- linux-2.6.orig/include/linux/etherdevice.h
+++ linux-2.6/include/linux/etherdevice.h
@@ -40,6 +40,8 @@ extern int		eth_header_cache(struct neig
 					 struct hh_cache *hh);
 
 extern struct net_device *alloc_etherdev(int sizeof_priv);
+extern struct net_device *devm_alloc_etherdev(struct device *dev,
+					      int sizeof_priv);
 static inline void eth_copy_and_sum (struct sk_buff *dest, 
 				     const unsigned char *src, 
 				     int len, int base)
Index: linux-2.6/net/ethernet/eth.c
===================================================================
--- linux-2.6.orig/net/ethernet/eth.c
+++ linux-2.6/net/ethernet/eth.c
@@ -333,3 +333,9 @@ struct net_device *alloc_etherdev(int si
 	return alloc_netdev(sizeof_priv, "eth%d", ether_setup);
 }
 EXPORT_SYMBOL(alloc_etherdev);
+
+struct net_device *devm_alloc_etherdev(struct device *dev, int sizeof_priv)
+{
+	return devm_alloc_netdev(dev, sizeof_priv, "eth%d", ether_setup);
+}
+EXPORT_SYMBOL(devm_alloc_etherdev);
