From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] [BUG?] ip ru flush && RTNETLINK answers: Numerical result
 out of range
Date: Tue, 20 Mar 2007 07:42:49 +0100
Message-ID: <45FF8269.3000606@trash.net>
References: <200703190046.47021.luciano@lugmen.org.ar>	<45FE2587.3050205@trash.net> <20070319152532.GL521@postel.suug.ch> <45FF7D07.4040103@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070509070207040209050204"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, lartc@mailman.ds9a.nl
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753530AbXCTGmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 02:42:52 -0400
In-Reply-To: <45FF7D07.4040103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070509070207040209050204
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> [NET]: Fix fib_rules compatibility breakage

I forgot to remove FRA_SRC/FRA_DST from fib6_rule_policy.
Updated patch attached.


--------------070509070207040209050204
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[NET]: Fix fib_rules compatibility breakage

The fib_rules netlink attribute policy introduced in 2.6.19 broke
userspace compatibilty. When specifying a rule with "from all"
or "to all", iproute adds a zero byte long netlink attribute,
but the policy requires all addresses to have a size equal to
sizeof(struct in_addr)/sizeof(struct in6_addr), resulting in a
validation error.

Fix by only looking at the FRA_SRC/FRA_DST attributes if src_len
or dst_len is larger than zero.

DECnet is unaffected since iproute doesn't support specifying
addresses as "all".

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 676307508e675dcf434f4f18e619b195f2f503ad
tree aa87342144b3b19ebddb5011380c3ac96c38dbbc
parent db98e0b434a6265c451ffe94ec0a29b8d0aaf587
author Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 07:08:38 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 20 Mar 2007 07:42:19 +0100

 net/ipv4/fib_rules.c  |   18 ++++++++++++------
 net/ipv6/fib6_rules.c |   18 ++++++++++++------
 2 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index b837c33..9524b2e 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -171,8 +171,6 @@ static struct fib_table *fib_empty_table
 
 static struct nla_policy fib4_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .type = NLA_U32 },
-	[FRA_DST]	= { .type = NLA_U32 },
 	[FRA_FLOW]	= { .type = NLA_U32 },
 };
 
@@ -187,6 +185,12 @@ static int fib4_rule_configure(struct fi
 	    (frh->tos & ~IPTOS_TOS_MASK))
 		goto errout;
 
+	if (frh->src_len && tb[FRA_SRC] && nla_len(tb[FRA_SRC]) != sizeof(u32))
+		goto errout;
+
+	if (frh->dst_len && tb[FRA_DST] && nla_len(tb[FRA_DST]) != sizeof(u32))
+		goto errout;
+
 	if (rule->table == RT_TABLE_UNSPEC) {
 		if (rule->action == FR_ACT_TO_TBL) {
 			struct fib_table *table;
@@ -201,10 +205,10 @@ static int fib4_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len && tb[FRA_SRC])
 		rule4->src = nla_get_be32(tb[FRA_SRC]);
 
-	if (tb[FRA_DST])
+	if (frh->dst_len && tb[FRA_DST])
 		rule4->dst = nla_get_be32(tb[FRA_DST]);
 
 #ifdef CONFIG_NET_CLS_ROUTE
@@ -242,10 +246,12 @@ #ifdef CONFIG_NET_CLS_ROUTE
 		return 0;
 #endif
 
-	if (tb[FRA_SRC] && (rule4->src != nla_get_be32(tb[FRA_SRC])))
+	if (frh->src_len && tb[FRA_SRC] &&
+	    (rule4->src != nla_get_be32(tb[FRA_SRC])))
 		return 0;
 
-	if (tb[FRA_DST] && (rule4->dst != nla_get_be32(tb[FRA_DST])))
+	if (frh->dst_len && tb[FRA_DST] &&
+	    (rule4->dst != nla_get_be32(tb[FRA_DST])))
 		return 0;
 
 	return 1;
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 0862809..6331306 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -131,8 +131,6 @@ static int fib6_rule_match(struct fib_ru
 
 static struct nla_policy fib6_rule_policy[FRA_MAX+1] __read_mostly = {
 	FRA_GENERIC_POLICY,
-	[FRA_SRC]	= { .len = sizeof(struct in6_addr) },
-	[FRA_DST]	= { .len = sizeof(struct in6_addr) },
 };
 
 static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
@@ -145,6 +143,14 @@ static int fib6_rule_configure(struct fi
 	if (frh->src_len > 128 || frh->dst_len > 128)
 		goto errout;
 
+	if (frh->src_len && tb[FRA_SRC] &&
+	    nla_len(tb[FRA_SRC]) != sizeof(struct in6_addr))
+		goto errout;
+
+	if (frh->dst_len && tb[FRA_DST] &&
+	    nla_len(tb[FRA_DST]) != sizeof(struct in6_addr))
+		goto errout;
+
 	if (rule->action == FR_ACT_TO_TBL) {
 		if (rule->table == RT6_TABLE_UNSPEC)
 			goto errout;
@@ -155,11 +161,11 @@ static int fib6_rule_configure(struct fi
 		}
 	}
 
-	if (tb[FRA_SRC])
+	if (frh->src_len && tb[FRA_SRC])
 		nla_memcpy(&rule6->src.addr, tb[FRA_SRC],
 			   sizeof(struct in6_addr));
 
-	if (tb[FRA_DST])
+	if (frh->dst_len && tb[FRA_DST])
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
@@ -186,11 +192,11 @@ static int fib6_rule_compare(struct fib_
 	if (frh->tos && (rule6->tclass != frh->tos))
 		return 0;
 
-	if (tb[FRA_SRC] &&
+	if (frh->src_len && tb[FRA_SRC] &&
 	    nla_memcmp(tb[FRA_SRC], &rule6->src.addr, sizeof(struct in6_addr)))
 		return 0;
 
-	if (tb[FRA_DST] &&
+	if (frh->dst_len && tb[FRA_DST] &&
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 

--------------070509070207040209050204--
