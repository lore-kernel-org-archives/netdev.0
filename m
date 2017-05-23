From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/5] esp4: Fix udpencap for local TCP packets.
Date: Tue, 23 May 2017 07:33:40 +0200
Message-ID: <1495517624-27096-2-git-send-email-steffen.klassert@secunet.com>
References: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45118 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933151AbdEWFdx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:33:53 -0400
In-Reply-To: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally generated TCP packets are usually cloned, so we
do skb_cow_data() on this packets. After that we need to
reload the pointer to the esp header. On udpencap this
header has an offset to skb_transport_header, so take this
offset into account.

Fixes: 67d349ed603 ("net/esp4: Fix invalid esph pointer crash")
Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Reported-by: Don Bowman <db@donbowman.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 65cc02b..93322f8 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -248,6 +248,7 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	u8 *tail;
 	u8 *vaddr;
 	int nfrags;
+	int esph_offset;
 	struct page *page;
 	struct sk_buff *trailer;
 	int tailen = esp->tailen;
@@ -313,11 +314,13 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	}
 
 cow:
+	esph_offset = (unsigned char *)esp->esph - skb_transport_header(skb);
+
 	nfrags = skb_cow_data(skb, tailen, &trailer);
 	if (nfrags < 0)
 		goto out;
 	tail = skb_tail_pointer(trailer);
-	esp->esph = ip_esp_hdr(skb);
+	esp->esph = (struct ip_esp_hdr *)(skb_transport_header(skb) + esph_offset);
 
 skip_cow:
 	esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
-- 
2.7.4
