From: Patrick McHardy <kaber@trash.net>
Subject: [DECNET]: Add support for fwmark masks in routing rules
Date: Fri, 25 Aug 2006 14:14:12 +0200
Message-ID: <44EEE994.90404@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070901030708000602020604"
Cc: Linux Netdev List <netdev@vger.kernel.org>, patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37801 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751462AbWHYMOP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:14:15 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070901030708000602020604
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------070901030708000602020604
Content-Type: text/plain;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[DECNET]: Add support for fwmark masks in routing rules

Add support for fwmark masks. For compatibility a mask of 0xFFFFFFFF is used
when a mark value != 0 is sent without a mask.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit bcd4f6996453aaf0a8d5515dcc533115621c961f
tree 62909d3d2c6edd4f236284b86c4c422cb40bc489
parent 9037bbabed75d822002be78047f518d42f225a00
author Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 14:00:12 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 25 Aug 2006 14:00:12 +0200

 net/decnet/dn_rules.c |   20 ++++++++++++++++++--
 1 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 50e819e..63ad63d 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -47,6 +47,7 @@ struct dn_fib_rule
 	u8			flags;
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
 	u32			fwmark;
+	u32			fwmask;
 #endif
 };
 
@@ -116,6 +117,7 @@ static struct nla_policy dn_fib_rule_pol
 	[FRA_SRC]	= { .type = NLA_U16 },
 	[FRA_DST]	= { .type = NLA_U16 },
 	[FRA_FWMARK]	= { .type = NLA_U32 },
+	[FRA_FWMASK]	= { .type = NLA_U32 },
 	[FRA_TABLE]     = { .type = NLA_U32 },
 };
 
@@ -130,7 +132,7 @@ static int dn_fib_rule_match(struct fib_
 		return 0;
 
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-	if (r->fwmark && (r->fwmark != fl->fld_fwmark))
+	if ((r->fwmark ^ fl->fld_fwmark) & r->fwmask)
 		return 0;
 #endif
 
@@ -168,8 +170,17 @@ static int dn_fib_rule_configure(struct 
 		r->dst = nla_get_u16(tb[FRA_DST]);
 
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
-	if (tb[FRA_FWMARK])
+	if (tb[FRA_FWMARK]) {
 		r->fwmark = nla_get_u32(tb[FRA_FWMARK]);
+		if (r->fwmark)
+			/* compatibility: if the mark value is non-zero all bits
+			 * are compared unless a mask is explicitly specified.
+			 */
+			r->fwmask = 0xFFFFFFFF;
+	}
+
+	if (tb[FRA_FWMASK])
+		r->fwmask = nla_get_u32(tb[FRA_FWMASK]);
 #endif
 
 	r->src_len = frh->src_len;
@@ -195,6 +206,9 @@ static int dn_fib_rule_compare(struct fi
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
 	if (tb[FRA_FWMARK] && (r->fwmark != nla_get_u32(tb[FRA_FWMARK])))
 		return 0;
+
+	if (tb[FRA_FWMASK] && (r->fwmask != nla_get_u32(tb[FRA_FWMASK])))
+		return 0;
 #endif
 
 	if (tb[FRA_SRC] && (r->src != nla_get_u16(tb[FRA_SRC])))
@@ -237,6 +251,8 @@ static int dn_fib_rule_fill(struct fib_r
 #ifdef CONFIG_DECNET_ROUTE_FWMARK
 	if (r->fwmark)
 		NLA_PUT_U32(skb, FRA_FWMARK, r->fwmark);
+	if (r->fwmask || r->fwmark)
+		NLA_PUT_U32(skb, FRA_FWMASK, r->fwmask);
 #endif
 	if (r->dst_len)
 		NLA_PUT_U16(skb, FRA_DST, r->dst);

--------------070901030708000602020604--
