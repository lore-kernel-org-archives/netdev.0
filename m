From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH v3 2/2] ravb: add workaround for clock when resuming with WoL enabled
Date: Tue,  1 Aug 2017 12:14:37 +0200
Message-ID: <20170801101437.9020-3-niklas.soderlund+renesas@ragnatech.se>
References: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:44207 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751680AbdHAKPU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 06:15:20 -0400
In-Reply-To: <20170801101437.9020-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The renesas-cpg-mssr clock driver are not yet aware of PSCI sleep where
power is cut to the SoC. When resuming from this state with WoL enabled
the enable count of the ravb clock is 1 and the clock driver thinks the
clock is already on when PM core enables the clock and increments the
enable count to 2. This will result in the ravb driver failing to talk
to the hardware since the module clock is off. Work around this by
forcing the enable count to 0 and then back to 2 when resuming with WoL
enabled.

This workaround should be reverted once the renesas-cpg-mssr clock
driver becomes aware of this PSCI sleep behavior.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/ravb_main.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 6d10db1b51468031..fdf30bfa403bf416 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -2270,9 +2270,32 @@ static int __maybe_unused ravb_resume(struct device *dev)
 	struct ravb_private *priv = netdev_priv(ndev);
 	int ret = 0;
 
-	/* If WoL is enabled set reset mode to rearm the WoL logic */
-	if (priv->wol_enabled)
+	if (priv->wol_enabled) {
+		/* Reduce the usecount of the clock to zero and then
+		 * restore it to its original value. This is done to force
+		 * the clock to be re-enabled which is a workaround
+		 * for renesas-cpg-mssr driver which do not enable clocks
+		 * when resuming from PSCI suspend/resume.
+		 *
+		 * Without this workaround the driver fails to communicate
+		 * with the hardware if WoL was enabled when the system
+		 * entered PSCI suspend. This is due to that if WoL is enabled
+		 * we explicitly keep the clock from being turned off when
+		 * suspending, but in PSCI sleep power is cut so the clock
+		 * is disabled anyhow, the clock driver is not aware of this
+		 * so the clock is not turned back on when resuming.
+		 *
+		 * TODO: once the renesas-cpg-mssr suspend/resume is working
+		 *       this clock dance should be removed.
+		 */
+		clk_disable(priv->clk);
+		clk_disable(priv->clk);
+		clk_enable(priv->clk);
+		clk_enable(priv->clk);
+
+		/* Set reset mode to rearm the WoL logic */
 		ravb_write(ndev, CCC_OPC_RESET, CCC);
+	}
 
 	/* All register have been reset to default values.
 	 * Restore all registers which where setup at probe time and
-- 
2.13.3
