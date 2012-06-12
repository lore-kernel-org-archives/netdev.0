From: pablo@netfilter.org
Subject: [PATCH 7/7] netfilter: add user-space connection tracking helper infrastructure
Date: Tue, 12 Jun 2012 20:06:20 +0200
Message-ID: <1339524380-2707-8-git-send-email-pablo@netfilter.org>
References: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53658 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001Ab2FLSHR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 14:07:17 -0400
In-Reply-To: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

There are good reasons to supports helpers in user-space instead:

* Rapid connection tracking helper development, as developing code
  in user-space is usually faster.

* Reliability: A buggy helper does not crash the kernel. Moreover,
  we can monitor the helper process and restart it in case of problems.

* Security: Avoid complex string matching and mangling in kernel-space
  running in privileged mode. Going further, we can even think about
  running user-space helpers as a non-root process.

* Extensibility: It allows the development of very specific helpers (most
  likely non-standard proprietary protocols) that are very likely not to be
  accepted for mainline inclusion in the form of kernel-space connection
  tracking helpers.

This patch adds the infrastructure to allow the implementation of
user-space conntrack helpers by means of the new nfnetlink subsystem
`nfnetlink_cthelper' and the existing queueing infrastructure
(nfnetlink_queue).

I had to add the new hook NF_IP6_PRI_CONNTRACK_HELPER to register
ipv[4|6]_helper which results from splitting ipv[4|6]_confirm into
two pieces. This change is required not to break NAT sequence
adjustment and conntrack confirmation for traffic that is enqueued
to our user-space conntrack helpers.

Basic operation, in a few steps:

1) Register user-space helper by means of `nfct':

 nfct helper add ftp inet

 [ It must be a valid existing helper supported by conntrack-tools.

2) Add rules to enable the FTP user-space helper which is
   used to track traffic going to TCP port 21.

For locally generated packets:

 iptables -I OUTPUT -t raw -p tcp --dport 21 -j CT --helper ftp

For non-locally generated packets:

 iptables -I PREROUTING -t raw -p tcp --dport 21 -j CT --helper ftp

3) Run the test conntrackd in helper mode (see example files under
   doc/helper/conntrackd.conf

 conntrackd

4) Generate FTP traffic going, if everything is OK, then conntrackd
   should create expectations (you can check that with `conntrack':

 conntrack -E expect

    [NEW] 301 proto=6 src=192.168.1.136 dst=130.89.148.12 sport=0 dport=54037 mask-src=255.255.255.255 mask-dst=255.255.255.255 sport=0 dport=65535 master-src=192.168.1.136 master-dst=130.89.148.12 sport=57127 dport=21 class=0 helper=ftp
[DESTROY] 301 proto=6 src=192.168.1.136 dst=130.89.148.12 sport=0 dport=54037 mask-src=255.255.255.255 mask-dst=255.255.255.255 sport=0 dport=65535 master-src=192.168.1.136 master-dst=130.89.148.12 sport=57127 dport=21 class=0 helper=ftp

This confirms that our test helper is receiving packets including the
conntrack information, and adding expectations in kernel-space.

The user-space helper can also store its private tracking information
in the conntrack structure in the kernel via the CTA_HELP_INFO. The
kernel will consider this a binary blob whose layout is unknown. This
information will be included in the information that is transfered
to user-space via glue code that integrates nfnetlink_queue and
ctnetlink.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/Kbuild                 |    1 +
 include/linux/netfilter/nfnetlink.h            |    3 +-
 include/linux/netfilter/nfnetlink_cthelper.h   |   55 ++
 include/linux/netfilter_ipv4.h                 |    1 +
 include/linux/netfilter_ipv6.h                 |    1 +
 include/net/netfilter/nf_conntrack_helper.h    |   11 +
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   49 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   49 +-
 net/netfilter/Kconfig                          |    8 +
 net/netfilter/Makefile                         |    1 +
 net/netfilter/nf_conntrack_helper.c            |   21 +-
 net/netfilter/nfnetlink_cthelper.c             |  674 ++++++++++++++++++++++++
 12 files changed, 848 insertions(+), 26 deletions(-)
 create mode 100644 include/linux/netfilter/nfnetlink_cthelper.h
 create mode 100644 net/netfilter/nfnetlink_cthelper.c

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 1697036..874ae8f 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -10,6 +10,7 @@ header-y += nfnetlink.h
 header-y += nfnetlink_acct.h
 header-y += nfnetlink_compat.h
 header-y += nfnetlink_conntrack.h
+header-y += nfnetlink_cthelper.h
 header-y += nfnetlink_cttimeout.h
 header-y += nfnetlink_log.h
 header-y += nfnetlink_queue.h
diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index a1048c1..18341cd 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -50,7 +50,8 @@ struct nfgenmsg {
 #define NFNL_SUBSYS_IPSET		6
 #define NFNL_SUBSYS_ACCT		7
 #define NFNL_SUBSYS_CTNETLINK_TIMEOUT	8
-#define NFNL_SUBSYS_COUNT		9
+#define NFNL_SUBSYS_CTHELPER		9
+#define NFNL_SUBSYS_COUNT		10
 
 #ifdef __KERNEL__
 
diff --git a/include/linux/netfilter/nfnetlink_cthelper.h b/include/linux/netfilter/nfnetlink_cthelper.h
new file mode 100644
index 0000000..33659f6
--- /dev/null
+++ b/include/linux/netfilter/nfnetlink_cthelper.h
@@ -0,0 +1,55 @@
+#ifndef _NFNL_CTHELPER_H_
+#define _NFNL_CTHELPER_H_
+
+#define NFCT_HELPER_STATUS_DISABLED	0
+#define NFCT_HELPER_STATUS_ENABLED	1
+
+enum nfnl_acct_msg_types {
+	NFNL_MSG_CTHELPER_NEW,
+	NFNL_MSG_CTHELPER_GET,
+	NFNL_MSG_CTHELPER_DEL,
+	NFNL_MSG_CTHELPER_MAX
+};
+
+enum nfnl_cthelper_type {
+	NFCTH_UNSPEC,
+	NFCTH_NAME,
+	NFCTH_TUPLE,
+	NFCTH_QUEUE_NUM,
+	NFCTH_POLICY,
+	NFCTH_PRIV_DATA_LEN,
+	NFCTH_STATUS,
+	__NFCTH_MAX
+};
+#define NFCTH_MAX (__NFCTH_MAX - 1)
+
+enum nfnl_cthelper_policy_type {
+	NFCTH_POLICY_SET_UNSPEC,
+	NFCTH_POLICY_SET_NUM,
+	NFCTH_POLICY_SET,
+	NFCTH_POLICY_SET1	= NFCTH_POLICY_SET,
+	NFCTH_POLICY_SET2,
+	NFCTH_POLICY_SET3,
+	NFCTH_POLICY_SET4,
+	__NFCTH_POLICY_SET_MAX
+};
+#define NFCTH_POLICY_SET_MAX (__NFCTH_POLICY_SET_MAX - 1)
+
+enum nfnl_cthelper_pol_type {
+	NFCTH_POLICY_UNSPEC,
+	NFCTH_POLICY_NAME,
+	NFCTH_POLICY_EXPECT_MAX,
+	NFCTH_POLICY_EXPECT_TIMEOUT,
+	__NFCTH_POLICY_MAX
+};
+#define NFCTH_POLICY_MAX (__NFCTH_POLICY_MAX - 1)
+
+enum nfnl_cthelper_tuple_type {
+	NFCTH_TUPLE_UNSPEC,
+	NFCTH_TUPLE_L3PROTONUM,
+	NFCTH_TUPLE_L4PROTONUM,
+	__NFCTH_TUPLE_MAX,
+};
+#define NFCTH_TUPLE_MAX (__NFCTH_TUPLE_MAX - 1)
+
+#endif /* _NFNL_CTHELPER_H */
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index fa0946c..e2b1280 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -66,6 +66,7 @@ enum nf_ip_hook_priorities {
 	NF_IP_PRI_SECURITY = 50,
 	NF_IP_PRI_NAT_SRC = 100,
 	NF_IP_PRI_SELINUX_LAST = 225,
+	NF_IP_PRI_CONNTRACK_HELPER = 300,
 	NF_IP_PRI_CONNTRACK_CONFIRM = INT_MAX,
 	NF_IP_PRI_LAST = INT_MAX,
 };
diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 57c0251..7c8a513 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -71,6 +71,7 @@ enum nf_ip6_hook_priorities {
 	NF_IP6_PRI_SECURITY = 50,
 	NF_IP6_PRI_NAT_SRC = 100,
 	NF_IP6_PRI_SELINUX_LAST = 225,
+	NF_IP6_PRI_CONNTRACK_HELPER = 300,
 	NF_IP6_PRI_LAST = INT_MAX,
 };
 
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 84b24c3..9aad956 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -15,6 +15,11 @@
 
 struct module;
 
+enum nf_ct_helper_flags {
+	NF_CT_HELPER_F_USERSPACE	= (1 << 0),
+	NF_CT_HELPER_F_CONFIGURED	= (1 << 1),
+};
+
 #define NF_CT_HELPER_NAME_LEN	16
 
 struct nf_conntrack_helper {
@@ -42,6 +47,9 @@ struct nf_conntrack_helper {
 	int (*from_nlattr)(struct nlattr *attr, struct nf_conn *ct);
 	int (*to_nlattr)(struct sk_buff *skb, const struct nf_conn *ct);
 	unsigned int expect_class_max;
+
+	unsigned int flags;
+	unsigned int queue_num;		/* For user-space helpers. */
 };
 
 extern struct nf_conntrack_helper *
@@ -96,4 +104,7 @@ nf_ct_helper_expectfn_find_by_name(const char *name);
 struct nf_ct_helper_expectfn *
 nf_ct_helper_expectfn_find_by_symbol(const void *symbol);
 
+extern struct hlist_head *nf_ct_helper_hash;
+extern unsigned int nf_ct_helper_hsize;
+
 #endif /*_NF_CONNTRACK_HELPER_H*/
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index d79b961..8227edc 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -95,11 +95,11 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	return NF_ACCEPT;
 }
 
-static unsigned int ipv4_confirm(unsigned int hooknum,
-				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+static unsigned int ipv4_helper(unsigned int hooknum,
+				struct sk_buff *skb,
+				const struct net_device *in,
+				const struct net_device *out,
+				int (*okfn)(struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -110,24 +110,38 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 	/* This is where we call the helper: as the packet goes out. */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
-		goto out;
+		return NF_ACCEPT;
 
 	help = nfct_help(ct);
 	if (!help)
-		goto out;
+		return NF_ACCEPT;
 
 	/* rcu_read_lock()ed by nf_hook_slow */
 	helper = rcu_dereference(help->helper);
 	if (!helper)
-		goto out;
+		return NF_ACCEPT;
 
 	ret = helper->help(skb, skb_network_offset(skb) + ip_hdrlen(skb),
 			   ct, ctinfo);
-	if (ret != NF_ACCEPT) {
+	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
 		nf_log_packet(NFPROTO_IPV4, hooknum, skb, in, out, NULL,
 			      "nf_ct_%s: dropping packet", helper->name);
-		return ret;
 	}
+	return ret;
+}
+
+static unsigned int ipv4_confirm(unsigned int hooknum,
+				 struct sk_buff *skb,
+				 const struct net_device *in,
+				 const struct net_device *out,
+				 int (*okfn)(struct sk_buff *))
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
+		return NF_ACCEPT;
 
 	/* adjust seqs for loopback traffic only in outgoing direction */
 	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status) &&
@@ -140,7 +154,6 @@ static unsigned int ipv4_confirm(unsigned int hooknum,
 			return NF_DROP;
 		}
 	}
-out:
 	/* We've seen it coming out the other side: confirm it */
 	return nf_conntrack_confirm(skb);
 }
@@ -185,6 +198,13 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
+		.hook		= ipv4_helper,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV4,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
+	},
+	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
@@ -192,6 +212,13 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
 	{
+		.hook		= ipv4_helper,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV4,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP_PRI_CONNTRACK_HELPER,
+	},
+	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index fca10da..b656d06 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -143,11 +143,11 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	return NF_ACCEPT;
 }
 
-static unsigned int ipv6_confirm(unsigned int hooknum,
-				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+static unsigned int ipv6_helper(unsigned int hooknum,
+				struct sk_buff *skb,
+				const struct net_device *in,
+				const struct net_device *out,
+				int (*okfn)(struct sk_buff *))
 {
 	struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -161,15 +161,15 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	/* This is where we call the helper: as the packet goes out. */
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
-		goto out;
+		return NF_ACCEPT;
 
 	help = nfct_help(ct);
 	if (!help)
-		goto out;
+		return NF_ACCEPT;
 	/* rcu_read_lock()ed by nf_hook_slow */
 	helper = rcu_dereference(help->helper);
 	if (!helper)
-		goto out;
+		return NF_ACCEPT;
 
 	protoff = nf_ct_ipv6_skip_exthdr(skb, extoff, &pnum,
 					 skb->len - extoff);
@@ -179,12 +179,27 @@ static unsigned int ipv6_confirm(unsigned int hooknum,
 	}
 
 	ret = helper->help(skb, protoff, ct, ctinfo);
-	if (ret != NF_ACCEPT) {
+	if (ret != NF_ACCEPT && (ret & NF_VERDICT_MASK) != NF_QUEUE) {
 		nf_log_packet(NFPROTO_IPV6, hooknum, skb, in, out, NULL,
 			      "nf_ct_%s: dropping packet", helper->name);
 		return ret;
 	}
-out:
+	return ret;
+}
+
+static unsigned int ipv6_confirm(unsigned int hooknum,
+				 struct sk_buff *skb,
+				 const struct net_device *in,
+				 const struct net_device *out,
+				 int (*okfn)(struct sk_buff *))
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || ctinfo == IP_CT_RELATED_REPLY)
+		return NF_ACCEPT;
+
 	/* We've seen it coming out the other side: confirm it */
 	return nf_conntrack_confirm(skb);
 }
@@ -254,6 +269,13 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
+		.hook		= ipv6_helper,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_POST_ROUTING,
+		.priority	= NF_IP6_PRI_CONNTRACK_HELPER,
+	},
+	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
@@ -261,6 +283,13 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 		.priority	= NF_IP6_PRI_LAST,
 	},
 	{
+		.hook		= ipv6_helper,
+		.owner		= THIS_MODULE,
+		.pf		= NFPROTO_IPV6,
+		.hooknum	= NF_INET_LOCAL_IN,
+		.priority	= NF_IP6_PRI_CONNTRACK_HELPER,
+	},
+	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 209c1ed..aae6c62 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -12,6 +12,14 @@ tristate "Netfilter NFACCT over NFNETLINK interface"
 	  If this option is enabled, the kernel will include support
 	  for extended accounting via NFNETLINK.
 
+config NETFILTER_NETLINK_CTHELPER
+tristate "Netfilter CTHELPER over NFNETLINK interface"
+	depends on NETFILTER_ADVANCED
+	select NETFILTER_NETLINK
+	help
+	  If this option is enabled, the kernel will include support
+	  for user-space connection tracking helpers via NFNETLINK.
+
 config NETFILTER_NETLINK_QUEUE
 	tristate "Netfilter NFQUEUE over NFNETLINK interface"
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 4e7960c..2f3bc0f 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_NETFILTER) = netfilter.o
 
 obj-$(CONFIG_NETFILTER_NETLINK) += nfnetlink.o
 obj-$(CONFIG_NETFILTER_NETLINK_ACCT) += nfnetlink_acct.o
+obj-$(CONFIG_NETFILTER_NETLINK_CTHELPER) += nfnetlink_cthelper.o
 obj-$(CONFIG_NETFILTER_NETLINK_QUEUE) += nfnetlink_queue.o
 obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 9c18ecb..2918ec2 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -30,8 +30,10 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 
 static DEFINE_MUTEX(nf_ct_helper_mutex);
-static struct hlist_head *nf_ct_helper_hash __read_mostly;
-static unsigned int nf_ct_helper_hsize __read_mostly;
+struct hlist_head *nf_ct_helper_hash __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ct_helper_hash);
+unsigned int nf_ct_helper_hsize __read_mostly;
+EXPORT_SYMBOL_GPL(nf_ct_helper_hsize);
 static unsigned int nf_ct_helper_count __read_mostly;
 
 static bool nf_ct_auto_assign_helper __read_mostly = true;
@@ -322,6 +324,9 @@ EXPORT_SYMBOL_GPL(nf_ct_helper_expectfn_find_by_symbol);
 
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
+	int ret = 0;
+	struct nf_conntrack_helper *cur;
+	struct hlist_node *n;
 	unsigned int h = helper_hash(&me->tuple);
 
 	BUG_ON(me->expect_policy == NULL);
@@ -329,11 +334,19 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 	BUG_ON(strlen(me->name) > NF_CT_HELPER_NAME_LEN - 1);
 
 	mutex_lock(&nf_ct_helper_mutex);
+	hlist_for_each_entry(cur, n, &nf_ct_helper_hash[h], hnode) {
+		if (strncmp(cur->name, me->name, NF_CT_HELPER_NAME_LEN) == 0 &&
+		    cur->tuple.src.l3num == me->tuple.src.l3num &&
+		    cur->tuple.dst.protonum == me->tuple.dst.protonum) {
+			ret = -EEXIST;
+			goto out;
+		}
+	}
 	hlist_add_head_rcu(&me->hnode, &nf_ct_helper_hash[h]);
 	nf_ct_helper_count++;
+out:
 	mutex_unlock(&nf_ct_helper_mutex);
-
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_register);
 
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
new file mode 100644
index 0000000..f399b46
--- /dev/null
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -0,0 +1,674 @@
+/*
+ * (C) 2012 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation (or any later at your option).
+ *
+ * This software has been sponsored by Vyatta Inc. <http://www.vyatta.com>
+ */
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
+#include <linux/rculist.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/errno.h>
+#include <net/netlink.h>
+#include <net/sock.h>
+
+#include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_ecache.h>
+
+#include <linux/netfilter/nfnetlink.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+#include <linux/netfilter/nfnetlink_cthelper.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_DESCRIPTION("nfnl_cthelper: User-space connection tracking helpers");
+
+static int
+nfnl_userspace_cthelper(struct sk_buff *skb, unsigned int protoff,
+			struct nf_conn *ct, enum ip_conntrack_info ctinfo)
+{
+	const struct nf_conn_help *help;
+	struct nf_conntrack_helper *helper;
+
+	help = nfct_help(ct);
+	if (help == NULL)
+		return NF_DROP;
+
+	/* rcu_read_lock()ed by nf_hook_slow */
+	helper = rcu_dereference(help->helper);
+	if (helper == NULL)
+		return NF_DROP;
+
+	/* This is an user-space helper not yet configured, skip. */
+	if ((helper->flags &
+	    (NF_CT_HELPER_F_USERSPACE | NF_CT_HELPER_F_CONFIGURED)) ==
+	     NF_CT_HELPER_F_USERSPACE)
+		return NF_ACCEPT;
+
+	/* If the user-space helper is not available, don't block traffic. */
+	return NF_QUEUE_NR(helper->queue_num) | NF_VERDICT_FLAG_QUEUE_BYPASS;
+}
+
+static const struct nla_policy nfnl_cthelper_tuple_pol[NFCTH_TUPLE_MAX+1] = {
+	[NFCTH_TUPLE_L3PROTONUM] = { .type = NLA_U16, },
+	[NFCTH_TUPLE_L4PROTONUM] = { .type = NLA_U8, },
+};
+
+static int
+nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *tuple,
+			  const struct nlattr *attr)
+{
+	struct nlattr *tb[NFCTH_TUPLE_MAX+1];
+
+	nla_parse_nested(tb, NFCTH_TUPLE_MAX, attr, nfnl_cthelper_tuple_pol);
+
+	if (!tb[NFCTH_TUPLE_L3PROTONUM] || !tb[NFCTH_TUPLE_L4PROTONUM])
+		return -EINVAL;
+
+	tuple->src.l3num = ntohs(nla_get_u16(tb[NFCTH_TUPLE_L3PROTONUM]));
+	tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);
+
+	return 0;
+}
+
+static int
+nfnl_cthelper_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
+{
+	const struct nf_conn_help *help = nfct_help(ct);
+
+	if (help->helper->data_len == 0)
+		return -EINVAL;
+
+	memcpy(&help->data, nla_data(attr), help->helper->data_len);
+	return 0;
+}
+
+static int
+nfnl_cthelper_to_nlattr(struct sk_buff *skb, const struct nf_conn *ct)
+{
+	const struct nf_conn_help *help = nfct_help(ct);
+
+	if (help->helper->data_len &&
+	    nla_put(skb, CTA_HELP_INFO, help->helper->data_len, &help->data))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -ENOSPC;
+}
+
+static const struct nla_policy nfnl_cthelper_expect_pol[NFCTH_POLICY_MAX+1] = {
+	[NFCTH_POLICY_NAME] = { .type = NLA_NUL_STRING,
+				.len = NF_CT_HELPER_NAME_LEN-1 },
+	[NFCTH_POLICY_EXPECT_MAX] = { .type = NLA_U32, },
+	[NFCTH_POLICY_EXPECT_TIMEOUT] = { .type = NLA_U32, },
+};
+
+static int
+nfnl_cthelper_expect_policy(struct nf_conntrack_expect_policy *expect_policy,
+			    const struct nlattr *attr)
+{
+	struct nlattr *tb[NFCTH_POLICY_MAX+1];
+
+	nla_parse_nested(tb, NFCTH_POLICY_MAX, attr, nfnl_cthelper_expect_pol);
+
+	if (!tb[NFCTH_POLICY_NAME] ||
+	    !tb[NFCTH_POLICY_EXPECT_MAX] ||
+	    !tb[NFCTH_POLICY_EXPECT_TIMEOUT])
+		return -EINVAL;
+
+	strncpy(expect_policy->name,
+		nla_data(tb[NFCTH_POLICY_NAME]), NF_CT_HELPER_NAME_LEN);
+	expect_policy->max_expected =
+		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_MAX]));
+	expect_policy->timeout =
+		ntohl(nla_get_be32(tb[NFCTH_POLICY_EXPECT_TIMEOUT]));
+
+	return 0;
+}
+
+static const struct nla_policy
+nfnl_cthelper_expect_policy_set[NFCTH_POLICY_SET_MAX+1] = {
+	[NFCTH_POLICY_SET_NUM] = { .type = NLA_U32, },
+};
+
+static int
+nfnl_cthelper_parse_expect_policy(struct nf_conntrack_helper *helper,
+				  const struct nlattr *attr)
+{
+	int i, ret;
+	struct nf_conntrack_expect_policy *expect_policy;
+	struct nlattr *tb[NFCTH_POLICY_SET_MAX+1];
+
+	nla_parse_nested(tb, NFCTH_POLICY_SET_MAX, attr,
+					nfnl_cthelper_expect_policy_set);
+
+	if (!tb[NFCTH_POLICY_SET_NUM])
+		return -EINVAL;
+
+	helper->expect_class_max =
+		ntohl(nla_get_be32(tb[NFCTH_POLICY_SET_NUM]));
+
+	if (helper->expect_class_max != 0 &&
+	    helper->expect_class_max > NF_CT_MAX_EXPECT_CLASSES)
+		return -EOVERFLOW;
+
+	expect_policy = kzalloc(sizeof(struct nf_conntrack_expect_policy) *
+				helper->expect_class_max, GFP_KERNEL);
+	if (expect_policy == NULL)
+		return -ENOMEM;
+
+	for (i=0; i<helper->expect_class_max; i++) {
+		if (!tb[NFCTH_POLICY_SET+i])
+			goto err;
+
+		ret = nfnl_cthelper_expect_policy(&expect_policy[i],
+						  tb[NFCTH_POLICY_SET+i]);
+		if (ret < 0)
+			goto err;
+	}
+	helper->expect_policy = expect_policy;
+	return 0;
+err:
+	kfree(expect_policy);
+	return -EINVAL;
+}
+
+static int
+nfnl_cthelper_create(const struct nlattr * const tb[],
+		     struct nf_conntrack_tuple *tuple)
+{
+	struct nf_conntrack_helper *helper;
+	int ret;
+
+	if (!tb[NFCTH_TUPLE] || !tb[NFCTH_POLICY] || !tb[NFCTH_PRIV_DATA_LEN])
+		return -EINVAL;
+
+	helper = kzalloc(sizeof(struct nf_conntrack_helper), GFP_KERNEL);
+	if (helper == NULL)
+		return -ENOMEM;
+
+	ret = nfnl_cthelper_parse_expect_policy(helper, tb[NFCTH_POLICY]);
+	if (ret < 0)
+		goto err;
+
+	strncpy(helper->name, nla_data(tb[NFCTH_NAME]), NF_CT_HELPER_NAME_LEN);
+	helper->data_len = ntohl(nla_get_be32(tb[NFCTH_PRIV_DATA_LEN]));
+	helper->flags |= NF_CT_HELPER_F_USERSPACE;
+	memcpy(&helper->tuple, tuple, sizeof(struct nf_conntrack_tuple));
+
+	helper->me = THIS_MODULE;
+	helper->help = nfnl_userspace_cthelper;
+	helper->from_nlattr = nfnl_cthelper_from_nlattr;
+	helper->to_nlattr = nfnl_cthelper_to_nlattr;
+
+	/* Default to queue number zero, this can be updated at any time. */
+	if (tb[NFCTH_QUEUE_NUM])
+		helper->queue_num = ntohl(nla_get_be32(tb[NFCTH_QUEUE_NUM]));
+
+	if (tb[NFCTH_STATUS]) {
+		int status = ntohl(nla_get_be32(tb[NFCTH_STATUS]));
+
+		switch(status) {
+		case NFCT_HELPER_STATUS_ENABLED:
+			helper->flags |= NF_CT_HELPER_F_CONFIGURED;
+			break;
+		case NFCT_HELPER_STATUS_DISABLED:
+			helper->flags &= ~NF_CT_HELPER_F_CONFIGURED;
+			break;
+		}
+	}
+
+	ret = nf_conntrack_helper_register(helper);
+	if (ret < 0)
+		goto err;
+
+	return 0;
+err:
+	kfree(helper);
+	return ret;
+}
+
+static int
+nfnl_cthelper_update(const struct nlattr * const tb[],
+		     struct nf_conntrack_helper *helper)
+{
+	int ret;
+
+	if (tb[NFCTH_PRIV_DATA_LEN])
+		return -EBUSY;
+
+	if (tb[NFCTH_POLICY]) {
+		ret = nfnl_cthelper_parse_expect_policy(helper,
+							tb[NFCTH_POLICY]);
+		if (ret < 0)
+			return ret;
+	}
+	if (tb[NFCTH_QUEUE_NUM])
+		helper->queue_num = ntohl(nla_get_be32(tb[NFCTH_QUEUE_NUM]));
+
+	if (tb[NFCTH_STATUS]) {
+		int status = ntohl(nla_get_be32(tb[NFCTH_STATUS]));
+
+		switch(status) {
+		case NFCT_HELPER_STATUS_ENABLED:
+			helper->flags |= NF_CT_HELPER_F_CONFIGURED;
+			break;
+		case NFCT_HELPER_STATUS_DISABLED:
+			helper->flags &= ~NF_CT_HELPER_F_CONFIGURED;
+			break;
+		}
+	}
+	return 0;
+}
+
+static int
+nfnl_cthelper_new(struct sock *nfnl, struct sk_buff *skb,
+		  const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+{
+	const char *helper_name;
+	struct nf_conntrack_helper *cur, *helper = NULL;
+	struct nf_conntrack_tuple tuple;
+	struct hlist_node *n;
+	int ret = 0, i;
+
+	if (!tb[NFCTH_NAME] || !tb[NFCTH_TUPLE])
+		return -EINVAL;
+
+	helper_name = nla_data(tb[NFCTH_NAME]);
+
+	ret = nfnl_cthelper_parse_tuple(&tuple, tb[NFCTH_TUPLE]);
+	if (ret < 0)
+		return ret;
+
+	rcu_read_lock();
+	for (i = 0; i < nf_ct_helper_hsize && !helper; i++) {
+		hlist_for_each_entry_rcu(cur, n, &nf_ct_helper_hash[i], hnode) {
+
+			/* skip non-userspace conntrack helpers. */
+			if (!(cur->flags & NF_CT_HELPER_F_USERSPACE))
+				continue;
+
+			if (strncmp(cur->name, helper_name,
+					NF_CT_HELPER_NAME_LEN) != 0)
+				continue;
+
+			if ((tuple.src.l3num != cur->tuple.src.l3num ||
+			     tuple.dst.protonum != cur->tuple.dst.protonum))
+				continue;
+
+			if (nlh->nlmsg_flags & NLM_F_EXCL) {
+				ret = -EEXIST;
+				goto err;
+			}
+			helper = cur;
+			break;
+		}
+	}
+	rcu_read_unlock();
+
+	if (helper == NULL)
+		ret = nfnl_cthelper_create(tb, &tuple);
+	else
+		ret = nfnl_cthelper_update(tb, helper);
+
+	return ret;
+err:
+	rcu_read_unlock();
+	return ret;
+}
+
+static int
+nfnl_cthelper_dump_tuple(struct sk_buff *skb,
+			 struct nf_conntrack_helper *helper)
+{
+	struct nlattr *nest_parms;
+
+	nest_parms = nla_nest_start(skb, NFCTH_TUPLE | NLA_F_NESTED);
+	if (nest_parms == NULL)
+		goto nla_put_failure;
+
+	if (nla_put_be16(skb, NFCTH_TUPLE_L3PROTONUM,
+			 htons(helper->tuple.src.l3num)))
+		goto nla_put_failure;
+
+	if (nla_put_u8(skb, NFCTH_TUPLE_L4PROTONUM, helper->tuple.dst.protonum))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, nest_parms);
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int
+nfnl_cthelper_dump_policy(struct sk_buff *skb,
+			struct nf_conntrack_helper *helper)
+{
+	int i;
+	struct nlattr *nest_parms1, *nest_parms2;
+
+	nest_parms1 = nla_nest_start(skb, NFCTH_POLICY | NLA_F_NESTED);
+	if (nest_parms1 == NULL)
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFCTH_POLICY_SET_NUM,
+			 htonl(helper->expect_class_max)))
+		goto nla_put_failure;
+
+	for (i=0; i<helper->expect_class_max; i++) {
+		nest_parms2 = nla_nest_start(skb,
+				(NFCTH_POLICY_SET+i) | NLA_F_NESTED);
+		if (nest_parms2 == NULL)
+			goto nla_put_failure;
+
+		if (nla_put_string(skb, NFCTH_POLICY_NAME,
+				   helper->expect_policy[i].name))
+			goto nla_put_failure;
+
+		if (nla_put_be32(skb, NFCTH_POLICY_EXPECT_MAX,
+				 htonl(helper->expect_policy[i].max_expected)))
+			goto nla_put_failure;
+
+		if (nla_put_be32(skb, NFCTH_POLICY_EXPECT_TIMEOUT,
+				 htonl(helper->expect_policy[i].timeout)))
+			goto nla_put_failure;
+
+		nla_nest_end(skb, nest_parms2);
+	}
+	nla_nest_end(skb, nest_parms1);
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
+static int
+nfnl_cthelper_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+			int event, struct nf_conntrack_helper *helper)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	int status;
+
+	event |= NFNL_SUBSYS_CTHELPER << 8;
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version = NFNETLINK_V0;
+	nfmsg->res_id = 0;
+
+	if (nla_put_string(skb, NFCTH_NAME, helper->name))
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFCTH_QUEUE_NUM, htonl(helper->queue_num)))
+		goto nla_put_failure;
+
+	if (nfnl_cthelper_dump_tuple(skb, helper) < 0)
+		goto nla_put_failure;
+
+	if (nfnl_cthelper_dump_policy(skb, helper) < 0)
+		goto nla_put_failure;
+
+	if (nla_put_be32(skb, NFCTH_PRIV_DATA_LEN, htonl(helper->data_len)))
+		goto nla_put_failure;
+
+	if (helper->flags & NF_CT_HELPER_F_CONFIGURED)
+		status = NFCT_HELPER_STATUS_ENABLED;
+	else
+		status = NFCT_HELPER_STATUS_DISABLED;
+
+	if (nla_put_be32(skb, NFCTH_STATUS, htonl(status)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nlmsg_failure:
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+nfnl_cthelper_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct nf_conntrack_helper *cur, *last;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	last = (struct nf_conntrack_helper *)cb->args[1];
+	for (; cb->args[0] < nf_ct_helper_hsize; cb->args[0]++) {
+restart:
+		hlist_for_each_entry_rcu(cur, n,
+				&nf_ct_helper_hash[cb->args[0]], hnode) {
+
+			/* skip non-userspace conntrack helpers. */
+			if (!(cur->flags & NF_CT_HELPER_F_USERSPACE))
+				continue;
+
+			if (cb->args[1]) {
+				if (cur != last)
+					continue;
+				cb->args[1] = 0;
+			}
+			if (nfnl_cthelper_fill_info(skb,
+					    NETLINK_CB(cb->skb).pid,
+					    cb->nlh->nlmsg_seq,
+					    NFNL_MSG_TYPE(cb->nlh->nlmsg_type),
+					    NFNL_MSG_CTHELPER_NEW, cur) < 0) {
+				cb->args[1] = (unsigned long)cur;
+				goto out;
+			}
+		}
+	}
+	if (cb->args[1]) {
+		cb->args[1] = 0;
+		goto restart;
+	}
+out:
+	rcu_read_unlock();
+	return skb->len;
+}
+
+static int
+nfnl_cthelper_get(struct sock *nfnl, struct sk_buff *skb,
+		  const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+{
+	int ret = -ENOENT, i;
+	struct nf_conntrack_helper *cur;
+	struct hlist_node *n;
+	struct sk_buff *skb2;
+	char *helper_name = NULL;
+	struct nf_conntrack_tuple tuple;
+	bool tuple_set = false;
+
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = nfnl_cthelper_dump_table,
+		};
+		return netlink_dump_start(nfnl, skb, nlh, &c);
+	}
+
+	if (tb[NFCTH_NAME])
+		helper_name = nla_data(tb[NFCTH_NAME]);
+
+	if (tb[NFCTH_TUPLE]) {
+		ret = nfnl_cthelper_parse_tuple(&tuple, tb[NFCTH_TUPLE]);
+		if (ret < 0)
+			return ret;
+
+		tuple_set = true;
+	}
+
+	for (i = 0; i < nf_ct_helper_hsize; i++) {
+		hlist_for_each_entry_rcu(cur, n, &nf_ct_helper_hash[i], hnode) {
+
+			/* skip non-userspace conntrack helpers. */
+			if (!(cur->flags & NF_CT_HELPER_F_USERSPACE))
+				continue;
+
+			if (helper_name && strncmp(cur->name, helper_name,
+						NF_CT_HELPER_NAME_LEN) != 0) {
+				continue;
+			}
+			if (tuple_set &&
+			    (tuple.src.l3num != cur->tuple.src.l3num ||
+			     tuple.dst.protonum != cur->tuple.dst.protonum))
+				continue;
+
+			skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+			if (skb2 == NULL) {
+				ret = -ENOMEM;
+				break;
+			}
+
+			ret = nfnl_cthelper_fill_info(skb2, NETLINK_CB(skb).pid,
+						nlh->nlmsg_seq,
+						NFNL_MSG_TYPE(nlh->nlmsg_type),
+						NFNL_MSG_CTHELPER_NEW, cur);
+			if (ret <= 0) {
+				kfree_skb(skb2);
+				break;
+			}
+
+			ret = netlink_unicast(nfnl, skb2, NETLINK_CB(skb).pid,
+						MSG_DONTWAIT);
+			if (ret > 0)
+				ret = 0;
+
+			/* this avoids a loop in nfnetlink. */
+			return ret == -EAGAIN ? -ENOBUFS : ret;
+		}
+	}
+	return ret;
+}
+
+static int
+nfnl_cthelper_del(struct sock *nfnl, struct sk_buff *skb,
+	     const struct nlmsghdr *nlh, const struct nlattr * const tb[])
+{
+	char *helper_name = NULL;
+	struct nf_conntrack_helper *cur;
+	struct hlist_node *n, *tmp;
+	struct nf_conntrack_tuple tuple;
+	bool tuple_set = false, found = false;
+	int i, j = 0, ret;
+
+	if (tb[NFCTH_NAME])
+		helper_name = nla_data(tb[NFCTH_NAME]);
+
+	if (tb[NFCTH_TUPLE]) {
+		ret = nfnl_cthelper_parse_tuple(&tuple, tb[NFCTH_TUPLE]);
+		if (ret < 0)
+			return ret;
+
+		tuple_set = true;
+	}
+
+	for (i = 0; i < nf_ct_helper_hsize; i++) {
+		hlist_for_each_entry_safe(cur, n, tmp, &nf_ct_helper_hash[i],
+								hnode) {
+			/* skip non-userspace conntrack helpers. */
+			if (!(cur->flags & NF_CT_HELPER_F_USERSPACE))
+				continue;
+
+			j++;
+
+			if (helper_name && strncmp(cur->name, helper_name,
+						NF_CT_HELPER_NAME_LEN) != 0) {
+				continue;
+			}
+			if (tuple_set &&
+			    (tuple.src.l3num != cur->tuple.src.l3num ||
+			     tuple.dst.protonum != cur->tuple.dst.protonum))
+				continue;
+
+			found = true;
+			nf_conntrack_helper_unregister(cur);
+		}
+	}
+	/* Make sure we return success if we flush and there is no helpers */
+	return (found || j == 0) ? 0 : -ENOENT;
+}
+
+static const struct nla_policy nfnl_cthelper_policy[NFCTH_MAX+1] = {
+	[NFCTH_NAME] = { .type = NLA_NUL_STRING,
+			 .len = NF_CT_HELPER_NAME_LEN-1 },
+	[NFCTH_QUEUE_NUM] = { .type = NLA_U32, },
+};
+
+static const struct nfnl_callback nfnl_cthelper_cb[NFNL_MSG_CTHELPER_MAX] = {
+	[NFNL_MSG_CTHELPER_NEW]		= { .call = nfnl_cthelper_new,
+					    .attr_count = NFCTH_MAX,
+					    .policy = nfnl_cthelper_policy },
+	[NFNL_MSG_CTHELPER_GET]		= { .call = nfnl_cthelper_get,
+					    .attr_count = NFCTH_MAX,
+					    .policy = nfnl_cthelper_policy },
+	[NFNL_MSG_CTHELPER_DEL]		= { .call = nfnl_cthelper_del,
+					    .attr_count = NFCTH_MAX,
+					    .policy = nfnl_cthelper_policy },
+};
+
+static const struct nfnetlink_subsystem nfnl_cthelper_subsys = {
+	.name				= "cthelper",
+	.subsys_id			= NFNL_SUBSYS_CTHELPER,
+	.cb_count			= NFNL_MSG_CTHELPER_MAX,
+	.cb				= nfnl_cthelper_cb,
+};
+
+MODULE_ALIAS_NFNL_SUBSYS(NFNL_SUBSYS_CTHELPER);
+
+static int __init nfnl_cthelper_init(void)
+{
+	int ret;
+
+	pr_info("nfnl_cthelper: registering with nfnetlink.\n");
+	ret = nfnetlink_subsys_register(&nfnl_cthelper_subsys);
+	if (ret < 0) {
+		pr_err("nfnl_cthelper: cannot register with nfnetlink.\n");
+		goto err_out;
+	}
+	return 0;
+err_out:
+	return ret;
+}
+
+static void __exit nfnl_cthelper_exit(void)
+{
+	struct nf_conntrack_helper *cur;
+	struct hlist_node *n, *tmp;
+	int i;
+
+	pr_info("nfnl_cthelper: unregistering from nfnetlink.\n");
+	nfnetlink_subsys_unregister(&nfnl_cthelper_subsys);
+
+	for (i=0; i<nf_ct_helper_hsize; i++) {
+		hlist_for_each_entry_safe(cur, n, tmp, &nf_ct_helper_hash[i],
+									hnode) {
+			/* skip non-userspace conntrack helpers. */
+			if (!(cur->flags & NF_CT_HELPER_F_USERSPACE))
+				continue;
+
+			nf_conntrack_helper_unregister(cur);
+		}
+	}
+}
+
+module_init(nfnl_cthelper_init);
+module_exit(nfnl_cthelper_exit);
-- 
1.7.10
