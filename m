From: Mateusz Bajorski <mateusz.bajorski@nokia.com>
Subject: [PATCH] Added NLM_F_EXCL support to fib_nl_newrule
Date: Fri, 20 May 2016 17:58:23 +0200
Message-ID: <573F341F.7020302@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0142.outbound.protection.outlook.com ([157.56.112.142]:43066
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753958AbcETP5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 May 2016 11:57:04 -0400
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
 net/core/fib_rules.c | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 840aceb..b9816a3 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -291,6 +291,47 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (err < 0)
 		goto errout;
 
+	if (nlh->nlmsg_flags & NLM_F_EXCL) {
+		list_for_each_entry(rule, &ops->rules_list, list) {
+			if (frh->action && (frh->action != rule->action))
+				continue;
+
+			if (frh_get_table(frh, tb) &&
+				frh_get_table(frh, tb) != rule->table)
+				continue;
+
+			if (tb[FRA_PRIORITY] &&
+				rule->pref != nla_get_u32(tb[FRA_PRIORITY]))
+				continue;
+
+			if (tb[FRA_IIFNAME] &&
+				nla_strcmp(tb[FRA_IIFNAME], rule->iifname))
+				continue;
+
+			if (tb[FRA_OIFNAME] &&
+				nla_strcmp(tb[FRA_OIFNAME], rule->oifname))
+				continue;
+
+			if (tb[FRA_FWMARK] &&
+				rule->mark != nla_get_u32(tb[FRA_FWMARK]))
+				continue;
+
+			if (tb[FRA_FWMASK] &&
+				rule->mark_mask != nla_get_u32(tb[FRA_FWMASK]))
+				continue;
+
+			if (tb[FRA_TUN_ID] &&
+				rule->tun_id != nla_get_be64(tb[FRA_TUN_ID]))
+				continue;
+
+			if (!ops->compare(rule, frh, tb))
+				continue;
+
+			err = -EEXIST;
+			goto errout;
+		}
+	}
+
 	rule = kzalloc(ops->rule_size, GFP_KERNEL);
 	if (rule == NULL) {
 		err = -ENOMEM;
-- 
2.6.4
