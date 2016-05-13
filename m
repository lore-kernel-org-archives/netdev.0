From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 1/2] net: mv643xx_eth: use {readl|writel}_relaxed instead of
 readl/writel
Date: Fri, 13 May 2016 19:59:19 +0800
Message-ID: <1463140760-7128-2-git-send-email-jszhang@marvell.com>
References: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: <sebastian.hesselbarth@gmail.com>, <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1463140760-7128-1-git-send-email-jszhang@marvell.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Since appropriate memory barriers are already there, use the relaxed
version to improve performance a bit.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 33 +++++++++++++++---------------
 1 file changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 5583118..c6d8124 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -433,22 +433,22 @@ struct mv643xx_eth_private {
 /* port register accessors **************************************************/
 static inline u32 rdl(struct mv643xx_eth_private *mp, int offset)
 {
-	return readl(mp->shared->base + offset);
+	return readl_relaxed(mp->shared->base + offset);
 }
 
 static inline u32 rdlp(struct mv643xx_eth_private *mp, int offset)
 {
-	return readl(mp->base + offset);
+	return readl_relaxed(mp->base + offset);
 }
 
 static inline void wrl(struct mv643xx_eth_private *mp, int offset, u32 data)
 {
-	writel(data, mp->shared->base + offset);
+	writel_relaxed(data, mp->shared->base + offset);
 }
 
 static inline void wrlp(struct mv643xx_eth_private *mp, int offset, u32 data)
 {
-	writel(data, mp->base + offset);
+	writel_relaxed(data, mp->base + offset);
 }
 
 
@@ -2642,10 +2642,10 @@ mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *msp,
 	int i;
 
 	for (i = 0; i < 6; i++) {
-		writel(0, base + WINDOW_BASE(i));
-		writel(0, base + WINDOW_SIZE(i));
+		writel_relaxed(0, base + WINDOW_BASE(i));
+		writel_relaxed(0, base + WINDOW_SIZE(i));
 		if (i < 4)
-			writel(0, base + WINDOW_REMAP_HIGH(i));
+			writel_relaxed(0, base + WINDOW_REMAP_HIGH(i));
 	}
 
 	win_enable = 0x3f;
@@ -2654,16 +2654,17 @@ mv643xx_eth_conf_mbus_windows(struct mv643xx_eth_shared_private *msp,
 	for (i = 0; i < dram->num_cs; i++) {
 		const struct mbus_dram_window *cs = dram->cs + i;
 
-		writel((cs->base & 0xffff0000) |
+		writel_relaxed((cs->base & 0xffff0000) |
 			(cs->mbus_attr << 8) |
 			dram->mbus_dram_target_id, base + WINDOW_BASE(i));
-		writel((cs->size - 1) & 0xffff0000, base + WINDOW_SIZE(i));
+		writel_relaxed((cs->size - 1) & 0xffff0000,
+			base + WINDOW_SIZE(i));
 
 		win_enable &= ~(1 << i);
 		win_protect |= 3 << (2 * i);
 	}
 
-	writel(win_enable, base + WINDOW_BAR_ENABLE);
+	writel_relaxed(win_enable, base + WINDOW_BAR_ENABLE);
 	msp->win_protect = win_protect;
 }
 
@@ -2674,8 +2675,8 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	 * [21:8], or a 16-bit coal limit in bits [25,21:7] of the
 	 * SDMA config register.
 	 */
-	writel(0x02000000, msp->base + 0x0400 + SDMA_CONFIG);
-	if (readl(msp->base + 0x0400 + SDMA_CONFIG) & 0x02000000)
+	writel_relaxed(0x02000000, msp->base + 0x0400 + SDMA_CONFIG);
+	if (readl_relaxed(msp->base + 0x0400 + SDMA_CONFIG) & 0x02000000)
 		msp->extended_rx_coal_limit = 1;
 	else
 		msp->extended_rx_coal_limit = 0;
@@ -2685,12 +2686,12 @@ static void infer_hw_params(struct mv643xx_eth_shared_private *msp)
 	 * yes, whether its associated registers are in the old or
 	 * the new place.
 	 */
-	writel(1, msp->base + 0x0400 + TX_BW_MTU_MOVED);
-	if (readl(msp->base + 0x0400 + TX_BW_MTU_MOVED) & 1) {
+	writel_relaxed(1, msp->base + 0x0400 + TX_BW_MTU_MOVED);
+	if (readl_relaxed(msp->base + 0x0400 + TX_BW_MTU_MOVED) & 1) {
 		msp->tx_bw_control = TX_BW_CONTROL_NEW_LAYOUT;
 	} else {
-		writel(7, msp->base + 0x0400 + TX_BW_RATE);
-		if (readl(msp->base + 0x0400 + TX_BW_RATE) & 7)
+		writel_relaxed(7, msp->base + 0x0400 + TX_BW_RATE);
+		if (readl_relaxed(msp->base + 0x0400 + TX_BW_RATE) & 7)
 			msp->tx_bw_control = TX_BW_CONTROL_OLD_LAYOUT;
 		else
 			msp->tx_bw_control = TX_BW_CONTROL_ABSENT;
-- 
2.8.1
