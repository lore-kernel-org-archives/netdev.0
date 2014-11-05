From: Calvin Owens <calvinowens@fb.com>
Subject: [PATCH] ipvs: Keep skb->sk when allocating headroom on tunnel xmit
Date: Tue, 4 Nov 2014 16:37:40 -0800
Message-ID: <1415147860-11389-1-git-send-email-calvinowens@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lvs-devel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <agartrell@fb.com>, <kernel-team@fb.com>,
	Calvin Owens <calvinowens@fb.com>
To: Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39647 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751303AbaKEAjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 19:39:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_vs_prepare_tunneled_skb() ignores ->sk when allocating a new
skb, either unconditionally setting ->sk to NULL or allowing
the uninitialized ->sk from a newly allocated skb to leak through
to the caller.

This patch properly copies ->sk and increments its reference count.

Signed-off-by: Calvin Owens <calvinowens@fb.com>
---
 net/netfilter/ipvs/ip_vs_xmit.c | 2 ++
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
2.1.1
