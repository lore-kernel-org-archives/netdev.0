From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 14:24:59 +0100
Message-ID: <1158585899.24527.356.camel@pmac.infradead.org>
References: <1158573909.24527.336.camel@pmac.infradead.org>
	 <1158575899.25125.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:20866 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751447AbWIRNZG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 09:25:06 -0400
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1158575899.25125.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-18 at 12:38 +0200, Marcel Holtmann wrote:
> Hi David,
> 
> > We were making no attempt to deal with the fact that a structure with a
> > uint32_t followed by a pointer is going to be _different_ for 32-bit and
> > 64-bit userspace. Any 32-bit process trying to use BNEPGETCONNLIST will
> > be failing with -EFAULT if it's lucky; suffering from having the
> > connection list dumped at a random address if it's not.
> 
> it seems that HIDP and CMTP will have the same problem.

Indeed they do. This patch fixes 'hidd -l'... although HIDP mouse
movement doesn't seem to be appearing in /dev/input/mice on my G5, while
the 'hcidump' output looks sane enough while I move it.

-----
[HIDP] Fix compat HIDPGETCONNLIST ioctl.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 099646e..af5a21c 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -35,6 +35,7 @@ #include <linux/socket.h>
 #include <linux/ioctl.h>
 #include <linux/file.h>
 #include <linux/init.h>
+#include <linux/compat.h>
 #include <net/sock.h>
 
 #include "hidp.h"
@@ -143,11 +144,42 @@ static int hidp_sock_ioctl(struct socket
 	return -EINVAL;
 }
 
+#ifdef CONFIG_COMPAT
+static int hidp_sock_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	if (cmd == HIDPGETCONNLIST) {
+		struct hidp_connlist_req cl;
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
+		err = hidp_get_connlist(&cl);
+
+		if (!err && put_user(cl.cnum, (uint32_t __user *)arg))
+			err = -EFAULT;
+
+		return err;
+	}
+	return hidp_sock_ioctl(sock, cmd, arg);
+}
+#endif
+
 static const struct proto_ops hidp_sock_ops = {
 	.family		= PF_BLUETOOTH,
 	.owner		= THIS_MODULE,
 	.release	= hidp_sock_release,
 	.ioctl		= hidp_sock_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= hidp_sock_compat_ioctl,
+#endif
 	.bind		= sock_no_bind,
 	.getname	= sock_no_getname,
 	.sendmsg	= sock_no_sendmsg,

-- 
dwmw2

