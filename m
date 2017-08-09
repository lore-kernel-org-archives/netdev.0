From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next] net: xfrm: support setting an output mark.
Date: Thu, 10 Aug 2017 02:08:52 +0900
Message-ID: <20170809170852.141745-1-lorenzo@google.com>
Cc: davem@davemloft.net, jhs@mojatatu.com,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37841 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752743AbdHIRJA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 13:09:00 -0400
Received: by mail-pg0-f42.google.com with SMTP id y129so30495021pgy.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 10:09:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On systems that use mark-based routing it may be necessary for
routing lookups to use marks in order for packets to be routed
correctly. An example of such a system is Android, which uses
socket marks to route packets via different networks.

Currently, routing lookups in tunnel mode always use a mark of
zero, making routing incorrect on such systems.

This patch adds a new output_mark element to the xfrm state and
a corresponding XFRMA_OUTPUT_MARK netlink attribute. The output
mark differs from the existing xfrm mark in two ways:

1. The xfrm mark is used to match xfrm policies and states, while
   the xfrm output mark is used to set the mark (and influence
   the routing) of the packets emitted by those states.
2. The existing mark is constrained to be a subset of the bits of
   the originating socket or transformed packet, but the output
   mark is arbitrary and depends only on the state.

The use of a separate mark provides additional flexibility. For
example:

- A packet subject to two transforms (e.g., transport mode inside
  tunnel mode) can have two different output marks applied to it,
  one for the transport mode SA and one for the tunnel mode SA.
- On a system where socket marks determine routing, the packets
  emitted by an IPsec tunnel can be routed based on a mark that
  is determined by the tunnel, not by the marks of the
  unencrypted packets.
- Support for setting the output marks can be introduced without
  breaking any existing setups that employ both mark-based
  routing and xfrm tunnel mode. Simply changing the code to use
  the xfrm mark for routing output packets could xfrm mark could
  change behaviour in a way that breaks these setups.

If the output mark is unspecified or set to zero, the mark is not
set or changed.

Tested: make allyesconfig; make -j64
Tested: https://android-review.googlesource.com/452776
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/xfrm.h        |  9 ++++++---
 include/uapi/linux/xfrm.h |  1 +
 net/ipv4/xfrm4_policy.c   | 14 +++++++++-----
 net/ipv6/xfrm6_policy.c   |  9 ++++++---
 net/xfrm/xfrm_device.c    |  3 ++-
 net/xfrm/xfrm_output.c    |  3 +++
 net/xfrm/xfrm_policy.c    | 17 +++++++++--------
 net/xfrm/xfrm_user.c      | 11 +++++++++++
 8 files changed, 47 insertions(+), 20 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afb4929d72..6b1ddb790d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -163,6 +163,7 @@ struct xfrm_state {
 		int		header_len;
 		int		trailer_len;
 		u32		extra_flags;
+		u32		output_mark;
 	} props;
 
 	struct xfrm_lifetime_cfg lft;
@@ -296,10 +297,12 @@ struct xfrm_policy_afinfo {
 	struct dst_entry	*(*dst_lookup)(struct net *net,
 					       int tos, int oif,
 					       const xfrm_address_t *saddr,
-					       const xfrm_address_t *daddr);
+					       const xfrm_address_t *daddr,
+					       u32 mark);
 	int			(*get_saddr)(struct net *net, int oif,
 					     xfrm_address_t *saddr,
-					     xfrm_address_t *daddr);
+					     xfrm_address_t *daddr,
+					     u32 mark);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
 						  int reverse);
@@ -1638,7 +1641,7 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
 				    const xfrm_address_t *saddr,
 				    const xfrm_address_t *daddr,
-				    int family);
+				    int family, u32 mark);
 
 struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 2b384ff09f..5fe7370a2b 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -304,6 +304,7 @@ enum xfrm_attr_type_t {
 	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
 	XFRMA_PAD,
 	XFRMA_OFFLOAD_DEV,	/* struct xfrm_state_offload */
+	XFRMA_OUTPUT_MARK,	/* __u32 */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4aefb149fe..d7bf0b0418 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -20,7 +20,8 @@
 static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 					    int tos, int oif,
 					    const xfrm_address_t *saddr,
-					    const xfrm_address_t *daddr)
+					    const xfrm_address_t *daddr,
+					    u32 mark)
 {
 	struct rtable *rt;
 
@@ -28,6 +29,7 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	fl4->daddr = daddr->a4;
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_oif = l3mdev_master_ifindex_by_index(net, oif);
+	fl4->flowi4_mark = mark;
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
@@ -42,20 +44,22 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 
 static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos, int oif,
 					  const xfrm_address_t *saddr,
-					  const xfrm_address_t *daddr)
+					  const xfrm_address_t *daddr,
+					  u32 mark)
 {
 	struct flowi4 fl4;
 
-	return __xfrm4_dst_lookup(net, &fl4, tos, oif, saddr, daddr);
+	return __xfrm4_dst_lookup(net, &fl4, tos, oif, saddr, daddr, mark);
 }
 
 static int xfrm4_get_saddr(struct net *net, int oif,
-			   xfrm_address_t *saddr, xfrm_address_t *daddr)
+			   xfrm_address_t *saddr, xfrm_address_t *daddr,
+			   u32 mark)
 {
 	struct dst_entry *dst;
 	struct flowi4 fl4;
 
-	dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, NULL, daddr);
+	dst = __xfrm4_dst_lookup(net, &fl4, 0, oif, NULL, daddr, mark);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f44b25a484..11d1314ab6 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -27,7 +27,8 @@
 
 static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 					  const xfrm_address_t *saddr,
-					  const xfrm_address_t *daddr)
+					  const xfrm_address_t *daddr,
+					  u32 mark)
 {
 	struct flowi6 fl6;
 	struct dst_entry *dst;
@@ -36,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_oif = l3mdev_master_ifindex_by_index(net, oif);
 	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
+	fl6.flowi6_mark = mark;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
 		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
@@ -52,12 +54,13 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 }
 
 static int xfrm6_get_saddr(struct net *net, int oif,
-			   xfrm_address_t *saddr, xfrm_address_t *daddr)
+			   xfrm_address_t *saddr, xfrm_address_t *daddr,
+			   u32 mark)
 {
 	struct dst_entry *dst;
 	struct net_device *dev;
 
-	dst = xfrm6_dst_lookup(net, 0, oif, NULL, daddr);
+	dst = xfrm6_dst_lookup(net, 0, oif, NULL, daddr, mark);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 5cd7a244e8..dc9840e366 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -79,7 +79,8 @@ int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 			daddr = &x->props.saddr;
 		}
 
-		dst = __xfrm_dst_lookup(net, 0, 0, saddr, daddr, x->props.family);
+		dst = __xfrm_dst_lookup(net, 0, 0, saddr, daddr,
+					x->props.family, x->props.output_mark);
 		if (IS_ERR(dst))
 			return 0;
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8c0b6722aa..31a2e6d34d 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -66,6 +66,9 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 			goto error_nolock;
 		}
 
+		if (x->props.output_mark)
+			skb->mark = x->props.output_mark;
+
 		err = x->outer_mode->output(x, skb);
 		if (err) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEMODEERROR);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 8da428f56a..cc0d783ccb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -122,7 +122,7 @@ static const struct xfrm_policy_afinfo *xfrm_policy_get_afinfo(unsigned short fa
 struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
 				    const xfrm_address_t *saddr,
 				    const xfrm_address_t *daddr,
-				    int family)
+				    int family, u32 mark)
 {
 	const struct xfrm_policy_afinfo *afinfo;
 	struct dst_entry *dst;
@@ -131,7 +131,7 @@ struct dst_entry *__xfrm_dst_lookup(struct net *net, int tos, int oif,
 	if (unlikely(afinfo == NULL))
 		return ERR_PTR(-EAFNOSUPPORT);
 
-	dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr);
+	dst = afinfo->dst_lookup(net, tos, oif, saddr, daddr, mark);
 
 	rcu_read_unlock();
 
@@ -143,7 +143,7 @@ static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
 						int tos, int oif,
 						xfrm_address_t *prev_saddr,
 						xfrm_address_t *prev_daddr,
-						int family)
+						int family, u32 mark)
 {
 	struct net *net = xs_net(x);
 	xfrm_address_t *saddr = &x->props.saddr;
@@ -159,7 +159,7 @@ static inline struct dst_entry *xfrm_dst_lookup(struct xfrm_state *x,
 		daddr = x->coaddr;
 	}
 
-	dst = __xfrm_dst_lookup(net, tos, oif, saddr, daddr, family);
+	dst = __xfrm_dst_lookup(net, tos, oif, saddr, daddr, family, mark);
 
 	if (!IS_ERR(dst)) {
 		if (prev_saddr != saddr)
@@ -1340,14 +1340,14 @@ int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 
 static int
 xfrm_get_saddr(struct net *net, int oif, xfrm_address_t *local,
-	       xfrm_address_t *remote, unsigned short family)
+	       xfrm_address_t *remote, unsigned short family, u32 mark)
 {
 	int err;
 	const struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	err = afinfo->get_saddr(net, oif, local, remote);
+	err = afinfo->get_saddr(net, oif, local, remote, mark);
 	rcu_read_unlock();
 	return err;
 }
@@ -1378,7 +1378,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, const struct flowi *fl,
 			if (xfrm_addr_any(local, tmpl->encap_family)) {
 				error = xfrm_get_saddr(net, fl->flowi_oif,
 						       &tmp, remote,
-						       tmpl->encap_family);
+						       tmpl->encap_family, 0);
 				if (error)
 					goto fail;
 				local = &tmp;
@@ -1598,7 +1598,8 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		if (xfrm[i]->props.mode != XFRM_MODE_TRANSPORT) {
 			family = xfrm[i]->props.family;
 			dst = xfrm_dst_lookup(xfrm[i], tos, fl->flowi_oif,
-					      &saddr, &daddr, family);
+					      &saddr, &daddr, family,
+					      xfrm[i]->props.output_mark);
 			err = PTR_ERR(dst);
 			if (IS_ERR(dst))
 				goto put_states;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1b539b7dcf..15dd0023ed 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -584,6 +584,9 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 
 	xfrm_mark_get(attrs, &x->mark);
 
+	if (attrs[XFRMA_OUTPUT_MARK])
+		x->props.output_mark = nla_get_u32(attrs[XFRMA_OUTPUT_MARK]);
+
 	err = __xfrm_init_state(x, false);
 	if (err)
 		goto error;
@@ -899,6 +902,11 @@ static int copy_to_user_state_extra(struct xfrm_state *x,
 		goto out;
 	if (x->security)
 		ret = copy_sec_ctx(x->security, skb);
+	if (x->props.output_mark) {
+		ret = nla_put_u32(skb, XFRMA_OUTPUT_MARK, x->props.output_mark);
+		if (ret)
+			goto out;
+	}
 out:
 	return ret;
 }
@@ -2454,6 +2462,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_PROTO]		= { .type = NLA_U8 },
 	[XFRMA_ADDRESS_FILTER]	= { .len = sizeof(struct xfrm_address_filter) },
 	[XFRMA_OFFLOAD_DEV]	= { .len = sizeof(struct xfrm_user_offload) },
+	[XFRMA_OUTPUT_MARK]	= { .len = NLA_U32 },
 };
 
 static const struct nla_policy xfrma_spd_policy[XFRMA_SPD_MAX+1] = {
@@ -2673,6 +2682,8 @@ static inline size_t xfrm_sa_len(struct xfrm_state *x)
 		l += nla_total_size(sizeof(x->props.extra_flags));
 	if (x->xso.dev)
 		 l += nla_total_size(sizeof(x->xso));
+	if (x->props.output_mark)
+		l += nla_total_size(sizeof(x->props.output_mark));
 
 	/* Must count x->lastused as it may become non-zero behind our back. */
 	l += nla_total_size_64bit(sizeof(u64));
-- 
2.14.0.434.g98096fd7a8-goog
