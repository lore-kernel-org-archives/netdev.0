From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 5/5] dp83640: Only wait for timestamps for packets with timestamping enabled.
Date: Fri, 30 Oct 2015 13:14:04 +0100
Message-ID: <1446207244-2206-6-git-send-email-stefan.sorensen@spectralink.com>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0102.outbound.protection.outlook.com ([65.55.169.102]:48592
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031016AbbJ3MPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 08:15:36 -0400
In-Reply-To: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the packet timestamping function, check that the ptp version and
protocol of the packet matches what we have configured the hardware to
actually generate timestamps for, before looking/waiting for a timestam=
p.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index c1f70b7..30bfeb1 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -37,8 +37,6 @@
=20
 #define DP83640_PHY_ID	0x20005ce1
 #define PAGESEL		0x13
-#define LAYER4		0x02
-#define LAYER2		0x01
 #define MAX_RXTS	64
 #define N_EXT_TS	6
 #define N_PER_OUT	7
@@ -1292,29 +1290,29 @@ static int dp83640_hwtstamp(struct phy_device *=
phydev, struct ifreq *ifr)
 	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
 		dp83640->hwts_rx_en =3D 1;
-		dp83640->layer =3D LAYER4;
-		dp83640->version =3D 1;
+		dp83640->layer =3D PTP_CLASS_L4;
+		dp83640->version =3D PTP_CLASS_V1;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
 		dp83640->hwts_rx_en =3D 1;
-		dp83640->layer =3D LAYER4;
-		dp83640->version =3D 2;
+		dp83640->layer =3D PTP_CLASS_L4;
+		dp83640->version =3D PTP_CLASS_V2;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
 		dp83640->hwts_rx_en =3D 1;
-		dp83640->layer =3D LAYER2;
-		dp83640->version =3D 2;
+		dp83640->layer =3D PTP_CLASS_L2;
+		dp83640->version =3D PTP_CLASS_V2;
 		break;
 	case HWTSTAMP_FILTER_PTP_V2_EVENT:
 	case HWTSTAMP_FILTER_PTP_V2_SYNC:
 	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
 		dp83640->hwts_rx_en =3D 1;
-		dp83640->layer =3D LAYER4|LAYER2;
-		dp83640->version =3D 2;
+		dp83640->layer =3D PTP_CLASS_L4 | PTP_CLASS_L2;
+		dp83640->version =3D PTP_CLASS_V2;
 		break;
 	default:
 		return -ERANGE;
@@ -1323,11 +1321,11 @@ static int dp83640_hwtstamp(struct phy_device *=
phydev, struct ifreq *ifr)
 	txcfg0 =3D (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
 	rxcfg0 =3D (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
=20
-	if (dp83640->layer & LAYER2) {
+	if (dp83640->layer & PTP_CLASS_L2) {
 		txcfg0 |=3D TX_L2_EN;
 		rxcfg0 |=3D RX_L2_EN;
 	}
-	if (dp83640->layer & LAYER4) {
+	if (dp83640->layer & PTP_CLASS_L4) {
 		txcfg0 |=3D TX_IPV6_EN | TX_IPV4_EN;
 		rxcfg0 |=3D RX_IPV6_EN | RX_IPV4_EN;
 	}
@@ -1393,6 +1391,9 @@ static bool dp83640_rxtstamp(struct phy_device *p=
hydev,
 	if (!dp83640->hwts_rx_en)
 		return false;
=20
+	if ((type & dp83640->version) =3D=3D 0 || (type & dp83640->layer) =3D=
=3D 0)
+		return false;
+
 	spin_lock_irqsave(&dp83640->rx_lock, flags);
 	prune_rx_ts(dp83640);
 	list_for_each_safe(this, next, &dp83640->rxts) {
--=20
2.5.0
