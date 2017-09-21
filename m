From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/12] net: mroute: Check if rule is a default rule
Date: Thu, 21 Sep 2017 08:43:32 +0200
Message-ID: <20170921064338.1282-7-jiri@resnulli.us>
References: <20170921064338.1282-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35179 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751896AbdIUGnp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 02:43:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id e64so4294925wmi.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 23:43:44 -0700 (PDT)
In-Reply-To: <20170921064338.1282-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

When the ipmr starts, it adds one default FIB rule that matches all packets
and sends them to the DEFAULT (multicast) FIB table. A more complex rule
can be added by user to specify that for a specific interface, a packet
should be look up at either an arbitrary table or according to the l3mdev
of the interface.

For drivers willing to offload the ipmr logic into a hardware but don't
want to offload all the FIB rules functionality, provide a function that
can indicate whether the FIB rule is the default multicast rule, thus only
one routing table is needed.

This way, a driver can register to the FIB notification chain, get
notifications about FIB rules added and trigger some kind of an internal
abort mechanism when a non default rule is added by the user.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/mroute.h |  7 +++++++
 net/ipv4/ipmr.c        | 10 ++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 9b64587..585369d 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -5,6 +5,7 @@
 #include <linux/pim.h>
 #include <linux/rhashtable.h>
 #include <net/sock.h>
+#include <net/fib_rules.h>
 #include <net/fib_notifier.h>
 #include <uapi/linux/mroute.h>
 
@@ -19,6 +20,7 @@ int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
 int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
 int ip_mr_init(void);
+bool ipmr_rule_default(const struct fib_rule *rule);
 #else
 static inline int ip_mroute_setsockopt(struct sock *sock, int optname,
 				       char __user *optval, unsigned int optlen)
@@ -46,6 +48,11 @@ static inline int ip_mroute_opt(int opt)
 {
 	return 0;
 }
+
+static inline bool ipmr_rule_default(const struct fib_rule *rule)
+{
+	return true;
+}
 #endif
 
 struct vif_device {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 6804885..6e1de35 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -320,6 +320,16 @@ static unsigned int ipmr_rules_seq_read(struct net *net)
 }
 #endif
 
+bool ipmr_rule_default(const struct fib_rule *rule)
+{
+#if IS_ENABLED(CONFIG_FIB_RULES)
+	return fib_rule_matchall(rule) && rule->table == RT_TABLE_DEFAULT;
+#else
+	return true;
+#endif
+}
+EXPORT_SYMBOL(ipmr_rule_default);
+
 static inline int ipmr_hash_cmp(struct rhashtable_compare_arg *arg,
 				const void *ptr)
 {
-- 
2.9.5
