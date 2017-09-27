From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 06/12] net: mroute: Check if rule is a default rule
Date: Wed, 27 Sep 2017 08:23:16 +0200
Message-ID: <20170927062322.5476-7-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37623 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751521AbdI0GXa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:30 -0400
Received: by mail-wr0-f193.google.com with SMTP id u48so3581789wrf.4
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:30 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
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
v2->v3:
 - Use the already existing ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
v1->v2:
 - Update the lastuse MFC entry field too, in addition to packets an bytes.
---
 include/linux/mroute.h |  7 +++++++
 net/ipv4/ipmr.c        | 12 ++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 5566580..b072a84 100644
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
index 2a795d2..292a8e8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -274,6 +274,12 @@ static unsigned int ipmr_rules_seq_read(struct net *net)
 {
 	return fib_rules_seq_read(net, RTNL_FAMILY_IPMR);
 }
+
+bool ipmr_rule_default(const struct fib_rule *rule)
+{
+	return fib_rule_matchall(rule) && rule->table == RT_TABLE_DEFAULT;
+}
+EXPORT_SYMBOL(ipmr_rule_default);
 #else
 #define ipmr_for_each_table(mrt, net) \
 	for (mrt = net->ipv4.mrt; mrt; mrt = NULL)
@@ -318,6 +324,12 @@ static unsigned int ipmr_rules_seq_read(struct net *net)
 {
 	return 0;
 }
+
+bool ipmr_rule_default(const struct fib_rule *rule)
+{
+	return true;
+}
+EXPORT_SYMBOL(ipmr_rule_default);
 #endif
 
 static inline int ipmr_hash_cmp(struct rhashtable_compare_arg *arg,
-- 
2.9.5
