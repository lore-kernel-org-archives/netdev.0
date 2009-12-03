From: Patrick McHardy <kaber@trash.net>
Subject: net 04/05: fib_rules: allow to delete local rule
Date: Thu,  3 Dec 2009 12:25:57 +0100 (MET)
Message-ID: <20091203112555.15100.29139.sendpatchset@x2.localnet>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60323 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923AbZLCLZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 06:25:51 -0500
In-Reply-To: <20091203112550.15100.86217.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d124356ce314fff22a047ea334379d5105b2d834
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Dec 3 12:16:35 2009 +0100

    net: fib_rules: allow to delete local rule
    
    Allow to delete the local rule and recreate it with a higher priority. This
    can be used to force packets with a local destination out on the wire instead
    of routing them to loopback. Additionally this patch allows to recreate rules
    with a priority of 0.
    
    Combined with the previous patch to allow oif classification, a socket can
    be bound to the desired interface and packets routed to the wire like this:
    
    # move local rule to lower priority
    ip rule add pref 1000 lookup local
    ip rule del pref 0
    
    # route packets of sockets bound to eth0 to the wire independant
    # of the destination address
    ip rule add pref 100 oif eth0 lookup 100
    ip route add default dev eth0 table 100
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index d1a70ad..ef0e7d9 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -287,7 +287,7 @@ static int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	rule->flags = frh->flags;
 	rule->table = frh_get_table(frh, tb);
 
-	if (!rule->pref && ops->default_pref)
+	if (!tb[FRA_PRIORITY] && ops->default_pref)
 		rule->pref = ops->default_pref(ops);
 
 	err = -EINVAL;
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 835262c..1239ed2 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -284,7 +284,7 @@ static int fib_default_rules_init(struct fib_rules_ops *ops)
 {
 	int err;
 
-	err = fib_default_rule_add(ops, 0, RT_TABLE_LOCAL, FIB_RULE_PERMANENT);
+	err = fib_default_rule_add(ops, 0, RT_TABLE_LOCAL, 0);
 	if (err < 0)
 		return err;
 	err = fib_default_rule_add(ops, 0x7FFE, RT_TABLE_MAIN, 0);
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 00a7a5e..3b38f49 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -276,7 +276,7 @@ static int fib6_rules_net_init(struct net *net)
 	INIT_LIST_HEAD(&net->ipv6.fib6_rules_ops->rules_list);
 
 	err = fib_default_rule_add(net->ipv6.fib6_rules_ops, 0,
-				   RT6_TABLE_LOCAL, FIB_RULE_PERMANENT);
+				   RT6_TABLE_LOCAL, 0);
 	if (err)
 		goto out_fib6_rules_ops;
 
