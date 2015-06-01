From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 06/14] fib: Add fib rule match on tunnel id
Date: Mon,  1 Jun 2015 16:27:30 +0200
Message-ID: <1cb04f26fad40df863f2ff49c64020dd327cdd4f.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50989 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbbFAO1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:50 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add the ability to select a routing table based on the tunnel
id which allows to maintain separate routing tables for each virtual
tunnel network.

ip rule add from all tunnel-id 100 lookup 100
ip rule add from all tunnel-id 200 lookup 200

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/fib_rules.h        |  1 +
 include/uapi/linux/fib_rules.h |  2 +-
 net/core/fib_rules.c           | 17 +++++++++++++++--
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 6d67383..822ed1e 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -19,6 +19,7 @@ struct fib_rule {
 	u8			action;
 	/* 3 bytes hole, try to use */
 	u32			target;
+	__be64			tun_id;
 	struct fib_rule __rcu	*ctarget;
 	struct net		*fr_net;
 
diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
index 2b82d7e..96161b8 100644
--- a/include/uapi/linux/fib_rules.h
+++ b/include/uapi/linux/fib_rules.h
@@ -43,7 +43,7 @@ enum {
 	FRA_UNUSED5,
 	FRA_FWMARK,	/* mark */
 	FRA_FLOW,	/* flow/class id */
-	FRA_UNUSED6,
+	FRA_TUN_ID,
 	FRA_SUPPRESS_IFGROUP,
 	FRA_SUPPRESS_PREFIXLEN,
 	FRA_TABLE,	/* Extended table id */
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 9a12668..6da78c9 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -186,6 +186,9 @@ static int fib_rule_match(struct fib_rule *rule, struct fib_rules_ops *ops,
 	if ((rule->mark ^ fl->flowi_mark) & rule->mark_mask)
 		goto out;
 
+	if (rule->tun_id && (rule->tun_id != fl->flowi_tun_key.tun_id))
+		goto out;
+
 	ret = ops->match(rule, fl, flags);
 out:
 	return (rule->flags & FIB_RULE_INVERT) ? !ret : ret;
@@ -330,6 +333,9 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 	if (tb[FRA_FWMASK])
 		rule->mark_mask = nla_get_u32(tb[FRA_FWMASK]);
 
+	if (tb[FRA_TUN_ID])
+		rule->tun_id = nla_get_be64(tb[FRA_TUN_ID]);
+
 	rule->action = frh->action;
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
@@ -473,6 +479,10 @@ static int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr* nlh)
 		    (rule->mark_mask != nla_get_u32(tb[FRA_FWMASK])))
 			continue;
 
+		if (tb[FRA_TUN_ID] &&
+		    (rule->tun_id != nla_get_be64(tb[FRA_TUN_ID])))
+			continue;
+
 		if (!ops->compare(rule, frh, tb))
 			continue;
 
@@ -535,7 +545,8 @@ static inline size_t fib_rule_nlmsg_size(struct fib_rules_ops *ops,
 			 + nla_total_size(4) /* FRA_SUPPRESS_PREFIXLEN */
 			 + nla_total_size(4) /* FRA_SUPPRESS_IFGROUP */
 			 + nla_total_size(4) /* FRA_FWMARK */
-			 + nla_total_size(4); /* FRA_FWMASK */
+			 + nla_total_size(4) /* FRA_FWMASK */
+			 + nla_total_size(8); /* FRA_TUN_ID */
 
 	if (ops->nlmsg_payload)
 		payload += ops->nlmsg_payload(rule);
@@ -591,7 +602,9 @@ static int fib_nl_fill_rule(struct sk_buff *skb, struct fib_rule *rule,
 	    ((rule->mark_mask || rule->mark) &&
 	     nla_put_u32(skb, FRA_FWMASK, rule->mark_mask)) ||
 	    (rule->target &&
-	     nla_put_u32(skb, FRA_GOTO, rule->target)))
+	     nla_put_u32(skb, FRA_GOTO, rule->target)) ||
+	    (rule->tun_id &&
+	     nla_put_be64(skb, FRA_TUN_ID, rule->tun_id)))
 		goto nla_put_failure;
 
 	if (rule->suppress_ifgroup != -1) {
-- 
2.3.5
