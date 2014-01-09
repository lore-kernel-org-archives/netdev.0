From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/2] qlcnic: Fix ethtool statistics length calculation
Date: Thu, 9 Jan 2014 12:41:05 -0500
Message-ID: <1389289265-9586-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1389289265-9586-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:51942 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756446AbaAISPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:15:02 -0500
In-Reply-To: <1389289265-9586-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Consider number of Tx queues while calculating the length of
  Tx statistics as part of ethtool stats.
o Calculate statistics lenght properly for 82xx and 83xx adapter

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    | 39 ++++++++++++----------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 7b36340..6b08194 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -167,27 +167,35 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
 
-static inline int qlcnic_82xx_statistics(void)
+static inline int qlcnic_82xx_statistics(struct qlcnic_adapter *adapter)
 {
-	return ARRAY_SIZE(qlcnic_device_gstrings_stats) +
-	       ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
+	return ARRAY_SIZE(qlcnic_gstrings_stats) +
+	       ARRAY_SIZE(qlcnic_83xx_mac_stats_strings) +
+	       QLCNIC_TX_STATS_LEN * adapter->drv_tx_rings;
 }
 
-static inline int qlcnic_83xx_statistics(void)
+static inline int qlcnic_83xx_statistics(struct qlcnic_adapter *adapter)
 {
-	return ARRAY_SIZE(qlcnic_83xx_tx_stats_strings) +
+	return ARRAY_SIZE(qlcnic_gstrings_stats) +
+	       ARRAY_SIZE(qlcnic_83xx_tx_stats_strings) +
 	       ARRAY_SIZE(qlcnic_83xx_mac_stats_strings) +
-	       ARRAY_SIZE(qlcnic_83xx_rx_stats_strings);
+	       ARRAY_SIZE(qlcnic_83xx_rx_stats_strings) +
+	       QLCNIC_TX_STATS_LEN * adapter->drv_tx_rings;
 }
 
 static int qlcnic_dev_statistics_len(struct qlcnic_adapter *adapter)
 {
-	if (qlcnic_82xx_check(adapter))
-		return qlcnic_82xx_statistics();
-	else if (qlcnic_83xx_check(adapter))
-		return qlcnic_83xx_statistics();
-	else
-		return -1;
+	int len = -1;
+
+	if (qlcnic_82xx_check(adapter)) {
+		len = qlcnic_82xx_statistics(adapter);
+		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
+			len += ARRAY_SIZE(qlcnic_device_gstrings_stats);
+	} else if (qlcnic_83xx_check(adapter)) {
+		len = qlcnic_83xx_statistics(adapter);
+	}
+
+	return len;
 }
 
 #define	QLCNIC_TX_INTR_NOT_CONFIGURED	0X78563412
@@ -920,18 +928,13 @@ static int qlcnic_eeprom_test(struct net_device *dev)
 
 static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 {
-	int len;
 
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	switch (sset) {
 	case ETH_SS_TEST:
 		return QLCNIC_TEST_LEN;
 	case ETH_SS_STATS:
-		len = qlcnic_dev_statistics_len(adapter) + QLCNIC_STATS_LEN;
-		if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
-		    qlcnic_83xx_check(adapter))
-			return len;
-		return qlcnic_82xx_statistics();
+		return qlcnic_dev_statistics_len(adapter);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
1.8.1.4
