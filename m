From: Sekhar Nori <nsekhar@ti.com>
Subject: [PATCH] net: ethernet: ti: cpsw: fix race condition during open()
Date: Mon, 3 Apr 2017 17:34:28 +0530
Message-ID: <509439ff3e756ea1dade2738e305f08fc7920650.1491220439.git.nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Grygorii Strashko <grygorii.strashko@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:12866 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdDCMFA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 08:05:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TI's cpsw driver handles both OF and non-OF case for phy
connect. Unfortunately of_phy_connect() returns NULL on
error while phy_connect() returns ERR_PTR().

To handle this, cpsw_slave_open() overrides the return value
from phy_connect() to make it NULL or error.

This leaves a small window, where cpsw_adjust_link() may be
invoked for a slave while slave->phy pointer is temporarily
set to -ENODEV (or some other error) before it is finally set
to NULL.

_cpsw_adjust_link() only handles the NULL case, and an oops
results when ERR_PTR() is seen by it.

Note that cpsw_adjust_link() checks PHY status for each
slave whenever it is invoked. It can so happen that even
though phy_connect() for a given slave returns error,
_cpsw_adjust_link() is still called for that slave because
the link status of another slave changed.

Fix this by using a temporary pointer to store return value
of {of_}phy_connect() and do a one-time write to slave->phy.

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>
Reported-by: Yan Liu <yan-liu@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 9f3d9c67e3fe..5a4faa4489d0 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1267,6 +1267,7 @@ static void soft_reset_slave(struct cpsw_slave *slave)
 static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 {
 	u32 slave_port;
+	struct phy_device *phy;
 	struct cpsw_common *cpsw = priv->cpsw;
 
 	soft_reset_slave(slave);
@@ -1300,27 +1301,28 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 	if (slave->data->phy_node) {
-		slave->phy = of_phy_connect(priv->ndev, slave->data->phy_node,
+		phy = of_phy_connect(priv->ndev, slave->data->phy_node,
 				 &cpsw_adjust_link, 0, slave->data->phy_if);
-		if (!slave->phy) {
+		if (!phy) {
 			dev_err(priv->dev, "phy \"%s\" not found on slave %d\n",
 				slave->data->phy_node->full_name,
 				slave->slave_num);
 			return;
 		}
 	} else {
-		slave->phy = phy_connect(priv->ndev, slave->data->phy_id,
+		phy = phy_connect(priv->ndev, slave->data->phy_id,
 				 &cpsw_adjust_link, slave->data->phy_if);
-		if (IS_ERR(slave->phy)) {
+		if (IS_ERR(phy)) {
 			dev_err(priv->dev,
 				"phy \"%s\" not found on slave %d, err %ld\n",
 				slave->data->phy_id, slave->slave_num,
-				PTR_ERR(slave->phy));
-			slave->phy = NULL;
+				PTR_ERR(phy));
 			return;
 		}
 	}
 
+	slave->phy = phy;
+
 	phy_attached_info(slave->phy);
 
 	phy_start(slave->phy);
-- 
2.9.0
