From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 13/15] esp: Introduce a helper to setup the trailer
Date: Wed, 1 Feb 2017 09:17:55 +0100
Message-ID: <1485937077-612-14-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37068 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751788AbdBAISO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:14 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to setup the trailer in two different cases,
so add a helper to avoid code duplication.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 44 +++++++++++++++++++-------------------------
 net/ipv6/esp6.c | 44 +++++++++++++++++++-------------------------
 2 files changed, 38 insertions(+), 50 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 9e8d971..b1e2444 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -182,6 +182,22 @@ static void esp_output_done_esn(struct crypto_async_request *base, int err)
 	esp_output_done(base, err);
 }
 
+static void esp_output_fill_trailer(u8 *tail, int tfclen, int plen, __u8 proto)
+{
+	/* Fill padding... */
+	if (tfclen) {
+		memset(tail, 0, tfclen);
+		tail += tfclen;
+	}
+	do {
+		int i;
+		for (i = 0; i < plen - 2; i++)
+			tail[i] = i + 1;
+	} while (0);
+	tail[plen - 2] = plen - 2;
+	tail[plen - 1] = proto;
+}
+
 static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct esp_output_extra *extra;
@@ -304,18 +320,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 			tail = vaddr + pfrag->offset;
 
-			/* Fill padding... */
-			if (tfclen) {
-				memset(tail, 0, tfclen);
-				tail += tfclen;
-			}
-			do {
-				int i;
-				for (i = 0; i < plen - 2; i++)
-					tail[i] = i + 1;
-			} while (0);
-			tail[plen - 2] = plen - 2;
-			tail[plen - 1] = proto;
+			esp_output_fill_trailer(tail, tfclen, plen, proto);
 
 			kunmap_atomic(vaddr);
 
@@ -395,20 +400,9 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = ip_esp_hdr(skb);
 
 skip_cow:
-	/* Fill padding... */
-	if (tfclen) {
-		memset(tail, 0, tfclen);
-		tail += tfclen;
-	}
-	do {
-		int i;
-		for (i = 0; i < plen - 2; i++)
-			tail[i] = i + 1;
-	} while (0);
-	tail[plen - 2] = plen - 2;
-	tail[plen - 1] = proto;
-	pskb_put(skb, trailer, clen - skb->len + alen);
+	esp_output_fill_trailer(tail, tfclen, plen, proto);
 
+	pskb_put(skb, trailer, clen - skb->len + alen);
 	skb_push(skb, -skb_network_offset(skb));
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
 	esph->spi = x->id.spi;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index a428ac6..ff54faa 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -198,6 +198,22 @@ static void esp_output_done_esn(struct crypto_async_request *base, int err)
 	esp_output_done(base, err);
 }
 
+static void esp_output_fill_trailer(u8 *tail, int tfclen, int plen, __u8 proto)
+{
+	/* Fill padding... */
+	if (tfclen) {
+		memset(tail, 0, tfclen);
+		tail += tfclen;
+	}
+	do {
+		int i;
+		for (i = 0; i < plen - 2; i++)
+			tail[i] = i + 1;
+	} while (0);
+	tail[plen - 2] = plen - 2;
+	tail[plen - 1] = proto;
+}
+
 static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
@@ -284,18 +300,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 			tail = vaddr + pfrag->offset;
 
-			/* Fill padding... */
-			if (tfclen) {
-				memset(tail, 0, tfclen);
-				tail += tfclen;
-			}
-			do {
-				int i;
-				for (i = 0; i < plen - 2; i++)
-					tail[i] = i + 1;
-			} while (0);
-			tail[plen - 2] = plen - 2;
-			tail[plen - 1] = proto;
+			esp_output_fill_trailer(tail, tfclen, plen, proto);
 
 			kunmap_atomic(vaddr);
 
@@ -375,20 +380,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph = ip_esp_hdr(skb);
 
 skip_cow:
-	/* Fill padding... */
-	if (tfclen) {
-		memset(tail, 0, tfclen);
-		tail += tfclen;
-	}
-	do {
-		int i;
-		for (i = 0; i < plen - 2; i++)
-			tail[i] = i + 1;
-	} while (0);
-	tail[plen - 2] = plen - 2;
-	tail[plen - 1] = proto;
-	pskb_put(skb, trailer, clen - skb->len + alen);
+	esp_output_fill_trailer(tail, tfclen, plen, proto);
 
+	pskb_put(skb, trailer, clen - skb->len + alen);
 	skb_push(skb, -skb_network_offset(skb));
 
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output.low);
-- 
1.9.1
