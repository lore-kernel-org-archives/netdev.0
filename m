From: prasanna.panchamukhi@riverbed.com
Subject: [PATCH] e1000: fix race condition while driver unload/reset using kref count
Date: Wed,  2 Mar 2011 10:46:37 -0800
Message-ID: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	prasanna.panchamukhi@riverbed.com
To: bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, jeffrey.e.pieper@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([208.70.196.45]:64803 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab1CBSrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:47:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This race conditions occurs with reentrant e1000_down(), which gets
called by multiple threads while driver unload or reset.
This patch fixes the race condition when one thread tries to destroy
the memory allocated for tx buffer_info, while another thread still
happen to access tx buffer_info.
This patch fixes the above race condition using kref count.

Signed-off-by: Prasanna S. Panchamukhi <prasanna.panchamukhi@riverbed.com>
---
 drivers/net/e1000/e1000.h      |    2 +
 drivers/net/e1000/e1000_main.c |   41 +++++++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a881dd0..36f55b3 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -168,6 +168,8 @@ struct e1000_tx_ring {
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
+	spinlock_t bufinfo_lock; /* protect access to buffer_info */
+	struct kref bufinfo_refcount; /* refcount access to buffer info */
 
 	u16 tdh;
 	u16 tdt;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index beec573..336d3e1 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1531,6 +1531,8 @@ setup_tx_desc_die:
 
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
+	spin_lock_init(&txdr->bufinfo_lock);
+	kref_init(&txdr->bufinfo_refcount);
 
 	return 0;
 }
@@ -1880,6 +1882,22 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	ew32(RCTL, rctl);
 }
 
+/*
+ * Free tx buffer info resources, only when no other thread is
+ * accessing it. Access to buffer_info is refcounted by bufinfo_refcount,
+ * hence memory allocated must be destroyed when bufinfo_refcount
+ * becomes zero. This routine gets executed when bufinfo_refcount
+ * becomes zero.
+ */
+static void e1000_free_tx_buffer_info(struct kref *ref)
+{
+	struct e1000_tx_ring *tx_ring =
+		container_of(ref, struct e1000_tx_ring, bufinfo_refcount);
+
+	vfree(tx_ring->buffer_info);
+	tx_ring->buffer_info = NULL;
+}
+
 /**
  * e1000_free_tx_resources - Free Tx Resources per Queue
  * @adapter: board private structure
@@ -1895,8 +1913,9 @@ static void e1000_free_tx_resources(struct e1000_adapter *adapter,
 
 	e1000_clean_tx_ring(adapter, tx_ring);
 
-	vfree(tx_ring->buffer_info);
-	tx_ring->buffer_info = NULL;
+	spin_lock(&tx_ring->bufinfo_lock);
+	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
+	spin_unlock(&tx_ring->bufinfo_lock);
 
 	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
 			  tx_ring->dma);
@@ -1954,8 +1973,20 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
-	/* Free all the Tx ring sk_buffs */
+	spin_lock(&tx_ring->bufinfo_lock);
+	/*
+	 * Check buffer_info is not NULL, and
+	 * increment the refcount to prevent
+	 * the buffer getting freed underneath.
+	 */
+	if (tx_ring->buffer_info == NULL) {
+		spin_unlock(&tx_ring->bufinfo_lock);
+		return;
+	}
+	kref_get(&tx_ring->bufinfo_refcount);
+	spin_unlock(&tx_ring->bufinfo_lock);
 
+	/* Free all the Tx ring sk_buffs */
 	for (i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -1968,6 +1999,10 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 
 	memset(tx_ring->desc, 0, tx_ring->size);
 
+	spin_lock(&tx_ring->bufinfo_lock);
+	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
+	spin_unlock(&tx_ring->bufinfo_lock);
+
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 	tx_ring->last_tx_tso = 0;
-- 
1.7.0.4

