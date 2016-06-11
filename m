From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] fib_rules: don't break ECN with TOS rules
Date: Sat, 11 Jun 2016 23:10:23 +0200
Message-ID: <1465679423-27414-1-git-send-email-hannes@stressinduktion.org>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53484 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752080AbcFKVKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 17:10:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users of ToS rules could accidentally break ECN, this patch tries to
fix this in a way so we don't break shell scripts depending on the old
behavior while still being transparent to ECN. This quietly fixes ECN
behavior for old setups.

For IPv6 we have no check if we check for ECN bits, in IPv4 we only
check for the last bit, which is specified to be '0' from pre-DSCP times
(because of implementation confusion).

This patch changes fib rules in a way that matches only for ecn bits
will never match from now on (I consider them illegal), as we simply
ignore those rules (it was easier to explain in a pr_warn). Opinions?

Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/inet_ecn.h | 5 +++++
 net/ipv4/fib_rules.c   | 6 +++++-
 net/ipv6/fib6_rules.c  | 7 ++++++-
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 0dc0a51da38faa..be65d94c05ee01 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -17,6 +17,11 @@ enum {
 
 extern int sysctl_tunnel_ecn_log;
 
+static inline __u8 INET_ECN_ignore(__u8 dsfield)
+{
+	return dsfield & ~INET_ECN_MASK;
+}
+
 static inline int INET_ECN_is_ce(__u8 dsfield)
 {
 	return (dsfield & INET_ECN_MASK) == INET_ECN_CE;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 6e9ea69e5f751b..87efbc38589c76 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -145,7 +145,8 @@ static int fib4_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 	    ((daddr ^ r->dst) & r->dstmask))
 		return 0;
 
-	if (r->tos && (r->tos != fl4->flowi4_tos))
+	if (!INET_ECN_ignore(r->tos) ||
+	    INET_ECN_ignore(r->tos) != INET_ECN_ignore(fl4->flowi4_tos))
 		return 0;
 
 	return 1;
@@ -215,6 +216,9 @@ static int fib4_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule4->dst_len = frh->dst_len;
 	rule4->dstmask = inet_make_mask(rule4->dst_len);
 	rule4->tos = frh->tos;
+	if (!INET_ECN_ignore(rule4->tos))
+		pr_warn("ipv4: never matching ipv4 rule with match for %x added\n",
+			rule4->tos);
 
 	net->ipv4.fib_has_custom_rules = true;
 	fib_flush_external(rule->fr_net);
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 5857c1fc8b6721..4c99e0347d05b7 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -21,6 +21,7 @@
 #include <net/addrconf.h>
 #include <net/ip6_route.h>
 #include <net/netlink.h>
+#include <net/inet_ecn.h>
 
 struct fib6_rule {
 	struct fib_rule		common;
@@ -183,7 +184,8 @@ static int fib6_rule_match(struct fib_rule *rule, struct flowi *fl, int flags)
 			return 0;
 	}
 
-	if (r->tclass && r->tclass != ip6_tclass(fl6->flowlabel))
+	if (!INET_ECN_ignore(r->tclass) ||
+	    INET_ECN_ignore(r->tclass) != INET_ECN_ignore(ip6_tclass(fl6->flowlabel)))
 		return 0;
 
 	return 1;
@@ -220,6 +222,9 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 	rule6->src.plen = frh->src_len;
 	rule6->dst.plen = frh->dst_len;
 	rule6->tclass = frh->tos;
+	if (!INET_ECN_ignore(rule6->tclass))
+		pr_warn("ipv6: never matching ipv6 rule with match for tos %x added\n",
+			rule6->tclass);
 
 	err = 0;
 errout:
-- 
2.5.5
