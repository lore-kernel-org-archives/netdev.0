From: David Miller <davem@davemloft.net>
Subject: Re: ctnetlink loop
Date: Wed, 08 Dec 2010 09:50:20 -0800 (PST)
Message-ID: <20101208.095020.245408999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	pablo@netfilter.org
To: holger@eitzenberger.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Holger, this replay -EAGAIN loop in nfnetlink processing was added by
Pablo to handle module loading properly, I think.  So it might not be
safe to just unilaterally remove it.

See:

commit e6a7d3c04f8fe49099521e6dc9a46b0272381f2f
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Oct 14 11:58:31 2008 -0700

    netfilter: ctnetlink: remove bogus module dependency between ctnetlink and nf_nat
    
    This patch removes the module dependency between ctnetlink and
    nf_nat by means of an indirect call that is initialized when
    nf_nat is loaded. Now, nf_conntrack_netlink only requires
    nf_conntrack and nfnetlink.
    
    This patch puts nfnetlink_parse_nat_setup_hook into the
    nf_conntrack_core to avoid dependencies between ctnetlink,
    nf_conntrack_ipv4 and nf_conntrack_ipv6.
    
    This patch also introduces the function ctnetlink_change_nat
    that is only invoked from the creation path. Actually, the
    nat handling cannot be invoked from the update path since
    this is not allowed. By introducing this function, we remove
    the useless nat handling in the update path and we avoid
    deadlock-prone code.
    
    This patch also adds the required EAGAIN logic for nfnetlink.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 0d8424f..7d8e045 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -78,6 +78,9 @@ extern int nfnetlink_send(struct sk_buff *skb, u32 pid, unsigned group,
 			  int echo);
 extern int nfnetlink_unicast(struct sk_buff *skb, u_int32_t pid, int flags);
 
+extern void nfnl_lock(void);
+extern void nfnl_unlock(void);
+
 #define MODULE_ALIAS_NFNL_SUBSYS(subsys) \
 	MODULE_ALIAS("nfnetlink-subsys-" __stringify(subsys))
 
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index f29eeb9..5868406 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -25,4 +25,12 @@ static inline int nf_nat_initialized(struct nf_conn *ct,
 	else
 		return test_bit(IPS_DST_NAT_DONE_BIT, &ct->status);
 }
+
+struct nlattr;
+
+extern int
+(*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
+				  enum nf_nat_manip_type manip,
+				  struct nlattr *attr);
+
 #endif /* _NF_NAT_CORE_H */
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 2ac9eaf..a65cf69 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -584,6 +584,98 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 	.flags		= NF_CT_EXT_F_PREALLOC,
 };
 
+#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+
+static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
+	[CTA_PROTONAT_PORT_MIN]	= { .type = NLA_U16 },
+	[CTA_PROTONAT_PORT_MAX]	= { .type = NLA_U16 },
+};
+
+static int nfnetlink_parse_nat_proto(struct nlattr *attr,
+				     const struct nf_conn *ct,
+				     struct nf_nat_range *range)
+{
+	struct nlattr *tb[CTA_PROTONAT_MAX+1];
+	const struct nf_nat_protocol *npt;
+	int err;
+
+	err = nla_parse_nested(tb, CTA_PROTONAT_MAX, attr, protonat_nla_policy);
+	if (err < 0)
+		return err;
+
+	npt = nf_nat_proto_find_get(nf_ct_protonum(ct));
+	if (npt->nlattr_to_range)
+		err = npt->nlattr_to_range(tb, range);
+	nf_nat_proto_put(npt);
+	return err;
+}
+
+static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
+	[CTA_NAT_MINIP]		= { .type = NLA_U32 },
+	[CTA_NAT_MAXIP]		= { .type = NLA_U32 },
+};
+
+static int
+nfnetlink_parse_nat(struct nlattr *nat,
+		    const struct nf_conn *ct, struct nf_nat_range *range)
+{
+	struct nlattr *tb[CTA_NAT_MAX+1];
+	int err;
+
+	memset(range, 0, sizeof(*range));
+
+	err = nla_parse_nested(tb, CTA_NAT_MAX, nat, nat_nla_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[CTA_NAT_MINIP])
+		range->min_ip = nla_get_be32(tb[CTA_NAT_MINIP]);
+
+	if (!tb[CTA_NAT_MAXIP])
+		range->max_ip = range->min_ip;
+	else
+		range->max_ip = nla_get_be32(tb[CTA_NAT_MAXIP]);
+
+	if (range->min_ip)
+		range->flags |= IP_NAT_RANGE_MAP_IPS;
+
+	if (!tb[CTA_NAT_PROTO])
+		return 0;
+
+	err = nfnetlink_parse_nat_proto(tb[CTA_NAT_PROTO], ct, range);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int
+nfnetlink_parse_nat_setup(struct nf_conn *ct,
+			  enum nf_nat_manip_type manip,
+			  struct nlattr *attr)
+{
+	struct nf_nat_range range;
+
+	if (nfnetlink_parse_nat(attr, ct, &range) < 0)
+		return -EINVAL;
+	if (nf_nat_initialized(ct, manip))
+		return -EEXIST;
+
+	return nf_nat_setup_info(ct, &range, manip);
+}
+#else
+static int
+nfnetlink_parse_nat_setup(struct nf_conn *ct,
+			  enum nf_nat_manip_type manip,
+			  struct nlattr *attr)
+{
+	return -EOPNOTSUPP;
+}
+#endif
+
 static int __net_init nf_nat_net_init(struct net *net)
 {
 	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size,
@@ -654,6 +746,9 @@ static int __init nf_nat_init(void)
 
 	BUG_ON(nf_nat_seq_adjust_hook != NULL);
 	rcu_assign_pointer(nf_nat_seq_adjust_hook, nf_nat_seq_adjust);
+	BUG_ON(nfnetlink_parse_nat_setup_hook != NULL);
+	rcu_assign_pointer(nfnetlink_parse_nat_setup_hook,
+			   nfnetlink_parse_nat_setup);
 	return 0;
 
  cleanup_extend:
@@ -667,10 +762,12 @@ static void __exit nf_nat_cleanup(void)
 	nf_ct_l3proto_put(l3proto);
 	nf_ct_extend_unregister(&nat_extend);
 	rcu_assign_pointer(nf_nat_seq_adjust_hook, NULL);
+	rcu_assign_pointer(nfnetlink_parse_nat_setup_hook, NULL);
 	synchronize_net();
 }
 
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("nf-nat-ipv4");
 
 module_init(nf_nat_init);
 module_exit(nf_nat_cleanup);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 27de3c7..622d7c6 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -38,9 +38,16 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
+#include <net/netfilter/nf_nat.h>
 
 #define NF_CONNTRACK_VERSION	"0.5.0"
 
+unsigned int
+(*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
+				  enum nf_nat_manip_type manip,
+				  struct nlattr *attr) __read_mostly;
+EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
+
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cadfd15..08e82d6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -689,71 +689,6 @@ ctnetlink_parse_tuple(struct nlattr *cda[], struct nf_conntrack_tuple *tuple,
 	return 0;
 }
 
-#ifdef CONFIG_NF_NAT_NEEDED
-static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
-	[CTA_PROTONAT_PORT_MIN]	= { .type = NLA_U16 },
-	[CTA_PROTONAT_PORT_MAX]	= { .type = NLA_U16 },
-};
-
-static int nfnetlink_parse_nat_proto(struct nlattr *attr,
-				     const struct nf_conn *ct,
-				     struct nf_nat_range *range)
-{
-	struct nlattr *tb[CTA_PROTONAT_MAX+1];
-	const struct nf_nat_protocol *npt;
-	int err;
-
-	err = nla_parse_nested(tb, CTA_PROTONAT_MAX, attr, protonat_nla_policy);
-	if (err < 0)
-		return err;
-
-	npt = nf_nat_proto_find_get(nf_ct_protonum(ct));
-	if (npt->nlattr_to_range)
-		err = npt->nlattr_to_range(tb, range);
-	nf_nat_proto_put(npt);
-	return err;
-}
-
-static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
-	[CTA_NAT_MINIP]		= { .type = NLA_U32 },
-	[CTA_NAT_MAXIP]		= { .type = NLA_U32 },
-};
-
-static inline int
-nfnetlink_parse_nat(struct nlattr *nat,
-		    const struct nf_conn *ct, struct nf_nat_range *range)
-{
-	struct nlattr *tb[CTA_NAT_MAX+1];
-	int err;
-
-	memset(range, 0, sizeof(*range));
-
-	err = nla_parse_nested(tb, CTA_NAT_MAX, nat, nat_nla_policy);
-	if (err < 0)
-		return err;
-
-	if (tb[CTA_NAT_MINIP])
-		range->min_ip = nla_get_be32(tb[CTA_NAT_MINIP]);
-
-	if (!tb[CTA_NAT_MAXIP])
-		range->max_ip = range->min_ip;
-	else
-		range->max_ip = nla_get_be32(tb[CTA_NAT_MAXIP]);
-
-	if (range->min_ip)
-		range->flags |= IP_NAT_RANGE_MAP_IPS;
-
-	if (!tb[CTA_NAT_PROTO])
-		return 0;
-
-	err = nfnetlink_parse_nat_proto(tb[CTA_NAT_PROTO], ct, range);
-	if (err < 0)
-		return err;
-
-	return 0;
-}
-#endif
-
 static inline int
 ctnetlink_parse_help(struct nlattr *attr, char **helper_name)
 {
@@ -879,6 +814,34 @@ out:
 }
 
 static int
+ctnetlink_parse_nat_setup(struct nf_conn *ct,
+			  enum nf_nat_manip_type manip,
+			  struct nlattr *attr)
+{
+	typeof(nfnetlink_parse_nat_setup_hook) parse_nat_setup;
+
+	parse_nat_setup = rcu_dereference(nfnetlink_parse_nat_setup_hook);
+	if (!parse_nat_setup) {
+#ifdef CONFIG_KMOD
+		rcu_read_unlock();
+		nfnl_unlock();
+		if (request_module("nf-nat-ipv4") < 0) {
+			nfnl_lock();
+			rcu_read_lock();
+			return -EOPNOTSUPP;
+		}
+		nfnl_lock();
+		rcu_read_lock();
+		if (nfnetlink_parse_nat_setup_hook)
+			return -EAGAIN;
+#endif
+		return -EOPNOTSUPP;
+	}
+
+	return parse_nat_setup(ct, manip, attr);
+}
+
+static int
 ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 {
 	unsigned long d;
@@ -897,31 +860,6 @@ ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 		/* ASSURED bit can only be set */
 		return -EBUSY;
 
-	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
-#ifndef CONFIG_NF_NAT_NEEDED
-		return -EOPNOTSUPP;
-#else
-		struct nf_nat_range range;
-
-		if (cda[CTA_NAT_DST]) {
-			if (nfnetlink_parse_nat(cda[CTA_NAT_DST], ct,
-						&range) < 0)
-				return -EINVAL;
-			if (nf_nat_initialized(ct, IP_NAT_MANIP_DST))
-				return -EEXIST;
-			nf_nat_setup_info(ct, &range, IP_NAT_MANIP_DST);
-		}
-		if (cda[CTA_NAT_SRC]) {
-			if (nfnetlink_parse_nat(cda[CTA_NAT_SRC], ct,
-						&range) < 0)
-				return -EINVAL;
-			if (nf_nat_initialized(ct, IP_NAT_MANIP_SRC))
-				return -EEXIST;
-			nf_nat_setup_info(ct, &range, IP_NAT_MANIP_SRC);
-		}
-#endif
-	}
-
 	/* Be careful here, modifying NAT bits can screw up things,
 	 * so don't let users modify them directly if they don't pass
 	 * nf_nat_range. */
@@ -929,6 +867,31 @@ ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 	return 0;
 }
 
+static int
+ctnetlink_change_nat(struct nf_conn *ct, struct nlattr *cda[])
+{
+#ifdef CONFIG_NF_NAT_NEEDED
+	int ret;
+
+	if (cda[CTA_NAT_DST]) {
+		ret = ctnetlink_parse_nat_setup(ct,
+						IP_NAT_MANIP_DST,
+						cda[CTA_NAT_DST]);
+		if (ret < 0)
+			return ret;
+	}
+	if (cda[CTA_NAT_SRC]) {
+		ret = ctnetlink_parse_nat_setup(ct,
+						IP_NAT_MANIP_SRC,
+						cda[CTA_NAT_SRC]);
+		if (ret < 0)
+			return ret;
+	}
+	return 0;
+#else
+	return -EOPNOTSUPP;
+#endif
+}
 
 static inline int
 ctnetlink_change_helper(struct nf_conn *ct, struct nlattr *cda[])
@@ -1157,6 +1120,14 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		}
 	}
 
+	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
+		err = ctnetlink_change_nat(ct, cda);
+		if (err < 0) {
+			rcu_read_unlock();
+			goto err;
+		}
+	}
+
 	if (cda[CTA_PROTOINFO]) {
 		err = ctnetlink_change_protoinfo(ct, cda);
 		if (err < 0) {
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b75c9c4..4739f9f 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -44,15 +44,17 @@ static struct sock *nfnl = NULL;
 static const struct nfnetlink_subsystem *subsys_table[NFNL_SUBSYS_COUNT];
 static DEFINE_MUTEX(nfnl_mutex);
 
-static inline void nfnl_lock(void)
+void nfnl_lock(void)
 {
 	mutex_lock(&nfnl_mutex);
 }
+EXPORT_SYMBOL_GPL(nfnl_lock);
 
-static inline void nfnl_unlock(void)
+void nfnl_unlock(void)
 {
 	mutex_unlock(&nfnl_mutex);
 }
+EXPORT_SYMBOL_GPL(nfnl_unlock);
 
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 {
@@ -132,6 +134,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return 0;
 
 	type = nlh->nlmsg_type;
+replay:
 	ss = nfnetlink_get_subsys(type);
 	if (!ss) {
 #ifdef CONFIG_KMOD
@@ -165,7 +168,10 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		} else
 			return -EINVAL;
 
-		return nc->call(nfnl, skb, nlh, cda);
+		err = nc->call(nfnl, skb, nlh, cda);
+		if (err == -EAGAIN)
+			goto replay;
+		return err;
 	}
 }
 
