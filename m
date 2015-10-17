From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/35] netfilter: nfnetlink_log: allow to attach conntrack
Date: Sat, 17 Oct 2015 13:32:44 +0200
Message-ID: <1445081590-2924-10-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>

This patch enables to include the conntrack information together
with the packet that is sent to user-space via NFLOG, then a
user-space program can acquire NATed information by this NFULA_CT
attribute.

Including the conntrack information is optional, you can set it
via NFULNL_CFG_F_CONNTRACK flag with the NFULA_CFG_FLAGS attribute
like NFQUEUE.

Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nfnetlink_log.h |  3 +++
 net/netfilter/Kconfig                        |  9 ++++---
 net/netfilter/nfnetlink_log.c                | 37 ++++++++++++++++++++++++----
 3 files changed, 40 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/netfilter/nfnetlink_log.h b/include/uapi/linux/netfilter/nfnetlink_log.h
index 90c2c95..fb21f0c 100644
--- a/include/uapi/linux/netfilter/nfnetlink_log.h
+++ b/include/uapi/linux/netfilter/nfnetlink_log.h
@@ -51,6 +51,8 @@ enum nfulnl_attr_type {
 	NFULA_HWTYPE,			/* hardware type */
 	NFULA_HWHEADER,			/* hardware header */
 	NFULA_HWLEN,			/* hardware header length */
+	NFULA_CT,                       /* nf_conntrack_netlink.h */
+	NFULA_CT_INFO,                  /* enum ip_conntrack_info */
 
 	__NFULA_MAX
 };
@@ -93,5 +95,6 @@ enum nfulnl_attr_config {
 
 #define NFULNL_CFG_F_SEQ	0x0001
 #define NFULNL_CFG_F_SEQ_GLOBAL	0x0002
+#define NFULNL_CFG_F_CONNTRACK	0x0004
 
 #endif /* _NFNETLINK_LOG_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index d287818..e22349e 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -363,12 +363,13 @@ config NF_CT_NETLINK_HELPER
 	  If unsure, say `N'.
 
 config NETFILTER_NETLINK_GLUE_CT
-	bool "NFQUEUE integration with Connection Tracking"
+	bool "NFQUEUE and NFLOG integration with Connection Tracking"
 	default n
-	depends on NETFILTER_NETLINK_QUEUE && NF_CT_NETLINK
+	depends on (NETFILTER_NETLINK_QUEUE || NETFILTER_NETLINK_LOG) && NF_CT_NETLINK
 	help
-	  If this option is enabled, NFQUEUE can include Connection Tracking
-	  information together with the packet is the enqueued via NFNETLINK.
+	  If this option is enabled, NFQUEUE and NFLOG can include
+	  Connection Tracking information together with the packet is
+	  the enqueued via NFNETLINK.
 
 config NF_NAT
 	tristate
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4670821..e1d1187 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -27,6 +27,7 @@
 #include <net/netlink.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_log.h>
+#include <linux/netfilter/nf_conntrack_common.h>
 #include <linux/spinlock.h>
 #include <linux/sysctl.h>
 #include <linux/proc_fs.h>
@@ -401,7 +402,9 @@ __build_packet_message(struct nfnl_log_net *log,
 			unsigned int hooknum,
 			const struct net_device *indev,
 			const struct net_device *outdev,
-			const char *prefix, unsigned int plen)
+			const char *prefix, unsigned int plen,
+			const struct nfnl_ct_hook *nfnl_ct,
+			struct nf_conn *ct, enum ip_conntrack_info ctinfo)
 {
 	struct nfulnl_msg_packet_hdr pmsg;
 	struct nlmsghdr *nlh;
@@ -575,6 +578,10 @@ __build_packet_message(struct nfnl_log_net *log,
 			 htonl(atomic_inc_return(&log->global_seq))))
 		goto nla_put_failure;
 
+	if (ct && nfnl_ct->build(inst->skb, ct, ctinfo,
+				 NFULA_CT, NFULA_CT_INFO) < 0)
+		goto nla_put_failure;
+
 	if (data_len) {
 		struct nlattr *nla;
 		int size = nla_attr_size(data_len);
@@ -620,12 +627,16 @@ nfulnl_log_packet(struct net *net,
 		  const struct nf_loginfo *li_user,
 		  const char *prefix)
 {
-	unsigned int size, data_len;
+	size_t size;
+	unsigned int data_len;
 	struct nfulnl_instance *inst;
 	const struct nf_loginfo *li;
 	unsigned int qthreshold;
 	unsigned int plen;
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
+	const struct nfnl_ct_hook *nfnl_ct = NULL;
+	struct nf_conn *ct = NULL;
+	enum ip_conntrack_info uninitialized_var(ctinfo);
 
 	if (li_user && li_user->type == NF_LOG_TYPE_ULOG)
 		li = li_user;
@@ -671,6 +682,14 @@ nfulnl_log_packet(struct net *net,
 		size += nla_total_size(sizeof(u_int32_t));
 	if (inst->flags & NFULNL_CFG_F_SEQ_GLOBAL)
 		size += nla_total_size(sizeof(u_int32_t));
+	if (inst->flags & NFULNL_CFG_F_CONNTRACK) {
+		nfnl_ct = rcu_dereference(nfnl_ct_hook);
+		if (nfnl_ct != NULL) {
+			ct = nfnl_ct->get_ct(skb, &ctinfo);
+			if (ct != NULL)
+				size += nfnl_ct->build_size(ct);
+		}
+	}
 
 	qthreshold = inst->qthreshold;
 	/* per-rule qthreshold overrides per-instance */
@@ -715,7 +734,8 @@ nfulnl_log_packet(struct net *net,
 	inst->qlen++;
 
 	__build_packet_message(log, inst, skb, data_len, pf,
-				hooknum, in, out, prefix, plen);
+				hooknum, in, out, prefix, plen,
+				nfnl_ct, ct, ctinfo);
 
 	if (inst->qlen >= qthreshold)
 		__nfulnl_flush(inst);
@@ -899,13 +919,20 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	if (nfula[NFULA_CFG_FLAGS]) {
-		__be16 flags = nla_get_be16(nfula[NFULA_CFG_FLAGS]);
+		u16 flags = ntohs(nla_get_be16(nfula[NFULA_CFG_FLAGS]));
 
 		if (!inst) {
 			ret = -ENODEV;
 			goto out;
 		}
-		nfulnl_set_flags(inst, ntohs(flags));
+
+		if (flags & NFULNL_CFG_F_CONNTRACK &&
+		    rcu_access_pointer(nfnl_ct_hook) == NULL) {
+			ret = -EOPNOTSUPP;
+			goto out;
+		}
+
+		nfulnl_set_flags(inst, flags);
 	}
 
 out_put:
-- 
2.1.4

