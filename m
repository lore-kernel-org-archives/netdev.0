From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: fib_rules: Resolve goto rules target on delete
Date: Fri, 16 Jun 2017 15:44:47 +0300
Message-ID: <1497617087-26386-1-git-send-email-serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:36810 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753500AbdFPMpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 08:45:00 -0400
Received: by mail-lf0-f68.google.com with SMTP id x81so4081959lfb.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 05:44:59 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id g41sm581520lfi.31.2017.06.16.05.44.57
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 05:44:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should avoid marking goto rules unresolved when their
target is actually reachable after rule deletion.

Consolder following sample scenario:

  # ip -4 ru sh
  0:      from all lookup local
  32000:  from all goto 32100
  32100:  from all lookup main
  32100:  from all lookup default
  32766:  from all lookup main
  32767:  from all lookup default

  # ip -4 ru del pref 32100 table main
  # ip -4 ru sh
  0:      from all lookup local
  32000:  from all goto 32100 [unresolved]
  32100:  from all lookup default
  32766:  from all lookup main
  32767:  from all lookup default

After removal of first rule with preference 32100 we
mark all goto rules as unreachable, even when rule with
same preference as removed one still present.

Check if next rule with same preference is available
and make all rules with goto action pointing to it.

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/core/fib_rules.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index f21c4d3..3bba291 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -568,7 +568,7 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct net *net = sock_net(skb->sk);
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
-	struct fib_rule *rule, *tmp;
+	struct fib_rule *rule, *r;
 	struct nlattr *tb[FRA_MAX+1];
 	struct fib_kuid_range range;
 	int err = -EINVAL;
@@ -668,16 +668,23 @@ int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 		/*
 		 * Check if this rule is a target to any of them. If so,
+		 * adjust to the next one with the same preference or
 		 * disable them. As this operation is eventually very
-		 * expensive, it is only performed if goto rules have
-		 * actually been added.
+		 * expensive, it is only performed if goto rules, except
+		 * current if it is goto rule, have actually been added.
 		 */
 		if (ops->nr_goto_rules > 0) {
-			list_for_each_entry(tmp, &ops->rules_list, list) {
-				if (rtnl_dereference(tmp->ctarget) == rule) {
-					RCU_INIT_POINTER(tmp->ctarget, NULL);
+			struct fib_rule *n;
+
+			n = list_next_entry(rule, list);
+			if (&n->list == &ops->rules_list || n->pref != rule->pref)
+				n = NULL;
+			list_for_each_entry(r, &ops->rules_list, list) {
+				if (rtnl_dereference(r->ctarget) != rule)
+					continue;
+				rcu_assign_pointer(r->ctarget, n);
+				if (!n)
 					ops->unresolved_rules++;
-				}
 			}
 		}
 
-- 
1.8.3.1
