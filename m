From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge (2.6.5) - allow non-root get ioctl's
Date: Thu, 1 Apr 2004 13:36:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401133617.3f30f39d@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch allows non-root users to inspect the status of a bridge.
It moves the permission check for the ioctl from the top level
down to where the set type commands are.

diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	Thu Apr  1 12:50:06 2004
+++ b/net/bridge/br_device.c	Thu Apr  1 12:50:06 2004
@@ -32,7 +32,7 @@
 	if (copy_from_user(args, data, 4*sizeof(unsigned long)))
 		return -EFAULT;
 
-	return br_ioctl(dev->priv, args[0], args[1], args[2], args[3]);
+	return br_ioctl_device(dev->priv, args[0], args[1], args[2], args[3]);
 }
 
 static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Thu Apr  1 12:50:06 2004
+++ b/net/bridge/br_ioctl.c	Thu Apr  1 12:50:06 2004
@@ -38,11 +38,8 @@
 			     ? (timer->expires - jiffies) : 0);
 }
 
-static int br_ioctl_device(struct net_bridge *br,
-			   unsigned int cmd,
-			   unsigned long arg0,
-			   unsigned long arg1,
-			   unsigned long arg2)
+int br_ioctl_device(struct net_bridge *br, unsigned int cmd,
+		   unsigned long arg0, unsigned long arg1, unsigned long arg2)
 {
 	if (br == NULL)
 		return -EINVAL;
@@ -55,6 +52,9 @@
 		struct net_device *dev;
 		int ret;
 
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		dev = dev_get_by_index(arg0);
 		if (dev == NULL)
 			return -EINVAL;
@@ -121,6 +121,9 @@
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		br->bridge_forward_delay = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
@@ -129,6 +132,9 @@
 		return 0;
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		br->bridge_hello_time = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
@@ -137,6 +143,9 @@
 		return 0;
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		br->bridge_max_age = user_to_ticks(arg0);
 		if (br_is_root_bridge(br))
@@ -145,10 +154,10 @@
 		return 0;
 
 	case BRCTL_SET_AGEING_TIME:
-		br->ageing_time = user_to_ticks(arg0);
-		return 0;
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 
-	case BRCTL_SET_GC_INTERVAL:	 /* no longer used */
+		br->ageing_time = user_to_ticks(arg0);
 		return 0;
 
 	case BRCTL_GET_PORT_INFO:
@@ -185,10 +194,16 @@
 	}
 
 	case BRCTL_SET_BRIDGE_STP_STATE:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		br->stp_enabled = arg0?1:0;
 		return 0;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		br_stp_set_bridge_priority(br, arg0);
 		spin_unlock_bh(&br->lock);
@@ -199,6 +214,9 @@
 		struct net_bridge_port *p;
 		int ret = 0;
 
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, arg0)) == NULL) 
 			ret = -EINVAL;
@@ -213,6 +231,9 @@
 		struct net_bridge_port *p;
 		int ret = 0;
 
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, arg0)) == NULL)
 			ret = -EINVAL;
@@ -265,6 +286,9 @@
 	{
 		char buf[IFNAMSIZ];
 
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		if (copy_from_user(buf, (void *)arg0, IFNAMSIZ))
 			return -EFAULT;
 
@@ -285,25 +309,8 @@
 {
 	unsigned long i[3];
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (copy_from_user(i, (void *)arg, 3*sizeof(unsigned long)))
 		return -EFAULT;
 
 	return br_ioctl_deviceless(i[0], i[1], i[2]);
-}
-
-int br_ioctl(struct net_bridge *br, unsigned int cmd, unsigned long arg0, unsigned long arg1, unsigned long arg2)
-{
-	int err;
-
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	err = br_ioctl_deviceless(cmd, arg0, arg1);
-	if (err == -EOPNOTSUPP)
-		err = br_ioctl_device(br, cmd, arg0, arg1, arg2);
-
-	return err;
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Thu Apr  1 12:50:06 2004
+++ b/net/bridge/br_private.h	Thu Apr  1 12:50:06 2004
@@ -174,11 +174,11 @@
 extern int br_handle_frame(struct sk_buff *skb);
 
 /* br_ioctl.c */
-extern int br_ioctl(struct net_bridge *br,
-	     unsigned int cmd,
-	     unsigned long arg0,
-	     unsigned long arg1,
-	     unsigned long arg2);
+extern int br_ioctl_device(struct net_bridge *br,
+			   unsigned int cmd,
+			   unsigned long arg0,
+			   unsigned long arg1,
+			   unsigned long arg2);
 extern int br_ioctl_deviceless_stub(unsigned long arg);
 
 /* br_netfilter.c */


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
