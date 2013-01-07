From: pablo@netfilter.org
Subject: [PATCH 1/3] netfilter: ip6t_NPT: fix IPv6 NTP checksum calculation
Date: Mon,  7 Jan 2013 21:04:05 +0100
Message-ID: <1357589047-3373-2-git-send-email-pablo@netfilter.org>
References: <1357589047-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1357589047-3373-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Weber <ulrich.weber@sophos.com>

csum16_add() has a broken carry detection, should be:
sum += sum < (__force u16)b;

Instead of fixing csum16_add, remove the custom checksum
functions and use the generic csum_add/csum_sub ones.

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
Acked-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |   33 +++++++--------------------------
 1 file changed, 7 insertions(+), 26 deletions(-)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NPT.c
index e948691..7302b0b 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -14,42 +14,23 @@
 #include <linux/netfilter_ipv6/ip6t_NPT.h>
 #include <linux/netfilter/x_tables.h>
 
-static __sum16 csum16_complement(__sum16 a)
-{
-	return (__force __sum16)(0xffff - (__force u16)a);
-}
-
-static __sum16 csum16_add(__sum16 a, __sum16 b)
-{
-	u16 sum;
-
-	sum = (__force u16)a + (__force u16)b;
-	sum += (__force u16)a < (__force u16)b;
-	return (__force __sum16)sum;
-}
-
-static __sum16 csum16_sub(__sum16 a, __sum16 b)
-{
-	return csum16_add(a, csum16_complement(b));
-}
-
 static int ip6t_npt_checkentry(const struct xt_tgchk_param *par)
 {
 	struct ip6t_npt_tginfo *npt = par->targinfo;
-	__sum16 src_sum = 0, dst_sum = 0;
+	__wsum src_sum = 0, dst_sum = 0;
 	unsigned int i;
 
 	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
 		return -EINVAL;
 
 	for (i = 0; i < ARRAY_SIZE(npt->src_pfx.in6.s6_addr16); i++) {
-		src_sum = csum16_add(src_sum,
-				(__force __sum16)npt->src_pfx.in6.s6_addr16[i]);
-		dst_sum = csum16_add(dst_sum,
-				(__force __sum16)npt->dst_pfx.in6.s6_addr16[i]);
+		src_sum = csum_add(src_sum,
+				(__force __wsum)npt->src_pfx.in6.s6_addr16[i]);
+		dst_sum = csum_add(dst_sum,
+				(__force __wsum)npt->dst_pfx.in6.s6_addr16[i]);
 	}
 
-	npt->adjustment = csum16_sub(src_sum, dst_sum);
+	npt->adjustment = (__force __sum16) csum_sub(src_sum, dst_sum);
 	return 0;
 }
 
@@ -85,7 +66,7 @@ static bool ip6t_npt_map_pfx(const struct ip6t_npt_tginfo *npt,
 			return false;
 	}
 
-	sum = csum16_add((__force __sum16)addr->s6_addr16[idx],
+	sum = (__force __sum16) csum_add((__force __wsum)addr->s6_addr16[idx],
 			 npt->adjustment);
 	if (sum == CSUM_MANGLED_0)
 		sum = 0;
-- 
1.7.10.4

