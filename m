From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.5] (4/9) bridge - use ethtool to get port speed
Date: Tue, 13 Apr 2004 15:24:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040413152440.7e410cd8@dell_ss3.pdx.osdl.net>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The bridge code needs to keep track of a cost estimate for each
port in the bridge.  Instead of a hack based on device name, try
and use ethtool to get port speed from device.  This has been tested
on e100 (uses ethtool_ops) and e1000 (does ethtool the hard way)
and dummy (no ethtool).

Need to export dev_ethtool() to allow bridge module to get to
it easily.

Code takes care to maintain same locking and semantics as if ioctl
was being done from application.

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	Mon Apr 12 16:10:23 2004
+++ b/net/bridge/br_if.c	Mon Apr 12 16:10:23 2004
@@ -14,6 +14,8 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
 #include <linux/if_arp.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -25,18 +27,55 @@
 /* Limited to 256 ports because of STP protocol pdu */
 #define  BR_MAX_PORTS	256
 
+/*
+ * Determine initial path cost based on speed.
+ * using recommendations from 802.1d standard
+ *
+ * Need to simulate user ioctl because not all device's that support
+ * ethtool, use ethtool_ops.  Also, since driver might sleep need to
+ * not be holding any locks.
+ */
 static int br_initial_port_cost(struct net_device *dev)
 {
+
+	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
+	struct ifreq ifr;
+	mm_segment_t old_fs;
+	int err;
+
+	strncpy(ifr.ifr_name, dev->name, IFNAMSIZ);
+	ifr.ifr_data = (void *) &ecmd;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+	err = dev_ethtool(&ifr);
+	set_fs(old_fs);
+	
+	if (!err) {
+		switch(ecmd.speed) {
+		case SPEED_100:
+			return 19;
+		case SPEED_1000:
+			return 4;
+		case SPEED_10000:
+			return 2;
+		case SPEED_10:
+			return 100;
+		default:
+			pr_info("bridge: can't decode speed from %s: %d\n",
+				dev->name, ecmd.speed);
+			return 100;
+		}
+	}
+
+	/* Old silly heuristics based on name */
 	if (!strncmp(dev->name, "lec", 3))
 		return 7;
 
-	if (!strncmp(dev->name, "eth", 3))
-		return 100;			/* FIXME handle 100Mbps */
-
 	if (!strncmp(dev->name, "plip", 4))
 		return 2500;
 
-	return 100;
+	return 100;	/* assume old 10Mbps */
 }
 
 static void destroy_nbp(void *arg)
@@ -147,7 +186,9 @@
 }
 
 /* called under bridge lock */
-static struct net_bridge_port *new_nbp(struct net_bridge *br, struct net_device *dev)
+static struct net_bridge_port *new_nbp(struct net_bridge *br, 
+				       struct net_device *dev,
+				       unsigned long cost)
 {
 	int index;
 	struct net_bridge_port *p;
@@ -162,16 +203,15 @@
 
 	memset(p, 0, sizeof(*p));
 	p->br = br;
+	dev_hold(dev);
 	p->dev = dev;
-	p->path_cost = br_initial_port_cost(dev);
+	p->path_cost = cost;
 	p->priority = 0x80;
 	dev->br_port = p;
 	p->port_no = index;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 
-	list_add_rcu(&p->list, &br->port_list);
-
 	return p;
 }
 
@@ -216,13 +256,11 @@
 	return ret;
 }
 
-/* called under bridge lock */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
-
-	if (dev->br_port != NULL)
-		return -EBUSY;
+	unsigned long cost;
+	int err = 0;
 
 	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
 		return -EINVAL;
@@ -230,34 +268,46 @@
 	if (dev->hard_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
-	dev_hold(dev);
-	p = new_nbp(br, dev);
-	if (IS_ERR(p)) {
-		dev_put(dev);
-		return PTR_ERR(p);
-	}
+	cost = br_initial_port_cost(dev);
 
-	dev_set_promiscuity(dev, 1);
+	spin_lock_bh(&br->lock);
+	if (dev->br_port != NULL)
+		err = -EBUSY;
+
+	else if (IS_ERR(p = new_nbp(br, dev, cost)))
+		err = PTR_ERR(p);
 
-	br_stp_recalculate_bridge_id(br);
-	br_fdb_insert(br, p, dev->dev_addr, 1);
-	if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
-		br_stp_enable_port(p);
+	else {
+		dev_set_promiscuity(dev, 1);
 
-	return 0;
+		list_add_rcu(&p->list, &br->port_list);
+
+		br_stp_recalculate_bridge_id(br);
+		br_fdb_insert(br, p, dev->dev_addr, 1);
+		if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
+			br_stp_enable_port(p);
+
+	}
+	spin_unlock_bh(&br->lock);
+	return err;
 }
 
-/* called under bridge lock */
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
+	int err = 0;
 
-	if ((p = dev->br_port) == NULL || p->br != br)
-		return -EINVAL;
+	spin_lock_bh(&br->lock);
+	p = dev->br_port;
+	if (!p || p->br != br) 
+		err = -EINVAL;
+	else {
+		del_nbp(p);
+		br_stp_recalculate_bridge_id(br);
+	}
+	spin_unlock_bh(&br->lock);
 
-	del_nbp(p);
-	br_stp_recalculate_bridge_id(br);
-	return 0;
+	return err;
 }
 
 int br_get_bridge_ifindices(int *indices, int num)
diff -Nru a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
--- a/net/bridge/br_ioctl.c	Mon Apr 12 16:10:23 2004
+++ b/net/bridge/br_ioctl.c	Mon Apr 12 16:10:23 2004
@@ -48,12 +48,10 @@
 		if (dev == NULL)
 			return -EINVAL;
 
-		spin_lock_bh(&br->lock);
 		if (cmd == BRCTL_ADD_IF)
 			ret = br_add_if(br, dev);
 		else
 			ret = br_del_if(br, dev);
-		spin_unlock_bh(&br->lock);
 
 		dev_put(dev);
 		return ret;
diff -Nru a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c	Mon Apr 12 16:10:23 2004
+++ b/net/core/ethtool.c	Mon Apr 12 16:10:23 2004
@@ -740,6 +740,7 @@
 	return -EOPNOTSUPP;
 }
 
+EXPORT_SYMBOL(dev_ethtool);
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_sg);
 EXPORT_SYMBOL(ethtool_op_get_tso);
