From: Patrick McHardy <kaber@trash.net>
Subject: [NET 02/05]: dev_mcast: add multicast list synchronization helpers
Date: Thu, 12 Jul 2007 20:13:42 +0200 (MEST)
Message-ID: <20070712181341.13849.58440.sendpatchset@localhost.localdomain>
References: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54184 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbXGLSNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:13:44 -0400
In-Reply-To: <20070712181338.13849.74894.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: dev_mcast: add multicast list synchronization helpers

The method drivers currently use to synchronize multicast lists is not
very pretty:

- walk the multicast list
- search each entry on a copy of the previous list
- if new add to lower device
- walk the copy of the previous list
- search each entry on the current list
- if removed delete from lower device
- copy entire list

This patch adds a new field to struct dev_addr_list to store the
synchronization state and adds two helper functions for synchronization
and cleanup.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 934ee4749ce12cb9b868a98fd3822cf5cdfa8208
tree ddb91cc1428e52f82712101518fccce65ed4597d
parent b977db07766ffb261d2c7ebe050cbc3b1d7d281a
author Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:53:58 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 12 Jul 2007 19:53:58 +0200

 include/linux/netdevice.h |    3 ++
 net/core/dev_mcast.c      |   75 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f193aba..e5af458 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -190,6 +190,7 @@ struct dev_addr_list
 	struct dev_addr_list	*next;
 	u8			da_addr[MAX_ADDR_LEN];
 	u8			da_addrlen;
+	u8			da_synced;
 	int			da_users;
 	int			da_gusers;
 };
@@ -1103,6 +1104,8 @@ extern int		dev_unicast_delete(struct net_device *dev, void *addr, int alen);
 extern int		dev_unicast_add(struct net_device *dev, void *addr, int alen);
 extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all);
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
+extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
+extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
 extern void		dev_mc_discard(struct net_device *dev);
 extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
 extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index aa38100..235a2a8 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -102,6 +102,81 @@ int dev_mc_add(struct net_device *dev, void *addr, int alen, int glbl)
 	return err;
 }
 
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
 /*
  *	Discard multicast list when a device is downed
  */
