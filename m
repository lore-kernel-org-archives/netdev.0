From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 4/5] stmmac: fix PHY reset during resume
Date: Thu, 26 Nov 2015 08:35:44 +0100
Message-ID: <1448523345-832-5-git-send-email-peppe.cavallaro@st.com>
References: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Pankaj Dev <pankaj.dev@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:13739 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026AbbKZH2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:28:13 -0500
Received: from pps.filterd (m0046037.ppops.net [127.0.0.1])
	by m0046037.ppops.net (8.14.5/8.14.5) with SMTP id tAQ7SCqZ011180
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:12 +0100
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by m0046037.ppops.net with ESMTP id 1ydn4asw6b-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 08:28:12 +0100
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 6806131
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:27:38 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas24.st.com [10.75.90.94])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8437A13CD
	for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 07:28:10 +0000 (GMT)
In-Reply-To: <1448523345-832-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When stmmac_mdio_reset, was called from stmmac_resume, it was not
resetting the PHY due to which MAC was not getting reset properly and
hence ethernet interface not was resumed properly.
The issue was currently only reproducible on stih301-b2204.

Signed-off-by: Pankaj Dev <pankaj.dev@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   28 +++++++++-----------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index ebf6abc..bba670c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -138,7 +138,6 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 #ifdef CONFIG_OF
 	if (priv->device->of_node) {
-		int reset_gpio, active_low;
 
 		if (data->reset_gpio < 0) {
 			struct device_node *np = priv->device->of_node;
@@ -154,24 +153,23 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 						"snps,reset-active-low");
 			of_property_read_u32_array(np,
 				"snps,reset-delays-us", data->delays, 3);
-		}
 
-		reset_gpio = data->reset_gpio;
-		active_low = data->active_low;
+			if (gpio_request(data->reset_gpio, "mdio-reset"))
+				return 0;
+		}
 
-		if (!gpio_request(reset_gpio, "mdio-reset")) {
-			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
-			if (data->delays[0])
-				msleep(DIV_ROUND_UP(data->delays[0], 1000));
+		gpio_direction_output(data->reset_gpio,
+				      data->active_low ? 1 : 0);
+		if (data->delays[0])
+			msleep(DIV_ROUND_UP(data->delays[0], 1000));
 
-			gpio_set_value(reset_gpio, active_low ? 0 : 1);
-			if (data->delays[1])
-				msleep(DIV_ROUND_UP(data->delays[1], 1000));
+		gpio_set_value(data->reset_gpio, data->active_low ? 0 : 1);
+		if (data->delays[1])
+			msleep(DIV_ROUND_UP(data->delays[1], 1000));
 
-			gpio_set_value(reset_gpio, active_low ? 1 : 0);
-			if (data->delays[2])
-				msleep(DIV_ROUND_UP(data->delays[2], 1000));
-		}
+		gpio_set_value(data->reset_gpio, data->active_low ? 1 : 0);
+		if (data->delays[2])
+			msleep(DIV_ROUND_UP(data->delays[2], 1000));
 	}
 #endif
 
-- 
1.7.4.4
