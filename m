From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: gro: make sure skb->cb[] initial content has not to be
 zero
Date: Fri, 16 May 2014 11:34:37 -0700
Message-ID: <1400265277.5367.13.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140516104014.607d2d0f@vostro>
	 <1400245157.7973.150.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516173443.0b40157e@vostro>
	 <1400257768.7973.204.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516194037.4486cd63@vostro>
	 <1400259027.7973.211.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516200112.114cf1bb@vostro>
	 <1400260430.7973.222.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516203835.5941ea3f@vostro>
	 <1400263479.5367.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:37387 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbaEPSek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:34:40 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so2890506pab.12
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 11:34:39 -0700 (PDT)
In-Reply-To: <1400263479.5367.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Starting from linux-3.13, GRO attempts to build full size skbs.

Problem is the commit assumed one particular field in skb->cb[]
was clean, but it is not the case on some stacked devices.

Timo reported a crash in case traffic is decrypted before
reaching a GRE device.

Fix this by initializing NAPI_GRO_CB(skb)->last at the right place,
this also removes one conditional.

Thanks a lot to Timo for providing full reports and bisecting this.

Fixes: 8a29111c7ca6 ("net: gro: allow to build full sized skb")
Bisected-by: Timo Teras <timo.teras@iki.fi>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Please Timo test this patch so that we confirm it fixes the bug for you.

 net/core/dev.c    |    1 +
 net/core/skbuff.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6da649bde4f7..ed928e846559 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3951,6 +3951,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	}
 	NAPI_GRO_CB(skb)->count = 1;
 	NAPI_GRO_CB(skb)->age = jiffies;
+	NAPI_GRO_CB(skb)->last = skb;
 	skb_shinfo(skb)->gso_size = skb_gro_len(skb);
 	skb->next = napi->gro_list;
 	napi->gro_list = skb;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 1b62343f5837..8383b2bddeb9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3076,7 +3076,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	if (unlikely(p->len + len >= 65536))
 		return -E2BIG;
 
-	lp = NAPI_GRO_CB(p)->last ?: p;
+	lp = NAPI_GRO_CB(p)->last;
 	pinfo = skb_shinfo(lp);
 
 	if (headlen <= offset) {
@@ -3192,7 +3192,7 @@ merge:
 
 	__skb_pull(skb, offset);
 
-	if (!NAPI_GRO_CB(p)->last)
+	if (NAPI_GRO_CB(p)->last == p)
 		skb_shinfo(p)->frag_list = skb;
 	else
 		NAPI_GRO_CB(p)->last->next = skb;
