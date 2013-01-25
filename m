From: pablo@netfilter.org
Subject: [PATCH 03/21] netfilter: ctnetlink: deliver labels to userspace
Date: Fri, 25 Jan 2013 14:54:35 +0100
Message-ID: <1359122093-3404-4-git-send-email-pablo@netfilter.org>
References: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1359122093-3404-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Introduce CTA_LABELS attribute to send a bit-vector of currently active labels
to userspace.

Future patch will permit userspace to also set/delete active labels.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_conntrack_common.h |    1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/netfilter/nf_conntrack_labels.c                |    2 +-
 net/netfilter/nf_conntrack_netlink.c               |   41 ++++++++++++++++++++
 4 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index 1644cdd..d69483f 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -101,6 +101,7 @@ enum ip_conntrack_events {
 	IPCT_MARK,		/* new mark has been set */
 	IPCT_NATSEQADJ,		/* NAT is doing sequence adjustment */
 	IPCT_SECMARK,		/* new security mark has been set */
+	IPCT_LABEL,		/* new connlabel has been set */
 };
 
 enum ip_conntrack_expect_events {
diff --git a/include/uapi/linux/netfilter/nfnetlink_conntrack.h b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
index 86e930c..9e71e0c 100644
--- a/include/uapi/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/uapi/linux/netfilter/nfnetlink_conntrack.h
@@ -49,6 +49,7 @@ enum ctattr_type {
 	CTA_SECCTX,
 	CTA_TIMESTAMP,
 	CTA_MARK_MASK,
+	CTA_LABELS,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_labels.c b/net/netfilter/nf_conntrack_labels.c
index 0c542f4..ac5d080 100644
--- a/net/netfilter/nf_conntrack_labels.c
+++ b/net/netfilter/nf_conntrack_labels.c
@@ -46,7 +46,7 @@ int nf_connlabel_set(struct nf_conn *ct, u16 bit)
 		return 0;
 
 	if (test_and_set_bit(bit, labels->bits))
-		return 0;
+		nf_conntrack_event_cache(IPCT_LABEL, ct);
 
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index e0b10ee..5f53863 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -324,6 +324,40 @@ nla_put_failure:
 #define ctnetlink_dump_secctx(a, b) (0)
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+static int ctnetlink_label_size(const struct nf_conn *ct)
+{
+	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
+
+	if (!labels)
+		return 0;
+	return nla_total_size(labels->words * sizeof(long));
+}
+
+static int
+ctnetlink_dump_labels(struct sk_buff *skb, const struct nf_conn *ct)
+{
+	struct nf_conn_labels *labels = nf_ct_labels_find(ct);
+	unsigned int len, i;
+
+	if (!labels)
+		return 0;
+
+	len = labels->words * sizeof(long);
+	i = 0;
+	do {
+		if (labels->bits[i] != 0)
+			return nla_put(skb, CTA_LABELS, len, labels->bits);
+		i++;
+	} while (i < labels->words);
+
+	return 0;
+}
+#else
+#define ctnetlink_dump_labels(a, b) (0)
+#define ctnetlink_label_size(a)	(0)
+#endif
+
 #define master_tuple(ct) &(ct->master->tuplehash[IP_CT_DIR_ORIGINAL].tuple)
 
 static inline int
@@ -464,6 +498,7 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 	    ctnetlink_dump_helpinfo(skb, ct) < 0 ||
 	    ctnetlink_dump_mark(skb, ct) < 0 ||
 	    ctnetlink_dump_secctx(skb, ct) < 0 ||
+	    ctnetlink_dump_labels(skb, ct) < 0 ||
 	    ctnetlink_dump_id(skb, ct) < 0 ||
 	    ctnetlink_dump_use(skb, ct) < 0 ||
 	    ctnetlink_dump_master(skb, ct) < 0 ||
@@ -562,6 +597,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 	       + nla_total_size(sizeof(u_int32_t)) /* CTA_MARK */
 #endif
 	       + ctnetlink_proto_size(ct)
+	       + ctnetlink_label_size(ct)
 	       ;
 }
 
@@ -663,6 +699,9 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		    && ctnetlink_dump_secctx(skb, ct) < 0)
 			goto nla_put_failure;
 #endif
+		if (events & (1 << IPCT_LABEL) &&
+		     ctnetlink_dump_labels(skb, ct) < 0)
+			goto nla_put_failure;
 
 		if (events & (1 << IPCT_RELATED) &&
 		    ctnetlink_dump_master(skb, ct) < 0)
@@ -1986,6 +2025,8 @@ ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct)
 	if (ct->mark && ctnetlink_dump_mark(skb, ct) < 0)
 		goto nla_put_failure;
 #endif
+	if (ctnetlink_dump_labels(skb, ct) < 0)
+		goto nla_put_failure;
 	rcu_read_unlock();
 	return 0;
 
-- 
1.7.10.4

