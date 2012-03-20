From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v3] ipv6: fix incorrent ipv6 ipsec packet fragment
Date: Tue, 20 Mar 2012 16:36:10 +0800
Message-ID: <1332232570-17424-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <20120320075846.GF29891@secunet.com>
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15850 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756835Ab2CTIfp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 04:35:45 -0400
In-Reply-To: <20120320075846.GF29891@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
In func ip6_append_data,after call skb_put(skb, fraglen + dst_exthdrlen)
the skb->len contains dst_exthdrlen,and we don't reduce dst_exthdrlen at last
This will make fraggap>0 in next "while cycle",and cause the size of skb incorrent

Fix this by reserve headroom for dst_exthdrlen.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/ip6_output.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d97e071..ea58e27a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1416,8 +1416,9 @@ alloc_new_skb:
 			 */
 			skb->ip_summed = csummode;
 			skb->csum = 0;
-			/* reserve for fragmentation */
-			skb_reserve(skb, hh_len+sizeof(struct frag_hdr));
+			/* reserve for fragmentation and ipsec header */
+			skb_reserve(skb, hh_len + sizeof(struct frag_hdr) +
+				    dst_exthdrlen);
 
 			if (sk->sk_type == SOCK_DGRAM)
 				skb_shinfo(skb)->tx_flags = tx_flags;
@@ -1425,9 +1426,9 @@ alloc_new_skb:
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
