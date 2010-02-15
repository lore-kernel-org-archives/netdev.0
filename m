From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 2/5] netlink: store MSG_CMSG_COMPAT flag in netlink_skb_parms
Date: Mon, 15 Feb 2010 17:46:30 +0100
Message-ID: <1266252393-20911-3-git-send-email-fw@strlen.de>
References: <1266252393-20911-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40214 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755119Ab0BOQqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 11:46:32 -0500
In-Reply-To: <1266252393-20911-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows the netlink processing context to determine if the data
needs any 32 bit fixups.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netlink.h  |    1 +
 net/netlink/af_netlink.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index fde27c0..8b30c01 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -164,6 +164,7 @@ struct netlink_skb_parms {
 	__u32			loginuid;	/* Login (audit) uid */
 	__u32			sessionid;	/* Session id (audit) */
 	__u32			sid;		/* SELinux security id */
+	__u8			msg_compat;	/* Message needs 32bit fixups */
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

