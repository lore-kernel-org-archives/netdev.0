From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 11/19] net: packetengines: slight optimization
 of addr
Date: Mon, 30 Dec 2013 15:41:06 +0800
Message-ID: <52C12392.2090102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use possibly more efficient ether_addr_equal
to instead of memcmp.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ethernet/packetengines/yellowfin.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 07a890e..9a6cb48 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -1053,7 +1053,7 @@ static int yellowfin_rx(struct net_device *dev)
 		struct sk_buff *rx_skb = yp->rx_skbuff[entry];
 		s16 frame_status;
 		u16 desc_status;
-		int data_size;
+		int data_size, yf_size;
 		u8 *buf_addr;
 
 		if(!desc->result_status)
@@ -1070,6 +1070,9 @@ static int yellowfin_rx(struct net_device *dev)
 			       __func__, frame_status);
 		if (--boguscnt < 0)
 			break;
+
+		yf_size = sizeof(struct yellowfin_desc);
+
 		if ( ! (desc_status & RX_EOP)) {
 			if (data_size != 0)
 				netdev_warn(dev, "Oversized Ethernet frame spanned multiple buffers, status %04x, data_size %d!\n",
@@ -1096,12 +1099,12 @@ static int yellowfin_rx(struct net_device *dev)
 			if (status2 & 0x80) dev->stats.rx_dropped++;
 #ifdef YF_PROTOTYPE		/* Support for prototype hardware errata. */
 		} else if ((yp->flags & HasMACAddrBug)  &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				dev->dev_addr, 6) != 0 &&
-			memcmp(le32_to_cpu(yp->rx_ring_dma +
-				entry*sizeof(struct yellowfin_desc)),
-				"\377\377\377\377\377\377", 6) != 0) {
+			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
+						      entry * yf_size),
+					  dev->dev_addr) &&
+			!ether_addr_equal(le32_to_cpu(yp->rx_ring_dma +
+						      entry * yf_size),
+					  "\377\377\377\377\377\377")) {
 			if (bogus_rx++ == 0)
 				netdev_warn(dev, "Bad frame to %pM\n",
 					    buf_addr);
-- 
1.8.0
