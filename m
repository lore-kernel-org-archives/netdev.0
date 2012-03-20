From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 11:22:59 +0800
Message-ID: <1332213779-19528-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <20120319080220.GA29891@secunet.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:37905 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754066Ab2CTDWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2012 23:22:34 -0400
In-Reply-To: <20120319080220.GA29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent

Fix this by reserve headroom for dst_exthdrlen.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..8d5d204 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1418,6 +1418,8 @@ alloc_new_skb:
 			skb->csum = 0;
 			/* reserve for fragmentation */
 			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
+			/* reserve for ipsec header */
+			skb_reserve(skb, dst_exthdrlen);
 
 			if (sk->sk_type == SOCK_DGRAM)
 				skb_shinfo(skb)->tx_flags = tx_flags;
@@ -1425,9 +1427,9 @@ alloc_new_skb:
 			/*
 			 *	Find where to start putting bytes
 			 */
-			data = skb_put(skb, fraglen + dst_exthdrlen);
-			skb_set_network_header(skb, exthdrlen + dst_exthdrlen);
-			data += fragheaderlen + dst_exthdrlen;
+			data = skb_put(skb, fraglen);
+			skb_set_network_header(skb, exthdrlen);
+			data += fragheaderlen;
 			skb->transport_header = (skb->network_header +
 						 fragheaderlen);
 			if (fraggap) {
-- 
1.7.7.6
