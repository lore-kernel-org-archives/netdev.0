From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: nfnetlink_queue: fix compilation with CONFIG_NF_NAT=m and CONFIG_NF_CT_NETLINK=y
Date: Sun, 24 Jun 2012 01:53:27 +0200
Message-ID: <1340495609-26250-3-git-send-email-pablo@netfilter.org>
References: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

  LD      init/built-in.o
net/built-in.o:(.data+0x4408): undefined reference to `nf_nat_tcp_seq_adjust'
make: *** [vmlinux] Error 1

This patch adds a new pointer hook (nfq_ct_nat_hook) similar to other existing
in Netfilter to solve our complicated configuration dependencies.

Reported-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h            |    6 +++++-
 net/ipv4/netfilter/nf_nat_core.c     |    6 ++++++
 net/netfilter/core.c                 |    3 +++
 net/netfilter/nf_conntrack_netlink.c |    3 ---
 net/netfilter/nfnetlink_queue_ct.c   |    8 ++++----
 5 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 38b96a5..c613cf0 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -401,10 +401,14 @@ struct nfq_ct_hook {
 	size_t (*build_size)(const struct nf_conn *ct);
 	int (*build)(struct sk_buff *skb, struct nf_conn *ct);
 	int (*parse)(const struct nlattr *attr, struct nf_conn *ct);
+};
+extern struct nfq_ct_hook __rcu *nfq_ct_hook;
+
+struct nfq_ct_nat_hook {
 	void (*seq_adjust)(struct sk_buff *skb, struct nf_conn *ct,
 			   u32 ctinfo, int off);
 };
-extern struct nfq_ct_hook __rcu *nfq_ct_hook;
+extern struct nfq_ct_nat_hook __rcu *nfq_ct_nat_hook;
 #else
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index abb52ad..44b082f 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -691,6 +691,10 @@ static struct nf_ct_helper_expectfn follow_master_nat = {
 	.expectfn	= nf_nat_follow_master,
 };
 
+static struct nfq_ct_nat_hook nfq_ct_nat = {
+	.seq_adjust	= nf_nat_tcp_seq_adjust,
+};
+
 static int __init nf_nat_init(void)
 {
 	size_t i;
@@ -731,6 +735,7 @@ static int __init nf_nat_init(void)
 			   nfnetlink_parse_nat_setup);
 	BUG_ON(nf_ct_nat_offset != NULL);
 	RCU_INIT_POINTER(nf_ct_nat_offset, nf_nat_get_offset);
+	RCU_INIT_POINTER(nfq_ct_nat_hook, &nfq_ct_nat);
 	return 0;
 
  cleanup_extend:
@@ -747,6 +752,7 @@ static void __exit nf_nat_cleanup(void)
 	RCU_INIT_POINTER(nf_nat_seq_adjust_hook, NULL);
 	RCU_INIT_POINTER(nfnetlink_parse_nat_setup_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
+	RCU_INIT_POINTER(nfq_ct_nat_hook, NULL);
 	synchronize_net();
 }
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 4cd10ed..0bc6b60 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -268,6 +268,9 @@ EXPORT_SYMBOL(nf_conntrack_destroy);
 struct nfq_ct_hook __rcu *nfq_ct_hook __read_mostly;
 EXPORT_SYMBOL_GPL(nfq_ct_hook);
 
+struct nfq_ct_nat_hook __rcu *nfq_ct_nat_hook __read_mostly;
+EXPORT_SYMBOL_GPL(nfq_ct_nat_hook);
+
 #endif /* CONFIG_NF_CONNTRACK */
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 31d1d8f..8bb4733 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1757,9 +1757,6 @@ static struct nfq_ct_hook ctnetlink_nfqueue_hook = {
 	.build_size	= ctnetlink_nfqueue_build_size,
 	.build		= ctnetlink_nfqueue_build,
 	.parse		= ctnetlink_nfqueue_parse,
-#ifdef CONFIG_NF_NAT_NEEDED
-	.seq_adjust	= nf_nat_tcp_seq_adjust,
-#endif
 };
 #endif /* CONFIG_NETFILTER_NETLINK_QUEUE_CT */
 
diff --git a/net/netfilter/nfnetlink_queue_ct.c b/net/netfilter/nfnetlink_queue_ct.c
index 68ef550..01247b7 100644
--- a/net/netfilter/nfnetlink_queue_ct.c
+++ b/net/netfilter/nfnetlink_queue_ct.c
@@ -86,12 +86,12 @@ nla_put_failure:
 void nfqnl_ct_seq_adjust(struct sk_buff *skb, struct nf_conn *ct,
 			 enum ip_conntrack_info ctinfo, int diff)
 {
-	struct nfq_ct_hook *nfq_ct;
+	struct nfq_ct_nat_hook *nfq_nat_ct;
 
-	nfq_ct = rcu_dereference(nfq_ct_hook);
-	if (nfq_ct == NULL)
+	nfq_nat_ct = rcu_dereference(nfq_ct_nat_hook);
+	if (nfq_nat_ct == NULL)
 		return;
 
 	if ((ct->status & IPS_NAT_MASK) && diff)
-		nfq_ct->seq_adjust(skb, ct, ctinfo, diff);
+		nfq_nat_ct->seq_adjust(skb, ct, ctinfo, diff);
 }
-- 
1.7.10

