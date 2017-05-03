From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/16] netfilter: Wrong icmp6 checksum for ICMPV6_TIME_EXCEED in reverse SNATv6 path
Date: Wed,  3 May 2017 11:32:07 +0200
Message-ID: <1493803931-2837-13-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Johnson <dave-kernel@centerclick.org>

When recalculating the outer ICMPv6 checksum for a reverse path NATv6
such as ICMPV6_TIME_EXCEED nf_nat_icmpv6_reply_translation() was
accessing data beyond the headlen of the skb for non-linear skb.  This
resulted in incorrect ICMPv6 checksum as garbage data was used.

Patch replaces csum_partial() with skb_checksum() which supports
non-linear skbs similar to nf_nat_icmp_reply_translation() from ipv4.

Signed-off-by: Dave Johnson <dave-kernel@centerclick.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index e0be97e636a4..69937b637ee5 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -235,7 +235,7 @@ int nf_nat_icmpv6_reply_translation(struct sk_buff *skb,
 		inside->icmp6.icmp6_cksum =
 			csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr,
 					skb->len - hdrlen, IPPROTO_ICMPV6,
-					csum_partial(&inside->icmp6,
+					skb_checksum(skb, hdrlen,
 						     skb->len - hdrlen, 0));
 	}
 
-- 
2.1.4

