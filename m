From: pablo@netfilter.org
Subject: [PATCH 7/7] netfilter: xt_CT: allow to attach timeout policy + glue code
Date: Sun,  4 Mar 2012 12:27:58 +0100
Message-ID: <1330860478-13184-8-git-send-email-pablo@netfilter.org>
References: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:49038 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753350Ab2CDL2P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2012 06:28:15 -0500
In-Reply-To: <1330860478-13184-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows you to attach the timeout policy via the
CT target, it adds a new revision of the target to ensure
backward compatibility. Moreover, it also contains the glue
code to stick the timeout object defined via nfnetlink_cttimeout
to the given flow.

Example usage (it requires installing the nfct tool and
libnetfilter_cttimeout):

1) create the timeout policy:

 nfct timeout add tcp-policy0 inet tcp \
	established 1000 close 10 time_wait 10 last_ack 10

2) attach the timeout policy to the packet:

 iptables -I PREROUTING -t raw -p tcp -j CT --timeout tcp-policy0

You have to install the following user-space software:

a) libnetfilter_cttimeout:
   git://git.netfilter.org/libnetfilter_cttimeout

b) nfct:
   git://git.netfilter.org/nfct

You also have to get iptables with -j CT --timeout support.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/xt_CT.h     |   12 ++
 net/netfilter/nf_conntrack_core.c   |   11 ++-
 net/netfilter/nfnetlink_cttimeout.c |   35 ++++++
 net/netfilter/xt_CT.c               |  220 ++++++++++++++++++++++++++++++++---
 4 files changed, 262 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter/xt_CT.h b/include/linux/netfilter/xt_CT.h
index b56e768..a064b8a 100644
--- a/include/linux/netfilter/xt_CT.h
+++ b/include/linux/netfilter/xt_CT.h
@@ -16,4 +16,16 @@ struct xt_ct_target_info {
 	struct nf_conn	*ct __attribute__((aligned(8)));
 };
 
+struct xt_ct_target_info_v1 {
+	__u16 flags;
+	__u16 zone;
+	__u32 ct_events;
+	__u32 exp_events;
+	char helper[16];
+	char timeout[32];
+
+	/* Used internally by the kernel */
+	struct nf_conn	*ct __attribute__((aligned(8)));
+};
+
 #endif /* _XT_CT_H */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 183453d..437b715 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -882,6 +882,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	enum ip_conntrack_info ctinfo;
 	struct nf_conntrack_l3proto *l3proto;
 	struct nf_conntrack_l4proto *l4proto;
+	struct nf_conn_timeout *timeout_ext;
 	unsigned int *timeouts;
 	unsigned int dataoff;
 	u_int8_t protonum;
@@ -929,7 +930,15 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			goto out;
 	}
 
-	timeouts = l4proto->get_timeouts(net);
+	/* Decide what timeout policy we want to apply to this flow. */
+	if (tmpl) {
+	        timeout_ext = nf_ct_timeout_find(tmpl);
+		if (timeout_ext)
+			timeouts = NF_CT_TIMEOUT_EXT_DATA(timeout_ext);
+		else
+			timeouts = l4proto->get_timeouts(net);
+	} else
+		timeouts = l4proto->get_timeouts(net);
 
 	ct = resolve_normal_ct(net, tmpl, skb, dataoff, pf, protonum,
 			       l3proto, l4proto, &set_reply, &ctinfo,
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index a5599be..e3596e7 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
+#include <net/netfilter/nf_conntrack_timeout.h>
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
@@ -328,6 +329,36 @@ cttimeout_del_timeout(struct sock *ctnl, struct sk_buff *skb,
 	return ret;
 }
 
+static struct ctnl_timeout *ctnl_timeout_find_get(const char *name)
+{
+	struct ctnl_timeout *timeout, *matching = NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(timeout, &cttimeout_list, head) {
+		if (strncmp(timeout->name, name, CTNL_TIMEOUT_NAME_MAX) != 0)
+			continue;
+
+		if (!try_module_get(THIS_MODULE))
+			goto err;
+
+		if (!atomic_inc_not_zero(&timeout->refcnt)) {
+			module_put(THIS_MODULE);
+			goto err;
+		}
+		matching = timeout;
+		break;
+	}
+err:
+	rcu_read_unlock();
+	return matching;
+}
+
+static void ctnl_timeout_put(struct ctnl_timeout *timeout)
+{
+	atomic_dec(&timeout->refcnt);
+	module_put(THIS_MODULE);
+}
+
 static const struct nfnl_callback cttimeout_cb[IPCTNL_MSG_TIMEOUT_MAX] = {
 	[IPCTNL_MSG_TIMEOUT_NEW]	= { .call = cttimeout_new_timeout,
 					    .attr_count = CTA_TIMEOUT_MAX,
@@ -359,6 +390,8 @@ static int __init cttimeout_init(void)
 			"nfnetlink.\n");
 		goto err_out;
 	}
+	RCU_INIT_POINTER(nf_ct_timeout_find_get_hook, ctnl_timeout_find_get);
+	RCU_INIT_POINTER(nf_ct_timeout_put_hook, ctnl_timeout_put);
 	return 0;
 
 err_out:
@@ -378,6 +411,8 @@ static void __exit cttimeout_exit(void)
 		   it's safe to release them all without checking refcnt. */
 		kfree_rcu(cur, rcu_head);
 	}
+	RCU_INIT_POINTER(nf_ct_timeout_find_get_hook, NULL);
+	RCU_INIT_POINTER(nf_ct_timeout_put_hook, NULL);
 }
 
 module_init(cttimeout_init);
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 0221d10..b873445 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -16,10 +16,11 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
+#include <net/netfilter/nf_conntrack_timeout.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
-static unsigned int xt_ct_target(struct sk_buff *skb,
-				 const struct xt_action_param *par)
+static unsigned int xt_ct_target_v0(struct sk_buff *skb,
+				    const struct xt_action_param *par)
 {
 	const struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
@@ -35,6 +36,23 @@ static unsigned int xt_ct_target(struct sk_buff *skb,
 	return XT_CONTINUE;
 }
 
+static unsigned int xt_ct_target_v1(struct sk_buff *skb,
+				    const struct xt_action_param *par)
+{
+	const struct xt_ct_target_info_v1 *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
+
+	/* Previously seen (loopback)? Ignore. */
+	if (skb->nfct != NULL)
+		return XT_CONTINUE;
+
+	atomic_inc(&ct->ct_general.use);
+	skb->nfct = &ct->ct_general;
+	skb->nfctinfo = IP_CT_NEW;
+
+	return XT_CONTINUE;
+}
+
 static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
 {
 	if (par->family == NFPROTO_IPV4) {
@@ -53,7 +71,7 @@ static u8 xt_ct_find_proto(const struct xt_tgchk_param *par)
 		return 0;
 }
 
-static int xt_ct_tg_check(const struct xt_tgchk_param *par)
+static int xt_ct_tg_check_v0(const struct xt_tgchk_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conntrack_tuple t;
@@ -130,7 +148,137 @@ err1:
 	return ret;
 }
 
-static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
+static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
+{
+	struct xt_ct_target_info_v1 *info = par->targinfo;
+	struct nf_conntrack_tuple t;
+	struct nf_conn_help *help;
+	struct nf_conn *ct;
+	int ret = 0;
+	u8 proto;
+
+	if (info->flags & ~XT_CT_NOTRACK)
+		return -EINVAL;
+
+	if (info->flags & XT_CT_NOTRACK) {
+		ct = nf_ct_untracked_get();
+		atomic_inc(&ct->ct_general.use);
+		goto out;
+	}
+
+#ifndef CONFIG_NF_CONNTRACK_ZONES
+	if (info->zone)
+		goto err1;
+#endif
+
+	ret = nf_ct_l3proto_try_module_get(par->family);
+	if (ret < 0)
+		goto err1;
+
+	memset(&t, 0, sizeof(t));
+	ct = nf_conntrack_alloc(par->net, info->zone, &t, &t, GFP_KERNEL);
+	ret = PTR_ERR(ct);
+	if (IS_ERR(ct))
+		goto err2;
+
+	ret = 0;
+	if ((info->ct_events || info->exp_events) &&
+	    !nf_ct_ecache_ext_add(ct, info->ct_events, info->exp_events,
+				  GFP_KERNEL))
+		goto err3;
+
+	if (info->helper[0]) {
+		ret = -ENOENT;
+		proto = xt_ct_find_proto(par);
+		if (!proto) {
+			pr_info("You must specify a L4 protocol, "
+				"and not use inversions on it.\n");
+			goto err3;
+		}
+
+		ret = -ENOMEM;
+		help = nf_ct_helper_ext_add(ct, GFP_KERNEL);
+		if (help == NULL)
+			goto err3;
+
+		ret = -ENOENT;
+		help->helper = nf_conntrack_helper_try_module_get(info->helper,
+								  par->family,
+								  proto);
+		if (help->helper == NULL) {
+			pr_info("No such helper \"%s\"\n", info->helper);
+			goto err3;
+		}
+	}
+
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	if (info->timeout) {
+		typeof(nf_ct_timeout_find_get_hook) timeout_find_get;
+		struct ctnl_timeout *timeout;
+		struct nf_conn_timeout *timeout_ext;
+
+		timeout_find_get =
+			rcu_dereference(nf_ct_timeout_find_get_hook);
+
+		if (timeout_find_get) {
+			const struct ipt_entry *e = par->entryinfo;
+
+			if (e->ip.invflags & IPT_INV_PROTO) {
+				ret = -EINVAL;
+				pr_info("You cannot use inversion on "
+					 "L4 protocol\n");
+				goto err3;
+			}
+			timeout = timeout_find_get(info->timeout);
+			if (timeout == NULL) {
+				ret = -ENOENT;
+				pr_info("No such timeout policy \"%s\"\n",
+					info->timeout);
+				goto err3;
+			}
+			if (timeout->l3num != par->family) {
+				ret = -EINVAL;
+				pr_info("Timeout policy `%s' can only be "
+					"used by L3 protocol number %d\n",
+					info->timeout, timeout->l3num);
+				goto err3;
+			}
+			if (timeout->l4num != e->ip.proto) {
+				ret = -EINVAL;
+				pr_info("Timeout policy `%s' can only be "
+					"used by L4 protocol number %d\n",
+					info->timeout, timeout->l4num);
+				goto err3;
+			}
+			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
+							    GFP_KERNEL);
+			if (timeout_ext == NULL) {
+				ret = -ENOMEM;
+				goto err3;
+			}
+		} else {
+			ret = -ENOENT;
+			pr_info("Timeout policy base is empty\n");
+			goto err3;
+		}
+	}
+#endif
+
+	__set_bit(IPS_TEMPLATE_BIT, &ct->status);
+	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
+out:
+	info->ct = ct;
+	return 0;
+
+err3:
+	nf_conntrack_free(ct);
+err2:
+	nf_ct_l3proto_module_put(par->family);
+err1:
+	return ret;
+}
+
+static void xt_ct_tg_destroy_v0(const struct xt_tgdtor_param *par)
 {
 	struct xt_ct_target_info *info = par->targinfo;
 	struct nf_conn *ct = info->ct;
@@ -146,25 +294,67 @@ static void xt_ct_tg_destroy(const struct xt_tgdtor_param *par)
 	nf_ct_put(info->ct);
 }
 
-static struct xt_target xt_ct_tg __read_mostly = {
-	.name		= "CT",
-	.family		= NFPROTO_UNSPEC,
-	.targetsize	= sizeof(struct xt_ct_target_info),
-	.checkentry	= xt_ct_tg_check,
-	.destroy	= xt_ct_tg_destroy,
-	.target		= xt_ct_target,
-	.table		= "raw",
-	.me		= THIS_MODULE,
+static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
+{
+	struct xt_ct_target_info_v1 *info = par->targinfo;
+	struct nf_conn *ct = info->ct;
+	struct nf_conn_help *help;
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+	struct nf_conn_timeout *timeout_ext;
+	typeof(nf_ct_timeout_put_hook) timeout_put;
+#endif
+	if (!nf_ct_is_untracked(ct)) {
+		help = nfct_help(ct);
+		if (help)
+			module_put(help->helper->me);
+
+		nf_ct_l3proto_module_put(par->family);
+
+#ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+		timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
+
+		if (timeout_put) {
+			timeout_ext = nf_ct_timeout_find(ct);
+			if (timeout_ext)
+				timeout_put(timeout_ext->timeout);
+		}
+#endif
+	}
+	nf_ct_put(info->ct);
+}
+
+static struct xt_target xt_ct_tg_reg[] __read_mostly = {
+	{
+		.name		= "CT",
+		.family		= NFPROTO_UNSPEC,
+		.targetsize	= sizeof(struct xt_ct_target_info),
+		.checkentry	= xt_ct_tg_check_v0,
+		.destroy	= xt_ct_tg_destroy_v0,
+		.target		= xt_ct_target_v0,
+		.table		= "raw",
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "CT",
+		.family		= NFPROTO_UNSPEC,
+		.revision	= 1,
+		.targetsize	= sizeof(struct xt_ct_target_info_v1),
+		.checkentry	= xt_ct_tg_check_v1,
+		.destroy	= xt_ct_tg_destroy_v1,
+		.target		= xt_ct_target_v1,
+		.table		= "raw",
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init xt_ct_tg_init(void)
 {
-	return xt_register_target(&xt_ct_tg);
+	return xt_register_targets(xt_ct_tg_reg, ARRAY_SIZE(xt_ct_tg_reg));
 }
 
 static void __exit xt_ct_tg_exit(void)
 {
-	xt_unregister_target(&xt_ct_tg);
+	xt_unregister_targets(xt_ct_tg_reg, ARRAY_SIZE(xt_ct_tg_reg));
 }
 
 module_init(xt_ct_tg_init);
-- 
1.7.7.3
