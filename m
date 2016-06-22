From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 12/13] liquidio: Support priv flag
Date: Tue, 21 Jun 2016 22:53:14 -0700
Message-ID: <1466574795-4306-13-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0091.outbound.protection.outlook.com ([65.55.169.91]:52906
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750721AbcFVGLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 02:11:25 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for private flags for the driver.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c   | 19 +++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c      |  1 +
 drivers/net/ethernet/cavium/liquidio/octeon_device.h | 15 +++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 85f5d17..03bfa97 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -1683,6 +1683,23 @@ static void lio_get_regs(struct net_device *dev,
 	}
 }
 
+static u32 lio_get_priv_flags(struct net_device *netdev)
+{
+	struct lio *lio = GET_LIO(netdev);
+
+	return lio->oct_dev->priv_flags;
+}
+
+static int lio_set_priv_flags(struct net_device *netdev, u32 flags)
+{
+	struct lio *lio = GET_LIO(netdev);
+	bool intr_by_tx_bytes = !!(flags & (0x1 << OCT_PRIV_FLAG_TX_BYTES));
+
+	lio_set_priv_flag(lio->oct_dev, OCT_PRIV_FLAG_TX_BYTES,
+			  intr_by_tx_bytes);
+	return 0;
+}
+
 static const struct ethtool_ops lio_ethtool_ops = {
 	.get_settings		= lio_get_settings,
 	.get_link		= ethtool_op_get_link,
@@ -1704,6 +1721,8 @@ static const struct ethtool_ops lio_ethtool_ops = {
 	.set_settings		= lio_set_settings,
 	.get_coalesce		= lio_get_intr_coalesce,
 	.set_coalesce		= lio_set_intr_coalesce,
+	.get_priv_flags		= lio_get_priv_flags,
+	.set_priv_flags		= lio_set_priv_flags,
 	.get_ts_info		= lio_get_ts_info,
 };
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 9f97d11..a8328f2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3535,6 +3535,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		/* Register ethtool support */
 		liquidio_set_ethtool_ops(netdev);
+		octeon_dev->priv_flags = 0x0;
 
 		if (netdev->features & NETIF_F_LRO)
 		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 95b4eb7..b4e566d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -400,6 +400,8 @@ struct octeon_device {
 
 	struct oct_link_stats link_stats; /*stastics from firmware*/
 
+	/* private flags to control driver-specific features through ethtool */
+	u32 priv_flags;
 };
 
 #define  OCT_DRV_ONLINE 1
@@ -660,4 +662,17 @@ void *oct_get_config_info(struct octeon_device *oct, u16 card_type);
  */
 struct octeon_config *octeon_get_conf(struct octeon_device *oct);
 
+/* LiquidIO driver pivate flags */
+enum {
+	OCT_PRIV_FLAG_TX_BYTES = 0, /* Tx interrupts by pending byte count */
+};
+
+static inline void lio_set_priv_flag(struct octeon_device *octdev, u32 flag,
+				     u32 val)
+{
+	if (val)
+		octdev->priv_flags |= (0x1 << flag);
+	else
+		octdev->priv_flags &= ~(0x1 << flag);
+}
 #endif
-- 
1.8.3.1
