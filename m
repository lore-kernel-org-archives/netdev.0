From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge (2.6.5) - lift ioctl limits on number of
 bridges/ports.
Date: Thu, 1 Apr 2004 13:41:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401134151.79ffe512@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of some arbitrary API restrictions that limit the kernel
to 64 bridges and 256 ports.  

Retain compatibility in GET_PORT_LIST, the existing bridge API
passes 0 for the third argument, and expects 256 entries.

Note: there still is limit of 256 ports due to STP, but this
shouldn't show up in the API, it needs to be handled by the
"add port to bridge ioctl".

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Thu Apr  1 12:50:36 2004
+++ b/net/bridge/br_if.c	Thu Apr  1 12:50:36 2004
@@ -262,13 +262,14 @@
 	return i;
 }
 
-void br_get_port_ifindices(struct net_bridge *br, int *ifindices)
+void br_get_port_ifindices(struct net_bridge *br, int *ifindices, int num)
 {
 	struct net_bridge_port *p;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(p, &br->port_list, list) {
-		ifindices[p->port_no] = p->dev->ifindex;
+		if (p->port_no < num)
+			ifindices[p->port_no] = p->dev->ifindex;
 	}
 	rcu_read_unlock();
 }
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Thu Apr  1 12:50:36 2004
+++ b/net/bridge/br_ioctl.c	Thu Apr  1 12:50:36 2004
@@ -104,17 +104,18 @@
 
 	case BRCTL_GET_PORT_LIST:
 	{
-		int *indices;
+		int num = arg1 ? arg1 : 256;	/* compatiablity */
 		int ret = 0;
+		int *indices;
 
-		indices = kmalloc(256*sizeof(int), GFP_KERNEL);
+		indices = kmalloc(num*sizeof(int), GFP_KERNEL);
 		if (indices == NULL)
 			return -ENOMEM;
 
-		memset(indices, 0, 256*sizeof(int));
+		memset(indices, 0, num*sizeof(int));
 
-		br_get_port_ifindices(br, indices);
-		if (copy_to_user((void *)arg0, indices, 256*sizeof(int)))
+		br_get_port_ifindices(br, indices, num);
+		if (copy_to_user((void *)arg0, indices, num*sizeof(int)))
 			ret =  -EFAULT;
 		kfree(indices);
 		return ret;
@@ -263,9 +264,6 @@
 	{
 		int *indices;
 		int ret = 0;
-
-		if (arg1 > 64)
-			arg1 = 64;
 
 		indices = kmalloc(arg1*sizeof(int), GFP_KERNEL);
 		if (indices == NULL)
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	Thu Apr  1 12:50:36 2004
+++ b/net/bridge/br_private.h	Thu Apr  1 12:50:36 2004
@@ -167,7 +167,7 @@
 extern int br_get_bridge_ifindices(int *indices,
 			    int num);
 extern void br_get_port_ifindices(struct net_bridge *br,
-			   int *ifindices);
+			   int *ifindices, int num);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
