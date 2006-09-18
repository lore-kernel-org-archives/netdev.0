From: David Woodhouse <dwmw2@infradead.org>
Subject: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 11:05:09 +0100
Message-ID: <1158573909.24527.336.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:61645 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S965632AbWIRKFe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 06:05:34 -0400
To: marcel@holtmann.org, torvalds@osdl.org, akpm@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We were making no attempt to deal with the fact that a structure with a
uint32_t followed by a pointer is going to be _different_ for 32-bit and
64-bit userspace. Any 32-bit process trying to use BNEPGETCONNLIST will
be failing with -EFAULT if it's lucky; suffering from having the
connection list dumped at a random address if it's not.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/net/bluetooth/bnep/sock.c b/net/bluetooth/bnep/sock.c
index 28c5583..0ef2783 100644
--- a/net/bluetooth/bnep/sock.c
+++ b/net/bluetooth/bnep/sock.c
@@ -43,6 +43,7 @@ #include <linux/socket.h>
 #include <linux/ioctl.h>
 #include <linux/file.h>
 #include <linux/init.h>
+#include <linux/compat.h>
 #include <net/sock.h>
 
 #include <asm/system.h>
@@ -146,11 +147,44 @@ static int bnep_sock_ioctl(struct socket
 	return 0;
 }
 
+#ifdef CONFIG_COMPAT
+static int bnep_sock_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+
+	if (cmd == BNEPGETCONNLIST) {
+		struct bnep_connlist_req cl;
+		uint32_t uci;
+		int err;
+
+		if (get_user(cl.cnum, (uint32_t __user *)arg) ||
+		    get_user(uci, (u32 __user *)(arg+4)))
+			return -EFAULT;
+
+		cl.ci = compat_ptr(uci);
+
+		if (cl.cnum <= 0)
+			return -EINVAL;
+	
+		err = bnep_get_connlist(&cl);
+
+		if (!err && put_user(cl.cnum, (uint32_t __user *)arg))
+			err = -EFAULT;
+
+		return err;
+	}
+
+	return bnep_sock_ioctl(sock, cmd, arg);
+}
+#endif
+
 static const struct proto_ops bnep_sock_ops = {
 	.family     = PF_BLUETOOTH,
 	.owner      = THIS_MODULE,
 	.release    = bnep_sock_release,
 	.ioctl      = bnep_sock_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl = bnep_sock_compat_ioctl,
+#endif
 	.bind       = sock_no_bind,
 	.getname    = sock_no_getname,
 	.sendmsg    = sock_no_sendmsg,

-- 
dwmw2

