From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: handle NAPI_GRO_FREE_STOLEN_HEAD case also in
 napi_frags_finish()
Date: Thu, 29 Jun 2017 23:59:13 -0700
Message-ID: <1498805953.736.153.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170629091336.3A0A6A1381@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36849 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751494AbdF3G7R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 02:59:17 -0400
Received: by mail-wr0-f193.google.com with SMTP id 77so38336558wrb.3
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 23:59:16 -0700 (PDT)
In-Reply-To: <20170629091336.3A0A6A1381@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-29 at 11:13 +0200, Michal Kubecek wrote:
> Recently I started seeing warnings about pages with refcount -1. The
> problem was traced to packets being reused after their head was merged into
> a GRO packet by skb_gro_receive(). While bisecting the issue pointed to
> commit c21b48cc1bbf ("net: adjust skb->truesize in ___pskb_trim()") and
> I have never seen it on a kernel with it reverted, I believe the real
> problem appeared earlier when the option to merge head frag in GRO was
> implemented.
> 
> Handling NAPI_GRO_FREE_STOLEN_HEAD state was only added to GRO_MERGED_FREE
> branch of napi_skb_finish() so that if the driver uses napi_gro_frags()
> and head is merged (which in my case happens after the skb_condense()
> call added by the commit mentioned above), the skb is reused including the
> head that has been merged. As a result, we release the page reference
> twice and eventually end up with negative page refcount.
> 
> To fix the problem, handle NAPI_GRO_FREE_STOLEN_HEAD in napi_frags_finish()
> the same way it's done in napi_skb_finish().
> 
> Fixes: d7e8883cfcf4 ("net: make GRO aware of skb->head_frag")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---

Nice catch !

Bug origin was when napi_get_frags() got skb->head as a page fragment.

Back in the days of commit d7e8883cfcf4 ("net: make GRO aware of
skb->head_frag"), napi_get_frags() was using a regular kmalloc() backed
skb->head


At Google we reverted to alloc_skb(), in order to not hold a page
fragment (up to order-3 page) for out of order TCP segments.

diff --git a/net/core/dev.c b/net/core/dev.c
index 416137c64bf8..a22c3f06690b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4838,8 +4838,10 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 	struct sk_buff *skb = napi->skb;
 
 	if (!skb) {
-		skb = napi_alloc_skb(napi, GRO_MAX_HEAD);
+		skb = alloc_skb(GRO_MAX_HEAD + NET_SKB_PAD + NET_IP_ALIGN, GFP_ATOMIC);
 		if (skb) {
+			skb->dev = napi->dev;
+			skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
 			napi->skb = skb;
 			skb_mark_napi_id(skb, napi);
 		}
