From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 32/53] netfilter: allow early drop of assured conntracks
Date: Mon,  1 May 2017 12:46:59 +0200
Message-ID: <1493635640-24325-33-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

If insertion of a new conntrack fails because the table is full, the kernel
searches the next buckets of the hash slot where the new connection
was supposed to be inserted at for an entry that hasn't seen traffic
in reply direction (non-assured), if it finds one, that entry is
is dropped and the new connection entry is allocated.

Allow the conntrack gc worker to also remove *assured* conntracks if
resources are low.

Do this by querying the l4 tracker, e.g. tcp connections are now dropped
if they are no longer established (e.g. in finwait).

This could be refined further, e.g. by adding 'soft' established timeout
(i.e., a timeout that is only used once we get close to resource
exhaustion).

Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h |  3 ++
 net/netfilter/nf_conntrack_core.c            | 49 ++++++++++++++++++++++++++++
 net/netfilter/nf_conntrack_proto_dccp.c      | 16 +++++++++
 net/netfilter/nf_conntrack_proto_sctp.c      | 16 +++++++++
 net/netfilter/nf_conntrack_proto_tcp.c       | 18 ++++++++++
 5 files changed, 102 insertions(+)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 85e993e278d5..7032e044bbe2 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -58,6 +58,9 @@ struct nf_conntrack_l4proto {
 		     unsigned int dataoff,
 		     u_int8_t pf, unsigned int hooknum);
 
+	/* called by gc worker if table is full */
+	bool (*can_early_drop)(const struct nf_conn *ct);
+
 	/* Print out the per-protocol part of the tuple. Return like seq_* */
 	void (*print_tuple)(struct seq_file *s,
 			    const struct nf_conntrack_tuple *);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 62368b05cef5..f9245dbfe435 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -76,6 +76,7 @@ struct conntrack_gc_work {
 	struct delayed_work	dwork;
 	u32			last_bucket;
 	bool			exiting;
+	bool			early_drop;
 	long			next_gc_run;
 };
 
@@ -951,10 +952,30 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 	return false;
 }
 
+static bool gc_worker_skip_ct(const struct nf_conn *ct)
+{
+	return !nf_ct_is_confirmed(ct) || nf_ct_is_dying(ct);
+}
+
+static bool gc_worker_can_early_drop(const struct nf_conn *ct)
+{
+	const struct nf_conntrack_l4proto *l4proto;
+
+	if (!test_bit(IPS_ASSURED_BIT, &ct->status))
+		return true;
+
+	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	if (l4proto->can_early_drop && l4proto->can_early_drop(ct))
+		return true;
+
+	return false;
+}
+
 static void gc_worker(struct work_struct *work)
 {
 	unsigned int min_interval = max(HZ / GC_MAX_BUCKETS_DIV, 1u);
 	unsigned int i, goal, buckets = 0, expired_count = 0;
+	unsigned int nf_conntrack_max95 = 0;
 	struct conntrack_gc_work *gc_work;
 	unsigned int ratio, scanned = 0;
 	unsigned long next_run;
@@ -963,6 +984,8 @@ static void gc_worker(struct work_struct *work)
 
 	goal = nf_conntrack_htable_size / GC_MAX_BUCKETS_DIV;
 	i = gc_work->last_bucket;
+	if (gc_work->early_drop)
+		nf_conntrack_max95 = nf_conntrack_max / 100u * 95u;
 
 	do {
 		struct nf_conntrack_tuple_hash *h;
@@ -979,6 +1002,8 @@ static void gc_worker(struct work_struct *work)
 			i = 0;
 
 		hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[i], hnnode) {
+			struct net *net;
+
 			tmp = nf_ct_tuplehash_to_ctrack(h);
 
 			scanned++;
@@ -987,6 +1012,27 @@ static void gc_worker(struct work_struct *work)
 				expired_count++;
 				continue;
 			}
+
+			if (nf_conntrack_max95 == 0 || gc_worker_skip_ct(tmp))
+				continue;
+
+			net = nf_ct_net(tmp);
+			if (atomic_read(&net->ct.count) < nf_conntrack_max95)
+				continue;
+
+			/* need to take reference to avoid possible races */
+			if (!atomic_inc_not_zero(&tmp->ct_general.use))
+				continue;
+
+			if (gc_worker_skip_ct(tmp)) {
+				nf_ct_put(tmp);
+				continue;
+			}
+
+			if (gc_worker_can_early_drop(tmp))
+				nf_ct_kill(tmp);
+
+			nf_ct_put(tmp);
 		}
 
 		/* could check get_nulls_value() here and restart if ct
@@ -1032,6 +1078,7 @@ static void gc_worker(struct work_struct *work)
 
 	next_run = gc_work->next_gc_run;
 	gc_work->last_bucket = i;
+	gc_work->early_drop = false;
 	queue_delayed_work(system_long_wq, &gc_work->dwork, next_run);
 }
 
@@ -1057,6 +1104,8 @@ __nf_conntrack_alloc(struct net *net,
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
 		if (!early_drop(net, hash)) {
+			if (!conntrack_gc_work.early_drop)
+				conntrack_gc_work.early_drop = true;
 			atomic_dec(&net->ct.count);
 			net_warn_ratelimited("nf_conntrack: table full, dropping packet\n");
 			return ERR_PTR(-ENOMEM);
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 93dd1c5b7bff..4b3b6e1cadc9 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -609,6 +609,20 @@ static int dccp_error(struct net *net, struct nf_conn *tmpl,
 	return -NF_ACCEPT;
 }
 
+static bool dccp_can_early_drop(const struct nf_conn *ct)
+{
+	switch (ct->proto.dccp.state) {
+	case CT_DCCP_CLOSEREQ:
+	case CT_DCCP_CLOSING:
+	case CT_DCCP_TIMEWAIT:
+		return true;
+	default:
+		break;
+	}
+
+	return false;
+}
+
 static void dccp_print_tuple(struct seq_file *s,
 			     const struct nf_conntrack_tuple *tuple)
 {
@@ -868,6 +882,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4 __read_mostly = {
 	.packet			= dccp_packet,
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
+	.can_early_drop		= dccp_can_early_drop,
 	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
@@ -902,6 +917,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6 __read_mostly = {
 	.packet			= dccp_packet,
 	.get_timeouts		= dccp_get_timeouts,
 	.error			= dccp_error,
+	.can_early_drop		= dccp_can_early_drop,
 	.print_tuple		= dccp_print_tuple,
 	.print_conntrack	= dccp_print_conntrack,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 33279aab583d..b34b49c59a1c 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -535,6 +535,20 @@ static int sctp_error(struct net *net, struct nf_conn *tpl, struct sk_buff *skb,
 	return -NF_ACCEPT;
 }
 
+static bool sctp_can_early_drop(const struct nf_conn *ct)
+{
+	switch (ct->proto.sctp.state) {
+	case SCTP_CONNTRACK_SHUTDOWN_SENT:
+	case SCTP_CONNTRACK_SHUTDOWN_RECD:
+	case SCTP_CONNTRACK_SHUTDOWN_ACK_SENT:
+		return true;
+	default:
+		break;
+	}
+
+	return false;
+}
+
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
@@ -783,6 +797,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
 	.error			= sctp_error,
+	.can_early_drop		= sctp_can_early_drop,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
@@ -818,6 +833,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.get_timeouts		= sctp_get_timeouts,
 	.new 			= sctp_new,
 	.error			= sctp_error,
+	.can_early_drop		= sctp_can_early_drop,
 	.me 			= THIS_MODULE,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= sctp_to_nlattr,
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index b122e9dacfed..d0c0a31dfe74 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1172,6 +1172,22 @@ static bool tcp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
+static bool tcp_can_early_drop(const struct nf_conn *ct)
+{
+	switch (ct->proto.tcp.state) {
+	case TCP_CONNTRACK_FIN_WAIT:
+	case TCP_CONNTRACK_LAST_ACK:
+	case TCP_CONNTRACK_TIME_WAIT:
+	case TCP_CONNTRACK_CLOSE:
+	case TCP_CONNTRACK_CLOSE_WAIT:
+		return true;
+	default:
+		break;
+	}
+
+	return false;
+}
+
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
@@ -1549,6 +1565,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
 	.error			= tcp_error,
+	.can_early_drop		= tcp_can_early_drop,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= tcp_to_nlattr,
 	.nlattr_size		= tcp_nlattr_size,
@@ -1586,6 +1603,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 	.get_timeouts		= tcp_get_timeouts,
 	.new 			= tcp_new,
 	.error			= tcp_error,
+	.can_early_drop		= tcp_can_early_drop,
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.to_nlattr		= tcp_to_nlattr,
 	.nlattr_size		= tcp_nlattr_size,
-- 
2.1.4

