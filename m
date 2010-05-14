From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 17/25] wimax/i2400m: fix incorrect handling of type 2 and 3 RX messages
Date: Fri, 14 May 2010 14:45:16 -0700
Message-ID: <0809a7bbe8fbcb4e899b0a3224d8461bd74987e0.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:45009 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932456Ab0ENVtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:17 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

According to Intel Wimax i3200, i5x50 and i6x60 device specification documents,
the host driver must not reset the device if the normalized sequence numbers
are greater than 1023 for type 2 and type 3 RX messages.
This patch removes the code that incorrectly used to reset the device.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/rx.c |   51 +++++++++++++++++++++--------------------
 1 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 71b697f..66f968a 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -743,12 +743,12 @@ unsigned __i2400m_roq_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 	unsigned new_nws, nsn_itr;
 
 	new_nws = __i2400m_roq_nsn(roq, sn);
-	if (unlikely(new_nws >= 1024) && d_test(1)) {
-		dev_err(dev, "SW BUG? __update_ws new_nws %u (sn %u ws %u)\n",
-			new_nws, sn, roq->ws);
-		WARN_ON(1);
-		i2400m_roq_log_dump(i2400m, roq);
-	}
+	/*
+	 * For type 2(update_window_start) rx messages, there is no
+	 * need to check if the normalized sequence number is greater 1023.
+	 * Simply insert and deliver all packets to the host up to the
+	 * window start.
+	 */
 	skb_queue_walk_safe(&roq->queue, skb_itr, tmp_itr) {
 		roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
 		nsn_itr = __i2400m_roq_nsn(roq, roq_data_itr->sn);
@@ -890,26 +890,27 @@ void i2400m_roq_queue_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
 		  i2400m, roq, skb, sn);
 	len = skb_queue_len(&roq->queue);
 	nsn = __i2400m_roq_nsn(roq, sn);
+	/*
+	 * For type 3(queue_update_window_start) rx messages, there is no
+	 * need to check if the normalized sequence number is greater 1023.
+	 * Simply insert and deliver all packets to the host up to the
+	 * window start.
+	 */
 	old_ws = roq->ws;
-	if (unlikely(nsn >= 1024)) {
-		dev_err(dev, "SW BUG? queue_update_ws nsn %u (sn %u ws %u)\n",
-			nsn, sn, roq->ws);
-		i2400m_roq_log_dump(i2400m, roq);
-		i2400m_reset(i2400m, I2400M_RT_WARM);
-	} else {
-		/* if the queue is empty, don't bother as we'd queue
-		 * it and inmediately unqueue it -- just deliver it */
-		if (len == 0) {
-			struct i2400m_roq_data *roq_data;
-			roq_data = (struct i2400m_roq_data *) &skb->cb;
-			i2400m_net_erx(i2400m, skb, roq_data->cs);
-		}
-		else
-			__i2400m_roq_queue(i2400m, roq, skb, sn, nsn);
-		__i2400m_roq_update_ws(i2400m, roq, sn + 1);
-		i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_PACKET_WS,
-				   old_ws, len, sn, nsn, roq->ws);
-	}
+	/* If the queue is empty, don't bother as we'd queue
+	 * it and immediately unqueue it -- just deliver it.
+	 */
+	if (len == 0) {
+		struct i2400m_roq_data *roq_data;
+		roq_data = (struct i2400m_roq_data *) &skb->cb;
+		i2400m_net_erx(i2400m, skb, roq_data->cs);
+	} else
+		__i2400m_roq_queue(i2400m, roq, skb, sn, nsn);
+
+	__i2400m_roq_update_ws(i2400m, roq, sn + 1);
+	i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_PACKET_WS,
+			   old_ws, len, sn, nsn, roq->ws);
+
 	d_fnend(2, dev, "(i2400m %p roq %p skb %p sn %u) = void\n",
 		i2400m, roq, skb, sn);
 	return;
-- 
1.6.6.1

