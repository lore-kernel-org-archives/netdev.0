From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 13/13] wimax/i2400m: fix oops caused by race condition when exiting USB kthreads
Date: Wed,  4 Nov 2009 13:40:08 -0800
Message-ID: <4a78fd9a736db4c871bc8b583d66b61c38abd299.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45636 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932777AbZKDVmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:14 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current i2400m USB code had to threads (one for processing RX, one for
TX). When calling i2400m_{tx,rx}_release(), it would crash if the
thread had exited already due to an error.

So changed the code to have the thread fill in/out
i2400mu->{tx,rx}_kthread under a spinlock; then the _release()
function will call kthread_stop() only if {rx,tx}_kthread is still
set.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/usb-rx.c |   35 +++++++++++++++++++++++++++++------
 drivers/net/wimax/i2400m/usb-tx.c |   35 ++++++++++++++++++++++++++++++-----
 2 files changed, 59 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wimax/i2400m/usb-rx.c b/drivers/net/wimax/i2400m/usb-rx.c
index e494e37..245587f 100644
--- a/drivers/net/wimax/i2400m/usb-rx.c
+++ b/drivers/net/wimax/i2400m/usb-rx.c
@@ -316,10 +316,15 @@ int i2400mu_rxd(void *_i2400mu)
 	size_t pending;
 	int rx_size;
 	struct sk_buff *rx_skb;
+	unsigned long flags;
 
 	d_fnstart(4, dev, "(i2400mu %p)\n", i2400mu);
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	BUG_ON(i2400mu->rx_kthread != NULL);
+	i2400mu->rx_kthread = current;
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	while (1) {
-		d_printf(2, dev, "TX: waiting for messages\n");
+		d_printf(2, dev, "RX: waiting for messages\n");
 		pending = 0;
 		wait_event_interruptible(
 			i2400mu->rx_wq,
@@ -367,6 +372,9 @@ int i2400mu_rxd(void *_i2400mu)
 	}
 	result = 0;
 out:
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	i2400mu->rx_kthread = NULL;
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	d_fnend(4, dev, "(i2400mu %p) = %d\n", i2400mu, result);
 	return result;
 
@@ -403,18 +411,33 @@ int i2400mu_rx_setup(struct i2400mu *i2400mu)
 	struct i2400m *i2400m = &i2400mu->i2400m;
 	struct device *dev = &i2400mu->usb_iface->dev;
 	struct wimax_dev *wimax_dev = &i2400m->wimax_dev;
+	struct task_struct *kthread;
 
-	i2400mu->rx_kthread = kthread_run(i2400mu_rxd, i2400mu, "%s-rx",
-					  wimax_dev->name);
-	if (IS_ERR(i2400mu->rx_kthread)) {
-		result = PTR_ERR(i2400mu->rx_kthread);
+	kthread = kthread_run(i2400mu_rxd, i2400mu, "%s-rx",
+			      wimax_dev->name);
+	/* the kthread function sets i2400mu->rx_thread */
+	if (IS_ERR(kthread)) {
+		result = PTR_ERR(kthread);
 		dev_err(dev, "RX: cannot start thread: %d\n", result);
 	}
 	return result;
 }
 
+
 void i2400mu_rx_release(struct i2400mu *i2400mu)
 {
-	kthread_stop(i2400mu->rx_kthread);
+	unsigned long flags;
+	struct i2400m *i2400m = &i2400mu->i2400m;
+	struct device *dev = i2400m_dev(i2400m);
+	struct task_struct *kthread;
+
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	kthread = i2400mu->rx_kthread;
+	i2400mu->rx_kthread = NULL;
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+	if (kthread)
+		kthread_stop(kthread);
+	else
+		d_printf(1, dev, "RX: kthread had already exited\n");
 }
 
diff --git a/drivers/net/wimax/i2400m/usb-tx.c b/drivers/net/wimax/i2400m/usb-tx.c
index 90dfff1..a3c46e9 100644
--- a/drivers/net/wimax/i2400m/usb-tx.c
+++ b/drivers/net/wimax/i2400m/usb-tx.c
@@ -161,9 +161,15 @@ int i2400mu_txd(void *_i2400mu)
 	struct device *dev = &i2400mu->usb_iface->dev;
 	struct i2400m_msg_hdr *tx_msg;
 	size_t tx_msg_size;
+	unsigned long flags;
 
 	d_fnstart(4, dev, "(i2400mu %p)\n", i2400mu);
 
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	BUG_ON(i2400mu->tx_kthread != NULL);
+	i2400mu->tx_kthread = current;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+
 	while (1) {
 		d_printf(2, dev, "TX: waiting for messages\n");
 		tx_msg = NULL;
@@ -183,6 +189,11 @@ int i2400mu_txd(void *_i2400mu)
 		if (result < 0)
 			break;
 	}
+
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	i2400mu->tx_kthread = NULL;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+
 	d_fnend(4, dev, "(i2400mu %p) = %d\n", i2400mu, result);
 	return result;
 }
@@ -213,11 +224,13 @@ int i2400mu_tx_setup(struct i2400mu *i2400mu)
 	struct i2400m *i2400m = &i2400mu->i2400m;
 	struct device *dev = &i2400mu->usb_iface->dev;
 	struct wimax_dev *wimax_dev = &i2400m->wimax_dev;
+	struct task_struct *kthread;
 
-	i2400mu->tx_kthread = kthread_run(i2400mu_txd, i2400mu, "%s-tx",
-					  wimax_dev->name);
-	if (IS_ERR(i2400mu->tx_kthread)) {
-		result = PTR_ERR(i2400mu->tx_kthread);
+	kthread = kthread_run(i2400mu_txd, i2400mu, "%s-tx",
+			      wimax_dev->name);
+	/* the kthread function sets i2400mu->tx_thread */
+	if (IS_ERR(kthread)) {
+		result = PTR_ERR(kthread);
 		dev_err(dev, "TX: cannot start thread: %d\n", result);
 	}
 	return result;
@@ -225,5 +238,17 @@ int i2400mu_tx_setup(struct i2400mu *i2400mu)
 
 void i2400mu_tx_release(struct i2400mu *i2400mu)
 {
-	kthread_stop(i2400mu->tx_kthread);
+	unsigned long flags;
+	struct i2400m *i2400m = &i2400mu->i2400m;
+	struct device *dev = i2400m_dev(i2400m);
+	struct task_struct *kthread;
+
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	kthread = i2400mu->tx_kthread;
+	i2400mu->tx_kthread = NULL;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+	if (kthread)
+		kthread_stop(kthread);
+	else
+		d_printf(1, dev, "TX: kthread had already exited\n");
 }
-- 
1.6.2.5

