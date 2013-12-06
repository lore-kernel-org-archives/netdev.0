From: freddy@asix.com.tw
Subject: [PATCH 1/1] AX88179_178A: Enable the hardware pseudo header in case of the NET_IP_ALIGN equals 0
Date: Fri,  6 Dec 2013 17:58:18 +0800
Message-ID: <1386323898-2246-1-git-send-email-freddy@asix.com.tw>
Cc: Freddy Xin <freddy@asix.com.tw>
To: davem@davemloft.net, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	louis@asix.com.tw, allan@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>

The AX88179_178A has a hardware feature that it can insert a 2-bytes pseudo
header in front of each received frame by setting the AX_RX_CTL_IPE bit.
This feature is used to let the IP header be aligned on a doubleword-aligned address,
but the NET_IP_ALIGN may equals to 2 and the __netdev_alloc_skb_ip_align in USBNET will
reserve 2 bytes also, so in this case the driver shouldn't enable this bit.

This patch modifies the driver to set AX_RX_CTL_IPE just in case of the NET_IP_ALIGN equals 0.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
---
 drivers/net/usb/ax88179_178a.c | 28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 8e8d0fc..d84f0e0 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -473,8 +473,10 @@ static int ax88179_resume(struct usb_interface *intf)
 	msleep(100);
 
 	/* Configure RX control register => start operation */
-	tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
-		AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_START | AX_RX_CTL_AP |
+		AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	if (NET_IP_ALIGN == 0)
+		tmp16 |= AX_RX_CTL_IPE;
 	ax88179_write_cmd_nopm(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, &tmp16);
 
 	return usbnet_resume(intf);
@@ -599,7 +601,9 @@ static void ax88179_set_multicast(struct net_device *net)
 	struct ax88179_data *data = (struct ax88179_data *)dev->data;
 	u8 *m_filter = ((u8 *)dev->data) + 12;
 
-	data->rxctl = (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_CTL_IPE);
+	data->rxctl = (AX_RX_CTL_START | AX_RX_CTL_AB);
+	if (NET_IP_ALIGN == 0)
+		data->rxctl |= AX_RX_CTL_IPE;
 
 	if (net->flags & IFF_PROMISC) {
 		data->rxctl |= AX_RX_CTL_PRO;
@@ -1054,8 +1058,10 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
 
 	/* Configure RX control register => start operation */
-	*tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
-		 AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	*tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_START | AX_RX_CTL_AP |
+		 AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	if (NET_IP_ALIGN == 0)
+		*tmp16 |= AX_RX_CTL_IPE;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, tmp16);
 
 	*tmp = AX_MONITOR_MODE_PMETYPE | AX_MONITOR_MODE_PMEPOL |
@@ -1143,7 +1149,8 @@ static int ax88179_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		if (pkt_cnt == 0) {
 			/* Skip IP alignment psudo header */
-			skb_pull(skb, 2);
+			if (NET_IP_ALIGN == 0)
+				skb_pull(skb, 2);
 			skb->len = pkt_len;
 			skb_set_tail_pointer(skb, pkt_len);
 			skb->truesize = pkt_len + sizeof(struct sk_buff);
@@ -1154,7 +1161,8 @@ static int ax88179_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		ax_skb = skb_clone(skb, GFP_ATOMIC);
 		if (ax_skb) {
 			ax_skb->len = pkt_len;
-			ax_skb->data = skb->data + 2;
+			if (NET_IP_ALIGN == 0)
+				ax_skb->data = skb->data + 2;
 			skb_set_tail_pointer(ax_skb, pkt_len);
 			ax_skb->truesize = pkt_len + sizeof(struct sk_buff);
 			ax88179_rx_checksum(ax_skb, pkt_hdr);
@@ -1328,8 +1336,10 @@ static int ax88179_reset(struct usbnet *dev)
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_TXCOE_CTL, 1, 1, tmp);
 
 	/* Configure RX control register => start operation */
-	*tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_IPE | AX_RX_CTL_START |
-		 AX_RX_CTL_AP | AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	*tmp16 = AX_RX_CTL_DROPCRCERR | AX_RX_CTL_START | AX_RX_CTL_AP |
+		 AX_RX_CTL_AMALL | AX_RX_CTL_AB;
+	if (NET_IP_ALIGN == 0)
+		*tmp16 |= AX_RX_CTL_IPE;
 	ax88179_write_cmd(dev, AX_ACCESS_MAC, AX_RX_CTL, 2, 2, tmp16);
 
 	*tmp = AX_MONITOR_MODE_PMETYPE | AX_MONITOR_MODE_PMEPOL |
-- 
1.8.3.2
