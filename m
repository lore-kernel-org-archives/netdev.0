From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 17/23] [PATCH] [XFRM]: Introduce XFRM_MSG_REPORT.
Date: Sat, 29 Jul 2006 18:30:45 +0900
Message-ID: <11541654453043-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:28291 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161134AbWG2Jaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:46 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

XFRM_MSG_REPORT is a message as notification of state protocol and selector
from kernel to user-space.
Mobile IPv6 will use it when inbound reject is occurred at route optimization
to make user-space know a binding error requirement.
Based on MIPL2 kernel patch.
---
 include/linux/xfrm.h  |   15 ++++++++++++++
 include/net/xfrm.h    |   11 ++++++++++
 net/xfrm/xfrm_state.c |   21 ++++++++++++++++++++
 net/xfrm/xfrm_user.c  |   52 +++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 597a7c7..84a3e76 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -160,6 +160,10 @@ #define XFRM_MSG_FLUSHPOLICY XFRM_MSG_FL
 #define XFRM_MSG_NEWAE XFRM_MSG_NEWAE
 	XFRM_MSG_GETAE,
 #define XFRM_MSG_GETAE XFRM_MSG_GETAE
+
+	XFRM_MSG_REPORT,
+#define XFRM_MSG_REPORT XFRM_MSG_REPORT
+
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -325,12 +329,21 @@ struct xfrm_usersa_flush {
 	__u8				proto;
 };
 
+/*
+ * This notifies flow information to the user space with carrying XFRMA_ADDR.
+ */
+struct xfrm_user_report {
+	__u8			proto;
+	struct xfrm_selector	sel;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
 #define XFRMGRP_SA		4
 #define XFRMGRP_POLICY		8
+#define XFRMGRP_REPORT		0x20
 #endif
 
 enum xfrm_nlgroups {
@@ -346,6 +359,8 @@ #define XFRMNLGRP_SA		XFRMNLGRP_SA
 #define XFRMNLGRP_POLICY	XFRMNLGRP_POLICY
 	XFRMNLGRP_AEVENTS,
 #define XFRMNLGRP_AEVENTS	XFRMNLGRP_AEVENTS
+	XFRMNLGRP_REPORT,
+#define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0b8edad..05d4257 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -383,6 +383,9 @@ struct xfrm_mgr
 	struct xfrm_policy	*(*compile_policy)(u16 family, int opt, u8 *data, int len, int *dir);
 	int			(*new_mapping)(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 	int			(*notify_policy)(struct xfrm_policy *x, int dir, struct km_event *c);
+#ifdef CONFIG_XFRM_ADVANCED
+	int			(*report)(__u8 proto, struct xfrm_selector *sel, void *arg);
+#endif
 };
 
 extern int xfrm_register_km(struct xfrm_mgr *km);
@@ -1042,6 +1045,14 @@ extern wait_queue_head_t km_waitq;
 extern int km_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr, u16 sport);
 extern void km_policy_expired(struct xfrm_policy *pol, int dir, int hard, u32 pid);
 
+#ifdef CONFIG_XFRM_ADVANCED
+extern int km_report(__u8 proto, struct xfrm_selector *sel, void *arg);
+#else
+static inline int km_report(__u8 proto, struct xfrm_selector *sel, void *arg)
+{
+	return -ENOSYS;
+}
+#endif
 extern void xfrm_input_init(void);
 extern int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, u32 *spi, u32 *seq);
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 1bdeecf..0c74e7c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1077,6 +1077,27 @@ void km_policy_expired(struct xfrm_polic
 }
 EXPORT_SYMBOL(km_policy_expired);
 
+#ifdef CONFIG_XFRM_ADVANCED
+int km_report(__u8 proto, struct xfrm_selector *sel, void *arg)
+{
+	int err = -EINVAL;
+	int ret;
+	struct xfrm_mgr *km;
+
+	read_lock(&xfrm_km_lock);
+	list_for_each_entry(km, &xfrm_km_list, list) {
+		if (km->report) {
+			ret = km->report(proto, sel, arg);
+			if (!ret)
+				err = ret;
+		}
+	}
+	read_unlock(&xfrm_km_lock);
+	return err;
+}
+EXPORT_SYMBOL(km_report);
+#endif
+
 int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
 {
 	int err;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index a91367d..8d7bf0a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1443,6 +1443,9 @@ static const int xfrm_msg_min[XFRM_NR_MS
 	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = NLMSG_LENGTH(0),
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
+#ifdef CONFIG_XFRM_ADVANCED
+	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
+#endif
 };
 
 #undef XMSGSIZE
@@ -2001,12 +2004,61 @@ static int xfrm_send_policy_notify(struc
 
 }
 
+#ifdef CONFIG_XFRM_ADVANCED
+static int build_report(struct sk_buff *skb, __u8 proto,
+			struct xfrm_selector *sel, void *arg)
+{
+	xfrm_address_t *addr = (xfrm_address_t *)arg;
+	struct xfrm_user_report *ur;
+	struct nlmsghdr *nlh;
+	unsigned char *b = skb->tail;
+
+	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_REPORT, sizeof(*ur));
+	ur = NLMSG_DATA(nlh);
+	nlh->nlmsg_flags = 0;
+
+	ur->proto = proto;
+	memcpy(&ur->sel, sel, sizeof(ur->sel));
+
+	if (addr)
+		RTA_PUT(skb, XFRMA_ADDR, sizeof(*addr), addr);
+
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int xfrm_send_report(__u8 proto, struct xfrm_selector *sel, void *arg)
+{
+	struct sk_buff *skb;
+	size_t len;
+
+	len = NLMSG_ALIGN(NLMSG_LENGTH(sizeof(struct xfrm_user_report)));
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	if (build_report(skb, proto, sel, arg) < 0)
+		BUG();
+
+	NETLINK_CB(skb).dst_group = XFRMNLGRP_REPORT;
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
+}
+#endif
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
 	.acquire	= xfrm_send_acquire,
 	.compile_policy	= xfrm_compile_policy,
 	.notify_policy	= xfrm_send_policy_notify,
+#ifdef CONFIG_XFRM_ADVANCED
+	.report		= xfrm_send_report,
+#endif
 };
 
 static int __init xfrm_user_init(void)
-- 
1.4.1

