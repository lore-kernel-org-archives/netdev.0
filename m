From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/2] net: introduce netif_addr_lock_nested() and call if when appropriate
Date: Mon,  9 Jan 2012 17:18:35 +0100
Message-ID: <1326125915-2711-2-git-send-email-jpirko@redhat.com>
References: <1326125915-2711-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29506 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932266Ab2AIQSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jan 2012 11:18:42 -0500
In-Reply-To: <1326125915-2711-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_uc_sync() and dev_mc_sync() are acquiring netif_addr_lock for
destination device of synchronization. Since netif_addr_lock is already
held at the time for source device, this triggers depmod deathlock
warning.

There's no way this deathlock can happen so use spin_lock_nested() to
silence the warning.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |    5 +++++
 net/core/dev_addr_lists.c |   12 ++++++------
 2 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a1d1095..656fade 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2450,6 +2450,11 @@ static inline void netif_addr_lock(struct net_device *dev)
 	spin_lock(&dev->addr_list_lock);
 }
 
+static inline void netif_addr_lock_nested(struct net_device *dev)
+{
+	spin_lock_nested(&dev->addr_list_lock, DENTRY_D_LOCK_NESTED);
+}
+
 static inline void netif_addr_lock_bh(struct net_device *dev)
 {
 	spin_lock_bh(&dev->addr_list_lock);
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index c34ce9f..29c07fe 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -439,11 +439,11 @@ int dev_uc_sync(struct net_device *to, struct net_device *from)
 	if (to->addr_len != from->addr_len)
 		return -EINVAL;
 
-	netif_addr_lock_bh(to);
+	netif_addr_lock_nested(to);
 	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
+	netif_addr_unlock(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_uc_sync);
@@ -463,7 +463,7 @@ void dev_uc_unsync(struct net_device *to, struct net_device *from)
 		return;
 
 	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
+	netif_addr_lock_nested(to);
 	__hw_addr_unsync(&to->uc, &from->uc, to->addr_len);
 	__dev_set_rx_mode(to);
 	netif_addr_unlock(to);
@@ -602,11 +602,11 @@ int dev_mc_sync(struct net_device *to, struct net_device *from)
 	if (to->addr_len != from->addr_len)
 		return -EINVAL;
 
-	netif_addr_lock_bh(to);
+	netif_addr_lock_nested(to);
 	err = __hw_addr_sync(&to->mc, &from->mc, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
-	netif_addr_unlock_bh(to);
+	netif_addr_unlock(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_mc_sync);
@@ -626,7 +626,7 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 		return;
 
 	netif_addr_lock_bh(from);
-	netif_addr_lock(to);
+	netif_addr_lock_nested(to);
 	__hw_addr_unsync(&to->mc, &from->mc, to->addr_len);
 	__dev_set_rx_mode(to);
 	netif_addr_unlock(to);
-- 
1.7.6
