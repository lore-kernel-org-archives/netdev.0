From: Kevin Cernekee <cernekee@chromium.org>
Subject: [PATCH 4/4] xfrm_user: Add new 32/64-agnostic netlink messages
Date: Fri, 20 Jan 2017 16:05:07 -0800
Message-ID: <20170121000507.34381-5-cernekee@chromium.org>
References: <20170121000507.34381-1-cernekee@chromium.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        selinux@tycho.nsa.gov, fw@strlen.de, fan.du@windriver.com,
        dianders@chromium.org, dtor@chromium.org
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, paul@paul-moore.com, sds@tycho.nsa.gov,
        eparis@parisplace.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170121000507.34381-1-cernekee@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add several new message types to address longstanding 32-bit/64-bit
compatibility issues.  Use xfrm_user_legacy to handle the existing
message types, which will retain the old IDs for compatibility with
existing binaries.

For user->kernel messages, the nlmsg_type will determine whether to use
the old format or the new format (for both requests and replies).  For
kernel->user multicasts, both types will be sent.

setsockopt() will deduce the format from the length.

Signed-off-by: Kevin Cernekee <cernekee@chromium.org>
---
 include/uapi/linux/xfrm.h   | 152 ++++++++++++++++++++++++++++++---------
 net/xfrm/xfrm_user.c        | 136 ++++++++++++++++++++++++++++++++---
 net/xfrm/xfrm_user.h        |  75 ++++++++++++++++++++
 net/xfrm/xfrm_user_legacy.c | 169 ++++++++++++++++++++++++++++----------------
 security/selinux/nlmsgtab.c |  61 +++++++++-------
 5 files changed, 466 insertions(+), 127 deletions(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 1fc62b239f1b..ae5f97681989 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -1,6 +1,7 @@
 #ifndef _LINUX_XFRM_H
 #define _LINUX_XFRM_H
 
+#include <linux/compiler.h>
 #include <linux/in6.h>
 #include <linux/types.h>
 
@@ -157,34 +158,34 @@ enum {
 enum {
 	XFRM_MSG_BASE = 0x10,
 
-	XFRM_MSG_NEWSA = 0x10,
-#define XFRM_MSG_NEWSA XFRM_MSG_NEWSA
-	XFRM_MSG_DELSA,
-#define XFRM_MSG_DELSA XFRM_MSG_DELSA
-	XFRM_MSG_GETSA,
-#define XFRM_MSG_GETSA XFRM_MSG_GETSA
-
-	XFRM_MSG_NEWPOLICY,
-#define XFRM_MSG_NEWPOLICY XFRM_MSG_NEWPOLICY
-	XFRM_MSG_DELPOLICY,
-#define XFRM_MSG_DELPOLICY XFRM_MSG_DELPOLICY
-	XFRM_MSG_GETPOLICY,
-#define XFRM_MSG_GETPOLICY XFRM_MSG_GETPOLICY
-
-	XFRM_MSG_ALLOCSPI,
-#define XFRM_MSG_ALLOCSPI XFRM_MSG_ALLOCSPI
-	XFRM_MSG_ACQUIRE,
-#define XFRM_MSG_ACQUIRE XFRM_MSG_ACQUIRE
-	XFRM_MSG_EXPIRE,
-#define XFRM_MSG_EXPIRE XFRM_MSG_EXPIRE
-
-	XFRM_MSG_UPDPOLICY,
-#define XFRM_MSG_UPDPOLICY XFRM_MSG_UPDPOLICY
-	XFRM_MSG_UPDSA,
-#define XFRM_MSG_UPDSA XFRM_MSG_UPDSA
-
-	XFRM_MSG_POLEXPIRE,
-#define XFRM_MSG_POLEXPIRE XFRM_MSG_POLEXPIRE
+	XFRM_MSG_NEWSA_LEGACY = 0x10,
+#define XFRM_MSG_NEWSA_LEGACY XFRM_MSG_NEWSA_LEGACY
+	XFRM_MSG_DELSA_LEGACY,
+#define XFRM_MSG_DELSA_LEGACY XFRM_MSG_DELSA_LEGACY
+	XFRM_MSG_GETSA_LEGACY,
+#define XFRM_MSG_GETSA_LEGACY XFRM_MSG_GETSA_LEGACY
+
+	XFRM_MSG_NEWPOLICY_LEGACY,
+#define XFRM_MSG_NEWPOLICY_LEGACY XFRM_MSG_NEWPOLICY_LEGACY
+	XFRM_MSG_DELPOLICY_LEGACY,
+#define XFRM_MSG_DELPOLICY_LEGACY XFRM_MSG_DELPOLICY_LEGACY
+	XFRM_MSG_GETPOLICY_LEGACY,
+#define XFRM_MSG_GETPOLICY_LEGACY XFRM_MSG_GETPOLICY_LEGACY
+
+	XFRM_MSG_ALLOCSPI_LEGACY,
+#define XFRM_MSG_ALLOCSPI_LEGACY XFRM_MSG_ALLOCSPI_LEGACY
+	XFRM_MSG_ACQUIRE_LEGACY,
+#define XFRM_MSG_ACQUIRE_LEGACY XFRM_MSG_ACQUIRE_LEGACY
+	XFRM_MSG_EXPIRE_LEGACY,
+#define XFRM_MSG_EXPIRE_LEGACY XFRM_MSG_EXPIRE_LEGACY
+
+	XFRM_MSG_UPDPOLICY_LEGACY,
+#define XFRM_MSG_UPDPOLICY_LEGACY XFRM_MSG_UPDPOLICY_LEGACY
+	XFRM_MSG_UPDSA_LEGACY,
+#define XFRM_MSG_UPDSA_LEGACY XFRM_MSG_UPDSA_LEGACY
+
+	XFRM_MSG_POLEXPIRE_LEGACY,
+#define XFRM_MSG_POLEXPIRE_LEGACY XFRM_MSG_POLEXPIRE_LEGACY
 
 	XFRM_MSG_FLUSHSA,
 #define XFRM_MSG_FLUSHSA XFRM_MSG_FLUSHSA
@@ -214,6 +215,34 @@ enum {
 
 	XFRM_MSG_MAPPING,
 #define XFRM_MSG_MAPPING XFRM_MSG_MAPPING
+
+	XFRM_MSG_ALLOCSPI,
+#define XFRM_MSG_ALLOCSPI XFRM_MSG_ALLOCSPI
+	XFRM_MSG_ACQUIRE,
+#define XFRM_MSG_ACQUIRE XFRM_MSG_ACQUIRE
+	XFRM_MSG_EXPIRE,
+#define XFRM_MSG_EXPIRE XFRM_MSG_EXPIRE
+	XFRM_MSG_POLEXPIRE,
+#define XFRM_MSG_POLEXPIRE XFRM_MSG_POLEXPIRE
+
+	XFRM_MSG_NEWSA,
+#define XFRM_MSG_NEWSA XFRM_MSG_NEWSA
+	XFRM_MSG_UPDSA,
+#define XFRM_MSG_UPDSA XFRM_MSG_UPDSA
+	XFRM_MSG_DELSA,
+#define XFRM_MSG_DELSA XFRM_MSG_DELSA
+	XFRM_MSG_GETSA,
+#define XFRM_MSG_GETSA XFRM_MSG_GETSA
+
+	XFRM_MSG_NEWPOLICY,
+#define XFRM_MSG_NEWPOLICY XFRM_MSG_NEWPOLICY
+	XFRM_MSG_UPDPOLICY,
+#define XFRM_MSG_UPDPOLICY XFRM_MSG_UPDPOLICY
+	XFRM_MSG_DELPOLICY,
+#define XFRM_MSG_DELPOLICY XFRM_MSG_DELPOLICY
+	XFRM_MSG_GETPOLICY,
+#define XFRM_MSG_GETPOLICY XFRM_MSG_GETPOLICY
+
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -221,7 +250,7 @@ enum {
 #define XFRM_NR_MSGTYPES (XFRM_MSG_MAX + 1 - XFRM_MSG_BASE)
 
 /*
- * Generic LSM security context for comunicating to user space
+ * Generic LSM security context for communicating to user space
  * NOTE: Same format as sadb_x_sec_ctx
  */
 struct xfrm_user_sec_ctx {
@@ -357,6 +386,22 @@ struct xfrmu_spdhthresh {
 	__u8 rbits;
 };
 
+/* Legacy structs are incompatible between 32-bit and 64-bit. */
+struct xfrm_usersa_info_legacy {
+	struct xfrm_selector		sel;
+	struct xfrm_id			id;
+	xfrm_address_t			saddr;
+	struct xfrm_lifetime_cfg	lft;
+	struct xfrm_lifetime_cur	curlft;
+	struct xfrm_stats		stats;
+	__u32				seq;
+	__u32				reqid;
+	__u16				family;
+	__u8				mode;		/* XFRM_MODE_xxx */
+	__u8				replay_window;
+	__u8				flags;
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
@@ -378,7 +423,8 @@ struct xfrm_usersa_info {
 #define XFRM_STATE_AF_UNSPEC	32
 #define XFRM_STATE_ALIGN4	64
 #define XFRM_STATE_ESN		128
-};
+	__u8				reserved[7];
+} __packed;
 
 #define XFRM_SA_XFLAG_DONT_ENCAP_DSCP	1
 
@@ -396,10 +442,28 @@ struct xfrm_aevent_id {
 	__u32				reqid;
 };
 
+struct xfrm_userspi_info_legacy {
+	struct xfrm_usersa_info_legacy	info;
+	__u32				min;
+	__u32				max;
+};
+
 struct xfrm_userspi_info {
 	struct xfrm_usersa_info		info;
 	__u32				min;
 	__u32				max;
+} __packed;
+
+struct xfrm_userpolicy_info_legacy {
+	struct xfrm_selector		sel;
+	struct xfrm_lifetime_cfg	lft;
+	struct xfrm_lifetime_cur	curlft;
+	__u32				priority;
+	__u32				index;
+	__u8				dir;
+	__u8				action;
+	__u8				flags;
+	__u8				share;
 };
 
 struct xfrm_userpolicy_info {
@@ -417,7 +481,8 @@ struct xfrm_userpolicy_info {
 	/* Automatically expand selector to include matching ICMP payloads. */
 #define XFRM_POLICY_ICMP	2
 	__u8				share;
-};
+	__u8				reserved[4];
+} __packed;
 
 struct xfrm_userpolicy_id {
 	struct xfrm_selector		sel;
@@ -425,6 +490,17 @@ struct xfrm_userpolicy_id {
 	__u8				dir;
 };
 
+struct xfrm_user_acquire_legacy {
+	struct xfrm_id				id;
+	xfrm_address_t				saddr;
+	struct xfrm_selector			sel;
+	struct xfrm_userpolicy_info_legacy	policy;
+	__u32					aalgos;
+	__u32					ealgos;
+	__u32					calgos;
+	__u32					seq;
+};
+
 struct xfrm_user_acquire {
 	struct xfrm_id			id;
 	xfrm_address_t			saddr;
@@ -434,17 +510,29 @@ struct xfrm_user_acquire {
 	__u32				ealgos;
 	__u32				calgos;
 	__u32				seq;
+} __packed;
+
+struct xfrm_user_expire_legacy {
+	struct xfrm_usersa_info_legacy	state;
+	__u8				hard;
 };
 
 struct xfrm_user_expire {
 	struct xfrm_usersa_info		state;
 	__u8				hard;
+	__u8				reserved[7];
+} __packed;
+
+struct xfrm_user_polexpire_legacy {
+	struct xfrm_userpolicy_info_legacy	pol;
+	__u8					hard;
 };
 
 struct xfrm_user_polexpire {
 	struct xfrm_userpolicy_info	pol;
 	__u8				hard;
-};
+	__u8				reserved[7];
+} __packed;
 
 struct xfrm_usersa_flush {
 	__u8				proto;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4d733f02c3a1..5456dde974bc 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2350,6 +2350,32 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = sizeof(u32),
 	[XFRM_MSG_NEWSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
+
+	[XFRM_MSG_ALLOCSPI_LEGACY  - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_userspi_info_legacy),
+	[XFRM_MSG_ACQUIRE_LEGACY   - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_user_acquire_legacy),
+	[XFRM_MSG_EXPIRE_LEGACY    - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_user_expire_legacy),
+	[XFRM_MSG_POLEXPIRE_LEGACY - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_user_polexpire_legacy),
+
+	[XFRM_MSG_NEWSA_LEGACY     - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_usersa_info_legacy),
+	[XFRM_MSG_UPDSA_LEGACY     - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_usersa_info_legacy),
+	[XFRM_MSG_DELSA_LEGACY     - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_usersa_id),
+	[XFRM_MSG_GETSA_LEGACY     - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_usersa_id),
+	[XFRM_MSG_NEWPOLICY_LEGACY - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_userpolicy_info_legacy),
+	[XFRM_MSG_UPDPOLICY_LEGACY - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_userpolicy_info_legacy),
+	[XFRM_MSG_DELPOLICY_LEGACY - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_userpolicy_id),
+	[XFRM_MSG_GETPOLICY_LEGACY - XFRM_MSG_BASE] =
+		XMSGSIZE(xfrm_userpolicy_id),
 };
 
 #undef XMSGSIZE
@@ -2396,6 +2422,7 @@ static const struct xfrm_link {
 	int (*done)(struct netlink_callback *);
 	const struct nla_policy *nla_pol;
 	int nla_max;
+	bool legacy;
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
@@ -2423,6 +2450,62 @@ static const struct xfrm_link {
 						   .nla_pol = xfrma_spd_policy,
 						   .nla_max = XFRMA_SPD_MAX },
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
+
+#ifdef CONFIG_XFRM_USER_LEGACY
+	[XFRM_MSG_ALLOCSPI_LEGACY  - XFRM_MSG_BASE] = {
+		.doit = xfrm_alloc_userspi_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_ACQUIRE_LEGACY   - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_acquire_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_EXPIRE_LEGACY    - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_sa_expire_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_POLEXPIRE_LEGACY - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_pol_expire_legacy,
+		.legacy = true,
+	},
+
+	[XFRM_MSG_NEWSA_LEGACY     - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_sa_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_UPDSA_LEGACY     - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_sa_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_DELSA_LEGACY     - XFRM_MSG_BASE] = {
+		.doit = xfrm_del_sa_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_GETSA_LEGACY     - XFRM_MSG_BASE] = {
+		.doit = xfrm_get_sa_legacy,
+		.dump = xfrm_dump_sa_legacy,
+		.done = xfrm_dump_sa_done_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_NEWPOLICY_LEGACY - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_policy_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_UPDPOLICY_LEGACY - XFRM_MSG_BASE] = {
+		.doit = xfrm_add_policy_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_DELPOLICY_LEGACY - XFRM_MSG_BASE] = {
+		.doit = xfrm_get_policy_legacy,
+		.legacy = true,
+	},
+	[XFRM_MSG_GETPOLICY_LEGACY - XFRM_MSG_BASE] = {
+		.doit = xfrm_get_policy_legacy,
+		.dump = xfrm_dump_policy_legacy,
+		.done = xfrm_dump_policy_done_legacy,
+		.legacy = true,
+	},
+#endif /* CONFIG_XFRM_USER_LEGACY */
 };
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
@@ -2432,11 +2515,6 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct xfrm_link *link;
 	int type, err;
 
-#ifdef CONFIG_COMPAT
-	if (in_compat_syscall())
-		return -EOPNOTSUPP;
-#endif
-
 	type = nlh->nlmsg_type;
 	if (type > XFRM_MSG_MAX)
 		return -EINVAL;
@@ -2444,12 +2522,19 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	type -= XFRM_MSG_BASE;
 	link = &xfrm_dispatch[type];
 
+#ifdef CONFIG_COMPAT
+	if (link->legacy && in_compat_syscall())
+		return -EOPNOTSUPP;
+#endif
+
 	/* All operations require privileges, even GET */
 	if (!netlink_net_capable(skb, CAP_NET_ADMIN))
 		return -EPERM;
 
 	if ((type == (XFRM_MSG_GETSA - XFRM_MSG_BASE) ||
-	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE)) &&
+	     type == (XFRM_MSG_GETPOLICY - XFRM_MSG_BASE) ||
+	     type == (XFRM_MSG_GETSA_LEGACY - XFRM_MSG_BASE) ||
+	     type == (XFRM_MSG_GETPOLICY_LEGACY - XFRM_MSG_BASE)) &&
 	    (nlh->nlmsg_flags & NLM_F_DUMP)) {
 		if (link->dump == NULL)
 			return -EINVAL;
@@ -2670,16 +2755,23 @@ static int xfrm_notify_sa(const struct xfrm_state *x, const struct km_event *c)
 static int xfrm_send_state_notify(const struct xfrm_state *x,
 				  const struct km_event *c)
 {
+	int err;
 
 	switch (c->event) {
 	case XFRM_MSG_EXPIRE:
-		return xfrm_exp_state_notify(x, c);
+		err = xfrm_exp_state_notify(x, c);
+		if (err)
+			return err;
+		return xfrm_exp_state_notify_legacy(x, c);
 	case XFRM_MSG_NEWAE:
 		return xfrm_aevent_state_notify(x, c);
 	case XFRM_MSG_DELSA:
 	case XFRM_MSG_UPDSA:
 	case XFRM_MSG_NEWSA:
-		return xfrm_notify_sa(x, c);
+		err = xfrm_notify_sa(x, c);
+		if (err)
+			return err;
+		return xfrm_notify_sa_legacy(x, c);
 	case XFRM_MSG_FLUSHSA:
 		return xfrm_notify_sa_flush(c);
 	default:
@@ -2748,6 +2840,7 @@ static int xfrm_send_acquire(struct xfrm_state *x,
 {
 	struct net *net = xs_net(x);
 	struct sk_buff *skb;
+	int err;
 
 	skb = nlmsg_new(xfrm_acquire_msgsize(x, xp), GFP_ATOMIC);
 	if (skb == NULL)
@@ -2756,7 +2849,11 @@ static int xfrm_send_acquire(struct xfrm_state *x,
 	if (build_acquire(skb, x, xt, xp) < 0)
 		BUG();
 
-	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
+	err = xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_ACQUIRE);
+	if (err)
+		return err;
+
+	return xfrm_send_acquire_legacy(x, xt, xp);
 }
 
 /* User gives us xfrm_user_policy_info followed by an array of 0
@@ -2799,6 +2896,16 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 		return NULL;
 
 	nr = ((len - sizeof(*p)) / sizeof(*ut));
+	if (len == (nr + 1) * sizeof(*ut) + sizeof(*p) - sizeof(u32)) {
+		/* The user passed a legacy xfrm_userpolicy_info struct whose
+		 * length is padded to 32 bits instead of 64, so the above
+		 * division had a remainder.  Adjust the start address and
+		 * count accordingly.
+		 */
+		ut = (void *)data + sizeof(*p) - sizeof(u32);
+		nr++;
+	}
+
 	if (validate_tmpl(nr, ut, p->sel.family))
 		return NULL;
 
@@ -2979,16 +3086,23 @@ static int xfrm_send_policy_notify(const struct xfrm_policy *xp,
 				   int dir,
 				   const struct km_event *c)
 {
+	int err;
 
 	switch (c->event) {
 	case XFRM_MSG_NEWPOLICY:
 	case XFRM_MSG_UPDPOLICY:
 	case XFRM_MSG_DELPOLICY:
-		return xfrm_notify_policy(xp, dir, c);
+		err = xfrm_notify_policy(xp, dir, c);
+		if (err)
+			return err;
+		return xfrm_notify_policy_legacy(xp, dir, c);
 	case XFRM_MSG_FLUSHPOLICY:
 		return xfrm_notify_policy_flush(c);
 	case XFRM_MSG_POLEXPIRE:
-		return xfrm_exp_policy_notify(xp, dir, c);
+		err = xfrm_exp_policy_notify(xp, dir, c);
+		if (err)
+			return err;
+		return xfrm_exp_policy_notify_legacy(xp, dir, c);
 	default:
 		printk(KERN_NOTICE "xfrm_user: Unknown Policy event %d\n",
 		       c->event);
diff --git a/net/xfrm/xfrm_user.h b/net/xfrm/xfrm_user.h
index 29bab2ebee83..78627d1c1cec 100644
--- a/net/xfrm/xfrm_user.h
+++ b/net/xfrm/xfrm_user.h
@@ -1,6 +1,7 @@
 #ifndef _XFRM_USER_H
 #define _XFRM_USER_H
 
+#include <linux/errno.h>
 #include <linux/netlink.h>
 #include <linux/skbuff.h>
 #include <linux/types.h>
@@ -87,4 +88,78 @@ static inline int copy_to_user_state_sec_ctx(const struct xfrm_state *x,
 	return 0;
 }
 
+/* Legacy functions */
+
+#ifdef CONFIG_XFRM_USER_LEGACY
+int xfrm_alloc_userspi_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      struct nlattr **attrs);
+int xfrm_add_pol_expire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			       struct nlattr **attrs);
+int xfrm_add_sa_expire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			      struct nlattr **attrs);
+int xfrm_add_acquire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			    struct nlattr **attrs);
+
+int xfrm_add_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs);
+int xfrm_del_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs);
+int xfrm_dump_sa_done_legacy(struct netlink_callback *cb);
+int xfrm_dump_sa_legacy(struct sk_buff *skb, struct netlink_callback *cb);
+int xfrm_get_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+		       struct nlattr **attrs);
+int xfrm_add_policy_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   struct nlattr **attrs);
+int xfrm_dump_policy_done_legacy(struct netlink_callback *cb);
+int xfrm_dump_policy_legacy(struct sk_buff *skb, struct netlink_callback *cb);
+int xfrm_get_policy_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+			   struct nlattr **attrs);
+
+int xfrm_exp_state_notify_legacy(const struct xfrm_state *x,
+				 const struct km_event *c);
+int xfrm_notify_sa_legacy(const struct xfrm_state *x, const struct km_event *c);
+int xfrm_send_acquire_legacy(struct xfrm_state *x,
+			     const struct xfrm_tmpl *xt,
+			     const struct xfrm_policy *xp);
+int xfrm_exp_policy_notify_legacy(const struct xfrm_policy *xp,
+				  int dir,
+				  const struct km_event *c);
+int xfrm_notify_policy_legacy(const struct xfrm_policy *xp,
+			      int dir,
+			      const struct km_event *c);
+#else /* CONFIG_XFRM_USER_LEGACY */
+static inline int xfrm_exp_state_notify_legacy(const struct xfrm_state *x,
+					       const struct km_event *c)
+{
+	return 0;
+}
+
+static inline int xfrm_notify_sa_legacy(const struct xfrm_state *x,
+					const struct km_event *c)
+{
+	return 0;
+}
+
+static inline int xfrm_send_acquire_legacy(struct xfrm_state *x,
+					   const struct xfrm_tmpl *xt,
+					   const struct xfrm_policy *xp)
+{
+	return 0;
+}
+
+static inline int xfrm_exp_policy_notify_legacy(const struct xfrm_policy *xp,
+						int dir,
+						const struct km_event *c)
+{
+	return 0;
+}
+
+static inline int xfrm_notify_policy_legacy(const struct xfrm_policy *xp,
+					    int dir,
+					    const struct km_event *c)
+{
+	return 0;
+}
+#endif /* CONFIG_XFRM_USER_LEGACY */
+
 #endif /* _XFRM_USER_H */
diff --git a/net/xfrm/xfrm_user_legacy.c b/net/xfrm/xfrm_user_legacy.c
index 058accfefc83..aa48845b47fa 100644
--- a/net/xfrm/xfrm_user_legacy.c
+++ b/net/xfrm/xfrm_user_legacy.c
@@ -29,28 +29,33 @@
 #include <asm/unaligned.h>
 #include "xfrm_user.h"
 
-static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_add_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
-	const struct xfrm_usersa_info *p = nlmsg_data(nlh);
+	const struct xfrm_usersa_info_legacy *p = nlmsg_data(nlh);
 	struct xfrm_state *x;
 	int err;
 	struct km_event c;
 
-	err = xfrm_verify_newsa_info(p, attrs);
+	/* This cast is safe because the only difference is end padding. */
+	err = xfrm_verify_newsa_info((const struct xfrm_usersa_info *)p, attrs);
 	if (err)
 		return err;
 
-	x = xfrm_state_construct(net, p, attrs, &err);
+	x = xfrm_state_construct(net, (const struct xfrm_usersa_info *)p,
+				 attrs, &err);
 	if (!x)
 		return err;
 
 	xfrm_state_hold(x);
-	if (nlh->nlmsg_type == XFRM_MSG_NEWSA)
+	if (nlh->nlmsg_type == XFRM_MSG_NEWSA_LEGACY) {
 		err = xfrm_state_add(x);
-	else
+		c.event = XFRM_MSG_NEWSA;
+	} else {
 		err = xfrm_state_update(x);
+		c.event = XFRM_MSG_UPDSA;
+	}
 
 	xfrm_audit_state_add(x, err ? 0 : 1, true);
 
@@ -62,7 +67,6 @@ static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
-	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
 out:
@@ -70,7 +74,7 @@ static int xfrm_add_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_del_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_del_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
@@ -98,7 +102,7 @@ static int xfrm_del_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
-	c.event = nlh->nlmsg_type;
+	c.event = XFRM_MSG_DELSA;
 	km_state_notify(x, &c);
 
 out:
@@ -108,7 +112,7 @@ static int xfrm_del_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 }
 
 static void copy_to_user_state(const struct xfrm_state *x,
-			       struct xfrm_usersa_info *p)
+			       struct xfrm_usersa_info_legacy *p)
 {
 	memset(p, 0, sizeof(*p));
 	memcpy(&p->id, &x->id, sizeof(p->id));
@@ -128,7 +132,7 @@ static void copy_to_user_state(const struct xfrm_state *x,
 }
 
 static int copy_to_user_state_extra(const struct xfrm_state *x,
-				    struct xfrm_usersa_info *p,
+				    struct xfrm_usersa_info_legacy *p,
 				    struct sk_buff *skb)
 {
 	int ret = 0;
@@ -209,12 +213,12 @@ static int dump_one_state(const struct xfrm_state *x, int count, void *ptr)
 	struct xfrm_dump_info *sp = ptr;
 	struct sk_buff *in_skb = sp->in_skb;
 	struct sk_buff *skb = sp->out_skb;
-	struct xfrm_usersa_info *p;
+	struct xfrm_usersa_info_legacy *p;
 	struct nlmsghdr *nlh;
 	int err;
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, sp->nlmsg_seq,
-			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
+			XFRM_MSG_NEWSA_LEGACY, sizeof(*p), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -229,7 +233,7 @@ static int dump_one_state(const struct xfrm_state *x, int count, void *ptr)
 	return 0;
 }
 
-static int xfrm_dump_sa_done(struct netlink_callback *cb)
+int xfrm_dump_sa_done_legacy(struct netlink_callback *cb)
 {
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
 	struct sock *sk = cb->skb->sk;
@@ -241,7 +245,7 @@ static int xfrm_dump_sa_done(struct netlink_callback *cb)
 }
 
 static const struct nla_policy xfrma_policy[XFRMA_MAX+1];
-static int xfrm_dump_sa(struct sk_buff *skb, struct netlink_callback *cb)
+int xfrm_dump_sa_legacy(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
@@ -311,7 +315,7 @@ static struct sk_buff *xfrm_state_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
-static int xfrm_get_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_get_sa_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
@@ -335,12 +339,12 @@ static int xfrm_get_sa(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_alloc_userspi(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_alloc_userspi_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			      struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
-	const struct xfrm_userspi_info *p;
+	const struct xfrm_userspi_info_legacy *p;
 	struct sk_buff *resp_skb;
 	const xfrm_address_t *daddr;
 	int family;
@@ -395,7 +399,7 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, const struct nlmsghdr *nlh,
 }
 
 static void copy_to_user_policy(const struct xfrm_policy *xp,
-				struct xfrm_userpolicy_info *p,
+				struct xfrm_userpolicy_info_legacy *p,
 				int dir)
 {
 	memset(p, 0, sizeof(*p));
@@ -411,24 +415,27 @@ static void copy_to_user_policy(const struct xfrm_policy *xp,
 	p->share = XFRM_SHARE_ANY; /* XXX xp->share */
 }
 
-static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_add_policy_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			   struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
-	const struct xfrm_userpolicy_info *p = nlmsg_data(nlh);
+	const struct xfrm_userpolicy_info_legacy *p = nlmsg_data(nlh);
 	struct xfrm_policy *xp;
 	struct km_event c;
 	int err;
 	int excl;
 
-	err = xfrm_verify_newpolicy_info(p);
+	/* This cast is safe because the only difference is end padding. */
+	err = xfrm_verify_newpolicy_info(
+		(const struct xfrm_userpolicy_info *)p);
 	if (err)
 		return err;
 	err = xfrm_verify_sec_ctx_len(attrs);
 	if (err)
 		return err;
 
-	xp = xfrm_policy_construct(net, p, attrs, &err);
+	xp = xfrm_policy_construct(net, (const struct xfrm_userpolicy_info *)p,
+				   attrs, &err);
 	if (!xp)
 		return err;
 
@@ -436,7 +443,13 @@ static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	 * Aha! this is anti-netlink really i.e  more pfkey derived
 	 * in netlink excl is a flag and you wouldnt need
 	 * a type XFRM_MSG_UPDPOLICY - JHS */
-	excl = nlh->nlmsg_type == XFRM_MSG_NEWPOLICY;
+	if (nlh->nlmsg_type == XFRM_MSG_NEWPOLICY_LEGACY) {
+		excl = 1;
+		c.event = XFRM_MSG_NEWPOLICY;
+	} else {
+		excl = 0;
+		c.event = XFRM_MSG_UPDPOLICY;
+	}
 	err = xfrm_policy_insert(p->dir, xp, excl);
 	xfrm_audit_policy_add(xp, err ? 0 : 1, true);
 
@@ -446,7 +459,6 @@ static int xfrm_add_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 		return err;
 	}
 
-	c.event = nlh->nlmsg_type;
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
 	km_policy_notify(xp, p->dir, &c);
@@ -471,14 +483,14 @@ static int dump_one_policy(const struct xfrm_policy *xp,
 			   void *ptr)
 {
 	struct xfrm_dump_info *sp = ptr;
-	struct xfrm_userpolicy_info *p;
+	struct xfrm_userpolicy_info_legacy *p;
 	struct sk_buff *in_skb = sp->in_skb;
 	struct sk_buff *skb = sp->out_skb;
 	struct nlmsghdr *nlh;
 	int err;
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).portid, sp->nlmsg_seq,
-			XFRM_MSG_NEWPOLICY, sizeof(*p), sp->nlmsg_flags);
+			XFRM_MSG_NEWPOLICY_LEGACY, sizeof(*p), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -499,7 +511,7 @@ static int dump_one_policy(const struct xfrm_policy *xp,
 	return 0;
 }
 
-static int xfrm_dump_policy_done(struct netlink_callback *cb)
+int xfrm_dump_policy_done_legacy(struct netlink_callback *cb)
 {
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
 	struct net *net = sock_net(cb->skb->sk);
@@ -508,7 +520,7 @@ static int xfrm_dump_policy_done(struct netlink_callback *cb)
 	return 0;
 }
 
-static int xfrm_dump_policy(struct sk_buff *skb, struct netlink_callback *cb)
+int xfrm_dump_policy_legacy(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
@@ -559,7 +571,7 @@ static struct sk_buff *xfrm_policy_netlink(struct sk_buff *in_skb,
 	return skb;
 }
 
-static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_get_policy_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			   struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
@@ -573,7 +585,13 @@ static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	u32 mark = xfrm_mark_get(attrs, &m);
 
 	p = nlmsg_data(nlh);
-	delete = nlh->nlmsg_type == XFRM_MSG_DELPOLICY;
+	if (nlh->nlmsg_type == XFRM_MSG_DELPOLICY_LEGACY) {
+		delete = 1;
+		c.event = XFRM_MSG_DELPOLICY;
+	} else {
+		delete = 0;
+		c.event = XFRM_MSG_GETPOLICY;
+	}
 
 	err = xfrm_copy_from_user_policy_type(&type, attrs);
 	if (err)
@@ -625,7 +643,6 @@ static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			goto out;
 
 		c.data.byid = p->index;
-		c.event = nlh->nlmsg_type;
 		c.seq = nlh->nlmsg_seq;
 		c.portid = nlh->nlmsg_pid;
 		km_policy_notify(xp, p->dir, &c);
@@ -638,13 +655,13 @@ static int xfrm_get_policy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_add_pol_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_add_pol_expire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			       struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_policy *xp;
-	const struct xfrm_user_polexpire *up = nlmsg_data(nlh);
-	const struct xfrm_userpolicy_info *p = &up->pol;
+	const struct xfrm_user_polexpire_legacy *up = nlmsg_data(nlh);
+	const struct xfrm_userpolicy_info_legacy *p = &up->pol;
 	u8 type = XFRM_POLICY_TYPE_MAIN;
 	int err = -ENOENT;
 	struct xfrm_mark m;
@@ -698,14 +715,14 @@ static int xfrm_add_pol_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_add_sa_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_add_sa_expire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			      struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
 	struct xfrm_state *x;
 	int err;
-	const struct xfrm_user_expire *ue = nlmsg_data(nlh);
-	const struct xfrm_usersa_info *p = &ue->state;
+	const struct xfrm_user_expire_legacy *ue = nlmsg_data(nlh);
+	const struct xfrm_usersa_info_legacy *p = &ue->state;
 	struct xfrm_mark m;
 	u32 mark = xfrm_mark_get(attrs, &m);
 
@@ -732,7 +749,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	return err;
 }
 
-static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
+int xfrm_add_acquire_legacy(struct sk_buff *skb, const struct nlmsghdr *nlh,
 			    struct nlattr **attrs)
 {
 	struct net *net = sock_net(skb->sk);
@@ -742,7 +759,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 	struct nlattr *rt = attrs[XFRMA_TMPL];
 	struct xfrm_mark mark;
 
-	const struct xfrm_user_acquire *ua = nlmsg_data(nlh);
+	const struct xfrm_user_acquire_legacy *ua = nlmsg_data(nlh);
 	struct xfrm_state *x = xfrm_state_alloc(net);
 	int err = -ENOMEM;
 
@@ -751,12 +768,15 @@ static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 	xfrm_mark_get(attrs, &mark);
 
-	err = xfrm_verify_newpolicy_info(&ua->policy);
+	/* This cast is safe because the only difference is end padding. */
+	err = xfrm_verify_newpolicy_info(
+		(const struct xfrm_userpolicy_info *)&ua->policy);
 	if (err)
 		goto free_state;
 
 	/*   build an XP */
-	xp = xfrm_policy_construct(net, &ua->policy, attrs, &err);
+	xp = xfrm_policy_construct(net, (const struct xfrm_userpolicy_info *)
+				   &ua->policy, attrs, &err);
 	if (!xp)
 		goto free_state;
 
@@ -793,7 +813,7 @@ static int xfrm_add_acquire(struct sk_buff *skb, const struct nlmsghdr *nlh,
 
 static inline size_t xfrm_expire_msgsize(void)
 {
-	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire))
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_expire_legacy))
 	       + nla_total_size(sizeof(struct xfrm_mark));
 }
 
@@ -801,11 +821,12 @@ static int build_expire(struct sk_buff *skb,
 			const struct xfrm_state *x,
 			const struct km_event *c)
 {
-	struct xfrm_user_expire *ue;
+	struct xfrm_user_expire_legacy *ue;
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_EXPIRE, sizeof(*ue), 0);
+	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_EXPIRE_LEGACY,
+			sizeof(*ue), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -821,7 +842,7 @@ static int build_expire(struct sk_buff *skb,
 	return 0;
 }
 
-static int xfrm_exp_state_notify(const struct xfrm_state *x,
+int xfrm_exp_state_notify_legacy(const struct xfrm_state *x,
 				 const struct km_event *c)
 {
 	struct net *net = xs_net(x);
@@ -839,15 +860,16 @@ static int xfrm_exp_state_notify(const struct xfrm_state *x,
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
-static int xfrm_notify_sa(const struct xfrm_state *x, const struct km_event *c)
+int xfrm_notify_sa_legacy(const struct xfrm_state *x, const struct km_event *c)
 {
 	struct net *net = xs_net(x);
-	struct xfrm_usersa_info *p;
+	struct xfrm_usersa_info_legacy *p;
 	struct xfrm_usersa_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	int len = xfrm_sa_len(x);
 	int headlen, err;
+	u32 event = 0;
 
 	headlen = sizeof(*p);
 	if (c->event == XFRM_MSG_DELSA) {
@@ -861,7 +883,19 @@ static int xfrm_notify_sa(const struct xfrm_state *x, const struct km_event *c)
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->portid, c->seq, c->event, headlen, 0);
+	switch (c->event) {
+	case XFRM_MSG_NEWSA:
+		event = XFRM_MSG_NEWSA_LEGACY;
+		break;
+	case XFRM_MSG_UPDSA:
+		event = XFRM_MSG_UPDSA_LEGACY;
+		break;
+	case XFRM_MSG_DELSA:
+		event = XFRM_MSG_DELSA_LEGACY;
+		break;
+	}
+
+	nlh = nlmsg_put(skb, c->portid, c->seq, event, headlen, 0);
 	err = -EMSGSIZE;
 	if (nlh == NULL)
 		goto out_free_skb;
@@ -899,7 +933,7 @@ static int xfrm_notify_sa(const struct xfrm_state *x, const struct km_event *c)
 static inline size_t xfrm_acquire_msgsize(const struct xfrm_state *x,
 					  const struct xfrm_policy *xp)
 {
-	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire))
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_acquire_legacy))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
 	       + nla_total_size(sizeof(struct xfrm_mark))
 	       + nla_total_size(xfrm_user_sec_ctx_size(x->security))
@@ -912,11 +946,11 @@ static int build_acquire(struct sk_buff *skb,
 			 const struct xfrm_policy *xp)
 {
 	__u32 seq = xfrm_get_acqseq();
-	struct xfrm_user_acquire *ua;
+	struct xfrm_user_acquire_legacy *ua;
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE, sizeof(*ua), 0);
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_ACQUIRE_LEGACY, sizeof(*ua), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -946,7 +980,7 @@ static int build_acquire(struct sk_buff *skb,
 	return 0;
 }
 
-static int xfrm_send_acquire(struct xfrm_state *x,
+int xfrm_send_acquire_legacy(struct xfrm_state *x,
 			     const struct xfrm_tmpl *xt,
 			     const struct xfrm_policy *xp)
 {
@@ -965,7 +999,7 @@ static int xfrm_send_acquire(struct xfrm_state *x,
 
 static inline size_t xfrm_polexpire_msgsize(const struct xfrm_policy *xp)
 {
-	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire))
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_polexpire_legacy))
 	       + nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr)
 	       + nla_total_size(xfrm_user_sec_ctx_size(xp->security))
 	       + nla_total_size(sizeof(struct xfrm_mark))
@@ -977,12 +1011,13 @@ static int build_polexpire(struct sk_buff *skb,
 			   int dir,
 			   const struct km_event *c)
 {
-	struct xfrm_user_polexpire *upe;
+	struct xfrm_user_polexpire_legacy *upe;
 	int hard = c->data.hard;
 	struct nlmsghdr *nlh;
 	int err;
 
-	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_POLEXPIRE, sizeof(*upe), 0);
+	nlh = nlmsg_put(skb, c->portid, 0, XFRM_MSG_POLEXPIRE_LEGACY,
+			sizeof(*upe), 0);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -1005,7 +1040,7 @@ static int build_polexpire(struct sk_buff *skb,
 	return 0;
 }
 
-static int xfrm_exp_policy_notify(const struct xfrm_policy *xp,
+int xfrm_exp_policy_notify_legacy(const struct xfrm_policy *xp,
 				  int dir,
 				  const struct km_event *c)
 {
@@ -1022,19 +1057,21 @@ static int xfrm_exp_policy_notify(const struct xfrm_policy *xp,
 	return xfrm_nlmsg_multicast(net, skb, 0, XFRMNLGRP_EXPIRE);
 }
 
-static int xfrm_notify_policy(const struct xfrm_policy *xp,
+int xfrm_notify_policy_legacy(const struct xfrm_policy *xp,
 			      int dir,
 			      const struct km_event *c)
 {
 	int len = nla_total_size(sizeof(struct xfrm_user_tmpl) * xp->xfrm_nr);
 	struct net *net = xp_net(xp);
-	struct xfrm_userpolicy_info *p;
+	struct xfrm_userpolicy_info_legacy *p;
 	struct xfrm_userpolicy_id *id;
 	struct nlmsghdr *nlh;
 	struct sk_buff *skb;
 	int headlen, err;
+	u32 event = 0;
 
 	headlen = sizeof(*p);
+
 	if (c->event == XFRM_MSG_DELPOLICY) {
 		len += nla_total_size(headlen);
 		headlen = sizeof(*id);
@@ -1047,7 +1084,19 @@ static int xfrm_notify_policy(const struct xfrm_policy *xp,
 	if (skb == NULL)
 		return -ENOMEM;
 
-	nlh = nlmsg_put(skb, c->portid, c->seq, c->event, headlen, 0);
+	switch (c->event) {
+	case XFRM_MSG_NEWPOLICY:
+		event = XFRM_MSG_NEWPOLICY_LEGACY;
+		break;
+	case XFRM_MSG_UPDPOLICY:
+		event = XFRM_MSG_UPDPOLICY_LEGACY;
+		break;
+	case XFRM_MSG_DELPOLICY:
+		event = XFRM_MSG_DELPOLICY_LEGACY;
+		break;
+	}
+
+	nlh = nlmsg_put(skb, c->portid, c->seq, event, headlen, 0);
 	err = -EMSGSIZE;
 	if (nlh == NULL)
 		goto out_free_skb;
diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
index 2ca9cde939d4..15e8b1381c13 100644
--- a/security/selinux/nlmsgtab.c
+++ b/security/selinux/nlmsgtab.c
@@ -90,29 +90,42 @@ static struct nlmsg_perm nlmsg_tcpdiag_perms[] =
 
 static struct nlmsg_perm nlmsg_xfrm_perms[] =
 {
-	{ XFRM_MSG_NEWSA,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_DELSA,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_GETSA,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_NEWPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_DELPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_GETPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_ALLOCSPI,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_ACQUIRE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_EXPIRE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_UPDPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_UPDSA,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_POLEXPIRE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_FLUSHSA,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_REPORT,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_MIGRATE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
-	{ XFRM_MSG_GETSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
-	{ XFRM_MSG_MAPPING,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWSA_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_DELSA_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETSA_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWPOLICY_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_DELPOLICY_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETPOLICY_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_ALLOCSPI_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_ACQUIRE_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_EXPIRE_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_UPDPOLICY_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_UPDSA_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_POLEXPIRE_LEGACY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_FLUSHSA,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_FLUSHPOLICY,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_NEWAE,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETAE,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_REPORT,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MIGRATE,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_NEWSADINFO,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_GETSADINFO,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWSPDINFO,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETSPDINFO,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_MAPPING,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_ALLOCSPI,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_ACQUIRE,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_EXPIRE,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_POLEXPIRE,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_NEWSA,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_NEWSA,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_UPDSA,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_DELSA,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETSA,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
+	{ XFRM_MSG_NEWPOLICY,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_UPDPOLICY,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_DELPOLICY,		NETLINK_XFRM_SOCKET__NLMSG_WRITE },
+	{ XFRM_MSG_GETPOLICY,		NETLINK_XFRM_SOCKET__NLMSG_READ  },
 };
 
 static struct nlmsg_perm nlmsg_audit_perms[] =
@@ -168,7 +181,7 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
 		break;
 
 	case SECCLASS_NETLINK_XFRM_SOCKET:
-		BUILD_BUG_ON(XFRM_MSG_MAX != XFRM_MSG_MAPPING);
+		BUILD_BUG_ON(XFRM_MSG_MAX != XFRM_MSG_GETPOLICY);
 		err = nlmsg_perm(nlmsg_type, perm, nlmsg_xfrm_perms,
 				 sizeof(nlmsg_xfrm_perms));
 		break;
-- 
2.11.0.483.g087da7b7c-goog
