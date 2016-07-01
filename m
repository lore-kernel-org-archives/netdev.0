From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH v3 net-next 8/9] net: hns: add media-type property for hns
Date: Fri, 1 Jul 2016 17:34:12 +0800
Message-ID: <1467365653-83331-9-git-send-email-Yisen.Zhuang@huawei.com>
References: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <akpm@linux-foundation.org>, <gregkh@linuxfoundation.org>,
	<kvalo@codeaurora.org>, <mchehab@osg.samsung.com>,
	<linux@roeck-us.net>, <jslaby@suse.cz>, <yankejian@huawei.com>,
	<huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
	<xieqianqian@huawei.com>, <arnd@arndb.de>, <andrew@lunn.ch>,
	<xypron.glpk@gmx.de>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467365653-83331-1-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kejian Yan <yankejian@huawei.com>

It is PORT_TP type if the service port is GE mode. It is wrong to
judge the port type by using if it is service port. Adding the media
type to know port type.

Reported-by: Jinchuan Tian <tianjinchuan1@huawei.com>
Signed-off-by: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hnae.h         |  9 ++++++++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c | 26 +++++++++++++++++++++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 14 +++++++++---
 5 files changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
index 3869322..e093cbf 100644
--- a/drivers/net/ethernet/hisilicon/hns/hnae.h
+++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
@@ -363,6 +363,14 @@ enum hnae_port_type {
 	HNAE_PORT_DEBUG
 };
 
+/* mac media type */
+enum hnae_media_type {
+	HNAE_MEDIA_TYPE_UNKNOWN = 0,
+	HNAE_MEDIA_TYPE_FIBER,
+	HNAE_MEDIA_TYPE_COPPER,
+	HNAE_MEDIA_TYPE_BACKPLANE,
+};
+
 /* This struct defines the operation on the handle.
  *
  * get_handle(): (mandatory)
@@ -525,6 +533,7 @@ struct hnae_handle {
 	u32 eport_id;
 	u32 dport_id;	/* v2 tx bd should fill the dport_id */
 	enum hnae_port_type port_type;
+	enum hnae_media_type media_type;
 	struct list_head node;    /* list to hnae_ae_dev->handle_list */
 	struct hnae_buf_ops *bops; /* operation for the buffer */
 	struct hnae_queue **qs;  /* array base of all queues */
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index 835521b..e28d960 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -134,6 +134,7 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 	ae_handle->phy_dev = vf_cb->mac_cb->phy_dev;
 	ae_handle->if_support = vf_cb->mac_cb->if_support;
 	ae_handle->port_type = vf_cb->mac_cb->mac_type;
+	ae_handle->media_type = vf_cb->mac_cb->media_type;
 	ae_handle->dport_id = port_id;
 
 	return ae_handle;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index d2effcc..3fb87e2 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -733,6 +733,18 @@ static void hns_mac_register_phy(struct hns_mac_cb *mac_cb)
 			mac_cb->mac_id, addr);
 }
 
+#define MAC_MEDIA_TYPE_MAX_LEN		16
+
+static const struct {
+	enum hnae_media_type value;
+	const char *name;
+} media_type_defs[] = {
+	{HNAE_MEDIA_TYPE_UNKNOWN,	"unknown" },
+	{HNAE_MEDIA_TYPE_FIBER,		"fiber" },
+	{HNAE_MEDIA_TYPE_COPPER,	"copper" },
+	{HNAE_MEDIA_TYPE_BACKPLANE,	"backplane" },
+};
+
 /**
  *hns_mac_get_info  - get mac information from device node
  *@mac_cb: mac device
@@ -744,10 +756,13 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 	struct device_node *np;
 	struct regmap *syscon;
 	struct of_phandle_args cpld_args;
+	const char *media_type;
+	u32 i;
 	u32 ret;
 
 	mac_cb->link = false;
 	mac_cb->half_duplex = false;
+	mac_cb->media_type = HNAE_MEDIA_TYPE_UNKNOWN;
 	mac_cb->speed = mac_phy_to_speed[mac_cb->phy_if];
 	mac_cb->max_speed = mac_cb->speed;
 
@@ -849,6 +864,17 @@ static int  hns_mac_get_info(struct hns_mac_cb *mac_cb)
 			mac_cb->mac_id);
 	}
 
+	if (!fwnode_property_read_string(mac_cb->fw_port, "media-type",
+					 &media_type)) {
+		for (i = 0; i < ARRAY_SIZE(media_type_defs); i++) {
+			if (!strncmp(media_type_defs[i].name, media_type,
+				     MAC_MEDIA_TYPE_MAX_LEN)) {
+				mac_cb->media_type = media_type_defs[i].value;
+				break;
+			}
+		}
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
index 05a6e8f..4cbdf14 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h
@@ -335,6 +335,7 @@ struct hns_mac_cb {
 	u64 txpkt_for_led;
 	u64 rxpkt_for_led;
 	enum hnae_port_type mac_type;
+	enum hnae_media_type media_type;
 	phy_interface_t phy_if;
 	enum hnae_loop loop_mode;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index a395ca1..ab33487 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -165,13 +165,21 @@ static int hns_nic_get_settings(struct net_device *net_dev,
 		cmd->advertising |= ADVERTISED_10000baseKR_Full;
 	}
 
-	if (h->port_type == HNAE_PORT_SERVICE) {
+	switch (h->media_type) {
+	case HNAE_MEDIA_TYPE_FIBER:
 		cmd->port = PORT_FIBRE;
-		cmd->supported |= SUPPORTED_Pause;
-	} else {
+		break;
+	case HNAE_MEDIA_TYPE_COPPER:
 		cmd->port = PORT_TP;
+		break;
+	case HNAE_MEDIA_TYPE_UNKNOWN:
+	default:
+		break;
 	}
 
+	if (!(AE_IS_VER1(priv->enet_ver) && h->port_type == HNAE_PORT_DEBUG))
+		cmd->supported |= SUPPORTED_Pause;
+
 	cmd->transceiver = XCVR_EXTERNAL;
 	cmd->mdio_support = (ETH_MDIO_SUPPORTS_C45 | ETH_MDIO_SUPPORTS_C22);
 	hns_get_mdix_mode(net_dev, cmd);
-- 
1.9.1
