From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (10/11) bridge -- compat hooks for new-ioctl interface
Date: Fri, 21 May 2004 16:39:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163920.641635c1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replacement 64 bit compatibility code for the new ioctl's.  The new 
ioctl's all pass through clean, but for the old style ioctl's it uses
the mis-feature of the earlier bridge-utils that they check the API version.

So if an old 32bit version of brctl is run on a 64bit platform it will
report
	bridge utilities not compatible with kernel version

Tested on Itanium 1; but should solve issue for sparc, ppc, and x86_64

diff -Nru a/fs/compat_ioctl.c b/fs/compat_ioctl.c
--- a/fs/compat_ioctl.c	2004-05-20 14:44:03 -07:00
+++ b/fs/compat_ioctl.c	2004-05-20 14:44:03 -07:00
@@ -20,6 +20,7 @@
 #include <linux/smp_lock.h>
 #include <linux/ioctl.h>
 #include <linux/if.h>
+#include <linux/if_bridge.h>
 #include <linux/slab.h>
 #include <linux/hdreg.h>
 #include <linux/raid/md.h>
@@ -3072,18 +3073,19 @@
 	return sys_ioctl(fd, cmd, (unsigned long) iwr);
 }
 
-/* Emulate old style bridge ioctls */
-static int do_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+/* Since old style bridge ioctl's endup using SIOCDEVPRIVATE
+ * for some operations; this forces use of the newer bridge-utils that
+ * use compatiable ioctls
+ */
+static int old_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	u32 tmp;
-	unsigned long *argbuf = compat_alloc_user_space(3 * sizeof(unsigned long)); 
-	int i;	
-	for (i = 0; i < 3; i++) {
-		if (get_user(tmp, i + ((u32 *)arg)) ||
-		    put_user(tmp, i + argbuf))
-			return -EFAULT;
-	}
-	return sys_ioctl(fd, cmd, (unsigned long)argbuf);
+
+	if (get_user(tmp, (u32 *) arg))
+		return -EFAULT;
+	if (tmp == BRCTL_GET_VERSION)
+		return BRCTL_VERSION + 1;
+	return -EINVAL;
 }
 
 #undef CODE
@@ -3133,6 +3135,8 @@
 HANDLE_IOCTL(SIOCBONDCHANGEACTIVE, bond_ioctl)
 HANDLE_IOCTL(SIOCADDRT, routing_ioctl)
 HANDLE_IOCTL(SIOCDELRT, routing_ioctl)
+HANDLE_IOCTL(SIOCBRADDIF, dev_ifsioc)
+HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
 /* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
 HANDLE_IOCTL(SIOCRTMSG, ret_einval)
 HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
@@ -3263,8 +3267,8 @@
 HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
-HANDLE_IOCTL(SIOCSIFBR, do_bridge_ioctl)
-HANDLE_IOCTL(SIOCGIFBR, do_bridge_ioctl)
+HANDLE_IOCTL(SIOCSIFBR, old_bridge_ioctl)
+HANDLE_IOCTL(SIOCGIFBR, old_bridge_ioctl)
 
 #undef DECLARES
 #endif
diff -Nru a/include/linux/compat_ioctl.h b/include/linux/compat_ioctl.h
--- a/include/linux/compat_ioctl.h	2004-05-20 14:44:03 -07:00
+++ b/include/linux/compat_ioctl.h	2004-05-20 14:44:03 -07:00
@@ -275,6 +275,8 @@
 COMPATIBLE_IOCTL(SIOCSMIIREG)
 COMPATIBLE_IOCTL(SIOCGIFVLAN)
 COMPATIBLE_IOCTL(SIOCSIFVLAN)
+COMPATIBLE_IOCTL(SIOCBRADDBR)
+COMPATIBLE_IOCTL(SIOCBRDELBR)
 /* SG stuff */
 COMPATIBLE_IOCTL(SG_SET_TIMEOUT)
 COMPATIBLE_IOCTL(SG_GET_TIMEOUT)
