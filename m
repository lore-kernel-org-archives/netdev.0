From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH v1 3/5] asix: Simplify asix_rx_fixup_internal() netdev alloc
Date: Fri, 2 Oct 2015 14:29:06 +0100
Message-ID: <1443792548-2025-4-git-send-email-Dean_Jenkins@mentor.com>
References: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-usb@vger.kernel.org>, <ben.hutchings@codethink.co.uk>,
	<davem@davemloft.net>, <bjorn@mork.no>, <linux@davidrobins.net>,
	Mark Craske <Mark_Craske@mentor.com>,
	Dean Jenkins <Dean_Jenkins@mentor.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:47529 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbbJBNbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 09:31:34 -0400
In-Reply-To: <1443792548-2025-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is checking that the Ethernet frame will fit into a
netdev allocated socket buffer within the constraints of MTU size,
Ethernet header length plus VLAN header length.

The original code was checking rx->remaining each loop of the while
loop that processes multiple Ethernet frames per URB and/or Ethernet
frames that span across URBs. rx->remaining decreases per while loop
so there is no point in potentially checking multiple times that the
Ethernet frame (remaining part) will fit into the netdev socket buffer.

The modification checks that the size of the Ethernet frame will fit
the netdev socket buffer before allocating the netdev socket buffer.
This avoids grabbing memory and then deciding that the Ethernet frame
is too big and then freeing the memory.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
Signed-off-by: Mark Craske <Mark_Craske@mentor.com>
---
 drivers/net/usb/asix_common.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 89efd6a..6a8eddf 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -87,19 +87,17 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 					   rx->header, offset);
 				return 0;
 			}
+			if (size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
+				netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
+					   size);
+				return 0;
+			}
+
 			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
 			if (!rx->ax_skb)
 				return 0;
-			rx->remaining = size;
-		}
 
-		if (rx->remaining > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   rx->remaining);
-			kfree_skb(rx->ax_skb);
-			rx->ax_skb = NULL;
-			rx->remaining = 0;
-			return 0;
+			rx->remaining = size;
 		}
 
 		if (rx->remaining > skb->len - offset) {
-- 
1.7.9.5
