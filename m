From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net-next.git) 14/18] stmmac: do not poll phy handler when attach a switch
Date: Mon, 4 Jan 2016 14:06:59 +0100
Message-ID: <1451912823-5245-15-git-send-email-peppe.cavallaro@st.com>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <alexandre.torgue@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:49006 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753743AbcADMyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 07:54:24 -0500
Received: from pps.filterd (m0046661.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id u04CoeE9032241
	for <netdev@vger.kernel.org>; Mon, 4 Jan 2016 13:54:23 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 204cmt5v7m-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 13:54:23 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9B94338
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:53:39 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D4E1B50FA
	for <netdev@vger.kernel.org>; Mon,  4 Jan 2016 12:54:21 +0000 (GMT)
In-Reply-To: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch avoids to call the stmmac_adjust_link when
the driver is connected to a switch by using the FIXED_PHY
support. Prior this patch the phydev->irq was set as PHY_POLL
so periodically the phy handler was invoked spending useless
time because the link cannot actually change.
Note that the stmmac_adjust_link will be called just one
time and this guarantees that the ST glue logic will be
setup according to the mode and speed fixed.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 4a75f79..76ca54c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -881,6 +881,11 @@ static int stmmac_init_phy(struct net_device *dev)
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
1.7.4.4
