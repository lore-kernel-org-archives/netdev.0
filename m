From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 4/5] xfrm: CONFIG_COMPAT support for x86 architecture
Date: Mon, 15 Feb 2010 17:46:32 +0100
Message-ID: <1266252393-20911-5-git-send-email-fw@strlen.de>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40216 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755119Ab0BOQqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 11:46:35 -0500
In-Reply-To: <1266252393-20911-1-git-send-email-fw@strlen.de>
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

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 net/xfrm/Kconfig     |    1 +
 net/xfrm/xfrm_user.c |  372 ++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 360 insertions(+), 13 deletions(-)

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
index bda5c15..5794fa3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -10,6 +10,7 @@
  *
  */
 
+#include <linux/compat.h>
 #include <linux/crypto.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
@@ -31,6 +32,161 @@
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
+	return unlikely(!!NETLINK_CB(skb).msg_compat);
+}
+
+static bool xfrm_add_compatskb(struct sk_buff *skb,
+                               unsigned int len, gfp_t gfp)
+{
+	struct sk_buff *compatskb = nlmsg_new(len, gfp);
+
+	WARN_ON(skb_shinfo(skb)->frag_list);
+
+	if (compatskb)
+		NETLINK_CB(compatskb).msg_compat = 1;
+
+	skb_shinfo(skb)->frag_list = compatskb;
+
+	return compatskb != NULL;
+}
+
+static struct sk_buff *xfrm_get_compatskb(struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->frag_list;
+}
+#else
+static inline bool xfrm_msg_compat(const struct sk_buff *skb)
+{
+	return false;
+}
+
+static inline bool xfrm_add_compatskb(struct sk_buff *skb,
+                                      unsigned int len, gfp_t gfp)
+{
+	return false;
+}
+static inline void compat_xfrm_notify_sa(struct sk_buff *skb,
+                                         struct xfrm_state *x, struct km_event *c)
+{
+}
+
+/*
+ * avoids #ifdefs all over the place. Use of these must be conditional via
+ * xfrm_add_compatskb/xfrm_get_compatskb so compiler can remove branches.
+ */
+#define compat_xfrm_user_expire     xfrm_user_expire
+#define compat_xfrm_user_acquire    xfrm_user_acquire
+#define compat_xfrm_user_polexpire  xfrm_user_polexpire
+#define compat_xfrm_userpolicy_info xfrm_userpolicy_info
+#define compat_xfrm_usersa_info     xfrm_usersa_info
+#define compat_xfrm_userspi_info    xfrm_userspi_info
+
+#endif
+
+/*
+ * userspace size of some structures is smaller by this amount
+ * due to different u64 alignment on x86 platform.
+ *
+ * Some of the structures need to use the compat_* structure definition
+ * when accessing certain members.
+ */
+static const u8 xfrm_msg_min_compat_pad[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = 4, /* padding at end */
+	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = 4, /* padding at end */
+
+	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = 4, /* access might need compat_ */
+	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = 4, /* access might need compat_ */
+	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = 4, /* access might need compat_ */
+	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = 4, /* padding at end */
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = 4, /* padding at end */
+	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = 4, /* access might need compat_ */
+};
+
+static int get_user_expire_hard(const struct sk_buff *skb,
+                                const struct xfrm_user_expire *ue)
+{
+	if (xfrm_msg_compat(skb)) {
+		const struct compat_xfrm_user_expire *cmpt;
+		cmpt = (const struct compat_xfrm_user_expire*) ue;
+		return cmpt->hard;
+	}
+	return ue->hard;
+}
+
+static int get_user_polexpire_hard(const struct sk_buff *skb,
+                                   const struct xfrm_user_polexpire *ue)
+{
+	if (xfrm_msg_compat(skb)) {
+		const struct compat_xfrm_user_polexpire *cmpt;
+		cmpt = (const struct compat_xfrm_user_polexpire*) ue;
+		return cmpt->hard;
+	}
+	return ue->hard;
+}
+
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -700,6 +856,9 @@ static int copy_one_state(struct sk_buff *skb, struct xfrm_state *x, struct xfrm
 	size_t len = sizeof(*p);
 	int err;
 
+	if (xfrm_msg_compat(skb))
+		len = sizeof(struct compat_xfrm_usersa_info);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
 			XFRM_MSG_NEWSA, len, sp->nlmsg_flags);
 	if (nlh == NULL)
@@ -724,6 +883,13 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *skb = sp->out_skb;
 	int ret = copy_one_state(skb, x, sp);
+#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
+	if (ret == 0) {
+		skb = xfrm_get_compatskb(skb);
+		if (skb)
+			copy_one_state(skb, x, sp);
+	}
+#endif
 	return ret;
 }
 
@@ -753,6 +919,8 @@ static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_state_walk_init(walk, 0);
 	}
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+
 	(void) xfrm_state_walk(net, walk, dump_one_state, &info);
 
 	return skb->len;
@@ -944,6 +1112,29 @@ static int verify_userspi_info(struct xfrm_userspi_info *p)
 	return 0;
 }
 
+static int compat_verify_userspi_info(struct xfrm_userspi_info *p __maybe_unused)
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
@@ -956,7 +1147,10 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	int err;
 
 	p = nlmsg_data(nlh);
-	err = verify_userspi_info(p);
+	if (xfrm_msg_compat(skb))
+		err = compat_verify_userspi_info(p);
+	else
+		err = verify_userspi_info(p);
 	if (err)
 		goto out_noput;
 
@@ -980,8 +1174,14 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
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
 
@@ -1359,6 +1559,9 @@ static int copy_one_policy(struct sk_buff *skb, struct xfrm_policy *xp, int dir,
 	struct nlmsghdr *nlh;
 	size_t len = sizeof(*p);
 
+	if (xfrm_msg_compat(skb))
+		len = sizeof(struct compat_xfrm_userpolicy_info);
+
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
 			XFRM_MSG_NEWPOLICY, len, sp->nlmsg_flags);
 	if (nlh == NULL)
@@ -1386,6 +1589,13 @@ static int dump_one_policy(struct xfrm_policy *xp, int dir, int count, void *ptr
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *skb = sp->out_skb;
 	int ret = copy_one_policy(skb, xp, dir, sp);
+#ifdef CONFIG_COMPAT_FOR_U64_ALIGNMENT
+	if (ret == 0) {
+		skb = xfrm_get_compatskb(skb);
+		if (skb)
+			copy_one_policy(skb, xp, dir, sp);
+	}
+#endif
 	return ret;
 }
 
@@ -1416,6 +1626,8 @@ static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
 		xfrm_policy_walk_init(walk, XFRM_POLICY_TYPE_ANY);
 	}
 
+	xfrm_add_compatskb(skb, NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+
 	(void) xfrm_policy_walk(net, walk, dump_one_policy, &info);
 
 	return skb->len;
@@ -1747,7 +1959,7 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	read_unlock(&xp->lock);
 	err = 0;
-	hard = up->hard;
+	hard = get_user_polexpire_hard(skb, up);
 	if (hard) {
 		uid_t loginuid = NETLINK_CB(skb).loginuid;
 		uid_t sessionid = NETLINK_CB(skb).sessionid;
@@ -1785,7 +1997,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	err = -EINVAL;
 	if (x->km.state != XFRM_STATE_VALID)
 		goto out;
-	hard = ue->hard;
+	hard = get_user_expire_hard(skb, ue);
 	km_state_expired(x, hard, current->pid);
 
 	if (hard) {
@@ -1802,6 +2014,23 @@ out:
 	return err;
 }
 
+static void acquire_extract_algos(const struct sk_buff *skb,
+                                  struct xfrm_tmpl *t,
+                                  const struct xfrm_user_acquire *ua)
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
@@ -1839,9 +2068,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, struct nlmsghdr *nlh,
 		x->props.mode = t->mode;
 		x->props.reqid = t->reqid;
 		x->props.family = ut->family;
-		t->aalgos = ua->aalgos;
-		t->ealgos = ua->ealgos;
-		t->calgos = ua->calgos;
+		acquire_extract_algos(skb, t, ua);
 		err = km_query(x, t, xp);
 
 	}
@@ -2122,6 +2349,13 @@ static struct xfrm_link {
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
@@ -2149,7 +2383,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done);
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
+	err = nlmsg_parse(nlh, xfrm_msg_hdrlen(skb, type), attrs, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;
@@ -2188,6 +2422,27 @@ static int build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_eve
 	return nlmsg_end(skb, nlh);
 }
 
+static inline size_t compat_xfrm_expire_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct compat_xfrm_user_expire));
+}
+
+static void compat_build_expire(struct sk_buff *skb, struct xfrm_state *x, struct km_event *c)
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
@@ -2200,6 +2455,9 @@ static int xfrm_exp_state_notify(struct xfrm_state *x, struct km_event *c)
 	if (build_expire(skb, x, c) < 0)
 		BUG();
 
+	if (xfrm_add_compatskb(skb, compat_xfrm_expire_msgsize(), GFP_ATOMIC))
+		compat_build_expire(skb_shinfo(skb)->frag_list, x, c);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
@@ -2293,6 +2551,13 @@ static int xfrm_notify_sa_headlen(const struct km_event *c)
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
                                        struct xfrm_state *x, struct km_event *c)
 {
@@ -2302,6 +2567,11 @@ static int copy_to_user_xfrm_notify_sa(struct sk_buff *skb,
 	int sizeof_xfrm_usersa_info = sizeof(*p);
 	int headlen = xfrm_notify_sa_headlen(c);
 
+	if (xfrm_msg_compat(skb)) {
+		headlen = compat_xfrm_notify_sa_headlen(c);
+		sizeof_xfrm_usersa_info = sizeof(struct compat_xfrm_usersa_info);
+	}
+
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
 		goto nla_put_failure;
@@ -2347,6 +2617,9 @@ static int xfrm_notify_sa(struct xfrm_state *x, struct km_event *c)
 	if (copy_to_user_xfrm_notify_sa(skb, x, c))
 		goto nla_put_failure;
 
+	if (xfrm_add_compatskb(skb, len, GFP_ATOMIC))
+		copy_to_user_xfrm_notify_sa(skb_shinfo(skb)->frag_list, x, c);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_SA, GFP_ATOMIC);
 
 nla_put_failure:
@@ -2388,6 +2661,32 @@ static inline size_t xfrm_acquire_msgsize(struct xfrm_state *x,
 	       + userpolicy_type_attrsize();
 }
 
+static inline size_t compat_xfrm_acquire_msgsize(struct xfrm_state *x,
+					  struct xfrm_policy *xp)
+{
+	return NLMSG_ALIGN(sizeof(struct compat_xfrm_user_acquire))
+	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
+	       + nla_total_size(xfrm_user_sec_ctx_size(x->security))
+	       + userpolicy_type_attrsize();
+}
+
+static void acquire_copy_algos(const struct sk_buff *skb,
+                               struct xfrm_user_acquire *ua,
+                               const struct xfrm_tmpl *xt)
+{
+	if (!xfrm_msg_compat(skb)) {
+		ua->aalgos = xt->aalgos;
+		ua->ealgos = xt->ealgos;
+		ua->calgos = xt->calgos;
+	} else {
+		struct compat_xfrm_user_acquire *compat_ua;
+		compat_ua = (struct compat_xfrm_user_acquire *) ua;
+		compat_ua->aalgos = xt->aalgos;
+		compat_ua->ealgos = xt->ealgos;
+		compat_ua->calgos = xt->calgos;
+	}
+}
+
 static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 			 struct xfrm_tmpl *xt, struct xfrm_policy *xp,
 			 int dir)
@@ -2396,6 +2695,10 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	size_t len = sizeof(*ua);
 	struct nlmsghdr *nlh;
 	__u32 seq = xfrm_get_acqseq();
+	struct compat_xfrm_user_acquire *compat_ua;
+
+	if (xfrm_msg_compat(skb))
+		len = sizeof(*compat_ua);
 
 	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, len, 0);
 	if (nlh == NULL)
@@ -2406,10 +2709,14 @@ static int build_acquire(struct sk_buff *skb, struct xfrm_state *x,
 	memcpy(&ua->saddr, &x->props.saddr, sizeof(ua->saddr));
 	memcpy(&ua->sel, &x->sel, sizeof(ua->sel));
 	copy_to_user_policy(xp, &ua->policy, dir);
-	ua->aalgos = xt->aalgos;
-	ua->ealgos = xt->ealgos;
-	ua->calgos = xt->calgos;
-	ua->seq = x->km.seq = seq;
+	acquire_copy_algos(skb, ua, xt);
+
+	if (xfrm_msg_compat(skb)) {
+		compat_ua = nlmsg_data(nlh);
+		compat_ua->seq = x->km.seq = seq;
+	} else {
+		ua->seq = x->km.seq = seq;
+	}
 
 	if (copy_to_user_tmpl(xp, skb) < 0)
 		goto nlmsg_failure;
@@ -2438,6 +2745,9 @@ static int xfrm_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *xt,
 	if (build_acquire(skb, x, xt, xp, dir) < 0)
 		BUG();
 
+	if (xfrm_add_compatskb(skb, compat_xfrm_acquire_msgsize(x, xp), GFP_ATOMIC))
+		build_acquire(skb_shinfo(skb)->frag_list, x, xt, xp, dir);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_ACQUIRE, GFP_ATOMIC);
 }
 
@@ -2501,6 +2811,14 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	return xp;
 }
 
+static inline size_t compat_xfrm_polexpire_msgsize(struct xfrm_policy *xp)
+{
+	return NLMSG_ALIGN(sizeof(struct compat_xfrm_user_polexpire))
+	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
+	       + nla_total_size(xfrm_user_sec_ctx_size(xp->security))
+	       + userpolicy_type_attrsize();
+}
+
 static inline size_t xfrm_polexpire_msgsize(struct xfrm_policy *xp)
 {
 	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
@@ -2516,6 +2834,10 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 	size_t len = sizeof(*upe);
 	struct nlmsghdr *nlh;
 	int hard = c->data.hard;
+	struct compat_xfrm_user_polexpire *upe_cmpt;
+
+	if (xfrm_msg_compat(skb))
+		len = sizeof(*upe_cmpt);
 
 	nlh = nlmsg_put(skb, c->pid, 0, XFRM_MSG_POLEXPIRE, len, 0);
 	if (nlh == NULL)
@@ -2529,7 +2851,12 @@ static int build_polexpire(struct sk_buff *skb, struct xfrm_policy *xp,
 		goto nlmsg_failure;
 	if (copy_to_user_policy_type(xp->type, skb) < 0)
 		goto nlmsg_failure;
-	upe->hard = !!hard;
+	if (xfrm_msg_compat(skb)) {
+		upe_cmpt = nlmsg_data(nlh);
+		upe_cmpt->hard = !!hard;
+	} else {
+		upe->hard = !!hard;
+	}
 
 	return nlmsg_end(skb, nlh);
 
@@ -2550,6 +2877,9 @@ static int xfrm_exp_policy_notify(struct xfrm_policy *xp, int dir, struct km_eve
 	if (build_polexpire(skb, xp, dir, c) < 0)
 		BUG();
 
+	if (xfrm_add_compatskb(skb, compat_xfrm_polexpire_msgsize(xp), GFP_ATOMIC))
+		build_polexpire(skb_shinfo(skb)->frag_list, xp, dir, c);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_EXPIRE, GFP_ATOMIC);
 }
 
@@ -2574,6 +2904,13 @@ static int xfrm_notify_policy_headlen(const struct km_event *c)
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
                                            struct xfrm_policy *xp, struct km_event *c)
 {
@@ -2583,6 +2920,11 @@ static int copy_to_user_xfrm_notify_policy(struct sk_buff *skb, int dir,
 	int sizeof_xfrm_userpolicy_info = sizeof(*p);
 	int headlen = xfrm_notify_policy_headlen(c);
 
+	if (xfrm_msg_compat(skb)) {
+		sizeof_xfrm_userpolicy_info = sizeof(struct compat_xfrm_userpolicy_info);
+		headlen = compat_xfrm_notify_policy_headlen(c);
+	}
+
 	nlh = nlmsg_put(skb, c->pid, c->seq, c->event, headlen, 0);
 	if (nlh == NULL)
 		goto nlmsg_failure;
@@ -2632,6 +2974,10 @@ static int xfrm_notify_policy(struct xfrm_policy *xp, int dir, struct km_event *
 	if (copy_to_user_xfrm_notify_policy(skb, dir, xp, c))
 		goto nlmsg_failure;
 
+	if (xfrm_add_compatskb(skb, len, GFP_ATOMIC))
+		copy_to_user_xfrm_notify_policy(skb_shinfo(skb)->frag_list,
+						dir, xp, c);
+
 	return nlmsg_multicast(net->xfrm.nlsk, skb, 0, XFRMNLGRP_POLICY, GFP_ATOMIC);
 
 nlmsg_failure:
-- 
1.6.3.3

