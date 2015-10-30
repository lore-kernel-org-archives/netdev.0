From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 2/5] dp83640: Delay scheduled work.
Date: Fri, 30 Oct 2015 13:14:01 +0100
Message-ID: <1446207244-2206-3-git-send-email-stefan.sorensen@spectralink.com>
References: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0148.outbound.protection.outlook.com ([207.46.100.148]:21829
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752372AbbJ3M37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 08:29:59 -0400
In-Reply-To: <1446207244-2206-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently rx_timestamp_work reschedules itself as a regular workqueue i=
tem,
effectively causing it run constantly as long as there are packets left=
 in
the queue. Fix by using delayed workqueue items, limiting it to run onl=
y
every two jiffies.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 9534478..f3e812b 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -69,6 +69,8 @@
 /* phyter seems to miss the mark by 16 ns */
 #define ADJTIME_FIX	16
=20
+#define SKB_TIMESTAMP_TIMEOUT	2 /* jiffies */
+
 #if defined(__BIG_ENDIAN)
 #define ENDIAN_FLAG	0
 #elif defined(__LITTLE_ENDIAN)
@@ -111,7 +113,7 @@ struct dp83640_private {
 	struct list_head list;
 	struct dp83640_clock *clock;
 	struct phy_device *phydev;
-	struct work_struct ts_work;
+	struct delayed_work ts_work;
 	int hwts_tx_en;
 	int hwts_rx_en;
 	int layer;
@@ -285,7 +287,7 @@ static void phy2rxts(struct phy_rxts *p, struct rxt=
s *rxts)
 	rxts->seqid =3D p->seqid;
 	rxts->msgtype =3D (p->msgtype >> 12) & 0xf;
 	rxts->hash =3D p->msgtype & 0x0fff;
-	rxts->tmo =3D jiffies + 2;
+	rxts->tmo =3D jiffies + SKB_TIMESTAMP_TIMEOUT;
 }
=20
 static u64 phy2txts(struct phy_txts *p)
@@ -1111,7 +1113,7 @@ static int dp83640_probe(struct phy_device *phyde=
v)
 		goto no_memory;
=20
 	dp83640->phydev =3D phydev;
-	INIT_WORK(&dp83640->ts_work, rx_timestamp_work);
+	INIT_DELAYED_WORK(&dp83640->ts_work, rx_timestamp_work);
=20
 	INIT_LIST_HEAD(&dp83640->rxts);
 	INIT_LIST_HEAD(&dp83640->rxpool);
@@ -1158,7 +1160,7 @@ static void dp83640_remove(struct phy_device *phy=
dev)
 		return;
=20
 	enable_status_frames(phydev, false);
-	cancel_work_sync(&dp83640->ts_work);
+	cancel_delayed_work_sync(&dp83640->ts_work);
=20
 	skb_queue_purge(&dp83640->rx_queue);
 	skb_queue_purge(&dp83640->tx_queue);
@@ -1352,7 +1354,7 @@ static int dp83640_hwtstamp(struct phy_device *ph=
ydev, struct ifreq *ifr)
 static void rx_timestamp_work(struct work_struct *work)
 {
 	struct dp83640_private *dp83640 =3D
-		container_of(work, struct dp83640_private, ts_work);
+		container_of(work, struct dp83640_private, ts_work.work);
 	struct sk_buff *skb;
=20
 	/* Deliver expired packets. */
@@ -1369,7 +1371,7 @@ static void rx_timestamp_work(struct work_struct =
*work)
 	}
=20
 	if (!skb_queue_empty(&dp83640->rx_queue))
-		schedule_work(&dp83640->ts_work);
+		schedule_delayed_work(&dp83640->ts_work, SKB_TIMESTAMP_TIMEOUT);
 }
=20
 static bool dp83640_rxtstamp(struct phy_device *phydev,
@@ -1408,9 +1410,11 @@ static bool dp83640_rxtstamp(struct phy_device *=
phydev,
=20
 	if (!shhwtstamps) {
 		skb_info->ptp_type =3D type;
-		skb_info->tmo =3D jiffies + 2;
+		skb_info->tmo =3D jiffies + SKB_TIMESTAMP_TIMEOUT;
 		skb_queue_tail(&dp83640->rx_queue, skb);
-		schedule_work(&dp83640->ts_work);
+		schedule_delayed_work(&dp83640->ts_work, SKB_TIMESTAMP_TIMEOUT);
+	} else {
+		netif_rx_ni(skb);
 	}
=20
 	return true;
--=20
2.5.0
