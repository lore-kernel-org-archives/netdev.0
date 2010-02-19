From: Florian Westphal <fwestphal@astaro.com>
Subject: [PATCH 2/5] netlink: store MSG_CMSG_COMPAT flag in netlink_skb_parms
Date: Fri, 19 Feb 2010 13:41:44 +0100
Message-ID: <1266583307-3049-3-git-send-email-fwestphal@astaro.com>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Cc: johannes@sipsolutions.net, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48618 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753467Ab0BSMlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:41:44 -0500
In-Reply-To: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This allows the netlink processing context to determine if the data
needs any 32 bit fixups.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 changes since v1: change msg_compat to bool.

 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index fde27c0..c094694 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -164,6 +164,7 @@ struct netlink_skb_parms {
 	__u32			loginuid;	/* Login (audit) uid */
 	__u32			sessionid;	/* Session id (audit) */
 	__u32			sid;		/* SELinux security id */
+	bool			msg_compat;	/* Message needs 32bit fixups */
 };
 
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4910031..5ff97cf 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1328,6 +1328,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).loginuid = audit_get_loginuid(current);
 	NETLINK_CB(skb).sessionid = audit_get_sessionid(current);
+#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
+	NETLINK_CB(skb).msg_compat = !!(msg->msg_flags & MSG_CMSG_COMPAT);
+#endif
 	security_task_getsecid(current, &(NETLINK_CB(skb).sid));
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
-- 
1.6.3.3

