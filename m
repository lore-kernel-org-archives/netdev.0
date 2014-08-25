From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: fix rx checksum programming
Date: Mon, 25 Aug 2014 14:56:18 +0200
Message-ID: <1408971379-14871-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:39790 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755469AbaHYM4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 08:56:25 -0400
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7PCsDtK005648
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:56:24 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1nxm5wksqn-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:56:24 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 47D4D34
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:56:14 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9785159F07
	for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:56:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to fix the IPC bit into the GMAC control register
that must be done after the core initialization otherwise it will
not have any effect.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 08addd6..51a89d4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1637,6 +1637,12 @@ static int stmmac_hw_setup(struct net_device *dev)
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->hw, dev->mtu);
 
+	ret = priv->hw->mac->rx_ipc(priv->hw);
+	if (!ret) {
+		pr_warn(" RX IPC Checksum Offload disabled\n");
+		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
+	}
+
 	/* Enable the MAC Rx/Tx */
 	stmmac_set_mac(priv->ioaddr, true);
 
@@ -2592,7 +2598,6 @@ static const struct net_device_ops stmmac_netdev_ops = {
  */
 static int stmmac_hw_init(struct stmmac_priv *priv)
 {
-	int ret;
 	struct mac_device_info *mac;
 
 	/* Identify the MAC HW device */
@@ -2649,12 +2654,6 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 	/* To use alternate (extended) or normal descriptor structures */
 	stmmac_selec_desc_mode(priv);
 
-	ret = priv->hw->mac->rx_ipc(priv->hw);
-	if (!ret) {
-		pr_warn(" RX IPC Checksum Offload not configured.\n");
-		priv->plat->rx_coe = STMMAC_RX_COE_NONE;
-	}
-
 	if (priv->plat->rx_coe)
 		pr_info(" RX Checksum Offload Engine supported (type %d)\n",
 			priv->plat->rx_coe);
-- 
1.7.4.4
