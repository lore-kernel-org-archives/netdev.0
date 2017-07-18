From: Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
Subject: [PATCH] NET: dwmac: Make dwmac reset unconditional
Date: Tue, 18 Jul 2017 17:07:15 +0300
Message-ID: <20170718140715.25798-1-Eugeniy.Paltsev@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unconditional reset dwmac before HW init if reset controller is present.

In existing implementation we reset dwmac only after second module
probing:
(module load -> unload -> load again [reset happens])

Now we reset dwmac at every module load:
(module load [reset happens] -> unload -> load again [reset happens])

Also some reset controllers have only reset callback instead of
assert + deassert callbacks pair, so handle this case.

Signed-off-by: Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 12236da..c7b3d0d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -4096,8 +4096,15 @@ int stmmac_dvr_probe(struct device *device,
 	if ((phyaddr >= 0) && (phyaddr <= 31))
 		priv->plat->phy_addr = phyaddr;
 
-	if (priv->plat->stmmac_rst)
+	if (priv->plat->stmmac_rst) {
+		ret = reset_control_assert(priv->plat->stmmac_rst);
 		reset_control_deassert(priv->plat->stmmac_rst);
+		/* Some reset controllers have only reset callback instead of
+		 * assert + deassert callbacks pair.
+		 */
+		if (ret == -ENOTSUPP)
+			reset_control_reset(priv->plat->stmmac_rst);
+	}
 
 	/* Init MAC and get the capabilities */
 	ret = stmmac_hw_init(priv);
-- 
2.9.3
