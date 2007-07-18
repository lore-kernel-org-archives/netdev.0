From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 2/2] net/core: some functions' definition order adjustment for readability
Date: Wed, 18 Jul 2007 19:30:29 +0800
Message-ID: <11847582511783-git-send-email-crquan@gmail.com>
References: <20070718.030306.50591269.davem@davemloft.net>
 <1184758229305-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Patrick McHardy <kaber@trash.net>, pekkas@netcore.fi,
	jmorris@namei.org, linux-kernel@vger.kernel.org,
	Denis Cheng <crquan@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:19881 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758178AbXGRLar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 07:30:47 -0400
Received: by nz-out-0506.google.com with SMTP id s18so138749nze
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 04:30:46 -0700 (PDT)
In-Reply-To: <1184758229305-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/core/dev.c |  407 ++++++++++++++++++++++++++++----------------------------
 1 files changed, 201 insertions(+), 206 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 16842af..ee567dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2790,6 +2790,134 @@ int dev_unicast_add(struct net_device *dev, void *addr, int alen)
 }
 EXPORT_SYMBOL(dev_unicast_add);
 
+/*
+ *	Device multicast list maintenance.
+ *
+ *	This is used both by IP and by the user level maintenance functions.
+ *	Unlike BSD we maintain a usage count on a given multicast address so
+ *	that a casual user application can add/delete multicasts used by
+ *	protocols without doing damage to the protocols when it deletes the
+ *	entries. It also helps IP as it tracks overlapping maps.
+ *
+ *	Device mc lists are changed by bh at least if IPv6 is enabled,
+ *	so that it must be bh protected.
+ *
+ *	We block accesses to device mc filters with netif_tx_lock.
+ */
+
+/*
+ *	Delete a device level multicast
+ */
+int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
+{
+	int err;
+
+	netif_tx_lock_bh(dev);
+	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
+				addr, alen, glbl);
+	if (!err) {
+		/*
+		 *	We have altered the list, so the card
+		 *	loaded filter is now wrong. Fix it
+		 */
+
+		__dev_set_rx_mode(dev);
+	}
+	netif_tx_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_mc_delete);
+
+/*
+ *	Add a device level multicast
+ */
+int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
+{
+	int err;
+
+	netif_tx_lock_bh(dev);
+	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
+	if (!err)
+		__dev_set_rx_mode(dev);
+	netif_tx_unlock_bh(dev);
+	return err;
+}
+EXPORT_SYMBOL(dev_mc_add);
+
+/**
+ *	dev_mc_sync	- Synchronize device's multicast list to another device
+ *	@to: destination device
+ *	@from: source device
+ *
+ * 	Add newly added addresses to the destination device and release
+ * 	addresses that have no users left. The source device must be
+ * 	locked by netif_tx_lock_bh.
+ *
+ *	This function is intended to be called from the dev->set_multicast_list
+ *	function of layered software devices.
+ */
+int dev_mc_sync(struct net_device *to, struct net_device *from)
+{
+	struct dev_addr_list *da;
+	int err = 0;
+
+	netif_tx_lock_bh(to);
+	for (da = from->mc_list; da != NULL; da = da->next) {
+		if (!da->da_synced) {
+			err = __dev_addr_add(&to->mc_list, &to->mc_count,
+					     da->da_addr, da->da_addrlen, 0);
+			if (err < 0)
+				break;
+			da->da_synced = 1;
+			da->da_users++;
+		} else if (da->da_users == 1) {
+			__dev_addr_delete(&to->mc_list, &to->mc_count,
+					  da->da_addr, da->da_addrlen, 0);
+			__dev_addr_delete(&from->mc_list, &from->mc_count,
+					  da->da_addr, da->da_addrlen, 0);
+		}
+	}
+	if (!err)
+		__dev_set_rx_mode(to);
+	netif_tx_unlock_bh(to);
+
+	return err;
+}
+EXPORT_SYMBOL(dev_mc_sync);
+
+/**
+ * 	dev_mc_unsync	- Remove synchronized addresses from the destination
+ * 			  device
+ *	@to: destination device
+ *	@from: source device
+ *
+ * 	Remove all addresses that were added to the destination device by
+ * 	dev_mc_sync(). This function is intended to be called from the
+ * 	dev->stop function of layered software devices.
+ */
+void dev_mc_unsync(struct net_device *to, struct net_device *from)
+{
+	struct dev_addr_list *da;
+
+	netif_tx_lock_bh(from);
+	netif_tx_lock_bh(to);
+
+	for (da = from->mc_list; da != NULL; da = da->next) {
+		if (!da->da_synced)
+			continue;
+		__dev_addr_delete(&to->mc_list, &to->mc_count,
+				  da->da_addr, da->da_addrlen, 0);
+		da->da_synced = 0;
+		__dev_addr_delete(&from->mc_list, &from->mc_count,
+				  da->da_addr, da->da_addrlen, 0);
+	}
+	__dev_set_rx_mode(to);
+
+	netif_tx_unlock_bh(to);
+	netif_tx_unlock_bh(from);
+}
+EXPORT_SYMBOL(dev_mc_unsync);
+
 static void __dev_addr_discard(struct dev_addr_list **list)
 {
 	struct dev_addr_list *tmp;
@@ -3963,6 +4091,79 @@ static int __init netdev_dma_register(void)
 static int __init netdev_dma_register(void) { return -ENODEV; }
 #endif /* CONFIG_NET_DMA */
 
+#ifdef CONFIG_PROC_FS
+static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct net_device *dev;
+	loff_t off = 0;
+
+	read_lock(&dev_base_lock);
+	for_each_netdev(dev) {
+		if (off++ == *pos)
+			return dev;
+	}
+	return NULL;
+}
+
+static void *dev_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return next_net_device((struct net_device *)v);
+}
+
+static void dev_mc_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock(&dev_base_lock);
+}
+
+static int dev_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct dev_addr_list *m;
+	struct net_device *dev = v;
+
+	netif_tx_lock_bh(dev);
+	for (m = dev->mc_list; m; m = m->next) {
+		int i;
+
+		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
+			   dev->name, m->dmi_users, m->dmi_gusers);
+
+		for (i = 0; i < m->dmi_addrlen; i++)
+			seq_printf(seq, "%02x", m->dmi_addr[i]);
+
+		seq_putc(seq, '\n');
+	}
+	netif_tx_unlock_bh(dev);
+	return 0;
+}
+
+static const struct seq_operations dev_mc_seq_ops = {
+	.start = dev_mc_seq_start,
+	.next  = dev_mc_seq_next,
+	.stop  = dev_mc_seq_stop,
+	.show  = dev_mc_seq_show,
+};
+
+static int dev_mc_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &dev_mc_seq_ops);
+}
+
+static const struct file_operations dev_mc_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = dev_mc_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+#endif
+
+void __init dev_mcast_init(void)
+{
+	proc_net_fops_create("dev_mcast", 0, &dev_mc_seq_fops);
+}
+
 /*
  *	Initialize the DEV module. At boot time this walks the device list and
  *	unhooks any devices that fail to initialise (normally hardware not
@@ -4076,209 +4277,3 @@ EXPORT_SYMBOL(dev_load);
 #endif
 
 EXPORT_PER_CPU_SYMBOL(softnet_data);
-
-/*
- *	Device multicast list maintenance.
- *
- *	This is used both by IP and by the user level maintenance functions.
- *	Unlike BSD we maintain a usage count on a given multicast address so
- *	that a casual user application can add/delete multicasts used by
- *	protocols without doing damage to the protocols when it deletes the
- *	entries. It also helps IP as it tracks overlapping maps.
- *
- *	Device mc lists are changed by bh at least if IPv6 is enabled,
- *	so that it must be bh protected.
- *
- *	We block accesses to device mc filters with netif_tx_lock.
- */
-
-/*
- *	Delete a device level multicast
- */
-
-int dev_mc_delete(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_tx_lock_bh(dev);
-	err = __dev_addr_delete(&dev->mc_list, &dev->mc_count,
-				addr, alen, glbl);
-	if (!err) {
-		/*
-		 *	We have altered the list, so the card
-		 *	loaded filter is now wrong. Fix it
-		 */
-
-		__dev_set_rx_mode(dev);
-	}
-	netif_tx_unlock_bh(dev);
-	return err;
-}
-
-/*
- *	Add a device level multicast
- */
-
-int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
-{
-	int err;
-
-	netif_tx_lock_bh(dev);
-	err = __dev_addr_add(&dev->mc_list, &dev->mc_count, addr, alen, glbl);
-	if (!err)
-		__dev_set_rx_mode(dev);
-	netif_tx_unlock_bh(dev);
-	return err;
-}
-
-/**
- *	dev_mc_sync	- Synchronize device's multicast list to another device
- *	@to: destination device
- *	@from: source device
- *
- * 	Add newly added addresses to the destination device and release
- * 	addresses that have no users left. The source device must be
- * 	locked by netif_tx_lock_bh.
- *
- *	This function is intended to be called from the dev->set_multicast_list
- *	function of layered software devices.
- */
-int dev_mc_sync(struct net_device *to, struct net_device *from)
-{
-	struct dev_addr_list *da;
-	int err = 0;
-
-	netif_tx_lock_bh(to);
-	for (da = from->mc_list; da != NULL; da = da->next) {
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
-	}
-	if (!err)
-		__dev_set_rx_mode(to);
-	netif_tx_unlock_bh(to);
-
-	return err;
-}
-EXPORT_SYMBOL(dev_mc_sync);
-
-
-/**
- * 	dev_mc_unsync	- Remove synchronized addresses from the destination
- * 			  device
- *	@to: destination device
- *	@from: source device
- *
- * 	Remove all addresses that were added to the destination device by
- * 	dev_mc_sync(). This function is intended to be called from the
- * 	dev->stop function of layered software devices.
- */
-void dev_mc_unsync(struct net_device *to, struct net_device *from)
-{
-	struct dev_addr_list *da;
-
-	netif_tx_lock_bh(from);
-	netif_tx_lock_bh(to);
-
-	for (da = from->mc_list; da != NULL; da = da->next) {
-		if (!da->da_synced)
-			continue;
-		__dev_addr_delete(&to->mc_list, &to->mc_count,
-				  da->da_addr, da->da_addrlen, 0);
-		da->da_synced = 0;
-		__dev_addr_delete(&from->mc_list, &from->mc_count,
-				  da->da_addr, da->da_addrlen, 0);
-	}
-	__dev_set_rx_mode(to);
-
-	netif_tx_unlock_bh(to);
-	netif_tx_unlock_bh(from);
-}
-EXPORT_SYMBOL(dev_mc_unsync);
-
-#ifdef CONFIG_PROC_FS
-static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	struct net_device *dev;
-	loff_t off = 0;
-
-	read_lock(&dev_base_lock);
-	for_each_netdev(dev) {
-		if (off++ == *pos)
-			return dev;
-	}
-	return NULL;
-}
-
-static void *dev_mc_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return next_net_device((struct net_device *)v);
-}
-
-static void dev_mc_seq_stop(struct seq_file *seq, void *v)
-{
-	read_unlock(&dev_base_lock);
-}
-
-
-static int dev_mc_seq_show(struct seq_file *seq, void *v)
-{
-	struct dev_addr_list *m;
-	struct net_device *dev = v;
-
-	netif_tx_lock_bh(dev);
-	for (m = dev->mc_list; m; m = m->next) {
-		int i;
-
-		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
-			   dev->name, m->dmi_users, m->dmi_gusers);
-
-		for (i = 0; i < m->dmi_addrlen; i++)
-			seq_printf(seq, "%02x", m->dmi_addr[i]);
-
-		seq_putc(seq, '\n');
-	}
-	netif_tx_unlock_bh(dev);
-	return 0;
-}
-
-static const struct seq_operations dev_mc_seq_ops = {
-	.start = dev_mc_seq_start,
-	.next  = dev_mc_seq_next,
-	.stop  = dev_mc_seq_stop,
-	.show  = dev_mc_seq_show,
-};
-
-static int dev_mc_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &dev_mc_seq_ops);
-}
-
-static const struct file_operations dev_mc_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = dev_mc_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release,
-};
-
-#endif
-
-void __init dev_mcast_init(void)
-{
-	proc_net_fops_create("dev_mcast", 0, &dev_mc_seq_fops);
-}
-
-EXPORT_SYMBOL(dev_mc_add);
-EXPORT_SYMBOL(dev_mc_delete);
-- 
1.5.2.2

