From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH v2] net: ethernet: ti/cpsw: do not crash on single-MAC machines during resume
Date: Fri, 15 Nov 2013 08:29:16 +0100
Message-ID: <1384500556-11634-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, mugunthanvnm@ti.com, ujhelyi.m@gmail.com,
	sergei.shtylyov@cogentembedded.com, Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:35863 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab3KOH3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:29:23 -0500
Received: by mail-bk0-f45.google.com with SMTP id r7so1469124bkg.4
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 23:29:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During resume, use for_each_slave to walk the slaves of the cpsw, and
soft-reset each of them. This prevents oopses if there is only one
slave configured.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index edd3e79..afb91ac 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -967,14 +967,19 @@ static inline void cpsw_add_dual_emac_def_ale_entries(
 		priv->host_port, ALE_VLAN, slave->port_vlan);
 }
 
-static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
+static void soft_reset_slave(struct cpsw_slave *slave)
 {
 	char name[32];
-	u32 slave_port;
-
-	sprintf(name, "slave-%d", slave->slave_num);
 
+	snprintf(name, sizeof(name), "slave-%d", slave->slave_num);
 	soft_reset(name, &slave->sliver->soft_reset);
+}
+
+static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
+{
+	u32 slave_port;
+
+	soft_reset_slave(slave);
 
 	/* setup priority mapping */
 	__raw_writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
@@ -2173,8 +2178,9 @@ static int cpsw_suspend(struct device *dev)
 
 	if (netif_running(ndev))
 		cpsw_ndo_stop(ndev);
-	soft_reset("sliver 0", &priv->slaves[0].sliver->soft_reset);
-	soft_reset("sliver 1", &priv->slaves[1].sliver->soft_reset);
+
+	for_each_slave(priv, soft_reset_slave);
+
 	pm_runtime_put_sync(&pdev->dev);
 
 	/* Select sleep pin state */
-- 
1.8.4.2
