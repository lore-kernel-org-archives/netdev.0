From: <rongqing.li@windriver.com>
Subject: [PATCH 1/5] Define the function to write sock's security context to seq_file.
Date: Fri, 5 Aug 2011 16:58:02 +0800
Message-ID: <1312534686-4099-2-git-send-email-rongqing.li@windriver.com>
References: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34182 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1HEI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 04:58:10 -0400
In-Reply-To: <1312534686-4099-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

This function will write the sock's security context to a seq_file
and return the error code, and the number of characters successfully
written is written in int pointers parameter.

This function will be called when export socket information to proc.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 include/net/sock.h |    1 +
 net/core/sock.c    |   26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..0366ab1 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1828,6 +1828,7 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
+extern int sock_write_secctx(struct sock *sk, struct seq_file *seq, int *len);
 
 /* 
  *	Enable debug/info messages 
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..1126a49 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2254,6 +2254,32 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
+int sock_write_secctx(struct sock *sk, struct seq_file *seq, int *len)
+{
+	struct flowi fl;
+	char *ctx = NULL;
+	u32 ctxlen;
+	int res = 0;
+
+	*len = 0;
+
+	if (sk == NULL)
+		return -EINVAL;
+	res = security_socket_getsockname(sk->sk_socket);
+	if (res)
+		return res;
+
+	security_sk_classify_flow(sk, &fl);
+
+	res = security_secid_to_secctx(fl.flowi_secid, &ctx, &ctxlen);
+	if (res)
+		return res;
+
+	seq_printf(seq, " %s%n", ctx, len);
+	security_release_secctx(ctx, ctxlen);
+	return res;
+}
+
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
-- 
1.7.1

