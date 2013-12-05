From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] ti_cpsw: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:56:32 +0000
Message-ID: <1386287792.1516.140.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6774 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756443Ab3LEX4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:56:36 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is untested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/ti/cpsw.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7536a4c01293..bc0cb154fc53 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1322,7 +1322,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 	__raw_writel(ETH_P_1588, &priv->regs->ts_ltype);
 }
 
-static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
+static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
 {
 	struct cpsw_priv *priv = netdev_priv(dev);
 	struct cpts *cpts = priv->cpts;
@@ -1383,6 +1383,24 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
 
+static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
+{
+	struct cpsw_priv *priv = netdev_priv(dev);
+	struct cpts *cpts = priv->cpts;
+	struct hwtstamp_config cfg;
+
+	if (priv->version != CPSW_VERSION_1 &&
+	    priv->version != CPSW_VERSION_2)
+		return -EOPNOTSUPP;
+
+	cfg.flags = 0;
+	cfg.tx_type = cpts->tx_enable ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	cfg.rx_filter = (cpts->rx_enable ?
+			 HWTSTAMP_FILTER_PTP_V2_EVENT : HWTSTAMP_FILTER_NONE);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
 #endif /*CONFIG_TI_CPTS*/
 
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
@@ -1397,7 +1415,9 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	switch (cmd) {
 #ifdef CONFIG_TI_CPTS
 	case SIOCSHWTSTAMP:
-		return cpsw_hwtstamp_ioctl(dev, req);
+		return cpsw_hwtstamp_set(dev, req);
+	case SIOCGHWTSTAMP:
+		return cpsw_hwtstamp_get(dev, req);
 #endif
 	case SIOCGMIIPHY:
 		data->phy_id = priv->slaves[slave_no].phy->addr;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
