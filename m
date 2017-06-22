From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next 1/3] net: mvpp2: add comments about smp_processor_id() usage
Date: Thu, 22 Jun 2017 14:23:18 +0200
Message-ID: <20170622122320.32676-2-thomas.petazzoni@free-electrons.com>
References: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:38153 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751149AbdFVMXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 08:23:38 -0400
In-Reply-To: <20170622122320.32676-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous commit modified a number of smp_processor_id() used in
migration-enabled contexts into get_cpu/put_cpu sections. However, a few
smp_processor_id() calls remain in the driver, and this commit adds
comments explaining why they can be kept.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 33 +++++++++++++++++++++++++++++----
 1 file changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index ca4b55c..4b3bf37 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4162,7 +4162,10 @@ static inline void mvpp2_interrupts_disable(struct mvpp2_port *port)
 		    MVPP2_ISR_DISABLE_INTERRUPT(cpu_mask));
 }
 
-/* Mask the current CPU's Rx/Tx interrupts */
+/* Mask the current CPU's Rx/Tx interrupts
+ * Called by on_each_cpu(), guaranteed to run with migration disabled,
+ * using smp_processor_id() is OK.
+ */
 static void mvpp2_interrupts_mask(void *arg)
 {
 	struct mvpp2_port *port = arg;
@@ -4171,7 +4174,10 @@ static void mvpp2_interrupts_mask(void *arg)
 			   MVPP2_ISR_RX_TX_MASK_REG(port->id), 0);
 }
 
-/* Unmask the current CPU's Rx/Tx interrupts */
+/* Unmask the current CPU's Rx/Tx interrupts.
+ * Called by on_each_cpu(), guaranteed to run with migration disabled,
+ * using smp_processor_id() is OK.
+ */
 static void mvpp2_interrupts_unmask(void *arg)
 {
 	struct mvpp2_port *port = arg;
@@ -4554,7 +4560,11 @@ mvpp2_txq_next_desc_get(struct mvpp2_tx_queue *txq)
 	return txq->descs + tx_desc;
 }
 
-/* Update HW with number of aggregated Tx descriptors to be sent */
+/* Update HW with number of aggregated Tx descriptors to be sent
+ *
+ * Called only from mvpp2_tx(), so migration is disabled, using
+ * smp_processor_id() is OK.
+ */
 static void mvpp2_aggr_txq_pend_desc_add(struct mvpp2_port *port, int pending)
 {
 	/* aggregated access - relevant TXQ number is written in TX desc */
@@ -4565,6 +4575,9 @@ static void mvpp2_aggr_txq_pend_desc_add(struct mvpp2_port *port, int pending)
 
 /* Check if there are enough free descriptors in aggregated txq.
  * If not, update the number of occupied descriptors and repeat the check.
+ *
+ * Called only from mvpp2_tx(), so migration is disabled, using
+ * smp_processor_id() is OK.
  */
 static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
 				     struct mvpp2_tx_queue *aggr_txq, int num)
@@ -4583,7 +4596,12 @@ static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
 	return 0;
 }
 
-/* Reserved Tx descriptors allocation request */
+/* Reserved Tx descriptors allocation request
+ *
+ * Called only from mvpp2_txq_reserved_desc_num_proc(), itself called
+ * only by mvpp2_tx(), so migration is disabled, using
+ * smp_processor_id() is OK.
+ */
 static int mvpp2_txq_alloc_reserved_desc(struct mvpp2 *priv,
 					 struct mvpp2_tx_queue *txq, int num)
 {
@@ -4687,6 +4705,10 @@ static u32 mvpp2_txq_desc_csum(int l3_offs, int l3_proto,
 /* Get number of sent descriptors and decrement counter.
  * The number of sent descriptors is returned.
  * Per-CPU access
+ *
+ * Called only from mvpp2_txq_done(), called from mvpp2_tx()
+ * (migration disabled) and from the TX completion tasklet (migration
+ * disabled) so using smp_processor_id() is OK.
  */
 static inline int mvpp2_txq_sent_desc_proc(struct mvpp2_port *port,
 					   struct mvpp2_tx_queue *txq)
@@ -4701,6 +4723,9 @@ static inline int mvpp2_txq_sent_desc_proc(struct mvpp2_port *port,
 		MVPP2_TRANSMITTED_COUNT_OFFSET;
 }
 
+/* Called through on_each_cpu(), so runs on all CPUs, with migration
+ * disabled, therefore using smp_processor_id() is OK.
+ */
 static void mvpp2_txq_sent_counter_clear(void *arg)
 {
 	struct mvpp2_port *port = arg;
-- 
2.9.4
