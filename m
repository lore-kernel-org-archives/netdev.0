From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net 2/3] enic: check return value for stat dump
Date: Thu, 11 Jun 2015 11:52:55 +0530
Message-ID: <1434003776-31840-2-git-send-email-_govind@gmx.com>
References: <1434003776-31840-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:60419 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbbFKGXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2015 02:23:36 -0400
In-Reply-To: <1434003776-31840-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not check the return value of enic_dev_stats_dump(). If allocation
fails, we will hit NULL pointer reference.

Return only if memory allocation fails. For other failures, we return the
previously recorded values.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 20 +++++++++++++++++---
 drivers/net/ethernet/cisco/enic/enic_main.c    |  9 ++++++++-
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 28d9ca6..68d47b1 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -131,8 +131,15 @@ static void enic_get_drvinfo(struct net_device *netdev,
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_devcmd_fw_info *fw_info;
+	int err;
 
-	enic_dev_fw_info(enic, &fw_info);
+	err = enic_dev_fw_info(enic, &fw_info);
+	/* return only when pci_zalloc_consistent fails in vnic_dev_fw_info
+	 * For other failures, like devcmd failure, we return previously
+	 * recorded info.
+	 */
+	if (err == -ENOMEM)
+		return;
 
 	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
@@ -181,8 +188,15 @@ static void enic_get_ethtool_stats(struct net_device *netdev,
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_stats *vstats;
 	unsigned int i;
-
-	enic_dev_stats_dump(enic, &vstats);
+	int err;
+
+	err = enic_dev_stats_dump(enic, &vstats);
+	/* return only when pci_zalloc_consistent fails in vnic_dev_stats_dump
+	 * For other failures, like devcmd failure, we return previously
+	 * recorded stats.
+	 */
+	if (err == -ENOMEM)
+		return;
 
 	for (i = 0; i < enic_n_tx_stats; i++)
 		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].index];
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 0e5a01d..eadae1b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -615,8 +615,15 @@ static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_stats *stats;
+	int err;
 
-	enic_dev_stats_dump(enic, &stats);
+	err = enic_dev_stats_dump(enic, &stats);
+	/* return only when pci_zalloc_consistent fails in vnic_dev_stats_dump
+	 * For other failures, like devcmd failure, we return previously
+	 * recorded stats.
+	 */
+	if (err == -ENOMEM)
+		return net_stats;
 
 	net_stats->tx_packets = stats->tx.tx_frames_ok;
 	net_stats->tx_bytes = stats->tx.tx_bytes_ok;
-- 
2.4.2
