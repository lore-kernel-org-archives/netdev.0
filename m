From: pablo@netfilter.org
Subject: [PATCH 17/19] netfilter: ctnetlink: get and zero operations must be atomic
Date: Sun, 25 Dec 2011 02:57:33 +0100
Message-ID: <1324778255-2830-18-git-send-email-pablo@netfilter.org>
References: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1324778255-2830-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

The get and zero operations have to be done in an atomic context,
otherwise counters added between them will be lost.

This problem was spotted by Changli Gao while discussing the
nfacct infrastructure.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   84 ++++++++++++++++------------------
 1 files changed, 39 insertions(+), 45 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 4f9c941..8503334 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -203,25 +203,18 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
-			enum ip_conntrack_dir dir)
+dump_counters(struct sk_buff *skb, u64 pkts, u64 bytes,
+	      enum ip_conntrack_dir dir)
 {
 	enum ctattr_type type = dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
 	struct nlattr *nest_count;
-	const struct nf_conn_counter *acct;
-
-	acct = nf_conn_acct_find(ct);
-	if (!acct)
-		return 0;
 
 	nest_count = nla_nest_start(skb, type | NLA_F_NESTED);
 	if (!nest_count)
 		goto nla_put_failure;
 
-	NLA_PUT_BE64(skb, CTA_COUNTERS_PACKETS,
-		     cpu_to_be64(atomic64_read(&acct[dir].packets)));
-	NLA_PUT_BE64(skb, CTA_COUNTERS_BYTES,
-		     cpu_to_be64(atomic64_read(&acct[dir].bytes)));
+	NLA_PUT_BE64(skb, CTA_COUNTERS_PACKETS, cpu_to_be64(pkts));
+	NLA_PUT_BE64(skb, CTA_COUNTERS_BYTES, cpu_to_be64(bytes));
 
 	nla_nest_end(skb, nest_count);
 
@@ -232,6 +225,27 @@ nla_put_failure:
 }
 
 static int
+ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
+			enum ip_conntrack_dir dir, int type)
+{
+	struct nf_conn_counter *acct;
+	u64 pkts, bytes;
+
+	acct = nf_conn_acct_find(ct);
+	if (!acct)
+		return 0;
+
+	if (type == IPCTNL_MSG_CT_GET_CTRZERO) {
+		pkts = atomic64_xchg(&acct[dir].packets, 0);
+		bytes = atomic64_xchg(&acct[dir].bytes, 0);
+	} else {
+		pkts = atomic64_read(&acct[dir].packets);
+		bytes = atomic64_read(&acct[dir].bytes);
+	}
+	return dump_counters(skb, pkts, bytes, dir);
+}
+
+static int
 ctnetlink_dump_timestamp(struct sk_buff *skb, const struct nf_conn *ct)
 {
 	struct nlattr *nest_count;
@@ -393,15 +407,15 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
-		    int event, struct nf_conn *ct)
+ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
+		    struct nf_conn *ct)
 {
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
-	unsigned int flags = pid ? NLM_F_MULTI : 0;
+	unsigned int flags = pid ? NLM_F_MULTI : 0, event;
 
-	event |= NFNL_SUBSYS_CTNETLINK << 8;
+	event = (NFNL_SUBSYS_CTNETLINK << 8 | IPCTNL_MSG_CT_NEW);
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -430,8 +444,8 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 
 	if (ctnetlink_dump_status(skb, ct) < 0 ||
 	    ctnetlink_dump_timeout(skb, ct) < 0 ||
-	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
-	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0 ||
+	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL, type) < 0 ||
+	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY, type) < 0 ||
 	    ctnetlink_dump_timestamp(skb, ct) < 0 ||
 	    ctnetlink_dump_protoinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
@@ -612,8 +626,10 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto nla_put_failure;
 
 	if (events & (1 << IPCT_DESTROY)) {
-		if (ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
-		    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY) < 0 ||
+		if (ctnetlink_dump_counters(skb, ct,
+					    IP_CT_DIR_ORIGINAL, type) < 0 ||
+		    ctnetlink_dump_counters(skb, ct,
+					    IP_CT_DIR_REPLY, type) < 0 ||
 		    ctnetlink_dump_timestamp(skb, ct) < 0)
 			goto nla_put_failure;
 	} else {
@@ -709,24 +725,13 @@ restart:
 			}
 			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
 						cb->nlh->nlmsg_seq,
-						IPCTNL_MSG_CT_NEW, ct) < 0) {
+						NFNL_MSG_TYPE(
+							cb->nlh->nlmsg_type),
+						ct) < 0) {
 				nf_conntrack_get(&ct->ct_general);
 				cb->args[1] = (unsigned long)ct;
 				goto out;
 			}
-
-			if (NFNL_MSG_TYPE(cb->nlh->nlmsg_type) ==
-						IPCTNL_MSG_CT_GET_CTRZERO) {
-				struct nf_conn_counter *acct;
-
-				acct = nf_conn_acct_find(ct);
-				if (acct) {
-					atomic64_set(&acct[IP_CT_DIR_ORIGINAL].bytes, 0);
-					atomic64_set(&acct[IP_CT_DIR_ORIGINAL].packets, 0);
-					atomic64_set(&acct[IP_CT_DIR_REPLY].bytes, 0);
-					atomic64_set(&acct[IP_CT_DIR_REPLY].packets, 0);
-					}
-			}
 		}
 		if (cb->args[1]) {
 			cb->args[1] = 0;
@@ -1005,7 +1010,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	rcu_read_lock();
 	err = ctnetlink_fill_info(skb2, NETLINK_CB(skb).pid, nlh->nlmsg_seq,
-				  IPCTNL_MSG_CT_NEW, ct);
+				  NFNL_MSG_TYPE(nlh->nlmsg_type), ct);
 	rcu_read_unlock();
 	nf_ct_put(ct);
 	if (err <= 0)
@@ -1015,17 +1020,6 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		goto out;
 
-	if (NFNL_MSG_TYPE(nlh->nlmsg_type) == IPCTNL_MSG_CT_GET_CTRZERO) {
-		struct nf_conn_counter *acct;
-
-		acct = nf_conn_acct_find(ct);
-		if (acct) {
-			atomic64_set(&acct[IP_CT_DIR_ORIGINAL].bytes, 0);
-			atomic64_set(&acct[IP_CT_DIR_ORIGINAL].packets, 0);
-			atomic64_set(&acct[IP_CT_DIR_REPLY].bytes, 0);
-			atomic64_set(&acct[IP_CT_DIR_REPLY].packets, 0);
-		}
-	}
 	return 0;
 
 free:
-- 
1.7.2.5

