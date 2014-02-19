From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits ip command on 64bits host
Date: Wed, 19 Feb 2014 17:12:56 +0800
Message-ID: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60534 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbaBSJRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 04:17:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to setup IPsec configuration on a 64bits host with
iproute2(32bits compiled), the intended xfrm policy and sa is
either deficit or wrong when kernel trying to parse user land
information.

Add compat support for 32bits compiled ip command for 64bits host.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 include/uapi/linux/xfrm.h |   44 ++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c      |   16 +++++++++++++++-
 2 files changed, 59 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index a8cd6a4..8d2fa8d 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -506,4 +506,48 @@ enum xfrm_nlgroups {
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
 
+#ifdef CONFIG_COMPAT
+
+struct compat_xfrm_userpolicy_info {
+	struct xfrm_selector		sel;
+	struct xfrm_lifetime_cfg	lft;
+	struct xfrm_lifetime_cur	curlft;
+	__u32				priority;
+	__u32				index;
+	__u8				dir;
+	__u8				action;
+#define XFRM_POLICY_ALLOW	0
+#define XFRM_POLICY_BLOCK	1
+	__u8				flags;
+#define XFRM_POLICY_LOCALOK	1	/* Allow user to override global policy */
+	/* Automatically expand selector to include matching ICMP payloads. */
+#define XFRM_POLICY_ICMP	2
+	__u8				share;
+} __attribute__((packed));
+
+struct compat_xfrm_usersa_info {
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
+#define XFRM_STATE_NOECN	1
+#define XFRM_STATE_DECAP_DSCP	2
+#define XFRM_STATE_NOPMTUDISC	4
+#define XFRM_STATE_WILDRECV	8
+#define XFRM_STATE_ICMP		16
+#define XFRM_STATE_AF_UNSPEC	32
+#define XFRM_STATE_ALIGN4	64
+#define XFRM_STATE_ESN		128
+} __attribute__((packed));
+
+#endif
+
 #endif /* _LINUX_XFRM_H */
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ae3ec7..8bfbd95 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2281,6 +2281,12 @@ static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 };
 
+static const int compat_xfrm_msg_min[XFRM_NR_MSGTYPES] = {
+	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = XMSGSIZE(compat_xfrm_usersa_info),
+	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(compat_xfrm_userpolicy_info),
+	[XFRM_MSG_UPDPOLICY   - XFRM_MSG_BASE] = XMSGSIZE(compat_xfrm_userpolicy_info),
+};
+
 #undef XMSGSIZE
 
 static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
@@ -2346,6 +2352,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *attrs[XFRMA_MAX+1];
 	const struct xfrm_link *link;
 	int type, err;
+	int len;
 
 	type = nlh->nlmsg_type;
 	if (type > XFRM_MSG_MAX)
@@ -2373,7 +2380,14 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		}
 	}
 
-	err = nlmsg_parse(nlh, xfrm_msg_min[type], attrs, XFRMA_MAX,
+#ifdef CONFIG_COMPAT
+	if (is_compat_task())
+		len = compat_xfrm_msg_min[type];
+	else
+#endif
+		len = xfrm_msg_min[type];
+
+	err = nlmsg_parse(nlh, len, attrs, XFRMA_MAX,
 			  xfrma_policy);
 	if (err < 0)
 		return err;
-- 
1.7.9.5
