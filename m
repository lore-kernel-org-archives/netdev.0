From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2] xen-netback: add gso_segs calculation
Date: Tue, 17 Dec 2013 11:44:35 +0000
Message-ID: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:16075 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3LQLoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 06:44:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netback already has code which parses IPv4 and v6 headers to set up checksum
offsets and these are always applied to GSO packets being sent from
frontends. It's therefore suboptimal that GSOs are being marked
SKB_GSO_DODGY to defer the gso_segs calculation when netback already has all
necessary information to hand to do the calculation. This patch adds that
calculation.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
v2:
 - Fixed header size calculation

 drivers/net/xen-netback/netback.c |   19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 904e497..d376e27 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1043,10 +1043,7 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
 	}
 
 	skb_shinfo(skb)->gso_size = gso->u.gso.size;
-
-	/* Header must be checked, and gso_segs computed. */
-	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-	skb_shinfo(skb)->gso_segs = 0;
+	/* gso_segs will be calculated later */
 
 	return 0;
 }
@@ -1582,6 +1579,20 @@ static int xenvif_tx_submit(struct xenvif *vif, int budget)
 
 		skb_probe_transport_header(skb, 0);
 
+		/* If the packet is GSO then we will have just set up the
+		 * transport header offset in checksum_setup so it's now
+		 * straightforward to calculate gso_segs.
+		 */
+		if (skb_is_gso(skb)) {
+			int mss = skb_shinfo(skb)->gso_size;
+			int hdrlen = skb_transport_header(skb) -
+				skb_mac_header(skb) +
+				tcp_hdrlen(skb);
+
+			skb_shinfo(skb)->gso_segs =
+				DIV_ROUND_UP(skb->len - hdrlen, mss);
+		}
+
 		vif->dev->stats.rx_bytes += skb->len;
 		vif->dev->stats.rx_packets++;
 
-- 
1.7.10.4
