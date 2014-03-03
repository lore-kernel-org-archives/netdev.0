From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 1/1] net: cpsw: fix cpdma rx descriptor leak on down interface
Date: Mon, 3 Mar 2014 16:19:06 +0530
Message-ID: <1393843746-6554-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Schuyler Patton <spatton@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:49658 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbaCCKtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 05:49:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Schuyler Patton <spatton@ti.com>

This patch fixes a CPDMA RX Descriptor leak that occurs after taking
the interface down when the CPSW is in Dual MAC mode. Previously
the CPSW_ALE port was left open up which causes packets to be received
and processed by the RX interrupt handler and were passed to the
non active network interface where they were ignored.

The fix is for the slave_stop function of the selected interface
to disable the respective CPSW_ALE Port from forwarding packets. This
blocks traffic from being received on the inactive interface.

Signed-off-by: Schuyler Patton <spatton@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 651087b..ffd4d12 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1164,11 +1164,17 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 
 static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
+	u32 slave_port;
+
+	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
+
 	if (!slave->phy)
 		return;
 	phy_stop(slave->phy);
 	phy_disconnect(slave->phy);
 	slave->phy = NULL;
+	cpsw_ale_control_set(priv->ale, slave_port,
+			     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
 }
 
 static int cpsw_ndo_open(struct net_device *ndev)
-- 
1.9.0
