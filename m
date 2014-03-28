From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v3 net 2/3] xen-netback: worse-case estimate in xenvif_rx_action is underestimating
Date: Fri, 28 Mar 2014 11:39:06 +0000
Message-ID: <1396006747-9113-3-git-send-email-paul.durrant@citrix.com>
References: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44316 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149AbaC1LjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 07:39:12 -0400
In-Reply-To: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The worse-case estimate for skb ring slot usage in xenvif_rx_action()
fails to take fragment page_offset into account. The page_offset does,
however, affect the number of times the fragmentation code calls
start_new_rx_buffer() (i.e. consume another slot) and the worse-case
should assume that will always return true. This patch adds the page_offset
into the DIV_ROUND_UP for each frag.

Unfortunately some frontends aggressively limit the number of requests
they post into the shared ring so to avoid an estimate that is 'too'
pessimal it is capped at MAX_SKB_FRAGS.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
---
 drivers/net/xen-netback/netback.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 72314c7..573f3e8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -493,9 +493,28 @@ static void xenvif_rx_action(struct xenvif *vif)
 						PAGE_SIZE);
 		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 			unsigned int size;
+			unsigned int offset;
+
 			size = skb_frag_size(&skb_shinfo(skb)->frags[i]);
-			max_slots_needed += DIV_ROUND_UP(size, PAGE_SIZE);
+			offset = skb_shinfo(skb)->frags[i].page_offset;
+
+			/* For a worse-case estimate we need to factor in
+			 * the fragment page offset as this will affect the
+			 * number of times xenvif_gop_frag_copy() will
+			 * call start_new_rx_buffer().
+			 */
+			max_slots_needed += DIV_ROUND_UP(offset + size,
+							 PAGE_SIZE);
 		}
+
+		/* To avoid the estimate becoming too pessimal for some
+		 * frontends that limit posted rx requests, cap the estimate
+		 * at MAX_SKB_FRAGS.
+		 */
+		if (max_slots_needed > MAX_SKB_FRAGS)
+			max_slots_needed = MAX_SKB_FRAGS;
+
+		/* We may need one more slot for GSO metadata */
 		if (skb_is_gso(skb) &&
 		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
 		    skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6))
-- 
1.7.10.4
