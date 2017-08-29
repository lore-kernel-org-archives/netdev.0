From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/7] esp: Fix skb tailroom calculation
Date: Tue, 29 Aug 2017 12:31:30 +0200
Message-ID: <1504002694-1931-4-git-send-email-steffen.klassert@secunet.com>
References: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50672 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752030AbdH2Kbn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:43 -0400
In-Reply-To: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use skb_availroom to calculate the skb tailroom for the
ESP trailer. skb_availroom calculates the tailroom and
subtracts this value by reserved_tailroom. However
reserved_tailroom is a union with the skb mark. This means
that we subtract the tailroom by the skb mark if set.
Fix this by using skb_tailroom instead.

Fixes: cac2661c53f3 ("esp4: Avoid skb_cow_data whenever possible")
Fixes: 03e2a30f6a27 ("esp6: Avoid skb_cow_data whenever possible")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 2 +-
 net/ipv6/esp6.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index a8ddb95..df68963 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -258,7 +258,7 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 		esp_output_udp_encap(x, skb, esp);
 
 	if (!skb_cloned(skb)) {
-		if (tailen <= skb_availroom(skb)) {
+		if (tailen <= skb_tailroom(skb)) {
 			nfrags = 1;
 			trailer = skb;
 			tail = skb_tail_pointer(trailer);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 4e3fdc88..ab64f36 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -226,7 +226,7 @@ int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	int tailen = esp->tailen;
 
 	if (!skb_cloned(skb)) {
-		if (tailen <= skb_availroom(skb)) {
+		if (tailen <= skb_tailroom(skb)) {
 			nfrags = 1;
 			trailer = skb;
 			tail = skb_tail_pointer(trailer);
-- 
2.7.4
