From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix adjust link call in case of a switch is attached
Date: Tue, 5 Apr 2016 08:46:57 +0200
Message-ID: <1459838817-24905-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Alexandre TORGUE <alexandre.torgue@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:55501 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751702AbcDEGql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 02:46:41 -0400
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u356fsGk009420
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:46:39 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 222xgus2sh-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:46:39 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id DB8BF31
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 06:46:38 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 85EB3EE4
	for <netdev@vger.kernel.org>; Tue,  5 Apr 2016 06:46:38 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While initializing the phy, the stmmac driver sets the
PHY_IGNORE_INTERRUPT so the PAL won't call the adjust hook
that is needed, on some platforms, e.g. STi, to invoke the glue.

The patch allows the PAL to poll the stmmac_adjust_link just one time
in case of a switch is attached, setting later the PHY_IGNORE_INTERRUPT
flag.
Moving this kind of logic inside the adjust_link it makes sense to
anticipate the check for EEE that will never initialized in this
scenario.

Reported-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   22 +++++++++-----------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 78464fa..fcbd4be 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -288,10 +288,6 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 	    (priv->pcs == STMMAC_PCS_RTBI))
 		goto out;
 
-	/* Never init EEE in case of a switch is attached */
-	if (priv->phydev->is_pseudo_fixed_link)
-		goto out;
-
 	/* MAC core supports the EEE feature. */
 	if (priv->dma_cap.eee) {
 		int tx_lpi_timer = priv->tx_lpi_timer;
@@ -771,10 +767,16 @@ static void stmmac_adjust_link(struct net_device *dev)
 
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	/* At this stage, it could be needed to setup the EEE or adjust some
-	 * MAC related HW registers.
-	 */
-	priv->eee_enabled = stmmac_eee_init(priv);
+	if (phydev->is_pseudo_fixed_link)
+		/* Stop PHY layer to call the hook to adjust the link in case
+		 * of a switch is attached to the stmmac driver.
+		 */
+		phydev->irq = PHY_IGNORE_INTERRUPT;
+	else
+		/* At this stage, init the EEE if supported.
+		 * Never called in case of fixed_link.
+		 */
+		priv->eee_enabled = stmmac_eee_init(priv);
 }
 
 /**
@@ -865,10 +867,6 @@ static int stmmac_init_phy(struct net_device *dev)
 		return -ENODEV;
 	}
 
-	/* If attached to a switch, there is no reason to poll phy handler */
-	if (phydev->is_pseudo_fixed_link)
-		phydev->irq = PHY_IGNORE_INTERRUPT;
-
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
 
-- 
1.7.4.4
