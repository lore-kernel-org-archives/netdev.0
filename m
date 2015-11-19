From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: avoid NULL deref in napi_get_frags()
Date: Thu, 19 Nov 2015 12:11:23 -0800
Message-ID: <1447963883.22599.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34888 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934659AbbKSULZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 15:11:25 -0500
Received: by pacej9 with SMTP id ej9so91014963pac.2
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 12:11:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

napi_alloc_skb() can return NULL.
We should not crash should this happen.

Fixes: 93f93a440415 ("net: move skb_mark_napi_id() into core networking stack")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 41cef3e3f558b857a9093a83f6b0c73f32b8b45f..5df6cbce727c140684b84129c26ffc0606260cbb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4390,8 +4390,10 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 
 	if (!skb) {
 		skb = napi_alloc_skb(napi, GRO_MAX_HEAD);
-		napi->skb = skb;
-		skb_mark_napi_id(skb, napi);
+		if (skb) {
+			napi->skb = skb;
+			skb_mark_napi_id(skb, napi);
+		}
 	}
 	return skb;
 }
