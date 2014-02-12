From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH ipsec-next] ipsec: add support of limited SA dump
Date: Wed, 12 Feb 2014 17:46:21 +0100
Message-ID: <1392223581-25554-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54612 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaBLQqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 11:46:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to allow userland to dump only a part of SA by
specifying a filter during the dump.
The kernel is in charge to filter SA, this avoids to generate useless netlink
traffic (it save also some cpu cycles). This is particularly useful when there
is a big number of SA set on the system.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that iproute2 patches are available and will be submitted once
the patch will be accepted. I can send them on demand.

 include/net/xfrm.h           |  4 +++-
 include/uapi/linux/pfkeyv2.h | 15 ++++++++++++++-
 include/uapi/linux/xfrm.h    | 10 ++++++++++
 net/key/af_key.c             | 19 ++++++++++++++++++-
 net/xfrm/xfrm_state.c        | 25 ++++++++++++++++++++++++-
 net/xfrm/xfrm_user.c         | 28 +++++++++++++++++++++++++++-
 6 files changed, 96 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afa5730fb3bd..17e4bfdbe0b3 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -123,6 +123,7 @@ struct xfrm_state_walk {
 		u8		proto;
 	};
 	u32			seq;
+	struct xfrm_filter	*filter;
 };
 
 /* Full description of state of transformer. */
@@ -1405,7 +1406,8 @@ static inline void xfrm_sysctl_fini(struct net *net)
 }
 #endif
 
-void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
+void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
+			  struct xfrm_filter *filter);
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*), void *);
 void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
diff --git a/include/uapi/linux/pfkeyv2.h b/include/uapi/linux/pfkeyv2.h
index 0b80c806631f..ada7f0171ccc 100644
--- a/include/uapi/linux/pfkeyv2.h
+++ b/include/uapi/linux/pfkeyv2.h
@@ -235,6 +235,18 @@ struct sadb_x_kmaddress {
 } __attribute__((packed));
 /* sizeof(struct sadb_x_kmaddress) == 8 */
 
+/* To specify the SA dump filter */
+struct sadb_x_filter {
+	__u16	sadb_x_filter_len;
+	__u16	sadb_x_filter_exttype;
+	__u32	sadb_x_filter_saddr[4];
+	__u32	sadb_x_filter_daddr[4];
+	__u16	sadb_x_filter_family;
+	__u8	sadb_x_filter_splen;
+	__u8	sadb_x_filter_dplen;
+} __attribute__((packed));
+/* sizeof(struct sadb_x_filter) == 40 */
+
 /* Message types */
 #define SADB_RESERVED		0
 #define SADB_GETSPI		1
@@ -358,7 +370,8 @@ struct sadb_x_kmaddress {
 #define SADB_X_EXT_SEC_CTX		24
 /* Used with MIGRATE to pass @ to IKE for negotiation */
 #define SADB_X_EXT_KMADDRESS		25
-#define SADB_EXT_MAX			25
+#define SADB_X_EXT_FILTER		26
+#define SADB_EXT_MAX			26
 
 /* Identity Extension values */
 #define SADB_IDENTTYPE_RESERVED	0
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index a8cd6a4a2970..6550c679584f 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -298,6 +298,8 @@ enum xfrm_attr_type_t {
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
+	XFRMA_PROTO,		/* __u8 */
+	XFRMA_FILTER,		/* struct xfrm_filter */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -474,6 +476,14 @@ struct xfrm_user_mapping {
 	__be16				new_sport;
 };
 
+struct xfrm_filter {
+	xfrm_address_t			saddr;
+	xfrm_address_t			daddr;
+	__u16				family;
+	__u8				splen;
+	__u8				dplen;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 1a04c1329362..70f8464eb6f0 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -1798,6 +1798,7 @@ static void pfkey_dump_sa_done(struct pfkey_sock *pfk)
 static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_msg *hdr, void * const *ext_hdrs)
 {
 	u8 proto;
+	struct xfrm_filter *filter = NULL;
 	struct pfkey_sock *pfk = pfkey_sk(sk);
 
 	if (pfk->dump.dump != NULL)
@@ -1807,11 +1808,27 @@ static int pfkey_dump(struct sock *sk, struct sk_buff *skb, const struct sadb_ms
 	if (proto == 0)
 		return -EINVAL;
 
+	if (ext_hdrs[SADB_X_EXT_FILTER - 1]) {
+		struct sadb_x_filter *xfilter = ext_hdrs[SADB_X_EXT_FILTER - 1];
+
+		filter = kmalloc(sizeof(*filter), GFP_KERNEL);
+		if (filter == NULL)
+			return -ENOMEM;
+
+		memcpy(&filter->saddr, &xfilter->sadb_x_filter_saddr,
+		       sizeof(xfrm_address_t));
+		memcpy(&filter->daddr, &xfilter->sadb_x_filter_daddr,
+		       sizeof(xfrm_address_t));
+		filter->family = xfilter->sadb_x_filter_family;
+		filter->splen = xfilter->sadb_x_filter_splen;
+		filter->dplen = xfilter->sadb_x_filter_dplen;
+	}
+
 	pfk->dump.msg_version = hdr->sadb_msg_version;
 	pfk->dump.msg_portid = hdr->sadb_msg_pid;
 	pfk->dump.dump = pfkey_dump_sa;
 	pfk->dump.done = pfkey_dump_sa_done;
-	xfrm_state_walk_init(&pfk->dump.u.state, proto);
+	xfrm_state_walk_init(&pfk->dump.u.state, proto, filter);
 
 	return pfkey_do_dump(pfk);
 }
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a26b7aa79475..45533b3fa63f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1590,6 +1590,23 @@ unlock:
 }
 EXPORT_SYMBOL(xfrm_alloc_spi);
 
+static bool __xfrm_state_filter_match(struct xfrm_state *x,
+				      struct xfrm_filter *filter)
+{
+	if (filter) {
+		if ((filter->family == AF_INET ||
+		     filter->family == AF_INET6) &&
+		    x->props.family != filter->family)
+			return false;
+
+		return addr_match(&x->props.saddr, &filter->saddr,
+				  filter->splen) &&
+		       addr_match(&x->id.daddr, &filter->daddr,
+				  filter->dplen);
+	}
+	return true;
+}
+
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*),
 		    void *data)
@@ -1612,6 +1629,8 @@ int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		state = container_of(x, struct xfrm_state, km);
 		if (!xfrm_id_proto_match(state->id.proto, walk->proto))
 			continue;
+		if (!__xfrm_state_filter_match(state, walk->filter))
+			continue;
 		err = func(state, walk->seq, data);
 		if (err) {
 			list_move_tail(&walk->all, &x->all);
@@ -1630,17 +1649,21 @@ out:
 }
 EXPORT_SYMBOL(xfrm_state_walk);
 
-void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto)
+void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
+			  struct xfrm_filter *filter)
 {
 	INIT_LIST_HEAD(&walk->all);
 	walk->proto = proto;
 	walk->state = XFRM_STATE_DEAD;
 	walk->seq = 0;
+	walk->filter = filter;
 }
 EXPORT_SYMBOL(xfrm_state_walk_init);
 
 void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net)
 {
+	kfree(walk->filter);
+
 	if (list_empty(&walk->all))
 		return;
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index ade9988f6e33..594ccb441801 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -887,6 +887,7 @@ static int xfrm_dump_sa_done(struct netlink_callback *cb)
 	return 0;
 }
 
+static const struct nla_policy xfrma_policy[XFRMA_MAX+1];
 static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
@@ -902,8 +903,31 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 	info.nlmsg_flags = NLM_F_MULTI;
 
 	if (!cb->args[0]) {
+		struct nlattr *attrs[XFRMA_MAX+1];
+		struct xfrm_filter *filter = NULL;
+		u8 proto = 0;
+		int err;
+
 		cb->args[0] = 1;
-		xfrm_state_walk_init(walk, 0);
+
+		err = nlmsg_parse(cb->nlh, 0, attrs, XFRMA_MAX,
+				  xfrma_policy);
+		if (err < 0)
+			return err;
+
+		if (attrs[XFRMA_FILTER]) {
+			filter = kmalloc(sizeof(*filter), GFP_KERNEL);
+			if (filter == NULL)
+				return -ENOMEM;
+
+			memcpy(filter, nla_data(attrs[XFRMA_FILTER]),
+			       sizeof(*filter));
+		}
+
+		if (attrs[XFRMA_PROTO])
+			proto = nla_get_u8(attrs[XFRMA_PROTO]);
+
+		xfrm_state_walk_init(walk, proto, filter);
 	}
 
 	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
@@ -2309,6 +2333,8 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_TFCPAD]		= { .type = NLA_U32 },
 	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
 	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
+	[XFRMA_PROTO]		= { .type = NLA_U8 },
+	[XFRMA_FILTER]		= { .len = sizeof(struct xfrm_filter) },
 };
 
 static const struct xfrm_link {
-- 
1.8.5.4
