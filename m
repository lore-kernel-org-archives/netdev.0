From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>
Subject: [PATCH net-next] net: cpsw: Don't handle SIOC[GS]HWTSTAMP when CPTS is disabled
Date: Wed, 30 Aug 2017 08:50:55 +0200
Message-ID: <20170830065055.419-1-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
        <stefan.sorensen@spectralink.com>
To: grygorii.strashko@ti.com, davem@davemloft.net,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0129.outbound.protection.outlook.com ([104.47.42.129]:20699
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750756AbdH3Gvb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Aug 2017 02:51:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason to handle SIOC[GS]HWTSTAMP and return -EOPNOTSUPP when
CPTS is disabled, so just pass them on to the phy. This will allow PTP
timestamping on a capable phy by disabling CPTS.

Signed-off-by: Stefan Sørensen <stefan.sorensen@spectralink.com>
---
 drivers/net/ethernet/ti/cpsw.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index db8a4bcfc6c7..4413a669fd79 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1791,16 +1791,6 @@ static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
-#else
-static int cpsw_hwtstamp_get(struct net_device *dev, struct ifreq *ifr)
-{
-	return -EOPNOTSUPP;
-}
-
-static int cpsw_hwtstamp_set(struct net_device *dev, struct ifreq *ifr)
-{
-	return -EOPNOTSUPP;
-}
 #endif /*CONFIG_TI_CPTS*/
 
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
@@ -1813,10 +1803,12 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 		return -EINVAL;
 
 	switch (cmd) {
+#if IS_ENABLED(CONFIG_TI_CPTS)
 	case SIOCSHWTSTAMP:
 		return cpsw_hwtstamp_set(dev, req);
 	case SIOCGHWTSTAMP:
 		return cpsw_hwtstamp_get(dev, req);
+#endif
 	}
 
 	if (!cpsw->slaves[slave_no].phy)
-- 
2.13.5
