From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 08/13] net: mvneta: simplify access to the rx descriptor status
Date: Thu, 16 Jan 2014 08:20:14 +0100
Message-ID: <1389856819-6503-9-git-send-email-w@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55488 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751996AbaAPHUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:20:48 -0500
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At several places, we already know the value of the rx status but
we call functions which dereference the pointer again to get it
and don't need the descriptor for anything else. Simplify this
task by replacing the rx desc pointer by the status word itself.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Tested-by: Arnaud Ebalard <arno@natisbad.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index eccafd1..aa3a4f7 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -528,14 +528,14 @@ struct rtnl_link_stats64 *mvneta_get_stats64(struct net_device *dev,
 
 /* Rx descriptors helper methods */
 
-/* Checks whether the given RX descriptor is both the first and the
- * last descriptor for the RX packet. Each RX packet is currently
+/* Checks whether the RX descriptor having this status is both the first
+ * and the last descriptor for the RX packet. Each RX packet is currently
  * received through a single RX descriptor, so not having each RX
  * descriptor with its first and last bits set is an error
  */
-static int mvneta_rxq_desc_is_first_last(struct mvneta_rx_desc *desc)
+static int mvneta_rxq_desc_is_first_last(u32 status)
 {
-	return (desc->status & MVNETA_RXD_FIRST_LAST_DESC) ==
+	return (status & MVNETA_RXD_FIRST_LAST_DESC) ==
 		MVNETA_RXD_FIRST_LAST_DESC;
 }
 
@@ -1234,10 +1234,10 @@ static void mvneta_rx_error(struct mvneta_port *pp,
 {
 	u32 status = rx_desc->status;
 
-	if (!mvneta_rxq_desc_is_first_last(rx_desc)) {
+	if (!mvneta_rxq_desc_is_first_last(status)) {
 		netdev_err(pp->dev,
 			   "bad rx status %08x (buffer oversize), size=%d\n",
-			   rx_desc->status, rx_desc->data_size);
+			   status, rx_desc->data_size);
 		return;
 	}
 
@@ -1261,13 +1261,12 @@ static void mvneta_rx_error(struct mvneta_port *pp,
 	}
 }
 
-/* Handle RX checksum offload */
-static void mvneta_rx_csum(struct mvneta_port *pp,
-			   struct mvneta_rx_desc *rx_desc,
+/* Handle RX checksum offload based on the descriptor's status */
+static void mvneta_rx_csum(struct mvneta_port *pp, u32 status,
 			   struct sk_buff *skb)
 {
-	if ((rx_desc->status & MVNETA_RXD_L3_IP4) &&
-	    (rx_desc->status & MVNETA_RXD_L4_CSUM_OK)) {
+	if ((status & MVNETA_RXD_L3_IP4) &&
+	    (status & MVNETA_RXD_L4_CSUM_OK)) {
 		skb->csum = 0;
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		return;
@@ -1449,7 +1448,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		rx_status = rx_desc->status;
 		skb = (struct sk_buff *)rx_desc->buf_cookie;
 
-		if (!mvneta_rxq_desc_is_first_last(rx_desc) ||
+		if (!mvneta_rxq_desc_is_first_last(rx_status) ||
 		    (rx_status & MVNETA_RXD_ERR_SUMMARY)) {
 			dev->stats.rx_errors++;
 			mvneta_rx_error(pp, rx_desc);
@@ -1472,7 +1471,7 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 
 		skb->protocol = eth_type_trans(skb, dev);
 
-		mvneta_rx_csum(pp, rx_desc, skb);
+		mvneta_rx_csum(pp, rx_status, skb);
 
 		napi_gro_receive(&pp->napi, skb);
 
-- 
1.7.12.2.21.g234cd45.dirty
