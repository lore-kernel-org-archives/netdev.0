From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Subject: [PATCH v3] fib_rules: Added NLM_F_EXCL support to fib_nl_newrule
Date: Tue, 28 Jun 2016 14:03:52 +0200
Message-ID: <577267A8.4020101@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0130.outbound.protection.outlook.com ([157.56.112.130]:59066
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752164AbcF1NiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 09:38:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When adding rule with NLM_F_EXCL flag then check if the same rule exist.
If yes then exit with -EEXIST.

This is already implemented in iproute2:
        if (cmd == RTM_NEWRULE) {
                req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
                req.r.rtm_type = RTN_UNICAST;
        }

Tested ipv4 and ipv6 with net-next linux on qemu x86

expected behavior after patch:
localhost ~ # ip rule
0:    from all lookup local
32766:    from all lookup main
32767:    from all lookup default
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
localhost ~ # ip rule add from 10.46.177.97 lookup 104 pref 1005
RTNETLINK answers: File exists
localhost ~ # ip rule
0:    from all lookup local
1005:    from 10.46.177.97 lookup 104
32766:    from all lookup main
32767:    from all lookup default

There was already topic regarding this but I don't see any changes
merged and problem still occurs.
https://lkml.kernel.org/r/1135778809.5944.7.camel+%28%29+localhost+%21+localdomain

Signed-off-by: Mateusz Bajorski <mateusz.bajorski@nokia.com>
---
Changes in v2: section moved to new place where new rule is already built
Changes in v3: compare moved to helper, added fr_net compare

 net/core/fib_rules.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 98298b1..fa0c3ff 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -269,6 +269,46 @@ errout:
 	return err;
 }
 
+static int rule_exists(struct fib_rules_ops *ops, struct fib_rule_hdr *frh,
+		       struct nlattr **tb, struct fib_rule *rule)
+{
+	struct fib_rule *r;
+
+	list_for_each_entry(r, &ops->rules_list, list) {
+		if (r->action != rule->action)
+			continue;
+
+		if (r->table != rule->table)
+			continue;
+
+		if (r->pref != rule->pref)
+			continue;
+
+		if (memcmp(r->iifname, rule->iifname, IFNAMSIZ))
+			continue;
+
+		if (memcmp(r->oifname, rule->oifname, IFNAMSIZ))
+			continue;
+
+		if (r->mark != rule->mark)
+			continue;
+
+		if (r->mark_mask != rule->mark_mask)
+			continue;
+
+		if (r->tun_id != rule->tun_id)
+			continue;
+
+		if (r->fr_net != rule->fr_net)
+			continue;
+
+		if (!ops->compare(r, frh, tb))
+			continue;
+		return 1;
+	}
+	return 0;
+}
+
 int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -386,6 +426,12 @@ int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (rule->l3mdev && rule->table)
 		goto errout_free;
 
+	if ((nlh->nlmsg_flags & NLM_F_EXCL) &&
+	    rule_exists(ops, frh, tb, rule)) {
+		err = -EEXIST;
+		goto errout_free;
+	}
+
 	err = ops->configure(rule, skb, frh, tb);
 	if (err < 0)
 		goto errout_free;
-- 
2.6.4
