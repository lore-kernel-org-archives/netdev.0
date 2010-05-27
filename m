From: Mark Ware <mware@elphinstone.net>
Subject: [PATCH] fs_enet: Adjust BDs after tx error
Date: Thu, 27 May 2010 11:12:12 +1000
Message-ID: <4BFDC6EC.9090804@elphinstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
To: Linuxppc-dev Development <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

This patch fixes an occasional transmit lockup in the mac-fcc which
occurs after a tx error.  The test scenario had the local port set
to autoneg and the other end fixed at 100FD, resulting in a large
number of late collisions.

According to the MPC8280RM 30.10.1.3 (also 8272RM 29.10.1.3), after
a tx error occurs, TBPTR may sometimes point beyond BDs still marked
as ready.  This patch walks back through the BDs and points TBPTR to
the earliest one marked as ready.

Tested on a custom board with a MPC8280.

Signed-off-by: Mark Ware <mware@elphinstone.net>
---
 drivers/net/fs_enet/mac-fcc.c |   49 ++++++++++++++++++++++++++++++++++++-----
 1 files changed, 43 insertions(+), 6 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 22e5a84..6023f15 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -503,17 +503,54 @@ static int get_regs_len(struct net_device *dev)
 }
 
 /* Some transmit errors cause the transmitter to shut
- * down.  We now issue a restart transmit.  Since the
- * errors close the BD and update the pointers, the restart
- * _should_ pick up without having to reset any of our
- * pointers either.  Also, To workaround 8260 device erratum
- * CPM37, we must disable and then re-enable the transmitter
- * following a Late Collision, Underrun, or Retry Limit error.
+ * down.  We now issue a restart transmit.
+ * Also, to workaround 8260 device erratum CPM37, we must
+ * disable and then re-enable the transmitterfollowing a
+ * Late Collision, Underrun, or Retry Limit error.
+ * In addition, tbptr may point beyond BDs beyond still marked
+ * as ready due to internal pipelining, so we need to look back
+ * through the BDs and adjust tbptr to point to the last BD
+ * marked as ready.  This may result in some buffers being
+ * retransmitted.
  */
 static void tx_restart(struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	fcc_t __iomem *fccp = fep->fcc.fccp;
+	const struct fs_platform_info *fpi = fep->fpi;
+	fcc_enet_t __iomem *ep = fep->fcc.ep;
+	cbd_t __iomem *curr_tbptr;
+	cbd_t __iomem *recheck_bd;
+	cbd_t __iomem *prev_bd;
+	cbd_t __iomem *last_tx_bd;
+
+	last_tx_bd = fep->tx_bd_base + (fpi->tx_ring * sizeof(cbd_t));
+
+	/* get the current bd held in TBPTR  and scan back from this point */
+	recheck_bd = curr_tbptr = (cbd_t __iomem *)
+		((R32(ep, fen_genfcc.fcc_tbptr) - fep->ring_mem_addr) +
+		fep->ring_base);
+
+	prev_bd = (recheck_bd == fep->tx_bd_base) ? last_tx_bd : recheck_bd - 1;
+
+	/* Move through the bds in reverse, look for the earliest buffer
+	 * that is not ready.  Adjust TBPTR to the following buffer */
+	while ((CBDR_SC(prev_bd) & BD_ENET_TX_READY) != 0) {
+		/* Go back one buffer */
+		recheck_bd = prev_bd;
+
+		/* update the previous buffer */
+		prev_bd = (prev_bd == fep->tx_bd_base) ? last_tx_bd : prev_bd - 1;
+
+		/* We should never see all bds marked as ready, check anyway */
+		if (recheck_bd == curr_tbptr)
+			break;
+	}
+	/* Now update the TBPTR and dirty flag to the current buffer */
+	W32(ep, fen_genfcc.fcc_tbptr,
+		(uint) (((void *)recheck_bd - fep->ring_base) +
+		fep->ring_mem_addr));
+	fep->dirty_tx = recheck_bd;
 
 	C32(fccp, fcc_gfmr, FCC_GFMR_ENT);
 	udelay(10);
-- 
1.5.6.5
