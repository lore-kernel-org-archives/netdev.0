From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v3 1/3] tcp: add generic netlink support for tcp_metrics
Date: Wed,  5 Sep 2012 00:03:15 +0300
Message-ID: <1346792597-2427-2-git-send-email-ja@ssi.bg>
References: <1346792597-2427-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34424 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757683Ab2IDVAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 17:00:24 -0400
In-Reply-To: <1346792597-2427-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Add support for genl "tcp_metrics". No locking
is changed, only that now we can unlink and delete
entries after grace period. We implement get/del for
single entry and dump to support show/flush filtering
in user space. Del without address attribute causes
flush for all addresses, sadly under genl_mutex.

v2:
- remove rcu_assign_pointer as suggested by Eric Dumazet,
it is not needed because there are no other writes under lock
- move the flushing code in tcp_metrics_flush_all

v3:
- remove synchronize_rcu on flush as suggested by Eric Dumazet

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/linux/Kbuild        |    1 +
 include/linux/tcp_metrics.h |   54 +++++++
 net/ipv4/tcp_metrics.c      |  354 +++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 396 insertions(+), 13 deletions(-)
 create mode 100644 include/linux/tcp_metrics.h

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 1f2c1c7..90da0af 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -363,6 +363,7 @@ header-y += sysctl.h
 header-y += sysinfo.h
 header-y += taskstats.h
 header-y += tcp.h
+header-y += tcp_metrics.h
 header-y += telephony.h
 header-y += termios.h
 header-y += time.h
diff --git a/include/linux/tcp_metrics.h b/include/linux/tcp_metrics.h
new file mode 100644
index 0000000..cb5157b
--- /dev/null
+++ b/include/linux/tcp_metrics.h
@@ -0,0 +1,54 @@
+/* tcp_metrics.h - TCP Metrics Interface */
+
+#ifndef _LINUX_TCP_METRICS_H
+#define _LINUX_TCP_METRICS_H
+
+#include <linux/types.h>
+
+/* NETLINK_GENERIC related info
+ */
+#define TCP_METRICS_GENL_NAME		"tcp_metrics"
+#define TCP_METRICS_GENL_VERSION	0x1
+
+enum tcp_metric_index {
+	TCP_METRIC_RTT,
+	TCP_METRIC_RTTVAR,
+	TCP_METRIC_SSTHRESH,
+	TCP_METRIC_CWND,
+	TCP_METRIC_REORDERING,
+
+	/* Always last.  */
+	__TCP_METRIC_MAX,
+};
+
+#define TCP_METRIC_MAX	(__TCP_METRIC_MAX - 1)
+
+enum {
+	TCP_METRICS_ATTR_UNSPEC,
+	TCP_METRICS_ATTR_ADDR_IPV4,		/* u32 */
+	TCP_METRICS_ATTR_ADDR_IPV6,		/* binary */
+	TCP_METRICS_ATTR_AGE,			/* msecs */
+	TCP_METRICS_ATTR_TW_TSVAL,		/* u32, raw, rcv tsval */
+	TCP_METRICS_ATTR_TW_TS_STAMP,		/* s32, sec age */
+	TCP_METRICS_ATTR_VALS,			/* nested +1, u32 */
+	TCP_METRICS_ATTR_FOPEN_MSS,		/* u16 */
+	TCP_METRICS_ATTR_FOPEN_SYN_DROPS,	/* u16, count of drops */
+	TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS,	/* msecs age */
+	TCP_METRICS_ATTR_FOPEN_COOKIE,		/* binary */
+
+	__TCP_METRICS_ATTR_MAX,
+};
+
+#define TCP_METRICS_ATTR_MAX	(__TCP_METRICS_ATTR_MAX - 1)
+
+enum {
+	TCP_METRICS_CMD_UNSPEC,
+	TCP_METRICS_CMD_GET,
+	TCP_METRICS_CMD_DEL,
+
+	__TCP_METRICS_CMD_MAX,
+};
+
+#define TCP_METRICS_CMD_MAX	(__TCP_METRICS_CMD_MAX - 1)
+
+#endif /* _LINUX_TCP_METRICS_H */
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
index 0abe67b..988edb6 100644
--- a/net/ipv4/tcp_metrics.c
+++ b/net/ipv4/tcp_metrics.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/tcp.h>
 #include <linux/hash.h>
+#include <linux/tcp_metrics.h>
 
 #include <net/inet_connection_sock.h>
 #include <net/net_namespace.h>
@@ -17,20 +18,10 @@
 #include <net/ipv6.h>
 #include <net/dst.h>
 #include <net/tcp.h>
+#include <net/genetlink.h>
 
 int sysctl_tcp_nometrics_save __read_mostly;
 
-enum tcp_metric_index {
-	TCP_METRIC_RTT,
-	TCP_METRIC_RTTVAR,
-	TCP_METRIC_SSTHRESH,
-	TCP_METRIC_CWND,
-	TCP_METRIC_REORDERING,
-
-	/* Always last.  */
-	TCP_METRIC_MAX,
-};
-
 struct tcp_fastopen_metrics {
 	u16	mss;
 	u16	syn_loss:10;		/* Recurring Fast Open SYN losses */
@@ -45,8 +36,10 @@ struct tcp_metrics_block {
 	u32				tcpm_ts;
 	u32				tcpm_ts_stamp;
 	u32				tcpm_lock;
-	u32				tcpm_vals[TCP_METRIC_MAX];
+	u32				tcpm_vals[TCP_METRIC_MAX + 1];
 	struct tcp_fastopen_metrics	tcpm_fastopen;
+
+	struct rcu_head			rcu_head;
 };
 
 static bool tcp_metric_locked(struct tcp_metrics_block *tm,
@@ -690,6 +683,325 @@ void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
 	rcu_read_unlock();
 }
 
+static struct genl_family tcp_metrics_nl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= TCP_METRICS_GENL_NAME,
+	.version	= TCP_METRICS_GENL_VERSION,
+	.maxattr	= TCP_METRICS_ATTR_MAX,
+	.netnsok	= true,
+};
+
+static struct nla_policy tcp_metrics_nl_policy[TCP_METRICS_ATTR_MAX + 1] = {
+	[TCP_METRICS_ATTR_ADDR_IPV4]	= { .type = NLA_U32, },
+	[TCP_METRICS_ATTR_ADDR_IPV6]	= { .type = NLA_BINARY,
+					    .len = sizeof(struct in6_addr), },
+	/* Following attributes are not received for GET/DEL,
+	 * we keep them for reference
+	 */
+#if 0
+	[TCP_METRICS_ATTR_AGE]		= { .type = NLA_MSECS, },
+	[TCP_METRICS_ATTR_TW_TSVAL]	= { .type = NLA_U32, },
+	[TCP_METRICS_ATTR_TW_TS_STAMP]	= { .type = NLA_S32, },
+	[TCP_METRICS_ATTR_VALS]		= { .type = NLA_NESTED, },
+	[TCP_METRICS_ATTR_FOPEN_MSS]	= { .type = NLA_U16, },
+	[TCP_METRICS_ATTR_FOPEN_SYN_DROPS]	= { .type = NLA_U16, },
+	[TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS]	= { .type = NLA_MSECS, },
+	[TCP_METRICS_ATTR_FOPEN_COOKIE]	= { .type = NLA_BINARY,
+					    .len = TCP_FASTOPEN_COOKIE_MAX, },
+#endif
+};
+
+/* Add attributes, caller cancels its header on failure */
+static int tcp_metrics_fill_info(struct sk_buff *msg,
+				 struct tcp_metrics_block *tm)
+{
+	struct nlattr *nest;
+	int i;
+
+	switch (tm->tcpm_addr.family) {
+	case AF_INET:
+		if (nla_put_be32(msg, TCP_METRICS_ATTR_ADDR_IPV4,
+				tm->tcpm_addr.addr.a4) < 0)
+			goto nla_put_failure;
+		break;
+	case AF_INET6:
+		if (nla_put(msg, TCP_METRICS_ATTR_ADDR_IPV6, 16,
+			    tm->tcpm_addr.addr.a6) < 0)
+			goto nla_put_failure;
+		break;
+	default:
+		return -EAFNOSUPPORT;
+	}
+
+	if (nla_put_msecs(msg, TCP_METRICS_ATTR_AGE,
+			  jiffies - tm->tcpm_stamp) < 0)
+		goto nla_put_failure;
+	if (tm->tcpm_ts_stamp) {
+		if (nla_put_s32(msg, TCP_METRICS_ATTR_TW_TS_STAMP,
+				(s32) (get_seconds() - tm->tcpm_ts_stamp)) < 0)
+			goto nla_put_failure;
+		if (nla_put_u32(msg, TCP_METRICS_ATTR_TW_TSVAL,
+				tm->tcpm_ts) < 0)
+			goto nla_put_failure;
+	}
+
+	{
+		int n = 0;
+
+		nest = nla_nest_start(msg, TCP_METRICS_ATTR_VALS);
+		if (!nest)
+			goto nla_put_failure;
+		for (i = 0; i < TCP_METRIC_MAX + 1; i++) {
+			if (!tm->tcpm_vals[i])
+				continue;
+			if (nla_put_u32(msg, i + 1, tm->tcpm_vals[i]) < 0)
+				goto nla_put_failure;
+			n++;
+		}
+		if (n)
+			nla_nest_end(msg, nest);
+		else
+			nla_nest_cancel(msg, nest);
+	}
+
+	{
+		struct tcp_fastopen_metrics tfom_copy[1], *tfom;
+		unsigned int seq;
+
+		do {
+			seq = read_seqbegin(&fastopen_seqlock);
+			tfom_copy[0] = tm->tcpm_fastopen;
+		} while (read_seqretry(&fastopen_seqlock, seq));
+
+		tfom = tfom_copy;
+		if (tfom->mss &&
+		    nla_put_u16(msg, TCP_METRICS_ATTR_FOPEN_MSS,
+				tfom->mss) < 0)
+			goto nla_put_failure;
+		if (tfom->syn_loss &&
+		    (nla_put_u16(msg, TCP_METRICS_ATTR_FOPEN_SYN_DROPS,
+				tfom->syn_loss) < 0 ||
+		     nla_put_msecs(msg, TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS,
+				jiffies - tfom->last_syn_loss) < 0))
+			goto nla_put_failure;
+		if (tfom->cookie.len > 0 &&
+		    nla_put(msg, TCP_METRICS_ATTR_FOPEN_COOKIE,
+			    tfom->cookie.len, tfom->cookie.val) < 0)
+			goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int tcp_metrics_dump_info(struct sk_buff *skb,
+				 struct netlink_callback *cb,
+				 struct tcp_metrics_block *tm)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
+			  &tcp_metrics_nl_family, NLM_F_MULTI,
+			  TCP_METRICS_CMD_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (tcp_metrics_fill_info(skb, tm) < 0)
+		goto nla_put_failure;
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+
+static int tcp_metrics_nl_dump(struct sk_buff *skb,
+			       struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
+	unsigned int row, s_row = cb->args[0];
+	int s_col = cb->args[1], col = s_col;
+
+	for (row = s_row; row < max_rows; row++, s_col = 0) {
+		struct tcp_metrics_block *tm;
+		struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash + row;
+
+		rcu_read_lock();
+		for (col = 0, tm = rcu_dereference(hb->chain); tm;
+		     tm = rcu_dereference(tm->tcpm_next), col++) {
+			if (col < s_col)
+				continue;
+			if (tcp_metrics_dump_info(skb, cb, tm) < 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+		}
+		rcu_read_unlock();
+	}
+
+done:
+	cb->args[0] = row;
+	cb->args[1] = col;
+	return skb->len;
+}
+
+static int parse_nl_addr(struct genl_info *info, struct inetpeer_addr *addr,
+			 unsigned int *hash, int optional)
+{
+	struct nlattr *a;
+
+	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV4];
+	if (a) {
+		addr->family = AF_INET;
+		addr->addr.a4 = nla_get_be32(a);
+		*hash = (__force unsigned int) addr->addr.a4;
+		return 0;
+	}
+	a = info->attrs[TCP_METRICS_ATTR_ADDR_IPV6];
+	if (a) {
+		if (nla_len(a) != sizeof(sizeof(struct in6_addr)))
+			return -EINVAL;
+		addr->family = AF_INET6;
+		memcpy(addr->addr.a6, nla_data(a), sizeof(addr->addr.a6));
+		*hash = ipv6_addr_hash((struct in6_addr *) addr->addr.a6);
+		return 0;
+	}
+	return optional ? 1 : -EAFNOSUPPORT;
+}
+
+static int tcp_metrics_nl_cmd_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct tcp_metrics_block *tm;
+	struct inetpeer_addr addr;
+	unsigned int hash;
+	struct sk_buff *msg;
+	struct net *net = genl_info_net(info);
+	void *reply;
+	int ret;
+
+	ret = parse_nl_addr(info, &addr, &hash, 0);
+	if (ret < 0)
+		return ret;
+
+	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!msg)
+		return -ENOMEM;
+
+	reply = genlmsg_put_reply(msg, info, &tcp_metrics_nl_family, 0,
+				  info->genlhdr->cmd);
+	if (!reply)
+		goto nla_put_failure;
+
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	ret = -ESRCH;
+	rcu_read_lock();
+	for (tm = rcu_dereference(net->ipv4.tcp_metrics_hash[hash].chain); tm;
+	     tm = rcu_dereference(tm->tcpm_next)) {
+		if (addr_same(&tm->tcpm_addr, &addr)) {
+			ret = tcp_metrics_fill_info(msg, tm);
+			break;
+		}
+	}
+	rcu_read_unlock();
+	if (ret < 0)
+		goto out_free;
+
+	genlmsg_end(msg, reply);
+	return genlmsg_reply(msg, info);
+
+nla_put_failure:
+	ret = -EMSGSIZE;
+
+out_free:
+	nlmsg_free(msg);
+	return ret;
+}
+
+#define deref_locked_genl(p)	\
+	rcu_dereference_protected(p, lockdep_genl_is_held() && \
+				     lockdep_is_held(&tcp_metrics_lock))
+
+#define deref_genl(p)	rcu_dereference_protected(p, lockdep_genl_is_held())
+
+static int tcp_metrics_flush_all(struct net *net)
+{
+	unsigned int max_rows = 1U << net->ipv4.tcp_metrics_hash_log;
+	struct tcpm_hash_bucket *hb = net->ipv4.tcp_metrics_hash;
+	struct tcp_metrics_block *tm;
+	unsigned int row;
+
+	for (row = 0; row < max_rows; row++, hb++) {
+		spin_lock_bh(&tcp_metrics_lock);
+		tm = deref_locked_genl(hb->chain);
+		if (tm)
+			hb->chain = NULL;
+		spin_unlock_bh(&tcp_metrics_lock);
+		while (tm) {
+			struct tcp_metrics_block *next;
+
+			next = deref_genl(tm->tcpm_next);
+			kfree_rcu(tm, rcu_head);
+			tm = next;
+		}
+	}
+	return 0;
+}
+
+static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
+{
+	struct tcpm_hash_bucket *hb;
+	struct tcp_metrics_block *tm;
+	struct tcp_metrics_block __rcu **pp;
+	struct inetpeer_addr addr;
+	unsigned int hash;
+	struct net *net = genl_info_net(info);
+	int ret;
+
+	ret = parse_nl_addr(info, &addr, &hash, 1);
+	if (ret < 0)
+		return ret;
+	if (ret > 0)
+		return tcp_metrics_flush_all(net);
+
+	hash = hash_32(hash, net->ipv4.tcp_metrics_hash_log);
+	hb = net->ipv4.tcp_metrics_hash + hash;
+	pp = &hb->chain;
+	spin_lock_bh(&tcp_metrics_lock);
+	for (tm = deref_locked_genl(*pp); tm;
+	     pp = &tm->tcpm_next, tm = deref_locked_genl(*pp)) {
+		if (addr_same(&tm->tcpm_addr, &addr)) {
+			*pp = tm->tcpm_next;
+			break;
+		}
+	}
+	spin_unlock_bh(&tcp_metrics_lock);
+	if (!tm)
+		return -ESRCH;
+	kfree_rcu(tm, rcu_head);
+	return 0;
+}
+
+static struct genl_ops tcp_metrics_nl_ops[] = {
+	{
+		.cmd = TCP_METRICS_CMD_GET,
+		.doit = tcp_metrics_nl_cmd_get,
+		.dumpit = tcp_metrics_nl_dump,
+		.policy = tcp_metrics_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+	{
+		.cmd = TCP_METRICS_CMD_DEL,
+		.doit = tcp_metrics_nl_cmd_del,
+		.policy = tcp_metrics_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+	},
+};
+
 static unsigned int tcpmhash_entries;
 static int __init set_tcpmhash_entries(char *str)
 {
@@ -753,5 +1065,21 @@ static __net_initdata struct pernet_operations tcp_net_metrics_ops = {
 
 void __init tcp_metrics_init(void)
 {
-	register_pernet_subsys(&tcp_net_metrics_ops);
+	int ret;
+
+	ret = register_pernet_subsys(&tcp_net_metrics_ops);
+	if (ret < 0)
+		goto cleanup;
+	ret = genl_register_family_with_ops(&tcp_metrics_nl_family,
+					    tcp_metrics_nl_ops,
+					    ARRAY_SIZE(tcp_metrics_nl_ops));
+	if (ret < 0)
+		goto cleanup_subsys;
+	return;
+
+cleanup_subsys:
+	unregister_pernet_subsys(&tcp_net_metrics_ops);
+
+cleanup:
+	return;
 }
-- 
1.7.3.4
