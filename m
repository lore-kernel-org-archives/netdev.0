From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 3/3] sock-diag: Report shutdown for inet and unix sockets
Date: Tue, 23 Oct 2012 20:28:22 +0400
Message-ID: <5086C5A6.7050101@parallels.com>
References: <5086C36B.6060508@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41958 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754833Ab2JWQ2Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 12:28:25 -0400
In-Reply-To: <5086C36B.6060508@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ext bits for inet-diag and unix-diag and report sk_shutdown state.

When it's zero (i.e. -- no shutdown on a socket) diag reports nothing
for this request. Otherwise report user-space known values using the
proper mask-to-user conversion trick.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/sock_diag.h      |    1 +
 include/net/sock.h             |   12 ++++++++++++
 include/uapi/linux/inet_diag.h |    3 ++-
 include/uapi/linux/unix_diag.h |    2 ++
 net/core/sock_diag.c           |    9 +++++++++
 net/ipv4/inet_diag.c           |    4 ++++
 net/unix/diag.c                |    4 ++++
 7 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index e8d702e..df4b20f 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -22,5 +22,6 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
+int sock_diag_put_shutdown(struct sock *sk, struct sk_buff *skb, int attr);
 
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index c42c115..8b64048 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1283,6 +1283,18 @@ static inline int shutdown_u2mask(int uhow)
 	return uhow;
 }
 
+static inline int shutdown_mask2u(int mask)
+{
+	/*
+	 * map
+	 * 	RCV_SHUTDOWN -> SHUT_RD
+	 * 	SEND_SHUTDOWN -> SHUT_WR
+	 * 	SHUTDOWN_MASK -> SHUT_RDWR
+	 */
+
+	return mask - 1;
+}
+
 #define SOCK_SNDBUF_LOCK	1
 #define SOCK_RCVBUF_LOCK	2
 #define SOCK_BINDADDR_LOCK	4
diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index c5e14f6..ace76b5 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -110,9 +110,10 @@ enum {
 	INET_DIAG_TCLASS,
 	INET_DIAG_SKMEMINFO,
 	__INET_DIAG_EXT2,
+	INET_DIAG_SHUTDOWN,
 };
 
-#define INET_DIAG_MAX INET_DIAG_SKMEMINFO
+#define INET_DIAG_MAX INET_DIAG_SHUTDOWN
 
 
 /* INET_DIAG_MEM */
diff --git a/include/uapi/linux/unix_diag.h b/include/uapi/linux/unix_diag.h
index b1d2bf1..2113d90 100644
--- a/include/uapi/linux/unix_diag.h
+++ b/include/uapi/linux/unix_diag.h
@@ -19,6 +19,7 @@ struct unix_diag_req {
 #define UDIAG_SHOW_ICONS	0x00000008	/* show pending connections */
 #define UDIAG_SHOW_RQLEN	0x00000010	/* show skb receive queue len */
 #define UDIAG_SHOW_MEMINFO	0x00000020	/* show memory info of a socket */
+#define UDIAG_SHOW_SHUTDOWN	0x00000040	/* show shutdown state */
 
 struct unix_diag_msg {
 	__u8	udiag_family;
@@ -37,6 +38,7 @@ enum {
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
 	UNIX_DIAG_MEMINFO,
+	UNIX_DIAG_SHUTDOWN,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 602cd63..152db24 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -49,6 +49,15 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
+int sock_diag_put_shutdown(struct sock *sk, struct sk_buff *skb, int attrtype)
+{
+	if (!sk->sk_shutdown)
+		return 0;
+
+	return nla_put_u32(skb, attrtype, shutdown_mask2u(sk->sk_shutdown));
+}
+EXPORT_SYMBOL_GPL(sock_diag_put_shutdown);
+
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh))
 {
 	mutex_lock(&sock_diag_table_mutex);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 52db768..3b91f86 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -115,6 +115,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		if (nla_put_u8(skb, INET_DIAG_TOS, inet->tos) < 0)
 			goto errout;
 
+	if (ext & (1 << (INET_DIAG_SHUTDOWN - 1)))
+		if (sock_diag_put_shutdown(sk, skb, INET_DIAG_SHUTDOWN))
+			goto errout;
+
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
 		const struct ipv6_pinfo *np = inet6_sk(sk);
diff --git a/net/unix/diag.c b/net/unix/diag.c
index 06748f1..e41308c 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -151,6 +151,10 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb, struct unix_diag_r
 	    sock_diag_put_meminfo(sk, skb, UNIX_DIAG_MEMINFO))
 		goto out_nlmsg_trim;
 
+	if ((req->udiag_show & UDIAG_SHOW_SHUTDOWN) &&
+	    sock_diag_put_shutdown(sk, skb, UNIX_DIAG_SHUTDOWN))
+		goto out_nlmsg_trim;
+
 	return nlmsg_end(skb, nlh);
 
 out_nlmsg_trim:
-- 
1.7.6.5
