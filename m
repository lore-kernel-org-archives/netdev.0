From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] more direct access of dev->refcnt
Date: Wed, 7 May 2003 13:23:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507132326.0864b07f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, philb@gnu.org, SteveW@ACM.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following places directly increment dev refcount rather than
using the inline dev_hold.

Also, Econet keeps pointers to devices without holding refcount which
is wrong.

diff -Nru a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
--- a/net/decnet/dn_fib.c	Wed May  7 13:22:27 2003
+++ b/net/decnet/dn_fib.c	Wed May  7 13:22:27 2003
@@ -218,7 +218,7 @@
 			if (!(dev->flags&IFF_UP))
 				return -ENETDOWN;
 			nh->nh_dev = dev;
-			atomic_inc(&dev->refcnt);
+			dev_hold(dev);
 			nh->nh_scope = RT_SCOPE_LINK;
 			return 0;
 		}
@@ -242,7 +242,7 @@
 		nh->nh_dev = DN_FIB_RES_DEV(res);
 		if (nh->nh_dev == NULL)
 			goto out;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		err = -ENETDOWN;
 		if (!(nh->nh_dev->flags & IFF_UP))
 			goto out;
@@ -262,7 +262,7 @@
 		if (!(dev->flags&IFF_UP))
 			return -ENETDOWN;
 		nh->nh_dev = dev;
-		atomic_inc(&nh->nh_dev->refcnt);
+		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
 	}
 
diff -Nru a/net/econet/af_econet.c b/net/econet/af_econet.c
--- a/net/econet/af_econet.c	Wed May  7 13:22:27 2003
+++ b/net/econet/af_econet.c	Wed May  7 13:22:27 2003
@@ -325,7 +325,7 @@
 	{
 		/* Real hardware Econet.  We're not worthy etc. */
 #ifdef CONFIG_ECONET_NATIVE
-		atomic_inc(&dev->refcnt);
+		dev_hold(dev);
 		
 		skb = sock_alloc_send_skb(sk, len+dev->hard_header_len+15, 
 					  msg->msg_flags & MSG_DONTWAIT, &err);
