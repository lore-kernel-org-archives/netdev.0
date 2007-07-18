From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 1/2] net/core: merge the content of dev_mcast.c into dev.c
Date: Wed, 18 Jul 2007 19:30:28 +0800
Message-ID: <1184758229305-git-send-email-crquan@gmail.com>
References: <20070718.030306.50591269.davem@davemloft.net>
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Patrick McHardy <kaber@trash.net>, pekkas@netcore.fi,
	jmorris@namei.org, linux-kernel@vger.kernel.org,
	Denis Cheng <crquan@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:19881 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbXGRLag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 07:30:36 -0400
Received: by nz-out-0506.google.com with SMTP id s18so138749nze
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 04:30:35 -0700 (PDT)
In-Reply-To: <20070718.030306.50591269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- removed three function declarations from header file to mark them static,
- reduced one file

Signed-off-by: Denis Cheng <crquan@gmail.com>
---

this one is just merging by concatenating, and I'll try to adjust some
function definitions' order to make it more readable.

 include/linux/netdevice.h |    3 -
 net/core/Makefile         |    2 +-
 net/core/dev.c            |  239 +++++++++++++++++++++++++++++++++++++++++-
 net/core/dev_mcast.c      |  255 ---------------------------------------------
 4 files changed, 237 insertions(+), 262 deletions(-)
 delete mode 100644 net/core/dev_mcast.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9820ca1..ca68c58 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1091,15 +1091,12 @@ extern int		register_netdev(struct net_device *dev);
 extern void		unregister_netdev(struct net_device *dev);
 /* Functions used for secondary unicast and multicast support */
 extern void		dev_set_rx_mode(struct net_device *dev);
-extern void		__dev_set_rx_mode(struct net_device *dev);
 extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
 extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
 extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
-extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
-extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/net/core/Makefile b/net/core/Makefile
index 4751613..54d28dd 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -7,7 +7,7 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
+obj-y		     += dev.o ethtool.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_XFRM) += flow.o
diff --git a/net/core/dev.c b/net/core/dev.c
index 6357f54..16842af 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -18,6 +18,7 @@
  *		Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
  *		Adam Sulmicki <adam@cfar.umd.edu>
  *              Pekka Riikonen <priikone@poesidon.pspt.fi>
+ *              Denis Cheng <crquan@gmail.com>
  *
  *	Changes:
  *              D.J. Barrow     :       Fixed bug where dev->refcnt gets set
@@ -70,6 +71,32 @@
  *              			indefinitely on dev->refcnt
  * 		J Hadi Salim	:	- Backlog queue sampling
  *				        - netif_rx() feedback
+ *              Denis Cheng     :       Merge dev_mcast.c into it
+ */
+
+/*
+ * 	The original information in dev_mcast.c:
+ *
+ *	Linux NET3:	Multicast List maintenance.
+ *
+ *	Authors:
+ *		Tim Kordas <tjk@nostromo.eeap.cwru.edu>
+ *		Richard Underwood <richard@wuzz.demon.co.uk>
+ *
+ *	Stir fried together from the IP multicast and CAP patches above
+ *		Alan Cox <Alan.Cox@linux.org>
+ *
+ *	Fixes:
+ *		Alan Cox	:	Update the device on a real delete
+ *					rather than any time but...
+ *		Alan Cox	:	IFF_ALLMULTI support.
+ *		Alan Cox	: 	New format set_multicast_list() calls.
+ *		Gleb Natapov    :       Remove dev_mc_lock.
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
  */
 
 #include <asm/uaccess.h>
@@ -2622,7 +2649,7 @@ void dev_set_allmulti(struct net_device *dev, int inc)
  *	filtering it is put in promiscous mode while unicast addresses
  *	are present.
  */
-void __dev_set_rx_mode(struct net_device *dev)
+static void __dev_set_rx_mode(struct net_device *dev)
 {
 	/* dev_open will call this function so the list will stay sane. */
 	if (!(dev->flags&IFF_UP))
@@ -2657,7 +2684,7 @@ void dev_set_rx_mode(struct net_device *dev)
 	netif_tx_unlock_bh(dev);
 }
 
-int __dev_addr_delete(struct dev_addr_list **list, int *count,
+static int __dev_addr_delete(struct dev_addr_list **list, int *count,
 		      void *addr, int alen, int glbl)
 {
 	struct dev_addr_list *da;
@@ -2683,7 +2710,7 @@ int __dev_addr_delete(struct dev_addr_list **list, int *count,
 	return -ENOENT;
 }
 
-int __dev_addr_add(struct dev_addr_list **list, int *count,
+static int __dev_addr_add(struct dev_addr_list **list, int *count,
 		   void *addr, int alen, int glbl)
 {
 	struct dev_addr_list *da;
@@ -4049,3 +4076,209 @@ EXPORT_SYMBOL(dev_load);
 #endif
 
 EXPORT_PER_CPU_SYMBOL(softnet_data);
+
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
+
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
+
+/*
+ *	Add a device level multicast
+ */
+
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
+EXPORT_SYMBOL(dev_mc_add);
+EXPORT_SYMBOL(dev_mc_delete);
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
deleted file mode 100644
index 99aece1..0000000
--- a/net/core/dev_mcast.c
+++ /dev/null
@@ -1,255 +0,0 @@
-/*
- *	Linux NET3:	Multicast List maintenance.
- *
- *	Authors:
- *		Tim Kordas <tjk@nostromo.eeap.cwru.edu>
- *		Richard Underwood <richard@wuzz.demon.co.uk>
- *
- *	Stir fried together from the IP multicast and CAP patches above
- *		Alan Cox <Alan.Cox@linux.org>
- *
- *	Fixes:
- *		Alan Cox	:	Update the device on a real delete
- *					rather than any time but...
- *		Alan Cox	:	IFF_ALLMULTI support.
- *		Alan Cox	: 	New format set_multicast_list() calls.
- *		Gleb Natapov    :       Remove dev_mc_lock.
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- */
-
-#include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
-#include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
-#include <linux/init.h>
-#include <net/ip.h>
-#include <net/route.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/arp.h>
-
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

