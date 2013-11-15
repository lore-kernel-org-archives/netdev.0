From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net v3 3/4] r8152: support stopping/waking tx queue
Date: Fri, 15 Nov 2013 15:57:58 +0800
Message-ID: <1384502279-9959-4-git-send-email-hayeswang@realtek.com>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384502279-9959-1-git-send-email-hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The maximum packet number which a tx aggregation buffer could contain
is the buffer size / (packet size + descriptor size).

If the tx buffer is empty and the tx queue length is more than the
maximum value which is defined above, stop the tx queue. Wake the tx
queue after any queued packet is filled in a available tx buffer.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 763234d..81a4171 100644
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
@@ -1173,6 +1174,9 @@ static int r8152_tx_agg_fill(struct r8152 *tp, struct tx_agg *agg)
 		remain = rx_buf_sz - (int)(tx_agg_align(tx_data) - agg->head);
 	}
 
+	if (netif_queue_stopped(tp->netdev))
+		netif_wake_queue(tp->netdev);
+
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_sndbulkpipe(tp->udev, 2),
 			  agg->head, (int)(tx_data - (u8 *)agg->head),
 			  (usb_complete_t)write_bulk_callback, agg);
@@ -1393,6 +1397,10 @@ static netdev_tx_t rtl8152_start_xmit(struct sk_buff *skb,
 
 	skb_queue_tail(&tp->tx_queue, skb);
 
+	if (list_empty(&tp->tx_free) &&
+	    skb_queue_len(&tp->tx_queue) > tp->tx_qlen)
+		netif_stop_queue(netdev);
+
 	if (!list_empty(&tp->tx_free))
 		tasklet_schedule(&tp->tl);
 
@@ -1423,6 +1431,14 @@ static void rtl8152_nic_reset(struct r8152 *tp)
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
@@ -1434,6 +1450,7 @@ static int rtl8152_enable(struct r8152 *tp)
 	int i, ret;
 	u8 speed;
 
+	set_tx_qlen(tp);
 	speed = rtl8152_get_speed(tp);
 	if (speed & _10bps) {
 		ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEEP_CR);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
