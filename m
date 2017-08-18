From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH net-next 2/3] net: hns3: Fixes the static checker error warning in hns3_get_link_ksettings()
Date: Fri, 18 Aug 2017 12:31:38 +0100
Message-ID: <20170818113139.153200-3-salil.mehta@huawei.com>
References: <20170818113139.153200-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <lipeng321@huawei.com>, <dan.carpenter@oracle.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linuxarm@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818113139.153200-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the static check error warning in hns3_get_link_ksettings()
function by re-arranging the code.

Fixes: 496d03e960ae ("net: hns3: Add Ethtool support to HNS3 Driver")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
 .../ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c  | 85 ++++++++++++----------
 1 file changed, 48 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
index 0ad65e4..ffc837b 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_ethtool.c
@@ -313,7 +313,7 @@ static int hns3_get_link_ksettings(struct net_device *netdev,
 	if (!h->ae_algo || !h->ae_algo->ops)
 		return -EOPNOTSUPP;
 
-	/* 1.auto_neg&speed&duplex from cmd */
+	/* 1.auto_neg & speed & duplex from cmd */
 	if (h->ae_algo->ops->get_ksettings_an_result) {
 		h->ae_algo->ops->get_ksettings_an_result(h, &auto_neg,
 							 &speed, &duplex);
@@ -329,50 +329,61 @@ static int hns3_get_link_ksettings(struct net_device *netdev,
 	}
 
 	/* 2.media_type get from bios parameter block */
-	if (h->ae_algo->ops->get_media_type)
+	if (h->ae_algo->ops->get_media_type) {
 		h->ae_algo->ops->get_media_type(h, &media_type);
 
-	switch (media_type) {
-	case HNAE3_MEDIA_TYPE_FIBER:
-		cmd->base.port = PORT_FIBRE;
-		supported_caps = HNS3_LM_FIBRE_BIT | HNS3_LM_AUTONEG_BIT |
-			HNS3_LM_PAUSE_BIT | HNS3_LM_1000BASET_FULL_BIT;
+		switch (media_type) {
+		case HNAE3_MEDIA_TYPE_FIBER:
+			cmd->base.port = PORT_FIBRE;
+			supported_caps = HNS3_LM_FIBRE_BIT |
+					 HNS3_LM_AUTONEG_BIT |
+					 HNS3_LM_PAUSE_BIT |
+					 HNS3_LM_1000BASET_FULL_BIT;
+
+			advertised_caps = supported_caps;
+			break;
+		case HNAE3_MEDIA_TYPE_COPPER:
+			cmd->base.port = PORT_TP;
+			supported_caps = HNS3_LM_TP_BIT |
+					 HNS3_LM_AUTONEG_BIT |
+					 HNS3_LM_PAUSE_BIT |
+					 HNS3_LM_1000BASET_FULL_BIT |
+					 HNS3_LM_100BASET_FULL_BIT |
+					 HNS3_LM_100BASET_HALF_BIT |
+					 HNS3_LM_10BASET_FULL_BIT |
+					 HNS3_LM_10BASET_HALF_BIT;
+			advertised_caps = supported_caps;
+			break;
+		case HNAE3_MEDIA_TYPE_BACKPLANE:
+			cmd->base.port = PORT_NONE;
+			supported_caps = HNS3_LM_BACKPLANE_BIT |
+					 HNS3_LM_PAUSE_BIT |
+					 HNS3_LM_AUTONEG_BIT |
+					 HNS3_LM_1000BASET_FULL_BIT |
+					 HNS3_LM_100BASET_FULL_BIT |
+					 HNS3_LM_100BASET_HALF_BIT |
+					 HNS3_LM_10BASET_FULL_BIT |
+					 HNS3_LM_10BASET_HALF_BIT;
+
+			advertised_caps = supported_caps;
+			break;
+		case HNAE3_MEDIA_TYPE_UNKNOWN:
+		default:
+			cmd->base.port = PORT_OTHER;
+			supported_caps = 0;
+			advertised_caps = 0;
+			break;
+		}
 
-		advertised_caps = supported_caps;
-		break;
-	case HNAE3_MEDIA_TYPE_COPPER:
-		cmd->base.port = PORT_TP;
-		supported_caps = HNS3_LM_TP_BIT | HNS3_LM_AUTONEG_BIT |
-			HNS3_LM_PAUSE_BIT | HNS3_LM_1000BASET_FULL_BIT |
-			HNS3_LM_100BASET_FULL_BIT | HNS3_LM_100BASET_HALF_BIT |
-			HNS3_LM_10BASET_FULL_BIT | HNS3_LM_10BASET_HALF_BIT;
-		advertised_caps = supported_caps;
-		break;
-	case HNAE3_MEDIA_TYPE_BACKPLANE:
-		cmd->base.port = PORT_NONE;
-		supported_caps = HNS3_LM_BACKPLANE_BIT | HNS3_LM_PAUSE_BIT |
-			HNS3_LM_AUTONEG_BIT | HNS3_LM_1000BASET_FULL_BIT |
-			HNS3_LM_100BASET_FULL_BIT | HNS3_LM_100BASET_HALF_BIT |
-			HNS3_LM_10BASET_FULL_BIT | HNS3_LM_10BASET_HALF_BIT;
-
-		advertised_caps = supported_caps;
-		break;
-	case HNAE3_MEDIA_TYPE_UNKNOWN:
-	default:
-		cmd->base.port = PORT_OTHER;
-		supported_caps = 0;
-		advertised_caps = 0;
-		break;
+		/* now, map driver link modes to ethtool link modes */
+		hns3_driv_to_eth_caps(supported_caps, cmd, false);
+		hns3_driv_to_eth_caps(advertised_caps, cmd, true);
 	}
 
-	/* now, map driver link modes to ethtool link modes */
-	hns3_driv_to_eth_caps(supported_caps, cmd, false);
-	hns3_driv_to_eth_caps(advertised_caps, cmd, true);
-
 	/* 3.mdix_ctrl&mdix get from phy reg */
 	if (h->ae_algo->ops->get_mdix_mode)
 		h->ae_algo->ops->get_mdix_mode(h, &cmd->base.eth_tp_mdix_ctrl,
-			&cmd->base.eth_tp_mdix);
+					       &cmd->base.eth_tp_mdix);
 	/* 4.mdio_support */
 	cmd->base.mdio_support = ETH_MDIO_SUPPORTS_C22;
 
-- 
2.7.4
