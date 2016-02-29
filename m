From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [PATCH v3 13/17] stmmac: do not poll phy handler when attach a switch
Date: Mon, 29 Feb 2016 14:27:39 +0100
Message-ID: <1456752463-27128-14-git-send-email-alexandre.torgue@st.com>
References: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <fabrice.gasnier@st.com>,
	<maxime.coquelin@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:45930 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755394AbcB2N24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 08:28:56 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1TDRpUV019379
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:54 +0100
Received: from beta.dmz-ap.st.com (beta.dmz-ap.st.com [138.198.100.35])
	by mx08-00178001.pphosted.com with ESMTP id 21b3jgaqfr-1
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 14:28:54 +0100
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 61EB023
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:51 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 09ED8F7
	for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 13:28:50 +0000 (GMT)
In-Reply-To: <1456752463-27128-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This patch avoids to call the stmmac_adjust_link when
the driver is connected to a switch by using the FIXED_PHY
support. Prior this patch the phydev->irq was set as PHY_POLL
so periodically the phy handler was invoked spending useless
time because the link cannot actually change.
Note that the stmmac_adjust_link will be called just one
time and this guarantees that the ST glue logic will be
setup according to the mode and speed fixed.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@st.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 90b2612..eab7ac0 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -866,6 +866,11 @@ static int stmmac_init_phy(struct net_device *dev)
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
+
+	/* If attached to a switch, there is no reason to poll phy handler */
+	if (!strcmp(priv->plat->phy_bus_name, "fixed"))
+		phydev->irq = PHY_IGNORE_INTERRUPT;
+
 	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
 		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
 
-- 
1.9.1
