From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 01/16] ipv6: introduce a new function fib6_update_sernum()
Date: Fri,  6 Oct 2017 12:05:56 -0700
Message-ID: <20171006190611.110633-2-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:44955 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdJFTGg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:36 -0400
Received: by mail-pf0-f173.google.com with SMTP id 74so2668833pfu.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:36 -0700 (PDT)
In-Reply-To: <20171006190611.110633-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This function takes a route as input and tries to update the sernum in
the fib6_node this route is associated with. It will be used in later
commit when adding a cached route into the exception table under that
route.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip6_fib.h |  2 ++
 net/ipv6/ip6_fib.c    | 14 ++++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index d060d711a624..152b7b14a5a5 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -358,6 +358,8 @@ void __net_exit fib6_notifier_exit(struct net *net);
 unsigned int fib6_tables_seq_read(struct net *net);
 int fib6_tables_dump(struct net *net, struct notifier_block *nb);
 
+void fib6_update_sernum(struct rt6_info *rt);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 int fib6_rules_init(void);
 void fib6_rules_cleanup(void);
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index e5308d7cbd75..0ba4fbb2f855 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -110,6 +110,20 @@ enum {
 	FIB6_NO_SERNUM_CHANGE = 0,
 };
 
+void fib6_update_sernum(struct rt6_info *rt)
+{
+	struct fib6_table *table = rt->rt6i_table;
+	struct net *net = dev_net(rt->dst.dev);
+	struct fib6_node *fn;
+
+	write_lock_bh(&table->tb6_lock);
+	fn = rcu_dereference_protected(rt->rt6i_node,
+			lockdep_is_held(&table->tb6_lock));
+	if (fn)
+		fn->fn_sernum = fib6_new_sernum(net);
+	write_unlock_bh(&table->tb6_lock);
+}
+
 /*
  *	Auxiliary address test functions for the radix tree.
  *
-- 
2.14.2.920.gcf0c67979c-goog
