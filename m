From: Shmulik Ladkani <shmulik@nsof.io>
Subject: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare implementations to support exact match
Date: Sat, 30 Sep 2017 11:59:09 +0300
Message-ID: <20170930085909.1103-1-shmulik@nsof.io>
Cc: Mateusz Bajorski <mateusz.bajorski@nokia.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Thomas Graf <tgraf@suug.ch>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:50462 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750933AbdI3I7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 04:59:36 -0400
Received: by mail-wm0-f43.google.com with SMTP id u138so2940720wmu.5
        for <netdev@vger.kernel.org>; Sat, 30 Sep 2017 01:59:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Commit 153380ec4b9b ("fib_rules: Added NLM_F_EXCL support to fib_nl_newrule")
added a check to 'fib_nl_newrule' that tests whether the suggested rule
already exists (i.e. has same properties). The check uses
fib_rules_ops->compare() method to compare the protocol specific
properties.

However, the 'compare()' implementations have wildcard semantics:
They compared the src_len of the given 'frh' against existing rules
ONLY if frh->src_len is specified (i.e. non-zero).
Same applies to dst_len and tos fields.

The wildcard behavior exists, since formerly (prior 153380ec4b9b),
the only use of 'compare' was in fib_nl_delrule, and it was expected
that one can delete a rule using a partial match.

However, the wildcard behavior is incorrect for fib_nl_newrule:
It means that if one specifies 0.0.0.0/0 as the FRA_SRC (or equivalently
doesn't specify a FRA_SRC), frh->src_len will NOT be compared against
other rules, resulting in compare returning true.

This leads to inconsistencies, depending on order of operations, e.g.:

A working sequence:
  # ip ru add from 0.0.0.0/0 iif eth2 pref 22 table 22
  # ip ru add from 10.0.0.0/8 iif eth2 pref 22 table 22
  # ip ru | grep 22                   # both added successfully
  22:  from all iif eth2 lookup 22
  22:  from 10.0.0.0/8 iif eth2 lookup 22

A non-working sequence:
  # ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33
  # ip ru add from 0.0.0.0/0 iif eth2 pref 33 table 33
  RTNETLINK answers: File exists      # wildcard compare returned true

Fix, by adding an 'exact' mode for comparison:
In exact mode, frh->src_len is compared to existing rules' src_len
regardless whether frh->src_len is non-zero.
(same applies for 'dst_len' and 'tos').

Fixes: 153380ec4b9b ("fib_rules: Added NLM_F_EXCL support to fib_nl_newrule")
Reported-by: Eyal Birger <eyal.birger@gmail.com>
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 An alternative I considered was changing all 'compare' implementations
 to have "exact" semantics.
 This has the adavantage of less user confusion, as both NEWRULE and
 DELRULE have an "exact match" behavior.
 Alas, I assume there are existing users which might rely on the
 wildcard behavior of DELRULE.
 Therefore, this patch results in NEWRULE+NLM_F_EXCL having "exact"
 semantics, but keeps the "wildcard" semantics for DELRULE.
---
 include/net/fib_rules.h | 2 +-
 net/core/fib_rules.c    | 4 ++--
 net/decnet/dn_rules.c   | 6 +++---
 net/ipv4/fib_rules.c    | 8 ++++----
 net/ipv4/ipmr.c         | 2 +-
 net/ipv6/fib6_rules.c   | 8 ++++----
 net/ipv6/ip6mr.c        | 2 +-
 7 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 3d7f1cefc6f5..23c406282af8 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -74,7 +74,7 @@ struct fib_rules_ops {
 	int			(*delete)(struct fib_rule *);
 	int			(*compare)(struct fib_rule *,
 					   struct fib_rule_hdr *,
-					   struct nlattr **);
+					   struct nlattr **, bool);
 	int			(*fill)(struct fib_rule *, struct sk_buff *,
 					struct fib_rule_hdr *);
 	size_t			(*nlmsg_payload)(struct fib_rule *);
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a6d97c1d810..7e5cdee5263a 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -422,7 +422,7 @@ static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
 		    !uid_eq(r->uid_range.end, rule->uid_range.end))
 			continue;
 
-		if (!ops->compare(r, frh, tb))
+		if (!ops->compare(r, frh, tb, true))
 			continue;
 		return 1;
 	}
@@ -702,7 +702,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 		     !uid_eq(rule->uid_range.end, range.end)))
 			continue;
 
-		if (!ops->compare(rule, frh, tb))
+		if (!ops->compare(rule, frh, tb, false))
 			continue;
 
 		if (rule->flags & FIB_RULE_PERMANENT) {
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index 295bbd6a56f2..f8117248564c 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -158,14 +158,14 @@ static int dn_fib_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 }
 
 static int dn_fib_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
-			       struct nlattr **tb)
+			       struct nlattr **tb, bool exact)
 {
 	struct dn_fib_rule *r = (struct dn_fib_rule *)rule;
 
-	if (frh->src_len && (r->src_len != frh->src_len))
+	if ((exact || frh->src_len) && r->src_len != frh->src_len)
 		return 0;
 
-	if (frh->dst_len && (r->dst_len != frh->dst_len))
+	if ((exact || frh->dst_len) && r->dst_len != frh->dst_len)
 		return 0;
 
 	if (frh->src_len && (r->src != nla_get_le16(tb[FRA_SRC])))
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 35d646a62ad4..13369b7e247f 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -277,17 +277,17 @@ static int fib4_rule_delete(struct fib_rule *rule)
 }
 
 static int fib4_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
-			     struct nlattr **tb)
+			     struct nlattr **tb, bool exact)
 {
 	struct fib4_rule *rule4 = (struct fib4_rule *) rule;
 
-	if (frh->src_len && (rule4->src_len != frh->src_len))
+	if ((exact || frh->src_len) && rule4->src_len != frh->src_len)
 		return 0;
 
-	if (frh->dst_len && (rule4->dst_len != frh->dst_len))
+	if ((exact || frh->dst_len) && rule4->dst_len != frh->dst_len)
 		return 0;
 
-	if (frh->tos && (rule4->tos != frh->tos))
+	if ((exact || frh->tos) && rule4->tos != frh->tos)
 		return 0;
 
 #ifdef CONFIG_IP_ROUTE_CLASSID
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 292a8e80bdfa..13d6702d5b8f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -192,7 +192,7 @@ static int ipmr_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 }
 
 static int ipmr_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
-			     struct nlattr **tb)
+			     struct nlattr **tb, bool exact)
 {
 	return 1;
 }
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index b240f24a6e52..7ffbff3777ce 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -265,17 +265,17 @@ static int fib6_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 }
 
 static int fib6_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
-			     struct nlattr **tb)
+			     struct nlattr **tb, bool exact)
 {
 	struct fib6_rule *rule6 = (struct fib6_rule *) rule;
 
-	if (frh->src_len && (rule6->src.plen != frh->src_len))
+	if ((exact || frh->src_len) && rule6->src.plen != frh->src_len)
 		return 0;
 
-	if (frh->dst_len && (rule6->dst.plen != frh->dst_len))
+	if ((exact || frh->dst_len) && rule6->dst.plen != frh->dst_len)
 		return 0;
 
-	if (frh->tos && (rule6->tclass != frh->tos))
+	if ((exact || frh->tos) && rule6->tclass != frh->tos)
 		return 0;
 
 	if (frh->src_len &&
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f5500f5444e9..95a0f15c4810 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -196,7 +196,7 @@ static int ip6mr_rule_configure(struct fib_rule *rule, struct sk_buff *skb,
 }
 
 static int ip6mr_rule_compare(struct fib_rule *rule, struct fib_rule_hdr *frh,
-			      struct nlattr **tb)
+			      struct nlattr **tb, bool exact)
 {
 	return 1;
 }
-- 
2.14.1
