From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/7] esp: Fix locking on page fragment allocation
Date: Tue, 29 Aug 2017 12:31:29 +0200
Message-ID: <1504002694-1931-3-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50656 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751883AbdH2Kbn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:43 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We allocate the page fragment for the ESP trailer inside
a spinlock, but consume it outside of the lock. This
is racy as some other cou could get the same page fragment
then. Fix this by consuming the page fragment inside the
lock too.

Fixes: cac2661c53f3 ("esp4: Avoid skb_cow_data whenever possible")
Fixes: 03e2a30f6a27 ("esp6: Avoid skb_cow_data whenever possible")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 +++--
 net/ipv6/esp6.c | 5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index dbb31a9..a8ddb95 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -292,8 +292,6 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 
 			kunmap_atomic(vaddr);
 
-			spin_unlock_bh(&x->lock);
-
 			nfrags = skb_shinfo(skb)->nr_frags;
 
 			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset,
@@ -301,6 +299,9 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 			skb_shinfo(skb)->nr_frags = ++nfrags;
 
 			pfrag->offset = pfrag->offset + allocsize;
+
+			spin_unlock_bh(&x->lock);
+
 			nfrags++;
 
 			skb->len += tailen;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 392def1..4e3fdc88 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -260,8 +260,6 @@ int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 
 			kunmap_atomic(vaddr);
 
-			spin_unlock_bh(&x->lock);
-
 			nfrags = skb_shinfo(skb)->nr_frags;
 
 			__skb_fill_page_desc(skb, nfrags, page, pfrag->offset,
@@ -269,6 +267,9 @@ int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 			skb_shinfo(skb)->nr_frags = ++nfrags;
 
 			pfrag->offset = pfrag->offset + allocsize;
+
+			spin_unlock_bh(&x->lock);
+
 			nfrags++;
 
 			skb->len += tailen;
-- 
2.7.4
