From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/atm: move all compat_ioctl handling to atm/ioctl.c
Date: Wed, 11 Nov 2009 14:30:44 +0100
Message-ID: <200911111430.44361.arnd@arndb.de>
References: <200911061500.01651.arnd@arndb.de> <20091110.204118.12070030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:58403 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683AbZKKNat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 08:30:49 -0500
In-Reply-To: <20091110.204118.12070030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have two implementations of the compat_ioctl handling for ATM, the
one that we have had for ages in fs/compat_ioctl.c and the one added to
net/atm/ioctl.c by David Woodhouse. Unfortunately, both versions are
incomplete, and in practice we use a very confusing combination of the
two.

For ioctl numbers that have the same identifier on 32 and 64 bit systems,
we go directly through the compat_ioctl socket operation, for those that
differ, we do a conversion in fs/compat_ioctl.c.

This patch moves both variants into the vcc_compat_ioctl() function,
while preserving the current behaviour. It also kills off the COMPATIBLE_IOCTL
definitions that we never use here.
Doing it this way is clearly not a good solution, but I hope it is a
step into the right direction, so that someone is able to clean up this
mess for real.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>

---
 net/atm/ioctl.c |  188 +++++++++++++++++++++++++++++++++++++++++++++++-
 net/socket.c    |  218 -------------------------------------------------------
 2 files changed, 186 insertions(+), 220 deletions(-)

diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 4da8892..4539c5c 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -191,8 +191,192 @@ int vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 }
 
 #ifdef CONFIG_COMPAT
-int vcc_compat_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
+/*
+ * FIXME:
+ * The compat_ioctl handling is duplicated, using both these conversion
+ * routines and the compat argument to the actual handlers. Both
+ * versions are somewhat incomplete and should be merged, e.g. by
+ * moving the ioctl number translation into the actual handlers and
+ * killing the conversion code.
+ *
+ * -arnd, November 2009
+ */
+struct atmif_sioc32 {
+	compat_int_t	number;
+	compat_int_t	length;
+	compat_caddr_t	arg;
+};
+
+struct atm_iobuf32 {
+	compat_int_t	length;
+	compat_caddr_t	buffer;
+};
+
+#define ATM_GETLINKRATE32 _IOW('a', ATMIOC_ITF+1, struct atmif_sioc32)
+#define ATM_GETNAMES32    _IOW('a', ATMIOC_ITF+3, struct atm_iobuf32)
+#define ATM_GETTYPE32     _IOW('a', ATMIOC_ITF+4, struct atmif_sioc32)
+#define ATM_GETESI32	  _IOW('a', ATMIOC_ITF+5, struct atmif_sioc32)
+#define ATM_GETADDR32	  _IOW('a', ATMIOC_ITF+6, struct atmif_sioc32)
+#define ATM_RSTADDR32	  _IOW('a', ATMIOC_ITF+7, struct atmif_sioc32)
+#define ATM_ADDADDR32	  _IOW('a', ATMIOC_ITF+8, struct atmif_sioc32)
+#define ATM_DELADDR32	  _IOW('a', ATMIOC_ITF+9, struct atmif_sioc32)
+#define ATM_GETCIRANGE32  _IOW('a', ATMIOC_ITF+10, struct atmif_sioc32)
+#define ATM_SETCIRANGE32  _IOW('a', ATMIOC_ITF+11, struct atmif_sioc32)
+#define ATM_SETESI32      _IOW('a', ATMIOC_ITF+12, struct atmif_sioc32)
+#define ATM_SETESIF32     _IOW('a', ATMIOC_ITF+13, struct atmif_sioc32)
+#define ATM_GETSTAT32     _IOW('a', ATMIOC_SARCOM+0, struct atmif_sioc32)
+#define ATM_GETSTATZ32    _IOW('a', ATMIOC_SARCOM+1, struct atmif_sioc32)
+#define ATM_GETLOOP32	  _IOW('a', ATMIOC_SARCOM+2, struct atmif_sioc32)
+#define ATM_SETLOOP32	  _IOW('a', ATMIOC_SARCOM+3, struct atmif_sioc32)
+#define ATM_QUERYLOOP32	  _IOW('a', ATMIOC_SARCOM+4, struct atmif_sioc32)
+
+static struct {
+	unsigned int cmd32;
+	unsigned int cmd;
+} atm_ioctl_map[] = {
+	{ ATM_GETLINKRATE32, ATM_GETLINKRATE },
+	{ ATM_GETNAMES32,    ATM_GETNAMES },
+	{ ATM_GETTYPE32,     ATM_GETTYPE },
+	{ ATM_GETESI32,	     ATM_GETESI },
+	{ ATM_GETADDR32,     ATM_GETADDR },
+	{ ATM_RSTADDR32,     ATM_RSTADDR },
+	{ ATM_ADDADDR32,     ATM_ADDADDR },
+	{ ATM_DELADDR32,     ATM_DELADDR },
+	{ ATM_GETCIRANGE32,  ATM_GETCIRANGE },
+	{ ATM_SETCIRANGE32,  ATM_SETCIRANGE },
+	{ ATM_SETESI32,	     ATM_SETESI },
+	{ ATM_SETESIF32,     ATM_SETESIF },
+	{ ATM_GETSTAT32,     ATM_GETSTAT },
+	{ ATM_GETSTATZ32     ATM_GETSTATZ },
+	{ ATM_GETLOOP32,     ATM_GETLOOP },
+	{ ATM_SETLOOP32,     ATM_SETLOOP },
+	{ ATM_QUERYLOOP32,   ATM_QUERYLOOP },
+};
+
+#define NR_ATM_IOCTL ARRAY_SIZE(atm_ioctl_map)
+
+static int do_atm_iobuf(struct socket *sock, unsigned int cmd,
+			unsigned long arg)
+{
+	struct atm_iobuf __user *iobuf;
+	struct atm_iobuf32 __user *iobuf32;
+	u32 data;
+	void __user *datap;
+	int len, err;
+
+	iobuf = compat_alloc_user_space(sizeof(*iobuf));
+	iobuf32 = compat_ptr(arg);
+
+	if (get_user(len, &iobuf32->length) ||
+	    get_user(data, &iobuf32->buffer))
+		return -EFAULT;
+	datap = compat_ptr(data);
+	if (put_user(len, &iobuf->length) ||
+	    put_user(datap, &iobuf->buffer))
+		return -EFAULT;
+
+	err = do_vcc_ioctl(sock, cmd, (unsigned long) iobuf, 0);
+
+	if (!err) {
+		if (copy_in_user(&iobuf32->length, &iobuf->length,
+				 sizeof(int)))
+			err = -EFAULT;
+	}
+
+	return err;
+}
+
+static int do_atmif_sioc(struct socket *sock, unsigned int cmd,
+			 unsigned long arg)
+{
+	struct atmif_sioc __user *sioc;
+	struct atmif_sioc32 __user *sioc32;
+	u32 data;
+	void __user *datap;
+	int err;
+
+	sioc = compat_alloc_user_space(sizeof(*sioc));
+	sioc32 = compat_ptr(arg);
+
+	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int))
+	    || get_user(data, &sioc32->arg))
+		return -EFAULT;
+	datap = compat_ptr(data);
+	if (put_user(datap, &sioc->arg))
+		return -EFAULT;
+
+	err = do_vcc_ioctl(sock, cmd, (unsigned long) sioc, 0);
+
+	if (!err) {
+		if (copy_in_user(&sioc32->length, &sioc->length,
+				 sizeof(int)))
+			err = -EFAULT;
+	}
+	return err;
+}
+
+static int do_atm_ioctl(struct socket *sock, unsigned int cmd32,
+			unsigned long arg)
 {
-	return do_vcc_ioctl(sock, cmd, arg, 1);
+	int i;
+	unsigned int cmd = 0;
+
+	switch (cmd32) {
+	case SONET_GETSTAT:
+	case SONET_GETSTATZ:
+	case SONET_GETDIAG:
+	case SONET_SETDIAG:
+	case SONET_CLRDIAG:
+	case SONET_SETFRAMING:
+	case SONET_GETFRAMING:
+	case SONET_GETFRSENSE:
+		return do_atmif_sioc(sock, cmd32, arg);
+	}
+
+	for (i = 0; i < NR_ATM_IOCTL; i++) {
+		if (cmd32 == atm_ioctl_map[i].cmd32) {
+			cmd = atm_ioctl_map[i].cmd;
+			break;
+		}
+	}
+	if (i == NR_ATM_IOCTL)
+		return -EINVAL;
+
+	switch (cmd) {
+	case ATM_GETNAMES:
+		return do_atm_iobuf(sock, cmd, arg);
+
+	case ATM_GETLINKRATE:
+	case ATM_GETTYPE:
+	case ATM_GETESI:
+	case ATM_GETADDR:
+	case ATM_RSTADDR:
+	case ATM_ADDADDR:
+	case ATM_DELADDR:
+	case ATM_GETCIRANGE:
+	case ATM_SETCIRANGE:
+	case ATM_SETESI:
+	case ATM_SETESIF:
+	case ATM_GETSTAT:
+	case ATM_GETSTATZ:
+	case ATM_GETLOOP:
+	case ATM_SETLOOP:
+	case ATM_QUERYLOOP:
+		return do_atmif_sioc(sock, cmd, arg);
+	}
+
+	return -EINVAL;
+}
+
+int vcc_compat_ioctl(struct socket *sock, unsigned int cmd,
+		     unsigned long arg)
+{
+	int ret;
+
+	ret = do_vcc_ioctl(sock, cmd, arg, 1);
+	if (ret != -ENOIOCTLCMD)
+		return ret;
+
+	return do_atm_ioctl(sock, cmd, arg);
 }
 #endif
diff --git a/net/socket.c b/net/socket.c
index 05c4828..402abb3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -100,14 +100,6 @@
 #include <linux/if_tun.h>
 #include <linux/ipv6_route.h>
 #include <linux/route.h>
-#include <linux/atmdev.h>
-#include <linux/atmarp.h>
-#include <linux/atmsvc.h>
-#include <linux/atmlec.h>
-#include <linux/atmclip.h>
-#include <linux/atmmpc.h>
-#include <linux/atm_tcp.h>
-#include <linux/sonet.h>
 #include <linux/sockios.h>
 #include <linux/atalk.h>
 
@@ -2917,173 +2909,6 @@ static int old_bridge_ioctl(compat_ulong_t __user *argp)
 	return -EINVAL;
 }
 
-struct atmif_sioc32 {
-	compat_int_t	number;
-	compat_int_t	length;
-	compat_caddr_t	arg;
-};
-
-struct atm_iobuf32 {
-	compat_int_t	length;
-	compat_caddr_t	buffer;
-};
-
-#define ATM_GETLINKRATE32 _IOW('a', ATMIOC_ITF+1, struct atmif_sioc32)
-#define ATM_GETNAMES32    _IOW('a', ATMIOC_ITF+3, struct atm_iobuf32)
-#define ATM_GETTYPE32     _IOW('a', ATMIOC_ITF+4, struct atmif_sioc32)
-#define ATM_GETESI32	  _IOW('a', ATMIOC_ITF+5, struct atmif_sioc32)
-#define ATM_GETADDR32	  _IOW('a', ATMIOC_ITF+6, struct atmif_sioc32)
-#define ATM_RSTADDR32	  _IOW('a', ATMIOC_ITF+7, struct atmif_sioc32)
-#define ATM_ADDADDR32	  _IOW('a', ATMIOC_ITF+8, struct atmif_sioc32)
-#define ATM_DELADDR32	  _IOW('a', ATMIOC_ITF+9, struct atmif_sioc32)
-#define ATM_GETCIRANGE32  _IOW('a', ATMIOC_ITF+10, struct atmif_sioc32)
-#define ATM_SETCIRANGE32  _IOW('a', ATMIOC_ITF+11, struct atmif_sioc32)
-#define ATM_SETESI32      _IOW('a', ATMIOC_ITF+12, struct atmif_sioc32)
-#define ATM_SETESIF32     _IOW('a', ATMIOC_ITF+13, struct atmif_sioc32)
-#define ATM_GETSTAT32     _IOW('a', ATMIOC_SARCOM+0, struct atmif_sioc32)
-#define ATM_GETSTATZ32    _IOW('a', ATMIOC_SARCOM+1, struct atmif_sioc32)
-#define ATM_GETLOOP32	  _IOW('a', ATMIOC_SARCOM+2, struct atmif_sioc32)
-#define ATM_SETLOOP32	  _IOW('a', ATMIOC_SARCOM+3, struct atmif_sioc32)
-#define ATM_QUERYLOOP32	  _IOW('a', ATMIOC_SARCOM+4, struct atmif_sioc32)
-
-static struct {
-	unsigned int cmd32;
-	unsigned int cmd;
-} atm_ioctl_map[] = {
-	{ ATM_GETLINKRATE32, ATM_GETLINKRATE },
-	{ ATM_GETNAMES32,    ATM_GETNAMES },
-	{ ATM_GETTYPE32,     ATM_GETTYPE },
-	{ ATM_GETESI32,      ATM_GETESI },
-	{ ATM_GETADDR32,     ATM_GETADDR },
-	{ ATM_RSTADDR32,     ATM_RSTADDR },
-	{ ATM_ADDADDR32,     ATM_ADDADDR },
-	{ ATM_DELADDR32,     ATM_DELADDR },
-	{ ATM_GETCIRANGE32,  ATM_GETCIRANGE },
-	{ ATM_SETCIRANGE32,  ATM_SETCIRANGE },
-	{ ATM_SETESI32,      ATM_SETESI },
-	{ ATM_SETESIF32,     ATM_SETESIF },
-	{ ATM_GETSTAT32,     ATM_GETSTAT },
-	{ ATM_GETSTATZ32,    ATM_GETSTATZ },
-	{ ATM_GETLOOP32,     ATM_GETLOOP },
-	{ ATM_SETLOOP32,     ATM_SETLOOP },
-	{ ATM_QUERYLOOP32,   ATM_QUERYLOOP }
-};
-
-#define NR_ATM_IOCTL ARRAY_SIZE(atm_ioctl_map)
-
-static int do_atm_iobuf(struct net *net, struct socket *sock,
-			 unsigned int cmd, unsigned long arg)
-{
-	struct atm_iobuf   __user *iobuf;
-	struct atm_iobuf32 __user *iobuf32;
-	u32 data;
-	void __user *datap;
-	int len, err;
-
-	iobuf = compat_alloc_user_space(sizeof(*iobuf));
-	iobuf32 = compat_ptr(arg);
-
-	if (get_user(len, &iobuf32->length) ||
-	    get_user(data, &iobuf32->buffer))
-		return -EFAULT;
-	datap = compat_ptr(data);
-	if (put_user(len, &iobuf->length) ||
-	    put_user(datap, &iobuf->buffer))
-		return -EFAULT;
-
-	err = sock_do_ioctl(net, sock, cmd, (unsigned long)iobuf);
-
-	if (!err) {
-		if (copy_in_user(&iobuf32->length, &iobuf->length,
-				 sizeof(int)))
-			err = -EFAULT;
-	}
-
-	return err;
-}
-
-static int do_atmif_sioc(struct net *net, struct socket *sock,
-			 unsigned int cmd, unsigned long arg)
-{
-	struct atmif_sioc   __user *sioc;
-	struct atmif_sioc32 __user *sioc32;
-	u32 data;
-	void __user *datap;
-	int err;
-
-	sioc = compat_alloc_user_space(sizeof(*sioc));
-	sioc32 = compat_ptr(arg);
-
-	if (copy_in_user(&sioc->number, &sioc32->number, 2 * sizeof(int)) ||
-	    get_user(data, &sioc32->arg))
-		return -EFAULT;
-	datap = compat_ptr(data);
-	if (put_user(datap, &sioc->arg))
-		return -EFAULT;
-
-	err = sock_do_ioctl(net, sock, cmd, (unsigned long) sioc);
-
-	if (!err) {
-		if (copy_in_user(&sioc32->length, &sioc->length,
-				 sizeof(int)))
-			err = -EFAULT;
-	}
-	return err;
-}
-
-static int do_atm_ioctl(struct net *net, struct socket *sock,
-			 unsigned int cmd32, unsigned long arg)
-{
-	int i;
-	unsigned int cmd = 0;
-
-	switch (cmd32) {
-	case SONET_GETSTAT:
-	case SONET_GETSTATZ:
-	case SONET_GETDIAG:
-	case SONET_SETDIAG:
-	case SONET_CLRDIAG:
-	case SONET_SETFRAMING:
-	case SONET_GETFRAMING:
-	case SONET_GETFRSENSE:
-		return do_atmif_sioc(net, sock, cmd32, arg);
-	}
-
-	for (i = 0; i < NR_ATM_IOCTL; i++) {
-		if (cmd32 == atm_ioctl_map[i].cmd32) {
-			cmd = atm_ioctl_map[i].cmd;
-			break;
-		}
-	}
-	if (i == NR_ATM_IOCTL)
-	        return -EINVAL;
-
-        switch (cmd) {
-	case ATM_GETNAMES:
-		return do_atm_iobuf(net, sock, cmd, arg);
-
-	case ATM_GETLINKRATE:
-	case ATM_GETTYPE:
-	case ATM_GETESI:
-	case ATM_GETADDR:
-	case ATM_RSTADDR:
-	case ATM_ADDADDR:
-	case ATM_DELADDR:
-	case ATM_GETCIRANGE:
-	case ATM_SETCIRANGE:
-	case ATM_SETESI:
-	case ATM_SETESIF:
-	case ATM_GETSTAT:
-	case ATM_GETSTATZ:
-	case ATM_GETLOOP:
-	case ATM_SETLOOP:
-	case ATM_QUERYLOOP:
-		return do_atmif_sioc(net, sock, cmd, arg);
-	}
-
-	return -EINVAL;
-}
-
 static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 			 unsigned int cmd, unsigned long arg)
 {
@@ -3173,49 +2998,6 @@ static int compat_sock_ioctl_trans(struct file *file, struct socket *sock,
 	case SIOCSMIIREG:
 		return dev_ifsioc(net, sock, cmd, argp);
 
-	case ATM_GETLINKRATE32:
-	case ATM_GETNAMES32:
-	case ATM_GETTYPE32:
-	case ATM_GETESI32:
-	case ATM_GETADDR32:
-	case ATM_RSTADDR32:
-	case ATM_ADDADDR32:
-	case ATM_DELADDR32:
-	case ATM_GETCIRANGE32:
-	case ATM_SETCIRANGE32:
-	case ATM_SETESI32:
-	case ATM_SETESIF32:
-	case ATM_GETSTAT32:
-	case ATM_GETSTATZ32:
-	case ATM_GETLOOP32:
-	case ATM_SETLOOP32:
-	case ATM_QUERYLOOP32:
-	case SONET_GETSTAT:
-	case SONET_GETSTATZ:
-	case SONET_GETDIAG:
-	case SONET_SETDIAG:
-	case SONET_CLRDIAG:
-	case SONET_SETFRAMING:
-	case SONET_GETFRAMING:
-	case SONET_GETFRSENSE:
-		return do_atm_ioctl(net, sock, cmd, arg);
-
-	case ATMSIGD_CTRL:
-	case ATMARPD_CTRL:
-	case ATMLEC_CTRL:
-	case ATMLEC_MCAST:
-	case ATMLEC_DATA:
-	case ATM_SETSC:
-	case SIOCSIFATMTCP:
-	case SIOCMKCLIP:
-	case ATMARP_MKIP:
-	case ATMARP_SETENTRY:
-	case ATMARP_ENCAP:
-	case ATMTCP_CREATE:
-	case ATMTCP_REMOVE:
-	case ATMMPC_CTRL:
-	case ATMMPC_DATA:
-
 	case SIOCSARP:
 	case SIOCGARP:
 	case SIOCDARP:
-- 
1.6.3.3

