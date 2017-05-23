From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 2/2] net: usb: r8152: Fix rx_bytes/tx_bytes to include FCS
Date: Tue, 23 May 2017 23:10:58 +0200
Message-ID: <1495573858-32346-3-git-send-email-andrew@lunn.ch>
References: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        hayeswang <hayeswang@realtek.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42169 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162002AbdEWVLn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 17:11:43 -0400
In-Reply-To: <1495573858-32346-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The statistics counters rx_bytes and tx_bytes don't include the
Ethernet Frame Check Sequence. Fix the rx_bytes/tx_bytes counters to
include the FCS, and include the received FCS in the skb.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/usb/r8152.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ddc62cb69be8..4081a2cd8b1b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1228,7 +1228,7 @@ static void write_bulk_callback(struct urb *urb)
 		stats->tx_errors += agg->skb_num;
 	} else {
 		stats->tx_packets += agg->skb_num;
-		stats->tx_bytes += agg->skb_len;
+		stats->tx_bytes += agg->skb_len + CRC_SIZE;
 	}
 
 	spin_lock(&tp->tx_lock);
@@ -1826,7 +1826,6 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			if (urb->actual_length < len_used)
 				break;
 
-			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
 			skb = napi_alloc_skb(napi, pkt_len);
@@ -1850,7 +1849,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			}
 
 find_next_rx:
-			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
+			rx_data = rx_agg_align(rx_data + pkt_len);
 			rx_desc = (struct rx_desc *)rx_data;
 			len_used = (int)(rx_data - (u8 *)agg->head);
 			len_used += sizeof(struct rx_desc);
-- 
2.11.0
