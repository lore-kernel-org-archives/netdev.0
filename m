From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [RFC net-next-2.6] can: replace spinlocks with mutexes
Date: Wed, 20 Apr 2011 17:31:33 +0200
Message-ID: <4DAEFC55.2010500@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Urs Thuermann <urs@isnogud.escape.de>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:31269 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725Ab1DTPbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 11:31:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes spinlocks for the CAN netdevice specific receive lists.
The RCU-based receive lists can be modified from process context or from the
netdevice notifier call. As both might sleep we can safely replace the
spinlocks with mutexes.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/net/can/af_can.c b/net/can/af_can.c
index a8dcaa4..e52ed358 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -47,7 +47,7 @@
 #include <linux/kmod.h>
 #include <linux/slab.h>
 #include <linux/list.h>
-#include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/rcupdate.h>
 #include <linux/uaccess.h>
 #include <linux/net.h>
@@ -79,7 +79,7 @@ MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 
 /* receive filters subscribed for 'all' CAN devices */
 struct dev_rcv_lists can_rx_alldev_list;
-static DEFINE_SPINLOCK(can_rcvlists_lock);
+static DEFINE_MUTEX(can_rcvlists_lock);
 
 static struct kmem_cache *rcv_cache __read_mostly;
 
@@ -435,7 +435,7 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
 	if (!r)
 		return -ENOMEM;
 
-	spin_lock(&can_rcvlists_lock);
+	mutex_lock(&can_rcvlists_lock);
 
 	d = find_dev_rcv_lists(dev);
 	if (d) {
@@ -459,7 +459,7 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
 		err = -ENODEV;
 	}
 
-	spin_unlock(&can_rcvlists_lock);
+	mutex_unlock(&can_rcvlists_lock);
 
 	return err;
 }
@@ -497,7 +497,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	if (dev && dev->type != ARPHRD_CAN)
 		return;
 
-	spin_lock(&can_rcvlists_lock);
+	mutex_lock(&can_rcvlists_lock);
 
 	d = find_dev_rcv_lists(dev);
 	if (!d) {
@@ -548,7 +548,7 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	}
 
  out:
-	spin_unlock(&can_rcvlists_lock);
+	mutex_unlock(&can_rcvlists_lock);
 
 	/* schedule the receiver item for deletion */
 	if (r)
@@ -775,7 +775,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 		break;
 
 	case NETDEV_UNREGISTER:
-		spin_lock(&can_rcvlists_lock);
+		mutex_lock(&can_rcvlists_lock);
 
 		d = dev->ml_priv;
 		if (d) {
@@ -789,7 +789,7 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 			printk(KERN_ERR "can: notifier: receive list not "
 			       "found for dev %s\n", dev->name);
 
-		spin_unlock(&can_rcvlists_lock);
+		mutex_unlock(&can_rcvlists_lock);
 
 		break;
 	}

