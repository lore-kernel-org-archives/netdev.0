From: kaber@trash.net
Subject: [PATCH 78/79] netfilter: nf_conntrack_tstamp: add flow-based timestamp extension
Date: Wed, 19 Jan 2011 20:15:18 +0100
Message-ID: <1295464519-21763-79-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds flow-based timestamping for conntracks. This
conntrack extension is disabled by default. Basically, we use
two 64-bits variables to store the creation timestamp once the
conntrack has been confirmed and the other to store the deletion
time. This extension is disabled by default, to enable it, you
have to:

echo 1 > /proc/sys/net/netfilter/nf_conntrack_timestamp

This patch allows to save memory for user-space flow-based
loogers such as ulogd2. In short, ulogd2 does not need to
keep a hashtable with the conntrack in user-space to know
when they were created and destroyed, instead we use the
kernel timestamp. If we want to have a sane IPFIX implementation
in user-space, this nanosecs resolution timestamps are also
useful. Other custom user-space applications can benefit from
this via libnetfilter_conntrack.

This patch modifies the /proc output to display the delta time
in seconds since the flow start. You can also obtain the
flow-start date by means of the conntrack-tools.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink_conntrack.h  |    9 ++
 include/net/netfilter/nf_conntrack_extend.h    |    4 +
 include/net/netfilter/nf_conntrack_timestamp.h |   53 +++++++++++
 include/net/netns/conntrack.h                  |    2 +
 net/netfilter/Kconfig                          |   11 ++
 net/netfilter/Makefile                         |    1 +
 net/netfilter/nf_conntrack_core.c              |   26 +++++
 net/netfilter/nf_conntrack_netlink.c           |   46 +++++++++-
 net/netfilter/nf_conntrack_standalone.c        |   41 ++++++++
 net/netfilter/nf_conntrack_timestamp.c         |  120 ++++++++++++++++++++++++
 10 files changed, 312 insertions(+), 1 deletions(-)
 create mode 100644 include/net/netfilter/nf_conntrack_timestamp.h
 create mode 100644 net/netfilter/nf_conntrack_timestamp.c

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 19711e3..debf1ae 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -42,6 +42,7 @@ enum ctattr_type {
 	CTA_SECMARK,		/* obsolete */
 	CTA_ZONE,
 	CTA_SECCTX,
+	CTA_TIMESTAMP,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
@@ -127,6 +128,14 @@ enum ctattr_counters {
 };
 #define CTA_COUNTERS_MAX (__CTA_COUNTERS_MAX - 1)
 
+enum ctattr_tstamp {
+	CTA_TIMESTAMP_UNSPEC,
+	CTA_TIMESTAMP_START,
+	CTA_TIMESTAMP_STOP,
+	__CTA_TIMESTAMP_MAX
+};
+#define CTA_TIMESTAMP_MAX (__CTA_TIMESTAMP_MAX - 1)
+
 enum ctattr_nat {
 	CTA_NAT_UNSPEC,
 	CTA_NAT_MINIP,
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 1a9f96d..2dcf317 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -17,6 +17,9 @@ enum nf_ct_ext_id {
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	NF_CT_EXT_ZONE,
 #endif
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
+	NF_CT_EXT_TSTAMP,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -25,6 +28,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
 #define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
 #define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
+#define NF_CT_EXT_TSTAMP_TYPE struct nf_conn_tstamp
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netfilter/nf_conntrack_timestamp.h b/include/net/netfilter/nf_conntrack_timestamp.h
new file mode 100644
index 0000000..f17dcb6
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_timestamp.h
@@ -0,0 +1,53 @@
+#ifndef _NF_CONNTRACK_TSTAMP_H
+#define _NF_CONNTRACK_TSTAMP_H
+
+#include <net/net_namespace.h>
+#include <linux/netfilter/nf_conntrack_common.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+
+struct nf_conn_tstamp {
+	u_int64_t start;
+	u_int64_t stop;
+};
+
+static inline
+struct nf_conn_tstamp *nf_conn_tstamp_find(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
+	return nf_ct_ext_find(ct, NF_CT_EXT_TSTAMP);
+#else
+	return NULL;
+#endif
+}
+
+static inline
+struct nf_conn_tstamp *nf_ct_tstamp_ext_add(struct nf_conn *ct, gfp_t gfp)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
+	struct net *net = nf_ct_net(ct);
+
+	if (!net->ct.sysctl_tstamp)
+		return NULL;
+
+	return nf_ct_ext_add(ct, NF_CT_EXT_TSTAMP, gfp);
+#else
+	return NULL;
+#endif
+};
+
+static inline bool nf_ct_tstamp_enabled(struct net *net)
+{
+	return net->ct.sysctl_tstamp != 0;
+}
+
+static inline void nf_ct_set_tstamp(struct net *net, bool enable)
+{
+	net->ct.sysctl_tstamp = enable;
+}
+
+extern int nf_conntrack_tstamp_init(struct net *net);
+extern void nf_conntrack_tstamp_fini(struct net *net);
+
+#endif /* _NF_CONNTRACK_TSTAMP_H */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 5cf8a8c..341eb08 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -21,11 +21,13 @@ struct netns_ct {
 	int			sysctl_events;
 	unsigned int		sysctl_events_retry_timeout;
 	int			sysctl_acct;
+	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
+	struct ctl_table_header	*tstamp_sysctl_header;
 	struct ctl_table_header	*event_sysctl_header;
 #endif
 	char			*slabname;
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 939b504..faf7412 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -85,6 +85,17 @@ config NF_CONNTRACK_EVENTS
 
 	  If unsure, say `N'.
 
+config NF_CONNTRACK_TIMESTAMP
+	bool  'Connection tracking timestamping'
+	depends on NETFILTER_ADVANCED
+	help
+	  This option enables support for connection tracking timestamping.
+	  This allows you to store the flow start-time and to obtain
+	  the flow-stop time (once it has been destroyed) via Connection
+	  tracking events.
+
+	  If unsure, say `N'.
+
 config NF_CT_PROTO_DCCP
 	tristate 'DCCP protocol connection tracking support (EXPERIMENTAL)'
 	depends on EXPERIMENTAL
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 2c2628d..9ae6878 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -1,6 +1,7 @@
 netfilter-objs := core.o nf_log.o nf_queue.o nf_sockopt.o
 
 nf_conntrack-y	:= nf_conntrack_core.o nf_conntrack_standalone.o nf_conntrack_expect.o nf_conntrack_helper.o nf_conntrack_proto.o nf_conntrack_l3proto_generic.o nf_conntrack_proto_generic.o nf_conntrack_proto_tcp.o nf_conntrack_proto_udp.o nf_conntrack_extend.o nf_conntrack_acct.o
+nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f47ac67..1909311 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -43,6 +43,7 @@
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_zones.h>
+#include <net/netfilter/nf_conntrack_timestamp.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 
@@ -282,6 +283,11 @@ EXPORT_SYMBOL_GPL(nf_ct_insert_dying_list);
 static void death_by_timeout(unsigned long ul_conntrack)
 {
 	struct nf_conn *ct = (void *)ul_conntrack;
+	struct nf_conn_tstamp *tstamp;
+
+	tstamp = nf_conn_tstamp_find(ct);
+	if (tstamp && tstamp->stop == 0)
+		tstamp->stop = ktime_to_ns(ktime_get_real());
 
 	if (!test_bit(IPS_DYING_BIT, &ct->status) &&
 	    unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
@@ -419,6 +425,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
+	struct nf_conn_tstamp *tstamp;
 	struct hlist_nulls_node *n;
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
@@ -488,6 +495,14 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	atomic_inc(&ct->ct_general.use);
 	ct->status |= IPS_CONFIRMED;
 
+	/* set conntrack timestamp, if enabled. */
+	tstamp = nf_conn_tstamp_find(ct);
+	if (tstamp) {
+		if (skb->tstamp.tv64 == 0)
+			__net_timestamp((struct sk_buff *)skb);
+
+		tstamp->start = ktime_to_ns(skb->tstamp);
+	}
 	/* Since the lookup is lockless, hash insertion must be done after
 	 * starting the timer and setting the CONFIRMED bit. The RCU barriers
 	 * guarantee that no other CPU can find the conntrack before the above
@@ -746,6 +761,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
 
 	ecache = tmpl ? nf_ct_ecache_find(tmpl) : NULL;
 	nf_ct_ecache_ext_add(ct, ecache ? ecache->ctmask : 0,
@@ -1186,6 +1202,11 @@ struct __nf_ct_flush_report {
 static int kill_report(struct nf_conn *i, void *data)
 {
 	struct __nf_ct_flush_report *fr = (struct __nf_ct_flush_report *)data;
+	struct nf_conn_tstamp *tstamp;
+
+	tstamp = nf_conn_tstamp_find(i);
+	if (tstamp && tstamp->stop == 0)
+		tstamp->stop = ktime_to_ns(ktime_get_real());
 
 	/* If we fail to deliver the event, death_by_timeout() will retry */
 	if (nf_conntrack_event_report(IPCT_DESTROY, i,
@@ -1497,6 +1518,9 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_acct_init(net);
 	if (ret < 0)
 		goto err_acct;
+	ret = nf_conntrack_tstamp_init(net);
+	if (ret < 0)
+		goto err_tstamp;
 	ret = nf_conntrack_ecache_init(net);
 	if (ret < 0)
 		goto err_ecache;
@@ -1504,6 +1528,8 @@ static int nf_conntrack_init_net(struct net *net)
 	return 0;
 
 err_ecache:
+	nf_conntrack_tstamp_fini(net);
+err_tstamp:
 	nf_conntrack_acct_fini(net);
 err_acct:
 	nf_conntrack_expect_fini(net);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 9eabaa6..715d56c 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -42,6 +42,7 @@
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_zones.h>
+#include <net/netfilter/nf_conntrack_timestamp.h>
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_protocol.h>
@@ -230,6 +231,33 @@ nla_put_failure:
 	return -1;
 }
 
+static int
+ctnetlink_dump_timestamp(struct sk_buff *skb, const struct nf_conn *ct)
+{
+	struct nlattr *nest_count;
+	const struct nf_conn_tstamp *tstamp;
+
+	tstamp = nf_conn_tstamp_find(ct);
+	if (!tstamp)
+		return 0;
+
+	nest_count = nla_nest_start(skb, CTA_TIMESTAMP | NLA_F_NESTED);
+	if (!nest_count)
+		goto nla_put_failure;
+
+	NLA_PUT_BE64(skb, CTA_TIMESTAMP_START, cpu_to_be64(tstamp->start));
+	if (tstamp->stop != 0) {
+		NLA_PUT_BE64(skb, CTA_TIMESTAMP_STOP,
+			     cpu_to_be64(tstamp->stop));
+	}
+	nla_nest_end(skb, nest_count);
+
+	return 0;
+
+nla_put_failure:
+	return -1;
+}
+
 #ifdef CONFIG_NF_CONNTRACK_MARK
 static inline int
 ctnetlink_dump_mark(struct sk_buff *skb, const struct nf_conn *ct)
@@ -404,6 +432,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 	    ctnetlink_dump_timeout(skb, ct) < 0 ||
 	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
 	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0 ||
+	    ctnetlink_dump_timestamp(skb, ct) < 0 ||
 	    ctnetlink_dump_protoinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_mark(skb, ct) < 0 ||
@@ -471,6 +500,18 @@ ctnetlink_secctx_size(const struct nf_conn *ct)
 }
 
 static inline size_t
+ctnetlink_timestamp_size(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
+	if (!nf_ct_ext_exist(ct, NF_CT_EXT_TSTAMP))
+		return 0;
+	return nla_total_size(0) + 2 * nla_total_size(sizeof(uint64_t));
+#else
+	return 0;
+#endif
+}
+
+static inline size_t
 ctnetlink_nlmsg_size(const struct nf_conn *ct)
 {
 	return NLMSG_ALIGN(sizeof(struct nfgenmsg))
@@ -481,6 +522,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
 	       + ctnetlink_counters_size(ct)
+	       + ctnetlink_timestamp_size(ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
 	       + nla_total_size(0) /* CTA_PROTOINFO */
 	       + nla_total_size(0) /* CTA_HELP */
@@ -571,7 +613,8 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 
 	if (events & (1 << IPCT_DESTROY)) {
 		if (ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
-		    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0)
+		    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0 ||
+		    ctnetlink_dump_timestamp(skb, ct) < 0)
 			goto nla_put_failure;
 	} else {
 		if (ctnetlink_dump_timeout(skb, ct) < 0)
@@ -1360,6 +1403,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
+	nf_ct_tstamp_ext_add(ct, GFP_ATOMIC);
 	nf_ct_ecache_ext_add(ct, 0, 0, GFP_ATOMIC);
 	/* we must add conntrack extensions before confirmation. */
 	ct->status |= IPS_CONFIRMED;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 8257bf6..69107fd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_zones.h>
+#include <net/netfilter/nf_conntrack_timestamp.h>
 #include <linux/rculist_nulls.h>
 
 MODULE_LICENSE("GPL");
@@ -46,6 +47,7 @@ EXPORT_SYMBOL_GPL(print_tuple);
 struct ct_iter_state {
 	struct seq_net_private p;
 	unsigned int bucket;
+	u_int64_t time_now;
 };
 
 static struct hlist_nulls_node *ct_get_first(struct seq_file *seq)
@@ -96,6 +98,9 @@ static struct hlist_nulls_node *ct_get_idx(struct seq_file *seq, loff_t pos)
 static void *ct_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
 {
+	struct ct_iter_state *st = seq->private;
+
+	st->time_now = ktime_to_ns(ktime_get_real());
 	rcu_read_lock();
 	return ct_get_idx(seq, *pos);
 }
@@ -135,6 +140,39 @@ static inline int ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 }
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
+static u_int64_t ct_delta_time(u_int64_t time_now, const struct nf_conn *ct)
+{
+	struct nf_conn_tstamp *tstamp;
+
+	tstamp = nf_conn_tstamp_find(ct);
+	if (tstamp) {
+		u_int64_t delta_time = time_now - tstamp->start;
+		return delta_time > 0 ? div_s64(delta_time, NSEC_PER_SEC) : 0;
+	}
+	return -1;
+}
+
+static int ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
+{
+	struct ct_iter_state *st = s->private;
+	u_int64_t delta_time;
+
+	delta_time = ct_delta_time(st->time_now, ct);
+	if (delta_time < 0)
+		return 0;
+
+	return seq_printf(s, "delta-time=%llu ",
+			  (unsigned long long)delta_time);
+}
+#else
+static inline int
+ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
+{
+	return 0;
+}
+#endif
+
 /* return 0 on success, 1 in case of error */
 static int ct_seq_show(struct seq_file *s, void *v)
 {
@@ -203,6 +241,9 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 #endif
 
+	if (ct_show_delta_time(s, ct))
+		goto release;
+
 	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
 		goto release;
 
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
new file mode 100644
index 0000000..af7dd31
--- /dev/null
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -0,0 +1,120 @@
+/*
+ * (C) 2010 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation (or any later at your option).
+ */
+
+#include <linux/netfilter.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/moduleparam.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+#include <net/netfilter/nf_conntrack_timestamp.h>
+
+static int nf_ct_tstamp __read_mostly;
+
+module_param_named(tstamp, nf_ct_tstamp, bool, 0644);
+MODULE_PARM_DESC(tstamp, "Enable connection tracking flow timestamping.");
+
+#ifdef CONFIG_SYSCTL
+static struct ctl_table tstamp_sysctl_table[] = {
+	{
+		.procname	= "nf_conntrack_timestamp",
+		.data		= &init_net.ct.sysctl_tstamp,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{}
+};
+#endif /* CONFIG_SYSCTL */
+
+static struct nf_ct_ext_type tstamp_extend __read_mostly = {
+	.len	= sizeof(struct nf_conn_tstamp),
+	.align	= __alignof__(struct nf_conn_tstamp),
+	.id	= NF_CT_EXT_TSTAMP,
+};
+
+#ifdef CONFIG_SYSCTL
+static int nf_conntrack_tstamp_init_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = kmemdup(tstamp_sysctl_table, sizeof(tstamp_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	table[0].data = &net->ct.sysctl_tstamp;
+
+	net->ct.tstamp_sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, table);
+	if (!net->ct.tstamp_sysctl_header) {
+		printk(KERN_ERR "nf_ct_tstamp: can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+
+out_register:
+	kfree(table);
+out:
+	return -ENOMEM;
+}
+
+static void nf_conntrack_tstamp_fini_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ct.tstamp_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.tstamp_sysctl_header);
+	kfree(table);
+}
+#else
+static int nf_conntrack_tstamp_init_sysctl(struct net *net)
+{
+	return 0;
+}
+
+static void nf_conntrack_tstamp_fini_sysctl(struct net *net)
+{
+}
+#endif
+
+int nf_conntrack_tstamp_init(struct net *net)
+{
+	int ret;
+
+	net->ct.sysctl_tstamp = nf_ct_tstamp;
+
+	if (net_eq(net, &init_net)) {
+		ret = nf_ct_extend_register(&tstamp_extend);
+		if (ret < 0) {
+			printk(KERN_ERR "nf_ct_tstamp: Unable to register "
+					"extension\n");
+			goto out_extend_register;
+		}
+	}
+
+	ret = nf_conntrack_tstamp_init_sysctl(net);
+	if (ret < 0)
+		goto out_sysctl;
+
+	return 0;
+
+out_sysctl:
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&tstamp_extend);
+out_extend_register:
+	return ret;
+}
+
+void nf_conntrack_tstamp_fini(struct net *net)
+{
+	nf_conntrack_tstamp_fini_sysctl(net);
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&tstamp_extend);
+}
-- 
1.7.2.3

