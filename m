From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 3/5] net: mvpp2: add comments about smp_processor_id() usage
Date: Thu,  8 Jun 2017 17:27:25 +0200
Message-ID: <1496935647-29670-4-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Marcin Wojtas <mw@semihalf.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Marc Zyngier <marc.zyngier@arm.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34639 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdFHP2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 11:28:11 -0400
In-Reply-To: <1496935647-29670-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
index fb6e9dc..037f6bd 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4152,7 +4152,10 @@ static inline void mvpp2_interrupts_disable(struct mvpp2_port *port)
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
@@ -4161,7 +4164,10 @@ static void mvpp2_interrupts_mask(void *arg)
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
@@ -4519,7 +4525,11 @@ mvpp2_txq_next_desc_get(struct mvpp2_tx_queue *txq)
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
@@ -4530,6 +4540,9 @@ static void mvpp2_aggr_txq_pend_desc_add(struct mvpp2_port *port, int pending)
 
 /* Check if there are enough free descriptors in aggregated txq.
  * If not, update the number of occupied descriptors and repeat the check.
+ *
+ * Called only from mvpp2_tx(), so migration is disabled, using
+ * smp_processor_id() is OK.
  */
 static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
 				     struct mvpp2_tx_queue *aggr_txq, int num)
@@ -4548,7 +4561,12 @@ static int mvpp2_aggr_desc_num_check(struct mvpp2 *priv,
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
@@ -4652,6 +4670,10 @@ static u32 mvpp2_txq_desc_csum(int l3_offs, int l3_proto,
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
@@ -4666,6 +4688,9 @@ static inline int mvpp2_txq_sent_desc_proc(struct mvpp2_port *port,
 		MVPP2_TRANSMITTED_COUNT_OFFSET;
 }
 
+/* Called through on_each_cpu(), so runs on all CPUs, with migration
+ * disabled, therefore using smp_processor_id() is OK.
+ */
 static void mvpp2_txq_sent_counter_clear(void *arg)
 {
 	struct mvpp2_port *port = arg;
-- 
2.7.4
