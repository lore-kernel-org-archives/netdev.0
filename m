From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/3 08/13] wimax/i2400m: on device stop, clean up pending wake & TX work
Date: Wed,  4 Nov 2009 13:39:59 -0800
Message-ID: <ac53aed9349242095a780f57ac0c995fb170c950.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20718 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932738AbZKDVmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:05 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the i2400m device needs to wake up an idle WiMAX connection, it
schedules a workqueue job to do it.

Currently, only when the network stack called the _stop() method this
work struct was being cancelled. This has to be done every time the
device is stopped.

So add a call in i2400m_dev_stop() to take care of such cleanup, which
is now wrapped in i2400m_net_wake_stop().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |    1 +
 drivers/net/wimax/i2400m/i2400m.h |    1 +
 drivers/net/wimax/i2400m/netdev.c |   53 +++++++++++++++++++++++--------------
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 07d12be..a33df04 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -527,6 +527,7 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	wimax_state_change(wimax_dev, __WIMAX_ST_QUIESCING);
+	i2400m_net_wake_stop(i2400m);
 	i2400m_dev_shutdown(i2400m);
 	i2400m->ready = 0;
 	i2400m->bus_dev_stop(i2400m);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 916b1d3..303eb78 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -691,6 +691,7 @@ extern void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned,
 			  const void *, int);
 extern void i2400m_net_erx(struct i2400m *, struct sk_buff *,
 			   enum i2400m_cs);
+extern void i2400m_net_wake_stop(struct i2400m *);
 enum i2400m_pt;
 extern int i2400m_tx(struct i2400m *, const void *, size_t, enum i2400m_pt);
 
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 960fb54..0e8f6a0 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -113,11 +113,6 @@ int i2400m_open(struct net_device *net_dev)
 }
 
 
-/*
- *
- * On kernel versions where cancel_work_sync() didn't return anything,
- * we rely on wake_tx_skb() being non-NULL.
- */
 static
 int i2400m_stop(struct net_device *net_dev)
 {
@@ -125,21 +120,7 @@ int i2400m_stop(struct net_device *net_dev)
 	struct device *dev = i2400m_dev(i2400m);
 
 	d_fnstart(3, dev, "(net_dev %p [i2400m %p])\n", net_dev, i2400m);
-	/* See i2400m_hard_start_xmit(), references are taken there
-	 * and here we release them if the work was still
-	 * pending. Note we can't differentiate work not pending vs
-	 * never scheduled, so the NULL check does that. */
-	if (cancel_work_sync(&i2400m->wake_tx_ws) == 0
-	    && i2400m->wake_tx_skb != NULL) {
-		unsigned long flags;
-		struct sk_buff *wake_tx_skb;
-		spin_lock_irqsave(&i2400m->tx_lock, flags);
-		wake_tx_skb = i2400m->wake_tx_skb;	/* compat help */
-		i2400m->wake_tx_skb = NULL;	/* compat help */
-		spin_unlock_irqrestore(&i2400m->tx_lock, flags);
-		i2400m_put(i2400m);
-		kfree_skb(wake_tx_skb);
-	}
+	i2400m_net_wake_stop(i2400m);
 	d_fnend(3, dev, "(net_dev %p [i2400m %p]) = 0\n", net_dev, i2400m);
 	return 0;
 }
@@ -230,6 +211,38 @@ void i2400m_tx_prep_header(struct sk_buff *skb)
 }
 
 
+
+/*
+ * Cleanup resources acquired during i2400m_net_wake_tx()
+ *
+ * This is called by __i2400m_dev_stop and means we have to make sure
+ * the workqueue is flushed from any pending work.
+ */
+void i2400m_net_wake_stop(struct i2400m *i2400m)
+{
+	struct device *dev = i2400m_dev(i2400m);
+
+	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
+	/* See i2400m_hard_start_xmit(), references are taken there
+	 * and here we release them if the work was still
+	 * pending. Note we can't differentiate work not pending vs
+	 * never scheduled, so the NULL check does that. */
+	if (cancel_work_sync(&i2400m->wake_tx_ws) == 0
+	    && i2400m->wake_tx_skb != NULL) {
+		unsigned long flags;
+		struct sk_buff *wake_tx_skb;
+		spin_lock_irqsave(&i2400m->tx_lock, flags);
+		wake_tx_skb = i2400m->wake_tx_skb;	/* compat help */
+		i2400m->wake_tx_skb = NULL;	/* compat help */
+		spin_unlock_irqrestore(&i2400m->tx_lock, flags);
+		i2400m_put(i2400m);
+		kfree_skb(wake_tx_skb);
+	}
+	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
+	return;
+}
+
+
 /*
  * TX an skb to an idle device
  *
-- 
1.6.2.5

