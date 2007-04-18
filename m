From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 5/7] [IrDA] IrDA monitor mode
Date: Thu, 19 Apr 2007 00:32:07 +0300
Message-ID: <20070418214751.455457680@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0006-IrDA-net-2.6.22-IrDA-monitor-mode.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Through a protocol specific ioctl, one can disable IrDA TX in order to
monitor an IrDA link.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 include/linux/irda.h     |    7 +++++
 include/net/irda/irlap.h |    2 +
 net/irda/af_irda.c       |   58 +++++++++++++++++++++++++++++++++++++++++++++-
 net/irda/irlap_frame.c   |    8 ++++++
 4 files changed, 74 insertions(+), 1 deletions(-)

Index: net-2.6.22-quilt/include/linux/irda.h
===================================================================
--- net-2.6.22-quilt.orig/include/linux/irda.h	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/include/linux/irda.h	2007-04-18 02:16:43.000000000 +0300
@@ -172,6 +172,12 @@
 #define SIOCSDTRRTS    (SIOCDEVPRIVATE + 8)
 #define SIOCGQOS       (SIOCDEVPRIVATE + 9)
 
+/* Protocol private ioctls */
+#define SIOCIRDASETMODE (SIOCPROTOPRIVATE + 0)
+#define SIOCIRDAGETMODE (SIOCPROTOPRIVATE + 1)
+
+#define IRDA_MODE_MONITOR   0x1
+
 /* No reason to include <linux/if.h> just because of this one ;-) */
 #define IRNAMSIZ 16 
 
@@ -209,6 +215,7 @@
 	} ifr_ifru;
 };
 
+#define ifr_name      ifr_ifrn.ifrn_name
 #define ifr_baudrate  ifr_ifru.ifru_qos.baudrate
 #define ifr_receiving ifr_ifru.ifru_receiving 
 #define ifr_dongle    ifr_ifru.ifru_dongle
Index: net-2.6.22-quilt/include/net/irda/irlap.h
===================================================================
--- net-2.6.22-quilt.orig/include/net/irda/irlap.h	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/include/net/irda/irlap.h	2007-04-18 02:16:43.000000000 +0300
@@ -208,6 +208,8 @@
 	int    xbofs_delay;   /* Nr of XBOF's used to MTT */
 	int    bofs_count;    /* Negotiated extra BOFs */
 	int    next_bofs;     /* Negotiated extra BOFs after next frame */
+
+	int    mode;     /* 1 is for monitor mode (TX disabled) */
 };
 
 /* 
Index: net-2.6.22-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
+++ net-2.6.22-quilt/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
@@ -49,7 +49,6 @@
 #include <linux/sockios.h>
 #include <linux/init.h>
 #include <linux/net.h>
-#include <linux/irda.h>
 #include <linux/poll.h>
 
 #include <asm/ioctls.h>		/* TIOCOUTQ, TIOCINQ */
@@ -1745,6 +1744,7 @@
 static int irda_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
+	void __user *argp = (void __user *)arg;
 
 	IRDA_DEBUG(4, "%s(), cmd=%#x\n", __FUNCTION__, cmd);
 
@@ -1786,6 +1786,62 @@
 	case SIOCGIFMETRIC:
 	case SIOCSIFMETRIC:
 		return -EINVAL;
+
+	case SIOCIRDASETMODE: {
+		struct if_irda_req if_irda;
+		struct net_device * dev;
+		struct irlap_cb * irlap;
+
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (copy_from_user(&if_irda, argp, sizeof(struct if_irda_req)))
+			return -EFAULT;
+
+		dev = dev_get_by_name(if_irda.ifr_name);
+		if (!dev)
+			return -ENODEV;
+
+		irlap = (struct irlap_cb *)dev->atalk_ptr;
+		if (!irlap)
+			return -ENODEV;
+
+		IRDA_DEBUG(4, "%s(): Setting %s to 0x%x\n", __FUNCTION__,
+			   dev->name, if_irda.ifr_mode);
+
+		irlap->mode = if_irda.ifr_mode;
+
+		dev_put(dev);
+
+		break;
+	}
+	case SIOCIRDAGETMODE: {
+		struct if_irda_req if_irda;
+		struct net_device * dev;
+		struct irlap_cb * irlap;
+
+		if (copy_from_user(&if_irda, argp, sizeof(struct if_irda_req)))
+			return -EFAULT;
+
+		dev = dev_get_by_name(if_irda.ifr_name);
+		if (!dev)
+			return -ENODEV;
+
+		irlap = (struct irlap_cb *)dev->atalk_ptr;
+		if (!irlap)
+			return -ENODEV;
+
+		if_irda.ifr_mode = irlap->mode;
+
+		dev_put(dev);
+
+		IRDA_DEBUG(4, "%s(): %s mode is 0x%x\n", __FUNCTION__,
+			   dev->name, if_irda.ifr_mode);
+
+		if (copy_to_user(argp, &if_irda, sizeof(struct if_irda_req)))
+			return -EFAULT;
+	}
+		break;
 	default:
 		IRDA_DEBUG(1, "%s(), doing device ioctl!\n", __FUNCTION__);
 		return -ENOIOCTLCMD;
Index: net-2.6.22-quilt/net/irda/irlap_frame.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/irlap_frame.c	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/net/irda/irlap_frame.c	2007-04-18 02:16:43.000000000 +0300
@@ -101,6 +101,14 @@
 
 	irlap_insert_info(self, skb);
 
+	if (unlikely(self->mode & IRDA_MODE_MONITOR)) {
+		IRDA_DEBUG(3, "%s(): %s is in monitor mode\n", __FUNCTION__,
+			   self->netdev->name);
+		dev_kfree_skb(skb);
+		return;
+	}
+
+
 	dev_queue_xmit(skb);
 }
 

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
