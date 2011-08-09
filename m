From: <rongqing.li@windriver.com>
Subject: [PATCH 2/6] Define the function to write sock's security context to seq_file.
Date: Tue, 9 Aug 2011 15:28:26 +0800
Message-ID: <1312874910-31010-3-git-send-email-rongqing.li@windriver.com>
References: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>, <sds@tycho.nsa.gov>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1312874910-31010-1-git-send-email-rongqing.li@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roy.Li <rongqing.li@windriver.com>

sock_write_secctx will write the sock's security context to a seq_file
and return the number of characters successfully written.

This function will be called when export socket information to proc.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 include/net/sock.h |    1 +
 net/core/sock.c    |   28 ++++++++++++++++++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 8e4062f..8bedb0c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1828,6 +1828,7 @@ static inline struct sock *skb_steal_sock(struct sk_buff *skb)
 extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
+extern int sock_write_secctx(struct sock *sk, struct seq_file *seq);
 
 /* 
  *	Enable debug/info messages 
diff --git a/net/core/sock.c b/net/core/sock.c
index bc745d0..032ea72 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2254,6 +2254,34 @@ void sk_common_release(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_common_release);
 
+int sock_write_secctx(struct sock *sk, struct seq_file *seq)
+{
+	char *ctx = NULL;
+	u32 ctxlen, secid;
+	int len;
+
+	if (sk == NULL)
+		goto error;
+
+	if (security_socket_getsockname(sk->sk_socket))
+		goto error;
+
+	security_sk_getsecid(sk, &secid);
+	if (!secid)
+		goto error;
+
+	if (security_secid_to_secctx(secid, &ctx, &ctxlen))
+		goto error;
+
+	seq_printf(seq, " %s%n", ctx, &len);
+	security_release_secctx(ctx, ctxlen);
+	return len;
+
+error:
+	seq_printf(seq, " %s%n", "-", &len);
+	return len;
+}
+
 static DEFINE_RWLOCK(proto_list_lock);
 static LIST_HEAD(proto_list);
 
-- 
1.7.1

