From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Fix CONFIG_COMPAT with !CONFIG_NET
Date: Tue, 31 Aug 2004 12:06:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3d617k4ex.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Fix compilation with CONFIG_COMPAT set and CONFIG_NET disabled.

diff -urpN -X ../KDIFX linux/net/Makefile linux-2.6.8-amd64/net/Makefile
--- linux/net/Makefile	2004-04-06 13:12:24.000000000 +0200
+++ linux-2.6.8-amd64/net/Makefile	2004-08-05 17:55:29.000000000 +0200
@@ -9,7 +9,8 @@ obj-y	:= nonet.o
 
 obj-$(CONFIG_NET)		:= socket.o core/
 
-obj-$(CONFIG_COMPAT)		+= compat.o
+tmp-$(CONFIG_COMPAT) 		:= compat.o
+obj-$(CONFIG_NET)		+= $(tmp-y)
 
 # LLC has to be linked before the files in net/802/
 obj-$(CONFIG_LLC)		+= llc/
diff -urpN -X ../KDIFX linux/fs/compat_ioctl.c linux-2.6.8-amd64/fs/compat_ioctl.c
--- linux/fs/compat_ioctl.c	2004-08-15 19:45:41.000000000 +0200
+++ linux-2.6.8-amd64/fs/compat_ioctl.c	2004-08-05 17:30:20.000000000 +0200
@@ -407,6 +407,7 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_NET
 static int do_siocgstamp(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	struct compat_timeval __user *up = compat_ptr(arg);
@@ -461,7 +462,6 @@ struct ifconf32 {
         compat_caddr_t  ifcbuf;
 };
 
-#ifdef CONFIG_NET
 static int dev_ifname32(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	struct net_device *dev;
@@ -481,7 +481,6 @@ static int dev_ifname32(unsigned int fd,
 	err = copy_to_user(compat_ptr(arg), &ifr32, sizeof(ifr32));
 	return (err ? -EFAULT : 0);
 }
-#endif
 
 static int dev_ifconf(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
@@ -797,6 +796,7 @@ static int routing_ioctl(unsigned int fd
 
 	return ret;
 }
+#endif
 
 struct hd_geometry32 {
 	unsigned char heads;
@@ -1872,7 +1872,8 @@ static int do_atm_ioctl(unsigned int fd,
         return -EINVAL;
 }
 
-static int ret_einval(unsigned int fd, unsigned int cmd, unsigned long arg)
+static __attribute__((used)) int 
+ret_einval(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
 	return -EINVAL;
 }
@@ -3162,7 +3163,6 @@ HANDLE_IOCTL(MEMREADOOB32, mtd_rw_oob)
 HANDLE_IOCTL(MEMWRITEOOB32, mtd_rw_oob)
 #ifdef CONFIG_NET
 HANDLE_IOCTL(SIOCGIFNAME, dev_ifname32)
-#endif
 HANDLE_IOCTL(SIOCGIFCONF, dev_ifconf)
 HANDLE_IOCTL(SIOCGIFFLAGS, dev_ifsioc)
 HANDLE_IOCTL(SIOCSIFFLAGS, dev_ifsioc)
@@ -3206,6 +3206,7 @@ HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
 /* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
 HANDLE_IOCTL(SIOCRTMSG, ret_einval)
 HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
+#endif
 HANDLE_IOCTL(HDIO_GETGEO, hdio_getgeo)
 HANDLE_IOCTL(BLKRAGET, w_long)
 HANDLE_IOCTL(BLKGETSIZE, w_long)
