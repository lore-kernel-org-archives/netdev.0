From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 02/34]bnx2x: Barriers for the compiler
Date: Wed, 14 Jan 2009 18:42:44 +0200
Message-ID: <1231951364.11301.123.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2391 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761923AbZANQni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make sure no swapping are made by the compiler, changed HAS_WORK to inline
functions and added all the necessary barriers

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    9 +--------
 drivers/net/bnx2x_main.c |   37 ++++++++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 96a8889..e5346d8 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -268,14 +268,7 @@ struct bnx2x_fastpath {
 
 #define bnx2x_fp(bp, nr, var)		(bp->fp[nr].var)
 
-#define BNX2X_HAS_TX_WORK(fp) \
-			((fp->tx_pkt_prod != le16_to_cpu(*fp->tx_cons_sb)) || \
-			 (fp->tx_pkt_prod != fp->tx_pkt_cons))
-
-#define BNX2X_HAS_RX_WORK(fp) \
-			(fp->rx_comp_cons != rx_cons_sb)
-
-#define BNX2X_HAS_WORK(fp)	(BNX2X_HAS_RX_WORK(fp) || BNX2X_HAS_TX_WORK(fp))
+#define BNX2X_HAS_WORK(fp)	(bnx2x_has_rx_work(fp) || bnx2x_has_tx_work(fp))
 
 
 /* MC hsi */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index cc6ffba..b8bc1a5 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -735,6 +735,17 @@ static u16 bnx2x_ack_int(struct bnx2x *bp)
  * fast path service functions
  */
 
+static inline int bnx2x_has_tx_work(struct bnx2x_fastpath *fp)
+{
+	u16 tx_cons_sb;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	tx_cons_sb = le16_to_cpu(*fp->tx_cons_sb);
+	return ((fp->tx_pkt_prod != tx_cons_sb) ||
+		(fp->tx_pkt_prod != fp->tx_pkt_cons));
+}
+
 /* free skb in the packet ring at pos idx
  * return idx of last bd freed
  */
@@ -6665,7 +6676,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 		cnt = 1000;
 		smp_rmb();
-		while (BNX2X_HAS_TX_WORK(fp)) {
+		while (bnx2x_has_tx_work(fp)) {
 
 			bnx2x_tx_int(fp, 1000);
 			if (!cnt) {
@@ -9245,6 +9256,18 @@ static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state)
 	return 0;
 }
 
+static inline int bnx2x_has_rx_work(struct bnx2x_fastpath *fp)
+{
+	u16 rx_cons_sb;
+
+	/* Tell compiler that status block fields can change */
+	barrier();
+	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
+	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
+		rx_cons_sb++;
+	return (fp->rx_comp_cons != rx_cons_sb);
+}
+
 /*
  * net_device service functions
  */
@@ -9255,7 +9278,6 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 						 napi);
 	struct bnx2x *bp = fp->bp;
 	int work_done = 0;
-	u16 rx_cons_sb;
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -9268,19 +9290,12 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 
 	bnx2x_update_fpsb_idx(fp);
 
-	if (BNX2X_HAS_TX_WORK(fp))
+	if (bnx2x_has_tx_work(fp))
 		bnx2x_tx_int(fp, budget);
 
-	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
-	if (BNX2X_HAS_RX_WORK(fp))
+	if (bnx2x_has_rx_work(fp))
 		work_done = bnx2x_rx_int(fp, budget);
-
 	rmb(); /* BNX2X_HAS_WORK() reads the status block */
-	rx_cons_sb = le16_to_cpu(*fp->rx_cons_sb);
-	if ((rx_cons_sb & MAX_RCQ_DESC_CNT) == MAX_RCQ_DESC_CNT)
-		rx_cons_sb++;
 
 	/* must not complete if we consumed full budget */
 	if ((work_done < budget) && !BNX2X_HAS_WORK(fp)) {
-- 
1.5.4.3




