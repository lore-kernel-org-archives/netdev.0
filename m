From: Florian Westphal <fwestphal@astaro.com>
Subject: [PATCH 4/5] xfrm: CONFIG_COMPAT support for x86 architecture
Date: Fri, 19 Feb 2010 13:41:46 +0100
Message-ID: <1266583307-3049-5-git-send-email-fwestphal@astaro.com>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Cc: johannes@sipsolutions.net, Florian Westphal <fwestphal@astaro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48622 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753474Ab0BSMlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:41:47 -0500
In-Reply-To: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on x86_64, struct xfrm_userpolicy_info/usersa_info have four
additional bytes of padding at the end compared to x86.

Thus, when calling nlmsg_parse(.., sizeof(struct xfrm_userpolicy_info),
trailing attributes are not parsed correctly by the kernel when
the message was sent from an x86 32bit task.

Furthermore, those structures are contained inside
a few other structures, e.g. struct xfrm_user_acquire.

When dealing with incoming data from userland,
those structures need special treatment in the "userland is 32bit"
case.

When sending data to userland, it is sent in both 32bit and native
format.

Errors when building the compat message are not visisble to user
space; data will then be sent without the compat payload.

refer to 1dacc76d0014a034b8aca14237c127d7c19d7726
(net/compat/wext: send different messages to compat tasks) for
more information on netlink compat handling.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 changes since v1:
 - reformat to avoid overly long lines
 - restrict xfrm_msg_compat() use to input path
 - xfrm_add_compatskb() now returns pointer to compatskb
 - xfrm_msg_min_compat_pad table no longer hardcodes value "4"
 - add missing compatskb alloc in xfrm_state_netlink
   and xfrm_policy_netlink.
 - removed compat_xfrm_acquire_msgsize() etc. and use normal
   msgsize helper for compatskb, too. This means that we'll
   allocate 4 bytes more memory for the compatskb than needed,
   but this saves about 30 LOC.

I did not remove the CONFIG_COMPAT_FOR_U64_ALIGNMENT-ifdef from
dump_one_state/_policy -- without it .o size increases by about
150 bytes with COMPAT_FOR_U64_ALIGNMENT=n, as the compiler
cannot know that skb_shinfo(skb)->frag_list will always be NULL
(and therefore the 2nd call to copy_() is not removed).

 net/xfrm/Kconfig     |    1 +
 net/xfrm/xfrm_user.c |  368 +++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 339 insertions(+), 30 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 6d08167..0b30357 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -9,6 +9,7 @@ config XFRM
 config XFRM_USER
 	tristate "Transformation user configuration interface"
 	depends on INET && XFRM
+	select WANT_COMPAT_NETLINK_MESSAGES if COMPAT_FOR_U64_ALIGNMENT
 	---help---
 	  Support for Transformation(XFRM) user configuration interface
 	  like IPsec used by native Linux tools.
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a36dbc9..34dee3d 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -10,6 +10,7 @@
  *
  */
 
+#include <linux/compat.h>
 #include <linux/crypto.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -31,6 +32,149 @@
 #include <linux/in6.h>
 #endif
 
+#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
+struct compat_xfrm_lifetime_cfg {
+	compat_u64 soft_byte_limit, hard_byte_limit;
+	compat_u64 soft_packet_limit, hard_packet_limit;
+	compat_u64 soft_add_expires_seconds, hard_add_expires_seconds;
+	compat_u64 soft_use_expires_seconds, hard_use_expires_seconds;
+};
+
+struct compat_xfrm_lifetime_cur {
+	compat_u64 bytes, packets, add_time, use_time;
+};
+
+struct compat_xfrm_userpolicy_info {
+	struct xfrm_selector sel;
+	struct compat_xfrm_lifetime_cfg lft;
+	struct compat_xfrm_lifetime_cur curlft;
+	u32 priority, index;
+	u8 dir, action, flags, share;
+	/* 4 bytes additional padding on 64bit */
+};
+
+struct compat_xfrm_usersa_info {
+	struct xfrm_selector sel;
+	struct xfrm_id id;
+	xfrm_address_t saddr;
+	struct compat_xfrm_lifetime_cfg lft;
+	struct compat_xfrm_lifetime_cur curlft;
+	struct xfrm_stats stats;
+	u32 seq, reqid;
+	u16 family;
+	u8 mode, replay_window, flags;
+	/* 4 bytes additional padding on 64bit */
+};
+
+struct compat_xfrm_user_acquire {
+	struct xfrm_id id;
+	xfrm_address_t saddr;
+	struct xfrm_selector sel;
+	struct compat_xfrm_userpolicy_info policy;
+	/* 4 bytes additional padding on 64bit */
+	u32 aalgos, ealgos, calgos, seq;
+};
+
+struct compat_xfrm_userspi_info {
+	struct compat_xfrm_usersa_info info;
+	/* 4 bytes additional padding on 64bit */
+	u32 min, max;
+};
+
+struct compat_xfrm_user_expire {
+	struct compat_xfrm_usersa_info state;
+	/* 4 bytes additional padding on 64bit */
+	u8 hard;
+};
+
+struct compat_xfrm_user_polexpire {
+	struct compat_xfrm_userpolicy_info pol;
+	/* 4 bytes additional padding on 64bit */
+	u8 hard;
+};
+
+static bool xfrm_msg_compat(const struct sk_buff *skb)
+{
+	return unlikely(NETLINK_CB(skb).msg_compat);
+}
+
+static struct sk_buff *xfrm_add_compatskb(struct sk_buff *skb,
+					  unsigned int len, gfp_t gfp)
+{
+	struct sk_buff *compatskb = nlmsg_new(len, gfp);
+
+	WARN_ON(skb_shinfo(skb)->frag_list);
+
+	skb_shinfo(skb)->frag_list = compatskb;
+	return compatskb;
+}
+#else
+static inline bool xfrm_msg_compat(const struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline struct sk_buff *xfrm_add_compatskb(struct sk_buff *skb,
+						 unsigned int len, gfp_t gfp)
+{
+	return NULL;
+}
+
+/*
+ * avoids #ifdefs all over the place. Use of these must be conditional via
+ * xfrm_msg_compat/xfrm_add_compatskb so compiler can remove branches.
+ */
+#define compat_xfrm_user_expire     xfrm_user_expire
+#define compat_xfrm_user_acquire    xfrm_user_acquire
+#define compat_xfrm_user_polexpire  xfrm_user_polexpire
+#define compat_xfrm_userpolicy_info xfrm_userpolicy_info
+#define compat_xfrm_usersa_info     xfrm_usersa_info
+#define compat_xfrm_userspi_info    xfrm_userspi_info
+
+#endif /* CONFIG_COMPAT_FOR_U64_ALIGNMENT */
+
+/*
+ * userspace size of some structures is smaller due to different u64
+ * u64 alignment on x86 platform.
+ *
+ * Some of the structures need to use the compat_* structure definition
+ * when accessing certain members, see compat_ structures above.
+ */
+#define XMSGDELTA(type) (sizeof(struct type) - sizeof(struct compat_##type))
+static const u8 xfrm_msg_min_compat_pad[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA     - XFRM_MSG_BASE] = XMSGDELTA(xfrm_usersa_info),
+	[XFRM_MSG_NEWPOLICY - XFRM_MSG_BASE] = XMSGDELTA(xfrm_userpolicy_info),
+	[XFRM_MSG_ALLOCSPI  - XFRM_MSG_BASE] = XMSGDELTA(xfrm_userspi_info),
+	[XFRM_MSG_ACQUIRE   - XFRM_MSG_BASE] = XMSGDELTA(xfrm_user_acquire),
+	[XFRM_MSG_EXPIRE    - XFRM_MSG_BASE] = XMSGDELTA(xfrm_user_expire),
+	[XFRM_MSG_UPDPOLICY - XFRM_MSG_BASE] = XMSGDELTA(xfrm_userpolicy_info),
+	[XFRM_MSG_UPDSA     - XFRM_MSG_BASE] = XMSGDELTA(xfrm_usersa_info),
+	[XFRM_MSG_POLEXPIRE - XFRM_MSG_BASE] = XMSGDELTA(xfrm_user_polexpire),
+};
+#undef XMSGDELTA
+
+static int get_user_expire_hard(const struct sk_buff *skb,
+				const struct xfrm_user_expire *ue)
+{
+	if (xfrm_msg_compat(skb)) {
+		const struct compat_xfrm_user_expire *cmpt;
+		cmpt = (const struct compat_xfrm_user_expire *) ue;
+		return cmpt->hard;
+	}
+	return ue->hard;
+}
+
+static int get_user_polexpire_hard(const struct sk_buff *skb,
+				   const struct xfrm_user_polexpire *ue)
+{
+	if (xfrm_msg_compat(skb)) {
+		const struct compat_xfrm_user_polexpire *cmpt;
+		cmpt = (const struct compat_xfrm_user_polexpire *) ue;
+		return cmpt->hard;
+	}
+	return ue->hard;
+}
+
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -693,7 +837,7 @@ nla_put_failure:
 }
 
 static int copy_one_state(struct sk_buff *skb, struct xfrm_state *x,
-			  struct xfrm_dump_info *sp)
+			  struct xfrm_dump_info *sp, bool compat)
 {
 	struct sk_buff *in_skb = sp->in_skb;
 	struct xfrm_usersa_info *p;
@@ -701,6 +845,9 @@ static int copy_one_state(struct sk_buff *skb, struct xfrm_state *x,
 	size_t len = sizeof(*p);
 	int err;
 
+	if (compat)
+		len = sizeof(struct compat_xfrm_usersa_info);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, len, sp->nlmsg_flags);
 	if (nlh == NULL)
@@ -724,7 +871,14 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *skb = sp->out_skb;
-	int ret = copy_one_state(skb, x, sp);
+	int ret = copy_one_state(skb, x, sp, false);
+#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
+	if (ret == 0) {
+		skb = skb_shinfo(skb)->frag_list;
+		if (skb)
+			copy_one_state(skb, x, sp, true);
+	}
+#endif
 	return ret;
 }
 
@@ -754,6 +908,8 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_state_walk_init(walk, 0);
 	}
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+
 	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
 
 	return skb->len;
@@ -774,6 +930,8 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	info.nlmsg_seq = seq;
 	info.nlmsg_flags = 0;
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_ATOMIC);
+
 	if (dump_one_state(x, 0, &info)) {
 		kfree_skb(skb);
 		return NULL;
@@ -945,6 +1103,29 @@ static int verify_userspi_info(struct xfrm_userspi_info *p)
 	return 0;
 }
 
+static int compat_verify_userspi_info(struct xfrm_userspi_info *p)
+{
+	struct compat_xfrm_userspi_info *compat;
+
+	compat = (struct compat_xfrm_userspi_info  *) p;
+
+	switch (p->info.id.proto) {
+	case IPPROTO_AH:
+	case IPPROTO_ESP:
+		break;
+	case IPPROTO_COMP:
+		if (compat->max >= 0x10000)
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (compat->min > compat->max)
+		return -EINVAL;
+	return 0;
+}
+
 static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
@@ -957,7 +1138,10 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 
 	p = nlmsg_data(nlh);
-	err = verify_userspi_info(p);
+	if (xfrm_msg_compat(skb))
+		err = compat_verify_userspi_info(p);
+	else
+		err = verify_userspi_info(p);
 	if (err)
 		goto out_noput;
 
@@ -981,8 +1165,14 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	err = -ENOENT;
 	if (x == NULL)
 		goto out_noput;
+	if (xfrm_msg_compat(skb)) {
+		struct compat_xfrm_userspi_info *compat;
+		compat = (struct compat_xfrm_userspi_info *) p;
+		err = xfrm_alloc_spi(x, compat->min, compat->max);
+	} else {
+		err = xfrm_alloc_spi(x, p->min, p->max);
+	}
 
-	err = xfrm_alloc_spi(x, p->min, p->max);
 	if (err)
 		goto out;
 
@@ -1354,13 +1544,16 @@ static inline int copy_to_user_policy_type(u8 type, struct sk_buff *skb)
 #endif
 
 static int copy_one_policy(struct sk_buff *skb, struct xfrm_policy *xp,
-			   int dir, struct xfrm_dump_info *sp)
+			   int dir, struct xfrm_dump_info *sp, bool compat)
 {
 	struct xfrm_userpolicy_info *p;
 	struct sk_buff *in_skb = sp->in_skb;
 	struct nlmsghdr *nlh;
 	size_t len = sizeof(*p);
 
+	if (compat)
+		len = sizeof(struct compat_xfrm_userpolicy_info);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, len, sp->nlmsg_flags);
 	if (nlh == NULL)
@@ -1388,7 +1581,14 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir,
 {
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *skb = sp->out_skb;
-	int ret = copy_one_policy(skb, xp, dir, sp);
+	int ret = copy_one_policy(skb, xp, dir, sp, false);
+#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
+	if (ret == 0) {
+		skb = skb_shinfo(skb)->frag_list;
+		if (skb)
+			copy_one_policy(skb, xp, dir, sp, true);
+	}
+#endif
 	return ret;
 }
 
@@ -1419,6 +1619,8 @@ static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
 	}
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+
 	(void) xfrm_policy_walk(net, walk, dump_one_policy, &info);
 
 	return skb->len;
@@ -1440,6 +1642,8 @@ static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
 	info.nlmsg_seq = seq;
 	info.nlmsg_flags = 0;
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+
 	if (dump_one_policy(xp, dir, 0, &info) < 0) {
 		kfree_skb(skb);
 		return NULL;
@@ -1750,7 +1954,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	read_unlock(&xp->lock);
 	err = 0;
-	hard = up->hard;
+	hard = get_user_polexpire_hard(skb, up);
 	if (hard) {
 		uid_t loginuid = NETLINK_CB(skb).loginuid;
 		uid_t sessionid = NETLINK_CB(skb).sessionid;
@@ -1788,7 +1992,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	err = -EINVAL;
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
-	hard = ue->hard;
+	hard = get_user_expire_hard(skb, ue);
 	km_state_expired(x, hard, current->pid);
 
 	if (hard) {
@@ -1805,6 +2009,23 @@ out:
 	return err;
 }
 
+static void acquire_extract_algos(const struct sk_buff *skb,
+				   struct xfrm_tmpl *t,
+				   const struct xfrm_user_acquire *ua)
+{
+	if (!xfrm_msg_compat(skb)) {
+		t->aalgos = ua->aalgos;
+		t->ealgos = ua->ealgos;
+		t->calgos = ua->calgos;
+	} else {
+		const struct compat_xfrm_user_acquire *compat_ua;
+		compat_ua = (const struct compat_xfrm_user_acquire *) ua;
+		t->aalgos = compat_ua->aalgos;
+		t->ealgos = compat_ua->ealgos;
+		t->calgos = compat_ua->calgos;
+	}
+}
+
 static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		struct nlattr **attrs)
 {
@@ -1842,9 +2063,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		x->props.mode = t->mode;
 		x->props.reqid = t->reqid;
 		x->props.family = ut->family;
-		t->aalgos = ua->aalgos;
-		t->ealgos = ua->ealgos;
-		t->calgos = ua->calgos;
+		acquire_extract_algos(skb, t, ua);
 		err = km_query(x, t, xp);
 
 	}
@@ -2125,6 +2344,13 @@ static struct xfrm_link {
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
+static int xfrm_msg_hdrlen(const struct sk_buff *skb, int type)
+{
+	if (xfrm_msg_compat(skb))
+		return xfrm_msg_min[type] - xfrm_msg_min_compat_pad[type];
+	return xfrm_msg_min[type];
+}
+
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2152,7 +2378,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done);
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
+	err = nlmsg_parse(nlh, xfrm_msg_hdrlen(skb, type), attrs, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;
@@ -2191,10 +2417,27 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	return nlmsg_end(skb, nlh);
 }
 
+static void compat_build_expire(struct sk_buff *skb, struct xfrm_state *x,
+				struct km_event *c)
+{
+	struct compat_xfrm_user_expire *compat_ue;
+	struct nlmsghdr *nlh;
+
+	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_EXPIRE, sizeof(*compat_ue), 0);
+	if (nlh == NULL)
+		return;
+
+	compat_ue = nlmsg_data(nlh);
+	copy_to_user_state(x, (struct xfrm_usersa_info *) &compat_ue->state);
+	compat_ue->hard = (c->data.hard != 0) ? 1 : 0;
+
+	nlmsg_end(skb, nlh);
+}
+
 static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 {
 	struct net *net = xs_net(x);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *cskb;
 
 	skb = nlmsg_new(xfrm_expire_msgsize(), GFP_ATOMIC);
 	if (skb == NULL)
@@ -2203,6 +2446,9 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 	if (build_expire(skb, x, c) < 0)
 		BUG();
 
+	if ((cskb = xfrm_add_compatskb(skb, xfrm_expire_msgsize(), GFP_ATOMIC)))
+		compat_build_expire(cskb, x, c);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
@@ -2296,8 +2542,16 @@ static int xfrm_notify_sa_headlen(const struct km_event *c)
 	return sizeof(struct xfrm_usersa_info);
 }
 
+static int compat_xfrm_notify_sa_headlen(const struct km_event *c)
+{
+	if (c->event == XFRM_MSG_DELSA)
+		return sizeof(struct xfrm_usersa_id);
+	return sizeof(struct compat_xfrm_usersa_info);
+}
+
 static int copy_to_user_xfrm_notify_sa(struct sk_buff *skb,
-				       struct xfrm_state *x, struct km_event *c)
+				       struct xfrm_state *x,
+				       struct km_event *c, bool compat)
 {
 	struct xfrm_usersa_info *p;
 	struct xfrm_usersa_id *id;
@@ -2305,6 +2559,11 @@ static int copy_to_user_xfrm_notify_sa(struct sk_buff *skb,
 	int sizeof_usersa_info = sizeof(*p);
 	int headlen = xfrm_notify_sa_headlen(c);
 
+	if (compat) {
+		headlen = compat_xfrm_notify_sa_headlen(c);
+		sizeof_usersa_info = sizeof(struct compat_xfrm_usersa_info);
+	}
+
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -2339,7 +2598,7 @@ nla_put_failure:
 
 static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb, *cskb;
 	struct net *net = xs_net(x);
 	int len = xfrm_notify_sa_len(x, c);
 
@@ -2347,9 +2606,12 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (copy_to_user_xfrm_notify_sa(skb, x, c))
+	if (copy_to_user_xfrm_notify_sa(skb, x, c, false))
 		goto nla_put_failure;
 
+	if ((cskb = xfrm_add_compatskb(skb, len, GFP_ATOMIC)))
+		copy_to_user_xfrm_notify_sa(cskb, x, c, true);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
 nla_put_failure:
@@ -2393,12 +2655,16 @@ static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
 
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
-			 int dir)
+			 int dir, bool compat)
 {
 	struct xfrm_user_acquire *ua;
 	size_t len = sizeof(*ua);
 	struct nlmsghdr *nlh;
 	__u32 seq = xfrm_get_acqseq();
+	struct compat_xfrm_user_acquire *compat_ua;
+
+	if (compat)
+		len = sizeof(*compat_ua);
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, len, 0);
 	if (nlh == NULL)
@@ -2409,10 +2675,19 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	memcpy(&ua->saddr, &x->props.saddr, sizeof(ua->saddr));
 	memcpy(&ua->sel, &x->sel, sizeof(ua->sel));
 	copy_to_user_policy(xp, &ua->policy, dir);
-	ua->aalgos = xt->aalgos;
-	ua->ealgos = xt->ealgos;
-	ua->calgos = xt->calgos;
-	ua->seq = x->km.seq = seq;
+
+	if (compat) {
+		compat_ua = nlmsg_data(nlh);
+		compat_ua->aalgos = xt->aalgos;
+		compat_ua->ealgos = xt->ealgos;
+		compat_ua->calgos = xt->calgos;
+		compat_ua->seq = x->km.seq = seq;
+	} else {
+		ua->aalgos = xt->aalgos;
+		ua->ealgos = xt->ealgos;
+		ua->calgos = xt->calgos;
+		ua->seq = x->km.seq = seq;
+	}
 
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
@@ -2432,15 +2707,19 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 			     struct xfrm_policy *xp, int dir)
 {
 	struct net *net = xs_net(x);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *cskb;
 
 	skb = nlmsg_new(xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_acquire(skb, x, xt, xp, dir) < 0)
+	if (build_acquire(skb, x, xt, xp, dir, false) < 0)
 		BUG();
 
+	cskb = xfrm_add_compatskb(skb, xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
+	if (cskb)
+		build_acquire(cskb, x, xt, xp, dir, true);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
 }
 
@@ -2513,12 +2792,16 @@ static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 }
 
 static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
-			   int dir, struct km_event *c)
+			   int dir, struct km_event *c, bool compat)
 {
 	struct xfrm_user_polexpire *upe;
 	size_t len = sizeof(*upe);
 	struct nlmsghdr *nlh;
 	int hard = c->data.hard;
+	struct compat_xfrm_user_polexpire *upe_cmpt;
+
+	if (compat)
+		len = sizeof(*upe_cmpt);
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, len, 0);
 	if (nlh == NULL)
@@ -2532,7 +2815,12 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 		goto nlmsg_failure;
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
-	upe->hard = !!hard;
+	if (compat) {
+		upe_cmpt = nlmsg_data(nlh);
+		upe_cmpt->hard = !!hard;
+	} else {
+		upe->hard = !!hard;
+	}
 
 	return nlmsg_end(skb, nlh);
 
@@ -2544,15 +2832,19 @@ nlmsg_failure:
 static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_event *c)
 {
 	struct net *net = xp_net(xp);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *cskb;
 
 	skb = nlmsg_new(xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
 
-	if (build_polexpire(skb, xp, dir, c) < 0)
+	if (build_polexpire(skb, xp, dir, c, false) < 0)
 		BUG();
 
+	cskb = xfrm_add_compatskb(skb, xfrm_polexpire_msgsize(xp), GFP_ATOMIC);
+	if (cskb)
+		build_polexpire(cskb, xp, dir, c, true);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
@@ -2577,9 +2869,16 @@ static int xfrm_notify_policy_headlen(const struct km_event *c)
 	return sizeof(struct xfrm_userpolicy_info);
 }
 
+static int compat_xfrm_notify_policy_headlen(const struct km_event *c)
+{
+	if (c->event == XFRM_MSG_DELPOLICY)
+		return sizeof(struct xfrm_userpolicy_id);
+	return sizeof(struct compat_xfrm_userpolicy_info);
+}
+
 static int copy_to_user_xfrm_notify_policy(struct sk_buff *skb, int dir,
 					   struct xfrm_policy *xp,
-					   struct km_event *c)
+					   struct km_event *c, bool compat)
 {
 	struct xfrm_userpolicy_info *p;
 	struct xfrm_userpolicy_id *id;
@@ -2587,6 +2886,12 @@ static int copy_to_user_xfrm_notify_policy(struct sk_buff *skb, int dir,
 	int sizeof_userpol_info = sizeof(*p);
 	int headlen = xfrm_notify_policy_headlen(c);
 
+	if (compat) {
+		sizeof_userpol_info =
+				sizeof(struct compat_xfrm_userpolicy_info);
+		headlen = compat_xfrm_notify_policy_headlen(c);
+	}
+
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2628,15 +2933,18 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir,
 			      struct km_event *c)
 {
 	struct net *net = xp_net(xp);
-	struct sk_buff *skb;
+	struct sk_buff *skb, *cskb;
 	int len = xfrm_notify_policy_len(xp, c);
 
 	skb = nlmsg_new(len, GFP_ATOMIC);
 	if (skb == NULL)
 		return -ENOMEM;
-	if (copy_to_user_xfrm_notify_policy(skb, dir, xp, c))
+	if (copy_to_user_xfrm_notify_policy(skb, dir, xp, c, false))
 		goto nlmsg_failure;
 
+	if ((cskb = xfrm_add_compatskb(skb, len, GFP_ATOMIC)))
+		copy_to_user_xfrm_notify_policy(cskb, dir, xp, c, true);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
-- 
1.6.3.3

