From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 4/8] netdev: octeon_mgmt: Improve ethtool_ops.
Date: Tue, 21 Aug 2012 11:45:08 -0700
Message-ID: <1345574712-21444-5-git-send-email-ddaney.cavm@gmail.com>
References: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1345574712-21444-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Correctly show no link when the interface is down, and return
-EOPNOTSUPP for things that don't work.  This quiets the ethtool
program when run on down interfaces.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/octeon/octeon_mgmt.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 687a6a0..cf06cf2 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1379,7 +1379,7 @@ static int octeon_mgmt_get_settings(struct net_device *netdev,
 	if (p->phydev)
 		return phy_ethtool_gset(p->phydev, cmd);
 
-	return -EINVAL;
+	return -EOPNOTSUPP;
 }
 
 static int octeon_mgmt_set_settings(struct net_device *netdev,
@@ -1393,14 +1393,28 @@ static int octeon_mgmt_set_settings(struct net_device *netdev,
 	if (p->phydev)
 		return phy_ethtool_sset(p->phydev, cmd);
 
-	return -EINVAL;
+	return -EOPNOTSUPP;
+}
+
+static int octeon_mgmt_nway_reset(struct net_device *dev)
+{
+	struct octeon_mgmt *p = netdev_priv(dev);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (p->phydev)
+		return phy_start_aneg(p->phydev);
+
+	return -EOPNOTSUPP;
 }
 
 static const struct ethtool_ops octeon_mgmt_ethtool_ops = {
 	.get_drvinfo = octeon_mgmt_get_drvinfo,
-	.get_link = ethtool_op_get_link,
 	.get_settings = octeon_mgmt_get_settings,
-	.set_settings = octeon_mgmt_set_settings
+	.set_settings = octeon_mgmt_set_settings,
+	.nway_reset = octeon_mgmt_nway_reset,
+	.get_link = ethtool_op_get_link,
 };
 
 static const struct net_device_ops octeon_mgmt_ops = {
-- 
1.7.11.4
