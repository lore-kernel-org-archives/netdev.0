From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 4/8] sock: accept SO_TIMESTAMPING flags in socket cmsg
Date: Wed, 30 Mar 2016 18:37:24 -0400
Message-ID: <1459377448-2239-5-git-send-email-soheil.kdev@gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:36447 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbcC3Wht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 18:37:49 -0400
Received: by mail-qg0-f65.google.com with SMTP id n34so6175551qge.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 15:37:48 -0700 (PDT)
In-Reply-To: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Accept SO_TIMESTAMPING in control messages of the SOL_SOCKET level
as a basis to accept timestamping requests per write.

This implementation only accepts TX recording flags (i.e.,
SOF_TIMESTAMPING_TX_HARDWARE, SOF_TIMESTAMPING_TX_SOFTWARE,
SOF_TIMESTAMPING_TX_SCHED, and SOF_TIMESTAMPING_TX_ACK) in
control messages. Users need to set reporting flags (e.g.,
SOF_TIMESTAMPING_OPT_ID) per socket via socket options.

This commit adds a tsflags field in sockcm_cookie which is
set in __sock_cmsg_send. It only override the SOF_TIMESTAMPING_TX_*
bits in sockcm_cookie.tsflags allowing the control message
to override the recording behavior per write, yet maintaining
the value of other flags.

This patch implements validating the control message and setting
tsflags in struct sockcm_cookie. Next commits in this series will
actually implement timestamping per write for different protocols.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 include/net/sock.h              |  1 +
 include/uapi/linux/net_tstamp.h | 10 ++++++++++
 net/core/sock.c                 | 13 +++++++++++++
 3 files changed, 24 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 03772d4..af012da 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1418,6 +1418,7 @@ void sk_send_sigurg(struct sock *sk);
 
 struct sockcm_cookie {
 	u32 mark;
+	u16 tsflags;
 };
 
 int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
index 6d1abea..264e515 100644
--- a/include/uapi/linux/net_tstamp.h
+++ b/include/uapi/linux/net_tstamp.h
@@ -31,6 +31,16 @@ enum {
 				 SOF_TIMESTAMPING_LAST
 };
 
+/*
+ * SO_TIMESTAMPING flags are either for recording a packet timestamp or for
+ * reporting the timestamp to user space.
+ * Recording flags can be set both via socket options and control messages.
+ */
+#define SOF_TIMESTAMPING_TX_RECORD_MASK	(SOF_TIMESTAMPING_TX_HARDWARE | \
+					 SOF_TIMESTAMPING_TX_SOFTWARE | \
+					 SOF_TIMESTAMPING_TX_SCHED | \
+					 SOF_TIMESTAMPING_TX_ACK)
+
 /**
  * struct hwtstamp_config - %SIOCGHWTSTAMP and %SIOCSHWTSTAMP parameter
  *
diff --git a/net/core/sock.c b/net/core/sock.c
index 0a64fe2..315f5e5 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1870,6 +1870,8 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
 int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 		     struct sockcm_cookie *sockc)
 {
+	u32 tsflags;
+
 	switch (cmsg->cmsg_type) {
 	case SO_MARK:
 		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
@@ -1878,6 +1880,17 @@ int __sock_cmsg_send(struct sock *sk, struct msghdr *msg, struct cmsghdr *cmsg,
 			return -EINVAL;
 		sockc->mark = *(u32 *)CMSG_DATA(cmsg);
 		break;
+	case SO_TIMESTAMPING:
+		if (cmsg->cmsg_len != CMSG_LEN(sizeof(u32)))
+			return -EINVAL;
+
+		tsflags = *(u32 *)CMSG_DATA(cmsg);
+		if (tsflags & ~SOF_TIMESTAMPING_TX_RECORD_MASK)
+			return -EINVAL;
+
+		sockc->tsflags &= ~SOF_TIMESTAMPING_TX_RECORD_MASK;
+		sockc->tsflags |= tsflags;
+		break;
 	default:
 		return -EINVAL;
 	}
-- 
2.8.0.rc3.226.g39d4020
