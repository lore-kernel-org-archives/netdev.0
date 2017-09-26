From: Ed Blake <ed.blake@sondrel.com>
Subject: [PATCH] net: stmmac: dwmac4: Re-enable MAC Rx before powering down
Date: Tue, 26 Sep 2017 11:44:53 +0100
Message-ID: <1506422693-26144-1-git-send-email-ed.blake@sondrel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ed Blake <ed.blake@sondrel.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0079.outbound.protection.outlook.com ([104.47.2.79]:11460
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S965157AbdIZKpF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 06:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-enable the MAC receiver by setting CONFIG_RE before powering down,
as instructed in section 6.3.5.1 of [1].  Without this the MAC fails
to receive WoL packets and never wakes up.

[1] DWC Ethernet QoS Databook 4.10a October 2014

Signed-off-by: Ed Blake <ed.blake@sondrel.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index c4407e8..2f7d7ec 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -296,6 +296,7 @@ static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
 {
 	void __iomem *ioaddr = hw->pcsr;
 	unsigned int pmt = 0;
+	u32 config;
 
 	if (mode & WAKE_MAGIC) {
 		pr_debug("GMAC: WOL Magic frame\n");
@@ -306,6 +307,12 @@ static void dwmac4_pmt(struct mac_device_info *hw, unsigned long mode)
 		pmt |= power_down | global_unicast | wake_up_frame_en;
 	}
 
+	if (pmt) {
+		/* The receiver must be enabled for WOL before powering down */
+		config = readl(ioaddr + GMAC_CONFIG);
+		config |= GMAC_CONFIG_RE;
+		writel(config, ioaddr + GMAC_CONFIG);
+	}
 	writel(pmt, ioaddr + GMAC_PMT);
 }
 
-- 
1.9.1
