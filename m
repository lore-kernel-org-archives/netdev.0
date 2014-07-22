From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 net-next] dp83640: Fix receive timestamp race condition
Date: Tue, 22 Jul 2014 15:20:45 +0200
Message-ID: <1406035245-31091-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0188.outbound.protection.outlook.com ([207.46.163.188]:26270
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754958AbaGVNVA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 09:21:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When timestamping received packets, rx_timestamp_work may be scheduled
before the timestamps is received from the hardware resulting in the
packet beeing delivered without the timestamp.

This is fixed by changing the receive timestamp path:

On receiving a packet that need timestamping, the rxts list is
traversed.  If a match is found, packet+timestamp are delivered,
otherwise the packet is added to a rx_queue.

When a timestamp arrives rx_queue is traversed and if a matching
packet is found, it is delivered with the timestamp. Otherwise the
timestamp is added to the rxts list for matching with packets arriving
later.

In case the hardware drops a timestamp, a workqueue regularly checks
the queue for old packets and delivers them without a timestamp.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 173 +++++++++++++++++++++++++++-----------=
--------
 1 file changed, 102 insertions(+), 71 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 255c21f..c301e4c 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -74,7 +74,10 @@
 #define ENDIAN_FLAG	PSF_ENDIAN
 #endif
=20
-#define SKB_PTP_TYPE(__skb) (*(unsigned int *)((__skb)->cb))
+struct dp83640_skb_info {
+	int ptp_type;
+	unsigned long tmo;
+};
=20
 struct phy_rxts {
 	u16 ns_lo;   /* ns[15:0] */
@@ -768,10 +771,51 @@ static int decode_evnt(struct dp83640_private *dp=
83640,
 	return parsed * sizeof(u16);
 }
=20
+static int match(struct sk_buff *skb, unsigned int type, struct rxts *=
rxts)
+{
+	u16 *seqid;
+	unsigned int offset =3D 0;
+	u8 *msgtype, *data =3D skb_mac_header(skb);
+
+	/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
+
+	if (type & PTP_CLASS_VLAN)
+		offset +=3D VLAN_HLEN;
+
+	switch (type & PTP_CLASS_PMASK) {
+	case PTP_CLASS_IPV4:
+		offset +=3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		break;
+	case PTP_CLASS_IPV6:
+		offset +=3D ETH_HLEN + IP6_HLEN + UDP_HLEN;
+		break;
+	case PTP_CLASS_L2:
+		offset +=3D ETH_HLEN;
+		break;
+	default:
+		return 0;
+	}
+
+	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID + sizeof(*seqi=
d))
+		return 0;
+
+	if (unlikely(type & PTP_CLASS_V1))
+		msgtype =3D data + offset + OFF_PTP_CONTROL;
+	else
+		msgtype =3D data + offset;
+
+	seqid =3D (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
+
+	return rxts->msgtype =3D=3D (*msgtype & 0xf) &&
+		rxts->seqid   =3D=3D ntohs(*seqid);
+}
+
 static void decode_rxts(struct dp83640_private *dp83640,
 			struct phy_rxts *phy_rxts)
 {
 	struct rxts *rxts;
+	struct skb_shared_hwtstamps *shhwtstamps =3D NULL;
+	struct sk_buff *skb;
 	unsigned long flags;
=20
 	spin_lock_irqsave(&dp83640->rx_lock, flags);
@@ -785,7 +829,26 @@ static void decode_rxts(struct dp83640_private *dp=
83640,
 	rxts =3D list_first_entry(&dp83640->rxpool, struct rxts, list);
 	list_del_init(&rxts->list);
 	phy2rxts(phy_rxts, rxts);
-	list_add_tail(&rxts->list, &dp83640->rxts);
+
+	spin_lock_irqsave(&dp83640->rx_queue.lock, flags);
+	skb_queue_walk(&dp83640->rx_queue, skb) {
+		struct dp83640_skb_info *skb_info;
+
+		skb_info =3D (struct dp83640_skb_info *)skb->cb;
+		if (match(skb, skb_info->ptp_type, rxts)) {
+			__skb_unlink(skb, &dp83640->rx_queue);
+			shhwtstamps =3D skb_hwtstamps(skb);
+			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+			shhwtstamps->hwtstamp =3D ns_to_ktime(rxts->ns);
+			netif_rx_ni(skb);
+			list_add(&rxts->list, &dp83640->rxpool);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&dp83640->rx_queue.lock, flags);
+
+	if (!shhwtstamps)
+		list_add_tail(&rxts->list, &dp83640->rxts);
 out:
 	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
 }
@@ -887,45 +950,6 @@ static int is_sync(struct sk_buff *skb, int type)
 	return (*msgtype & 0xf) =3D=3D 0;
 }
=20
-static int match(struct sk_buff *skb, unsigned int type, struct rxts *=
rxts)
-{
-	u16 *seqid;
-	unsigned int offset =3D 0;
-	u8 *msgtype, *data =3D skb_mac_header(skb);
-
-	/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
-
-	if (type & PTP_CLASS_VLAN)
-		offset +=3D VLAN_HLEN;
-
-	switch (type & PTP_CLASS_PMASK) {
-	case PTP_CLASS_IPV4:
-		offset +=3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
-		break;
-	case PTP_CLASS_IPV6:
-		offset +=3D ETH_HLEN + IP6_HLEN + UDP_HLEN;
-		break;
-	case PTP_CLASS_L2:
-		offset +=3D ETH_HLEN;
-		break;
-	default:
-		return 0;
-	}
-
-	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID + sizeof(*seqi=
d))
-		return 0;
-
-	if (unlikely(type & PTP_CLASS_V1))
-		msgtype =3D data + offset + OFF_PTP_CONTROL;
-	else
-		msgtype =3D data + offset;
-
-	seqid =3D (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
-
-	return rxts->msgtype =3D=3D (*msgtype & 0xf) &&
-		rxts->seqid   =3D=3D ntohs(*seqid);
-}
-
 static void dp83640_free_clocks(void)
 {
 	struct dp83640_clock *clock;
@@ -1302,44 +1326,34 @@ static void rx_timestamp_work(struct work_struc=
t *work)
 {
 	struct dp83640_private *dp83640 =3D
 		container_of(work, struct dp83640_private, ts_work);
-	struct list_head *this, *next;
-	struct rxts *rxts;
-	struct skb_shared_hwtstamps *shhwtstamps;
 	struct sk_buff *skb;
-	unsigned int type;
-	unsigned long flags;
=20
-	/* Deliver each deferred packet, with or without a time stamp. */
-
-	while ((skb =3D skb_dequeue(&dp83640->rx_queue)) !=3D NULL) {
-		type =3D SKB_PTP_TYPE(skb);
-		spin_lock_irqsave(&dp83640->rx_lock, flags);
-		list_for_each_safe(this, next, &dp83640->rxts) {
-			rxts =3D list_entry(this, struct rxts, list);
-			if (match(skb, type, rxts)) {
-				shhwtstamps =3D skb_hwtstamps(skb);
-				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
-				shhwtstamps->hwtstamp =3D ns_to_ktime(rxts->ns);
-				list_del_init(&rxts->list);
-				list_add(&rxts->list, &dp83640->rxpool);
-				break;
-			}
+	/* Deliver expired packets. */
+	while ((skb =3D skb_dequeue(&dp83640->rx_queue))) {
+		struct dp83640_skb_info *skb_info;
+
+		skb_info =3D (struct dp83640_skb_info *)skb->cb;
+		if (!time_after(jiffies, skb_info->tmo)) {
+			skb_queue_head(&dp83640->rx_queue, skb);
+			break;
 		}
-		spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+
 		netif_rx_ni(skb);
 	}
=20
-	/* Clear out expired time stamps. */
-
-	spin_lock_irqsave(&dp83640->rx_lock, flags);
-	prune_rx_ts(dp83640);
-	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+	if (!skb_queue_empty(&dp83640->rx_queue))
+		schedule_work(&dp83640->ts_work);
 }
=20
 static bool dp83640_rxtstamp(struct phy_device *phydev,
 			     struct sk_buff *skb, int type)
 {
 	struct dp83640_private *dp83640 =3D phydev->priv;
+	struct dp83640_skb_info *skb_info =3D (struct dp83640_skb_info *)skb-=
>cb;
+	struct list_head *this, *next;
+	struct rxts *rxts;
+	struct skb_shared_hwtstamps *shhwtstamps =3D NULL;
+	unsigned long flags;
=20
 	if (is_status_frame(skb, type)) {
 		decode_status_frame(dp83640, skb);
@@ -1350,9 +1364,27 @@ static bool dp83640_rxtstamp(struct phy_device *=
phydev,
 	if (!dp83640->hwts_rx_en)
 		return false;
=20
-	SKB_PTP_TYPE(skb) =3D type;
-	skb_queue_tail(&dp83640->rx_queue, skb);
-	schedule_work(&dp83640->ts_work);
+	spin_lock_irqsave(&dp83640->rx_lock, flags);
+	list_for_each_safe(this, next, &dp83640->rxts) {
+		rxts =3D list_entry(this, struct rxts, list);
+		if (match(skb, type, rxts)) {
+			shhwtstamps =3D skb_hwtstamps(skb);
+			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+			shhwtstamps->hwtstamp =3D ns_to_ktime(rxts->ns);
+			netif_rx_ni(skb);
+			list_del_init(&rxts->list);
+			list_add(&rxts->list, &dp83640->rxpool);
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+
+	if (!shhwtstamps) {
+		skb_info->ptp_type =3D type;
+		skb_info->tmo =3D jiffies + 2;
+		skb_queue_tail(&dp83640->rx_queue, skb);
+		schedule_work(&dp83640->ts_work);
+	}
=20
 	return true;
 }
@@ -1373,7 +1405,6 @@ static void dp83640_txtstamp(struct phy_device *p=
hydev,
 	case HWTSTAMP_TX_ON:
 		skb_shinfo(skb)->tx_flags |=3D SKBTX_IN_PROGRESS;
 		skb_queue_tail(&dp83640->tx_queue, skb);
-		schedule_work(&dp83640->ts_work);
 		break;
=20
 	case HWTSTAMP_TX_OFF:
--=20
1.9.3
