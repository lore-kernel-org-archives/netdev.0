From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/18] igb: remove unecessary q_vector
	declarations and remove itr_shift
Date: Wed, 17 Feb 2010 03:00:41 -0800
Message-ID: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:33645 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751877Ab0BQLBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:01:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change removes the use of itr_shift since a mac type call can be used
just as easily to identify the only HW that needs to have the itr shifted.

In addition it removes two unecessary declrations of a q_vector pointer from
the initialization path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    1 -
 drivers/net/igb/igb_main.c |   25 +++++++++++++------------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 83ea117..0efd285 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -176,7 +176,6 @@ struct igb_q_vector {
 
 	u16 itr_val;
 	u8 set_itr;
-	u8 itr_shift;
 	void __iomem *itr_register;
 
 	char name[IFNAMSIZ + 9];
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 4fe7b0b..677b5f5 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -504,6 +504,12 @@ static void igb_assign_vector(struct igb_q_vector *q_vector, int msix_vector)
 		BUG();
 		break;
 	}
+
+	/* add q_vector eims value to global eims_enable_mask */
+	adapter->eims_enable_mask |= q_vector->eims_value;
+
+	/* configure q_vector to set itr on first interrupt */
+	q_vector->set_itr = 1;
 }
 
 /**
@@ -561,11 +567,8 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 	adapter->eims_enable_mask |= adapter->eims_other;
 
-	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		igb_assign_vector(q_vector, vector++);
-		adapter->eims_enable_mask |= q_vector->eims_value;
-	}
+	for (i = 0; i < adapter->num_q_vectors; i++)
+		igb_assign_vector(adapter->q_vector[i], vector++);
 
 	wrfl();
 }
@@ -756,10 +759,8 @@ static int igb_alloc_q_vectors(struct igb_adapter *adapter)
 		if (!q_vector)
 			goto err_out;
 		q_vector->adapter = adapter;
-		q_vector->itr_shift = (hw->mac.type == e1000_82575) ? 16 : 0;
 		q_vector->itr_register = hw->hw_addr + E1000_EITR(0);
 		q_vector->itr_val = IGB_START_ITR;
-		q_vector->set_itr = 1;
 		netif_napi_add(adapter->netdev, &q_vector->napi, igb_poll, 64);
 		adapter->q_vector[v_idx] = q_vector;
 	}
@@ -4142,6 +4143,7 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 
 static void igb_write_itr(struct igb_q_vector *q_vector)
 {
+	struct igb_adapter *adapter = q_vector->adapter;
 	u32 itr_val = q_vector->itr_val & 0x7FFC;
 
 	if (!q_vector->set_itr)
@@ -4150,8 +4152,8 @@ static void igb_write_itr(struct igb_q_vector *q_vector)
 	if (!itr_val)
 		itr_val = 0x4;
 
-	if (q_vector->itr_shift)
-		itr_val |= itr_val << q_vector->itr_shift;
+	if (adapter->hw.mac.type == e1000_82575)
+		itr_val |= itr_val << 16;
 	else
 		itr_val |= 0x8000000;
 
@@ -4228,9 +4230,8 @@ static void igb_setup_dca(struct igb_adapter *adapter)
 	wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
 
 	for (i = 0; i < adapter->num_q_vectors; i++) {
-		struct igb_q_vector *q_vector = adapter->q_vector[i];
-		q_vector->cpu = -1;
-		igb_update_dca(q_vector);
+		adapter->q_vector[i]->cpu = -1;
+		igb_update_dca(adapter->q_vector[i]);
 	}
 }
 

