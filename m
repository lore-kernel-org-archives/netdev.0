From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: move fib_rules_unregister() under rtnl lock
Date: Tue, 31 Mar 2015 11:01:46 -0700
Message-ID: <1427824907-13331-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:34253 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbbCaSCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:02:53 -0400
Received: by pdbni2 with SMTP id ni2so28077194pdb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 11:02:52 -0700 (PDT)
In-Reply-To: <1427824907-13331-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to hold rtnl lock for fib_rules_unregister()
otherwise the following race could happen:

fib_rules_unregister():	fib_nl_delrule():
...				...
...				ops = lookup_rules_ops();
list_del_rcu(&ops->list);
				list_for_each_entry(ops->rules) {
fib_rules_cleanup_ops(ops);	  ...
  list_del_rcu();		  list_del_rcu();
				}

Note, net->rules_mod_lock is actually not needed at all,
either upper layer netns code or rtnl lock guarantees
we are safe.

Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/fib_rules.c    | 2 +-
 net/decnet/dn_rules.c   | 2 ++
 net/ipv4/fib_frontend.c | 3 +--
 net/ipv4/ipmr.c         | 2 +-
 net/ipv6/fib6_rules.c   | 2 ++
 net/ipv6/ip6mr.c        | 2 +-
 6 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 44706e8..e4fdc9d 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -175,9 +175,9 @@ void fib_rules_unregister(struct fib_rules_ops *ops)
 
 	spin_lock(&net->rules_mod_lock);
 	list_del_rcu(&ops->list);
-	fib_rules_cleanup_ops(ops);
 	spin_unlock(&net->rules_mod_lock);
 
+	fib_rules_cleanup_ops(ops);
 	call_rcu(&ops->rcu, fib_rules_put_rcu);
 }
 EXPORT_SYMBOL_GPL(fib_rules_unregister);
diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
index faf7cc3..9d66a0f 100644
--- a/net/decnet/dn_rules.c
+++ b/net/decnet/dn_rules.c
@@ -248,7 +248,9 @@ void __init dn_fib_rules_init(void)
 
 void __exit dn_fib_rules_cleanup(void)
 {
+	rtnl_lock();
 	fib_rules_unregister(dn_fib_rules_ops);
+	rtnl_unlock();
 	rcu_barrier();
 }
 
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 57be71d..23b9b3e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -1111,11 +1111,10 @@ static void ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
+	rtnl_lock();
 #ifdef CONFIG_IP_MULTIPLE_TABLES
 	fib4_rules_exit(net);
 #endif
-
-	rtnl_lock();
 	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
 		struct fib_table *tb;
 		struct hlist_head *head;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index bc40115..fe54eba 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -283,8 +283,8 @@ static void __net_exit ipmr_rules_exit(struct net *net)
 		list_del(&mrt->list);
 		ipmr_free_table(mrt);
 	}
-	rtnl_unlock();
 	fib_rules_unregister(net->ipv4.mr_rules_ops);
+	rtnl_unlock();
 }
 #else
 #define ipmr_for_each_table(mrt, net) \
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 27ca796..70bc6ab 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -322,7 +322,9 @@ static int __net_init fib6_rules_net_init(struct net *net)
 
 static void __net_exit fib6_rules_net_exit(struct net *net)
 {
+	rtnl_lock();
 	fib_rules_unregister(net->ipv6.fib6_rules_ops);
+	rtnl_unlock();
 }
 
 static struct pernet_operations fib6_rules_net_ops = {
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 52028f4..2f1fd9f 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -267,8 +267,8 @@ static void __net_exit ip6mr_rules_exit(struct net *net)
 		list_del(&mrt->list);
 		ip6mr_free_table(mrt);
 	}
-	rtnl_unlock();
 	fib_rules_unregister(net->ipv6.mr6_rules_ops);
+	rtnl_unlock();
 }
 #else
 #define ip6mr_for_each_table(mrt, net) \
-- 
1.8.3.1
