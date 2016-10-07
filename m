From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] wan/fsl_ucc_hdlc: Fix size used in dma_free_coherent()
Date: Fri,  7 Oct 2016 22:58:47 +0200
Message-ID: <1475873927-14999-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: qiang.zhao@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Size used with 'dma_alloc_coherent()' and 'dma_free_coherent()' should be
consistent.
Here, the size of a pointer is used in dma_alloc... and the size of the
pointed structure is used in dma_free...

This has been spotted with coccinelle, using the following script:
////////////////////
@r@
expression x0, x1, y0, y1, z0, z1, t0, t1, ret;
@@

*   ret = dma_alloc_coherent(x0, y0, z0, t0);
    ...
*   dma_free_coherent(x1, y1, ret, t1);


@script:python@
y0 << r.y0;
y1 << r.y1;

@@
if y1.find(y0) == -1:
 print "WARNING: sizes look different:  '%s'   vs   '%s'" % (y0, y1)
////////////////////

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
Untested
---
 drivers/net/wan/fsl_ucc_hdlc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wan/fsl_ucc_hdlc.c b/drivers/net/wan/fsl_ucc_hdlc.c
index 5fbf83d5aa57..65647533b401 100644
--- a/drivers/net/wan/fsl_ucc_hdlc.c
+++ b/drivers/net/wan/fsl_ucc_hdlc.c
@@ -295,11 +295,11 @@ static int uhdlc_init(struct ucc_hdlc_private *priv)
 	qe_muram_free(priv->ucc_pram_offset);
 free_tx_bd:
 	dma_free_coherent(priv->dev,
-			  TX_BD_RING_LEN * sizeof(struct qe_bd),
+			  TX_BD_RING_LEN * sizeof(struct qe_bd *),
 			  priv->tx_bd_base, priv->dma_tx_bd);
 free_rx_bd:
 	dma_free_coherent(priv->dev,
-			  RX_BD_RING_LEN * sizeof(struct qe_bd),
+			  RX_BD_RING_LEN * sizeof(struct qe_bd *),
 			  priv->rx_bd_base, priv->dma_rx_bd);
 free_uccf:
 	ucc_fast_free(priv->uccf);
@@ -688,7 +688,7 @@ static void uhdlc_memclean(struct ucc_hdlc_private *priv)
 
 	if (priv->rx_bd_base) {
 		dma_free_coherent(priv->dev,
-				  RX_BD_RING_LEN * sizeof(struct qe_bd),
+				  RX_BD_RING_LEN * sizeof(struct qe_bd *),
 				  priv->rx_bd_base, priv->dma_rx_bd);
 
 		priv->rx_bd_base = NULL;
@@ -697,7 +697,7 @@ static void uhdlc_memclean(struct ucc_hdlc_private *priv)
 
 	if (priv->tx_bd_base) {
 		dma_free_coherent(priv->dev,
-				  TX_BD_RING_LEN * sizeof(struct qe_bd),
+				  TX_BD_RING_LEN * sizeof(struct qe_bd *),
 				  priv->tx_bd_base, priv->dma_tx_bd);
 
 		priv->tx_bd_base = NULL;
-- 
2.7.4
