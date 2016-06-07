From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] packet: compat support for sock_fprog
Date: Tue,  7 Jun 2016 12:06:34 -0400
Message-ID: <1465315594-84301-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: daniel@iogearbox.net, davem@davemloft.net, deller@gmx.de,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33927 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161606AbcFGQGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 12:06:38 -0400
Received: by mail-it0-f66.google.com with SMTP id r205so9036609itd.1
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 09:06:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Socket option PACKET_FANOUT_DATA takes a struct sock_fprog as argument
if PACKET_FANOUT has mode PACKET_FANOUT_CBPF. This structure contains
a pointer into user memory. If userland is 32-bit and kernel is 64-bit
the two disagree about the layout of struct sock_fprog.

Add compat setsockopt support to convert a 32-bit compat_sock_fprog to
a 64-bit sock_fprog. This is analogous to compat_sock_fprog support for
SO_REUSEPORT added in commit 1957598840f4 ("soreuseport: add compat
case for setsockopt SO_ATTACH_REUSEPORT_CBPF").

Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/compat.h   |  1 +
 net/compat.c           | 17 +++++++++++++++--
 net/packet/af_packet.c | 25 +++++++++++++++++++++++++
 3 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/include/net/compat.h b/include/net/compat.h
index 48103cf..13de0cc 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -42,6 +42,7 @@ int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 
 int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *,
 		      struct sockaddr __user **, struct iovec **);
+struct sock_fprog __user *get_compat_bpf_fprog(char __user *optval);
 asmlinkage long compat_sys_sendmsg(int, struct compat_msghdr __user *,
 				   unsigned int);
 asmlinkage long compat_sys_sendmmsg(int, struct compat_mmsghdr __user *,
diff --git a/net/compat.c b/net/compat.c
index 1373947..1cd2ec0 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -309,8 +309,8 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 	__scm_destroy(scm);
 }
 
-static int do_set_attach_filter(struct socket *sock, int level, int optname,
-				char __user *optval, unsigned int optlen)
+/* allocate a 64-bit sock_fprog on the user stack for duration of syscall. */
+struct sock_fprog __user *get_compat_bpf_fprog(char __user *optval)
 {
 	struct compat_sock_fprog __user *fprog32 = (struct compat_sock_fprog __user *)optval;
 	struct sock_fprog __user *kfprog = compat_alloc_user_space(sizeof(struct sock_fprog));
@@ -323,6 +323,19 @@ static int do_set_attach_filter(struct socket *sock, int level, int optname,
 	    __get_user(ptr, &fprog32->filter) ||
 	    __put_user(len, &kfprog->len) ||
 	    __put_user(compat_ptr(ptr), &kfprog->filter))
+		return NULL;
+
+	return kfprog;
+}
+EXPORT_SYMBOL_GPL(get_compat_bpf_fprog);
+
+static int do_set_attach_filter(struct socket *sock, int level, int optname,
+				char __user *optval, unsigned int optlen)
+{
+	struct sock_fprog __user *kfprog;
+
+	kfprog = get_compat_bpf_fprog(optval);
+	if (!kfprog)
 		return -EFAULT;
 
 	return sock_setsockopt(sock, level, optname, (char __user *)kfprog,
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4040eb9..9bff6ef 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -93,6 +93,7 @@
 #include <net/inet_common.h>
 #endif
 #include <linux/bpf.h>
+#include <net/compat.h>
 
 #include "internal.h"
 
@@ -3940,6 +3941,27 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 }
 
 
+#ifdef CONFIG_COMPAT
+static int compat_packet_setsockopt(struct socket *sock, int level, int optname,
+				    char __user *optval, unsigned int optlen)
+{
+	struct packet_sock *po = pkt_sk(sock->sk);
+
+	if (level != SOL_PACKET)
+		return -ENOPROTOOPT;
+
+	if (optname == PACKET_FANOUT_DATA &&
+	    po->fanout && po->fanout->type == PACKET_FANOUT_CBPF) {
+		optval = (char __user *)get_compat_bpf_fprog(optval);
+		if (!optval)
+			return -EFAULT;
+		optlen = sizeof(struct sock_fprog);
+	}
+
+	return packet_setsockopt(sock, level, optname, optval, optlen);
+}
+#endif
+
 static int packet_notifier(struct notifier_block *this,
 			   unsigned long msg, void *ptr)
 {
@@ -4416,6 +4438,9 @@ static const struct proto_ops packet_ops = {
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	packet_setsockopt,
 	.getsockopt =	packet_getsockopt,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_packet_setsockopt,
+#endif
 	.sendmsg =	packet_sendmsg,
 	.recvmsg =	packet_recvmsg,
 	.mmap =		packet_mmap,
-- 
2.8.0.rc3.226.g39d4020
