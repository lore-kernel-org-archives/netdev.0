From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 09/16] [XFRM] netlink: Use nlmsg_parse() to parse attributes
Date: Wed, 22 Aug 2007 16:55:47 +0200
Message-ID: <20070822145631.073291531@lsx.localdomain>
References: <20070822145538.861270927@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56949 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762794AbXHVP3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:29:16 -0400
Content-Disposition: inline; filename=xfrm_parse_attr
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uses nlmsg_parse() to parse the attributes. This actually changes
behaviour as unknown attributes (type > MAXTYPE) no longer cause
an error. Instead unknown attributes will be ignored henceforth
to keep older kernels compatible with more recent userspace tools.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.24/net/xfrm/xfrm_user.c
===================================================================
--- net-2.6.24.orig/net/xfrm/xfrm_user.c	2007-08-21 17:07:38.000000000 +0200
+++ net-2.6.24/net/xfrm/xfrm_user.c	2007-08-21 17:31:04.000000000 +0200
@@ -1890,7 +1890,7 @@ static int xfrm_send_migrate(struct xfrm
 }
 #endif
 
-#define XMSGSIZE(type) NLMSG_LENGTH(sizeof(struct type))
+#define XMSGSIZE(type) sizeof(struct type)
 
 static const int xfrm_msg_min[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
@@ -1906,13 +1906,13 @@ static const int xfrm_msg_min[XFRM_NR_MS
 	[XFRM_MSG_UPDSA       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_info),
 	[XFRM_MSG_POLEXPIRE   - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_polexpire),
 	[XFRM_MSG_FLUSHSA     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_usersa_flush),
-	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = NLMSG_LENGTH(0),
+	[XFRM_MSG_FLUSHPOLICY - XFRM_MSG_BASE] = 0,
 	[XFRM_MSG_NEWAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_GETAE       - XFRM_MSG_BASE] = XMSGSIZE(xfrm_aevent_id),
 	[XFRM_MSG_REPORT      - XFRM_MSG_BASE] = XMSGSIZE(xfrm_user_report),
 	[XFRM_MSG_MIGRATE     - XFRM_MSG_BASE] = XMSGSIZE(xfrm_userpolicy_id),
-	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = NLMSG_LENGTH(sizeof(u32)),
-	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = NLMSG_LENGTH(sizeof(u32)),
+	[XFRM_MSG_GETSADINFO  - XFRM_MSG_BASE] = sizeof(u32),
+	[XFRM_MSG_GETSPDINFO  - XFRM_MSG_BASE] = sizeof(u32),
 };
 
 #undef XMSGSIZE
@@ -1946,9 +1946,9 @@ static struct xfrm_link {
 
 static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
-	struct rtattr *xfrma[XFRMA_MAX];
+	struct nlattr *xfrma[XFRMA_MAX+1];
 	struct xfrm_link *link;
-	int type, min_len;
+	int type, err;
 
 	type = nlh->nlmsg_type;
 	if (type > XFRM_MSG_MAX)
@@ -1970,30 +1970,16 @@ static int xfrm_user_rcv_msg(struct sk_b
 		return netlink_dump_start(xfrm_nl, skb, nlh, link->dump, NULL);
 	}
 
-	memset(xfrma, 0, sizeof(xfrma));
-
-	if (nlh->nlmsg_len < (min_len = xfrm_msg_min[type]))
-		return -EINVAL;
-
-	if (nlh->nlmsg_len > min_len) {
-		int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
-		struct rtattr *attr = (void *) nlh + NLMSG_ALIGN(min_len);
-
-		while (RTA_OK(attr, attrlen)) {
-			unsigned short flavor = attr->rta_type;
-			if (flavor) {
-				if (flavor > XFRMA_MAX)
-					return -EINVAL;
-				xfrma[flavor - 1] = attr;
-			}
-			attr = RTA_NEXT(attr, attrlen);
-		}
-	}
+	/* FIXME: Temporary hack, nlmsg_parse() starts at xfrma[1], old code
+	 * expects first attribute at xfrma[0] */
+	err = nlmsg_parse(nlh, xfrm_msg_min[type], xfrma-1, XFRMA_MAX, NULL);
+	if (err < 0)
+		return err;
 
 	if (link->doit == NULL)
 		return -EINVAL;
 
-	return link->doit(skb, nlh, xfrma);
+	return link->doit(skb, nlh, (struct rtattr **) xfrma);
 }
 
 static void xfrm_netlink_rcv(struct sock *sk, int len)

-- 

