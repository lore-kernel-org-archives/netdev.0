From: pablo@netfilter.org
Subject: [PATCH 01/12] netfilter: ip6t_NPT: Use csum_partial()
Date: Mon, 25 Mar 2013 13:15:41 +0100
Message-ID: <1364213752-3934-2-git-send-email-pablo@netfilter.org>
References: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1364213752-3934-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

[ Some fixes went into mainstream before this patch, so I needed
  to rebase it upon the current tree, that's why it's different from
  the original one posted on the list --pablo ]

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NPT.c
index 83acc14..59286a1 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -18,9 +18,8 @@
 static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
 {
 	struct ip6t_npt_tginfo *npt = par->targinfo;
-	__wsum src_sum = 0, dst_sum = 0;
 	struct in6_addr pfx;
-	unsigned int i;
+	__wsum src_sum, dst_sum;
 
 	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
 		return -EINVAL;
@@ -33,12 +32,8 @@ static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
 	if (!ipv6_addr_equal(&pfx, &npt->dst_pfx.in6))
 		return -EINVAL;
 
-	for (i = 0; i < ARRAY_SIZE(npt->src_pfx.in6.s6_addr16); i++) {
-		src_sum = csum_add(src_sum,
-				(__force __wsum)npt->src_pfx.in6.s6_addr16[i]);
-		dst_sum = csum_add(dst_sum,
-				(__force __wsum)npt->dst_pfx.in6.s6_addr16[i]);
-	}
+	src_sum = csum_partial(&npt->src_pfx.in6, sizeof(npt->src_pfx.in6), 0);
+	dst_sum = csum_partial(&npt->dst_pfx.in6, sizeof(npt->dst_pfx.in6), 0);
 
 	npt->adjustment = ~csum_fold(csum_sub(src_sum, dst_sum));
 	return 0;
-- 
1.7.10.4

