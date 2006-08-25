From: Patrick McHardy <kaber@trash.net>
Subject: [IPV4]: Add support for fwmark masks in routing rules
Date: Fri, 25 Aug 2006 14:14:05 +0200
Message-ID: <44EEE98D.9040100@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070004090200010306090804"
Cc: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37033 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751462AbWHYMOI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:14:08 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070004090200010306090804
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Hi Dave,

these three patches add support for masking the nfmark value
in a few spots where it would be useful in an attempt to make
life easier for users using it for multiple unrelated things.


--------------070004090200010306090804
Content-Type: text/plain;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[IPV4]: Add support for fwmark masks in routing rules

Add a FRA_FWMASK attributes for fwmark masks. For compatibility a mask of
0xFFFFFFFF is used when a mark value != 0 is sent without a mask.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9037bbabed75d822002be78047f518d42f225a00
tree 2ccc07b7c4d7f20b2b8722ed935908595c197803
parent e6d442e62c126e11b3199ca1bddeb7534a7cb15e
author Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 13:59:10 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 13:59:10 +0200

 include/linux/fib_rules.h |    3 ++-
 net/ipv4/fib_rules.c      |   21 +++++++++++++++++++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 19a82b6..4418c8d 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -34,12 +34,13 @@ enum
 	FRA_UNUSED3,
 	FRA_UNUSED4,
 	FRA_UNUSED5,
-	FRA_FWMARK,	/* netfilter mark (IPv4) */
+	FRA_FWMARK,	/* netfilter mark */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,
 	FRA_UNUSED8,
 	FRA_TABLE,	/* Extended table id */
+	FRA_FWMASK,	/* mask for netfilter mark */
 	__FRA_MAX
 };
 
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index ce185ac..280f424 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -46,6 +46,7 @@ struct fib4_rule
 	u32			dstmask;
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	u32			fwmark;
+	u32			fwmask;
 #endif
 #ifdef CONFIG_NET_CLS_ROUTE
 	u32			tclassid;
@@ -160,7 +161,7 @@ static int fib4_rule_match(struct fib_ru
 		return 0;
 
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	if (r->fwmark && (r->fwmark != fl->fl4_fwmark))
+	if ((r->fwmark ^ fl->fl4_fwmark) & r->fwmask)
 		return 0;
 #endif
 
@@ -183,6 +184,7 @@ static struct nla_policy fib4_rule_polic
 	[FRA_SRC]	= { .type = NLA_U32 },
 	[FRA_DST]	= { .type = NLA_U32 },
 	[FRA_FWMARK]	= { .type = NLA_U32 },
+	[FRA_FWMASK]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
 	[FRA_TABLE]	= { .type = NLA_U32 },
 };
@@ -219,8 +221,17 @@ static int fib4_rule_configure(struct fi
 		rule4->dst = nla_get_u32(tb[FRA_DST]);
 
 #ifdef CONFIG_IP_ROUTE_FWMARK
-	if (tb[FRA_FWMARK])
+	if (tb[FRA_FWMARK]) {
 		rule4->fwmark = nla_get_u32(tb[FRA_FWMARK]);
+		if (rule4->fwmark)
+			/* compatibility: if the mark value is non-zero all bits
+			 * are compared unless a mask is explicitly specified.
+			 */
+			rule4->fwmask = 0xFFFFFFFF;
+	}
+
+	if (tb[FRA_FWMASK])
+		rule4->fwmask = nla_get_u32(tb[FRA_FWMASK]);
 #endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -256,6 +267,9 @@ static int fib4_rule_compare(struct fib_
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (rule4->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
+
+	if (tb[FRA_FWMASK] && (rule4->fwmask != nla_get_u32(tb[FRA_FWMASK])))
+		return 0;
 #endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -285,6 +299,9 @@ static int fib4_rule_fill(struct fib_rul
 #ifdef CONFIG_IP_ROUTE_FWMARK
 	if (rule4->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, rule4->fwmark);
+
+	if (rule4->fwmask || rule4->fwmark)
+		NLA_PUT_U32(skb, FRA_FWMASK, rule4->fwmask);
 #endif
 
 	if (rule4->dst_len)

--------------070004090200010306090804--
