From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 5/5] fec: Handle the regulator in suspend/resume
Date: Mon, 27 May 2013 10:48:33 -0300
Message-ID: <1369662513-32133-6-git-send-email-fabio.estevam@freescale.com>
References: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe004.messaging.microsoft.com ([216.32.180.14]:45422
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932542Ab3E0NtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:49:01 -0400
In-Reply-To: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to save power, let's disable the regulator in the suspend function and
enable it in resume.

Tested on a mx28evk board.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index cac667d..866b922 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2044,6 +2044,9 @@ fec_suspend(struct device *dev)
 	clk_disable_unprepare(fep->clk_ahb);
 	clk_disable_unprepare(fep->clk_ipg);
 
+	if (fep->reg_phy)
+		regulator_disable(fep->reg_phy);
+
 	return 0;
 }
 
@@ -2052,6 +2055,13 @@ fec_resume(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	int ret;
+
+	if (fep->reg_phy) {
+		ret = regulator_enable(fep->reg_phy);
+		if (ret)
+			return ret;
+	}
 
 	clk_prepare_enable(fep->clk_enet_out);
 	clk_prepare_enable(fep->clk_ahb);
-- 
1.8.1.2
