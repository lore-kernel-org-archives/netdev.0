From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 20/20] netfilter: ctnetlink: account both directions in one step
Date: Mon,  4 Nov 2013 22:50:42 +0100
Message-ID: <1383601842-4570-21-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55750 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837Ab3KDVvE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:04 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Holger Eitzenberger <holger@eitzenberger.org>

With the intent to dump other accounting data later.
This patch is a cleanup.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   49 +++++++++++++++++-----------------
 1 file changed, 24 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ddc3777..08870b8 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -211,13 +211,23 @@ nla_put_failure:
 }
 
 static int
-dump_counters(struct sk_buff *skb, u64 pkts, u64 bytes,
-	      enum ip_conntrack_dir dir)
+dump_counters(struct sk_buff *skb, struct nf_conn_acct *acct,
+	      enum ip_conntrack_dir dir, int type)
 {
-	enum ctattr_type type = dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
+	enum ctattr_type attr = dir ? CTA_COUNTERS_REPLY: CTA_COUNTERS_ORIG;
+	struct nf_conn_counter *counter = acct->counter;
 	struct nlattr *nest_count;
+	u64 pkts, bytes;
 
-	nest_count = nla_nest_start(skb, type | NLA_F_NESTED);
+	if (type == IPCTNL_MSG_CT_GET_CTRZERO) {
+		pkts = atomic64_xchg(&counter[dir].packets, 0);
+		bytes = atomic64_xchg(&counter[dir].bytes, 0);
+	} else {
+		pkts = atomic64_read(&counter[dir].packets);
+		bytes = atomic64_read(&counter[dir].bytes);
+	}
+
+	nest_count = nla_nest_start(skb, attr | NLA_F_NESTED);
 	if (!nest_count)
 		goto nla_put_failure;
 
@@ -234,26 +244,19 @@ nla_put_failure:
 }
 
 static int
-ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
-			enum ip_conntrack_dir dir, int type)
+ctnetlink_dump_acct(struct sk_buff *skb, const struct nf_conn *ct, int type)
 {
-	struct nf_conn_acct *acct;
-	struct nf_conn_counter *counter;
-	u64 pkts, bytes;
+	struct nf_conn_acct *acct = nf_conn_acct_find(ct);
 
-	acct = nf_conn_acct_find(ct);
 	if (!acct)
 		return 0;
 
-	counter = acct->counter;
-	if (type == IPCTNL_MSG_CT_GET_CTRZERO) {
-		pkts = atomic64_xchg(&counter[dir].packets, 0);
-		bytes = atomic64_xchg(&counter[dir].bytes, 0);
-	} else {
-		pkts = atomic64_read(&counter[dir].packets);
-		bytes = atomic64_read(&counter[dir].bytes);
-	}
-	return dump_counters(skb, pkts, bytes, dir);
+	if (dump_counters(skb, acct, IP_CT_DIR_ORIGINAL, type) < 0)
+		return -1;
+	if (dump_counters(skb, acct, IP_CT_DIR_REPLY, type) < 0)
+		return -1;
+
+	return 0;
 }
 
 static int
@@ -490,8 +493,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 
 	if (ctnetlink_dump_status(skb, ct) < 0 ||
 	    ctnetlink_dump_timeout(skb, ct) < 0 ||
-	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL, type) < 0 ||
-	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_REPLY, type) < 0 ||
+	    ctnetlink_dump_acct(skb, ct, type) < 0 ||
 	    ctnetlink_dump_timestamp(skb, ct) < 0 ||
 	    ctnetlink_dump_protoinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
@@ -675,10 +677,7 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto nla_put_failure;
 
 	if (events & (1 << IPCT_DESTROY)) {
-		if (ctnetlink_dump_counters(skb, ct,
-					    IP_CT_DIR_ORIGINAL, type) < 0 ||
-		    ctnetlink_dump_counters(skb, ct,
-					    IP_CT_DIR_REPLY, type) < 0 ||
+		if (ctnetlink_dump_acct(skb, ct, type) < 0 ||
 		    ctnetlink_dump_timestamp(skb, ct) < 0)
 			goto nla_put_failure;
 	} else {
-- 
1.7.10.4
