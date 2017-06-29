From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH net] net: handle NAPI_GRO_FREE_STOLEN_HEAD case also in
 napi_frags_finish()
Date: Thu, 29 Jun 2017 11:13:36 +0200 (CEST)
Message-ID: <20170629091336.3A0A6A1381@unicorn.suse.cz>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46898 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752172AbdF2JNl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 05:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I started seeing warnings about pages with refcount -1. The
problem was traced to packets being reused after their head was merged into
a GRO packet by skb_gro_receive(). While bisecting the issue pointed to
commit c21b48cc1bbf ("net: adjust skb->truesize in ___pskb_trim()") and
I have never seen it on a kernel with it reverted, I believe the real
problem appeared earlier when the option to merge head frag in GRO was
implemented.

Handling NAPI_GRO_FREE_STOLEN_HEAD state was only added to GRO_MERGED_FREE
branch of napi_skb_finish() so that if the driver uses napi_gro_frags()
and head is merged (which in my case happens after the skb_condense()
call added by the commit mentioned above), the skb is reused including the
head that has been merged. As a result, we release the page reference
twice and eventually end up with negative page refcount.

To fix the problem, handle NAPI_GRO_FREE_STOLEN_HEAD in napi_frags_finish()
the same way it's done in napi_skb_finish().

Fixes: d7e8883cfcf4 ("net: make GRO aware of skb->head_frag")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/core/dev.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 91bb55070533..416137c64bf8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4767,6 +4767,13 @@ struct packet_offload *gro_find_complete_by_type(__be16 type)
 }
 EXPORT_SYMBOL(gro_find_complete_by_type);
 
+static void napi_skb_free_stolen_head(struct sk_buff *skb)
+{
+	skb_dst_drop(skb);
+	secpath_reset(skb);
+	kmem_cache_free(skbuff_head_cache, skb);
+}
+
 static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
 	switch (ret) {
@@ -4780,13 +4787,10 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 		break;
 
 	case GRO_MERGED_FREE:
-		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD) {
-			skb_dst_drop(skb);
-			secpath_reset(skb);
-			kmem_cache_free(skbuff_head_cache, skb);
-		} else {
+		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
+			napi_skb_free_stolen_head(skb);
+		else
 			__kfree_skb(skb);
-		}
 		break;
 
 	case GRO_HELD:
@@ -4858,10 +4862,16 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi,
 		break;
 
 	case GRO_DROP:
-	case GRO_MERGED_FREE:
 		napi_reuse_skb(napi, skb);
 		break;
 
+	case GRO_MERGED_FREE:
+		if (NAPI_GRO_CB(skb)->free == NAPI_GRO_FREE_STOLEN_HEAD)
+			napi_skb_free_stolen_head(skb);
+		else
+			napi_reuse_skb(napi, skb);
+		break;
+
 	case GRO_MERGED:
 	case GRO_CONSUMED:
 		break;
-- 
2.13.2
