From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 10/13] ipsec: add support of limited SA dump
Date: Mon, 24 Feb 2014 10:59:58 +0100
Message-ID: <1393236001-2445-11-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39145 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752222AbaBXKAU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:20 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

The goal of this patch is to allow userland to dump only a part of SA by
specifying a filter during the dump.
The kernel is in charge to filter SA, this avoids to generate useless netlink
traffic (it save also some cpu cycles). This is particularly useful when there
is a big number of SA set on the system.

Note that I removed the union in struct xfrm_state_walk to fix a problem on arm.
struct netlink_callback->args is defined as a array of 6 long and the first long
is used in xfrm code to flag the cb as initialized. Hence, we must have:
sizeof(struct xfrm_state_walk) <= sizeof(long) * 5.
With the union, it was false on arm (sizeof(struct xfrm_state_walk) was
sizeof(long) * 7), due to the padding.
In fact, whatever the arch is, this union seems useless, there will be always
padding after it. Removing it will not increase the size of this struct (and
reduce it on arm).

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h           |   10 +++++-----
 include/uapi/linux/pfkeyv2.h |   15 ++++++++++++++-
 include/uapi/linux/xfrm.h    |   10 ++++++++++
 net/key/af_key.c             |   19 ++++++++++++++++++-
 net/xfrm/xfrm_state.c        |   25 ++++++++++++++++++++++++-
 net/xfrm/xfrm_user.c         |   28 +++++++++++++++++++++++++++-
 6 files changed, 98 insertions(+), 9 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5313ccf..45332ac 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -118,11 +118,10 @@
 struct xfrm_state_walk {
 	struct list_head	all;
 	u8			state;
-	union {
-		u8		dying;
-		u8		proto;
-	};
+	u8			dying;
+	u8			proto;
 	u32			seq;
+	struct xfrm_filter	*filter;
 };
 
 /* Full description of state of transformer. */
@@ -1406,7 +1405,8 @@ static inline void xfrm_sysctl_fini(struct net *net)
 }
 #endif
 
-void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
+void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto,
+			  struct xfrm_filter *filter);
 int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		    int (*func)(struct xfrm_state *, int, void*), void *);
 void xfrm_state_walk_done(struct xfrm_state_walk *walk, struct net *net);
diff --git a/include/uapi/linux/pfkeyv2.h b/include/uapi/linux/pfkeyv2.h
index 0b80c80..ada7f01 100644
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
index a8cd6a4..6550c67 100644
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
index e1c69d0..f0879c1 100644
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
index 0bf12f6..a750901 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1603,6 +1603,23 @@ unlock:
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
@@ -1625,6 +1642,8 @@ int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 		state = container_of(x, struct xfrm_state, km);
 		if (!xfrm_id_proto_match(state->id.proto, walk->proto))
 			continue;
+		if (!__xfrm_state_filter_match(state, walk->filter))
+			continue;
 		err = func(state, walk->seq, data);
 		if (err) {
 			list_move_tail(&walk->all, &x->all);
@@ -1643,17 +1662,21 @@ out:
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
index d7694f2..023e5e7 100644
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
1.7.9.5
