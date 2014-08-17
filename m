From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/9] bnx2x: Safe bnx2x_panic_dump()
Date: Sun, 17 Aug 2014 16:47:47 +0300
Message-ID: <1408283271-16176-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32749 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751282AbaHQNsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 09:48:15 -0400
In-Reply-To: <1408283271-16176-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x panic dump spills a lot of information from the driver's
fastpath, but may be called while some of the fastpath is uninitialized.

This patch verifies that pointers are already allocated before dereferencing
them to prevent possible kernel panics.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   29 ++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 17c629a..b4b8fc3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -987,6 +987,12 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 		u32 *sb_data_p;
 		struct bnx2x_fp_txdata txdata;
 
+		if (!bp->fp)
+			break;
+
+		if (!fp->rx_cons_sb)
+			continue;
+
 		/* Rx */
 		BNX2X_ERR("fp%d: rx_bd_prod(0x%x)  rx_bd_cons(0x%x)  rx_comp_prod(0x%x)  rx_comp_cons(0x%x)  *rx_cons_sb(0x%x)\n",
 			  i, fp->rx_bd_prod, fp->rx_bd_cons,
@@ -999,7 +1005,14 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 		/* Tx */
 		for_each_cos_in_tx_queue(fp, cos)
 		{
+			if (!fp->txdata_ptr)
+				break;
+
 			txdata = *fp->txdata_ptr[cos];
+
+			if (!txdata.tx_cons_sb)
+				continue;
+
 			BNX2X_ERR("fp%d: tx_pkt_prod(0x%x)  tx_pkt_cons(0x%x)  tx_bd_prod(0x%x)  tx_bd_cons(0x%x)  *tx_cons_sb(0x%x)\n",
 				  i, txdata.tx_pkt_prod,
 				  txdata.tx_pkt_cons, txdata.tx_bd_prod,
@@ -1101,6 +1114,12 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 	for_each_valid_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
+		if (!bp->fp)
+			break;
+
+		if (!fp->rx_cons_sb)
+			continue;
+
 		start = RX_BD(le16_to_cpu(*fp->rx_cons_sb) - 10);
 		end = RX_BD(le16_to_cpu(*fp->rx_cons_sb) + 503);
 		for (j = start; j != end; j = RX_BD(j + 1)) {
@@ -1134,9 +1153,19 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 	/* Tx */
 	for_each_valid_tx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		if (!bp->fp)
+			break;
+
 		for_each_cos_in_tx_queue(fp, cos) {
 			struct bnx2x_fp_txdata *txdata = fp->txdata_ptr[cos];
 
+			if (!fp->txdata_ptr)
+				break;
+
+			if (!txdata.tx_cons_sb)
+				continue;
+
 			start = TX_BD(le16_to_cpu(*txdata->tx_cons_sb) - 10);
 			end = TX_BD(le16_to_cpu(*txdata->tx_cons_sb) + 245);
 			for (j = start; j != end; j = TX_BD(j + 1)) {
-- 
1.7.1
