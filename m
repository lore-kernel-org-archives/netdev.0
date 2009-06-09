From: Johannes Berg <johannes@sipsolutions.net>
Subject: error handling for dev_mc_sync (__dev_addr_add)
Date: Tue, 09 Jun 2009 16:11:07 +0200
Message-ID: <1244556667.4672.18.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34415 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZFIOLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 10:11:38 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <johannes@sipsolutions.net>)
	id 1ME239-0002XJ-PG
	for netdev@vger.kernel.org; Tue, 09 Jun 2009 16:11:39 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I can't seem to figure out how to handle errors from dev_mc_sync(). I
can see why it fails, looking at __dev_addr_add(), because memory
allocations can fail. However, it seems that __dev_addr_sync() will then
leave the netdev in a state where some addresses were added, but others
were not. And ndo_set_multicast_list() cannot even return an error code.

So how am I supposed to handle the error? Isn't it possible that
dev_mc_unsync() will then cause trouble because it removes something
that wasn't actually added? OTOH, there always is da->synced, but then
__dev_addr_sync() confuses me -- why does it not increment da->da_users?

Basically what I need is the patch below to maintain a multicast list,
but I'm wondering if it's all correct that way and what error handling I
need and am currently lacking if I ignore the return value of
dev_mc_sync().

johannes

--- wireless-testing.orig/include/linux/netdevice.h	2009-06-09 11:49:10.000000000 +0200
+++ wireless-testing/include/linux/netdevice.h	2009-06-09 11:54:41.000000000 +0200
@@ -1810,6 +1810,9 @@ extern int		dev_set_allmulti(struct net_
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_bonding_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
+/* locking of to/to_count must be caller-provided */
+extern int		mc_sync_from_dev(struct dev_addr_list **to, int *to_count, struct net_device *from);
+extern void		mc_unsync_from_dev(struct dev_addr_list **to, int *to_count, struct net_device *from);
 /* Load a device via the kmod */
 extern void		dev_load(struct net *net, const char *name);
 extern void		dev_mcast_init(void);
--- wireless-testing.orig/net/core/dev_mcast.c	2009-06-09 11:50:37.000000000 +0200
+++ wireless-testing/net/core/dev_mcast.c	2009-06-09 12:26:17.000000000 +0200
@@ -155,6 +155,52 @@ void dev_mc_unsync(struct net_device *to
 }
 EXPORT_SYMBOL(dev_mc_unsync);
 
+
+/**
+ *	mc_sync_from_dev - Synchronize device's multicast list to another list
+ *	@to: destination list
+ *	@to_count: destination list count
+ *	@from: source device
+ *
+ * 	Add newly added addresses to the destination device and release
+ * 	addresses that have no users left. The source device must be
+ * 	locked by netif_tx_lock_bh, and the destination list must be locked
+ *	in whatever way the caller manages it.
+ *
+ *	This function is intended to be called from the dev->set_multicast_list
+ *	or dev->set_rx_mode function of layered software devices.
+ */
+int mc_sync_from_dev(struct dev_addr_list **to, int *to_count,
+		     struct net_device *from)
+{
+	return __dev_addr_sync(to, to_count,
+			       &from->mc_list, &from->mc_count);
+}
+EXPORT_SYMBOL(mc_sync_from_dev);
+
+
+/**
+ * 	mc_unsync_from_dev - Remove synchronized addresses from the destination list
+ *	@to: destination list
+ *	@to_count: destination list count
+ *	@from: source device
+ *
+ * 	Remove all addresses that were added to the destination list by
+ * 	mc_sync_from_dev(). This function is intended to be called from
+ *	the * 	dev->stop function of layered software devices. The
+ *	destination list must be locked in whatever way the caller
+ *	manages it.
+ */
+void mc_unsync_from_dev(struct dev_addr_list **to, int *to_count,
+			struct net_device *from)
+{
+	netif_addr_lock_bh(from);
+	__dev_addr_unsync(to, to_count,
+			  &from->mc_list, &from->mc_count);
+	netif_addr_unlock_bh(from);
+}
+EXPORT_SYMBOL(mc_unsync_from_dev);
+
 #ifdef CONFIG_PROC_FS
 static int dev_mc_seq_show(struct seq_file *seq, void *v)
 {


