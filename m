From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4/cxgb4vf: Updated the LSO transfer length in CPL_TX_PKT_LSO for T5
Date: Thu,  9 Oct 2014 05:48:45 +0530
Message-ID: <1412813927-24951-2-git-send-email-hariprasad@chelsio.com>
References: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59657
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755199AbaJIAOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:14:32 -0400
In-Reply-To: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the lso length for T5 adapter and fix PIDX_T5 macro

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c     |    5 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h  |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h |    5 ++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c   |    5 ++++-
 4 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index fab4c84..5e1b314 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1123,7 +1123,10 @@ out_free:	dev_kfree_skb_any(skb);
 		lso->c.ipid_ofst = htons(0);
 		lso->c.mss = htons(ssi->gso_size);
 		lso->c.seqno_offset = htonl(0);
-		lso->c.len = htonl(skb->len);
+		if (is_t4(adap->params.chip))
+			lso->c.len = htonl(skb->len);
+		else
+			lso->c.len = htonl(LSO_T5_XFER_SIZE(skb->len));
 		cpl = (void *)(lso + 1);
 		cntrl = TXPKT_CSUM_TYPE(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
 			TXPKT_IPHDR_LEN(l3hdr_len) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 52e0810..5f4db23 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -527,6 +527,7 @@ struct cpl_tx_pkt_lso_core {
 #define LSO_LAST_SLICE    (1 << 22)
 #define LSO_FIRST_SLICE   (1 << 23)
 #define LSO_OPCODE(x)     ((x) << 24)
+#define LSO_T5_XFER_SIZE(x) ((x) << 0)
 	__be16 ipid_ofst;
 	__be16 mss;
 	__be32 seqno_offset;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index eee2728..a1024db 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -72,9 +72,8 @@
 #define  PIDX_MASK   0x00003fffU
 #define  PIDX_SHIFT  0
 #define  PIDX(x)     ((x) << PIDX_SHIFT)
-#define  S_PIDX_T5   0
-#define  M_PIDX_T5   0x1fffU
-#define  PIDX_T5(x)  (((x) >> S_PIDX_T5) & M_PIDX_T5)
+#define  PIDX_SHIFT_T5   0
+#define  PIDX_T5(x)  ((x) << PIDX_SHIFT_T5)
 
 
 #define SGE_TIMERREGS	6
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index a5fb949..85036e6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -1208,7 +1208,10 @@ int t4vf_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		lso->ipid_ofst = cpu_to_be16(0);
 		lso->mss = cpu_to_be16(ssi->gso_size);
 		lso->seqno_offset = cpu_to_be32(0);
-		lso->len = cpu_to_be32(skb->len);
+		if (is_t4(adapter->params.chip))
+			lso->len = cpu_to_be32(skb->len);
+		else
+			lso->len = cpu_to_be32(LSO_T5_XFER_SIZE(skb->len));
 
 		/*
 		 * Set up TX Packet CPL pointer, control word and perform
-- 
1.7.1
