From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-2.6] net: restore the original spinlock to protect
	unicast list
Date: Thu, 30 Jul 2009 13:06:12 +0200
Message-ID: <20090730110612.GD3686@psychotron.englab.brq.redhat.com>
References: <Pine.SOC.4.64.0907301114150.10041@math.ut.ee> <4A71630A.9080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Meelis Roos <mroos@linux.ee>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43379 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246AbZG3LGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 07:06:24 -0400
Content-Disposition: inline
In-Reply-To: <4A71630A.9080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a path when an assetion in dev_unicast_sync() appears. 

igmp6_group_added -> dev_mc_add -> __dev_set_rx_mode ->
-> vlan_dev_set_rx_mode -> dev_unicast_sync

Therefore we cannot protect this list with rtnl. This patch restores the
original protecting this list with spinlock.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index 70c27e0..43e61ba 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3865,10 +3865,12 @@ int dev_unicast_delete(struct net_device *dev, void *addr)
 
 	ASSERT_RTNL();
 
+	netif_addr_lock_bh(dev);
 	err = __hw_addr_del(&dev->uc, addr, dev->addr_len,
 			    NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_delete);
@@ -3889,10 +3891,12 @@ int dev_unicast_add(struct net_device *dev, void *addr)
 
 	ASSERT_RTNL();
 
+	netif_addr_lock_bh(dev);
 	err = __hw_addr_add(&dev->uc, addr, dev->addr_len,
 			    NETDEV_HW_ADDR_T_UNICAST);
 	if (!err)
 		__dev_set_rx_mode(dev);
+	netif_addr_unlock_bh(dev);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_add);
@@ -3949,7 +3953,8 @@ void __dev_addr_unsync(struct dev_addr_list **to, int *to_count,
  *	@from: source device
  *
  *	Add newly added addresses to the destination device and release
- *	addresses that have no users left.
+ *	addresses that have no users left. The source device must be
+ *	locked by netif_tx_lock_bh.
  *
  *	This function is intended to be called from the dev->set_rx_mode
  *	function of layered software devices.
@@ -3958,14 +3963,14 @@ int dev_unicast_sync(struct net_device *to, struct net_device *from)
 {
 	int err = 0;
 
-	ASSERT_RTNL();
-
 	if (to->addr_len != from->addr_len)
 		return -EINVAL;
 
+	netif_addr_lock_bh(to);
 	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
 	if (!err)
 		__dev_set_rx_mode(to);
+	netif_addr_unlock_bh(to);
 	return err;
 }
 EXPORT_SYMBOL(dev_unicast_sync);
@@ -3981,28 +3986,30 @@ EXPORT_SYMBOL(dev_unicast_sync);
  */
 void dev_unicast_unsync(struct net_device *to, struct net_device *from)
 {
-	ASSERT_RTNL();
-
 	if (to->addr_len != from->addr_len)
 		return;
 
+	netif_addr_lock_bh(from);
+	netif_addr_lock(to);
 	__hw_addr_unsync(&to->uc, &from->uc, to->addr_len);
 	__dev_set_rx_mode(to);
+	netif_addr_unlock(to);
+	netif_addr_unlock_bh(from);
 }
 EXPORT_SYMBOL(dev_unicast_unsync);
 
 static void dev_unicast_flush(struct net_device *dev)
 {
-	/* rtnl_mutex must be held here */
-
+	netif_addr_lock_bh(dev);
 	__hw_addr_flush(&dev->uc);
+	netif_addr_unlock_bh(dev);
 }
 
 static void dev_unicast_init(struct net_device *dev)
 {
-	/* rtnl_mutex must be held here */
-
+	netif_addr_lock_bh(dev);
 	__hw_addr_init(&dev->uc);
+	netif_addr_unlock_bh(dev);
 }
 
 
