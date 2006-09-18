From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [BNEP] Fix compat BNEPGETCONNLIST ioctl.
Date: Mon, 18 Sep 2006 15:19:23 +0100
Message-ID: <1158589163.24527.367.camel@pmac.infradead.org>
References: <1158573909.24527.336.camel@pmac.infradead.org>
	 <1158575899.25125.1.camel@localhost>
	 <1158585899.24527.356.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org, akpm@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:24263 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S965266AbWIROTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 10:19:46 -0400
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1158585899.24527.356.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-18 at 14:25 +0100, David Woodhouse wrote:
> although HIDP mouse movement doesn't seem to be appearing
> in /dev/input/mice on my G5, while the 'hcidump' output looks sane
> enough while I move it. 

Ew, that's because struct hidp_connadd_req is similarly buggered for
compat. Replacement HIDP patch to fix both at once... I didn't miss
anywhere where we actually change the hidp_connadd_req structure during
the call, did I?

-----
[HIDP] Fix compat HIDPGETCONNLIST and HIDPCONNADD ioctls.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>

diff --git a/net/bluetooth/hidp/sock.c b/net/bluetooth/hidp/sock.c
index 099646e..e01fdc5 100644
--- a/net/bluetooth/hidp/sock.c
+++ b/net/bluetooth/hidp/sock.c
@@ -35,6 +35,7 @@ #include <linux/socket.h>
 #include <linux/ioctl.h>
 #include <linux/file.h>
 #include <linux/init.h>
+#include <linux/compat.h>
 #include <net/sock.h>
 
 #include "hidp.h"
@@ -143,11 +144,87 @@ static int hidp_sock_ioctl(struct socket
 	return -EINVAL;
 }
 
+#ifdef CONFIG_COMPAT
+struct compat_hidp_connadd_req {
+	int   ctrl_sock;	// Connected control socket
+	int   intr_sock;	// Connteted interrupt socket
+	__u16 parser;
+	__u16 rd_size;
+	compat_uptr_t rd_data;
+	__u8  country;
+	__u8  subclass;
+	__u16 vendor;
+	__u16 product;
+	__u16 version;
+	__u32 flags;
+	__u32 idle_to;
+	char  name[128];
+};
+
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
+	} else if (cmd == HIDPCONNADD) {
+		struct compat_hidp_connadd_req ca;
+		struct hidp_connadd_req __user *uca;
+
+		uca = compat_alloc_user_space(sizeof(*uca));
+
+		if (copy_from_user(&ca, (void *)arg, sizeof(ca)))
+			return -EFAULT;
+
+		if (put_user(ca.ctrl_sock, &uca->ctrl_sock)
+		    || put_user(ca.intr_sock, &uca->intr_sock)
+		    || put_user(ca.parser, &uca->parser)
+		    || put_user(ca.rd_size, &uca->parser)
+		    || put_user(compat_ptr(ca.rd_data), &uca->rd_data)
+		    || put_user(ca.country, &uca->country)
+		    || put_user(ca.subclass, &uca->subclass)
+		    || put_user(ca.vendor, &uca->vendor)
+		    || put_user(ca.product, &uca->product)
+		    || put_user(ca.version, &uca->version)
+		    || put_user(ca.flags, &uca->flags)
+		    || put_user(ca.idle_to, &uca->idle_to)
+		    || copy_to_user(&uca->name[0], &ca.name[0], 128))
+			return -EFAULT;
+		
+		arg = (unsigned long)uca;
+		/* Fall through. We don't actually write back any _changes_
+		   to the structure anyway, so there's no need to copy back
+		   into the original compat version */
+	}
+
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

