From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5 net-next v2] tg3: PTP - Add the hardware timestamp
 ioctl
Date: Mon, 3 Dec 2012 21:36:59 -0800
Message-ID: <1354599420-3589-4-git-send-email-mchan@broadcom.com>
References: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
 <1354599420-3589-2-git-send-email-mchan@broadcom.com>
 <1354599420-3589-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3681 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750827Ab2LDFVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 00:21:51 -0500
In-Reply-To: <1354599420-3589-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

This patch implements the SIOCSHWTSTAMP ioctl as described in
Documentation/networking/timestamping.txt

[Removed HWTSTAMP_FILTER_ALL handling by returning -ERANGE based on input
 from Richard Cochran.]

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   93 +++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 58af2a1..dddb21e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12760,6 +12760,96 @@ static void tg3_self_test(struct net_device *dev, struct ethtool_test *etest,
 
 }
 
+static int tg3_hwtstamp_ioctl(struct net_device *dev,
+			      struct ifreq *ifr, int cmd)
+{
+	struct tg3 *tp = netdev_priv(dev);
+	struct hwtstamp_config stmpconf;
+
+	if (!tg3_flag(tp, PTP_CAPABLE))
+		return -EINVAL;
+
+	if (copy_from_user(&stmpconf, ifr->ifr_data, sizeof(stmpconf)))
+		return -EFAULT;
+
+	if (stmpconf.flags)
+		return -EINVAL;
+
+	switch (stmpconf.tx_type) {
+	case HWTSTAMP_TX_ON:
+		tg3_flag_set(tp, TX_TSTAMP_EN);
+		break;
+	case HWTSTAMP_TX_OFF:
+		tg3_flag_clear(tp, TX_TSTAMP_EN);
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (stmpconf.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		tp->rxptpctl = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V1_EN |
+			       TG3_RX_PTP_CTL_ALL_V1_EVENTS;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V1_EN |
+			       TG3_RX_PTP_CTL_SYNC_EVNT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V1_EN |
+			       TG3_RX_PTP_CTL_DELAY_REQ;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_EN |
+			       TG3_RX_PTP_CTL_ALL_V2_EVENTS;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN |
+			       TG3_RX_PTP_CTL_ALL_V2_EVENTS;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN |
+			       TG3_RX_PTP_CTL_ALL_V2_EVENTS;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_EN |
+			       TG3_RX_PTP_CTL_SYNC_EVNT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN |
+			       TG3_RX_PTP_CTL_SYNC_EVNT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN |
+			       TG3_RX_PTP_CTL_SYNC_EVNT;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_EN |
+			       TG3_RX_PTP_CTL_DELAY_REQ;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L2_EN |
+			       TG3_RX_PTP_CTL_DELAY_REQ;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		tp->rxptpctl = TG3_RX_PTP_CTL_RX_PTP_V2_L4_EN |
+			       TG3_RX_PTP_CTL_DELAY_REQ;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	if (netif_running(dev) && tp->rxptpctl)
+		tw32(TG3_RX_PTP_CTL,
+		     tp->rxptpctl | TG3_RX_PTP_CTL_HWTS_INTERLOCK);
+
+	return copy_to_user(ifr->ifr_data, &stmpconf, sizeof(stmpconf)) ?
+		-EFAULT : 0;
+}
+
 static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mii_ioctl_data *data = if_mii(ifr);
@@ -12810,6 +12900,9 @@ static int tg3_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		return err;
 
+	case SIOCSHWTSTAMP:
+		return tg3_hwtstamp_ioctl(dev, ifr, cmd);
+
 	default:
 		/* do nothing */
 		break;
-- 
1.7.1
