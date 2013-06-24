From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/9] sfc: Report software timestamping capabilities
Date: Mon, 24 Jun 2013 21:13:40 +0100
Message-ID: <1372104820.1896.33.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17300 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775Ab3FXUNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:13:43 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel can generate software receive timestamps and we should
report those for all ports regardless of hardware capabilities.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c | 16 +++++++++++++++-
 drivers/net/ethernet/sfc/nic.h     |  4 ++--
 drivers/net/ethernet/sfc/ptp.c     | 13 +++++--------
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 6e76817..1fc2145 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -1114,6 +1114,20 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
 	return 0;
 }
 
+int efx_ethtool_get_ts_info(struct net_device *net_dev,
+			    struct ethtool_ts_info *ts_info)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+
+	/* Software capabilities */
+	ts_info->so_timestamping = (SOF_TIMESTAMPING_RX_SOFTWARE |
+				    SOF_TIMESTAMPING_SOFTWARE);
+	ts_info->phc_index = -1;
+
+	efx_ptp_get_ts_info(efx, ts_info);
+	return 0;
+}
+
 static int efx_ethtool_get_module_eeprom(struct net_device *net_dev,
 					 struct ethtool_eeprom *ee,
 					 u8 *data)
@@ -1176,7 +1190,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_rxfh_indir_size	= efx_ethtool_get_rxfh_indir_size,
 	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
 	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
-	.get_ts_info		= efx_ptp_get_ts_info,
+	.get_ts_info		= efx_ethtool_get_ts_info,
 	.get_module_info	= efx_ethtool_get_module_info,
 	.get_module_eeprom	= efx_ethtool_get_module_eeprom,
 };
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 1b00033..d63c299 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -254,8 +254,8 @@ extern int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
 struct ethtool_ts_info;
 extern void efx_ptp_probe(struct efx_nic *efx);
 extern int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd);
-extern int efx_ptp_get_ts_info(struct net_device *net_dev,
-			       struct ethtool_ts_info *ts_info);
+extern void efx_ptp_get_ts_info(struct efx_nic *efx,
+				struct ethtool_ts_info *ts_info);
 extern bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 extern int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 extern void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 9a95abf..b495394 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1203,18 +1203,16 @@ static int efx_ptp_ts_init(struct efx_nic *efx, struct hwtstamp_config *init)
 	return 0;
 }
 
-int
-efx_ptp_get_ts_info(struct net_device *net_dev, struct ethtool_ts_info *ts_info)
+void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info)
 {
-	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_ptp_data *ptp = efx->ptp_data;
 
 	if (!ptp)
-		return -EOPNOTSUPP;
+		return;
 
-	ts_info->so_timestamping = (SOF_TIMESTAMPING_TX_HARDWARE |
-				    SOF_TIMESTAMPING_RX_HARDWARE |
-				    SOF_TIMESTAMPING_RAW_HARDWARE);
+	ts_info->so_timestamping |= (SOF_TIMESTAMPING_TX_HARDWARE |
+				     SOF_TIMESTAMPING_RX_HARDWARE |
+				     SOF_TIMESTAMPING_RAW_HARDWARE);
 	ts_info->phc_index = ptp_clock_index(ptp->phc_clock);
 	ts_info->tx_types = 1 << HWTSTAMP_TX_OFF | 1 << HWTSTAMP_TX_ON;
 	ts_info->rx_filters = (1 << HWTSTAMP_FILTER_NONE |
@@ -1224,7 +1222,6 @@ efx_ptp_get_ts_info(struct net_device *net_dev, struct ethtool_ts_info *ts_info)
 			       1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT |
 			       1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC |
 			       1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
-	return 0;
 }
 
 int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
