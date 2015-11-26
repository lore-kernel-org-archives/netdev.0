From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/5] stmmac: dwmac-sti: fix st,tx-retime-src check
Date: Thu, 26 Nov 2015 08:35:43 +0100
Message-ID: <1448523345-832-4-git-send-email-peppe.cavallaro@st.com>
References: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:54295 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752151AbbKZH2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:28:09 -0500
Received: from pps.filterd (m0046660.ppops.net [127.0.0.1])
	by mx08-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id tAQ7S7mA018530
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:08 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx08-00178001.pphosted.com with ESMTP id 1yd9vd4u3f-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:08 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 731AC38
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:34 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8EBDE13CD
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:28:06 +0000 (GMT)
In-Reply-To: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of the st,tx-retime-src is missing from device-tree
(it's an optional field) the driver will invoke the strcasecmp to check
which clock has been selected and this is a bug; the else condition
is needed.

In the dwmac_setup, the "rs" variable, passed to the strcasecmp, was not
initialized and the compiler, depending on the options adopted, could
take it in some different part of the stack generating the hang in such
configuration.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 7f6f4a4..58c05ac 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -299,16 +299,17 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	if (IS_PHY_IF_MODE_GBIT(dwmac->interface)) {
 		const char *rs;
 
+		dwmac->tx_retime_src = TX_RETIME_SRC_CLKGEN;
+
 		err = of_property_read_string(np, "st,tx-retime-src", &rs);
 		if (err < 0) {
 			dev_warn(dev, "Use internal clock source\n");
-			dwmac->tx_retime_src = TX_RETIME_SRC_CLKGEN;
-		} else if (!strcasecmp(rs, "clk_125")) {
-			dwmac->tx_retime_src = TX_RETIME_SRC_CLK_125;
-		} else if (!strcasecmp(rs, "txclk")) {
-			dwmac->tx_retime_src = TX_RETIME_SRC_TXCLK;
+		} else {
+			if (!strcasecmp(rs, "clk_125"))
+				dwmac->tx_retime_src = TX_RETIME_SRC_CLK_125;
+			else if (!strcasecmp(rs, "txclk"))
+				dwmac->tx_retime_src = TX_RETIME_SRC_TXCLK;
 		}
-
 		dwmac->speed = SPEED_1000;
 	}
 
-- 
1.7.4.4
