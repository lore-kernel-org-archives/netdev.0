From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] bridge -- support different MTU sizes
Date: Thu, 8 Jul 2004 10:41:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708104143.67210e39@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds support for different size MTU's to bridging.
It is useful for bridging Ethernet's with jumbo frames, etc.

The mtu of the bridge pseudo-device is maintained as the minimum
of all the underlying ports.  And when forwarding a frame through
the bridge, it will drop the frame if the outgoing port's MTU
is less than the frame size (as per 802 standard).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	2004-06-30 11:48:01 -07:00
+++ b/net/bridge/br_device.c	2004-06-30 11:48:01 -07:00
@@ -89,6 +89,15 @@
 	return 0;
 }
 
+static int br_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if ((new_mtu < 68) || new_mtu > br_min_mtu(dev->priv))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static int br_dev_accept_fastpath(struct net_device *dev, struct dst_entry *dst)
 {
 	return -1;
@@ -105,6 +114,7 @@
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
 	dev->set_multicast_list = br_dev_set_multicast_list;
+	dev->change_mtu = br_change_mtu;
 	dev->destructor = free_netdev;
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
diff -Nru a/net/bridge/br_forward.c b/net/bridge/br_forward.c
--- a/net/bridge/br_forward.c	2004-06-30 11:48:01 -07:00
+++ b/net/bridge/br_forward.c	2004-06-30 11:48:01 -07:00
@@ -22,7 +22,8 @@
 static inline int should_deliver(const struct net_bridge_port *p, 
 				 const struct sk_buff *skb)
 {
-	if (skb->dev == p->dev ||
+	if (skb->dev == p->dev ||
+	    skb->len > p->dev->mtu ||
 	    p->state != BR_STATE_FORWARDING)
 		return 0;
 
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-06-30 11:48:01 -07:00
+++ b/net/bridge/br_if.c	2004-06-30 11:48:01 -07:00
@@ -295,6 +295,24 @@
 	return ret;
 }
 
+int br_min_mtu(const struct net_bridge *br)
+{
+	const struct net_bridge_port *p;
+	int mtu = 0;
+
+	ASSERT_RTNL();
+
+	if (list_empty(&br->port_list))
+		mtu = 1500;
+	else {
+		list_for_each_entry(p, &br->port_list, list) {
+			if (!mtu  || p->dev->mtu < mtu)
+				mtu = p->dev->mtu;
+		}
+	}
+	return mtu;
+}
+
 /* called with RTNL */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
@@ -328,6 +346,8 @@
 		if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
 			br_stp_enable_port(p);
 		spin_unlock_bh(&br->lock);
+
+		br->dev->mtu = br_min_mtu(br);
 	}
 
 	return err;
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	2004-06-30 11:48:01 -07:00
+++ b/net/bridge/br_notify.c	2004-06-30 11:48:01 -07:00
@@ -47,6 +47,10 @@
 		spin_unlock_bh(&br->lock);
 		break;
 
+	case NETDEV_CHANGEMTU:
+		br->dev->mtu = br_min_mtu(br);
+		break;
+
 	case NETDEV_DOWN:
 		if (br->dev->flags & IFF_UP) {
 			spin_lock_bh(&br->lock);
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-06-30 11:48:01 -07:00
+++ b/net/bridge/br_private.h	2004-06-30 11:48:01 -07:00
@@ -168,6 +168,7 @@
 	      struct net_device *dev);
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
+extern int br_min_mtu(const struct net_bridge *br);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
