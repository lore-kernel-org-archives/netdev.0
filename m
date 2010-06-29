From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH] be2net: memory barrier fixes on IBM p7
 platform
Date: Tue, 29 Jun 2010 15:41:17 +0530
Message-ID: <20100629101117.GA2338@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:10803 "EHLO
	ubuntu.ubuntu-domain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753618Ab0F2KLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 06:11:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ibm p7 architecure seems to reorder memory accesses more
aggressively than previous ppc64 architectures. This requires memory
barriers to ensure that rx/tx doorbells are pressed only after
memory to be DMAed is written.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 ++
 drivers/net/benet/be_main.c |    9 ++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index ee1ad96..65e3260 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -25,6 +25,8 @@ static void be_mcc_notify(struct be_adapter *adapter)
 
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
 	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
+
+	wmb();
 	iowrite32(val, adapter->db + DB_MCCQ_OFFSET);
 }
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 01eb447..62484b8 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -89,6 +89,8 @@ static void be_rxq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 	u32 val = 0;
 	val |= qid & DB_RQ_RING_ID_MASK;
 	val |= posted << DB_RQ_NUM_POSTED_SHIFT;
+
+	wmb();
 	iowrite32(val, adapter->db + DB_RQ_OFFSET);
 }
 
@@ -97,6 +99,8 @@ static void be_txq_notify(struct be_adapter *adapter, u16 qid, u16 posted)
 	u32 val = 0;
 	val |= qid & DB_TXULP_RING_ID_MASK;
 	val |= (posted & DB_TXULP_NUM_POSTED_MASK) << DB_TXULP_NUM_POSTED_SHIFT;
+
+	wmb();
 	iowrite32(val, adapter->db + DB_TXULP1_OFFSET);
 }
 
@@ -972,7 +976,8 @@ static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
 
 	if (rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] == 0)
 		return NULL;
-
+	
+	rmb();
 	be_dws_le_to_cpu(rxcp, sizeof(*rxcp));
 
 	queue_tail_inc(&adapter->rx_obj.cq);
@@ -1066,6 +1071,7 @@ static struct be_eth_tx_compl *be_tx_compl_get(struct be_queue_info *tx_cq)
 	if (txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] == 0)
 		return NULL;
 
+	rmb();
 	be_dws_le_to_cpu(txcp, sizeof(*txcp));
 
 	txcp->dw[offsetof(struct amap_eth_tx_compl, valid) / 32] = 0;
@@ -1113,6 +1119,7 @@ static inline struct be_eq_entry *event_get(struct be_eq_obj *eq_obj)
 	if (!eqe->evt)
 		return NULL;
 
+	rmb();
 	eqe->evt = le32_to_cpu(eqe->evt);
 	queue_tail_inc(&eq_obj->q);
 	return eqe;
-- 
1.6.5.2

