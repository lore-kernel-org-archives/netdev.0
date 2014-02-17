From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: fix sctp_connectx abi for ia32 emulation/compat mode
Date: Mon, 17 Feb 2014 12:11:11 +0100
Message-ID: <1392635471-31528-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbaBQLLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 06:11:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SCTP's sctp_connectx() abi breaks for 64bit kernels compiled with 32bit
emulation (e.g. ia32 emulation or x86_x32). Due to internal usage of
'struct sctp_getaddrs_old' which includes a struct sockaddr pointer,
sizeof(param) check will always fail in kernel as the structure in
64bit kernel space is 4bytes larger than for user binaries compiled
in 32bit mode. Thus, applications making use of sctp_connectx() won't
be able to run under such circumstances.

Introduce a compat interface in the kernel to deal with such
situations by using a 'struct compat_sctp_getaddrs_old' structure
where user data is copied into it, and then sucessively transformed
into a 'struct sctp_getaddrs_old' structure with the help of
compat_ptr(). That fixes sctp_connectx() abi without any changes
needed in user space, and lets the SCTP test suite pass when compiled
in 32bit and run on 64bit kernels.

Fixes: f9c67811ebc0 ("sctp: Fix regression introduced by new sctp_connectx api")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/socket.c | 41 ++++++++++++++++++++++++++++++++---------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7075ac8..9145ffc 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -64,6 +64,7 @@
 #include <linux/crypto.h>
 #include <linux/slab.h>
 #include <linux/file.h>
+#include <linux/compat.h>
 
 #include <net/ip.h>
 #include <net/icmp.h>
@@ -1368,11 +1369,19 @@ static int sctp_setsockopt_connectx(struct sock *sk,
 /*
  * New (hopefully final) interface for the API.
  * We use the sctp_getaddrs_old structure so that use-space library
- * can avoid any unnecessary allocations.   The only defferent part
+ * can avoid any unnecessary allocations. The only different part
  * is that we store the actual length of the address buffer into the
- * addrs_num structure member.  That way we can re-use the existing
+ * addrs_num structure member. That way we can re-use the existing
  * code.
  */
+#ifdef CONFIG_COMPAT
+struct compat_sctp_getaddrs_old {
+	sctp_assoc_t	assoc_id;
+	s32		addr_num;
+	compat_uptr_t	addrs;		/* struct sockaddr * */
+};
+#endif
+
 static int sctp_getsockopt_connectx3(struct sock *sk, int len,
 				     char __user *optval,
 				     int __user *optlen)
@@ -1381,16 +1390,30 @@ static int sctp_getsockopt_connectx3(struct sock *sk, int len,
 	sctp_assoc_t assoc_id = 0;
 	int err = 0;
 
-	if (len < sizeof(param))
-		return -EINVAL;
+#ifdef CONFIG_COMPAT
+	if (is_compat_task()) {
+		struct compat_sctp_getaddrs_old param32;
 
-	if (copy_from_user(&param, optval, sizeof(param)))
-		return -EFAULT;
+		if (len < sizeof(param32))
+			return -EINVAL;
+		if (copy_from_user(&param32, optval, sizeof(param32)))
+			return -EFAULT;
 
-	err = __sctp_setsockopt_connectx(sk,
-			(struct sockaddr __user *)param.addrs,
-			param.addr_num, &assoc_id);
+		param.assoc_id = param32.assoc_id;
+		param.addr_num = param32.addr_num;
+		param.addrs = compat_ptr(param32.addrs);
+	} else
+#endif
+	{
+		if (len < sizeof(param))
+			return -EINVAL;
+		if (copy_from_user(&param, optval, sizeof(param)))
+			return -EFAULT;
+	}
 
+	err = __sctp_setsockopt_connectx(sk, (struct sockaddr __user *)
+					 param.addrs, param.addr_num,
+					 &assoc_id);
 	if (err == 0 || err == -EINPROGRESS) {
 		if (copy_to_user(optval, &assoc_id, sizeof(assoc_id)))
 			return -EFAULT;
-- 
1.7.11.7
