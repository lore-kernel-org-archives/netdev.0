From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net] fib_rules: fix fib rule dumps across multiple skbs
Date: Tue, 22 Sep 2015 21:40:22 -0700
Message-ID: <1442983222-42750-1-git-send-email-roopa@cumulusnetworks.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org, wkok@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36338 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbbIWEk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 00:40:27 -0400
Received: by pacbt3 with SMTP id bt3so10748433pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 21:40:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

dump_rules returns skb length and not error.
But when family == AF_UNSPEC, the caller of dump_rules
assumes that it returns an error. Hence, when family == AF_UNSPEC,
we continue trying to dump on -EMSGSIZE errors resulting in
incorrect dump idx carried between skbs belonging to the same dump.
This results in fib rule dump always only dumping rules that fit
into the first skb.

This patch fixes dump_rules to return error so that we exit correctly
and idx is correctly maintained between skbs that are part of the
same dump.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/core/fib_rules.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index bf77e36..365de66 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -631,15 +631,17 @@ static int dump_rules(struct sk_buff *skb, struct netlink_callback *cb,
 {
 	int idx = 0;
 	struct fib_rule *rule;
+	int err = 0;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(rule, &ops->rules_list, list) {
 		if (idx < cb->args[1])
 			goto skip;
 
-		if (fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
-				     cb->nlh->nlmsg_seq, RTM_NEWRULE,
-				     NLM_F_MULTI, ops) < 0)
+		err = fib_nl_fill_rule(skb, rule, NETLINK_CB(cb->skb).portid,
+				       cb->nlh->nlmsg_seq, RTM_NEWRULE,
+				       NLM_F_MULTI, ops);
+		if (err)
 			break;
 skip:
 		idx++;
@@ -648,7 +650,7 @@ skip:
 	cb->args[1] = idx;
 	rules_ops_put(ops);
 
-	return skb->len;
+	return err;
 }
 
 static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
@@ -664,7 +666,9 @@ static int fib_nl_dumprule(struct sk_buff *skb, struct netlink_callback *cb)
 		if (ops == NULL)
 			return -EAFNOSUPPORT;
 
-		return dump_rules(skb, cb, ops);
+		dump_rules(skb, cb, ops);
+
+		return skb->len;
 	}
 
 	rcu_read_lock();
-- 
1.9.1
