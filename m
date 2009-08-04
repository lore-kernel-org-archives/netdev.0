From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [2/6] vxge: fix pktgen hangs (don't abuse skb->cb[])
Date: Tue, 4 Aug 2009 16:21:03 -0400
Message-ID: <20090804202103.GC9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33067 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbZHDUj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:59 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id BD0C82065B9F
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:21:06 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id SzBZADIwzNuJZvfV for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:21:06 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KL3md013275
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:21:04 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a case in the transmit completion code which was resulting
in pktgen hanging at the end of a run.  The cause is due to the fact that
the ->cb[] area of an skb cannot be used in a network driver's transmit
path, as that area belongs to the network protocol.  Pktgen hangs, as it
sends out the same packet multiple times, and vxge's use of this area of
the skb for a temporary list can only add the packet to the temporary list
once (while it may be on the queue many times).  The fix is to remove this
abuse of skb->cb[].  Instead, skb pointers are placed into a temporary
stack array, and then free outside of the tx lock.  This retains the smp
optimization of doing dev_kfree_skb() outside of the tx lock.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
 drivers/net/vxge/vxge-config.h  |    7 ++++-
 drivers/net/vxge/vxge-main.c    |   51 ++++++++++++++++++++------------------
 drivers/net/vxge/vxge-main.h    |    3 +-
 drivers/net/vxge/vxge-traffic.c |    7 +++--
 drivers/net/vxge/vxge-traffic.h |    2 +-
 5 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 224acea..62779a5 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -978,7 +978,9 @@ struct __vxge_hw_fifo {
 			void *txdlh,
 			enum vxge_hw_fifo_tcode t_code,
 			void *userdata,
-			void **skb_ptr);
+			struct sk_buff ***skb_ptr,
+			int nr_skb,
+			int *more);
 
 	void (*txdl_term)(
 			void *txdlh,
@@ -1779,7 +1781,8 @@ struct vxge_hw_fifo_attr {
 			void *txdlh,
 			enum vxge_hw_fifo_tcode t_code,
 			void *userdata,
-			void **skb_ptr);
+			struct sk_buff ***skb_ptr,
+			int nr_skb, int *more);
 
 	void (*txdl_term)(
 			void *txdlh,
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 7c2241c..2e4d362 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -87,22 +87,25 @@ static inline int is_vxge_card_up(struct vxgedev *vdev)
 static inline void VXGE_COMPLETE_VPATH_TX(struct vxge_fifo *fifo)
 {
 	unsigned long flags = 0;
-	struct sk_buff *skb_ptr = NULL;
-	struct sk_buff **temp, *head, *skb;
-
-	if (spin_trylock_irqsave(&fifo->tx_lock, flags)) {
-		vxge_hw_vpath_poll_tx(fifo->handle, (void **)&skb_ptr);
-		spin_unlock_irqrestore(&fifo->tx_lock, flags);
-	}
-	/* free SKBs */
-	head = skb_ptr;
-	while (head) {
-		skb = head;
-		temp = (struct sk_buff **)&skb->cb;
-		head = *temp;
-		*temp = NULL;
-		dev_kfree_skb_irq(skb);
-	}
+	struct sk_buff **skb_ptr = NULL;
+	struct sk_buff **temp;
+#define NR_SKB_COMPLETED 128
+	struct sk_buff *completed[NR_SKB_COMPLETED];
+	int more;
+
+	do {
+		more = 0;
+		skb_ptr = completed;
+
+		if (spin_trylock_irqsave(&fifo->tx_lock, flags)) {
+			vxge_hw_vpath_poll_tx(fifo->handle, &skb_ptr,
+						NR_SKB_COMPLETED, &more);
+			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+		}
+		/* free SKBs */
+		for (temp = completed; temp != skb_ptr; temp++)
+			dev_kfree_skb_irq(*temp);
+	} while (more) ;
 }
 
 static inline void VXGE_COMPLETE_ALL_TX(struct vxgedev *vdev)
@@ -600,11 +603,10 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 enum vxge_hw_status
 vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 		enum vxge_hw_fifo_tcode t_code, void *userdata,
-		void **skb_ptr)
+		struct sk_buff ***skb_ptr, int nr_skb, int *more)
 {
 	struct vxge_fifo *fifo = (struct vxge_fifo *)userdata;
-	struct sk_buff *skb, *head = NULL;
-	struct sk_buff **temp;
+	struct sk_buff *skb, **done_skb = *skb_ptr;
 	int pkt_cnt = 0;
 
 	vxge_debug_entryexit(VXGE_TRACE,
@@ -657,9 +659,12 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 		fifo->stats.tx_frms++;
 		fifo->stats.tx_bytes += skb->len;
 
-		temp = (struct sk_buff **)&skb->cb;
-		*temp = head;
-		head = skb;
+		*done_skb++ = skb;
+
+		if (--nr_skb <= 0) {
+			*more = 1;
+			break;
+		}
 
 		pkt_cnt++;
 		if (pkt_cnt > fifo->indicate_max_pkts)
@@ -668,11 +673,9 @@ vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
 	} while (vxge_hw_fifo_txdl_next_completed(fifo_hw,
 				&dtr, &t_code) == VXGE_HW_OK);
 
+	*skb_ptr = done_skb;
 	vxge_wake_tx_queue(fifo, skb);
 
-	if (skb_ptr)
-		*skb_ptr = (void *) head;
-
 	vxge_debug_entryexit(VXGE_TRACE,
 				"%s: %s:%d  Exiting...",
 				fifo->ndev->name, __func__, __LINE__);
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 18d824c..8b3989b 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -428,7 +428,8 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 
 enum vxge_hw_status
 vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
-	enum vxge_hw_fifo_tcode t_code, void *userdata, void **skb_ptr);
+	enum vxge_hw_fifo_tcode t_code, void *userdata,
+	struct sk_buff ***skb_ptr, int nr_skbs, int *more);
 
 int vxge_close(struct net_device *dev);
 
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 370f55c..c249cd2 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -2508,7 +2508,8 @@ enum vxge_hw_status vxge_hw_vpath_poll_rx(struct __vxge_hw_ring *ring)
  * See also: vxge_hw_vpath_poll_tx().
  */
 enum vxge_hw_status vxge_hw_vpath_poll_tx(struct __vxge_hw_fifo *fifo,
-					void **skb_ptr)
+					struct sk_buff ***skb_ptr, int nr_skb,
+					int *more)
 {
 	enum vxge_hw_fifo_tcode t_code;
 	void *first_txdlh;
@@ -2520,8 +2521,8 @@ enum vxge_hw_status vxge_hw_vpath_poll_tx(struct __vxge_hw_fifo *fifo,
 	status = vxge_hw_fifo_txdl_next_completed(fifo,
 				&first_txdlh, &t_code);
 	if (status == VXGE_HW_OK)
-		if (fifo->callback(fifo, first_txdlh,
-			t_code, channel->userdata, skb_ptr) != VXGE_HW_OK)
+		if (fifo->callback(fifo, first_txdlh, t_code,
+			channel->userdata, skb_ptr, nr_skb, more) != VXGE_HW_OK)
 			status = VXGE_HW_COMPLETIONS_REMAIN;
 
 	return status;
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 8260b91..461742b 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -2326,7 +2326,7 @@ enum vxge_hw_status vxge_hw_vpath_poll_rx(
 
 enum vxge_hw_status vxge_hw_vpath_poll_tx(
 	struct __vxge_hw_fifo *fifoh,
-	void **skb_ptr);
+	struct sk_buff ***skb_ptr, int nr_skb, int *more);
 
 enum vxge_hw_status vxge_hw_vpath_alarm_process(
 	struct __vxge_hw_vpath_handle *vpath_handle,
-- 
1.6.0.6
