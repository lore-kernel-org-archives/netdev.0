From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/16] sfc: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:45:52 +0000
Message-ID: <1386287152.1516.129.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34800 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869Ab3LEXp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:45:56 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |  4 +++-
 drivers/net/ethernet/sfc/nic.h |  3 ++-
 drivers/net/ethernet/sfc/ptp.c | 11 ++++++++++-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 07c9bc4c61bc..22ca5cd3f722 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1857,7 +1857,9 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 	struct mii_ioctl_data *data = if_mii(ifr);
 
 	if (cmd == SIOCSHWTSTAMP)
-		return efx_ptp_ioctl(efx, ifr, cmd);
+		return efx_ptp_set_ts_config(efx, ifr);
+	if (cmd == SIOCGHWTSTAMP)
+		return efx_ptp_get_ts_config(efx, ifr);
 
 	/* Convert phy_id from older PRTAD/DEVAD format */
 	if ((cmd == SIOCGMIIREG || cmd == SIOCSMIIREG) &&
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 11b6112d9249..33852e824f12 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -555,7 +555,8 @@ int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
 
 struct ethtool_ts_info;
 void efx_ptp_probe(struct efx_nic *efx);
-int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd);
+int efx_ptp_set_ts_config(struct efx_nic *efx, struct ifreq *ifr);
+int efx_ptp_get_ts_config(struct efx_nic *efx, struct ifreq *ifr);
 void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info);
 bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 03acf57df045..afd4d3a50460 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1231,7 +1231,7 @@ void efx_ptp_get_ts_info(struct efx_nic *efx, struct ethtool_ts_info *ts_info)
 			       1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ);
 }
 
-int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)
+int efx_ptp_set_ts_config(struct efx_nic *efx, struct ifreq *ifr)
 {
 	struct hwtstamp_config config;
 	int rc;
@@ -1251,6 +1251,15 @@ int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)
 		? -EFAULT : 0;
 }
 
+int efx_ptp_get_ts_config(struct efx_nic *efx, struct ifreq *ifr)
+{
+	if (!efx->ptp_data)
+		return -EOPNOTSUPP;
+
+	return copy_to_user(ifr->ifr_data, &efx->ptp_data->config,
+			    sizeof(efx->ptp_data->config)) ? -EFAULT : 0;
+}
+
 static void ptp_event_failure(struct efx_nic *efx, int expected_frag_len)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
