From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH v2 5/7] ucc_geth: Implement Transmit on Demand support
Date: Fri, 13 Apr 2007 01:26:19 -0500
Message-ID: <20070413012619.60c37cca.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:39519 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbXDMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 02:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Reiss <michael.f.reiss@freescale.com>

Transmit on Demand: Fix spelling in config option, and make it actually enable TOD.

Signed-off-by: Michael Reiss <michael.f.reiss@freescale.com>
Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 arch/powerpc/sysdev/qe_lib/ucc_fast.c |    3 +++
 drivers/net/Kconfig                   |    4 ++--
 drivers/net/ucc_geth.c                |   15 +++++++--------
 include/asm-powerpc/ucc_fast.h        |    3 +++
 4 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/sysdev/qe_lib/ucc_fast.c b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
index a457ac1..66137bf 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_fast.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
@@ -210,6 +210,9 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, struct ucc_fast_private ** ucc
 	uf_regs = uccf->uf_regs;
 	uccf->p_ucce = (u32 *) & (uf_regs->ucce);
 	uccf->p_uccm = (u32 *) & (uf_regs->uccm);
+#ifdef CONFIG_UGETH_TX_ON_DEMAND
+	uccf->p_utodr = (u16 *) & (uf_regs->utodr);
+#endif
 #ifdef STATISTICS
 	uccf->tx_frames = 0;
 	uccf->rx_frames = 0;
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8c7be7f..c0de6fe 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2292,8 +2292,8 @@ config UGETH_FILTERING
 	bool "Mac address filtering support"
 	depends on UCC_GETH
 
-config UGETH_TX_ON_DEMOND
-	bool "Transmit on Demond support"
+config UGETH_TX_ON_DEMAND
+	bool "Transmit on Demand support"
 	depends on UCC_GETH
 
 config MV643XX_ETH
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1a16ab2..60844a6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1626,14 +1626,6 @@ static int init_phy(struct net_device *dev)
 }
 
 
-#ifdef CONFIG_UGETH_TX_ON_DEMOND
-static int ugeth_transmit_on_demand(struct ucc_geth_private *ugeth)
-{
-	struct ucc_fastransmit_on_demand(ugeth->uccf);
-
-	return 0;
-}
-#endif
 
 static int ugeth_graceful_stop_tx(struct ucc_geth_private *ugeth)
 {
@@ -3343,6 +3335,9 @@ static void ucc_geth_timeout(struct net_device *dev)
 static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
+#ifdef CONFIG_UGETH_TX_ON_DEMAND
+	struct ucc_fast_private *uccf;
+#endif
 	u8 *bd;			/* BD pointer */
 	u32 bd_status;
 	u8 txQ = 0;
@@ -3401,6 +3396,10 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		out_be16(ugeth->p_cpucount[txQ], ugeth->cpucount[txQ]);
 	}
 
+#ifdef CONFIG_UGETH_TX_ON_DEMAND
+	uccf = ugeth->uccf;
+	out_be16(uccf->p_utodr, UCC_FAST_TOD);
+#endif
 	spin_unlock_irq(&ugeth->lock);
 
 	return 0;
diff --git a/include/asm-powerpc/ucc_fast.h b/include/asm-powerpc/ucc_fast.h
index 39d1c90..f529f70 100644
--- a/include/asm-powerpc/ucc_fast.h
+++ b/include/asm-powerpc/ucc_fast.h
@@ -159,6 +159,9 @@ struct ucc_fast_private {
 	struct ucc_fast *uf_regs;	/* a pointer to memory map of UCC regs. */
 	u32 *p_ucce;		/* a pointer to the event register in memory. */
 	u32 *p_uccm;		/* a pointer to the mask register in memory. */
+#ifdef CONFIG_UGETH_TX_ON_DEMAND
+	u16 *p_utodr;		/* pointer to the transmit on demand register */
+#endif
 	int enabled_tx;		/* Whether channel is enabled for Tx (ENT) */
 	int enabled_rx;		/* Whether channel is enabled for Rx (ENR) */
 	int stopped_tx;		/* Whether channel has been stopped for Tx
-- 
1.5.0.1

