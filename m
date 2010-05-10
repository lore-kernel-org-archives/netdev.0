From: kaber@trash.net
Subject: [PATCH 02/84] netfilter: ebt_ip6: Use ipv6_masked_addr_cmp()
Date: Mon, 10 May 2010 22:17:33 +0200
Message-ID: <1273522735-24672-3-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/netfilter/ebt_ip6.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index bbf2534..4644cc9 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -35,8 +35,6 @@ ebt_ip6_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	struct ipv6hdr _ip6h;
 	const struct tcpudphdr *pptr;
 	struct tcpudphdr _ports;
-	struct in6_addr tmp_addr;
-	int i;
 
 	ih6 = skb_header_pointer(skb, 0, sizeof(_ip6h), &_ip6h);
 	if (ih6 == NULL)
@@ -44,18 +42,10 @@ ebt_ip6_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (info->bitmask & EBT_IP6_TCLASS &&
 	   FWINV(info->tclass != ipv6_get_dsfield(ih6), EBT_IP6_TCLASS))
 		return false;
-	for (i = 0; i < 4; i++)
-		tmp_addr.in6_u.u6_addr32[i] = ih6->saddr.in6_u.u6_addr32[i] &
-			info->smsk.in6_u.u6_addr32[i];
-	if (info->bitmask & EBT_IP6_SOURCE &&
-		FWINV((ipv6_addr_cmp(&tmp_addr, &info->saddr) != 0),
-			EBT_IP6_SOURCE))
-		return false;
-	for (i = 0; i < 4; i++)
-		tmp_addr.in6_u.u6_addr32[i] = ih6->daddr.in6_u.u6_addr32[i] &
-			info->dmsk.in6_u.u6_addr32[i];
-	if (info->bitmask & EBT_IP6_DEST &&
-	   FWINV((ipv6_addr_cmp(&tmp_addr, &info->daddr) != 0), EBT_IP6_DEST))
+	if (FWINV(ipv6_masked_addr_cmp(&ih6->saddr, &info->smsk,
+				       &info->saddr), EBT_IP6_SOURCE) ||
+	    FWINV(ipv6_masked_addr_cmp(&ih6->daddr, &info->dmsk,
+				       &info->daddr), EBT_IP6_DEST))
 		return false;
 	if (info->bitmask & EBT_IP6_PROTO) {
 		uint8_t nexthdr = ih6->nexthdr;
-- 
1.7.0.4

