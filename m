From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: fix loss of CAN frames in raw_rcv
Date: Sun, 21 Jun 2015 19:04:59 +0200
Message-ID: <1434906299-19452-2-git-send-email-mkl@pengutronix.de>
References: <1434906299-19452-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Oliver Hartkopp <socketcan@hartkopp.net>,
	linux-stable <stable@vger.kernel.org>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1434906299-19452-1-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>

As reported by Manfred Schlaegl here

   http://marc.info/?l=linux-netdev&m=143482089824232&w=2

commit 514ac99c64b "can: fix multiple delivery of a single CAN frame for
overlapping CAN filters" requires the skb->tstamp to be set to check for
identical CAN skbs.

As net timestamping is influenced by several players (netstamp_needed and
netdev_tstamp_prequeue) Manfred missed a proper timestamp which leads to
CAN frame loss.

As skb timestamping became now mandatory for CAN related skbs this patch
makes sure that received CAN skbs always have a proper timestamp set.
Maybe there's a better solution in the future but this patch fixes the
CAN frame loss so far.

Reported-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/dev.c   | 5 +++++
 drivers/net/can/slcan.c | 1 +
 drivers/net/can/vcan.c  | 3 +++
 net/can/af_can.c        | 6 +++++-
 4 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index b0f69248cb71..e9b1810d319f 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -440,6 +440,9 @@ unsigned int can_get_echo_skb(struct net_device *dev, unsigned int idx)
 		struct can_frame *cf = (struct can_frame *)skb->data;
 		u8 dlc = cf->can_dlc;
 
+		if (!(skb->tstamp.tv64))
+			__net_timestamp(skb);
+
 		netif_rx(priv->echo_skb[idx]);
 		priv->echo_skb[idx] = NULL;
 
@@ -575,6 +578,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
 	if (unlikely(!skb))
 		return NULL;
 
+	__net_timestamp(skb);
 	skb->protocol = htons(ETH_P_CAN);
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -603,6 +607,7 @@ struct sk_buff *alloc_canfd_skb(struct net_device *dev,
 	if (unlikely(!skb))
 		return NULL;
 
+	__net_timestamp(skb);
 	skb->protocol = htons(ETH_P_CANFD);
 	skb->pkt_type = PACKET_BROADCAST;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index c837eb91d43e..f64f5290d6f8 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -207,6 +207,7 @@ static void slc_bump(struct slcan *sl)
 	if (!skb)
 		return;
 
+	__net_timestamp(skb);
 	skb->dev = sl->dev;
 	skb->protocol = htons(ETH_P_CAN);
 	skb->pkt_type = PACKET_BROADCAST;
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 674f367087c5..0ce868de855d 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -78,6 +78,9 @@ static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
 	skb->dev       = dev;
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 
+	if (!(skb->tstamp.tv64))
+		__net_timestamp(skb);
+
 	netif_rx_ni(skb);
 }
 
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 32d710eaf1fc..689c818ed007 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -310,8 +310,12 @@ int can_send(struct sk_buff *skb, int loop)
 		return err;
 	}
 
-	if (newskb)
+	if (newskb) {
+		if (!(newskb->tstamp.tv64))
+			__net_timestamp(newskb);
+
 		netif_rx_ni(newskb);
+	}
 
 	/* update statistics */
 	can_stats.tx_frames++;
-- 
2.1.4
