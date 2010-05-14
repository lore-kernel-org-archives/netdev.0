From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 16/25] wimax i2400m: fix race condition while accessing rx_roq by using kref count
Date: Fri, 14 May 2010 14:45:15 -0700
Message-ID: <d11a6e4495ee1fbb38b59bc88d49d050d3736929.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:32478 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932542Ab0ENVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:17 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch fixes the race condition when one thread tries to destroy
the memory allocated for rx_roq, while another thread still happen
to access rx_roq.
Such a race condition occurs when i2400m-sdio kernel module gets
unloaded, destroying the memory allocated for rx_roq while rx_roq
is accessed by i2400m_rx_edata(), as explained below:
$thread1                                $thread2
$ void i2400m_rx_edata()                $
$Access rx_roq[]                        $
$roq = &i2400m->rx_roq[ro_cin]          $
$ i2400m_roq_[reset/queue/update_ws]    $
$                                       $ void i2400m_rx_release();
$                                       $kfree(rx->roq);
$                                       $rx->roq = NULL;
$Oops! rx_roq is NULL

This patch fixes the race condition using refcount approach.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/i2400m.h |   12 +++++++--
 drivers/net/wimax/i2400m/rx.c     |   44 ++++++++++++++++++++++++++++++++----
 2 files changed, 48 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 7a9c2c5..b8c7dbf 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -412,7 +412,7 @@ struct i2400m_barker_db;
  *
  * @tx_size_max: biggest TX message sent.
  *
- * @rx_lock: spinlock to protect RX members
+ * @rx_lock: spinlock to protect RX members and rx_roq_refcount.
  *
  * @rx_pl_num: total number of payloads received
  *
@@ -436,6 +436,10 @@ struct i2400m_barker_db;
  *     delivered. Then the driver can release them to the host. See
  *     drivers/net/i2400m/rx.c for details.
  *
+ * @rx_roq_refcount: refcount rx_roq. This refcounts any access to
+ *     rx_roq thus preventing rx_roq being destroyed when rx_roq
+ *     is being accessed. rx_roq_refcount is protected by rx_lock.
+ *
  * @rx_reports: reports received from the device that couldn't be
  *     processed because the driver wasn't still ready; when ready,
  *     they are pulled from here and chewed.
@@ -597,10 +601,12 @@ struct i2400m {
 		tx_num, tx_size_acc, tx_size_min, tx_size_max;
 
 	/* RX stuff */
-	spinlock_t rx_lock;		/* protect RX state */
+	/* protect RX state and rx_roq_refcount */
+	spinlock_t rx_lock;
 	unsigned rx_pl_num, rx_pl_max, rx_pl_min,
 		rx_num, rx_size_acc, rx_size_min, rx_size_max;
-	struct i2400m_roq *rx_roq;	/* not under rx_lock! */
+	struct i2400m_roq *rx_roq;	/* access is refcounted */
+	struct kref rx_roq_refcount;	/* refcount access to rx_roq */
 	u8 src_mac_addr[ETH_HLEN];
 	struct list_head rx_reports;	/* under rx_lock! */
 	struct work_struct rx_report_ws;
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index fa2e11e..71b697f 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -917,6 +917,25 @@ void i2400m_roq_queue_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 
 
 /*
+ * This routine destroys the memory allocated for rx_roq, when no
+ * other thread is accessing it. Access to rx_roq is refcounted by
+ * rx_roq_refcount, hence memory allocated must be destroyed when
+ * rx_roq_refcount becomes zero. This routine gets executed when
+ * rx_roq_refcount becomes zero.
+ */
+void i2400m_rx_roq_destroy(struct kref *ref)
+{
+	unsigned itr;
+	struct i2400m *i2400m
+			= container_of(ref, struct i2400m, rx_roq_refcount);
+	for (itr = 0; itr < I2400M_RO_CIN + 1; itr++)
+		__skb_queue_purge(&i2400m->rx_roq[itr].queue);
+	kfree(i2400m->rx_roq[0].log);
+	kfree(i2400m->rx_roq);
+	i2400m->rx_roq = NULL;
+}
+
+/*
  * Receive and send up an extended data packet
  *
  * @i2400m: device descriptor
@@ -969,6 +988,7 @@ void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
 	unsigned ro_needed, ro_type, ro_cin, ro_sn;
 	struct i2400m_roq *roq;
 	struct i2400m_roq_data *roq_data;
+	unsigned long flags;
 
 	BUILD_BUG_ON(ETH_HLEN > sizeof(*hdr));
 
@@ -1007,7 +1027,16 @@ void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		ro_cin = (reorder >> I2400M_RO_CIN_SHIFT) & I2400M_RO_CIN;
 		ro_sn = (reorder >> I2400M_RO_SN_SHIFT) & I2400M_RO_SN;
 
+		spin_lock_irqsave(&i2400m->rx_lock, flags);
 		roq = &i2400m->rx_roq[ro_cin];
+		if (roq == NULL) {
+			kfree_skb(skb);	/* rx_roq is already destroyed */
+			spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+			goto error;
+		}
+		kref_get(&i2400m->rx_roq_refcount);
+		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+
 		roq_data = (struct i2400m_roq_data *) &skb->cb;
 		roq_data->sn = ro_sn;
 		roq_data->cs = cs;
@@ -1034,6 +1063,10 @@ void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		default:
 			dev_err(dev, "HW BUG? unknown reorder type %u\n", ro_type);
 		}
+
+		spin_lock_irqsave(&i2400m->rx_lock, flags);
+		kref_put(&i2400m->rx_roq_refcount, i2400m_rx_roq_destroy);
+		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	}
 	else
 		i2400m_net_erx(i2400m, skb, cs);
@@ -1344,6 +1377,7 @@ int i2400m_rx_setup(struct i2400m *i2400m)
 			__i2400m_roq_init(&i2400m->rx_roq[itr]);
 			i2400m->rx_roq[itr].log = &rd[itr];
 		}
+		kref_init(&i2400m->rx_roq_refcount);
 	}
 	return 0;
 
@@ -1357,12 +1391,12 @@ error_roq_alloc:
 /* Tear down the RX queue and infrastructure */
 void i2400m_rx_release(struct i2400m *i2400m)
 {
+	unsigned long flags;
+
 	if (i2400m->rx_reorder) {
-		unsigned itr;
-		for(itr = 0; itr < I2400M_RO_CIN + 1; itr++)
-			__skb_queue_purge(&i2400m->rx_roq[itr].queue);
-		kfree(i2400m->rx_roq[0].log);
-		kfree(i2400m->rx_roq);
+		spin_lock_irqsave(&i2400m->rx_lock, flags);
+		kref_put(&i2400m->rx_roq_refcount, i2400m_rx_roq_destroy);
+		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
 	}
 	/* at this point, nothing can be received... */
 	i2400m_report_hook_flush(i2400m);
-- 
1.6.6.1

