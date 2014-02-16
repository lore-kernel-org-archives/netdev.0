From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v3] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Sun, 16 Feb 2014 14:54:25 +0100
Message-ID: <1392558865-18388-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:60230 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752127AbaBPNy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 08:54:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the use of a generic timestamping phy connected
to the cpsw if CPTS support is not enabled. This also adds support
of the SIOCGMIIREG and SIOCSMIIREG, and moves handling of SIOCGMIIPHY
to the generic driver.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
Changes since v2:
  - Return -EOPNOTSUPP on unsupported request
Changes since v1:
  - Remove SIOCGMIIPHY from cpsw
  - Mention that SIOCGMIIREG and SIOCSMIIREG support is gained

 drivers/net/ethernet/ti/cpsw.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
index 1d860ce..39d1253 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1471,7 +1471,6 @@ static int cpsw_hwtstamp_get(struct net_device *d=
ev, struct ifreq *ifr)
 static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, i=
nt cmd)
 {
 	struct cpsw_priv *priv =3D netdev_priv(dev);
-	struct mii_ioctl_data *data =3D if_mii(req);
 	int slave_no =3D cpsw_slave_index(priv);
=20
 	if (!netif_running(dev))
@@ -1484,14 +1483,11 @@ static int cpsw_ndo_ioctl(struct net_device *de=
v, struct ifreq *req, int cmd)
 	case SIOCGHWTSTAMP:
 		return cpsw_hwtstamp_get(dev, req);
 #endif
-	case SIOCGMIIPHY:
-		data->phy_id =3D priv->slaves[slave_no].phy->addr;
-		break;
-	default:
-		return -ENOTSUPP;
 	}
=20
-	return 0;
+	if (!priv->slaves[slave_no].phy)
+		return -EOPNOTSUPP;
+	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
 }
=20
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
--=20
1.8.5.3
