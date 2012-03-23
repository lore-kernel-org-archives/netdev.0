From: pablo@netfilter.org
Subject: [PATCH 2/5] netfilter: cttimeout: fix dependency with l4protocol conntrack module
Date: Fri, 23 Mar 2012 10:34:14 +0100
Message-ID: <1332495257-3149-3-git-send-email-pablo@netfilter.org>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch introduces nf_conntrack_l4proto_find_get() and
nf_conntrack_l4proto_put() to fix module dependencies between
timeout objects and l4-protocol conntrack modules.

Thus, we make sure that the module cannot be removed if it is
used by any of the cttimeout objects.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    4 ++
 include/net/netfilter/nf_conntrack_timeout.h |    2 +-
 net/netfilter/nf_conntrack_proto.c           |   21 ++++++++++++
 net/netfilter/nfnetlink_cttimeout.c          |   45 +++++++++++++------------
 net/netfilter/xt_CT.c                        |    6 ++-
 5 files changed, 53 insertions(+), 25 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 90c67c7..3b572bb 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -118,6 +118,10 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 extern struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto);
 
+extern struct nf_conntrack_l4proto *
+nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
+extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
+
 /* Protocol registration. */
 extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
 extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
diff --git a/include/net/netfilter/nf_conntrack_timeout.h b/include/net/netfilter/nf_conntrack_timeout.h
index 0e04db4..34ec89f 100644
--- a/include/net/netfilter/nf_conntrack_timeout.h
+++ b/include/net/netfilter/nf_conntrack_timeout.h
@@ -15,7 +15,7 @@ struct ctnl_timeout {
 	atomic_t		refcnt;
 	char			name[CTNL_TIMEOUT_NAME_MAX];
 	__u16			l3num;
-	__u8			l4num;
+	struct nf_conntrack_l4proto *l4proto;
 	char			data[0];
 };
 
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 5701c8d..be3da2c 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -127,6 +127,27 @@ void nf_ct_l3proto_module_put(unsigned short l3proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_module_put);
 
+struct nf_conntrack_l4proto *
+nf_ct_l4proto_find_get(u_int16_t l3num, u_int8_t l4num)
+{
+	struct nf_conntrack_l4proto *p;
+
+	rcu_read_lock();
+	p = __nf_ct_l4proto_find(l3num, l4num);
+	if (!try_module_get(p->me))
+		p = &nf_conntrack_l4proto_generic;
+	rcu_read_unlock();
+
+	return p;
+}
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_find_get);
+
+void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p)
+{
+	module_put(p->me);
+}
+EXPORT_SYMBOL_GPL(nf_ct_l4proto_put);
+
 static int kill_l3proto(struct nf_conn *i, void *data)
 {
 	return nf_ct_l3num(i) == ((struct nf_conntrack_l3proto *)data)->l3proto;
diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index fec29a4..2b9e79f 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -98,11 +98,13 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 		break;
 	}
 
-	l4proto = __nf_ct_l4proto_find(l3num, l4num);
+	l4proto = nf_ct_l4proto_find_get(l3num, l4num);
 
 	/* This protocol is not supportted, skip. */
-	if (l4proto->l4proto != l4num)
-		return -EOPNOTSUPP;
+	if (l4proto->l4proto != l4num) {
+		ret = -EOPNOTSUPP;
+		goto err_proto_put;
+	}
 
 	if (matching) {
 		if (nlh->nlmsg_flags & NLM_F_REPLACE) {
@@ -110,20 +112,25 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 			 * different kind, sorry.
 			 */
 			if (matching->l3num != l3num ||
-			    matching->l4num != l4num)
-				return -EINVAL;
+			    matching->l4proto->l4proto != l4num) {
+				ret = -EINVAL;
+				goto err_proto_put;
+			}
 
 			ret = ctnl_timeout_parse_policy(matching, l4proto,
 							cda[CTA_TIMEOUT_DATA]);
 			return ret;
 		}
-		return -EBUSY;
+		ret = -EBUSY;
+		goto err_proto_put;
 	}
 
 	timeout = kzalloc(sizeof(struct ctnl_timeout) +
 			  l4proto->ctnl_timeout.obj_size, GFP_KERNEL);
-	if (timeout == NULL)
-		return -ENOMEM;
+	if (timeout == NULL) {
+		ret = -ENOMEM;
+		goto err_proto_put;
+	}
 
 	ret = ctnl_timeout_parse_policy(timeout, l4proto,
 					cda[CTA_TIMEOUT_DATA]);
@@ -132,13 +139,15 @@ cttimeout_new_timeout(struct sock *ctnl, struct sk_buff *skb,
 
 	strcpy(timeout->name, nla_data(cda[CTA_TIMEOUT_NAME]));
 	timeout->l3num = l3num;
-	timeout->l4num = l4num;
+	timeout->l4proto = l4proto;
 	atomic_set(&timeout->refcnt, 1);
 	list_add_tail_rcu(&timeout->head, &cttimeout_list);
 
 	return 0;
 err:
 	kfree(timeout);
+err_proto_put:
+	nf_ct_l4proto_put(l4proto);
 	return ret;
 }
 
@@ -149,7 +158,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	unsigned int flags = pid ? NLM_F_MULTI : 0;
-	struct nf_conntrack_l4proto *l4proto;
+	struct nf_conntrack_l4proto *l4proto = timeout->l4proto;
 
 	event |= NFNL_SUBSYS_CTNETLINK_TIMEOUT << 8;
 	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*nfmsg), flags);
@@ -163,20 +172,10 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 
 	NLA_PUT_STRING(skb, CTA_TIMEOUT_NAME, timeout->name);
 	NLA_PUT_BE16(skb, CTA_TIMEOUT_L3PROTO, htons(timeout->l3num));
-	NLA_PUT_U8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4num);
+	NLA_PUT_U8(skb, CTA_TIMEOUT_L4PROTO, timeout->l4proto->l4proto);
 	NLA_PUT_BE32(skb, CTA_TIMEOUT_USE,
 			htonl(atomic_read(&timeout->refcnt)));
 
-	l4proto = __nf_ct_l4proto_find(timeout->l3num, timeout->l4num);
-
-	/* If the timeout object does not match the layer 4 protocol tracker,
-	 * then skip dumping the data part since we don't know how to
-	 * interpret it. This may happen for UPDlite, SCTP and DCCP since
-	 * you can unload the module.
-	 */
-	if (timeout->l4num != l4proto->l4proto)
-		goto out;
-
 	if (likely(l4proto->ctnl_timeout.obj_to_nlattr)) {
 		struct nlattr *nest_parms;
 		int ret;
@@ -192,7 +191,7 @@ ctnl_timeout_fill_info(struct sk_buff *skb, u32 pid, u32 seq, u32 type,
 
 		nla_nest_end(skb, nest_parms);
 	}
-out:
+
 	nlmsg_end(skb, nlh);
 	return skb->len;
 
@@ -293,6 +292,7 @@ static int ctnl_timeout_try_del(struct ctnl_timeout *timeout)
 	if (atomic_dec_and_test(&timeout->refcnt)) {
 		/* We are protected by nfnl mutex. */
 		list_del_rcu(&timeout->head);
+		nf_ct_l4proto_put(timeout->l4proto);
 		kfree_rcu(timeout, rcu_head);
 	} else {
 		/* still in use, restore reference counter. */
@@ -417,6 +417,7 @@ static void __exit cttimeout_exit(void)
 		/* We are sure that our objects have no clients at this point,
 		 * it's safe to release them all without checking refcnt.
 		 */
+		nf_ct_l4proto_put(cur->l4proto);
 		kfree_rcu(cur, rcu_head);
 	}
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index b873445..80c39f0 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -16,6 +16,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_timeout.h>
 #include <net/netfilter/nf_conntrack_zones.h>
 
@@ -243,11 +244,12 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 					info->timeout, timeout->l3num);
 				goto err3;
 			}
-			if (timeout->l4num != e->ip.proto) {
+			if (timeout->l4proto->l4proto != e->ip.proto) {
 				ret = -EINVAL;
 				pr_info("Timeout policy `%s' can only be "
 					"used by L4 protocol number %d\n",
-					info->timeout, timeout->l4num);
+					info->timeout,
+					timeout->l4proto->l4proto);
 				goto err3;
 			}
 			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
-- 
1.7.2.5

