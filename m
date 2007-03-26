From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3] [NET] fib_rules: goto rule action
Date: Tue, 27 Mar 2007 01:54:51 +0200
Message-ID: <20070326235713.478149847@lsx.localdomain>
References: <20070326235450.756924134@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52595 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933818AbXCZX6e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:58:34 -0400
Content-Disposition: inline; filename=rules_goto
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a new rule action FR_ACT_GOTO which allows
to skip a set of rules by jumping to another rule. The rule
to jump to is specified via the FRA_GOTO attribute which
carries a rule preference.

Referring to a rule which doesn't exists is explicitely allowed.
Such goto rules are marked with the flag FIB_RULE_UNRESOLVED
and will act like a rule with a non-matching selector. The rule
will become functional as soon as its target is present.

The goto action enables performance optimizations by reducing
the average number of rules that have to be passed per lookup.

Example:
0:      from all lookup local 
40:     not from all to 192.168.23.128 goto 32766
41:     from all fwmark 0xa blackhole
42:     from all fwmark 0xff blackhole
32766:  from all lookup main 

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/linux/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/linux/fib_rules.h	2007-03-26 13:07:41.000000000 +0200
+++ net-2.6.22/include/linux/fib_rules.h	2007-03-27 01:43:14.000000000 +0200
@@ -7,6 +7,7 @@
 /* rule is permanent, and cannot be deleted */
 #define FIB_RULE_PERMANENT	1
 #define FIB_RULE_INVERT		2
+#define FIB_RULE_UNRESOLVED	4
 
 struct fib_rule_hdr
 {
@@ -29,7 +30,7 @@ enum
 	FRA_DST,	/* destination address */
 	FRA_SRC,	/* source address */
 	FRA_IFNAME,	/* interface name */
-	FRA_UNUSED1,
+	FRA_GOTO,	/* target to jump to (FR_ACT_GOTO) */
 	FRA_UNUSED2,
 	FRA_PRIORITY,	/* priority/preference */
 	FRA_UNUSED3,
@@ -51,7 +52,7 @@ enum
 {
 	FR_ACT_UNSPEC,
 	FR_ACT_TO_TBL,		/* Pass to fixed table */
-	FR_ACT_RES1,
+	FR_ACT_GOTO,		/* Jump to another rule */
 	FR_ACT_RES2,
 	FR_ACT_RES3,
 	FR_ACT_RES4,
Index: net-2.6.22/include/net/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/net/fib_rules.h	2007-03-26 13:07:41.000000000 +0200
+++ net-2.6.22/include/net/fib_rules.h	2007-03-26 13:40:32.000000000 +0200
@@ -19,6 +19,8 @@ struct fib_rule
 	u32			flags;
 	u32			table;
 	u8			action;
+	u32			target;
+	struct fib_rule *	ctarget;
 	struct rcu_head		rcu;
 };
 
@@ -35,6 +37,8 @@ struct fib_rules_ops
 	struct list_head	list;
 	int			rule_size;
 	int			addr_size;
+	int			unresolved_rules;
+	int			nr_goto_rules;
 
 	int			(*action)(struct fib_rule *,
 					  struct flowi *, int,
@@ -66,7 +70,8 @@ struct fib_rules_ops
 	[FRA_PRIORITY]	= { .type = NLA_U32 }, \
 	[FRA_FWMARK]	= { .type = NLA_U32 }, \
 	[FRA_FWMASK]	= { .type = NLA_U32 }, \
-	[FRA_TABLE]     = { .type = NLA_U32 }
+	[FRA_TABLE]     = { .type = NLA_U32 }, \
+	[FRA_GOTO]	= { .type = NLA_U32 }
 
 static inline void fib_rule_get(struct fib_rule *rule)
 {
Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-26 13:07:41.000000000 +0200
+++ net-2.6.22/net/core/fib_rules.c	2007-03-27 01:43:39.000000000 +0200
@@ -132,10 +132,23 @@ int fib_rules_lookup(struct fib_rules_op
 	rcu_read_lock();
 
 	list_for_each_entry_rcu(rule, ops->rules_list, list) {
+jumped:
 		if (!fib_rule_match(rule, ops, fl, flags))
 			continue;
 
-		err = ops->action(rule, fl, flags, arg);
+		if (rule->action == FR_ACT_GOTO) {
+			struct fib_rule *target;
+
+			target = rcu_dereference(rule->ctarget);
+			if (target == NULL) {
+				continue;
+			} else {
+				rule = target;
+				goto jumped;
+			}
+		} else
+			err = ops->action(rule, fl, flags, arg);
+
 		if (err != -EAGAIN) {
 			fib_rule_get(rule);
 			arg->rule = rule;
@@ -180,7 +193,7 @@ static int fib_nl_newrule(struct sk_buff
 	struct fib_rules_ops *ops = NULL;
 	struct fib_rule *rule, *r, *last = NULL;
 	struct nlattr *tb[FRA_MAX+1];
-	int err = -EINVAL;
+	int err = -EINVAL, unresolved = 0;
 
 	if (nlh->nlmsg_len < nlmsg_msg_size(sizeof(*frh)))
 		goto errout;
@@ -237,6 +250,28 @@ static int fib_nl_newrule(struct sk_buff
 	if (!rule->pref && ops->default_pref)
 		rule->pref = ops->default_pref();
 
+	err = -EINVAL;
+	if (tb[FRA_GOTO]) {
+		if (rule->action != FR_ACT_GOTO)
+			goto errout_free;
+
+		rule->target = nla_get_u32(tb[FRA_GOTO]);
+		/* Backward jumps are prohibited to avoid endless loops */
+		if (rule->target <= rule->pref)
+			goto errout_free;
+
+		list_for_each_entry(r, ops->rules_list, list) {
+			if (r->pref == rule->target) {
+				rule->ctarget = r;
+				break;
+			}
+		}
+
+		if (rule->ctarget == NULL)
+			unresolved = 1;
+	} else if (rule->action == FR_ACT_GOTO)
+		goto errout_free;
+
 	err = ops->configure(rule, skb, nlh, frh, tb);
 	if (err < 0)
 		goto errout_free;
@@ -249,6 +284,28 @@ static int fib_nl_newrule(struct sk_buff
 
 	fib_rule_get(rule);
 
+	if (ops->unresolved_rules) {
+		/*
+		 * There are unresolved goto rules in the list, check if
+		 * any of them are pointing to this new rule.
+		 */
+		list_for_each_entry(r, ops->rules_list, list) {
+			if (r->action == FR_ACT_GOTO &&
+			    r->target == rule->pref) {
+				BUG_ON(r->ctarget != NULL);
+				rcu_assign_pointer(r->ctarget, rule);
+				if (--ops->unresolved_rules == 0)
+					break;
+			}
+		}
+	}
+
+	if (rule->action == FR_ACT_GOTO)
+		ops->nr_goto_rules++;
+
+	if (unresolved)
+		ops->unresolved_rules++;
+
 	if (last)
 		list_add_rcu(&rule->list, &last->list);
 	else
@@ -269,7 +326,7 @@ static int fib_nl_delrule(struct sk_buff
 {
 	struct fib_rule_hdr *frh = nlmsg_data(nlh);
 	struct fib_rules_ops *ops = NULL;
-	struct fib_rule *rule;
+	struct fib_rule *rule, *tmp;
 	struct nlattr *tb[FRA_MAX+1];
 	int err = -EINVAL;
 
@@ -322,6 +379,25 @@ static int fib_nl_delrule(struct sk_buff
 		}
 
 		list_del_rcu(&rule->list);
+
+		if (rule->action == FR_ACT_GOTO)
+			ops->nr_goto_rules--;
+
+		/*
+		 * Check if this rule is a target to any of them. If so,
+		 * disable them. As this operation is eventually very
+		 * expensive, it is only performed if goto rules have
+		 * actually been added.
+		 */
+		if (ops->nr_goto_rules > 0) {
+			list_for_each_entry(tmp, ops->rules_list, list) {
+				if (tmp->ctarget == rule) {
+					rcu_assign_pointer(tmp->ctarget, NULL);
+					ops->unresolved_rules++;
+				}
+			}
+		}
+
 		synchronize_rcu();
 		notify_rule_change(RTM_DELRULE, rule, ops, nlh,
 				   NETLINK_CB(skb).pid);
@@ -371,6 +447,9 @@ static int fib_nl_fill_rule(struct sk_bu
 	frh->action = rule->action;
 	frh->flags = rule->flags;
 
+	if (rule->action == FR_ACT_GOTO && rule->ctarget == NULL)
+		frh->flags |= FIB_RULE_UNRESOLVED;
+
 	if (rule->ifname[0])
 		NLA_PUT_STRING(skb, FRA_IFNAME, rule->ifname);
 
@@ -383,6 +462,9 @@ static int fib_nl_fill_rule(struct sk_bu
 	if (rule->mark_mask || rule->mark)
 		NLA_PUT_U32(skb, FRA_FWMASK, rule->mark_mask);
 
+	if (rule->target)
+		NLA_PUT_U32(skb, FRA_GOTO, rule->target);
+
 	if (ops->fill(rule, skb, nlh, frh) < 0)
 		goto nla_put_failure;
 

--

