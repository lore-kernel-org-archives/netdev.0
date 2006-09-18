From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 15:28:04 +0100
Message-ID: <1158589684.24527.370.camel@pmac.infradead.org>
References: <1158573909.24527.336.camel@pmac.infradead.org>
	 <1158575899.25125.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:27556 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S965213AbWIRO2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 10:28:07 -0400
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1158575899.25125.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-18 at 12:38 +0200, Marcel Holtmann wrote:
> it seems that HIDP and CMTP will have the same problem.

Finally, the CMTP version... this one is untested.

----
[CMTP] Fix compat CMTPGETCONNLIST ioctl

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/net/bluetooth/cmtp/sock.c b/net/bluetooth/cmtp/sock.c
index 10ad7fd..68e1290 100644
--- a/net/bluetooth/cmtp/sock.c
+++ b/net/bluetooth/cmtp/sock.c
@@ -34,6 +34,7 @@ #include <linux/skbuff.h>
 #include <linux/socket.h>
 #include <linux/ioctl.h>
 #include <linux/file.h>
+#include <linux/compat.h>
 #include <net/sock.h>
 
 #include <linux/isdn/capilli.h>
@@ -137,11 +138,44 @@ static int cmtp_sock_ioctl(struct socket
 	return -EINVAL;
 }
 
+#ifdef CONFIG_COMPAT
+static int cmtp_sock_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+
+	if (cmd == CMTPGETCONNLIST) {
+		struct cmtp_connlist_req cl;
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
+		err = cmtp_get_connlist(&cl);
+
+		if (!err && put_user(cl.cnum, (uint32_t __user *)arg))
+			err = -EFAULT;
+
+		return err;
+	}
+
+	return cmtp_sock_ioctl(sock, cmd, arg);
+}
+#endif
+
 static const struct proto_ops cmtp_sock_ops = {
 	.family		= PF_BLUETOOTH,
 	.owner		= THIS_MODULE,
 	.release	= cmtp_sock_release,
 	.ioctl		= cmtp_sock_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= cmtp_sock_compat_ioctl,
+#endif
 	.bind		= sock_no_bind,
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,

-- 
dwmw2

