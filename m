From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 5/6] ti_cpsw: Validate hwtstamp_config completely before
 applying it
Date: Thu, 14 Nov 2013 00:47:36 +0000
Message-ID: <1384390056.29151.12.camel@bwh-desktop.uk.level5networks.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15160 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521Ab3KNArk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 19:47:40 -0500
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpsw_hwtstamp_ioctl() should validate all fields of hwtstamp_config,
and the hardware version, before making any changes.  Currently it
sets the TX configuration before validating the rx_filter field
or that the hardware supports timestamping.

Also correct the error code for hardware versions that don't
support timestamping.  ENOTSUPP is used by the NFS implementation
and is not part of userland API; we want EOPNOTSUPP (which glibc
also calls ENOTSUP, with one 'P').

Untested as I don't have a cross-compiler to hand.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/ti/cpsw.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index cc3ce557e4aa..8bda244df0fb 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1321,6 +1321,10 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	struct cpts *cpts = priv->cpts;
 	struct hwtstamp_config cfg;
 
+	if (priv->version != CPSW_VERSION_1 &&
+	    priv->version != CPSW_VERSION_2)
+		return -EOPNOTSUPP;
+
 	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
 		return -EFAULT;
 
@@ -1328,16 +1332,8 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 	if (cfg.flags)
 		return -EINVAL;
 
-	switch (cfg.tx_type) {
-	case HWTSTAMP_TX_OFF:
-		cpts->tx_enable = 0;
-		break;
-	case HWTSTAMP_TX_ON:
-		cpts->tx_enable = 1;
-		break;
-	default:
+	if (cfg.tx_type != HWTSTAMP_TX_OFF && cfg.tx_type != HWTSTAMP_TX_ON)
 		return -ERANGE;
-	}
 
 	switch (cfg.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
@@ -1364,6 +1360,8 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		return -ERANGE;
 	}
 
+	cpts->tx_enable = cfg.tx_type == HWTSTAMP_TX_ON;
+
 	switch (priv->version) {
 	case CPSW_VERSION_1:
 		cpsw_hwtstamp_v1(priv);
@@ -1372,7 +1370,7 @@ static int cpsw_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		cpsw_hwtstamp_v2(priv);
 		break;
 	default:
-		return -ENOTSUPP;
+		WARN_ON(1);
 	}
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
