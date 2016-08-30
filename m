From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 01/12] net: flow: Add l3mdev flow update
Date: Tue, 30 Aug 2016 10:34:06 -0700
Message-ID: <1472578457-26722-2-git-send-email-dsa@cumulusnetworks.com>
References: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35677 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758751AbcH3Re0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 13:34:26 -0400
Received: by mail-pa0-f45.google.com with SMTP id hb8so9518076pac.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 10:34:26 -0700 (PDT)
In-Reply-To: <1472578457-26722-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add l3mdev hook to set FLOWI_FLAG_SKIP_NH_OIF flag and update oif/iif
in flow struct if its oif or iif points to a device enslaved to an L3
Master device. Only 1 needs to be converted to match the l3mdev FIB
rule. This moves the flow adjustment for l3mdev to a single point
catching all lookups. It is redundant for existing hooks (those are
removed in later patches) but is needed for missed lookups such as
PMTU updates.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h  |  6 ++++++
 net/ipv4/fib_rules.c  |  3 +++
 net/ipv6/fib6_rules.c |  3 +++
 net/l3mdev/l3mdev.c   | 35 +++++++++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index e90095091aa0..81e175e80537 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -49,6 +49,8 @@ struct l3mdev_ops {
 int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
 			  struct fib_lookup_arg *arg);
 
+void l3mdev_update_flow(struct net *net, struct flowi *fl);
+
 int l3mdev_master_ifindex_rcu(const struct net_device *dev);
 static inline int l3mdev_master_ifindex(struct net_device *dev)
 {
@@ -290,6 +292,10 @@ int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
 {
 	return 1;
 }
+static inline
+void l3mdev_update_flow(struct net *net, struct flowi *fl)
+{
+}
 #endif
 
 #endif /* _NET_L3MDEV_H_ */
diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
index 6e9ea69e5f75..770bebed6b28 100644
--- a/net/ipv4/fib_rules.c
+++ b/net/ipv4/fib_rules.c
@@ -56,6 +56,9 @@ int __fib_lookup(struct net *net, struct flowi4 *flp,
 	};
 	int err;
 
+	/* update flow if oif or iif point to device enslaved to l3mdev */
+	l3mdev_update_flow(net, flowi4_to_flowi(flp));
+
 	err = fib_rules_lookup(net->ipv4.rules_ops, flowi4_to_flowi(flp), 0, &arg);
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	if (arg.rule)
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 5857c1fc8b67..eea23b57c6a5 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -38,6 +38,9 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi6 *fl6,
 		.flags = FIB_LOOKUP_NOREF,
 	};
 
+	/* update flow if oif or iif point to device enslaved to l3mdev */
+	l3mdev_update_flow(net, flowi6_to_flowi(fl6));
+
 	fib_rules_lookup(net->ipv6.fib6_rules_ops,
 			 flowi6_to_flowi(fl6), flags, &arg);
 
diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index c4a1c3e84e12..43610e5acc4e 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -222,3 +222,38 @@ int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
 
 	return rc;
 }
+
+void l3mdev_update_flow(struct net *net, struct flowi *fl)
+{
+	struct net_device *dev;
+	int ifindex;
+
+	rcu_read_lock();
+
+	if (fl->flowi_oif) {
+		dev = dev_get_by_index_rcu(net, fl->flowi_oif);
+		if (dev) {
+			ifindex = l3mdev_master_ifindex_rcu(dev);
+			if (ifindex) {
+				fl->flowi_oif = ifindex;
+				fl->flowi_flags |= FLOWI_FLAG_SKIP_NH_OIF;
+				goto out;
+			}
+		}
+	}
+
+	if (fl->flowi_iif) {
+		dev = dev_get_by_index_rcu(net, fl->flowi_iif);
+		if (dev) {
+			ifindex = l3mdev_master_ifindex_rcu(dev);
+			if (ifindex) {
+				fl->flowi_iif = ifindex;
+				fl->flowi_flags |= FLOWI_FLAG_SKIP_NH_OIF;
+			}
+		}
+	}
+
+out:
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(l3mdev_update_flow);
-- 
2.1.4
