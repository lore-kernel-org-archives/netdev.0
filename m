From: Christian Lamparter <chunkeey@googlemail.com>
Subject: [PATCH v1 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Mon,  5 Jun 2017 22:49:39 +0200
Message-ID: <635dd014238af6f48c4169439b7ac161e80de1b7.1496695540.git.chunkeey@googlemail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>,
        Chris Blake <chrisrblake93@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33588 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdFEUtn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 16:49:43 -0400
Received: by mail-wr0-f196.google.com with SMTP id v104so8555493wrb.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 13:49:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem where the AR8035 PHY can't be
detected on an Cisco Meraki MR24, if the ethernet cable is
not connected on boot.

Russell Senior provided steps to reproduce the issue:
|Disconnect ethernet cable, apply power, wait until device has booted,
|plug in ethernet, check for interfaces, no eth0 is listed.
|
|This appears to be a problem during probing of the AR8035 Phy chip.
|When ethernet has no link, the phy detection fails, and eth0 is not
|created. Plugging ethernet later has no effect, because there is no
|interface as far as the kernel is concerned. The relevant part of
|the boot log looks like this:
|this is the failing case:
|
|[    0.876611] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
|[    0.882532] /plb/opb/ethernet@ef600c00: reset timeout
|[    0.888546] /plb/opb/ethernet@ef600c00: can't find PHY!
|and the succeeding case:
|
|[    0.876672] /plb/opb/emac-rgmii@ef601500: input 0 in RGMII mode
|[    0.883952] eth0: EMAC-0 /plb/opb/ethernet@ef600c00, MAC 00:01:..
|[    0.890822] eth0: found Atheros 8035 Gigabit Ethernet PHY (0x01)

Based on the comment and the commit message of
commit 23fbb5a87c56 ("emac: Fix EMAC soft reset on 460EX/GT").
This is because the AR8035 PHY of the Meraki MR24 does not
provide the TX Clk, if the ethernet cable is not attached.
This causes the reset to timeout and the PHY detection code
in emac_init_phy() is unable to detect the AR8035 PHY.
As a result, the emac driver bails out early and the user
has no ethernet.

In order to stay compatible with existing configurations, the
driver will try the normal reset first and only falls back to
to the internal clock, after the first reset fails. If the
second reset fails as well, it will give up as before.

LEDE-Bug: #687 <https://bugs.lede-project.org/index.php?do=details&task_id=687>

Cc: Chris Blake <chrisrblake93@gmail.com>
Reported-by: Russell Senior <russell@personaltelco.net>
Fixes: 23fbb5a87c56e98 ("emac: Fix EMAC soft reset on 460EX/GT")
Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>
---
 drivers/net/ethernet/ibm/emac/core.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 508923f39ccf..18af1116fa1d 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -343,6 +343,7 @@ static int emac_reset(struct emac_instance *dev)
 {
 	struct emac_regs __iomem *p = dev->emacp;
 	int n = 20;
+	bool try_internal_clock = false;
 
 	DBG(dev, "reset" NL);
 
@@ -355,6 +356,7 @@ static int emac_reset(struct emac_instance *dev)
 	}
 
 #ifdef CONFIG_PPC_DCR_NATIVE
+do_retry:
 	/*
 	 * PPC460EX/GT Embedded Processor Advanced User's Manual
 	 * section 28.10.1 Mode Register 0 (EMACx_MR0) states:
@@ -362,10 +364,19 @@ static int emac_reset(struct emac_instance *dev)
 	 * of the EMAC. If none is present, select the internal clock
 	 * (SDR0_ETH_CFG[EMACx_PHY_CLK] = 1).
 	 * After a soft reset, select the external clock.
+	 *
+	 * The AR8035-A PHY Meraki MR24 does not provide a TX Clk if the
+	 * ethernet cable is not attached. This causes the reset to timeout
+	 * and the PHY detection code in emac_init_phy() is unable to
+	 * communicate and detect the AR8035-A PHY. As a result, the emac
+	 * driver bails out early and the user has no ethernet.
+	 * In order to stay compatible with existing configurations, the
+	 * driver will fall back to and switch to the internal clock, after
+	 * the first reset fails.
 	 */
 	if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX)) {
-		if (dev->phy_address == 0xffffffff &&
-		    dev->phy_map == 0xffffffff) {
+		if (try_internal_clock || (dev->phy_address == 0xffffffff &&
+					   dev->phy_map == 0xffffffff)) {
 			/* No PHY: select internal loop clock before reset */
 			dcri_clrset(SDR0, SDR0_ETH_CFG,
 				    0, SDR0_ETH_CFG_ECS << dev->cell_index);
@@ -383,8 +394,8 @@ static int emac_reset(struct emac_instance *dev)
 
 #ifdef CONFIG_PPC_DCR_NATIVE
 	if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX)) {
-		if (dev->phy_address == 0xffffffff &&
-		    dev->phy_map == 0xffffffff) {
+		if (try_internal_clock || (dev->phy_address == 0xffffffff &&
+					   dev->phy_map == 0xffffffff)) {
 			/* No PHY: restore external clock source after reset */
 			dcri_clrset(SDR0, SDR0_ETH_CFG,
 				    SDR0_ETH_CFG_ECS << dev->cell_index, 0);
@@ -396,9 +407,16 @@ static int emac_reset(struct emac_instance *dev)
 		dev->reset_failed = 0;
 		return 0;
 	} else {
-		emac_report_timeout_error(dev, "reset timeout");
-		dev->reset_failed = 1;
-		return -ETIMEDOUT;
+		if (emac_has_feature(dev, EMAC_FTR_460EX_PHY_CLK_FIX) &&
+		    !try_internal_clock) {
+			/* do a retry with the internal clock */
+			try_internal_clock = true;
+			goto do_retry;
+		} else {
+			emac_report_timeout_error(dev, "reset timeout");
+			dev->reset_failed = 1;
+			return -ETIMEDOUT;
+		}
 	}
 }
 
-- 
2.11.0
