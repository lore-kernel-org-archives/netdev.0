From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [PATCH 2/5] [XFRM]: User inteface for handling XFRM_MSG_MIGRATE
Date: Wed, 07 Feb 2007 22:18:10 +0900
Message-ID: <20070207214501.90BD.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:36784 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161006AbXBGNSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 08:18:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add user interface for handling XFRM_MSG_MIGRATE. The message is issued
by user application. When kernel receives the message, procedure of
updating XFRM databases will take place.

Signed-off-by: Shinta Sugimoto <shinta.sugimoto@ericsson.com>
Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/xfrm/xfrm_user.c |  173 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 173 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 82f36d3..8d9a56a 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1632,6 +1632,176 @@ static int xfrm_add_acquire(struct sk_bu
 	return 0;
 }
 
+#ifdef CONFIG_XFRM_MIGRATE
+static int verify_user_migrate(struct rtattr **xfrma)
+{
+	struct rtattr *rt = xfrma[XFRMA_MIGRATE-1];
+	struct xfrm_user_migrate *um;
+
+	if (!rt)
+		return -EINVAL;
+
+	if ((rt->rta_len - sizeof(*rt)) < sizeof(*um))
+		return -EINVAL;
+
+	return 0;
+}
+
+static int copy_from_user_migrate(struct xfrm_migrate *ma,
+				  struct rtattr **xfrma, int *num)
+{
+	struct rtattr *rt = xfrma[XFRMA_MIGRATE-1];
+	struct xfrm_user_migrate *um;
+	int i, num_migrate;
+
+	um = RTA_DATA(rt);
+	num_migrate = (rt->rta_len - sizeof(*rt)) / sizeof(*um);
+
+	if (num_migrate <= 0 || num_migrate > XFRM_MAX_DEPTH)
+		return -EINVAL;
+
+	for (i = 0; i < num_migrate; i++, um++, ma++) {
+		ma->proto = um->proto;
+		ma->mode = um->mode;
+		ma->reqid = um->reqid;
+
+		ma->old_family = um->old_family;
+		memcpy(&ma->old_daddr, &um->old_daddr, sizeof(ma->old_daddr));
+		memcpy(&ma->old_saddr, &um->old_saddr, sizeof(ma->old_saddr));
+
+		ma->new_family = um->new_family;
+		memcpy(&ma->new_daddr, &um->new_daddr, sizeof(ma->new_daddr));
+		memcpy(&ma->new_saddr, &um->new_saddr, sizeof(ma->new_saddr));
+	}
+
+	*num = i;
+	return 0;
+}
+
+static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
+			   struct rtattr **xfrma)
+{
+	struct xfrm_userpolicy_id *pi = NLMSG_DATA(nlh);
+	struct xfrm_migrate m[XFRM_MAX_DEPTH];
+	u8 type;
+	int err;
+	int n = 0;
+
+	err = verify_user_migrate((struct rtattr **)xfrma);
+	if (err)
+		return err;
+
+	err = copy_from_user_policy_type(&type, (struct rtattr **)xfrma);
+	if (err)
+		return err;
+
+	err = copy_from_user_migrate((struct xfrm_migrate *)m,
+				     (struct rtattr **)xfrma, &n);
+	if (err)
+		return err;
+
+	if (!n)
+		return 0;
+
+	xfrm_migrate(&pi->sel, pi->dir, type, m, n);
+
+	return 0;
+}
+#else
+static int xfrm_do_migrate(struct sk_buff *skb, struct nlmsghdr *nlh,
+			   struct rtattr **xfrma)
+{
+	return -ENOPROTOOPT;
+}
+#endif
+
+#ifdef CONFIG_XFRM_MIGRATE
+static int copy_to_user_migrate(struct xfrm_migrate *m, struct sk_buff *skb)
+{
+	struct xfrm_user_migrate um;
+
+	memset(&um, 0, sizeof(um));
+	um.proto = m->proto;
+	um.mode = m->mode;
+	um.reqid = m->reqid;
+	um.old_family = m->old_family;
+	memcpy(&um.old_daddr, &m->old_daddr, sizeof(um.old_daddr));
+	memcpy(&um.old_saddr, &m->old_saddr, sizeof(um.old_saddr));
+	um.new_family = m->new_family;
+	memcpy(&um.new_daddr, &m->new_daddr, sizeof(um.new_daddr));
+	memcpy(&um.new_saddr, &m->new_saddr, sizeof(um.new_saddr));
+
+	RTA_PUT(skb, XFRMA_MIGRATE, sizeof(um), &um);
+	return 0;
+
+rtattr_failure:
+	return -1;
+}
+
+static int build_migrate(struct sk_buff *skb, struct xfrm_migrate *m,
+			 int num_migrate, struct xfrm_selector *sel,
+			 u8 dir, u8 type)
+{
+	struct xfrm_migrate *mp;
+	struct xfrm_userpolicy_id *pol_id;
+	struct nlmsghdr *nlh;
+	unsigned char *b = skb->tail;
+	int i;
+
+	nlh = NLMSG_PUT(skb, 0, 0, XFRM_MSG_MIGRATE, sizeof(*pol_id));
+	pol_id = NLMSG_DATA(nlh);
+	nlh->nlmsg_flags = 0;
+
+	/* copy data from selector, dir, and type to the pol_id */
+	memset(pol_id, 0, sizeof(*pol_id));
+	memcpy(&pol_id->sel, sel, sizeof(pol_id->sel));
+	pol_id->dir = dir;
+
+	if (copy_to_user_policy_type(type, skb) < 0)
+		goto nlmsg_failure;
+
+	for (i = 0, mp = m ; i < num_migrate; i++, mp++) {
+		if (copy_to_user_migrate(mp, skb) < 0)
+			goto nlmsg_failure;
+	}
+
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+nlmsg_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+			     struct xfrm_migrate *m, int num_migrate)
+{
+	struct sk_buff *skb;
+	size_t len;
+
+	len = RTA_SPACE(sizeof(struct xfrm_user_migrate) * num_migrate);
+	len += NLMSG_SPACE(sizeof(struct xfrm_userpolicy_id));
+#ifdef CONFIG_XFRM_SUB_POLICY
+	len += RTA_SPACE(sizeof(struct xfrm_userpolicy_type));
+#endif
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	/* build migrate */
+	if (build_migrate(skb, m, num_migrate, sel, dir, type) < 0)
+		BUG();
+
+	NETLINK_CB(skb).dst_group = XFRMNLGRP_MIGRATE;
+	return netlink_broadcast(xfrm_nl, skb, 0, XFRMNLGRP_MIGRATE,
+				 GFP_ATOMIC);
+}
+#else
+static int xfrm_send_migrate(struct xfrm_selector *sel, u8 dir, u8 type,
+			     struct xfrm_migrate *m, int num_migrate)
+{
+	return -ENOPROTOOPT;
+}
+#endif
 
 #define XMSGSIZE(type) NLMSG_LENGTH(sizeof(struct type))
 
@@ -1653,6 +1823,7 @@ static const int xfrm_msg_min[XFRM_NR_MS
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
+	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
 };
 
 #undef XMSGSIZE
@@ -1679,6 +1850,7 @@ static struct xfrm_link {
 	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = { .doit = xfrm_flush_policy  },
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = { .doit = xfrm_new_ae  },
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = { .doit = xfrm_get_ae  },
+	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = { .doit = xfrm_do_migrate    },
 };
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
@@ -2285,6 +2457,7 @@ static struct xfrm_mgr netlink_mgr = {
 	.compile_policy	= xfrm_compile_policy,
 	.notify_policy	= xfrm_send_policy_notify,
 	.report		= xfrm_send_report,
+	.migrate	= xfrm_send_migrate,
 };
 
 static int __init xfrm_user_init(void)
-- 
1.4.2



