From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH -resend 1/6] mISDN: Add support for group membership check
Date: Wed, 22 May 2013 14:59:07 +0200
Message-ID: <1369227552-11743-1-git-send-email-jslaby@suse.cz>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	Jeff Mahoney <jeffm@suse.com>,
	Patrick Koppen <isdn4linux@koppen.de>,
	Jiri Slaby <jslaby@suse.cz>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: jirislaby@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Mahoney <jeffm@suse.com>

This patch adds a module parameter to allow a group access to the
mISDN devices. Otherwise, unpriviledged users on systems with ISDN
hardware have the ability to dial out, potentially causing expensive
bills.

Based on a different implementation by Patrick Koppen <isdn4linux@koppen.de>

Acked-by: Jeff Mahoney <jeffm@suse.com>
Cc: Patrick Koppen <isdn4linux@koppen.de>
Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/isdn/mISDN/core.c   | 3 +++
 drivers/isdn/mISDN/core.h   | 1 +
 drivers/isdn/mISDN/socket.c | 8 ++++++++
 3 files changed, 12 insertions(+)

diff --git a/drivers/isdn/mISDN/core.c b/drivers/isdn/mISDN/core.c
index da30c5c..a7050c3 100644
--- a/drivers/isdn/mISDN/core.c
+++ b/drivers/isdn/mISDN/core.c
@@ -21,10 +21,13 @@
 #include "core.h"
 
 static u_int debug;
+u_int misdn_permitted_gid;
 
 MODULE_AUTHOR("Karsten Keil");
 MODULE_LICENSE("GPL");
 module_param(debug, uint, S_IRUGO | S_IWUSR);
+module_param_named(gid, misdn_permitted_gid, uint, 0);
+MODULE_PARM_DESC(gid, "Unix group for accessing misdn socket (default 0)");
 
 static u64		device_ids;
 #define MAX_DEVICE_ID	63
diff --git a/drivers/isdn/mISDN/core.h b/drivers/isdn/mISDN/core.h
index 52695bb..6ea673f 100644
--- a/drivers/isdn/mISDN/core.h
+++ b/drivers/isdn/mISDN/core.h
@@ -17,6 +17,7 @@
 
 extern struct mISDNdevice	*get_mdevice(u_int);
 extern int			get_mdevice_count(void);
+extern u_int misdn_permitted_gid;
 
 /* stack status flag */
 #define mISDN_STACK_ACTION_MASK		0x0000ffff
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index e47dcb9..71f4986 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -612,6 +612,10 @@ data_sock_create(struct net *net, struct socket *sock, int protocol)
 {
 	struct sock *sk;
 
+	if(!capable(CAP_SYS_ADMIN) && (misdn_permitted_gid != current_gid())
+		&& (!in_group_p(misdn_permitted_gid)))
+			return -EPERM;
+
 	if (sock->type != SOCK_DGRAM)
 		return -ESOCKTNOSUPPORT;
 
@@ -694,6 +698,10 @@ base_sock_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 	case IMSETDEVNAME:
 	{
 		struct mISDN_devrename dn;
+		if(!capable(CAP_SYS_ADMIN)
+			&& (misdn_permitted_gid != current_gid())
+			&& (!in_group_p(misdn_permitted_gid)))
+				return -EPERM;
 		if (copy_from_user(&dn, (void __user *)arg,
 				   sizeof(dn))) {
 			err = -EFAULT;
-- 
1.8.2.3
