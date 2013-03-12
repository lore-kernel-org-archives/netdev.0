From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH v2 5/5] drivers: net: ethernet: cpsw: implement get phy_id via ioctl
Date: Tue, 12 Mar 2013 14:46:38 +0530
Message-ID: <1363079798-18147-6-git-send-email-mugunthanvnm@ti.com>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree-discuss@lists.ozlabs.org>,
	<linux-omap@vger.kernel.org>, <b-cousson@ti.com>, <paul@pwsan.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60518 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932203Ab3CLJRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 05:17:18 -0400
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement get phy_id via ioctl SIOCGMIIPHY. In switch mode active phy_id
is returned and in dual EMAC mode slave's specific phy_id is returned.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index d6cf698..8ff1d3d 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1157,14 +1157,26 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
+	struct cpsw_priv *priv = netdev_priv(dev);
+	struct mii_ioctl_data *data = if_mii(req);
+	int slave_no = cpsw_slave_index(priv);
+
 	if (!netif_running(dev))
 		return -EINVAL;
 
+	switch (cmd) {
 #ifdef CONFIG_TI_CPTS
-	if (cmd == SIOCSHWTSTAMP)
+	case SIOCSHWTSTAMP:
 		return cpsw_hwtstamp_ioctl(dev, req);
 #endif
-	return -ENOTSUPP;
+	case SIOCGMIIPHY:
+		data->phy_id = priv->slaves[slave_no].phy->addr;
+		break;
+	default:
+		return -ENOTSUPP;
+	}
+
+	return 0;
 }
 
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
-- 
1.7.9.5
