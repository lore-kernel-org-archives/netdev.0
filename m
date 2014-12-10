From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 1/3] net: fec: reset fep link status in suspend function
Date: Wed, 10 Dec 2014 17:54:47 +0800
Message-ID: <1418205289-7730-2-git-send-email-b38611@freescale.com>
References: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0127.outbound.protection.outlook.com ([207.46.100.127]:54720
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752779AbaLJK2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 05:28:23 -0500
In-Reply-To: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some i.MX6 serial boards, phy power and refrence clock are supplied
or controlled by SOC. When do suspend/resume test, the power and clock
are disabled, so phy device link down.

For current driver, fep->link is still up status, which cause extra operation
like below code. To avoid the dumy operation, we set fep->link to down when
phy device is real down.
...
if (fep->link) {
	napi_disable(&fep->napi);
	netif_tx_lock_bh(ndev);
	fec_stop(ndev);
	netif_tx_unlock_bh(ndev);
	napi_enable(&fep->napi);
	fep->link = phy_dev->link;
	status_change = 1;
}
...

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index fee2afe..e8c7c82 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3332,6 +3332,13 @@ static int __maybe_unused fec_suspend(struct device *dev)
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 
+	/*
+	 * SOC supply clock to phy, when clock is disabled, phy link down
+	 * SOC control phy regulator, when regulator is disabled, phy link down
+	 */
+	if (fep->clk_enet_out || fep->reg_phy)
+		fep->link = 0;
+
 	return 0;
 }
 
-- 
1.7.8
