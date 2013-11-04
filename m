From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/20] netfilter: introduce nf_conn_acct structure
Date: Mon,  4 Nov 2013 22:50:41 +0100
Message-ID: <1383601842-4570-20-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55743 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832Ab3KDVvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:04 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>

Encapsulate counters for both directions into nf_conn_acct. During
that process also consistently name pointers to the extend 'acct',
not 'counters'. This patch is a cleanup.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_acct.h   |   10 +++++++---
 include/net/netfilter/nf_conntrack_extend.h |    2 +-
 net/netfilter/nf_conntrack_acct.c           |   12 +++++++-----
 net/netfilter/nf_conntrack_core.c           |   16 ++++++++++------
 net/netfilter/nf_conntrack_netlink.c        |   16 +++++++++-------
 net/netfilter/xt_connbytes.c                |    6 ++++--
 6 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_acct.h b/include/net/netfilter/nf_conntrack_acct.h
index fef44ed..79d8d16 100644
--- a/include/net/netfilter/nf_conntrack_acct.h
+++ b/include/net/netfilter/nf_conntrack_acct.h
@@ -19,17 +19,21 @@ struct nf_conn_counter {
 	atomic64_t bytes;
 };
 
+struct nf_conn_acct {
+	struct nf_conn_counter counter[IP_CT_DIR_MAX];
+};
+
 static inline
-struct nf_conn_counter *nf_conn_acct_find(const struct nf_conn *ct)
+struct nf_conn_acct *nf_conn_acct_find(const struct nf_conn *ct)
 {
 	return nf_ct_ext_find(ct, NF_CT_EXT_ACCT);
 }
 
 static inline
-struct nf_conn_counter *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
+struct nf_conn_acct *nf_ct_acct_ext_add(struct nf_conn *ct, gfp_t gfp)
 {
 	struct net *net = nf_ct_net(ct);
-	struct nf_conn_counter *acct;
+	struct nf_conn_acct *acct;
 
 	if (!net->ct.sysctl_acct)
 		return NULL;
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 86372ae..956b175 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -36,7 +36,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_HELPER_TYPE struct nf_conn_help
 #define NF_CT_EXT_NAT_TYPE struct nf_conn_nat
 #define NF_CT_EXT_SEQADJ_TYPE struct nf_conn_seqadj
-#define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
+#define NF_CT_EXT_ACCT_TYPE struct nf_conn_acct
 #define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
 #define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
 #define NF_CT_EXT_TSTAMP_TYPE struct nf_conn_tstamp
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 2d3030a..a4b5e2a 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -39,21 +39,23 @@ static struct ctl_table acct_sysctl_table[] = {
 unsigned int
 seq_print_acct(struct seq_file *s, const struct nf_conn *ct, int dir)
 {
-	struct nf_conn_counter *acct;
+	struct nf_conn_acct *acct;
+	struct nf_conn_counter *counter;
 
 	acct = nf_conn_acct_find(ct);
 	if (!acct)
 		return 0;
 
+	counter = acct->counter;
 	return seq_printf(s, "packets=%llu bytes=%llu ",
-			  (unsigned long long)atomic64_read(&acct[dir].packets),
-			  (unsigned long long)atomic64_read(&acct[dir].bytes));
+			  (unsigned long long)atomic64_read(&counter[dir].packets),
+			  (unsigned long long)atomic64_read(&counter[dir].bytes));
 };
 EXPORT_SYMBOL_GPL(seq_print_acct);
 
 static struct nf_ct_ext_type acct_extend __read_mostly = {
-	.len	= sizeof(struct nf_conn_counter[IP_CT_DIR_MAX]),
-	.align	= __alignof__(struct nf_conn_counter[IP_CT_DIR_MAX]),
+	.len	= sizeof(struct nf_conn_acct),
+	.align	= __alignof__(struct nf_conn_acct),
 	.id	= NF_CT_EXT_ACCT,
 };
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5d892fe..e22d950 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1109,12 +1109,14 @@ void __nf_ct_refresh_acct(struct nf_conn *ct,
 
 acct:
 	if (do_acct) {
-		struct nf_conn_counter *acct;
+		struct nf_conn_acct *acct;
 
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
-			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
-			atomic64_add(skb->len, &acct[CTINFO2DIR(ctinfo)].bytes);
+			struct nf_conn_counter *counter = acct->counter;
+
+			atomic64_inc(&counter[CTINFO2DIR(ctinfo)].packets);
+			atomic64_add(skb->len, &counter[CTINFO2DIR(ctinfo)].bytes);
 		}
 	}
 }
@@ -1126,13 +1128,15 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 		       int do_acct)
 {
 	if (do_acct) {
-		struct nf_conn_counter *acct;
+		struct nf_conn_acct *acct;
 
 		acct = nf_conn_acct_find(ct);
 		if (acct) {
-			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
+			struct nf_conn_counter *counter = acct->counter;
+
+			atomic64_inc(&counter[CTINFO2DIR(ctinfo)].packets);
 			atomic64_add(skb->len - skb_network_offset(skb),
-				     &acct[CTINFO2DIR(ctinfo)].bytes);
+				     &counter[CTINFO2DIR(ctinfo)].bytes);
 		}
 	}
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index eea936b..ddc3777 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -237,19 +237,21 @@ static int
 ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
 			enum ip_conntrack_dir dir, int type)
 {
-	struct nf_conn_counter *acct;
+	struct nf_conn_acct *acct;
+	struct nf_conn_counter *counter;
 	u64 pkts, bytes;
 
 	acct = nf_conn_acct_find(ct);
 	if (!acct)
 		return 0;
 
+	counter = acct->counter;
 	if (type == IPCTNL_MSG_CT_GET_CTRZERO) {
-		pkts = atomic64_xchg(&acct[dir].packets, 0);
-		bytes = atomic64_xchg(&acct[dir].bytes, 0);
+		pkts = atomic64_xchg(&counter[dir].packets, 0);
+		bytes = atomic64_xchg(&counter[dir].bytes, 0);
 	} else {
-		pkts = atomic64_read(&acct[dir].packets);
-		bytes = atomic64_read(&acct[dir].bytes);
+		pkts = atomic64_read(&counter[dir].packets);
+		bytes = atomic64_read(&counter[dir].bytes);
 	}
 	return dump_counters(skb, pkts, bytes, dir);
 }
@@ -530,7 +532,7 @@ ctnetlink_proto_size(const struct nf_conn *ct)
 }
 
 static inline size_t
-ctnetlink_counters_size(const struct nf_conn *ct)
+ctnetlink_acct_size(const struct nf_conn *ct)
 {
 	if (!nf_ct_ext_exist(ct, NF_CT_EXT_ACCT))
 		return 0;
@@ -579,7 +581,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + 3 * nla_total_size(sizeof(u_int8_t)) /* CTA_PROTO_NUM */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_ID */
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_STATUS */
-	       + ctnetlink_counters_size(ct)
+	       + ctnetlink_acct_size(ct)
 	       + ctnetlink_timestamp_size(ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_TIMEOUT */
 	       + nla_total_size(0) /* CTA_PROTOINFO */
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index e595e07..1e63461 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -26,16 +26,18 @@ connbytes_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	u_int64_t what = 0;	/* initialize to make gcc happy */
 	u_int64_t bytes = 0;
 	u_int64_t pkts = 0;
+	const struct nf_conn_acct *acct;
 	const struct nf_conn_counter *counters;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (!ct)
 		return false;
 
-	counters = nf_conn_acct_find(ct);
-	if (!counters)
+	acct = nf_conn_acct_find(ct);
+	if (!acct)
 		return false;
 
+	counters = acct->counter;
 	switch (sinfo->what) {
 	case XT_CONNBYTES_PKTS:
 		switch (sinfo->direction) {
-- 
1.7.10.4
