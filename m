From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v5 3/4] r8152: support stopping/waking tx queue
Date: Wed, 20 Nov 2013 17:30:56 +0800
Message-ID: <1384939857-13519-4-git-send-email-hayeswang@realtek.com>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
 <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The maximum packet number which a tx aggregation buffer could contain
is the tx_qlen.

	tx_qlen = buffer size / (packet size + descriptor size).

If the tx buffer is empty and the queued packets are more than the
maximum value which is defined above, stop the tx queue. Wake the
tx queue if tx queue is stopped and the queued packets are less than
tx_qlen.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8a786b6..f92e0cf 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -365,6 +365,7 @@ struct r8152 {
 	struct mii_if_info mii;
 	int intr_interval;
 	u32 msg_enable;
+	u32 tx_qlen;
 	u16 ocp_base;
 	u8 *intr_buff;
 	u8 version;
@@ -1173,6 +1174,14 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
+	netif_tx_lock(tp->netdev);
+
+	if (netif_queue_stopped(tp->netdev) &&
+	    skb_queue_len(&tp->tx_queue) < tp->tx_qlen)
+		netif_wake_queue(tp->netdev);
+
+	netif_tx_unlock(tp->netdev);
+
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
 			  agg->head, (int)(tx_data - (u8 *)agg->head),
 			  (usb_complete_t)write_bulk_callback, agg);
@@ -1393,6 +1402,10 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	skb_queue_tail(&tp->tx_queue, skb);
 
+	if (list_empty(&tp->tx_free) &&
+	    skb_queue_len(&tp->tx_queue) > tp->tx_qlen)
+		netif_stop_queue(netdev);
+
 	if (!list_empty(&tp->tx_free))
 		tasklet_schedule(&tp->tl);
 
@@ -1423,6 +1436,14 @@ static void rtl8152_nic_reset(struct r8152 *tp)
 	}
 }
 
+static void set_tx_qlen(struct r8152 *tp)
+{
+	struct net_device *netdev = tp->netdev;
+
+	tp->tx_qlen = rx_buf_sz / (netdev->mtu + VLAN_ETH_HLEN + VLAN_HLEN +
+				   sizeof(struct tx_desc));
+}
+
 static inline u8 rtl8152_get_speed(struct r8152 *tp)
 {
 	return ocp_read_byte(tp, MCU_TYPE_PLA, PLA_PHYSTATUS);
@@ -1434,6 +1455,7 @@ static int rtl8152_enable(struct r8152 *tp)
 	int i, ret;
 	u8 speed;
 
+	set_tx_qlen(tp);
 	speed = rtl8152_get_speed(tp);
 	if (speed & _10bps) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
-- 
1.8.3.1
