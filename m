From: sunil.kovvuri@gmail.com
Subject: [PATCH 2/4] net: thunderx: Add ethtool support for supported ports
 and link modes.
Date: Thu, 24 Nov 2016 14:48:01 +0530
Message-ID: <1479979083-15963-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1479979083-15963-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>,
 Thanneeru Srinivasulu <tsrinivasulu@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1479979083-15963-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |  2 ++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  1 +
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 36 ++++++++++++++++++++--
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |  1 +
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  1 +
 5 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 86bd93c..be8404a 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -292,6 +292,7 @@ struct nicvf {
 	u8			node;
 	u8			cpi_alg;
 	bool			link_up;
+	u8			mac_type;
 	u8			duplex;
 	u32			speed;
 	bool			tns_mode;
@@ -446,6 +447,7 @@ struct bgx_stats_msg {
 /* Physical interface link status */
 struct bgx_link_status {
 	u8    msg;
+	u8    mac_type;
 	u8    link_up;
 	u8    duplex;
 	u32   speed;
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 6677b96..b87d416 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -1258,6 +1258,7 @@ static void nic_poll_for_link(struct work_struct *work)
 			mbx.link_status.link_up = link.link_up;
 			mbx.link_status.duplex = link.duplex;
 			mbx.link_status.speed = link.speed;
+			mbx.link_status.mac_type = link.mac_type;
 			nic_send_msg_to_vf(nic, vf, &mbx);
 		}
 	}
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index 432bf6b..d4d76a7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -130,12 +130,42 @@ static int nicvf_get_settings(struct net_device *netdev,
 		return 0;
 	}
 
-	if (nic->speed <= 1000) {
-		cmd->port = PORT_MII;
+	switch (nic->speed) {
+	case SPEED_1000:
+		cmd->port = PORT_MII | PORT_TP;
 		cmd->autoneg = AUTONEG_ENABLE;
-	} else {
+		cmd->supported |= SUPPORTED_MII | SUPPORTED_TP;
+		cmd->supported |= SUPPORTED_1000baseT_Full |
+				  SUPPORTED_1000baseT_Half |
+				  SUPPORTED_100baseT_Full  |
+				  SUPPORTED_100baseT_Half  |
+				  SUPPORTED_10baseT_Full   |
+				  SUPPORTED_10baseT_Half;
+		cmd->supported |= SUPPORTED_Autoneg;
+		cmd->advertising |= ADVERTISED_1000baseT_Full |
+				    ADVERTISED_1000baseT_Half |
+				    ADVERTISED_100baseT_Full  |
+				    ADVERTISED_100baseT_Half  |
+				    ADVERTISED_10baseT_Full   |
+				    ADVERTISED_10baseT_Half;
+		break;
+	case SPEED_10000:
+		if (nic->mac_type == BGX_MODE_RXAUI) {
+			cmd->port = PORT_TP;
+			cmd->supported |= SUPPORTED_TP;
+		} else {
+			cmd->port = PORT_FIBRE;
+			cmd->supported |= SUPPORTED_FIBRE;
+		}
+		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->supported |= SUPPORTED_10000baseT_Full;
+		break;
+	case SPEED_40000:
 		cmd->port = PORT_FIBRE;
 		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->supported |= SUPPORTED_FIBRE;
+		cmd->supported |= SUPPORTED_40000baseCR4_Full;
+		break;
 	}
 	cmd->duplex = nic->duplex;
 	ethtool_cmd_speed_set(cmd, nic->speed);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 7c2c373..c6c2303 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -221,6 +221,7 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nic->link_up = mbx.link_status.link_up;
 		nic->duplex = mbx.link_status.duplex;
 		nic->speed = mbx.link_status.speed;
+		nic->mac_type = mbx.link_status.mac_type;
 		if (nic->link_up) {
 			netdev_info(nic->netdev, "%s: Link is Up %d Mbps %s\n",
 				    nic->netdev->name, nic->speed,
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 1d6214b..29c727f 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -161,6 +161,7 @@ void bgx_get_lmac_link_state(int node, int bgx_idx, int lmacid, void *status)
 		return;
 
 	lmac = &bgx->lmac[lmacid];
+	link->mac_type = lmac->lmac_type;
 	link->link_up = lmac->link_up;
 	link->duplex = lmac->last_duplex;
 	link->speed = lmac->last_speed;
-- 
2.7.4
