From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3] tg3: Add tg3_restart_hw()
Date: Tue, 25 Jul 2006 15:56:13 -0700
Message-ID: <1153868173.3167.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sdoyon@max-t.com, howie@vmware.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:10771 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1030215AbWGYWyx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:54:53 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add tg3_restart_hw() to handle failures when re-initializing the
device.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ce6f3be..1253cec 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -3590,6 +3590,28 @@ static irqreturn_t tg3_test_isr(int irq,
 static int tg3_init_hw(struct tg3 *, int);
 static int tg3_halt(struct tg3 *, int, int);
 
+/* Restart hardware after configuration changes, self-test, etc.
+ * Invoked with tp->lock held.
+ */
+static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
+{
+	int err;
+
+	err = tg3_init_hw(tp, reset_phy);
+	if (err) {
+		printk(KERN_ERR PFX "%s: Failed to re-initialize device, "
+		       "aborting.\n", tp->dev->name);
+		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+		tg3_full_unlock(tp);
+		del_timer_sync(&tp->timer);
+		tp->irq_sync = 0;
+		netif_poll_enable(tp->dev);
+		dev_close(tp->dev);
+		tg3_full_lock(tp, 0);
+	}
+	return err;
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void tg3_poll_controller(struct net_device *dev)
 {
@@ -3630,13 +3652,15 @@ static void tg3_reset_task(void *_data)
 	}
 
 	tg3_halt(tp, RESET_KIND_SHUTDOWN, 0);
-	tg3_init_hw(tp, 1);
+	if (tg3_init_hw(tp, 1))
+		goto out;
 
 	tg3_netif_start(tp);
 
 	if (restart_timer)
 		mod_timer(&tp->timer, jiffies + 1);
 
+out:
 	tp->tg3_flags &= ~TG3_FLAG_IN_RESET_TASK;
 
 	tg3_full_unlock(tp);
@@ -4124,6 +4148,7 @@ static inline void tg3_set_mtu(struct ne
 static int tg3_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct tg3 *tp = netdev_priv(dev);
+	int err;
 
 	if (new_mtu < TG3_MIN_MTU || new_mtu > TG3_MAX_MTU(tp))
 		return -EINVAL;
@@ -4144,13 +4169,14 @@ static int tg3_change_mtu(struct net_dev
 
 	tg3_set_mtu(dev, tp, new_mtu);
 
-	tg3_init_hw(tp, 0);
+	err = tg3_restart_hw(tp, 0);
 
-	tg3_netif_start(tp);
+	if (!err)
+		tg3_netif_start(tp);
 
 	tg3_full_unlock(tp);
 
-	return 0;
+	return err;
 }
 
 /* Free up pending packets in all rx/tx rings.
@@ -5815,6 +5841,7 @@ static int tg3_set_mac_addr(struct net_d
 {
 	struct tg3 *tp = netdev_priv(dev);
 	struct sockaddr *addr = p;
+	int err = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
@@ -5832,9 +5859,9 @@ static int tg3_set_mac_addr(struct net_d
 		tg3_full_lock(tp, 1);
 
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp, 0);
-
-		tg3_netif_start(tp);
+		err = tg3_restart_hw(tp, 0);
+		if (!err)
+			tg3_netif_start(tp);
 		tg3_full_unlock(tp);
 	} else {
 		spin_lock_bh(&tp->lock);
@@ -5842,7 +5869,7 @@ static int tg3_set_mac_addr(struct net_d
 		spin_unlock_bh(&tp->lock);
 	}
 
-	return 0;
+	return err;
 }
 
 /* tp->lock is held. */
@@ -7956,7 +7983,7 @@ static void tg3_get_ringparam(struct net
 static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int irq_sync = 0;
+	int irq_sync = 0, err = 0;
   
 	if ((ering->rx_pending > TG3_RX_RING_SIZE - 1) ||
 	    (ering->rx_jumbo_pending > TG3_RX_JUMBO_RING_SIZE - 1) ||
@@ -7980,13 +8007,14 @@ static int tg3_set_ringparam(struct net_
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp, 1);
-		tg3_netif_start(tp);
+		err = tg3_restart_hw(tp, 1);
+		if (!err)
+			tg3_netif_start(tp);
 	}
 
 	tg3_full_unlock(tp);
   
-	return 0;
+	return err;
 }
   
 static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
@@ -8001,7 +8029,7 @@ static void tg3_get_pauseparam(struct ne
 static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int irq_sync = 0;
+	int irq_sync = 0, err = 0;
   
 	if (netif_running(dev)) {
 		tg3_netif_stop(tp);
@@ -8025,13 +8053,14 @@ static int tg3_set_pauseparam(struct net
 
 	if (netif_running(dev)) {
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		tg3_init_hw(tp, 1);
-		tg3_netif_start(tp);
+		err = tg3_restart_hw(tp, 1);
+		if (!err)
+			tg3_netif_start(tp);
 	}
 
 	tg3_full_unlock(tp);
   
-	return 0;
+	return err;
 }
   
 static u32 tg3_get_rx_csum(struct net_device *dev)
@@ -8666,7 +8695,9 @@ static int tg3_test_loopback(struct tg3 
 	if (!netif_running(tp->dev))
 		return TG3_LOOPBACK_FAILED;
 
-	tg3_reset_hw(tp, 1);
+	err = tg3_reset_hw(tp, 1);
+	if (err)
+		return TG3_LOOPBACK_FAILED;
 
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
@@ -8740,8 +8771,8 @@ static void tg3_self_test(struct net_dev
 		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
 		if (netif_running(dev)) {
 			tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-			tg3_init_hw(tp, 1);
-			tg3_netif_start(tp);
+			if (!tg3_restart_hw(tp, 1))
+				tg3_netif_start(tp);
 		}
 
 		tg3_full_unlock(tp);
@@ -11699,7 +11730,8 @@ static int tg3_suspend(struct pci_dev *p
 		tg3_full_lock(tp, 0);
 
 		tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-		tg3_init_hw(tp, 1);
+		if (tg3_restart_hw(tp, 1))
+			goto out;
 
 		tp->timer.expires = jiffies + tp->timer_offset;
 		add_timer(&tp->timer);
@@ -11707,6 +11739,7 @@ static int tg3_suspend(struct pci_dev *p
 		netif_device_attach(dev);
 		tg3_netif_start(tp);
 
+out:
 		tg3_full_unlock(tp);
 	}
 
@@ -11733,16 +11766,19 @@ static int tg3_resume(struct pci_dev *pd
 	tg3_full_lock(tp, 0);
 
 	tp->tg3_flags |= TG3_FLAG_INIT_COMPLETE;
-	tg3_init_hw(tp, 1);
+	err = tg3_restart_hw(tp, 1);
+	if (err)
+		goto out;
 
 	tp->timer.expires = jiffies + tp->timer_offset;
 	add_timer(&tp->timer);
 
 	tg3_netif_start(tp);
 
+out:
 	tg3_full_unlock(tp);
 
-	return 0;
+	return err;
 }
 
 static struct pci_driver tg3_driver = {


