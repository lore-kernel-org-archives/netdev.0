From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/1] net: create num frags requested
Date: Fri, 22 Apr 2011 19:22:20 -0700
Message-ID: <1303525340-29483-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43501 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757118Ab1DWBWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 21:22:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pktgen doesn't generate number of frags requested.
Divide packet size by number of frags and fill that in every frags.

Example:
With packet size 1470, it generate only 11 frags. Initial frags
get lenght 706, 353, 177....so on. Last frag get divided by 2.

Now with this fix, each frags will get 78 bytes.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 net/core/pktgen.c |   35 +++++++++--------------------------
 1 files changed, 9 insertions(+), 26 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2fa6fee..ff79d94 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2622,6 +2622,7 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
+		int frag_len;
 
 
 		if (frags > MAX_SKB_FRAGS)
@@ -2633,6 +2634,8 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 		}
 
 		i = 0;
+		frag_len = (datalen/frags) < PAGE_SIZE ?
+			   (datalen/frags) : PAGE_SIZE;
 		while (datalen > 0) {
 			if (unlikely(!pkt_dev->page)) {
 				int node = numa_node_id();
@@ -2646,38 +2649,18 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			skb_shinfo(skb)->frags[i].page = pkt_dev->page;
 			get_page(pkt_dev->page);
 			skb_shinfo(skb)->frags[i].page_offset = 0;
-			skb_shinfo(skb)->frags[i].size =
-			    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
+			/*last fragment, fill rest of data*/
+			if (i == (frags - 1))
+				skb_shinfo(skb)->frags[i].size =
+				    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE);
+			else
+				skb_shinfo(skb)->frags[i].size = frag_len;
 			datalen -= skb_shinfo(skb)->frags[i].size;
 			skb->len += skb_shinfo(skb)->frags[i].size;
 			skb->data_len += skb_shinfo(skb)->frags[i].size;
 			i++;
 			skb_shinfo(skb)->nr_frags = i;
 		}
-
-		while (i < frags) {
-			int rem;
-
-			if (i == 0)
-				break;
-
-			rem = skb_shinfo(skb)->frags[i - 1].size / 2;
-			if (rem == 0)
-				break;
-
-			skb_shinfo(skb)->frags[i - 1].size -= rem;
-
-			skb_shinfo(skb)->frags[i] =
-			    skb_shinfo(skb)->frags[i - 1];
-			get_page(skb_shinfo(skb)->frags[i].page);
-			skb_shinfo(skb)->frags[i].page =
-			    skb_shinfo(skb)->frags[i - 1].page;
-			skb_shinfo(skb)->frags[i].page_offset +=
-			    skb_shinfo(skb)->frags[i - 1].size;
-			skb_shinfo(skb)->frags[i].size = rem;
-			i++;
-			skb_shinfo(skb)->nr_frags = i;
-		}
 	}
 
 	/* Stamp the time, and sequence number,
-- 
1.6.3.3

