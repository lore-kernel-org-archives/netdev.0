From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 1/2][net-next] gianfar: Fix Tx csum generation errata handling
Date: Mon, 5 Aug 2013 17:20:09 +0300
Message-ID: <1375712410-11760-2-git-send-email-claudiu.manoil@freescale.com>
References: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0189.outbound.messaging.microsoft.com ([213.199.154.189]:34869
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753372Ab3HEOUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 10:20:45 -0400
In-Reply-To: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both [eTSEC76] and [eTSEC12] errata relate to Tx checksum generation
(for some MPC83xx and MCP8548 older revisions). They require the same
workaround: manual checksum computation and insertion, and disabling
the H/W Tx csum acceleration feature (per frame) through Tx FCB
(Frame Control Block) csum offload settings.

The workaround for [eTSEC76] needs to be fixed because it currently
fails to disable H/W Tx csum insertion via FCB. This patch fixes it
and provides a common workaround implementation for both Tx csum errata.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 44 ++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 0f05b96..3a543f7 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2054,6 +2054,24 @@ static inline struct txbd8 *next_txbd(struct txbd8 *bdp, struct txbd8 *base,
 	return skip_txbd(bdp, 1, base, ring_size);
 }
 
+/* eTSEC12: csum generation not supported for some fcb offsets */
+static inline bool gfar_csum_errata_12(struct gfar_private *priv,
+				       unsigned long fcb_addr)
+{
+	return (gfar_has_errata(priv, GFAR_ERRATA_12) &&
+	       (fcb_addr % 0x20) > 0x18);
+}
+
+/* eTSEC76: csum generation for frames larger than 2500 may
+ * cause excess delays before start of transmission
+ */
+static inline bool gfar_csum_errata_76(struct gfar_private *priv,
+				       unsigned int len)
+{
+	return (gfar_has_errata(priv, GFAR_ERRATA_76) &&
+	       (len > 2500));
+}
+
 /* This is called by the kernel when a frame is ready for transmission.
  * It is pointed to by the dev->hard_start_xmit function pointer
  */
@@ -2071,19 +2089,6 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	unsigned int nr_frags, nr_txbds, length, fcb_length = GMAC_FCB_LEN;
 
-	/* TOE=1 frames larger than 2500 bytes may see excess delays
-	 * before start of transmission.
-	 */
-	if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_76) &&
-		     skb->ip_summed == CHECKSUM_PARTIAL &&
-		     skb->len > 2500)) {
-		int ret;
-
-		ret = skb_checksum_help(skb);
-		if (ret)
-			return ret;
-	}
-
 	rq = skb->queue_mapping;
 	tx_queue = priv->tx_queue[rq];
 	txq = netdev_get_tx_queue(dev, rq);
@@ -2190,14 +2195,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
 		fcb = gfar_add_fcb(skb);
-		/* as specified by errata */
-		if (unlikely(gfar_has_errata(priv, GFAR_ERRATA_12) &&
-			     ((unsigned long)fcb % 0x20) > 0x18)) {
+		lstatus |= BD_LFLAG(TXBD_TOE);
+		gfar_tx_checksum(skb, fcb, fcb_length);
+
+		if (unlikely(gfar_csum_errata_12(priv, (unsigned long)fcb)) ||
+		    unlikely(gfar_csum_errata_76(priv, skb->len))) {
 			__skb_pull(skb, GMAC_FCB_LEN);
 			skb_checksum_help(skb);
-		} else {
-			lstatus |= BD_LFLAG(TXBD_TOE);
-			gfar_tx_checksum(skb, fcb, fcb_length);
+			lstatus &= ~(BD_LFLAG(TXBD_TOE));
+			fcb = NULL;
 		}
 	}
 
-- 
1.7.11.7
