From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 04/12] bnx2x: Add additional debug information
Date: Wed, 23 Jan 2013 15:21:46 +0200
Message-ID: <1358947314-3851-5-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1794 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755891Ab3AWOWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:22:19 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add/Revise several debug prints in the bnx2x driver - on regular flows
as well as error flows.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c     |  7 +++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |  4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 21 +++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      | 12 ++++++++++--
 4 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index e8f2700..58f491e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3486,9 +3486,10 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	DP(NETIF_MSG_TX_QUEUED,
-	   "queue[%d]: SKB: summed %x  protocol %x protocol(%x,%x) gso type %x  xmit_type %x\n",
+	   "queue[%d]: SKB: summed %x  protocol %x protocol(%x,%x) gso type %x  xmit_type %x len %d\n",
 	   txq_index, skb->ip_summed, skb->protocol, ipv6_hdr(skb)->nexthdr,
-	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type);
+	   ip_hdr(skb)->protocol, skb_shinfo(skb)->gso_type, xmit_type,
+	   skb->len);
 
 	eth = (struct ethhdr *)skb->data;
 
@@ -4078,6 +4079,8 @@ static int bnx2x_alloc_fp_mem_at(struct bnx2x *bp, int index)
 	} else /* if rx_ring_size specified - use it */
 		rx_ring_size = bp->rx_ring_size;
 
+	DP(BNX2X_MSG_SP, "calculated rx_ring_size %d\n", rx_ring_size);
+
 	/* Common */
 	sb = &bnx2x_fp(bp, index, status_blk);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index f949540..9a674b1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1731,6 +1731,10 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	DP(BNX2X_MSG_ETHTOOL,
+	   "set ring params command parameters: rx_pending = %d, tx_pending = %d\n",
+	   ering->rx_pending, ering->tx_pending);
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		DP(BNX2X_MSG_ETHTOOL,
 		   "Handling parity error recovery. Try again later\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e496f19..c9effad 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1027,6 +1027,17 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 	}
 
 #ifdef BNX2X_STOP_ON_ERROR
+
+	/* event queue */
+	for (i = 0; i < NUM_EQ_DESC; i++) {
+		u32 *data = (u32 *)&bp->eq_ring[i].message.data;
+
+		BNX2X_ERR("event queue [%d]: header: opcode %d, error %d\n",
+			  i, bp->eq_ring[i].message.opcode,
+			  bp->eq_ring[i].message.error);
+		BNX2X_ERR("data: %x %x %x\n", data[0], data[1], data[2]);
+	}
+
 	/* Rings */
 	/* Rx */
 	for_each_valid_rx_queue(bp, i) {
@@ -7395,8 +7406,10 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	/* FLR cleanup - hmmm */
 	if (!CHIP_IS_E1x(bp)) {
 		rc = bnx2x_pf_flr_clnup(bp);
-		if (rc)
+		if (rc) {
+			bnx2x_fw_dump(bp);
 			return rc;
+		}
 	}
 
 	/* set MSI reconfigure capability */
@@ -9782,6 +9795,8 @@ static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 	if (bnx2x_prev_is_path_marked(bp))
 		return bnx2x_prev_mcp_done(bp);
 
+	BNX2X_DEV_INFO("Path is unmarked\n");
+
 	/* If function has FLR capabilities, and existing FW version matches
 	 * the one required, then FLR will be sufficient to clean any residue
 	 * left by previous driver
@@ -9917,7 +9932,8 @@ static void bnx2x_prev_interrupted_dmae(struct bnx2x *bp)
 	if (!CHIP_IS_E1x(bp)) {
 		u32 val = REG_RD(bp, PGLUE_B_REG_PGLUE_B_INT_STS);
 		if (val & PGLUE_B_PGLUE_B_INT_STS_REG_WAS_ERROR_ATTN) {
-			BNX2X_ERR("was error bit was found to be set in pglueb upon startup. Clearing");
+			DP(BNX2X_MSG_SP,
+			   "'was error' bit was found to be set in pglueb upon startup. Clearing\n");
 			REG_WR(bp, PGLUE_B_REG_WAS_ERROR_PF_7_0_CLR,
 			       1 << BP_FUNC(bp));
 		}
@@ -12488,6 +12504,7 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 		dev_err(&pdev->dev, "Cannot set interrupts\n");
 		goto init_one_exit;
 	}
+	BNX2X_DEV_INFO("set interrupts successfully\n");
 
 	/* register the net device */
 	rc = register_netdev(dev);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 4a28601..7d6d601 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4241,11 +4241,16 @@ int bnx2x_queue_state_change(struct bnx2x *bp,
 	unsigned long *pending = &o->pending;
 
 	/* Check that the requested transition is legal */
-	if (o->check_transition(bp, o, params))
+	rc = o->check_transition(bp, o, params);
+	if (rc) {
+		BNX2X_ERR("check transition returned an error. rc %d\n", rc);
 		return -EINVAL;
+	}
 
 	/* Set "pending" bit */
+	DP(BNX2X_MSG_SP, "pending bit was=%lx\n", o->pending);
 	pending_bit = o->set_pending(o, params);
+	DP(BNX2X_MSG_SP, "pending bit now=%lx\n", o->pending);
 
 	/* Don't send a command if only driver cleanup was requested */
 	if (test_bit(RAMROD_DRV_CLR_ONLY, &params->ramrod_flags))
@@ -5029,8 +5034,11 @@ static int bnx2x_queue_chk_transition(struct bnx2x *bp,
 	 * Don't allow a next state transition if we are in the middle of
 	 * the previous one.
 	 */
-	if (o->pending)
+	if (o->pending) {
+		BNX2X_ERR("Blocking transition since pending was %lx\n",
+			  o->pending);
 		return -EBUSY;
+	}
 
 	switch (state) {
 	case BNX2X_Q_STATE_RESET:
-- 
1.8.1.227.g44fe835
