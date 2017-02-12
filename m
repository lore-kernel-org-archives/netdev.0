From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/21] netfilter: nfnetlink: allow to check for generation ID
Date: Sun, 12 Feb 2017 20:42:49 +0100
Message-ID: <1486928573-24773-18-git-send-email-pablo@netfilter.org>
References: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486928573-24773-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows userspace to specify the generation ID that has been
used to build an incremental batch update.

If userspace specifies the generation ID in the batch message as
attribute, then nfnetlink compares it to the current generation ID so
you make sure that you work against the right baseline. Otherwise, bail
out with ERESTART so userspace knows that its changeset is stale and
needs to respin. Userspace can do this transparently at the cost of
taking slightly more time to refresh caches and rework the changeset.

This check is optional, if there is no NFNL_BATCH_GENID attribute in the
batch begin message, then no check is performed.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink.h      |  1 +
 include/uapi/linux/netfilter/nfnetlink.h | 12 ++++++++++++
 net/netfilter/nfnetlink.c                | 31 +++++++++++++++++++++++++++----
 3 files changed, 40 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 1d82dd5e9a08..1b49209dd5c7 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -28,6 +28,7 @@ struct nfnetlink_subsystem {
 	const struct nfnl_callback *cb;	/* callback for individual types */
 	int (*commit)(struct net *net, struct sk_buff *skb);
 	int (*abort)(struct net *net, struct sk_buff *skb);
+	bool (*valid_genid)(struct net *net, u32 genid);
 };
 
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
diff --git a/include/uapi/linux/netfilter/nfnetlink.h b/include/uapi/linux/netfilter/nfnetlink.h
index 4bb8cb7730e7..a09906a30d77 100644
--- a/include/uapi/linux/netfilter/nfnetlink.h
+++ b/include/uapi/linux/netfilter/nfnetlink.h
@@ -65,4 +65,16 @@ struct nfgenmsg {
 #define NFNL_MSG_BATCH_BEGIN		NLMSG_MIN_TYPE
 #define NFNL_MSG_BATCH_END		NLMSG_MIN_TYPE+1
 
+/**
+ * enum nfnl_batch_attributes - nfnetlink batch netlink attributes
+ *
+ * @NFNL_BATCH_GENID: generation ID for this changeset (NLA_U32)
+ */
+enum nfnl_batch_attributes {
+        NFNL_BATCH_UNSPEC,
+        NFNL_BATCH_GENID,
+        __NFNL_BATCH_MAX
+};
+#define NFNL_BATCH_MAX			(__NFNL_BATCH_MAX - 1)
+
 #endif /* _UAPI_NFNETLINK_H */
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index ca645a3b1375..a2148d0bc50e 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -3,7 +3,7 @@
  *
  * (C) 2001 by Jay Schulist <jschlst@samba.org>,
  * (C) 2002-2005 by Harald Welte <laforge@gnumonks.org>
- * (C) 2005,2007 by Pablo Neira Ayuso <pablo@netfilter.org>
+ * (C) 2005-2017 by Pablo Neira Ayuso <pablo@netfilter.org>
  *
  * Initial netfilter messages via netlink development funded and
  * generally made possible by Network Robots, Inc. (www.networkrobots.com)
@@ -273,7 +273,7 @@ enum {
 };
 
 static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
-				u16 subsys_id)
+				u16 subsys_id, u32 genid)
 {
 	struct sk_buff *oskb = skb;
 	struct net *net = sock_net(skb->sk);
@@ -315,6 +315,12 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return kfree_skb(skb);
 	}
 
+	if (genid && ss->valid_genid && !ss->valid_genid(net, genid)) {
+		nfnl_unlock(subsys_id);
+		netlink_ack(oskb, nlh, -ERESTART);
+		return kfree_skb(skb);
+	}
+
 	while (skb->len >= nlmsg_total_size(0)) {
 		int msglen, type;
 
@@ -436,11 +442,20 @@ static void nfnetlink_rcv_batch(struct sk_buff *skb, struct nlmsghdr *nlh,
 	kfree_skb(skb);
 }
 
+static const struct nla_policy nfnl_batch_policy[NFNL_BATCH_MAX + 1] = {
+	[NFNL_BATCH_GENID]	= { .type = NLA_U32 },
+};
+
 static void nfnetlink_rcv_skb_batch(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
+	int min_len = nlmsg_total_size(sizeof(struct nfgenmsg));
+	struct nlattr *attr = (void *)nlh + min_len;
+	struct nlattr *cda[NFNL_BATCH_MAX + 1];
+	int attrlen = nlh->nlmsg_len - min_len;
 	struct nfgenmsg *nfgenmsg;
+	int msglen, err;
+	u32 gen_id = 0;
 	u16 res_id;
-	int msglen;
 
 	msglen = NLMSG_ALIGN(nlh->nlmsg_len);
 	if (msglen > skb->len)
@@ -450,6 +465,14 @@ static void nfnetlink_rcv_skb_batch(struct sk_buff *skb, struct nlmsghdr *nlh)
 	    skb->len < NLMSG_HDRLEN + sizeof(struct nfgenmsg))
 		return;
 
+	err = nla_parse(cda, NFNL_BATCH_MAX, attr, attrlen, nfnl_batch_policy);
+	if (err < 0) {
+		netlink_ack(skb, nlh, err);
+		return;
+	}
+	if (cda[NFNL_BATCH_GENID])
+		gen_id = ntohl(nla_get_be32(cda[NFNL_BATCH_GENID]));
+
 	nfgenmsg = nlmsg_data(nlh);
 	skb_pull(skb, msglen);
 	/* Work around old nft using host byte order */
@@ -458,7 +481,7 @@ static void nfnetlink_rcv_skb_batch(struct sk_buff *skb, struct nlmsghdr *nlh)
 	else
 		res_id = ntohs(nfgenmsg->res_id);
 
-	nfnetlink_rcv_batch(skb, nlh, res_id);
+	nfnetlink_rcv_batch(skb, nlh, res_id, gen_id);
 }
 
 static void nfnetlink_rcv(struct sk_buff *skb)
-- 
2.1.4

