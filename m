From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 3/3] liquidio: ethtool support for switchdev ports
Date: Wed, 25 Oct 2017 22:37:35 -0700
Message-ID: <20171026053735.GA17901@felix-thinkpad.cavium.com>
References: <20171026053641.GA17861@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        vijaya.guvva@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0066.outbound.protection.outlook.com ([104.47.33.66]:43456
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932194AbdJZFhn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 01:37:43 -0400
Content-Disposition: inline
In-Reply-To: <20171026053641.GA17861@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>

Added ethtool support for vf representor ports to return port stats and
driver info.

Signed-off-by: Vijaya Mohan Guvva <vijaya.guvva@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c | 87 +++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
index 2207956..92dcf54 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_rep.c
@@ -26,6 +26,7 @@
 #include "octeon_main.h"
 #include "octeon_network.h"
 #include <net/switchdev.h>
+#include <linux/ethtool.h>
 #include "lio_vf_rep.h"
 #include "octeon_network.h"
 
@@ -39,6 +40,91 @@ static void lio_vf_rep_get_stats64(struct net_device *dev,
 				   struct rtnl_link_stats64 *stats64);
 static int lio_vf_rep_change_mtu(struct net_device *ndev, int new_mtu);
 
+static const char lio_vf_rep_stats_strings[][ETH_GSTRING_LEN] = {
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_dropped",
+	"tx_dropped",
+};
+
+static void
+lio_vf_rep_get_drvinfo(struct net_device *ndev,
+		       struct ethtool_drvinfo *drvinfo)
+{
+	struct lio_vf_rep_desc *vf_rep = netdev_priv(ndev);
+	struct octeon_device *oct;
+
+	oct = vf_rep->oct;
+
+	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
+	strcpy(drvinfo->driver, "liquidio");
+	strcpy(drvinfo->version, LIQUIDIO_VERSION);
+	strncpy(drvinfo->fw_version, oct->fw_info.liquidio_firmware_version,
+		ETHTOOL_FWVERS_LEN);
+}
+
+static void
+lio_vf_rep_get_ethtool_stats(struct net_device *ndev,
+			     struct ethtool_stats *stats,
+			     u64 *data)
+{
+	struct rtnl_link_stats64 *stats_ptr, net_stats;
+	int i = 0;
+
+	stats_ptr = dev_get_stats(ndev, &net_stats);
+
+	data[i++] = stats_ptr->rx_packets;
+	data[i++] = stats_ptr->tx_packets;
+	data[i++] = stats_ptr->rx_bytes;
+	data[i++] = stats_ptr->tx_bytes;
+	data[i++] = stats_ptr->rx_dropped;
+	data[i++] = stats_ptr->tx_dropped;
+}
+
+static int
+lio_vf_rep_get_sset_count(struct net_device *ndev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(lio_vf_rep_stats_strings);
+
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void
+lio_vf_rep_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
+{
+	struct lio_vf_rep_desc *vf_rep = netdev_priv(ndev);
+	struct octeon_device *oct = vf_rep->oct;
+	int i, num_stats;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		num_stats = ARRAY_SIZE(lio_vf_rep_stats_strings);
+		for (i = 0; i < num_stats; i++) {
+			sprintf(data, "%s", lio_vf_rep_stats_strings[i]);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+
+	default:
+		dev_err(&oct->pci_dev->dev, "Unknown Stringset !!\n");
+		break;
+	}
+}
+
+static const struct ethtool_ops lio_vf_rep_ethtool_ops = {
+	.get_drvinfo	= lio_vf_rep_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+	.get_strings	= lio_vf_rep_get_strings,
+	.get_sset_count	= lio_vf_rep_get_sset_count,
+	.get_ethtool_stats = lio_vf_rep_get_ethtool_stats,
+};
+
 static const struct net_device_ops lio_vf_rep_ndev_ops = {
 	.ndo_open = lio_vf_rep_open,
 	.ndo_stop = lio_vf_rep_stop,
@@ -537,6 +623,7 @@ lio_vf_rep_create(struct octeon_device *oct)
 		ndev->max_mtu = LIO_MAX_MTU_SIZE;
 		ndev->netdev_ops = &lio_vf_rep_ndev_ops;
 		SWITCHDEV_SET_OPS(ndev, &lio_vf_rep_switchdev_ops);
+		ndev->ethtool_ops = &lio_vf_rep_ethtool_ops;
 
 		vf_rep = netdev_priv(ndev);
 		memset(vf_rep, 0, sizeof(*vf_rep));
-- 
2.9.0
