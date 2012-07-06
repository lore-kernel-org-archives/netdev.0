From: pablo@netfilter.org
Subject: [PATCH 01/18] netfilter: ctnetlink: add new messages to obtain statistics
Date: Fri,  6 Jul 2012 13:16:51 +0200
Message-ID: <1341573428-3204-2-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43370 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757033Ab2GFLSx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:18:53 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch adds the following messages to ctnetlink:

IPCTNL_MSG_CT_GET_STATS_CPU
IPCTNL_MSG_CT_GET_STATS
IPCTNL_MSG_EXP_GET_STATS_CPU

To display connection tracking system per-cpu and global statistics.

This provides a replacement for the following /proc interfaces:

/proc/net/stat/nf_conntrack
/proc/sys/net/netfilter/nf_conntrack_count

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |   38 +++++
 net/netfilter/nf_conntrack_netlink.c          |  227 ++++++++++++++++++++++++-
 2 files changed, 264 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index 7688833..f649f74 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -7,6 +7,8 @@ enum cntl_msg_types {
 	IPCTNL_MSG_CT_GET,
 	IPCTNL_MSG_CT_DELETE,
 	IPCTNL_MSG_CT_GET_CTRZERO,
+	IPCTNL_MSG_CT_GET_STATS_CPU,
+	IPCTNL_MSG_CT_GET_STATS,
 
 	IPCTNL_MSG_MAX
 };
@@ -15,6 +17,7 @@ enum ctnl_exp_msg_types {
 	IPCTNL_MSG_EXP_NEW,
 	IPCTNL_MSG_EXP_GET,
 	IPCTNL_MSG_EXP_DELETE,
+	IPCTNL_MSG_EXP_GET_STATS_CPU,
 
 	IPCTNL_MSG_EXP_MAX
 };
@@ -203,4 +206,39 @@ enum ctattr_secctx {
 };
 #define CTA_SECCTX_MAX (__CTA_SECCTX_MAX - 1)
 
+enum ctattr_stats_cpu {
+	CTA_STATS_UNSPEC,
+	CTA_STATS_SEARCHED,
+	CTA_STATS_FOUND,
+	CTA_STATS_NEW,
+	CTA_STATS_INVALID,
+	CTA_STATS_IGNORE,
+	CTA_STATS_DELETE,
+	CTA_STATS_DELETE_LIST,
+	CTA_STATS_INSERT,
+	CTA_STATS_INSERT_FAILED,
+	CTA_STATS_DROP,
+	CTA_STATS_EARLY_DROP,
+	CTA_STATS_ERROR,
+	CTA_STATS_SEARCH_RESTART,
+	__CTA_STATS_MAX,
+};
+#define CTA_STATS_MAX (__CTA_STATS_MAX - 1)
+
+enum ctattr_stats_global {
+	CTA_STATS_GLOBAL_UNSPEC,
+	CTA_STATS_GLOBAL_ENTRIES,
+	__CTA_STATS_GLOBAL_MAX,
+};
+#define CTA_STATS_GLOBAL_MAX (__CTA_STATS_GLOBAL_MAX - 1)
+
+enum ctattr_expect_stats {
+	CTA_STATS_EXP_UNSPEC,
+	CTA_STATS_EXP_NEW,
+	CTA_STATS_EXP_CREATE,
+	CTA_STATS_EXP_DELETE,
+	__CTA_STATS_EXP_MAX,
+};
+#define CTA_STATS_EXP_MAX (__CTA_STATS_EXP_MAX - 1)
+
 #endif /* _IPCONNTRACK_NETLINK_H */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b9b8f4a..14f67a2 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -4,7 +4,7 @@
  * (C) 2001 by Jay Schulist <jschlst@samba.org>
  * (C) 2002-2006 by Harald Welte <laforge@gnumonks.org>
  * (C) 2003 by Patrick Mchardy <kaber@trash.net>
- * (C) 2005-2011 by Pablo Neira Ayuso <pablo@netfilter.org>
+ * (C) 2005-2012 by Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * Initial connection tracking via netlink development funded and
  * generally made possible by Network Robots, Inc. (www.networkrobots.com)
@@ -1627,6 +1627,155 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
+static int
+ctnetlink_ct_stat_cpu_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+				__u16 cpu, const struct ip_conntrack_stat *st)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+
+	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS_CPU);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version      = NFNETLINK_V0;
+	nfmsg->res_id	    = htons(cpu);
+
+	if (nla_put_be32(skb, CTA_STATS_SEARCHED, htonl(st->searched)) ||
+	    nla_put_be32(skb, CTA_STATS_FOUND, htonl(st->found)) ||
+	    nla_put_be32(skb, CTA_STATS_NEW, htonl(st->new)) ||
+	    nla_put_be32(skb, CTA_STATS_INVALID, htonl(st->invalid)) ||
+	    nla_put_be32(skb, CTA_STATS_IGNORE, htonl(st->ignore)) ||
+	    nla_put_be32(skb, CTA_STATS_DELETE, htonl(st->delete)) ||
+	    nla_put_be32(skb, CTA_STATS_DELETE_LIST, htonl(st->delete_list)) ||
+	    nla_put_be32(skb, CTA_STATS_INSERT, htonl(st->insert)) ||
+	    nla_put_be32(skb, CTA_STATS_INSERT_FAILED,
+				htonl(st->insert_failed)) ||
+	    nla_put_be32(skb, CTA_STATS_DROP, htonl(st->drop)) ||
+	    nla_put_be32(skb, CTA_STATS_EARLY_DROP, htonl(st->early_drop)) ||
+	    nla_put_be32(skb, CTA_STATS_ERROR, htonl(st->error)) ||
+	    nla_put_be32(skb, CTA_STATS_SEARCH_RESTART,
+				htonl(st->search_restart)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nla_put_failure:
+nlmsg_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+ctnetlink_ct_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int cpu;
+	struct net *net = sock_net(skb->sk);
+
+	if (cb->args[0] == nr_cpu_ids)
+		return 0;
+
+	for (cpu = cb->args[0]; cpu < nr_cpu_ids; cpu++) {
+		const struct ip_conntrack_stat *st;
+
+		if (!cpu_possible(cpu))
+			continue;
+
+		st = per_cpu_ptr(net->ct.stat, cpu);
+		if (ctnetlink_ct_stat_cpu_fill_info(skb,
+						    NETLINK_CB(cb->skb).pid,
+						    cb->nlh->nlmsg_seq,
+						    cpu, st) < 0)
+				break;
+	}
+	cb->args[0] = cpu;
+
+	return skb->len;
+}
+
+static int
+ctnetlink_stat_ct_cpu(struct sock *ctnl, struct sk_buff *skb,
+		      const struct nlmsghdr *nlh,
+		      const struct nlattr * const cda[])
+{
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_ct_stat_cpu_dump,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
+
+	return 0;
+}
+
+static int
+ctnetlink_stat_ct_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+			    struct net *net)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+	unsigned int nr_conntracks = atomic_read(&net->ct.count);
+
+	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_GET_STATS);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version      = NFNETLINK_V0;
+	nfmsg->res_id	    = 0;
+
+	if (nla_put_be32(skb, CTA_STATS_GLOBAL_ENTRIES, htonl(nr_conntracks)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nla_put_failure:
+nlmsg_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+ctnetlink_stat_ct(struct sock *ctnl, struct sk_buff *skb,
+		  const struct nlmsghdr *nlh,
+		  const struct nlattr * const cda[])
+{
+	struct sk_buff *skb2;
+	int err;
+
+	skb2 = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (skb2 == NULL)
+		return -ENOMEM;
+
+	err = ctnetlink_stat_ct_fill_info(skb2, NETLINK_CB(skb).pid,
+					  nlh->nlmsg_seq,
+					  NFNL_MSG_TYPE(nlh->nlmsg_type),
+					  sock_net(skb->sk));
+	if (err <= 0)
+		goto free;
+
+	err = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
+	if (err < 0)
+		goto out;
+
+	return 0;
+
+free:
+	kfree_skb(skb2);
+out:
+	/* this avoids a loop in nfnetlink. */
+	return err == -EAGAIN ? -ENOBUFS : err;
+}
+
 #ifdef CONFIG_NETFILTER_NETLINK_QUEUE_CT
 static size_t
 ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
@@ -2440,6 +2589,79 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	return err;
 }
 
+static int
+ctnetlink_exp_stat_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int cpu,
+			     const struct ip_conntrack_stat *st)
+{
+	struct nlmsghdr *nlh;
+	struct nfgenmsg *nfmsg;
+	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
+
+	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_EXP_GET_STATS_CPU);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
+	if (nlh == NULL)
+		goto nlmsg_failure;
+
+	nfmsg = nlmsg_data(nlh);
+	nfmsg->nfgen_family = AF_UNSPEC;
+	nfmsg->version      = NFNETLINK_V0;
+	nfmsg->res_id	    = htons(cpu);
+
+	if (nla_put_be32(skb, CTA_STATS_EXP_NEW, htonl(st->expect_new)) ||
+	    nla_put_be32(skb, CTA_STATS_EXP_CREATE, htonl(st->expect_create)) ||
+	    nla_put_be32(skb, CTA_STATS_EXP_DELETE, htonl(st->expect_delete)))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return skb->len;
+
+nla_put_failure:
+nlmsg_failure:
+	nlmsg_cancel(skb, nlh);
+	return -1;
+}
+
+static int
+ctnetlink_exp_stat_cpu_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int cpu;
+	struct net *net = sock_net(skb->sk);
+
+	if (cb->args[0] == nr_cpu_ids)
+		return 0;
+
+	for (cpu = cb->args[0]; cpu < nr_cpu_ids; cpu++) {
+		const struct ip_conntrack_stat *st;
+
+		if (!cpu_possible(cpu))
+			continue;
+
+		st = per_cpu_ptr(net->ct.stat, cpu);
+		if (ctnetlink_exp_stat_fill_info(skb, NETLINK_CB(cb->skb).pid,
+						 cb->nlh->nlmsg_seq,
+						 cpu, st) < 0)
+			break;
+	}
+	cb->args[0] = cpu;
+
+	return skb->len;
+}
+
+static int
+ctnetlink_stat_exp_cpu(struct sock *ctnl, struct sk_buff *skb,
+		       const struct nlmsghdr *nlh,
+		       const struct nlattr * const cda[])
+{
+	if (nlh->nlmsg_flags & NLM_F_DUMP) {
+		struct netlink_dump_control c = {
+			.dump = ctnetlink_exp_stat_cpu_dump,
+		};
+		return netlink_dump_start(ctnl, skb, nlh, &c);
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 static struct nf_ct_event_notifier ctnl_notifier = {
 	.fcn = ctnetlink_conntrack_event,
@@ -2463,6 +2685,8 @@ static const struct nfnl_callback ctnl_cb[IPCTNL_MSG_MAX] = {
 	[IPCTNL_MSG_CT_GET_CTRZERO] 	= { .call = ctnetlink_get_conntrack,
 					    .attr_count = CTA_MAX,
 					    .policy = ct_nla_policy },
+	[IPCTNL_MSG_CT_GET_STATS_CPU]	= { .call = ctnetlink_stat_ct_cpu },
+	[IPCTNL_MSG_CT_GET_STATS]	= { .call = ctnetlink_stat_ct },
 };
 
 static const struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_EXP_MAX] = {
@@ -2475,6 +2699,7 @@ static const struct nfnl_callback ctnl_exp_cb[IPCTNL_MSG_EXP_MAX] = {
 	[IPCTNL_MSG_EXP_DELETE]		= { .call = ctnetlink_del_expect,
 					    .attr_count = CTA_EXPECT_MAX,
 					    .policy = exp_nla_policy },
+	[IPCTNL_MSG_EXP_GET_STATS_CPU]	= { .call = ctnetlink_stat_exp_cpu },
 };
 
 static const struct nfnetlink_subsystem ctnl_subsys = {
-- 
1.7.10
