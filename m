From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/21] ipv6: fib_rules: Dump rules during registration to FIB chain
Date: Thu,  3 Aug 2017 13:28:18 +0200
Message-ID: <20170803112831.1831-9-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33188 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbdHCL2t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:49 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so804100wrd.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:49 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow users of the FIB notification chain to receive a complete view of
the IPv6 FIB rules upon registration to the chain.

The integrity of the dump is ensured by a per-family sequence counter
that is incremented (under RTNL) whenever a rule is added or deleted.

All the sequence counters are read (under RTNL) and summed, prior and
after the dump. In case the counters differ, then the dump is either
restarted or the registration fails.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h    | 10 ++++++++++
 net/ipv6/fib6_notifier.c |  4 ++--
 net/ipv6/fib6_rules.c    | 11 +++++++++++
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index e2b292b..dbe5537 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -312,6 +312,8 @@ void __net_exit fib6_notifier_exit(struct net *net);
 int fib6_rules_init(void);
 void fib6_rules_cleanup(void);
 bool fib6_rule_default(const struct fib_rule *rule);
+int fib6_rules_dump(struct net *net, struct notifier_block *nb);
+unsigned int fib6_rules_seq_read(struct net *net);
 #else
 static inline int               fib6_rules_init(void)
 {
@@ -325,5 +327,13 @@ static inline bool fib6_rule_default(const struct fib_rule *rule)
 {
 	return true;
 }
+static inline int fib6_rules_dump(struct net *net, struct notifier_block *nb)
+{
+	return 0;
+}
+static inline unsigned int fib6_rules_seq_read(struct net *net)
+{
+	return 0;
+}
 #endif
 #endif
diff --git a/net/ipv6/fib6_notifier.c b/net/ipv6/fib6_notifier.c
index c2bb1ab..298efc6 100644
--- a/net/ipv6/fib6_notifier.c
+++ b/net/ipv6/fib6_notifier.c
@@ -23,12 +23,12 @@ int call_fib6_notifiers(struct net *net, enum fib_event_type event_type,
 
 static unsigned int fib6_seq_read(struct net *net)
 {
-	return 0;
+	return fib6_rules_seq_read(net);
 }
 
 static int fib6_dump(struct net *net, struct notifier_block *nb)
 {
-	return 0;
+	return fib6_rules_dump(net, nb);
 }
 
 static const struct fib_notifier_ops fib6_notifier_ops_template = {
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index ef1fcee..2f29e4e 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/netdevice.h>
+#include <linux/notifier.h>
 #include <linux/export.h>
 
 #include <net/fib_rules.h>
@@ -49,6 +50,16 @@ bool fib6_rule_default(const struct fib_rule *rule)
 }
 EXPORT_SYMBOL_GPL(fib6_rule_default);
 
+int fib6_rules_dump(struct net *net, struct notifier_block *nb)
+{
+	return fib_rules_dump(net, nb, AF_INET6);
+}
+
+unsigned int fib6_rules_seq_read(struct net *net)
+{
+	return fib_rules_seq_read(net, AF_INET6);
+}
+
 struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 				   int flags, pol_lookup_t lookup)
 {
-- 
2.9.3
