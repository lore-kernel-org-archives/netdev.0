From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: disable coalesce when rx_coalesce_usecs is zero
Date: Tue, 15 Jul 2014 20:26:53 +0530
Message-ID: <1405436213-11428-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:45844 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751027AbaGOO5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 10:57:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

instead of return error on zero rx_coalesce_usecs, disable coalesce

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 0940bc2..a9b5bbb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -884,14 +884,16 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	u32 addnl_dvdr = 1;
 	u32 coal_intvl = 0;
 
-	if (!coal->rx_coalesce_usecs)
-		return -EINVAL;
-
 	coal_intvl = coal->rx_coalesce_usecs;
 
 	int_ctrl =  readl(&priv->wr_regs->int_control);
 	prescale = priv->bus_freq_mhz * 4;
 
+	if (!coal->rx_coalesce_usecs) {
+		int_ctrl &= ~(CPSW_INTPRESCALE_MASK | CPSW_INTPACEEN);
+		goto update_return;
+	}
+
 	if (coal_intvl < CPSW_CMINTMIN_INTVL)
 		coal_intvl = CPSW_CMINTMIN_INTVL;
 
@@ -919,6 +921,8 @@ static int cpsw_set_coalesce(struct net_device *ndev,
 	int_ctrl |= CPSW_INTPACEEN;
 	int_ctrl &= (~CPSW_INTPRESCALE_MASK);
 	int_ctrl |= (prescale & CPSW_INTPRESCALE_MASK);
+
+update_return:
 	writel(int_ctrl, &priv->wr_regs->int_control);
 
 	cpsw_notice(priv, timer, "Set coalesce to %d usecs.\n", coal_intvl);
-- 
2.0.0.390.gcb682f8
