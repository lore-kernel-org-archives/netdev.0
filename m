From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (9/11) bridge -- new ioctl interface for 32/64
 compatiablity
Date: Fri, 21 May 2004 16:39:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521163918.14c799d6@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add four new ioctl's for the operations that can't be done through sysfs.
The existing bridge ioctl's are multiplexed, and most go through SIOCDEVPRIVATE
so they won't work in a mixed 32/64bit environment.

The new release of bridge-utils will use these if possible, and fall
back to the old interface.
 
diff -Nru a/include/linux/if_bridge.h b/include/linux/if_bridge.h
--- a/include/linux/if_bridge.h	2004-05-20 14:46:10 -07:00
+++ b/include/linux/if_bridge.h	2004-05-20 14:46:10 -07:00
@@ -104,7 +104,7 @@
 
 #include <linux/netdevice.h>
 
-extern void brioctl_set(int (*ioctl_hook)(unsigned long));
+extern void brioctl_set(int (*ioctl_hook)(unsigned int, unsigned long));
 extern int (*br_handle_frame_hook)(struct sk_buff *skb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
 
diff -Nru a/include/linux/sockios.h b/include/linux/sockios.h
--- a/include/linux/sockios.h	2004-05-20 14:46:10 -07:00
+++ b/include/linux/sockios.h	2004-05-20 14:46:10 -07:00
@@ -116,6 +116,12 @@
 #define SIOCBONDINFOQUERY      0x8994	/* rtn info about bond state    */
 #define SIOCBONDCHANGEACTIVE   0x8995   /* update to a new active slave */
 			
+/* bridge calls */
+#define SIOCBRADDBR     0x89a0		/* create new bridge device     */
+#define SIOCBRDELBR     0x89a1		/* remove bridge device         */
+#define SIOCBRADDIF	0x89a2		/* add interface to bridge      */
+#define SIOCBRDELIF	0x89a3		/* remove interface from bridge */
+
 /* Device private ioctl calls */
 
 /*
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	2004-05-20 14:46:10 -07:00
+++ b/net/bridge/br_ioctl.c	2004-05-20 14:46:10 -07:00
@@ -78,13 +78,36 @@
 	return num;
 }
 
-int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
+{
+	struct net_device *dev;
+	int ret;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	dev = dev_get_by_index(ifindex);
+	if (dev == NULL)
+		return -EINVAL;
+	
+	if (isadd)
+		ret = br_add_if(br, dev);
+	else
+		ret = br_del_if(br, dev);
+
+	dev_put(dev);
+	return ret;
+}
+
+/*
+ * Legacy ioctl's through SIOCDEVPRIVATE
+ * This interface is deprecated because it was too difficult to
+ * to do the translation for 32/64bit ioctl compatability.
+ */
+static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	unsigned long args[4];
-
-	if (cmd != SIOCDEVPRIVATE)
-		return -EOPNOTSUPP;
 	
 	if (copy_from_user(args, rq->ifr_data, sizeof(args)))
 		return -EFAULT;
@@ -92,25 +115,7 @@
 	switch (args[0]) {
 	case BRCTL_ADD_IF:
 	case BRCTL_DEL_IF:
-	{
-		struct net_device *dev;
-		int ret;
-
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
-		dev = dev_get_by_index(args[1]);
-		if (dev == NULL)
-			return -EINVAL;
-
-		if (args[0] == BRCTL_ADD_IF)
-			ret = br_add_if(br, dev);
-		else
-			ret = br_del_if(br, dev);
-
-		dev_put(dev);
-		return ret;
-	}
+		return add_del_if(br, args[1], args[0] == BRCTL_ADD_IF);
 
 	case BRCTL_GET_BRIDGE_INFO:
 	{
@@ -303,8 +308,7 @@
 	return -EOPNOTSUPP;
 }
 
-
-int br_ioctl_deviceless_stub(unsigned long uarg)
+static int old_deviceless(unsigned long uarg)
 {
 	unsigned long args[3];
 
@@ -354,5 +358,51 @@
 	}
 	}
 
+	return -EOPNOTSUPP;
+}
+
+int br_ioctl_deviceless_stub(unsigned int cmd, unsigned long uarg)
+{
+	switch (cmd) {
+	case SIOCGIFBR:
+	case SIOCSIFBR:
+		return old_deviceless(uarg);
+		
+	case SIOCBRADDBR:
+	case SIOCBRDELBR:
+	{
+		char buf[IFNAMSIZ];
+
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (copy_from_user(buf, (void __user *) uarg, IFNAMSIZ))
+			return -EFAULT;
+
+		buf[IFNAMSIZ-1] = 0;
+		if (cmd == SIOCBRADDBR)
+			return br_add_bridge(buf);
+
+		return br_del_bridge(buf);
+	}
+	}
+	return -EOPNOTSUPP;
+}
+
+int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	switch(cmd) {
+	case SIOCDEVPRIVATE:
+		return old_dev_ioctl(dev, rq, cmd);
+
+	case SIOCBRADDIF:
+	case SIOCBRDELIF:
+		return add_del_if(br, rq->ifr_ifindex, cmd == SIOCBRADDIF);
+
+	}
+
+	printk(KERN_DEBUG "Bridge does not support ioctl 0x%x\n", cmd);
 	return -EOPNOTSUPP;
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-05-20 14:46:10 -07:00
+++ b/net/bridge/br_private.h	2004-05-20 14:46:10 -07:00
@@ -173,8 +173,8 @@
 extern int br_handle_frame(struct sk_buff *skb);
 
 /* br_ioctl.c */
-extern int br_ioctl_deviceless_stub(unsigned long arg);
 extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+extern int br_ioctl_deviceless_stub(unsigned int cmd, unsigned long arg);
 
 /* br_netfilter.c */
 extern int br_netfilter_init(void);
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-05-20 14:46:10 -07:00
+++ b/net/core/dev.c	2004-05-20 14:46:10 -07:00
@@ -2519,6 +2519,8 @@
 			    cmd == SIOCGMIIPHY ||
 			    cmd == SIOCGMIIREG ||
 			    cmd == SIOCSMIIREG ||
+			    cmd == SIOCBRADDIF ||
+			    cmd == SIOCBRDELIF ||
 			    cmd == SIOCWANDEV) {
 				err = -EOPNOTSUPP;
 				if (dev->do_ioctl) {
@@ -2673,6 +2675,8 @@
 		case SIOCBONDSLAVEINFOQUERY:
 		case SIOCBONDINFOQUERY:
 		case SIOCBONDCHANGEACTIVE:
+		case SIOCBRADDIF:
+		case SIOCBRDELIF:
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 			dev_load(ifr.ifr_name);
diff -Nru a/net/socket.c b/net/socket.c
--- a/net/socket.c	2004-05-20 14:46:10 -07:00
+++ b/net/socket.c	2004-05-20 14:46:10 -07:00
@@ -727,9 +727,9 @@
  */
 
 static DECLARE_MUTEX(br_ioctl_mutex);
-static int (*br_ioctl_hook)(unsigned long arg) = NULL;
+static int (*br_ioctl_hook)(unsigned int cmd, unsigned long arg) = NULL;
 
-void brioctl_set(int (*hook)(unsigned long))
+void brioctl_set(int (*hook)(unsigned int, unsigned long))
 {
 	down(&br_ioctl_mutex);
 	br_ioctl_hook = hook;
@@ -794,13 +794,15 @@
 			break;
 		case SIOCGIFBR:
 		case SIOCSIFBR:
+		case SIOCBRADDBR:
+		case SIOCBRDELBR:
 			err = -ENOPKG;
 			if (!br_ioctl_hook)
 				request_module("bridge");
 
 			down(&br_ioctl_mutex);
 			if (br_ioctl_hook) 
-				err = br_ioctl_hook(arg);
+				err = br_ioctl_hook(cmd, arg);
 			up(&br_ioctl_mutex);
 			break;
 		case SIOCGIFVLAN:
