From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/4] netlink: store MSG_CMSG_COMPAT flag in netlink_skb_parms
Date: Tue,  6 Apr 2010 00:27:09 +0200
Message-ID: <1270506431-25578-3-git-send-email-fw@strlen.de>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
Cc: johannes@sipsolutions.net, Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60852 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756545Ab0DEW2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 18:28:54 -0400
In-Reply-To: <1270506431-25578-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows the netlink processing context to determine if the data
needs any 32 bit fixups.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 6eaca5e..031e528 100644
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
index beaada0..47c8314 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1339,6 +1339,9 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	NETLINK_CB(skb).dst_group = dst_group;
 	NETLINK_CB(skb).loginuid = audit_get_loginuid(current);
 	NETLINK_CB(skb).sessionid = audit_get_sessionid(current);
+#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
+	NETLINK_CB(skb).msg_compat = !!(msg->msg_flags & MSG_CMSG_COMPAT);
+#endif
 	security_task_getsecid(current, &(NETLINK_CB(skb).sid));
 	memcpy(NETLINK_CREDS(skb), &siocb->scm->creds, sizeof(struct ucred));
 
-- 
1.6.4.4

