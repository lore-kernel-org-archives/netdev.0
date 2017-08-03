From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/21] ipv6: fib: Dump tables during registration to FIB chain
Date: Thu,  3 Aug 2017 13:28:19 +0200
Message-ID: <20170803112831.1831-10-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35692 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752123AbdHCL2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:51 -0400
Received: by mail-wm0-f65.google.com with SMTP id r77so1830753wmd.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:51 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Dump all the FIB tables in each net namespace upon registration to the
FIB notification chain so that the callee will have a complete view of
the tables.

The integrity of the dump is ensured by a per-table sequence counter
that is incremented (under write lock) whenever a route is added or
deleted from the table.

All the sequence counters are read (under each table's read lock) and
summed, prior and after the dump. In case the counters differ, then the
dump is either restarted or the registration fails.

While it's possible for a table to be modified after its counter has
been read, this isn't really a problem. In case it happened before it
was read the second time, then the comparison at the end will fail. If
it happened afterwards, then we're guaranteed to be notified about the
change, as the notification block is registered prior to the second
read.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h    |  4 +++
 net/ipv6/fib6_notifier.c | 10 ++++--
 net/ipv6/ip6_fib.c       | 92 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 104 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index dbe5537..0b30521 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -235,6 +235,7 @@ struct fib6_table {
 	struct fib6_node	tb6_root;
 	struct inet_peer_base	tb6_peers;
 	unsigned int		flags;
+	unsigned int		fib_seq;
 #define RT6_TABLE_HAS_DFLT_ROUTER	BIT(0)
 };
 
@@ -308,6 +309,9 @@ int call_fib6_notifiers(struct net *net, enum fib_event_type event_type,
 int __net_init fib6_notifier_init(struct net *net);
 void __net_exit fib6_notifier_exit(struct net *net);
 
+unsigned int fib6_tables_seq_read(struct net *net);
+int fib6_tables_dump(struct net *net, struct notifier_block *nb);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 int fib6_rules_init(void);
 void fib6_rules_cleanup(void);
diff --git a/net/ipv6/fib6_notifier.c b/net/ipv6/fib6_notifier.c
index 298efc6..66a103e 100644
--- a/net/ipv6/fib6_notifier.c
+++ b/net/ipv6/fib6_notifier.c
@@ -23,12 +23,18 @@ int call_fib6_notifiers(struct net *net, enum fib_event_type event_type,
 
 static unsigned int fib6_seq_read(struct net *net)
 {
-	return fib6_rules_seq_read(net);
+	return fib6_tables_seq_read(net) + fib6_rules_seq_read(net);
 }
 
 static int fib6_dump(struct net *net, struct notifier_block *nb)
 {
-	return fib6_rules_dump(net, nb);
+	int err;
+
+	err = fib6_rules_dump(net, nb);
+	if (err)
+		return err;
+
+	return fib6_tables_dump(net, nb);
 }
 
 static const struct fib_notifier_ops fib6_notifier_ops_template = {
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 595a57c..719c1048 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -303,6 +303,37 @@ static void __net_init fib6_tables_init(struct net *net)
 
 #endif
 
+unsigned int fib6_tables_seq_read(struct net *net)
+{
+	unsigned int h, fib_seq = 0;
+
+	rcu_read_lock();
+	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
+		struct hlist_head *head = &net->ipv6.fib_table_hash[h];
+		struct fib6_table *tb;
+
+		hlist_for_each_entry_rcu(tb, head, tb6_hlist) {
+			read_lock_bh(&tb->tb6_lock);
+			fib_seq += tb->fib_seq;
+			read_unlock_bh(&tb->tb6_lock);
+		}
+	}
+	rcu_read_unlock();
+
+	return fib_seq;
+}
+
+static int call_fib6_entry_notifier(struct notifier_block *nb, struct net *net,
+				    enum fib_event_type event_type,
+				    struct rt6_info *rt)
+{
+	struct fib6_entry_notifier_info info = {
+		.rt = rt,
+	};
+
+	return call_fib6_notifier(nb, net, event_type, &info.info);
+}
+
 static int call_fib6_entry_notifiers(struct net *net,
 				     enum fib_event_type event_type,
 				     struct rt6_info *rt)
@@ -311,9 +342,70 @@ static int call_fib6_entry_notifiers(struct net *net,
 		.rt = rt,
 	};
 
+	rt->rt6i_table->fib_seq++;
 	return call_fib6_notifiers(net, event_type, &info.info);
 }
 
+struct fib6_dump_arg {
+	struct net *net;
+	struct notifier_block *nb;
+};
+
+static void fib6_rt_dump(struct rt6_info *rt, struct fib6_dump_arg *arg)
+{
+	if (rt == arg->net->ipv6.ip6_null_entry)
+		return;
+	call_fib6_entry_notifier(arg->nb, arg->net, FIB_EVENT_ENTRY_ADD, rt);
+}
+
+static int fib6_node_dump(struct fib6_walker *w)
+{
+	struct rt6_info *rt;
+
+	for (rt = w->leaf; rt; rt = rt->dst.rt6_next)
+		fib6_rt_dump(rt, w->args);
+	w->leaf = NULL;
+	return 0;
+}
+
+static void fib6_table_dump(struct net *net, struct fib6_table *tb,
+			    struct fib6_walker *w)
+{
+	w->root = &tb->tb6_root;
+	read_lock_bh(&tb->tb6_lock);
+	fib6_walk(net, w);
+	read_unlock_bh(&tb->tb6_lock);
+}
+
+/* Called with rcu_read_lock() */
+int fib6_tables_dump(struct net *net, struct notifier_block *nb)
+{
+	struct fib6_dump_arg arg;
+	struct fib6_walker *w;
+	unsigned int h;
+
+	w = kzalloc(sizeof(*w), GFP_ATOMIC);
+	if (!w)
+		return -ENOMEM;
+
+	w->func = fib6_node_dump;
+	arg.net = net;
+	arg.nb = nb;
+	w->args = &arg;
+
+	for (h = 0; h < FIB6_TABLE_HASHSZ; h++) {
+		struct hlist_head *head = &net->ipv6.fib_table_hash[h];
+		struct fib6_table *tb;
+
+		hlist_for_each_entry_rcu(tb, head, tb6_hlist)
+			fib6_table_dump(net, tb, w);
+	}
+
+	kfree(w);
+
+	return 0;
+}
+
 static int fib6_dump_node(struct fib6_walker *w)
 {
 	int res;
-- 
2.9.3
