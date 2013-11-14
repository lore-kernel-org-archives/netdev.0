From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC][PATCH 3/3] sfc: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 14 Nov 2013 02:40:00 +0000
Message-ID: <1384396800.29151.39.camel@bwh-desktop.uk.level5networks.com>
References: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:24772 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab3KNCkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:40:03 -0500
In-Reply-To: <1384396635.29151.36.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |  2 +-
 drivers/net/ethernet/sfc/ptp.c | 14 +++++++++-----
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 07c9bc4c61bc..d5fbac313bf7 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1856,7 +1856,7 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 
-	if (cmd == SIOCSHWTSTAMP)
+	if (cmd == SIOCGHWTSTAMP || cmd == SIOCSHWTSTAMP)
 		return efx_ptp_ioctl(efx, ifr, cmd);
 
 	/* Convert phy_id from older PRTAD/DEVAD format */
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 03acf57df045..ba14a4d95dfb 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1240,12 +1240,16 @@ int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)
 	if (!efx->ptp_data)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
-		return -EFAULT;
+	if (cmd == SIOCSHWTSTAMP) {
+		if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+			return -EFAULT;
 
-	rc = efx_ptp_ts_init(efx, &config);
-	if (rc != 0)
-		return rc;
+		rc = efx_ptp_ts_init(efx, &config);
+		if (rc != 0)
+			return rc;
+	} else {
+		config = efx->ptp_data->config;
+	}
 
 	return copy_to_user(ifr->ifr_data, &config, sizeof(config))
 		? -EFAULT : 0;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
