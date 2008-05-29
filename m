From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 16/37] net/usb: use get/put_endian helpers
Date: Thu, 29 May 2008 13:18:30 -0700
Message-ID: <1212092310.28403.118.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-arch <linux-arch@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/usb/catc.c       |    8 ++++----
 drivers/net/usb/kaweth.c     |    2 +-
 drivers/net/usb/net1080.c    |    4 ++--
 drivers/net/usb/pegasus.c    |    2 +-
 drivers/net/usb/rndis_host.c |    2 +-
 drivers/net/usb/rtl8150.c    |    2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 22c17bb..4b265d0 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -242,7 +242,7 @@ static void catc_rx_done(struct urb *urb)
 
 	do {
 		if(!catc->is_f5u011) {
-			pkt_len = le16_to_cpup((__le16*)pkt_start);
+			pkt_len = get_le16((__le16 *)pkt_start);
 			if (pkt_len > urb->actual_length) {
 				catc->stats.rx_length_errors++;
 				catc->stats.rx_errors++;
@@ -302,7 +302,7 @@ static void catc_irq_done(struct urb *urb)
 		else if (data[1] & 0x20)
 			linksts = LinkBad;
 	} else {
-		hasdata = (unsigned int)(be16_to_cpup((__be16*)data) & 0x0fff);
+		hasdata = (unsigned int)(get_be16((__be16 *)data) & 0x0fff);
 		if (data[0] == 0x90)
 			linksts = LinkGood;
 		else if (data[0] == 0xA0)
@@ -424,9 +424,9 @@ static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	catc->tx_ptr = (((catc->tx_ptr - 1) >> 6) + 1) << 6;
 	tx_buf = catc->tx_buf[catc->tx_idx] + catc->tx_ptr;
 	if (catc->is_f5u011)
-		*(__be16 *)tx_buf = cpu_to_be16(skb->len);
+		put_be16(skb->len, (__be16 *)tx_buf);
 	else
-		*(__le16 *)tx_buf = cpu_to_le16(skb->len);
+		put_le16(skb->len, (__le16 *)tx_buf);
 	skb_copy_from_linear_data(skb, tx_buf + 2, skb->len);
 	catc->tx_ptr += skb->len + 2;
 
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 0dcfc03..0fded74 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -589,7 +589,7 @@ static void kaweth_usb_receive(struct urb *urb)
 	int count = urb->actual_length;
 	int count2 = urb->transfer_buffer_length;
 
-	__u16 pkt_len = le16_to_cpup((__le16 *)kaweth->rx_buf);
+	__u16 pkt_len = get_le16((__le16 *)kaweth->rx_buf);
 
 	struct sk_buff *skb;
 
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 034e8a7..4304278 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -439,8 +439,8 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	header = (struct nc_header *) skb->data;
-	hdr_len = le16_to_cpup(&header->hdr_len);
-	packet_len = le16_to_cpup(&header->packet_len);
+	hdr_len = get_le16(&header->hdr_len);
+	packet_len = get_le16(&header->packet_len);
 	if (FRAMED_SIZE(packet_len) > NC_MAX_PACKET) {
 		dev->stats.rx_frame_errors++;
 		dbg("packet too big, %d", packet_len);
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index b588c89..eacaada 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -665,7 +665,7 @@ static void read_bulk_callback(struct urb *urb)
 		goto goon;
 	}
 	if (pegasus->chip == 0x8513) {
-		pkt_len = le32_to_cpu(*(__le32 *)urb->transfer_buffer);
+		pkt_len = get_le32((__le32 *)urb->transfer_buffer);
 		pkt_len &= 0x0fff;
 		pegasus->rx_skb->data += 2;
 	} else {
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index ae467f1..bda89c9 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -407,7 +407,7 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 	u.set->oid = OID_GEN_CURRENT_PACKET_FILTER;
 	u.set->len = ccpu2(4);
 	u.set->offset = ccpu2((sizeof *u.set) - 8);
-	*(__le32 *)(u.buf + sizeof *u.set) = RNDIS_DEFAULT_FILTER;
+	put_le32(RNDIS_DEFAULT_FILTER, (__le32 *)(u.buf + sizeof(*u.set)));
 
 	retval = rndis_command(dev, u.header);
 	if (unlikely(retval < 0)) {
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index df56a51..1505b07 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -455,7 +455,7 @@ static void read_bulk_callback(struct urb *urb)
 		goto goon;
 
 	res = urb->actual_length;
-	rx_stat = le16_to_cpu(*(__le16 *)(urb->transfer_buffer + res - 4));
+	rx_stat = get_le16((__le16 *)(urb->transfer_buffer + res - 4));
 	pkt_len = res - 4;
 
 	skb_put(dev->rx_skb, pkt_len);
-- 
1.5.6.rc0.277.g804cf
