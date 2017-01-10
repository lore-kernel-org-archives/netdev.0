From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gro: Enter slow-path if there is no tailroom
Date: Tue, 10 Jan 2017 12:24:01 -0800
Message-ID: <1484079841.21472.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Slava Shwartsman <slavash@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36194 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030869AbdAJUYE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:24:04 -0500
Received: by mail-pf0-f193.google.com with SMTP id b22so13978791pfd.3
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:24:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

The GRO path has a fast-path where we avoid calling pskb_may_pull
and pskb_expand by directly accessing frag0.  However, this should
only be done if we have enough tailroom in the skb as otherwise
we'll have to expand it later anyway.

This patch adds the check by capping frag0_len with the skb tailroom.

Fixes: cb18978cbf45 ("gro: Open-code final pskb_may_pull")
Reported-by: Slava Shwartsman <slavash@mellanox.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 8db5a0b4b52061afe9cd44dead33cc69523d15df..88d2907ca2cda3438a7a1c0c179051a5038aa1e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4441,7 +4441,8 @@ static void skb_gro_reset_offset(struct sk_buff *skb)
 	    pinfo->nr_frags &&
 	    !PageHighMem(skb_frag_page(frag0))) {
 		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
-		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(frag0);
+		NAPI_GRO_CB(skb)->frag0_len = min(skb_frag_size(frag0),
+						  skb->end - skb->tail);
 	}
 }
 
