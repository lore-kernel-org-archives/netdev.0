From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 4/5] be2net: Fix early reset of rx-completion
Date: Wed, 10 Jun 2009 17:53:28 +0530
Message-ID: <20090610122328.GA16735@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52802 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754539AbZFJMXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:23:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_rx_compl_get() must not reset(via the valid word) the rx_compl as the rx_compl is not processed yet; it must be reset after it is processed.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 5aadd71..86f70af 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -876,12 +876,19 @@ static struct be_eth_rx_compl *be_rx_compl_get(struct be_adapter *adapter)
 
 	be_dws_le_to_cpu(rxcp, sizeof(*rxcp));
 
-	rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] = 0;
-
 	queue_tail_inc(&adapter->rx_obj.cq);
 	return rxcp;
 }
 
+/* To reset the valid bit, we need to reset the whole word as
+ * when walking the queue the valid entries are little-endian
+ * and invalid entries are host endian
+ */
+static inline void be_rx_compl_reset(struct be_eth_rx_compl *rxcp)
+{
+	rxcp->dw[offsetof(struct amap_eth_rx_compl, valid) / 32] = 0;
+}
+
 static inline struct page *be_alloc_pages(u32 size)
 {
 	gfp_t alloc_flags = GFP_ATOMIC;
@@ -1013,6 +1020,7 @@ static void be_rx_q_clean(struct be_adapter *adapter)
 	/* First cleanup pending rx completions */
 	while ((rxcp = be_rx_compl_get(adapter)) != NULL) {
 		be_rx_compl_discard(adapter, rxcp);
+		be_rx_compl_reset(rxcp);
 		be_cq_notify(&adapter->ctrl, rx_cq->id, true, 1);
 	}
 
@@ -1294,6 +1302,8 @@ int be_poll_rx(struct napi_struct *napi, int budget)
 			be_rx_compl_process_lro(adapter, rxcp);
 		else
 			be_rx_compl_process(adapter, rxcp);
+
+		be_rx_compl_reset(rxcp);
 	}
 
 	lro_flush_all(&adapter->rx_obj.lro_mgr);
-- 
1.6.0.4

