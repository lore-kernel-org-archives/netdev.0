From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/11) bridge - ioctl cleanup and consolidation
Date: Fri, 21 May 2004 15:54:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521155425.57aa71c1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Merge the ioctl stub calls that just end up calling the sub-function
to do the actual ioctl.  Move br_get_XXX_ifindices into the ioctl file
as well where they can be static.

diff -Nru a/net/bridge/br_device.c b/net/bridge/br_device.c
--- a/net/bridge/br_device.c	2004-05-20 10:51:05 -07:00
+++ b/net/bridge/br_device.c	2004-05-20 10:51:05 -07:00
@@ -19,21 +19,6 @@
 #include <asm/uaccess.h>
 #include "br_private.h"
 
-static int br_dev_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-{
-	unsigned long args[4];
-	unsigned long *data;
-
-	if (cmd != SIOCDEVPRIVATE)
-		return -EOPNOTSUPP;
-
-	data = (unsigned long *)rq->ifr_data;
-	if (copy_from_user(args, data, 4*sizeof(unsigned long)))
-		return -EFAULT;
-
-	return br_ioctl_device(dev->priv, args[0], args[1], args[2], args[3]);
-}
-
 static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
 {
 	struct net_bridge *br;
@@ -115,7 +100,7 @@
 
 	ether_setup(dev);
 
-	dev->do_ioctl = br_dev_do_ioctl;
+	dev->do_ioctl = br_dev_ioctl;
 	dev->get_stats = br_dev_get_stats;
 	dev->hard_start_xmit = br_dev_xmit;
 	dev->open = br_dev_open;
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-05-20 10:51:05 -07:00
+++ b/net/bridge/br_if.c	2004-05-20 10:51:05 -07:00
@@ -309,34 +309,6 @@
 	return 0;
 }
 
-int br_get_bridge_ifindices(int *indices, int num)
-{
-	struct net_device *dev;
-	int i = 0;
-
-	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev && i < num; dev = dev->next) {
-		if (dev->priv_flags & IFF_EBRIDGE) 
-			indices[i++] = dev->ifindex;
-	}
-	read_unlock(&dev_base_lock);
-
-	return i;
-}
-
-void br_get_port_ifindices(struct net_bridge *br, int *ifindices, int num)
-{
-	struct net_bridge_port *p;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(p, &br->port_list, list) {
-		if (p->port_no < num)
-			ifindices[p->port_no] = p->dev->ifindex;
-	}
-	rcu_read_unlock();
-}
-
-
 void __exit br_cleanup_bridges(void)
 {
 	struct net_device *dev, *nxt;
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	2004-05-20 10:51:05 -07:00
+++ b/net/bridge/br_ioctl.c	2004-05-20 10:51:05 -07:00
@@ -27,14 +27,43 @@
 		? jiffies_to_clock_t(timer->expires - jiffies) : 0;
 }
 
-int br_ioctl_device(struct net_bridge *br, unsigned int cmd,
-		   unsigned long arg0, unsigned long arg1, unsigned long arg2)
+/* called with RTNL */
+static int get_bridge_ifindices(int *indices, int num)
 {
-	if (br == NULL)
-		return -EINVAL;
+	struct net_device *dev;
+	int i = 0;
 
-	switch (cmd)
-	{
+	for (dev = dev_base; dev && i < num; dev = dev->next) {
+		if (dev->priv_flags & IFF_EBRIDGE) 
+			indices[i++] = dev->ifindex;
+	}
+
+	return i;
+}
+
+/* called with RTNL */
+static void get_port_ifindices(struct net_bridge *br, int *ifindices, int num)
+{
+	struct net_bridge_port *p;
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (p->port_no < num)
+			ifindices[p->port_no] = p->dev->ifindex;
+	}
+}
+
+int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	unsigned long args[4];
+
+	if (cmd != SIOCDEVPRIVATE)
+		return -EOPNOTSUPP;
+	
+	if (copy_from_user(args, rq->ifr_data, sizeof(args)))
+		return -EFAULT;
+
+	switch (args[0]) {
 	case BRCTL_ADD_IF:
 	case BRCTL_DEL_IF:
 	{
@@ -44,11 +73,11 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		dev = dev_get_by_index(arg0);
+		dev = dev_get_by_index(args[1]);
 		if (dev == NULL)
 			return -EINVAL;
 
-		if (cmd == BRCTL_ADD_IF)
+		if (args[0] == BRCTL_ADD_IF)
 			ret = br_add_if(br, dev);
 		else
 			ret = br_del_if(br, dev);
@@ -83,7 +112,7 @@
 		b.gc_timer_value = timer_residue(&br->gc_timer);
 	        rcu_read_unlock();
 
-		if (copy_to_user((void *)arg0, &b, sizeof(b)))
+		if (copy_to_user((void *)args[1], &b, sizeof(b)))
 			return -EFAULT;
 
 		return 0;
@@ -93,7 +122,7 @@
 	{
 		int num, *indices;
 
-		num = arg1;
+		num = args[2];
 		if (num < 0)
 			return -EINVAL;
 		if (num == 0)
@@ -107,8 +136,8 @@
 
 		memset(indices, 0, num*sizeof(int));
 
-		br_get_port_ifindices(br, indices, num);
-		if (copy_to_user((void *)arg0, indices, num*sizeof(int)))
+		get_port_ifindices(br, indices, num);
+		if (copy_to_user((void *)args[1], indices, num*sizeof(int)))
 			num =  -EFAULT;
 		kfree(indices);
 		return num;
@@ -119,7 +148,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_forward_delay = clock_t_to_jiffies(arg0);
+		br->bridge_forward_delay = clock_t_to_jiffies(args[1]);
 		if (br_is_root_bridge(br))
 			br->forward_delay = br->bridge_forward_delay;
 		spin_unlock_bh(&br->lock);
@@ -130,7 +159,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_hello_time = clock_t_to_jiffies(arg0);
+		br->bridge_hello_time = clock_t_to_jiffies(args[1]);
 		if (br_is_root_bridge(br))
 			br->hello_time = br->bridge_hello_time;
 		spin_unlock_bh(&br->lock);
@@ -141,7 +170,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br->bridge_max_age = clock_t_to_jiffies(arg0);
+		br->bridge_max_age = clock_t_to_jiffies(args[1]);
 		if (br_is_root_bridge(br))
 			br->max_age = br->bridge_max_age;
 		spin_unlock_bh(&br->lock);
@@ -151,7 +180,7 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		br->ageing_time = clock_t_to_jiffies(arg0);
+		br->ageing_time = clock_t_to_jiffies(args[1]);
 		return 0;
 
 	case BRCTL_GET_PORT_INFO:
@@ -160,7 +189,7 @@
 		struct net_bridge_port *pt;
 
 		rcu_read_lock();
-		if ((pt = br_get_port(br, arg1)) == NULL) {
+		if ((pt = br_get_port(br, args[2])) == NULL) {
 			rcu_read_unlock();
 			return -EINVAL;
 		}
@@ -181,7 +210,7 @@
 
 		rcu_read_unlock();
 
-		if (copy_to_user((void *)arg0, &p, sizeof(p)))
+		if (copy_to_user((void *)args[1], &p, sizeof(p)))
 			return -EFAULT;
 
 		return 0;
@@ -191,7 +220,7 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		br->stp_enabled = arg0?1:0;
+		br->stp_enabled = args[1]?1:0;
 		return 0;
 
 	case BRCTL_SET_BRIDGE_PRIORITY:
@@ -199,7 +228,7 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		br_stp_set_bridge_priority(br, arg0);
+		br_stp_set_bridge_priority(br, args[1]);
 		spin_unlock_bh(&br->lock);
 		return 0;
 
@@ -211,14 +240,14 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if (arg1 >= (1<<(16-BR_PORT_BITS)))
+		if (args[2] >= (1<<(16-BR_PORT_BITS)))
 			return -ERANGE;
 
 		spin_lock_bh(&br->lock);
-		if ((p = br_get_port(br, arg0)) == NULL) 
+		if ((p = br_get_port(br, args[1])) == NULL) 
 			ret = -EINVAL;
 		else
-			br_stp_set_port_priority(p, arg1);
+			br_stp_set_port_priority(p, args[2]);
 		spin_unlock_bh(&br->lock);
 		return ret;
 	}
@@ -232,27 +261,30 @@
 			return -EPERM;
 
 		spin_lock_bh(&br->lock);
-		if ((p = br_get_port(br, arg0)) == NULL)
+		if ((p = br_get_port(br, args[1])) == NULL)
 			ret = -EINVAL;
 		else
-			br_stp_set_path_cost(p, arg1);
+			br_stp_set_path_cost(p, args[2]);
 		spin_unlock_bh(&br->lock);
 		return ret;
 	}
 
 	case BRCTL_GET_FDB_ENTRIES:
-		return br_fdb_get_entries(br, (void *)arg0, arg1, arg2);
+		return br_fdb_get_entries(br, (void *)args[1], args[2], args[3]);
 	}
 
 	return -EOPNOTSUPP;
 }
 
-static int br_ioctl_deviceless(unsigned int cmd,
-			       unsigned long arg0,
-			       unsigned long arg1)
+
+int br_ioctl_deviceless_stub(unsigned long uarg)
 {
-	switch (cmd)
-	{
+	unsigned long args[3];
+
+	if (copy_from_user(args, (void *)uarg, sizeof(args)))
+		return -EFAULT;
+
+	switch (args[0]) {
 	case BRCTL_GET_VERSION:
 		return BRCTL_VERSION;
 
@@ -261,15 +293,15 @@
 		int *indices;
 		int ret = 0;
 
-		indices = kmalloc(arg1*sizeof(int), GFP_KERNEL);
+		indices = kmalloc(args[2]*sizeof(int), GFP_KERNEL);
 		if (indices == NULL)
 			return -ENOMEM;
 
-		memset(indices, 0, arg1*sizeof(int));
-		arg1 = br_get_bridge_ifindices(indices, arg1);
+		memset(indices, 0, args[2]*sizeof(int));
+		args[2] = get_bridge_ifindices(indices, args[2]);
 
-		ret = copy_to_user((void *)arg0, indices, arg1*sizeof(int))
-			? -EFAULT : arg1;
+		ret = copy_to_user((void *)args[1], indices, args[2]*sizeof(int))
+			? -EFAULT : args[2];
 
 		kfree(indices);
 		return ret;
@@ -283,12 +315,12 @@
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if (copy_from_user(buf, (void *)arg0, IFNAMSIZ))
+		if (copy_from_user(buf, (void *)args[1], IFNAMSIZ))
 			return -EFAULT;
 
 		buf[IFNAMSIZ-1] = 0;
 
-		if (cmd == BRCTL_ADD_BRIDGE)
+		if (args[0] == BRCTL_ADD_BRIDGE)
 			return br_add_bridge(buf);
 
 		return br_del_bridge(buf);
@@ -296,15 +328,4 @@
 	}
 
 	return -EOPNOTSUPP;
-}
-
-
-int br_ioctl_deviceless_stub(unsigned long arg)
-{
-	unsigned long i[3];
-
-	if (copy_from_user(i, (void *)arg, 3*sizeof(unsigned long)))
-		return -EFAULT;
-
-	return br_ioctl_deviceless(i[0], i[1], i[2]);
 }
diff -Nru a/net/bridge/br_private.h b/net/bridge/br_private.h
--- a/net/bridge/br_private.h	2004-05-20 10:51:05 -07:00
+++ b/net/bridge/br_private.h	2004-05-20 10:51:05 -07:00
@@ -168,22 +168,14 @@
 	      struct net_device *dev);
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
-extern int br_get_bridge_ifindices(int *indices,
-			    int num);
-extern void br_get_port_ifindices(struct net_bridge *br,
-			   int *ifindices, int num);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
 extern int br_handle_frame(struct sk_buff *skb);
 
 /* br_ioctl.c */
-extern int br_ioctl_device(struct net_bridge *br,
-			   unsigned int cmd,
-			   unsigned long arg0,
-			   unsigned long arg1,
-			   unsigned long arg2);
 extern int br_ioctl_deviceless_stub(unsigned long arg);
+extern int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 
 /* br_netfilter.c */
 extern int br_netfilter_init(void);
