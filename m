From: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
Subject: [PATCH 1/1] net: pegasus: remove dead coding
Date: Wed, 18 May 2016 02:13:30 +0200
Message-ID: <1463530410-12772-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
To: Petko Manolov <petkan-nPnTwAqkgEqakBO8gow8eQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(!count || count < 4) is always true.
So let's remove the coding which is dead at least since 2005.

Signed-off-by: Heinrich Schuchardt <xypron.glpk-Mmb7MZpHnFY@public.gmane.org>
---
 drivers/net/usb/pegasus.c | 53 -----------------------------------------------
 1 file changed, 53 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 36cd7f0..1903d2e 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -470,61 +470,8 @@ static void read_bulk_callback(struct urb *urb)
 		return;
 	default:
 		netif_dbg(pegasus, rx_err, net, "RX status %d\n", status);
-		goto goon;
 	}
 
-	if (!count || count < 4)
-		goto goon;
-
-	rx_status = buf[count - 2];
-	if (rx_status & 0x1e) {
-		netif_dbg(pegasus, rx_err, net,
-			  "RX packet error %x\n", rx_status);
-		pegasus->stats.rx_errors++;
-		if (rx_status & 0x06)	/* long or runt	*/
-			pegasus->stats.rx_length_errors++;
-		if (rx_status & 0x08)
-			pegasus->stats.rx_crc_errors++;
-		if (rx_status & 0x10)	/* extra bits	*/
-			pegasus->stats.rx_frame_errors++;
-		goto goon;
-	}
-	if (pegasus->chip == 0x8513) {
-		pkt_len = le32_to_cpu(*(__le32 *)urb->transfer_buffer);
-		pkt_len &= 0x0fff;
-		pegasus->rx_skb->data += 2;
-	} else {
-		pkt_len = buf[count - 3] << 8;
-		pkt_len += buf[count - 4];
-		pkt_len &= 0xfff;
-		pkt_len -= 4;
-	}
-
-	/*
-	 * If the packet is unreasonably long, quietly drop it rather than
-	 * kernel panicing by calling skb_put.
-	 */
-	if (pkt_len > PEGASUS_MTU)
-		goto goon;
-
-	/*
-	 * at this point we are sure pegasus->rx_skb != NULL
-	 * so we go ahead and pass up the packet.
-	 */
-	skb_put(pegasus->rx_skb, pkt_len);
-	pegasus->rx_skb->protocol = eth_type_trans(pegasus->rx_skb, net);
-	netif_rx(pegasus->rx_skb);
-	pegasus->stats.rx_packets++;
-	pegasus->stats.rx_bytes += pkt_len;
-
-	if (pegasus->flags & PEGASUS_UNPLUG)
-		return;
-
-	pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net, PEGASUS_MTU,
-						      GFP_ATOMIC);
