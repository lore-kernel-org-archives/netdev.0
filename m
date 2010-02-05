From: Florian Westphal <fw@strlen.de>
Subject: [RFC] xfrm: x86_64 CONFIG_COMPAT support
Date: Fri, 5 Feb 2010 02:47:44 +0100
Message-ID: <20100205014744.GD28659@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:59380 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932877Ab0BEBrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 20:47:45 -0500
Received: id: fw by Chamillionaire.breakpoint.cc with local
	(easymta 1.00 BETA 1)
	id 1NdDIO-00056O-Ch
	for netdev@vger.kernel.org; Fri, 05 Feb 2010 02:47:44 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At the moment, it is not possible to use the xfrm netlink interface on
x86_64 with a 32bit userland.

The problem is due to a few structures, notably struct xfrm_usersa_info,
which have different sizes in user/kernelspace (3 byte padding on x86, 7
byte on x86_64). Thus, when the kernel skips the family specific header,
it skips 4 additional bytes; netlink verification thus fails.

What follows is a (incomplete, untested) draft patch that tries
to solve this by introducing a delta table.  With the changes in place
so far its possible to run
"ip xfrm state add ..." with a 32bit ip binary.

Unfortunately, the MSG_COMPAT flag seems to get lost along
the way, so this uses x86_64 is_compat_task() for now.

The delta table is not sufficient, as struct xfrm_usersa_info
can be embedded inside other structs, so when accessing data
after xfrm_usersa_info, one has to use an appropriate compat
structure definition.

Before I spend any more time on this, my questions are:

- does this approach look somewhat sane to you?
- do you have any suggestions how xfrm CONFIG_COMPAT support should
  look like?
- are you aware of pitfalls other than xfrm structure padding?
- are there platforms other than x86_64 that have this problem?

Thanks in advance, Florian

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index d5a7129..e8747fb 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -11,6 +11,7 @@
  */
 
 #include <linux/crypto.h>
+#include <linux/compat.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -31,6 +32,35 @@
 #include <linux/in6.h>
 #endif
 
+#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
+#define XFRM_COMPAT_TEST is_compat_task()
+/* userspace size decreases by this amount due to padding */
+static const u8 xfrm_msg_min_compat_pad[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = 4,
+	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = 4,
+
+	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = 4, /* need converter */
+	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = 4, /* need converter */
+	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = 4, /* need converter */
+	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = 4,
+	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = 4,
+	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = 4, /* need converter */
+
+	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = 4,
+	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = 4,
+};
+
+#else
+#define XFRM_COMPAT_TEST 0
+#endif	/* defined(CONFIG_X86_64) && defined(CONFIG_COMPAT) */
+
+struct xfrm_compat_userspi_info {
+	__u32 xfrm_usersa_info[55];
+	__u32 min, max;
+};
+
+static int xfrm_msg_hdrlen(int type);
+
 static inline int aead_len(struct xfrm_algo_aead *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -700,9 +730,10 @@ static int dump_one_state(struct xfrm_state *x, int count, void *ptr)
 	struct xfrm_usersa_info *p;
 	struct nlmsghdr *nlh;
 	int err;
+	int type = XFRM_MSG_NEWSA - XFRM_MSG_BASE;
 
 	nlh = nlmsg_put(skb, NETLINK_CB(in_skb).pid, sp->nlmsg_seq,
-			XFRM_MSG_NEWSA, sizeof(*p), sp->nlmsg_flags);
+			XFRM_MSG_NEWSA, xfrm_msg_hdrlen(type), sp->nlmsg_flags);
 	if (nlh == NULL)
 		return -EMSGSIZE;
 
@@ -916,6 +947,30 @@ out_noput:
 
 static int verify_userspi_info(struct xfrm_userspi_info *p)
 {
+	if (XFRM_COMPAT_TEST) {
+		struct xfrm_compat_userspi_info *compat = (struct xfrm_compat_userspi_info  *) p;
+
+		switch (p->info.id.proto) {
+		case IPPROTO_AH:
+		case IPPROTO_ESP:
+			break;
+
+		case IPPROTO_COMP:
+			/* IPCOMP spi is 16-bits. */
+			if (compat->max >= 0x10000)
+				return -EINVAL;
+		break;
+
+		default:
+			return -EINVAL;
+		}
+
+		if (compat->min > compat->max)
+			return -EINVAL;
+
+		return 0;
+	}
+
 	switch (p->info.id.proto) {
 	case IPPROTO_AH:
 	case IPPROTO_ESP:
@@ -974,7 +1029,12 @@ static int xfrm_alloc_userspi(struct sk_buff *skb, struct nlmsghdr *nlh,
 	if (x == NULL)
 		goto out_noput;
 
-	err = xfrm_alloc_spi(x, p->min, p->max);
+	if (XFRM_COMPAT_TEST) {
+		struct xfrm_compat_userspi_info *compat = (struct xfrm_compat_userspi_info  *) p;
+		err = xfrm_alloc_spi(x, compat->min, compat->max);
+	} else {
+		err = xfrm_alloc_spi(x, p->min, p->max);
+	}
 	if (err)
 		goto out;
 
@@ -2102,6 +2162,13 @@ static struct xfrm_link {
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = { .doit = xfrm_get_spdinfo   },
 };
 
+static int xfrm_msg_hdrlen(int type)
+{
+	if (unlikely(XFRM_COMPAT_TEST))
+		return xfrm_msg_min[type] - xfrm_msg_min_compat_pad[type];
+	return xfrm_msg_min[type];
+}
+
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2129,7 +2196,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return netlink_dump_start(net->xfrm.nlsk, skb, nlh, link->dump, link->done);
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
+	err = nlmsg_parse(nlh, xfrm_msg_hdrlen(type), attrs, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;
