From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH net-next 1/5] X25 remove bkl in subscription ioctls
Date: Thu, 25 Nov 2010 23:18:15 +1100
Message-ID: <1290687495.5053.35.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:50013 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245Ab0KYMSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Nov 2010 07:18:04 -0500
Received: by yxp4 with SMTP id 4so426993yxp.19
        for <netdev@vger.kernel.org>; Thu, 25 Nov 2010 04:18:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 include/net/x25.h  |    2 ++
 net/x25/af_x25.c   |   12 ++++--------
 net/x25/x25_link.c |    8 ++++++--
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/x25.h b/include/net/x25.h
index 1479cb4..a06119a 100644
--- a/include/net/x25.h
+++ b/include/net/x25.h
@@ -315,6 +315,8 @@ extern struct list_head x25_route_list;
 extern rwlock_t x25_route_list_lock;
 extern struct list_head x25_forward_list;
 extern rwlock_t x25_forward_list_lock;
+extern struct list_head x25_neigh_list;
+extern rwlock_t x25_neigh_list_lock;
 
 extern int x25_proc_init(void);
 extern void x25_proc_exit(void);
diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 2351ace..45be72c 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1415,17 +1415,13 @@ static int x25_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 			rc = x25_route_ioctl(cmd, argp);
 			break;
 		case SIOCX25GSUBSCRIP:
-			lock_kernel();
 			rc = x25_subscr_ioctl(cmd, argp);
-			unlock_kernel();
 			break;
 		case SIOCX25SSUBSCRIP:
 			rc = -EPERM;
 			if (!capable(CAP_NET_ADMIN))
 				break;
-			lock_kernel();
 			rc = x25_subscr_ioctl(cmd, argp);
-			unlock_kernel();
 			break;
 		case SIOCX25GFACILITIES: {
 			struct x25_facilities fac = x25->facilities;
@@ -1646,16 +1642,20 @@ static int compat_x25_subscr_ioctl(unsigned int cmd,
 	dev_put(dev);
 
 	if (cmd == SIOCX25GSUBSCRIP) {
+		read_lock_bh(&x25_neigh_list_lock);
 		x25_subscr.extended = nb->extended;
 		x25_subscr.global_facil_mask = nb->global_facil_mask;
+		read_unlock_bh(&x25_neigh_list_lock);
 		rc = copy_to_user(x25_subscr32, &x25_subscr,
 				sizeof(*x25_subscr32)) ? -EFAULT : 0;
 	} else {
 		rc = -EINVAL;
 		if (x25_subscr.extended == 0 || x25_subscr.extended == 1) {
 			rc = 0;
+			write_lock_bh(&x25_neigh_list_lock);
 			nb->extended = x25_subscr.extended;
 			nb->global_facil_mask = x25_subscr.global_facil_mask;
+			write_unlock_bh(&x25_neigh_list_lock);
 		}
 	}
 	x25_neigh_put(nb);
@@ -1711,17 +1711,13 @@ static int compat_x25_ioctl(struct socket *sock, unsigned int cmd,
 		rc = x25_route_ioctl(cmd, argp);
 		break;
 	case SIOCX25GSUBSCRIP:
-		lock_kernel();
 		rc = compat_x25_subscr_ioctl(cmd, argp);
-		unlock_kernel();
 		break;
 	case SIOCX25SSUBSCRIP:
 		rc = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		lock_kernel();
 		rc = compat_x25_subscr_ioctl(cmd, argp);
-		unlock_kernel();
 		break;
 	case SIOCX25GFACILITIES:
 	case SIOCX25SFACILITIES:
diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index 73e7b95..4c81f6a 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -31,8 +31,8 @@
 #include <linux/init.h>
 #include <net/x25.h>
 
-static LIST_HEAD(x25_neigh_list);
-static DEFINE_RWLOCK(x25_neigh_list_lock);
+LIST_HEAD(x25_neigh_list);
+DEFINE_RWLOCK(x25_neigh_list_lock);
 
 static void x25_t20timer_expiry(unsigned long);
 
@@ -360,16 +360,20 @@ int x25_subscr_ioctl(unsigned int cmd, void __user *arg)
 	dev_put(dev);
 
 	if (cmd == SIOCX25GSUBSCRIP) {
+		read_lock_bh(&x25_neigh_list_lock);
 		x25_subscr.extended	     = nb->extended;
 		x25_subscr.global_facil_mask = nb->global_facil_mask;
+		read_unlock_bh(&x25_neigh_list_lock);
 		rc = copy_to_user(arg, &x25_subscr,
 				  sizeof(x25_subscr)) ? -EFAULT : 0;
 	} else {
 		rc = -EINVAL;
 		if (!(x25_subscr.extended && x25_subscr.extended != 1)) {
 			rc = 0;
+			write_lock_bh(&x25_neigh_list_lock);
 			nb->extended	     = x25_subscr.extended;
 			nb->global_facil_mask = x25_subscr.global_facil_mask;
+			write_unlock_bh(&x25_neigh_list_lock);
 		}
 	}
 	x25_neigh_put(nb);
-- 
1.7.1



