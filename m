From: akpm@linux-foundation.org
Subject: [patch 2/4] mISDN: add support for group membership check
Date: Fri, 13 Sep 2013 14:52:02 -0700
Message-ID: <20130913215202.7D16C31C1BF@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, jeffm@suse.com,
	isdn4linux@koppen.de, isdn@linux-pingi.de, jslaby@suse.cz,
	sergei.shtylyov@cogentembedded.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:37394 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302Ab3IMV5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 17:57:04 -0400
Received: by mail-vc0-f202.google.com with SMTP id gd11so228754vcb.3
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 14:57:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Mahoney <jeffm@suse.com>
Subject: mISDN: add support for group membership check

This patch adds a module parameter to allow a group access to the mISDN
devices.  Otherwise, unpriviledged users on systems with ISDN hardware
have the ability to dial out, potentially causing expensive bills.

Based on a different implementation by Patrick Koppen.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Acked-by: Jeff Mahoney <jeffm@suse.com>
Cc: Patrick Koppen <isdn4linux@koppen.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/core.c   |    6 ++++++
 drivers/isdn/mISDN/core.h   |    1 +
 drivers/isdn/mISDN/socket.c |    9 +++++++++
 3 files changed, 16 insertions(+)

diff -puN drivers/isdn/mISDN/core.c~misdn-add-support-for-group-membership-check drivers/isdn/mISDN/core.c
--- a/drivers/isdn/mISDN/core.c~misdn-add-support-for-group-membership-check
+++ a/drivers/isdn/mISDN/core.c
@@ -21,10 +21,14 @@
 #include "core.h"
 
 static u_int debug;
+static u_int gid;
+kgid_t misdn_permitted_gid;
 
 MODULE_AUTHOR("Karsten Keil");
 MODULE_LICENSE("GPL");
 module_param(debug, uint, S_IRUGO | S_IWUSR);
+module_param(gid, uint, 0);
+MODULE_PARM_DESC(gid, "Unix group for accessing misdn socket (default 0)");
 
 static u64		device_ids;
 #define MAX_DEVICE_ID	63
@@ -372,6 +376,8 @@ mISDNInit(void)
 {
 	int	err;
 
+	misdn_permitted_gid = make_kgid(current_user_ns(), gid);
+
 	printk(KERN_INFO "Modular ISDN core version %d.%d.%d\n",
 	       MISDN_MAJOR_VERSION, MISDN_MINOR_VERSION, MISDN_RELEASE);
 	mISDN_init_clock(&debug);
diff -puN drivers/isdn/mISDN/core.h~misdn-add-support-for-group-membership-check drivers/isdn/mISDN/core.h
--- a/drivers/isdn/mISDN/core.h~misdn-add-support-for-group-membership-check
+++ a/drivers/isdn/mISDN/core.h
@@ -17,6 +17,7 @@
 
 extern struct mISDNdevice	*get_mdevice(u_int);
 extern int			get_mdevice_count(void);
+extern kgid_t misdn_permitted_gid;
 
 /* stack status flag */
 #define mISDN_STACK_ACTION_MASK		0x0000ffff
diff -puN drivers/isdn/mISDN/socket.c~misdn-add-support-for-group-membership-check drivers/isdn/mISDN/socket.c
--- a/drivers/isdn/mISDN/socket.c~misdn-add-support-for-group-membership-check
+++ a/drivers/isdn/mISDN/socket.c
@@ -612,6 +612,11 @@ data_sock_create(struct net *net, struct
 {
 	struct sock *sk;
 
+	if (!capable(CAP_SYS_ADMIN) &&
+			!gid_eq(misdn_permitted_gid, current_gid()) &&
+			!in_group_p(misdn_permitted_gid))
+		return -EPERM;
+
 	if (sock->type != SOCK_DGRAM)
 		return -ESOCKTNOSUPPORT;
 
@@ -694,6 +699,10 @@ base_sock_ioctl(struct socket *sock, uns
 	case IMSETDEVNAME:
 	{
 		struct mISDN_devrename dn;
+		if (!capable(CAP_SYS_ADMIN) &&
+				!gid_eq(misdn_permitted_gid, current_gid()) &&
+				!in_group_p(misdn_permitted_gid))
+			return -EPERM;
 		if (copy_from_user(&dn, (void __user *)arg,
 				   sizeof(dn))) {
 			err = -EFAULT;
_
