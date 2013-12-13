From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 06/12] bna: RX Processing and Config Changes
Date: Thu, 12 Dec 2013 17:54:32 -0800
Message-ID: <1386899678-18591-7-git-send-email-rmody@brocade.com>
References: <1386899678-18591-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:30731 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784Ab3LMBzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 20:55:24 -0500
In-Reply-To: <1386899678-18591-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
 - Prefetch header in GRO path. This reduces napi_frags_skb time from 9% to 5%.
 - Changed the configurable limit of RxQ depth to 16384 (was 2048).
 - bnad_rx_unmap_q elements are cachealigned.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 5 +++++
 drivers/net/ethernet/brocade/bna/bnad.h | 6 +++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index f47d157..57f43cc 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -536,6 +536,11 @@ bnad_cq_setup_skb_frags(struct bna_rcb *rcb, struct sk_buff *skb,
 
 	unmap_q = rcb->unmap_q;
 	bnad = rcb->bnad;
+
+	/* prefetch header */
+	prefetch(page_address(unmap_q->unmap[sop_ci].page) +
+			unmap_q->unmap[sop_ci].page_offset);
+
 	for (vec = 1, ci = sop_ci; vec <= nvecs; vec++) {
 		unmap = &unmap_q->unmap[ci];
 		BNA_QE_INDX_INC(ci, rcb->q_depth);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 8584ee4..3cdc88e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -84,7 +84,7 @@ struct bnad_rx_ctrl {
 #define BNAD_IOCETH_TIMEOUT	     10000
 
 #define BNAD_MIN_Q_DEPTH		512
-#define BNAD_MAX_RXQ_DEPTH		2048
+#define BNAD_MAX_RXQ_DEPTH		16384
 #define BNAD_MAX_TXQ_DEPTH		2048
 
 #define BNAD_JUMBO_MTU			9000
@@ -237,9 +237,9 @@ struct bnad_rx_vector {
 
 struct bnad_rx_unmap {
 	struct page		*page;
-	u32			page_offset;
 	struct sk_buff		*skb;
 	struct bnad_rx_vector	vector;
+	u32			page_offset;
 };
 
 enum bnad_rxbuf_type {
@@ -257,7 +257,7 @@ struct bnad_rx_unmap_q {
 	int			alloc_order;
 	u32			map_size;
 	enum bnad_rxbuf_type	type;
-	struct bnad_rx_unmap	unmap[0];
+	struct bnad_rx_unmap	unmap[0] ____cacheline_aligned;
 };
 
 #define BNAD_PCI_DEV_IS_CAT2(_bnad) \
-- 
1.8.2.3
