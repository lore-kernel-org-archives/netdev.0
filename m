From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 4/4] net: xfrm: convert to SKB frag APIs
Date: Tue, 23 Aug 2011 10:45:01 +0100
Message-ID: <1314092701-4347-4-git-send-email-ian.campbell@citrix.com>
References: <1314092683.10283.21.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7385 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754935Ab1HWJpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 05:45:13 -0400
In-Reply-To: <1314092683.10283.21.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 net/xfrm/xfrm_ipcomp.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index fc91ad7..f781b9a 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -70,26 +70,29 @@ static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 
 	while ((scratch += len, dlen -= len) > 0) {
 		skb_frag_t *frag;
+		struct page *page;
 
 		err = -EMSGSIZE;
 		if (WARN_ON(skb_shinfo(skb)->nr_frags >= MAX_SKB_FRAGS))
 			goto out;
 
 		frag = skb_shinfo(skb)->frags + skb_shinfo(skb)->nr_frags;
-		frag->page = alloc_page(GFP_ATOMIC);
+		page = alloc_page(GFP_ATOMIC);
 
 		err = -ENOMEM;
-		if (!frag->page)
+		if (!page)
 			goto out;
 
+		__skb_frag_set_page(frag, page);
+
 		len = PAGE_SIZE;
 		if (dlen < len)
 			len = dlen;
 
-		memcpy(page_address(frag->page), scratch, len);
-
 		frag->page_offset = 0;
 		frag->size = len;
+		memcpy(skb_frag_address(frag), scratch, len);
+
 		skb->truesize += len;
 		skb->data_len += len;
 		skb->len += len;
-- 
1.7.2.5

