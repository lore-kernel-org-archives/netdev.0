From: martin@strongswan.org (Martin Willi)
Subject: [PATCH] xfrm: Notify changes in UDP encapsulation via netlink
Date: Mon, 13 Oct 2008 11:27:26 +0200 (CEST)
Message-ID: <20081013092726.49B34EFADF@strongswan.org>
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sidv0150.hsr.ch ([152.96.52.150]:58562 "EHLO strongswan.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761455AbYJMJ5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 05:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new_mapping() implementation to the netlink xfrm_mgr to notify
address/port changes detected in UDP encapsulated ESP packets.

Signed-off-by: Martin Willi <martin@strongswan.org>

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 4bc1e6b..52f3abd 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -199,6 +199,9 @@ enum {
 #define XFRM_MSG_NEWSPDINFO XFRM_MSG_NEWSPDINFO
 	XFRM_MSG_GETSPDINFO,
 #define XFRM_MSG_GETSPDINFO XFRM_MSG_GETSPDINFO
+
+	XFRM_MSG_MAPPING,
+#define XFRM_MSG_MAPPING XFRM_MSG_MAPPING
 	__XFRM_MSG_MAX
 };
 #define XFRM_MSG_MAX (__XFRM_MSG_MAX - 1)
@@ -438,6 +441,15 @@ struct xfrm_user_migrate {
 	__u16				new_family;
 };
 
+struct xfrm_user_mapping {
+	struct xfrm_usersa_id		id;
+	__u32				reqid;
+	xfrm_address_t			old_saddr;
+	xfrm_address_t			new_saddr;
+	__be16				old_sport;
+	__be16				new_sport;
+};
+
 #ifndef __KERNEL__
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
@@ -464,6 +476,8 @@ enum xfrm_nlgroups {
 #define XFRMNLGRP_REPORT	XFRMNLGRP_REPORT
 	XFRMNLGRP_MIGRATE,
 #define XFRMNLGRP_MIGRATE	XFRMNLGRP_MIGRATE
+	XFRMNLGRP_MAPPING,
+#define XFRMNLGRP_MAPPING	XFRMNLGRP_MAPPING
 	__XFRMNLGRP_MAX
 };
 #define XFRMNLGRP_MAX	(__XFRMNLGRP_MAX - 1)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 4a8a1ab..499a516 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2503,6 +2503,57 @@ static int xfrm_send_report(u8 proto, struct xfrm_selector *sel,
 	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_REPORT, GFP_ATOMIC);
 }
 
+static inline size_t xfrm_mapping_msgsize(void)
+{
+	return NLMSG_ALIGN(sizeof(struct xfrm_user_mapping));
+}
+
+static int build_mapping(struct sk_buff *skb, struct xfrm_state *x,
+			 xfrm_address_t *new_saddr, __be16 new_sport)
+{
+	struct xfrm_user_mapping *um;
+	struct nlmsghdr *nlh;
+
+	nlh = nlmsg_put(skb, 0, 0, XFRM_MSG_MAPPING, sizeof(*um), 0);
+	if (nlh == NULL)
+		return -EMSGSIZE;
+
+	um = nlmsg_data(nlh);
+	
+	memcpy(&um->id.daddr, &x->id.daddr, sizeof(um->id.daddr));
+	um->id.spi = x->id.spi;
+	um->id.family = x->props.family;
+	um->id.proto = x->id.proto;
+	memcpy(&um->new_saddr, new_saddr, sizeof(um->new_saddr));
+	memcpy(&um->old_saddr, &x->props.saddr, sizeof(um->old_saddr));
+	um->new_sport = new_sport;
+	um->old_sport = x->encap->encap_sport;
+	um->reqid = x->props.reqid;
+
+	return nlmsg_end(skb, nlh);
+}
+
+static int xfrm_send_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
+			     __be16 sport)
+{
+	struct sk_buff *skb;
+
+	if (x->id.proto != IPPROTO_ESP)
+		return -EINVAL;
+
+	if (!x->encap)
+		return -EINVAL;
+
+	skb = nlmsg_new(xfrm_mapping_msgsize(), GFP_ATOMIC);
+	if (skb == NULL)
+		return -ENOMEM;
+
+	if (build_mapping(skb, x, ipaddr, sport) < 0)
+		BUG();
+
+	return nlmsg_multicast(xfrm_nl, skb, 0, XFRMNLGRP_MAPPING, GFP_ATOMIC);
+}
+
 static struct xfrm_mgr netlink_mgr = {
 	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
@@ -2511,6 +2562,7 @@ static struct xfrm_mgr netlink_mgr = {
 	.notify_policy	= xfrm_send_policy_notify,
 	.report		= xfrm_send_report,
 	.migrate	= xfrm_send_migrate,
+	.new_mapping	= xfrm_send_mapping,
 };
 
 static int __init xfrm_user_init(void)
