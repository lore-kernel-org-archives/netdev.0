From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: [PATCH 2.6.X] 32->64 bit conversion for wireless private ioctl
Date: Thu, 24 Jun 2004 16:43:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624234307.GA5514@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>,
        Andi Kleen <ak@suse.de>, Pavel Machek <pavel@suse.cz>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi all,

	(Sorry for the spam)

	The Wireless Extensions use a bunch of driver specific
ioctl. Jeff told me that those can't be safe when running a 32 bit
userspace on a 64 bit kernel. So, I did a patch...
	Patch is for kernel 2.6.5.

	Treat this patch as a proof of concept. I don't have any 64
bit machine, so no way to compile it (without talking of actually
testing it). But this is where I hope you guys will help me ;-)

	Waiting for your feedback,
	Have fun...

	Jean

----------------------------------------------------------------

diff -u -p linux/include/net/iw_handler.p1.h linux/include/net/iw_handler.h
--- linux/include/net/iw_handler.p1.h	Thu Jun 24 16:27:53 2004
+++ linux/include/net/iw_handler.h	Thu Jun 24 16:18:29 2004
@@ -412,6 +412,9 @@ struct iw_public_data {
  * Those may be called only within the kernel.
  */
 
+/* Data needed by fs/compat_ioctl.c for 32->64 bit conversion */
+extern const char iw_priv_type_size[];
+
 /* First : function strictly used inside the kernel */
 
 /* Handle /proc/net/wireless, called in net/code/dev.c */
diff -u -p linux/net/core/wireless.p1.c linux/net/core/wireless.c
--- linux/net/core/wireless.p1.c	Thu Jun 24 16:15:07 2004
+++ linux/net/core/wireless.c	Thu Jun 24 16:17:07 2004
@@ -301,7 +301,7 @@ static const int standard_event_num = (s
 				       sizeof(struct iw_ioctl_description));
 
 /* Size (in bytes) of the various private data types */
-static const char priv_type_size[] = {
+const char iw_priv_type_size[] = {
 	0,				/* IW_PRIV_TYPE_NONE */
 	1,				/* IW_PRIV_TYPE_BYTE */
 	1,				/* IW_PRIV_TYPE_CHAR */
@@ -415,7 +415,7 @@ static inline int get_priv_size(__u16	ar
 	int	num = args & IW_PRIV_SIZE_MASK;
 	int	type = (args & IW_PRIV_TYPE_MASK) >> 12;
 
-	return num * priv_type_size[type];
+	return num * iw_priv_type_size[type];
 }
 
 
diff -u -p linux/fs/compat_ioctl.p1.c linux/fs/compat_ioctl.c
--- linux/fs/compat_ioctl.p1.c	Thu Jun 24 16:15:18 2004
+++ linux/fs/compat_ioctl.c	Thu Jun 24 16:24:34 2004
@@ -67,6 +67,7 @@
 #include <linux/i2c.h>
 #include <linux/i2c-dev.h>
 #include <linux/wireless.h>
+#include <net/iw_handler.h>
 
 #include <net/sock.h>          /* siocdevprivate_ioctl */
 #include <net/bluetooth/bluetooth.h>
@@ -3070,6 +3071,79 @@ static int do_wireless_ioctl(unsigned in
 	return sys_ioctl(fd, cmd, (unsigned long) iwr);
 }
 
+static int do_wireless_private_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct iwreq *iwr, *iwr_u;
+	struct net_device *dev;
+	struct iw_priv_args *descr = NULL;
+	__u16 iw_args;
+	int offset = 0;
+	int extra_size = 0;
+
+	iwr_u = (struct iwreq *) compat_ptr(arg);
+	iwr = compat_alloc_user_space(sizeof(*iwr));
+	if (iwr == NULL)
+		return -ENOMEM;
+
+	if (verify_area(VERIFY_WRITE, iwr, sizeof(*iwr)))
+		return -EFAULT;
+
+	if (__copy_in_user(&iwr->ifr_ifrn.ifrn_name[0],
+			   &iwr_u->ifr_ifrn.ifrn_name[0],
+			   sizeof(struct iwreq)))
+		return -EFAULT;
+
+	/* Wireless Private ioctls are different from regular Wireless
+	 * ioctls, in that they are driver specific. Therefore, we have
+	 * to ask the driver how the ioctl should be handled. 
+	 * This is a bit messy, see wireless.c for details. Jean II
+	 */
+
+	//dev_load(ifr.ifr_name);
+	/* Lock */
+	rtnl_lock();
+
+	/* Make sure the device exist */
+	if ((dev = __dev_get_by_name(ifr->ifr_name)) == NULL)
+		return -ENODEV;
+
+	/* Get the description of the IOCTL */
+	for(i = 0; i < dev->wireless_handlers->num_private_args; i++)
+		if(cmd == dev->wireless_handlers->private_args[i].cmd) {
+			descr = &(dev->wireless_handlers->private_args[i]);
+			break;
+		}
+	if(!descr)
+		return -EFAULT;
+
+	/* Compute size of arguments */
+	if(IW_IS_SET(cmd)) {
+		/* Check for sub-ioctl handler */
+		if(descr->name[0] == '\0')
+			offset = sizeof(__u32);
+		iw_args = descr->set_args;
+	} else
+		iw_args = descr->get_args;
+	extra_size = ((iw_args & IW_PRIV_SIZE_MASK) *
+		      iw_priv_type_size[(args & IW_PRIV_TYPE_MASK) >> 12]);
+
+	/* Are the args passed inline ? */
+	if((iw_args & IW_PRIV_SIZE_FIXED) &&
+	   ((extra_size + offset) <= IFNAMSIZ))
+		extra_size = 0;
+
+	/* Unlock */
+	rtnl_unlock();
+
+	/* Done */
+	if(extra_size)
+		/* Convert struct iw_point appropriately */
+		return do_wireless_ioctl(fd, cmd, (unsigned long) iwr);
+	else
+		/* No conversion needed */
+		return sys_ioctl(fd, cmd, (unsigned long) iwr);
+}
+
 /* Emulate old style bridge ioctls */
 static int do_bridge_ioctl(unsigned int fd, unsigned int cmd, unsigned long arg)
 {
@@ -3261,6 +3335,40 @@ HANDLE_IOCTL(SIOCSIWNICKN, do_wireless_i
 HANDLE_IOCTL(SIOCGIWNICKN, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCSIWENCODE, do_wireless_ioctl)
 HANDLE_IOCTL(SIOCGIWENCODE, do_wireless_ioctl)
+/* wireless private */
+HANDLE_IOCTL(SIOCIWFIRSTPRIV, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 1, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 2, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 3, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 4, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 5, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 6, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 7, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 8, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 9, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 10, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 11, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 12, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 13, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 14, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 15, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 16, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 17, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 18, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 19, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 20, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 21, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 22, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 23, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 24, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 25, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 26, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 27, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 28, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 29, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 30, do_wireless_private_ioctl)
+HANDLE_IOCTL(SIOCIWFIRSTPRIV + 31, do_wireless_private_ioctl)
+/* bridge */
 HANDLE_IOCTL(SIOCSIFBR, do_bridge_ioctl)
 HANDLE_IOCTL(SIOCGIFBR, do_bridge_ioctl)
 
