From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/16] fec: Implement the SIOCGHWTSTAMP ioctl
Date: Thu, 5 Dec 2013 23:52:35 +0000
Message-ID: <1386287555.1516.135.camel@bwh-desktop.uk.level5networks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>,
	Frank Li <frank.li@freescale.net>,
	Fugang Duan <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6617 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751717Ab3LEXwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:52:39 -0500
In-Reply-To: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is untested.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/freescale/fec.h      |  3 ++-
 drivers/net/ethernet/freescale/fec_main.c |  8 ++++++--
 drivers/net/ethernet/freescale/fec_ptp.c  | 16 +++++++++++++++-
 3 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 0120217a16dd..3b8d6d19ff05 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -339,7 +339,8 @@ struct fec_enet_private {
 
 void fec_ptp_init(struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
-int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd);
+int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);
+int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr);
 
 /****************************************************************************/
 #endif /* FEC_H */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 4cbebf3d80eb..40e953e81eb5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1684,8 +1684,12 @@ static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 	if (!phydev)
 		return -ENODEV;
 
-	if (cmd == SIOCSHWTSTAMP && fep->bufdesc_ex)
-		return fec_ptp_ioctl(ndev, rq, cmd);
+	if (fep->bufdesc_ex) {
+		if (cmd == SIOCSHWTSTAMP)
+			return fec_ptp_set(ndev, rq);
+		if (cmd == SIOCGHWTSTAMP)
+			return fec_ptp_get(ndev, rq);
+	}
 
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 5007e4f9fff9..3a74ea48fd40 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -274,7 +274,7 @@ static int fec_ptp_enable(struct ptp_clock_info *ptp,
  * @ifreq: ioctl data
  * @cmd: particular ioctl requested
  */
-int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
+int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
@@ -321,6 +321,20 @@ int fec_ptp_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
 	    -EFAULT : 0;
 }
 
+int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct hwtstamp_config config;
+
+	config.flags = 0;
+	config.tx_type = fep->hwts_tx_en ? HWTSTAMP_TX_ON : HWTSTAMP_TX_OFF;
+	config.rx_filter = (fep->hwts_rx_en ?
+			    HWTSTAMP_FILTER_ALL : HWTSTAMP_FILTER_NONE);
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
 /**
  * fec_time_keep - call timecounter_read every second to avoid timer overrun
  *                 because ENET just support 32bit counter, will timeout in 4s


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
