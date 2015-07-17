From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4 : Fill DCB priority in vlan control headers
Date: Fri, 17 Jul 2015 13:12:33 -0700
Message-ID: <1437163953-15447-5-git-send-email-anish@chelsio.com>
References: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31925 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751901AbbGQUMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:12:41 -0400
In-Reply-To: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c    | 14 ++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h |  3 +++
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 942db078f33a..d4248d74f560 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1137,7 +1137,7 @@ cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
  */
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	u32 wr_mid;
+	u32 wr_mid, ctrl0;
 	u64 cntrl, *end;
 	int qidx, credits;
 	unsigned int flits, ndesc;
@@ -1274,9 +1274,15 @@ out_free:	dev_kfree_skb_any(skb);
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 	}
 
-	cpl->ctrl0 = htonl(TXPKT_OPCODE_V(CPL_TX_PKT_XT) |
-			   TXPKT_INTF_V(pi->tx_chan) |
-			   TXPKT_PF_V(adap->pf));
+	ctrl0 = TXPKT_OPCODE_V(CPL_TX_PKT_XT) | TXPKT_INTF_V(pi->tx_chan) |
+		TXPKT_PF_V(adap->pf);
+#ifdef CONFIG_CHELSIO_T4_DCB
+	if (is_t4(adap->params.chip))
+		ctrl0 |= TXPKT_OVLAN_IDX_V(q->dcb_prio);
+	else
+		ctrl0 |= TXPKT_T5_OVLAN_IDX_V(q->dcb_prio);
+#endif
+	cpl->ctrl0 = htonl(ctrl0);
 	cpl->pack = htons(0);
 	cpl->len = htons(skb->len);
 	cpl->ctrl1 = cpu_to_be64(cntrl);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 132cb8fc0bf7..b99144afd4ec 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -660,6 +660,9 @@ struct cpl_tx_pkt {
 #define TXPKT_OVLAN_IDX_S    12
 #define TXPKT_OVLAN_IDX_V(x) ((x) << TXPKT_OVLAN_IDX_S)
 
+#define TXPKT_T5_OVLAN_IDX_S	12
+#define TXPKT_T5_OVLAN_IDX_V(x)	((x) << TXPKT_T5_OVLAN_IDX_S)
+
 #define TXPKT_INTF_S    16
 #define TXPKT_INTF_V(x) ((x) << TXPKT_INTF_S)
 
-- 
2.4.6
