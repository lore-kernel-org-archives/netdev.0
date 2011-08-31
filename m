From: <rongqing.li@windriver.com>
Subject: [PATCH 2/2] Add a netlink attribute INET_DIAG_SECCTX
Date: Wed, 31 Aug 2011 16:36:17 +0800
Message-ID: <1314779777-12669-3-git-send-email-rongqing.li@windriver.com>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	<linux-security-module@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37922 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068Ab1HaIg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 04:36:27 -0400
In-Reply-To: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roy.Li <rongqing.li@windriver.com>

Add a new netlink attribute INET_DIAG_SECCTX to dump the security
context of TCP sockets.

The element sk_security of struct sock represents the socket
security context ID, which is inherited from the parent process
when the socket is created.

but when SELinux type_transition rule is applied to socket, or
application sets /proc/xxx/attr/createsock, the socket security
context would be different from the creating process. For these
conditions, the "netstat -Z" will return wrong value, since
"netstat -Z" only returns the process security context as socket
process security.

Signed-off-by: Roy.Li <rongqing.li@windriver.com>
---
 include/linux/inet_diag.h |    3 ++-
 net/ipv4/inet_diag.c      |   38 +++++++++++++++++++++++++++++++++-----
 2 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index bc8c490..00382b4 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -97,9 +97,10 @@ enum {
 	INET_DIAG_INFO,
 	INET_DIAG_VEGASINFO,
 	INET_DIAG_CONG,
+	INET_DIAG_SECCTX,
 };
 
-#define INET_DIAG_MAX INET_DIAG_CONG
+#define INET_DIAG_MAX INET_DIAG_SECCTX
 
 
 /* INET_DIAG_MEM */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 389a2e6..1faf752 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -34,6 +34,8 @@
 
 #include <linux/inet_diag.h>
 
+#define MAX_SECCTX_LEN 128
+
 static const struct inet_diag_handler **inet_diag_table;
 
 struct inet_diag_entry {
@@ -108,6 +110,25 @@ static int inet_csk_diag_fill(struct sock *sk,
 		       icsk->icsk_ca_ops->name);
 	}
 
+	if (ext & (1 << (INET_DIAG_SECCTX - 1))) {
+		u32 ctxlen = 0;
+		void *secctx;
+		int error;
+
+		error = security_sk_getsecctx(sk, &secctx, &ctxlen);
+
+		if (!error && ctxlen) {
+			if (ctxlen < MAX_SECCTX_LEN) {
+				strcpy(INET_DIAG_PUT(skb, INET_DIAG_SECCTX,
+					ctxlen + 1), secctx);
+			} else {
+				strcpy(INET_DIAG_PUT(skb, INET_DIAG_SECCTX,
+					2), "-");
+			}
+			security_release_secctx(secctx, ctxlen);
+		}
+	}
+
 	r->idiag_family = sk->sk_family;
 	r->idiag_state = sk->sk_state;
 	r->idiag_timer = 0;
@@ -246,7 +267,7 @@ static int sk_diag_fill(struct sock *sk, struct sk_buff *skb,
 static int inet_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh)
 {
-	int err;
+	int err, len;
 	struct sock *sk;
 	struct inet_diag_req *req = NLMSG_DATA(nlh);
 	struct sk_buff *rep;
@@ -293,10 +314,17 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 		goto out;
 
 	err = -ENOMEM;
-	rep = alloc_skb(NLMSG_SPACE((sizeof(struct inet_diag_msg) +
-				     sizeof(struct inet_diag_meminfo) +
-				     handler->idiag_info_size + 64)),
-			GFP_KERNEL);
+	len = sizeof(struct inet_diag_msg) + 64;
+
+	len += (req->idiag_ext & (1 << (INET_DIAG_MEMINFO - 1))) ?
+		sizeof(struct inet_diag_meminfo) : 0;
+	len += (req->idiag_ext & (1 << (INET_DIAG_INFO - 1))) ?
+		handler->idiag_info_size : 0;
+	len += (req->idiag_ext & (1 << (INET_DIAG_SECCTX - 1))) ?
+		MAX_SECCTX_LEN : 0;
+
+	rep = alloc_skb(NLMSG_SPACE(len), GFP_KERNEL);
+
 	if (!rep)
 		goto out;
 
-- 
1.7.1
