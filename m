From: Anssi Hannula <anssi.hannula@bitwise.fi>
Subject: [PATCH 1/2] net: xilinx_emaclite: fix receive buffer overflow
Date: Tue, 14 Feb 2017 19:11:44 +0200
Message-ID: <20170214171145.26953-1-anssi.hannula@bitwise.fi>
Cc: Michal Simek <michal.simek@xilinx.com>,
        =?UTF-8?q?S=C3=B6ren=20Brinkmann?= <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bitwise.fi ([109.204.228.163]:40619 "EHLO mail.bitwise.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753768AbdBNRVE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 12:21:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xilinx_emaclite looks at the received data to try to determine the
Ethernet packet length but does not properly clamp it if
proto_type == ETH_P_IP or 1500 < proto_type <= 1518, causing a buffer
overflow and a panic via skb_panic() as the length exceeds the allocated
skb size.

Fix those cases.

Also add an additional unconditional check with WARN_ON() at the end.

Signed-off-by: Anssi Hannula <anssi.hannula@bitwise.fi>
Fixes: bb81b2ddfa19 ("net: add Xilinx emac lite device driver")
---

 drivers/net/ethernet/xilinx/xilinx_emaclite.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index e3070fd8..bd6470f 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -369,7 +369,7 @@ static int xemaclite_send_data(struct net_local *drvdata, u8 *data,
  *
  * Return:	Total number of bytes received
  */
-static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
+static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data, int maxlen)
 {
 	void __iomem *addr;
 	u16 length, proto_type;
@@ -409,7 +409,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 
 	/* Check if received ethernet frame is a raw ethernet frame
 	 * or an IP packet or an ARP packet */
-	if (proto_type > (ETH_FRAME_LEN + ETH_FCS_LEN)) {
+	if (proto_type > ETH_DATA_LEN) {
 
 		if (proto_type == ETH_P_IP) {
 			length = ((ntohl(__raw_readl(addr +
@@ -417,6 +417,7 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 					XEL_RXBUFF_OFFSET)) >>
 					XEL_HEADER_SHIFT) &
 					XEL_RPLR_LENGTH_MASK);
+			length = min_t(u16, length, ETH_DATA_LEN);
 			length += ETH_HLEN + ETH_FCS_LEN;
 
 		} else if (proto_type == ETH_P_ARP)
@@ -429,6 +430,9 @@ static u16 xemaclite_recv_data(struct net_local *drvdata, u8 *data)
 		/* Use the length in the frame, plus the header and trailer */
 		length = proto_type + ETH_HLEN + ETH_FCS_LEN;
 
+	if (WARN_ON(length > maxlen))
+		length = maxlen;
+
 	/* Read from the EmacLite device */
 	xemaclite_aligned_read((u32 __force *) (addr + XEL_RXBUFF_OFFSET),
 				data, length);
@@ -603,7 +607,7 @@ static void xemaclite_rx_handler(struct net_device *dev)
 
 	skb_reserve(skb, 2);
 
-	len = xemaclite_recv_data(lp, (u8 *) skb->data);
+	len = xemaclite_recv_data(lp, (u8 *) skb->data, len);
 
 	if (!len) {
 		dev->stats.rx_errors++;
-- 
2.8.3
