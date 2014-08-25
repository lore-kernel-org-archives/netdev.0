From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/5] bnx2x: Fix stop-on-error
Date: Mon, 25 Aug 2014 17:48:30 +0300
Message-ID: <1408978113-27902-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:31857 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932559AbaHYOsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:48:50 -0400
In-Reply-To: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When STOP_ON_ERROR is set driver will not compile. Even if it did,
traffic will not pass without this patch as several fields which are
verified by FW/HW on the Tx path are not properly set.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  | 25 +++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |  2 +-
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 2388144..2f210ba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3873,12 +3873,16 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* when transmitting in a vf, start bd must hold the ethertype
 		 * for fw to enforce it
 		 */
+#ifndef BNX2X_STOP_ON_ERROR
 		if (IS_VF(bp))
+#endif
 			tx_start_bd->vlan_or_ethertype =
 				cpu_to_le16(ntohs(eth->h_proto));
+#ifndef BNX2X_STOP_ON_ERROR
 		else
 			/* used by FW for packet accounting */
 			tx_start_bd->vlan_or_ethertype = cpu_to_le16(pkt_prod);
+#endif
 	}
 
 	nbd = 2; /* start_bd + pbd + frags (updated when pages are mapped) */
@@ -3951,11 +3955,22 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 					      &pbd_e2->data.mac_addr.dst_mid,
 					      &pbd_e2->data.mac_addr.dst_lo,
 					      eth->h_dest);
-		} else if (bp->flags & TX_SWITCHING) {
-			bnx2x_set_fw_mac_addr(&pbd_e2->data.mac_addr.dst_hi,
-					      &pbd_e2->data.mac_addr.dst_mid,
-					      &pbd_e2->data.mac_addr.dst_lo,
-					      eth->h_dest);
+		} else {
+			if (bp->flags & TX_SWITCHING)
+				bnx2x_set_fw_mac_addr(
+						&pbd_e2->data.mac_addr.dst_hi,
+						&pbd_e2->data.mac_addr.dst_mid,
+						&pbd_e2->data.mac_addr.dst_lo,
+						eth->h_dest);
+#ifdef BNX2X_STOP_ON_ERROR
+			/* Enforce security is always set in Stop on Error -
+			 * source mac should be present in the parsing BD
+			 */
+			bnx2x_set_fw_mac_addr(&pbd_e2->data.mac_addr.src_hi,
+					      &pbd_e2->data.mac_addr.src_mid,
+					      &pbd_e2->data.mac_addr.src_lo,
+					      eth->h_source);
+#endif
 		}
 
 		SET_FLAG(pbd_e2_parsing_data,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a008f48..cf5b3b4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1142,7 +1142,7 @@ void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int)
 			if (!fp->txdata_ptr)
 				break;
 
-			if (!txdata.tx_cons_sb)
+			if (!txdata->tx_cons_sb)
 				continue;
 
 			start = TX_BD(le16_to_cpu(*txdata->tx_cons_sb) - 10);
-- 
1.8.3.1
