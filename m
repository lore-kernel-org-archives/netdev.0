From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] netlink: Mark dumps as inconsistent which have been interrupted by a resize
Date: Tue, 20 Jan 2015 14:20:26 +0100
Message-ID: <cce004895ab6bcef267e2133a1c7ecab0fac403b.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
In-Reply-To: <cover.1421759056.git.tgraf@suug.ch>
References: <cover.1421759056.git.tgraf@suug.ch>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A deferred resize of nl_table causes the offsets that Netlink diag keeps
to become inaccurate. Mark the dump as inconsistent and have user space
request a new dump.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/af_netlink.c | 10 ++++++++++
 net/netlink/af_netlink.h |  1 +
 net/netlink/diag.c       |  1 +
 3 files changed, 12 insertions(+)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7a94185..e214557 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -91,6 +91,9 @@ static inline int netlink_is_kernel(struct sock *sk)
 struct netlink_table *nl_table;
 EXPORT_SYMBOL_GPL(nl_table);
 
+atomic_t nl_table_seq;
+EXPORT_SYMBOL_GPL(nl_table_seq);
+
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 
 static int netlink_dump(struct sock *sk);
@@ -3071,6 +3074,12 @@ static const struct net_proto_family netlink_family_ops = {
 	.owner	= THIS_MODULE,	/* for consistency 8) */
 };
 
+static void nl_table_resize_notify(const struct rhashtable *ht,
+				   enum rht_resize_op op)
+{
+	atomic_inc(&nl_table_seq);
+}
+
 static int __net_init netlink_net_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
@@ -3124,6 +3133,7 @@ static int __init netlink_proto_init(void)
 		.max_shift = 16, /* 64K */
 		.grow_decision = rht_grow_above_75,
 		.shrink_decision = rht_shrink_below_30,
+		.resize_notify = nl_table_resize_notify,
 	};
 
 	if (err != 0)
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 7518375..51c23c0 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -74,5 +74,6 @@ struct netlink_table {
 
 extern struct netlink_table *nl_table;
 extern rwlock_t nl_table_lock;
+extern atomic_t nl_table_seq;
 
 #endif
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index 3ee63a3..50aa385 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -112,6 +112,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	int ret = 0, num = 0, i;
 
 	req = nlmsg_data(cb->nlh);
+	cb->seq = atomic_read(&nl_table_seq);
 
 	for (i = 0; i < htbl->size; i++) {
 		struct rhash_head *pos;
-- 
1.9.3

