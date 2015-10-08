From: Edward Hyunkoo Jee <edjee@google.com>
Subject: [PATCH net-next 1/2] sock: support per-packet fwmark
Date: Thu,  8 Oct 2015 14:56:48 -0700
Message-ID: <1444341409-28729-1-git-send-email-edjee@google.com>
Cc: edumazet@google.com, willemb@google.com,
	Edward Hyunkoo Jee <edjee@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35134 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758884AbbJHV6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 17:58:31 -0400
Received: by pabve7 with SMTP id ve7so7216339pab.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 14:58:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's useful to allow users to set fwmark for an individual packet,
without changing the socket state. The function this patch adds in
sock layer can be used by the protocols that need such a feature.

Signed-off-by: Edward Hyunkoo Jee <edjee@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h |  7 +++++++
 net/core/sock.c    | 26 ++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index dfe2eb8..03ca20f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1514,6 +1514,13 @@ void sock_kfree_s(struct sock *sk, void *mem, int size);
 void sock_kzfree_s(struct sock *sk, void *mem, int size);
 void sk_send_sigurg(struct sock *sk);
 
+struct sockcm_cookie {
+	u32 mark;
+};
+
+int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
+		   struct sockcm_cookie *sockc);
+
 /*
  * Functions to fill in entries in struct proto_ops when a protocol
  * does not implement a particular function.
diff --git a/net/core/sock.c b/net/core/sock.c
index 7dd1263..3395777 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1852,6 +1852,32 @@ struct sk_buff *sock_alloc_send_skb(struct sock *sk, unsigned long size,
 }
 EXPORT_SYMBOL(sock_alloc_send_skb);
 
+int sock_cmsg_send(struct sock *sk, struct msghdr *msg,
+		   struct sockcm_cookie *sockc)
+{
+	struct cmsghdr *cmsg;
+
+	for_each_cmsghdr(cmsg, msg) {
+		if (!CMSG_OK(msg, cmsg))
+			return -EINVAL;
+		if (cmsg->cmsg_level != SOL_SOCKET)
+			continue;
+		switch (cmsg->cmsg_type) {
+		case SO_MARK:
+			if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+				return -EPERM;
+			if (cmsg->cmsg_len != CMSG_LEN(sizeof(u32)))
+				return -EINVAL;
+			sockc->mark = *(u32 *)CMSG_DATA(cmsg);
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(sock_cmsg_send);
+
 /* On 32bit arches, an skb frag is limited to 2^15 */
 #define SKB_FRAG_PAGE_ORDER	get_order(32768)
 
-- 
2.6.0.rc2.230.g3dd15c0
