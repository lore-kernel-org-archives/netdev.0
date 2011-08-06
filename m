From: Mark Kamichoff <prox@prolixium.com>
Subject: [PATCH] net/usb: Add IPv6 support to the LG-VL600 LTE USB modem driver
Date: Sat,  6 Aug 2011 18:28:14 -0400
Message-ID: <1312669694-28800-1-git-send-email-prox@prolixium.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mark Kamichoff <prox@prolixium.com>
To: gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from nox.prolixium.com ([64.16.214.60]:37958 "EHLO nox.prolixium.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751658Ab1HFXET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Aug 2011 19:04:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LG-VL600 LTE USB modem supports IPv6, but uses and expects an IPv4
ethertype (0x800) for these packets instead of the standard 0x86dd.
This patch peeks at the IP version in the L3 header and sets the
ethertype appropriately for IPv6 packets.

Signed-off-by: Mark Kamichoff <prox@prolixium.com>
---
 drivers/net/usb/lg-vl600.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
index 1d83ccf..1e72219 100644
--- a/drivers/net/usb/lg-vl600.c
+++ b/drivers/net/usb/lg-vl600.c
@@ -89,6 +89,8 @@ static int vl600_bind(struct usbnet *dev, struct usb_interface *intf)
 	 * addresses have no meaning, the destination and the source of every
 	 * packet depend only on whether it is on the IN or OUT endpoint.  */
 	dev->net->flags |= IFF_NOARP;
+	/* IPv6 NDP relies on multicast.  Enable it by default. */
+	dev->net->flags |= IFF_MULTICAST;
 
 	return ret;
 }
@@ -200,6 +202,14 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		} else {
 			memset(ethhdr->h_source, 0, ETH_ALEN);
 			memcpy(ethhdr->h_dest, dev->net->dev_addr, ETH_ALEN);
+
+			/* Inbound IPv6 packets have an IPv4 ethertype (0x800)
+			 * for some reason.  Peek at the L3 header to check
+			 * for IPv6 packets, and set the ethertype to IPv6
+			 * (0x86dd) so Linux can understand it.
+			 */
+			if ((buf->data[sizeof(*ethhdr)] & 0xf0) == 0x60)
+				ethhdr->h_proto = __constant_htons(ETH_P_IPV6);
 		}
 
 		if (count) {
@@ -297,6 +307,15 @@ encapsulate:
 	if (skb->len < full_len) /* Pad */
 		skb_put(skb, full_len - skb->len);
 
+	/* The VL600 wants IPv6 packets to have an IPv4 ethertype
+	 * Check if this is an IPv6 packet, and set the ethertype
+	 * to 0x800
+	 */
+	if ((skb->data[sizeof(struct vl600_pkt_hdr *) + 0x22] & 0xf0) == 0x60) {
+		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x20] = 0x08;
+		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x21] = 0;
+	}
+
 	return skb;
 }
 
-- 
1.7.5.4

