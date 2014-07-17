From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next] dp83640: Fix receive timestamp race condition
Date: Thu, 17 Jul 2014 15:17:59 +0200
Message-ID: <1405603079-23572-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0205.outbound.protection.outlook.com ([207.46.163.205]:48029
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932129AbaGQNSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2014 09:18:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When timestamping received packets, rx_timestamp_work may be scheduled =
before
the timestamps is received from the hardware resulting in the packet be=
eing
delivered without the timestamp.

This is fixed by changing the receive timestamp path: On receiving a pa=
cket
that need timestamping, it is added to a queue. When a timestamp arrive=
s, the
queue is traversed and if a matching packet is found, it is deliverd wi=
th the
timestamp. In case the hardware drops a timestamp, a workqueue regularl=
y
checks the queue for old packets and delivers them without a timestamp.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 197 +++++++++++++++++++-------------------=
--------
 1 file changed, 82 insertions(+), 115 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 255c21f..89eea31 100644
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
@@ -94,7 +97,6 @@ struct phy_txts {
=20
 struct rxts {
 	struct list_head list;
-	unsigned long tmo;
 	u64 ns;
 	u16 seqid;
 	u8  msgtype;
@@ -116,12 +118,6 @@ struct dp83640_private {
 	int cfg0;
 	/* remember the last event time stamp */
 	struct phy_txts edata;
-	/* list of rx timestamps */
-	struct list_head rxts;
-	struct list_head rxpool;
-	struct rxts rx_pool_data[MAX_RXTS];
-	/* protects above three fields from concurrent access */
-	spinlock_t rx_lock;
 	/* queues of incoming and outgoing packets */
 	struct sk_buff_head rx_queue;
 	struct sk_buff_head tx_queue;
@@ -281,7 +277,6 @@ static void phy2rxts(struct phy_rxts *p, struct rxt=
s *rxts)
 	rxts->seqid =3D p->seqid;
 	rxts->msgtype =3D (p->msgtype >> 12) & 0xf;
 	rxts->hash =3D p->msgtype & 0x0fff;
-	rxts->tmo =3D jiffies + 2;
 }
=20
 static u64 phy2txts(struct phy_txts *p)
@@ -563,26 +558,6 @@ static bool is_status_frame(struct sk_buff *skb, i=
nt type)
 		return false;
 }
=20
-static int expired(struct rxts *rxts)
-{
-	return time_after(jiffies, rxts->tmo);
-}
-
-/* Caller must hold rx_lock. */
-static void prune_rx_ts(struct dp83640_private *dp83640)
-{
-	struct list_head *this, *next;
-	struct rxts *rxts;
-
-	list_for_each_safe(this, next, &dp83640->rxts) {
-		rxts =3D list_entry(this, struct rxts, list);
-		if (expired(rxts)) {
-			list_del_init(&rxts->list);
-			list_add(&rxts->list, &dp83640->rxpool);
-		}
-	}
-}
-
 /* synchronize the phyters so they act as one clock */
=20
 static void enable_broadcast(struct phy_device *phydev, int init_page,=
 int on)
@@ -768,26 +743,70 @@ static int decode_evnt(struct dp83640_private *dp=
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
-	struct rxts *rxts;
+	struct rxts rxts;
+	struct skb_shared_hwtstamps *shhwtstamps;
+	struct sk_buff *skb;
 	unsigned long flags;
=20
-	spin_lock_irqsave(&dp83640->rx_lock, flags);
+	phy2rxts(phy_rxts, &rxts);
=20
-	prune_rx_ts(dp83640);
+	spin_lock_irqsave(&dp83640->rx_queue.lock, flags);
+	skb_queue_walk(&dp83640->rx_queue, skb) {
+		struct dp83640_skb_info *skb_info;
=20
-	if (list_empty(&dp83640->rxpool)) {
-		pr_debug("rx timestamp pool is empty\n");
-		goto out;
+		skb_info =3D (struct dp83640_skb_info *)skb->cb;
+		if (match(skb, skb_info->ptp_type, &rxts)) {
+			__skb_unlink(skb, &dp83640->rx_queue);
+			shhwtstamps =3D skb_hwtstamps(skb);
+			memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+			shhwtstamps->hwtstamp =3D ns_to_ktime(rxts.ns);
+			netif_rx_ni(skb);
+			break;
+		}
 	}
-	rxts =3D list_first_entry(&dp83640->rxpool, struct rxts, list);
-	list_del_init(&rxts->list);
-	phy2rxts(phy_rxts, rxts);
-	list_add_tail(&rxts->list, &dp83640->rxts);
-out:
-	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+	spin_unlock_irqrestore(&dp83640->rx_queue.lock, flags);
 }
=20
 static void decode_txts(struct dp83640_private *dp83640,
@@ -887,45 +906,6 @@ static int is_sync(struct sk_buff *skb, int type)
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
@@ -1049,7 +1029,7 @@ static int dp83640_probe(struct phy_device *phyde=
v)
 {
 	struct dp83640_clock *clock;
 	struct dp83640_private *dp83640;
-	int err =3D -ENOMEM, i;
+	int err =3D -ENOMEM;
=20
 	if (phydev->addr =3D=3D BROADCAST_ADDR)
 		return 0;
@@ -1065,14 +1045,8 @@ static int dp83640_probe(struct phy_device *phyd=
ev)
 	dp83640->phydev =3D phydev;
 	INIT_WORK(&dp83640->ts_work, rx_timestamp_work);
=20
-	INIT_LIST_HEAD(&dp83640->rxts);
-	INIT_LIST_HEAD(&dp83640->rxpool);
-	for (i =3D 0; i < MAX_RXTS; i++)
-		list_add(&dp83640->rx_pool_data[i].list, &dp83640->rxpool);
-
 	phydev->priv =3D dp83640;
=20
-	spin_lock_init(&dp83640->rx_lock);
 	skb_queue_head_init(&dp83640->rx_queue);
 	skb_queue_head_init(&dp83640->tx_queue);
=20
@@ -1267,6 +1241,13 @@ static int dp83640_hwtstamp(struct phy_device *p=
hydev, struct ifreq *ifr)
 		return -ERANGE;
 	}
=20
+	if (!dp83640->hwts_rx_en) {
+		struct sk_buff *skb;
+
+		while ((skb =3D skb_dequeue(&dp83640->rx_queue)))
+			netif_rx_ni(skb);
+	}
+
 	txcfg0 =3D (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
 	rxcfg0 =3D (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
=20
@@ -1302,44 +1283,30 @@ static void rx_timestamp_work(struct work_struc=
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
=20
 	if (is_status_frame(skb, type)) {
 		decode_status_frame(dp83640, skb);
@@ -1350,7 +1317,8 @@ static bool dp83640_rxtstamp(struct phy_device *p=
hydev,
 	if (!dp83640->hwts_rx_en)
 		return false;
=20
-	SKB_PTP_TYPE(skb) =3D type;
+	skb_info->ptp_type =3D type;
+	skb_info->tmo =3D jiffies + 2;
 	skb_queue_tail(&dp83640->rx_queue, skb);
 	schedule_work(&dp83640->ts_work);
=20
@@ -1373,7 +1341,6 @@ static void dp83640_txtstamp(struct phy_device *p=
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
