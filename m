From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] clean up the divert ifdef mess
Date: Tue, 20 May 2003 17:30:44 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520173044.A21103@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With some stubs in divert.h this looks a lot nicer.  Compile-tested with
and without CONFIG_NET_DIVERT.


--- 1.19/drivers/net/Space.c	Fri Mar  7 05:30:51 2003
+++ edited/drivers/net/Space.c	Mon May 19 19:16:24 2003
@@ -131,26 +131,20 @@
 {
 	struct devprobe *p = plist;
 	unsigned long base_addr = dev->base_addr;
-#ifdef CONFIG_NET_DIVERT
 	int ret;
-#endif /* CONFIG_NET_DIVERT */
 
 	while (p->probe != NULL) {
 		if (base_addr && p->probe(dev) == 0) {	/* probe given addr */
-#ifdef CONFIG_NET_DIVERT
 			ret = alloc_divert_blk(dev);
 			if (ret)
 				return ret;
-#endif /* CONFIG_NET_DIVERT */
 			return 0;
 		} else if (p->status == 0) {		/* has autoprobe failed yet? */
 			p->status = p->probe(dev);	/* no, try autoprobe */
 			if (p->status == 0) {
-#ifdef CONFIG_NET_DIVERT
 				ret = alloc_divert_blk(dev);
 				if (ret)
 					return ret;
-#endif /* CONFIG_NET_DIVERT */
 				return 0;
 			}
 		}
--- 1.1/include/linux/divert.h	Tue Feb  5 18:39:43 2002
+++ edited/include/linux/divert.h	Mon May 19 19:25:29 2003
@@ -107,11 +107,24 @@
 
 /* diverter functions */
 #include <linux/skbuff.h>
+
+#ifdef CONFIG_NET_DIVERT
 int alloc_divert_blk(struct net_device *);
 void free_divert_blk(struct net_device *);
 int divert_ioctl(unsigned int cmd, struct divert_cf *arg);
 void divert_frame(struct sk_buff *skb);
+static inline void handle_diverter(struct sk_buff *skb)
+{
+	/* if diversion is supported on device, then divert */
+	if (skb->dev->divert && skb->dev->divert->divert)
+		divert_frame(skb);
+}
 
+#else
+# define alloc_divert_blk(dev)		(0)
+# define free_divert_blk(dev)		do {} while (0)
+# define divert_ioctl(cmd, arg)		(-ENOPKG)
+# define handle_diverter(skb)		do {} while (0)
+#endif
 #endif 
-
 #endif	/* _LINUX_DIVERT_H */
--- 1.61/net/socket.c	Sat May 17 21:39:14 2003
+++ edited/net/socket.c	Mon May 19 19:25:12 2003
@@ -821,11 +821,7 @@
 		case SIOCGIFDIVERT:
 		case SIOCSIFDIVERT:
 		/* Convert this to call through a hook */
-#ifdef CONFIG_NET_DIVERT
 			err = divert_ioctl(cmd, (struct divert_cf *)arg);
-#else
-			err = -ENOPKG;
-#endif	/* CONFIG_NET_DIVERT */
 			break;
 		case SIOCADDDLCI:
 		case SIOCDELDLCI:
===== net/core/dev.c 1.74 vs edited =====
--- 1.74/net/core/dev.c	Sat May 17 21:39:13 2003
+++ edited/net/core/dev.c	Mon May 19 19:23:05 2003
@@ -1482,15 +1482,6 @@
 
 #endif
 
-static inline void handle_diverter(struct sk_buff *skb)
-{
-#ifdef CONFIG_NET_DIVERT
-	/* if diversion is supported on device, then divert */
-	if (skb->dev->divert && skb->dev->divert->divert)
-		divert_frame(skb);
-#endif
-}
-
 static inline int __handle_bridge(struct sk_buff *skb,
 			struct packet_type **pt_prev, int *ret)
 {
@@ -2590,11 +2581,9 @@
 	dev->fastpath_lock = RW_LOCK_UNLOCKED;
 #endif
 
-#ifdef CONFIG_NET_DIVERT
 	ret = alloc_divert_blk(dev);
 	if (ret)
 		goto out;
-#endif /* CONFIG_NET_DIVERT */
 
 	dev->iflink = -1;
 
@@ -2660,9 +2649,7 @@
 out:
 	return ret;
 out_err:
-#ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
-#endif
 	goto out;
 }
 
@@ -2769,9 +2756,7 @@
 	/* Notifier chain MUST detach us from master device. */
 	BUG_TRAP(!dev->master);
 
-#ifdef CONFIG_NET_DIVERT
 	free_divert_blk(dev);
-#endif
 
 	if (dev->destructor != NULL) {
 #ifdef NET_REFCNT_DEBUG
