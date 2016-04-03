From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v3 net-next 1/8] sock: break up sock_cmsg_snd into __sock_cmsg_snd and loop
Date: Sat,  2 Apr 2016 23:08:06 -0400
Message-ID: <1459652893-14207-2-git-send-email-soheil.kdev@gmail.com>
References: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:36384 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcDCDIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 23:08:24 -0400
Received: by mail-qg0-f68.google.com with SMTP id n34so14845795qge.3
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 20:08:23 -0700 (PDT)
In-Reply-To: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

To process cmsg's of the SOL_SOCKET level in addition to
cmsgs of another level, protocols can call sock_cmsg_send().
This causes a double walk on the cmsghdr list, one for SOL_SOCKET
and one for the other level.

Extract the inner demultiplex logic from the loop that walks the list,
to allow having this called directly from a walker in the protocol
specific code.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/sock.h |  2 ++
 net/core/sock.c    | 33 ++++++++++++++++++++++-----------
 2 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e0..03772d4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1420,6 +1420,8 @@ struct sockcm_cookie {
 	u32 mark;
 };
 
+int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+		     struct sockcm_cookie *sockc);
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index b67b9ae..66976f8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1866,27 +1866,38 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
+int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
+		     struct sockcm_cookie *sockc)
+{
+	switch (cmsg->cmsg_type) {
+	case SO_MARK:
+		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+		if (cmsg->cmsg_len != CMSG_LEN(sizeof(u32)))
+			return -EINVAL;
+		sockc->mark = *(u32 *)CMSG_DATA(cmsg);
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(__sock_cmsg_send);
+
 int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
 		   struct sockcm_cookie *sockc)
 {
 	struct cmsghdr *cmsg;
+	int ret;
 
 	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 		if (cmsg->cmsg_level != SOL_SOCKET)
 			continue;
-		switch (cmsg->cmsg_type) {
-		case SO_MARK:
-			if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
-				return -EPERM;
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(u32)))
-				return -EINVAL;
-			sockc->mark = *(u32 *)CMSG_DATA(cmsg);
-			break;
-		default:
-			return -EINVAL;
-		}
+		ret = __sock_cmsg_send(sk, msg, cmsg, sockc);
+		if (ret)
+			return ret;
 	}
 	return 0;
 }
-- 
2.8.0.rc3.226.g39d4020
