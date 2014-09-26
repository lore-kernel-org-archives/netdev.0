From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH v2] net: stmmac: fix stmmac_pci_probe failed when CONFIG_HAVE_CLK is selected
Date: Fri, 26 Sep 2014 21:42:55 +0800
Message-ID: <1411738975-20056-1-git-send-email-hock.leong.kweh@intel.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	rayagond@vayavyalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

When the CONFIG_HAVE_CLK is selected for the system, the stmmac_pci_probe
will fail with dmesg:
[    2.167225] stmmaceth 0000:00:14.6: enabling device (0000 -> 0002)
[    2.178267] stmmaceth 0000:00:14.6: enabling bus mastering
[    2.178436] stmmaceth 0000:00:14.6: irq 24 for MSI/MSI-X
[    2.178703] stmmaceth 0000:00:14.6: stmmac_dvr_probe: warning: cannot
get CSR clock
[    2.186503] stmmac_pci_probe: main driver probe failed
[    2.194003] stmmaceth 0000:00:14.6: disabling bus mastering
[    2.196473] stmmaceth: probe of 0000:00:14.6 failed with error -2

This patch fix the issue by breaking the dependency to devm_clk_get()
as the CSR clock can be obtained at priv->plat->clk_csr from pci driver.

Reported-by: Tobias Klausmann <tobias.johannes.klausmann@mni.thm.de>
Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
---

changelog v2:
* retain the dev_warn message while devm_clk_get failed
* add in comments to indicate clk_csr failed condition

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 08addd6..90cac23 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2716,8 +2716,15 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	if (IS_ERR(priv->stmmac_clk)) {
 		dev_warn(priv->device, "%s: warning: cannot get CSR clock\n",
 			 __func__);
-		ret = PTR_ERR(priv->stmmac_clk);
-		goto error_clk_get;
+		/* If failed to obtain stmmac_clk and specific clk_csr value
+		 * is NOT passed from the platform, probe fail.
+		 */
+		if (!priv->plat->clk_csr) {
+			ret = PTR_ERR(priv->stmmac_clk);
+			goto error_clk_get;
+		} else {
+			priv->stmmac_clk = NULL;
+		}
 	}
 	clk_prepare_enable(priv->stmmac_clk);
 
-- 
1.7.9.5
