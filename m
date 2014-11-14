From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/8] ipvs: Keep skb->sk when allocating headroom on tunnel xmit
Date: Fri, 14 Nov 2014 17:58:44 +0100
Message-ID: <1415984329-5569-5-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40388 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161382AbaKNQ5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2014 11:57:20 -0500
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Calvin Owens <calvinowens@fb.com>

ip_vs_prepare_tunneled_skb() ignores ->sk when allocating a new
skb, either unconditionally setting ->sk to NULL or allowing
the uninitialized ->sk from a newly allocated skb to leak through
to the caller.

This patch properly copies ->sk and increments its reference count.

Signed-off-by: Calvin Owens <calvinowens@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 437a366..bd90bf8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -846,6 +846,8 @@ ip_vs_prepare_tunneled_skb(struct sk_buff *skb, int skb_af,
 		new_skb = skb_realloc_headroom(skb, max_headroom);
 		if (!new_skb)
 			goto error;
+		if (skb->sk)
+			skb_set_owner_w(new_skb, skb->sk);
 		consume_skb(skb);
 		skb = new_skb;
 	}
-- 
1.7.10.4
