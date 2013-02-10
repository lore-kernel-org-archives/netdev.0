From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH 2/2] net: calexdaxgmac: fixup endian issues after __raw IO
 function change
Date: Sun, 10 Feb 2013 15:38:41 +0000
Message-ID: <1360510721-17860-3-git-send-email-ben.dooks@codethink.co.uk>
References: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, Ben Dooks <ben.dooks@codethink.co.uk>,
 "David S. Miller" <davem@davemloft.net>, Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1360510721-17860-1-git-send-email-ben.dooks@codethink.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

When changing to __raw acccessors in 0ec6d343f7bcf9e0944aa9ff65287b987ec00c0f
("net: calxedaxgmac: use raw i/o accessors in rx and tx paths"), the driver
is now broken on big endian systems as the readl/writel have an implict
endian swap in them.

Change all the places where the __raw calls are used to correctly convert
the constants in big endian format to the little endian data that the
peripheral expects to see.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 drivers/net/ethernet/calxeda/xgmac.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index f91d9b2..96fd538 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1202,7 +1202,8 @@ static int xgmac_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete(napi);
-		__raw_writel(DMA_INTR_DEFAULT_MASK, priv->base + XGMAC_DMA_INTR_ENA);
+		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_DEFAULT_MASK),
+			     priv->base + XGMAC_DMA_INTR_ENA);
 	}
 	return work_done;
 }
@@ -1348,7 +1349,7 @@ static irqreturn_t xgmac_pmt_interrupt(int irq, void *dev_id)
 	void __iomem *ioaddr = priv->base;
 
 	intr_status = __raw_readl(ioaddr + XGMAC_INT_STAT);
-	if (intr_status & XGMAC_INT_STAT_PMT) {
+	if (intr_status & le32_to_cpu((__force __le32)XGMAC_INT_STAT_PMT)) {
 		netdev_dbg(priv->dev, "received Magic frame\n");
 		/* clear the PMT bits 5 and 6 by reading the PMT */
 		readl(ioaddr + XGMAC_PMT);
@@ -1369,6 +1370,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 	intr_status &= __raw_readl(priv->base + XGMAC_DMA_INTR_ENA);
 	__raw_writel(intr_status, priv->base + XGMAC_DMA_STATUS);
 
+	intr_status = (__force u32)cpu_to_le32(intr_status);
+
 	/* It displays the DMA process states (CSR5 register) */
 	/* ABNORMAL interrupts */
 	if (unlikely(intr_status & DMA_STATUS_AIS)) {
@@ -1403,7 +1406,8 @@ static irqreturn_t xgmac_interrupt(int irq, void *dev_id)
 
 	/* TX/RX NORMAL interrupts */
 	if (intr_status & (DMA_STATUS_RI | DMA_STATUS_TU | DMA_STATUS_TI)) {
-		__raw_writel(DMA_INTR_ABNORMAL, priv->base + XGMAC_DMA_INTR_ENA);
+		__raw_writel(le32_to_cpu((__force __le32)DMA_INTR_ABNORMAL),
+			     priv->base + XGMAC_DMA_INTR_ENA);
 		napi_schedule(&priv->napi);
 	}
 
-- 
1.7.10.4
