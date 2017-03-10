From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] ipv4: fib: Move FIB notification code to a separate file
Date: Fri, 10 Mar 2017 08:56:18 +0100
Message-ID: <1489132579-12664-2-git-send-email-jiri@resnulli.us>
References: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34195 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdCJH4Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:56:25 -0500
Received: by mail-wm0-f68.google.com with SMTP id u132so940189wmg.1
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:56:23 -0800 (PST)
In-Reply-To: <1489132579-12664-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Most of the code concerned with the FIB notification chain currently
resides in fib_trie.c, but this isn't really appropriate, as the FIB
notification chain is also used for FIB rules.

Therefore, it makes sense to move the common FIB notification code to a
separate file and have it export the relevant functions, which can be
invoked by its different users (e.g., fib_trie.c, fib_rules.c).

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h    | 15 ++++++++
 net/ipv4/Makefile       |  2 +-
 net/ipv4/fib_notifier.c | 86 +++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/fib_rules.c    |  9 +++++
 net/ipv4/fib_trie.c     | 97 +------------------------------------------------
 5 files changed, 113 insertions(+), 96 deletions(-)
 create mode 100644 net/ipv4/fib_notifier.c

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 368bb40..3ad8706 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -232,9 +232,24 @@ enum fib_event_type {
 int register_fib_notifier(struct notifier_block *nb,
 			  void (*cb)(struct notifier_block *nb));
 int unregister_fib_notifier(struct notifier_block *nb);
+int call_fib_notifier(struct notifier_block *nb, struct net *net,
+		      enum fib_event_type event_type,
+		      struct fib_notifier_info *info);
 int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
 		       struct fib_notifier_info *info);
 
+void fib_notify(struct net *net, struct notifier_block *nb,
+		enum fib_event_type event_type);
+#ifdef CONFIG_IP_MULTIPLE_TABLES
+void fib_rules_notify(struct net *net, struct notifier_block *nb,
+		      enum fib_event_type event_type);
+#else
+static inline void fib_rules_notify(struct net *net, struct notifier_block *nb,
+				    enum fib_event_type event_type)
+{
+}
+#endif
+
 struct fib_table {
 	struct hlist_node	tb_hlist;
 	u32			tb_id;
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index c6d4238..f83de23 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_rate.o tcp_recovery.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
-	     fib_frontend.o fib_semantics.o fib_trie.o \
+	     fib_frontend.o fib_semantics.o fib_trie.o fib_notifier.o \
 	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
diff --git a/net/ipv4/fib_notifier.c b/net/ipv4/fib_notifier.c
new file mode 100644
index 0000000..91f8f18
--- /dev/null
+++ b/net/ipv4/fib_notifier.c
@@ -0,0 +1,86 @@
+#include <linux/rtnetlink.h>
+#include <linux/notifier.h>
+#include <linux/rcupdate.h>
+#include <linux/kernel.h>
+#include <net/net_namespace.h>
+#include <net/netns/ipv4.h>
+#include <net/ip_fib.h>
+
+static ATOMIC_NOTIFIER_HEAD(fib_chain);
+
+int call_fib_notifier(struct notifier_block *nb, struct net *net,
+		      enum fib_event_type event_type,
+		      struct fib_notifier_info *info)
+{
+	info->net = net;
+	return nb->notifier_call(nb, event_type, info);
+}
+
+int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
+		       struct fib_notifier_info *info)
+{
+	net->ipv4.fib_seq++;
+	info->net = net;
+	return atomic_notifier_call_chain(&fib_chain, event_type, info);
+}
+
+static unsigned int fib_seq_sum(void)
+{
+	unsigned int fib_seq = 0;
+	struct net *net;
+
+	rtnl_lock();
+	for_each_net(net)
+		fib_seq += net->ipv4.fib_seq;
+	rtnl_unlock();
+
+	return fib_seq;
+}
+
+static bool fib_dump_is_consistent(struct notifier_block *nb,
+				   void (*cb)(struct notifier_block *nb),
+				   unsigned int fib_seq)
+{
+	atomic_notifier_chain_register(&fib_chain, nb);
+	if (fib_seq == fib_seq_sum())
+		return true;
+	atomic_notifier_chain_unregister(&fib_chain, nb);
+	if (cb)
+		cb(nb);
+	return false;
+}
+
+#define FIB_DUMP_MAX_RETRIES 5
+int register_fib_notifier(struct notifier_block *nb,
+			  void (*cb)(struct notifier_block *nb))
+{
+	int retries = 0;
+
+	do {
+		unsigned int fib_seq = fib_seq_sum();
+		struct net *net;
+
+		/* Mutex semantics guarantee that every change done to
+		 * FIB tries before we read the change sequence counter
+		 * is now visible to us.
+		 */
+		rcu_read_lock();
+		for_each_net_rcu(net) {
+			fib_rules_notify(net, nb, FIB_EVENT_RULE_ADD);
+			fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
+		}
+		rcu_read_unlock();
+
+		if (fib_dump_is_consistent(nb, cb, fib_seq))
+			return 0;
+	} while (++retries < FIB_DUMP_MAX_RETRIES);
+
+	return -EBUSY;
+}
+EXPORT_SYMBOL(register_fib_notifier);
+
+int unregister_fib_notifier(struct notifier_block *nb)
+{
+	return atomic_notifier_chain_unregister(&fib_chain, nb);
+}
+EXPORT_SYMBOL(unregister_fib_notifier);
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 2e50062..bbd57f0 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -172,6 +172,15 @@ static int call_fib_rule_notifiers(struct net *net,
 	return call_fib_notifiers(net, event_type, &info);
 }
 
+void fib_rules_notify(struct net *net, struct notifier_block *nb,
+		      enum fib_event_type event_type)
+{
+	struct fib_notifier_info info;
+
+	if (net->ipv4.fib_has_custom_rules)
+		call_fib_notifier(nb, net, event_type, &info);
+}
+
 static const struct nla_policy fib4_rule_policy[FRA_MAX+1] = {
 	FRA_GENERIC_POLICY,
 	[FRA_FLOW]	= { .type = NLA_U32 },
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2f0d823..5639e8a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -84,43 +84,6 @@
 #include <trace/events/fib.h>
 #include "fib_lookup.h"
 
-static unsigned int fib_seq_sum(void)
-{
-	unsigned int fib_seq = 0;
-	struct net *net;
-
-	rtnl_lock();
-	for_each_net(net)
-		fib_seq += net->ipv4.fib_seq;
-	rtnl_unlock();
-
-	return fib_seq;
-}
-
-static ATOMIC_NOTIFIER_HEAD(fib_chain);
-
-static int call_fib_notifier(struct notifier_block *nb, struct net *net,
-			     enum fib_event_type event_type,
-			     struct fib_notifier_info *info)
-{
-	info->net = net;
-	return nb->notifier_call(nb, event_type, info);
-}
-
-static void fib_rules_notify(struct net *net, struct notifier_block *nb,
-			     enum fib_event_type event_type)
-{
-#ifdef CONFIG_IP_MULTIPLE_TABLES
-	struct fib_notifier_info info;
-
-	if (net->ipv4.fib_has_custom_rules)
-		call_fib_notifier(nb, net, event_type, &info);
-#endif
-}
-
-static void fib_notify(struct net *net, struct notifier_block *nb,
-		       enum fib_event_type event_type);
-
 static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 				   enum fib_event_type event_type, u32 dst,
 				   int dst_len, struct fib_info *fi,
@@ -137,62 +100,6 @@ static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 	return call_fib_notifier(nb, net, event_type, &info.info);
 }
 
-static bool fib_dump_is_consistent(struct notifier_block *nb,
-				   void (*cb)(struct notifier_block *nb),
-				   unsigned int fib_seq)
-{
-	atomic_notifier_chain_register(&fib_chain, nb);
-	if (fib_seq == fib_seq_sum())
-		return true;
-	atomic_notifier_chain_unregister(&fib_chain, nb);
-	if (cb)
-		cb(nb);
-	return false;
-}
-
-#define FIB_DUMP_MAX_RETRIES 5
-int register_fib_notifier(struct notifier_block *nb,
-			  void (*cb)(struct notifier_block *nb))
-{
-	int retries = 0;
-
-	do {
-		unsigned int fib_seq = fib_seq_sum();
-		struct net *net;
-
-		/* Mutex semantics guarantee that every change done to
-		 * FIB tries before we read the change sequence counter
-		 * is now visible to us.
-		 */
-		rcu_read_lock();
-		for_each_net_rcu(net) {
-			fib_rules_notify(net, nb, FIB_EVENT_RULE_ADD);
-			fib_notify(net, nb, FIB_EVENT_ENTRY_ADD);
-		}
-		rcu_read_unlock();
-
-		if (fib_dump_is_consistent(nb, cb, fib_seq))
-			return 0;
-	} while (++retries < FIB_DUMP_MAX_RETRIES);
-
-	return -EBUSY;
-}
-EXPORT_SYMBOL(register_fib_notifier);
-
-int unregister_fib_notifier(struct notifier_block *nb)
-{
-	return atomic_notifier_chain_unregister(&fib_chain, nb);
-}
-EXPORT_SYMBOL(unregister_fib_notifier);
-
-int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
-		       struct fib_notifier_info *info)
-{
-	net->ipv4.fib_seq++;
-	info->net = net;
-	return atomic_notifier_call_chain(&fib_chain, event_type, info);
-}
-
 static int call_fib_entry_notifiers(struct net *net,
 				    enum fib_event_type event_type, u32 dst,
 				    int dst_len, struct fib_info *fi,
@@ -2036,8 +1943,8 @@ static void fib_table_notify(struct net *net, struct fib_table *tb,
 	}
 }
 
-static void fib_notify(struct net *net, struct notifier_block *nb,
-		       enum fib_event_type event_type)
+void fib_notify(struct net *net, struct notifier_block *nb,
+		enum fib_event_type event_type)
 {
 	unsigned int h;
 
-- 
2.7.4
