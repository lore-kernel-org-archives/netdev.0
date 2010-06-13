From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/8] sock: Introduce cred_to_ucred
Date: Sun, 13 Jun 2010 06:28:59 -0700
Message-ID: <m139wrhxic.fsf@fess.ebiederm.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Serge Hallyn <serue@us.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	<netdev@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38278 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706Ab0FMN3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 09:29:05 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sun\, 13 Jun 2010 06\:25\:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To keep the coming code clear and to allow both the sock
code and the scm code to share the logic introduce a
fuction to translate from struct cred to struct ucred.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/socket.h |    5 +++++
 net/core/sock.c        |   14 ++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 032a19e..a2fada9 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -24,6 +24,9 @@ struct __kernel_sockaddr_storage {
 #include <linux/types.h>		/* pid_t			*/
 #include <linux/compiler.h>		/* __user			*/
 
+struct pid;
+struct cred;
+
 #define __sockaddr_check_size(size)	\
 	BUILD_BUG_ON(((size) > sizeof(struct __kernel_sockaddr_storage)))
 
@@ -309,6 +312,8 @@ struct ucred {
 #define IPX_TYPE	1
 
 #ifdef __KERNEL__
+extern void cred_to_ucred(struct pid *pid, const struct cred *cred, struct ucred *ucred);
+
 extern int memcpy_fromiovec(unsigned char *kdata, struct iovec *iov, int len);
 extern int memcpy_fromiovecend(unsigned char *kdata, const struct iovec *iov,
 			       int offset, int len);
diff --git a/net/core/sock.c b/net/core/sock.c
index 7effa1e..9e229d8 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -110,6 +110,7 @@
 #include <linux/tcp.h>
 #include <linux/init.h>
 #include <linux/highmem.h>
+#include <linux/user_namespace.h>
 
 #include <asm/uaccess.h>
 #include <asm/system.h>
@@ -734,6 +735,19 @@ set_rcvbuf:
 EXPORT_SYMBOL(sock_setsockopt);
 
 
+void cred_to_ucred(struct pid *pid, const struct cred *cred,
+		   struct ucred *ucred)
+{
+	ucred->pid = pid_vnr(pid);
+	ucred->uid = ucred->gid = -1;
+	if (cred) {
+		struct user_namespace *current_ns = current_user_ns();
+
+		ucred->uid = user_ns_map_uid(current_ns, cred, cred->euid);
+		ucred->gid = user_ns_map_gid(current_ns, cred, cred->egid);
+	}
+}
+
 int sock_getsockopt(struct socket *sock, int level, int optname,
 		    char __user *optval, int __user *optlen)
 {
-- 
1.6.5.2.143.g8cc62

