From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/3] [IPV6] ROUTE: Add support for fwmask in routing rules.
Date: Sat, 26 Aug 2006 00:09:37 +0900 (JST)
Message-ID: <20060826.000937.92483566.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:56842 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1422705AbWHYPHs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 11:07:48 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6] ROUTE: Add support for fwmask in routing rules.

Add support for fwmark masks.
A mask of 0xFFFFFFFF is used when a mark value != 0 is sent without a mask.

Based on patch for net/ipv4/fib_rules.c by Patrick McHardy <kaber@trash.net>.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/fib6_rules.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 3d64c71..ee4aa43 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -28,6 +28,7 @@ struct fib6_rule
 	struct rt6key		dst;
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
 	u32			fwmark;
+	u32			fwmask;
 #endif
 	u8			tclass;
 };
@@ -128,7 +129,7 @@ static int fib6_rule_match(struct fib_ru
 		return 0;
 
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
-	if (r->fwmark && (r->fwmark != fl->fl6_fwmark))
+	if ((r->fwmark ^ fl->fl6_fwmark) / r->fwmask)
 		return 0;
 #endif
 
@@ -141,6 +142,7 @@ static struct nla_policy fib6_rule_polic
 	[FRA_SRC]	= { .minlen = sizeof(struct in6_addr) },
 	[FRA_DST]	= { .minlen = sizeof(struct in6_addr) },
 	[FRA_FWMARK]	= { .type = NLA_U32 },
+	[FRA_FWMASK]	= { .type = NLA_U32 },
 	[FRA_TABLE]	= { .type = NLA_U32 },
 };
 
@@ -174,8 +176,20 @@ static int fib6_rule_configure(struct fi
 			   sizeof(struct in6_addr));
 
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
-	if (tb[FRA_FWMARK])
+	if (tb[FRA_FWMARK]) {
 		rule6->fwmark = nla_get_u32(tb[FRA_FWMARK]);
+		if (rule6->fwmark) {
+			/*
+			 * if the mark value is non-zero,
+			 * all bits are compared by default
+			 * unless a mask is explicitly specified.
+			 */
+			rule6->fwmask = 0xFFFFFFFF;
+		}
+	}
+
+	if (tb[FRA_FWMASK])
+		rule6->fwmask = nla_get_u32(tb[FRA_FWMASK]);
 #endif
 
 	rule6->src.plen = frh->src_len;
@@ -212,6 +226,9 @@ static int fib6_rule_compare(struct fib_
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (rule6->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
+
+	if (tb[FRA_FWMASK] && (rule6->fwmask != nla_get_u32(tb[FRA_FWMASK])))
+		return 0;
 #endif
 
 	return 1;
@@ -238,6 +255,9 @@ static int fib6_rule_fill(struct fib_rul
 #ifdef CONFIG_IPV6_ROUTE_FWMARK
 	if (rule6->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, rule6->fwmark);
+
+	if (rule6->fwmask)
+		NLA_PUT_U32(skb, FRA_FWMASK, rule6->fwmask);
 #endif
 
 	return 0;

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
