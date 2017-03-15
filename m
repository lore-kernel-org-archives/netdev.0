From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/9] net: fib_rules: Check if selector matches all packets
Date: Wed, 15 Mar 2017 12:05:04 +0100
Message-ID: <1489575912-6469-2-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35228 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753843AbdCOLFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id z63so4071291wmg.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:21 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Currently, when non-default (custom) FIB rules are used, devices capable
of layer 3 offloading flush their tables and let the kernel do the
forwarding instead.

When these devices' drivers are loaded they register to the FIB
notification chain, which lets them know about the existence of any
custom FIB rules. This is done by sending a RULE_ADD notification based
on the value of 'net->ipv4.fib_has_custom_rules'.

This approach is problematic when VRF offload is taken into account, as
upon the creation of the first VRF netdev, a l3mdev rule is programmed
to direct skbs to the VRF's table.

Instead of merely reading the above value and sending a single RULE_ADD
notification, we should iterate over all the FIB rules and send a
detailed notification for each, thereby allowing offloading drivers to
sanitize the rules they don't support and potentially flush their
tables.

While l3mdev rules are uniquely marked, the default rules are not.
Therefore, when they are being notified they might invoke offloading
drivers to unnecessarily flush their tables.

Solve this by adding helpers that check whether a FIB rule's selector
matches all packets and is thus essentially a NOP. Unlike the selector,
the rule's action is completely visible to potential listeners and can
therefore be sanitized by them.

As noted by David Ahern, uniquely marking the default rules is
insufficient. When using VRFs, it's common to avoid false hits by moving
the rule for the local table to just before the main table:

Default configuration:
$ ip rule show
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

Common configuration with VRFs:
$ ip rule show
1000:   from all lookup [l3mdev-table]
32765:  from all lookup local
32766:  from all lookup main
32767:  from all lookup default

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/fib_rules.h |  1 +
 include/net/ip_fib.h    |  7 +++++++
 net/core/fib_rules.c    | 14 ++++++++++++++
 net/ipv4/fib_rules.c    | 10 ++++++++++
 4 files changed, 32 insertions(+)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 8dbfdf7..1243b9c 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -141,6 +141,7 @@ int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
 		     struct fib_lookup_arg *);
 int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
 			 u32 flags);
+bool fib_rule_matchall(const struct fib_rule *rule);
 
 int fib_nl_newrule(struct sk_buff *skb, struct nlmsghdr *nlh);
 int fib_nl_delrule(struct sk_buff *skb, struct nlmsghdr *nlh);
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index d9cee96..ec03e0f 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -311,6 +311,11 @@ static inline int fib_lookup(struct net *net, const struct flowi4 *flp,
 	return err;
 }
 
+static inline bool fib4_rule_matchall(const struct fib_rule *rule)
+{
+	return true;
+}
+
 #else /* CONFIG_IP_MULTIPLE_TABLES */
 int __net_init fib4_rules_init(struct net *net);
 void __net_exit fib4_rules_exit(struct net *net);
@@ -355,6 +360,8 @@ static inline int fib_lookup(struct net *net, struct flowi4 *flp,
 	return err;
 }
 
+bool fib4_rule_matchall(const struct fib_rule *rule);
+
 #endif /* CONFIG_IP_MULTIPLE_TABLES */
 
 /* Exported by fib_frontend.c */
diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index b6791d9..4ed475d 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -23,6 +23,20 @@ static const struct fib_kuid_range fib_kuid_range_unset = {
 	KUIDT_INIT(~0),
 };
 
+bool fib_rule_matchall(const struct fib_rule *rule)
+{
+	if (rule->iifindex || rule->oifindex || rule->mark || rule->l3mdev ||
+	    rule->tun_id || rule->flags)
+		return false;
+	if (rule->suppress_ifgroup != -1 || rule->suppress_prefixlen != -1)
+		return false;
+	if (!uid_eq(rule->uid_range.start, fib_kuid_range_unset.start) ||
+	    !uid_eq(rule->uid_range.end, fib_kuid_range_unset.end))
+		return false;
+	return true;
+}
+EXPORT_SYMBOL_GPL(fib_rule_matchall);
+
 int fib_default_rule_add(struct fib_rules_ops *ops,
 			 u32 pref, u32 table, u32 flags)
 {
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 2892109..7a941a5 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -47,6 +47,16 @@ struct fib4_rule {
 #endif
 };
 
+bool fib4_rule_matchall(const struct fib_rule *rule)
+{
+	struct fib4_rule *r = (struct fib4_rule *) rule;
+
+	if (r->dst_len || r->src_len || r->tos)
+		return false;
+	return fib_rule_matchall(rule);
+}
+EXPORT_SYMBOL_GPL(fib4_rule_matchall);
+
 int __fib_lookup(struct net *net, struct flowi4 *flp,
 		 struct fib_result *res, unsigned int flags)
 {
-- 
2.7.4
