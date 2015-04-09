From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/20] netfilter: nft_meta: fix cgroup matching
Date: Thu,  9 Apr 2015 13:34:51 +0200
Message-ID: <1428579304-5520-8-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33094 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932941AbbDILbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:13 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to stop iterating on the rule expressions if the cgroup
mismatches. Moreover, make sure a non-full socket from the input path
leads us to a crash.

Fixes: ce67417 ("netfilter: nft_meta: add cgroup support")
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_meta.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 5197874..d79ce88 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -166,9 +166,8 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		dest->data[0] = out->group;
 		break;
 	case NFT_META_CGROUP:
-		if (skb->sk == NULL)
-			break;
-
+		if (skb->sk == NULL || !sk_fullsock(skb->sk))
+			goto err;
 		dest->data[0] = skb->sk->sk_classid;
 		break;
 	default:
-- 
1.7.10.4
