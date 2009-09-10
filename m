From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/3] ucc_geth: Rearrange some code to avoid forward
 declarations
Date: Thu, 10 Sep 2009 06:01:40 +0400
Message-ID: <20090910020140.GB31083@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Timur Tabi <timur@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:26232 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754830AbZIJCBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 22:01:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll need ugeth_disable() and ugeth_enable() calls earlier in the
file, so rearrange some code to avoid forward declarations.

The patch doesn't contain any functional changes.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |  300 ++++++++++++++++++++++++------------------------
 1 files changed, 149 insertions(+), 151 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 33ed69e..2a2c973 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1411,6 +1411,155 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	return 0;
 }
 
+static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_fast_private *uccf;
+	u32 cecr_subblock;
+	u32 temp;
+	int i = 10;
+
+	uccf = ugeth->uccf;
+
+	/* Mask GRACEFUL STOP TX interrupt bit and clear it */
+	clrbits32(uccf->p_uccm, UCC_GETH_UCCE_GRA);
+	out_be32(uccf->p_ucce, UCC_GETH_UCCE_GRA);  /* clear by writing 1 */
+
+	/* Issue host command */
+	cecr_subblock =
+	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
+	qe_issue_cmd(QE_GRACEFUL_STOP_TX, cecr_subblock,
+		     QE_CR_PROTOCOL_ETHERNET, 0);
+
+	/* Wait for command to complete */
+	do {
+		msleep(10);
+		temp = in_be32(uccf->p_ucce);
+	} while (!(temp & UCC_GETH_UCCE_GRA) && --i);
+
+	uccf->stopped_tx = 1;
+
+	return 0;
+}
+
+static int ugeth_graceful_stop_rx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_fast_private *uccf;
+	u32 cecr_subblock;
+	u8 temp;
+	int i = 10;
+
+	uccf = ugeth->uccf;
+
+	/* Clear acknowledge bit */
+	temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
+	temp &= ~GRACEFUL_STOP_ACKNOWLEDGE_RX;
+	out_8(&ugeth->p_rx_glbl_pram->rxgstpack, temp);
+
+	/* Keep issuing command and checking acknowledge bit until
+	it is asserted, according to spec */
+	do {
+		/* Issue host command */
+		cecr_subblock =
+		    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.
+						ucc_num);
+		qe_issue_cmd(QE_GRACEFUL_STOP_RX, cecr_subblock,
+			     QE_CR_PROTOCOL_ETHERNET, 0);
+		msleep(10);
+		temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
+	} while (!(temp & GRACEFUL_STOP_ACKNOWLEDGE_RX) && --i);
+
+	uccf->stopped_rx = 1;
+
+	return 0;
+}
+
+static int ugeth_restart_tx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_fast_private *uccf;
+	u32 cecr_subblock;
+
+	uccf = ugeth->uccf;
+
+	cecr_subblock =
+	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
+	qe_issue_cmd(QE_RESTART_TX, cecr_subblock, QE_CR_PROTOCOL_ETHERNET, 0);
+	uccf->stopped_tx = 0;
+
+	return 0;
+}
+
+static int ugeth_restart_rx(struct ucc_geth_private *ugeth)
+{
+	struct ucc_fast_private *uccf;
+	u32 cecr_subblock;
+
+	uccf = ugeth->uccf;
+
+	cecr_subblock =
+	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
+	qe_issue_cmd(QE_RESTART_RX, cecr_subblock, QE_CR_PROTOCOL_ETHERNET,
+		     0);
+	uccf->stopped_rx = 0;
+
+	return 0;
+}
+
+static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
+{
+	struct ucc_fast_private *uccf;
+	int enabled_tx, enabled_rx;
+
+	uccf = ugeth->uccf;
+
+	/* check if the UCC number is in range. */
+	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __func__);
+		return -EINVAL;
+	}
+
+	enabled_tx = uccf->enabled_tx;
+	enabled_rx = uccf->enabled_rx;
+
+	/* Get Tx and Rx going again, in case this channel was actively
+	disabled. */
+	if ((mode & COMM_DIR_TX) && (!enabled_tx) && uccf->stopped_tx)
+		ugeth_restart_tx(ugeth);
+	if ((mode & COMM_DIR_RX) && (!enabled_rx) && uccf->stopped_rx)
+		ugeth_restart_rx(ugeth);
+
+	ucc_fast_enable(uccf, mode);	/* OK to do even if not disabled */
+
+	return 0;
+
+}
+
+static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
+{
+	struct ucc_fast_private *uccf;
+
+	uccf = ugeth->uccf;
+
+	/* check if the UCC number is in range. */
+	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
+		if (netif_msg_probe(ugeth))
+			ugeth_err("%s: ucc_num out of range.", __func__);
+		return -EINVAL;
+	}
+
+	/* Stop any transmissions */
+	if ((mode & COMM_DIR_TX) && uccf->enabled_tx && !uccf->stopped_tx)
+		ugeth_graceful_stop_tx(ugeth);
+
+	/* Stop any receptions */
+	if ((mode & COMM_DIR_RX) && uccf->enabled_rx && !uccf->stopped_rx)
+		ugeth_graceful_stop_rx(ugeth);
+
+	ucc_fast_disable(ugeth->uccf, mode); /* OK to do even if not enabled */
+
+	return 0;
+}
+
 /* Called every time the controller might need to be made
  * aware of new link state.  The PHY code conveys this
  * information through variables in the ugeth structure, and this
@@ -1586,157 +1735,6 @@ static int init_phy(struct net_device *dev)
 	return 0;
 }
 
-
-
-static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fast_private *uccf;
-	u32 cecr_subblock;
-	u32 temp;
-	int i = 10;
-
-	uccf = ugeth->uccf;
-
-	/* Mask GRACEFUL STOP TX interrupt bit and clear it */
-	clrbits32(uccf->p_uccm, UCC_GETH_UCCE_GRA);
-	out_be32(uccf->p_ucce, UCC_GETH_UCCE_GRA);  /* clear by writing 1 */
-
-	/* Issue host command */
-	cecr_subblock =
-	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
-	qe_issue_cmd(QE_GRACEFUL_STOP_TX, cecr_subblock,
-		     QE_CR_PROTOCOL_ETHERNET, 0);
-
-	/* Wait for command to complete */
-	do {
-		msleep(10);
-		temp = in_be32(uccf->p_ucce);
-	} while (!(temp & UCC_GETH_UCCE_GRA) && --i);
-
-	uccf->stopped_tx = 1;
-
-	return 0;
-}
-
-static int ugeth_graceful_stop_rx(struct ucc_geth_private * ugeth)
-{
-	struct ucc_fast_private *uccf;
-	u32 cecr_subblock;
-	u8 temp;
-	int i = 10;
-
-	uccf = ugeth->uccf;
-
-	/* Clear acknowledge bit */
-	temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
-	temp &= ~GRACEFUL_STOP_ACKNOWLEDGE_RX;
-	out_8(&ugeth->p_rx_glbl_pram->rxgstpack, temp);
-
-	/* Keep issuing command and checking acknowledge bit until
-	it is asserted, according to spec */
-	do {
-		/* Issue host command */
-		cecr_subblock =
-		    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.
-						ucc_num);
-		qe_issue_cmd(QE_GRACEFUL_STOP_RX, cecr_subblock,
-			     QE_CR_PROTOCOL_ETHERNET, 0);
-		msleep(10);
-		temp = in_8(&ugeth->p_rx_glbl_pram->rxgstpack);
-	} while (!(temp & GRACEFUL_STOP_ACKNOWLEDGE_RX) && --i);
-
-	uccf->stopped_rx = 1;
-
-	return 0;
-}
-
-static int ugeth_restart_tx(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fast_private *uccf;
-	u32 cecr_subblock;
-
-	uccf = ugeth->uccf;
-
-	cecr_subblock =
-	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
-	qe_issue_cmd(QE_RESTART_TX, cecr_subblock, QE_CR_PROTOCOL_ETHERNET, 0);
-	uccf->stopped_tx = 0;
-
-	return 0;
-}
-
-static int ugeth_restart_rx(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fast_private *uccf;
-	u32 cecr_subblock;
-
-	uccf = ugeth->uccf;
-
-	cecr_subblock =
-	    ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
-	qe_issue_cmd(QE_RESTART_RX, cecr_subblock, QE_CR_PROTOCOL_ETHERNET,
-		     0);
-	uccf->stopped_rx = 0;
-
-	return 0;
-}
-
-static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
-{
-	struct ucc_fast_private *uccf;
-	int enabled_tx, enabled_rx;
-
-	uccf = ugeth->uccf;
-
-	/* check if the UCC number is in range. */
-	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __func__);
-		return -EINVAL;
-	}
-
-	enabled_tx = uccf->enabled_tx;
-	enabled_rx = uccf->enabled_rx;
-
-	/* Get Tx and Rx going again, in case this channel was actively
-	disabled. */
-	if ((mode & COMM_DIR_TX) && (!enabled_tx) && uccf->stopped_tx)
-		ugeth_restart_tx(ugeth);
-	if ((mode & COMM_DIR_RX) && (!enabled_rx) && uccf->stopped_rx)
-		ugeth_restart_rx(ugeth);
-
-	ucc_fast_enable(uccf, mode);	/* OK to do even if not disabled */
-
-	return 0;
-
-}
-
-static int ugeth_disable(struct ucc_geth_private * ugeth, enum comm_dir mode)
-{
-	struct ucc_fast_private *uccf;
-
-	uccf = ugeth->uccf;
-
-	/* check if the UCC number is in range. */
-	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
-		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __func__);
-		return -EINVAL;
-	}
-
-	/* Stop any transmissions */
-	if ((mode & COMM_DIR_TX) && uccf->enabled_tx && !uccf->stopped_tx)
-		ugeth_graceful_stop_tx(ugeth);
-
-	/* Stop any receptions */
-	if ((mode & COMM_DIR_RX) && uccf->enabled_rx && !uccf->stopped_rx)
-		ugeth_graceful_stop_rx(ugeth);
-
-	ucc_fast_disable(ugeth->uccf, mode); /* OK to do even if not enabled */
-
-	return 0;
-}
-
 static void ugeth_dump_regs(struct ucc_geth_private *ugeth)
 {
 #ifdef DEBUG
-- 
1.6.3.3

