From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] ATM 32-bit ioctl compatibility
Date: Wed, 03 Dec 2008 16:00:31 +0000
Message-ID: <1228320031.7381.4.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53774 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbYLCQkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 11:40:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We lack compat ioctl support through most of the ATM code. This patch
deals with most of it, and I can now at least use BR2684 and PPPoATM
with 32-bit userspace.

I haven't added a .compat_ioctl method to struct atm_ioctl, because
AFAICT none of the current users need any conversion -- so we can just
call the ->ioctl() method in every case. I looked at br2684, clip, lec,
mpc, pppoatm and atmtcp.

In svc_compat_ioctl() the only mangling which is needed is to change
COMPAT_ATM_ADDPARTY to ATM_ADDPARTY. Although it's defined as
	_IOW('a', ATMIOC_SPECIAL+4,struct atm_iobuf)
it doesn't actually _take_ a struct atm_iobuf as an argument -- it takes
a struct sockaddr_atmsvc, which _is_ the same between 32-bit and 64-bit
code, so doesn't need conversion.

Almost all of vcc_ioctl() would have been identical, so I converted that
into a core do_vcc_ioctl() function with an 'int compat' argument.

I've done the same with atm_dev_ioctl(), where there _are_ a few
differences, but still it's relatively contained and there would
otherwise have been a lot of duplication.

I haven't done any of the actual device-specific ioctls, although I've
added a compat_ioctl method to struct atmdev_ops.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

diff --git a/include/linux/atm.h b/include/linux/atm.h
index c791ddd..d3b2921 100644
--- a/include/linux/atm.h
+++ b/include/linux/atm.h
@@ -231,10 +231,21 @@ static __inline__ int atmpvc_addr_in_use(struct sockaddr_atmpvc addr)
  */
 
 struct atmif_sioc {
-    int number;
-    int length;
-    void __user *arg;
+	int number;
+	int length;
+	void __user *arg;
 };
 
+#ifdef __KERNEL__
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+struct compat_atmif_sioc {
+	int number;
+	int length;
+	compat_uptr_t arg;
+};
+#endif
+#endif
+
 typedef unsigned short atm_backend_t;
 #endif
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index a3d07c2..086e5c3 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -100,6 +100,10 @@ struct atm_dev_stats {
 					/* use backend to make new if */
 #define ATM_ADDPARTY  	_IOW('a', ATMIOC_SPECIAL+4,struct atm_iobuf)
  					/* add party to p2mp call */
+#ifdef CONFIG_COMPAT
+/* It actually takes struct sockaddr_atmsvc, not struct atm_iobuf */
+#define COMPAT_ATM_ADDPARTY  	_IOW('a', ATMIOC_SPECIAL+4,struct compat_atm_iobuf)
+#endif
 #define ATM_DROPPARTY 	_IOW('a', ATMIOC_SPECIAL+5,int)
 					/* drop party from p2mp call */
 
@@ -224,6 +228,13 @@ struct atm_cirange {
 extern struct proc_dir_entry *atm_proc_root;
 #endif
 
+#ifdef CONFIG_COMPAT
+#include <linux/compat.h>
+struct compat_atm_iobuf {
+	int length;
+	compat_uptr_t buffer;
+};
+#endif
 
 struct k_atm_aal_stats {
 #define __HANDLE_ITEM(i) atomic_t i
@@ -379,6 +390,10 @@ struct atmdev_ops { /* only send is required */
 	int (*open)(struct atm_vcc *vcc);
 	void (*close)(struct atm_vcc *vcc);
 	int (*ioctl)(struct atm_dev *dev,unsigned int cmd,void __user *arg);
+#ifdef CONFIG_COMPAT
+	int (*compat_ioctl)(struct atm_dev *dev,unsigned int cmd,
+			    void __user *arg);
+#endif
 	int (*getsockopt)(struct atm_vcc *vcc,int level,int optname,
 	    void __user *optval,int optlen);
 	int (*setsockopt)(struct atm_vcc *vcc,int level,int optname,
diff --git a/net/atm/common.h b/net/atm/common.h
index 16f32c1..92e2981 100644
--- a/net/atm/common.h
+++ b/net/atm/common.h
@@ -19,6 +19,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		size_t total_len);
 unsigned int vcc_poll(struct file *file, struct socket *sock, poll_table *wait);
 int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
+int vcc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg);
 int vcc_setsockopt(struct socket *sock, int level, int optname,
 		   char __user *optval, int optlen);
 int vcc_getsockopt(struct socket *sock, int level, int optname,
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 7afd8e7..5b680ab 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -19,6 +19,7 @@
 #include <linux/atmlec.h>
 #include <linux/mutex.h>
 #include <asm/ioctls.h>
+#include <net/compat.h>
 
 #include "resources.h"
 #include "signaling.h"		/* for WAITING and sigd_attach */
@@ -46,7 +47,7 @@ void deregister_atm_ioctl(struct atm_ioctl *ioctl)
 EXPORT_SYMBOL(register_atm_ioctl);
 EXPORT_SYMBOL(deregister_atm_ioctl);
 
-int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+static int do_vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg, int compat)
 {
 	struct sock *sk = sock->sk;
 	struct atm_vcc *vcc;
@@ -80,13 +81,25 @@ int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 				goto done;
 			}
 		case SIOCGSTAMP: /* borrowed from IP */
-			error = sock_get_timestamp(sk, argp);
+#ifdef CONFIG_COMPAT
+			if (compat)
+				error = compat_sock_get_timestamp(sk, argp);
+			else
+#endif
+				error = sock_get_timestamp(sk, argp);
 			goto done;
 		case SIOCGSTAMPNS: /* borrowed from IP */
-			error = sock_get_timestampns(sk, argp);
+#ifdef CONFIG_COMPAT
+			if (compat)
+				error = compat_sock_get_timestampns(sk, argp);
+			else
+#endif
+				error = sock_get_timestampns(sk, argp);
 			goto done;
 		case ATM_SETSC:
-			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
+			if (net_ratelimit())
+				printk(KERN_WARNING "ATM_SETSC is obsolete; used by %s:%d\n",
+				       current->comm, task_pid_nr(current));
 			error = 0;
 			goto done;
 		case ATMSIGD_CTRL:
@@ -99,12 +112,23 @@ int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			 * info uses kernel pointers as opaque references,
 			 * so the holder of the file descriptor can scribble
 			 * on the kernel... so we should make sure that we
-			 * have the same privledges that /proc/kcore needs
+			 * have the same privileges that /proc/kcore needs
 			 */
 			if (!capable(CAP_SYS_RAWIO)) {
 				error = -EPERM;
 				goto done;
 			}
+#ifdef CONFIG_COMPAT
+			/* WTF? I don't even want to _think_ about making this 
+			   work for 32-bit userspace. TBH I don't really want
+			   to think about it at all. dwmw2. */
+			if (compat) {
+				if (net_ratelimit())
+					printk(KERN_WARNING "32-bit task cannot be atmsigd\n");
+				error = -EINVAL;
+				goto done;
+			}
+#endif
 			error = sigd_attach(vcc);
 			if (!error)
 				sock->state = SS_CONNECTED;
@@ -155,8 +179,21 @@ int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	if (error != -ENOIOCTLCMD)
 		goto done;
 
-	error = atm_dev_ioctl(cmd, argp);
+	error = atm_dev_ioctl(cmd, argp, compat);
 
 done:
 	return error;
 }
+
+
+int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	return do_vcc_ioctl(sock, cmd, arg, 0);
+}
+
+#ifdef CONFIG_COMPAT
+int vcc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	return do_vcc_ioctl(sock, cmd, arg, 1);
+}
+#endif
diff --git a/net/atm/pvc.c b/net/atm/pvc.c
index 43e8bf5..e1d22d9 100644
--- a/net/atm/pvc.c
+++ b/net/atm/pvc.c
@@ -113,6 +113,9 @@ static const struct proto_ops pvc_proto_ops = {
 	.getname =	pvc_getname,
 	.poll =		vcc_poll,
 	.ioctl =	vcc_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl = vcc_compat_ioctl,
+#endif
 	.listen =	sock_no_listen,
 	.shutdown =	pvc_shutdown,
 	.setsockopt =	pvc_setsockopt,
diff --git a/net/atm/resources.c b/net/atm/resources.c
index a34ba94..56b7322 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -195,20 +195,39 @@ static int fetch_stats(struct atm_dev *dev, struct atm_dev_stats __user *arg, in
 }
 
 
-int atm_dev_ioctl(unsigned int cmd, void __user *arg)
+int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 {
 	void __user *buf;
 	int error, len, number, size = 0;
 	struct atm_dev *dev;
 	struct list_head *p;
 	int *tmp_buf, *tmp_p;
-	struct atm_iobuf __user *iobuf = arg;
-	struct atmif_sioc __user *sioc = arg;
+	int __user *sioc_len;
+	int __user *iobuf_len;
+
+#ifndef CONFIG_COMPAT
+	compat = 0; /* Just so the compiler _knows_ */
+#endif
+
 	switch (cmd) {
 		case ATM_GETNAMES:
-			if (get_user(buf, &iobuf->buffer))
-				return -EFAULT;
-			if (get_user(len, &iobuf->length))
+
+			if (compat) {
+#ifdef CONFIG_COMPAT
+				struct compat_atm_iobuf __user *ciobuf = arg;
+				compat_uptr_t cbuf;
+				iobuf_len = &ciobuf->length;
+				if (get_user(cbuf, &ciobuf->buffer))
+					return -EFAULT;
+				buf = compat_ptr(cbuf);
+#endif
+			} else {
+				struct atm_iobuf __user *iobuf = arg;
+				iobuf_len = &iobuf->length;
+				if (get_user(buf, &iobuf->buffer))
+					return -EFAULT;
+			}
+			if (get_user(len, iobuf_len))
 				return -EFAULT;
 			mutex_lock(&atm_dev_mutex);
 			list_for_each(p, &atm_devs)
@@ -229,7 +248,7 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg)
 			}
 			mutex_unlock(&atm_dev_mutex);
 			error = ((copy_to_user(buf, tmp_buf, size)) ||
-					put_user(size, &iobuf->length))
+					put_user(size, iobuf_len))
 						? -EFAULT : 0;
 			kfree(tmp_buf);
 			return error;
@@ -237,13 +256,32 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg)
 			break;
 	}
 
-	if (get_user(buf, &sioc->arg))
-		return -EFAULT;
-	if (get_user(len, &sioc->length))
-		return -EFAULT;
-	if (get_user(number, &sioc->number))
-		return -EFAULT;
-
+	if (compat) {
+#ifdef CONFIG_COMPAT
+		struct compat_atmif_sioc __user *csioc = arg;
+		compat_uptr_t carg;
+
+		sioc_len = &csioc->length;
+		if (get_user(carg, &csioc->arg))
+			return -EFAULT;
+		buf = compat_ptr(carg);
+
+		if (get_user(len, &csioc->length))
+			return -EFAULT;
+		if (get_user(number, &csioc->number))
+			return -EFAULT;
+#endif
+	} else {
+		struct atmif_sioc __user *sioc = arg;
+
+		sioc_len = &sioc->length;
+		if (get_user(buf, &sioc->arg))
+			return -EFAULT;
+		if (get_user(len, &sioc->length))
+			return -EFAULT;
+		if (get_user(number, &sioc->number))
+			return -EFAULT;
+	}
 	if (!(dev = try_then_request_module(atm_dev_lookup(number),
 					    "atm-device-%d", number)))
 		return -ENODEV;
@@ -358,7 +396,7 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg)
 			size = error;
 			/* may return 0, but later on size == 0 means "don't
 			   write the length" */
-			error = put_user(size, &sioc->length)
+			error = put_user(size, sioc_len)
 				? -EFAULT : 0;
 			goto done;
 		case ATM_SETLOOP:
@@ -380,11 +418,21 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg)
 			}
 			/* fall through */
 		default:
-			if (!dev->ops->ioctl) {
-				error = -EINVAL;
-				goto done;
+			if (compat) {
+#ifdef CONFIG_COMPAT
+				if (!dev->ops->compat_ioctl) {
+					error = -EINVAL;
+					goto done;
+				}
+				size = dev->ops->compat_ioctl(dev, cmd, buf);
+#endif
+			} else {
+				if (!dev->ops->ioctl) {
+					error = -EINVAL;
+					goto done;
+				}
+				size = dev->ops->ioctl(dev, cmd, buf);
 			}
-			size = dev->ops->ioctl(dev, cmd, buf);
 			if (size < 0) {
 				error = (size == -ENOIOCTLCMD ? -EINVAL : size);
 				goto done;
@@ -392,7 +440,7 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg)
 	}
 
 	if (size)
-		error = put_user(size, &sioc->length)
+		error = put_user(size, sioc_len)
 			? -EFAULT : 0;
 	else
 		error = 0;
diff --git a/net/atm/resources.h b/net/atm/resources.h
index 1d004aa..126fb18 100644
--- a/net/atm/resources.h
+++ b/net/atm/resources.h
@@ -13,7 +13,7 @@
 extern struct list_head atm_devs;
 extern struct mutex atm_dev_mutex;
 
-int atm_dev_ioctl(unsigned int cmd, void __user *arg);
+int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat);
 
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/atm/svc.c b/net/atm/svc.c
index de1e4f2..e9c6550 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -604,6 +604,22 @@ static int svc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	return error;
 }
 
+#ifdef CONFIG_COMPAT
+static int svc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+{
+	/* The definition of ATM_ADDPARTY uses the size of struct atm_iobuf.
+	   But actually it takes a struct sockaddr_atmsvc, which doesn't need
+	   compat handling. So all we have to do is fix up cmd... */
+	if (cmd == COMPAT_ATM_ADDPARTY)
+		cmd = ATM_ADDPARTY;
+
+	if (cmd == ATM_ADDPARTY || cmd == ATM_DROPPARTY)
+		return svc_ioctl(sock, cmd, arg);
+	else
+		return vcc_compat_ioctl(sock, cmd, arg);
+}
+#endif /* CONFIG_COMPAT */
+
 static const struct proto_ops svc_proto_ops = {
 	.family =	PF_ATMSVC,
 	.owner =	THIS_MODULE,
@@ -616,6 +632,9 @@ static const struct proto_ops svc_proto_ops = {
 	.getname =	svc_getname,
 	.poll =		vcc_poll,
 	.ioctl =	svc_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl =	svc_compat_ioctl,
+#endif
 	.listen =	svc_listen,
 	.shutdown =	svc_shutdown,
 	.setsockopt =	svc_setsockopt,


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

