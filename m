From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) set random address in dummy
Date: Fri, 9 Apr 2004 11:45:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040409114553.7f5b5d25@dell_ss3.pdx.osdl.net>
References: <20040408110834.2fd1bd25@dell_ss3.pdx.osdl.net>
	<20040408145403.34382c96.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-usb-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040408145403.34382c96.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix several things in dummy device to make it more useable.
 * add MODULE_PARAM_DESC for num_dummies
 * set initial random ether address
 * allow changing address

diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	Fri Apr  9 11:33:59 2004
+++ b/drivers/net/dummy.c	Fri Apr  9 11:33:59 2004
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
 
@@ -40,6 +41,17 @@
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev);
 static struct net_device_stats *dummy_get_stats(struct net_device *dev);
 
+static int dummy_set_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *sa = p;
+
+	if (!is_valid_ether_addr(sa->sa_data)) 
+		return -EADDRNOTAVAIL;
+		
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+	return 0;
+}
+
 /* fake multicast ability */
 static void set_multicast_list(struct net_device *dev)
 {
@@ -58,6 +70,7 @@
 	dev->get_stats = dummy_get_stats;
 	dev->hard_start_xmit = dummy_xmit;
 	dev->set_multicast_list = set_multicast_list;
+	dev->set_mac_address = dummy_set_address;
 #ifdef CONFIG_NET_FASTROUTE
 	dev->accept_fastpath = dummy_accept_fastpath;
 #endif
@@ -68,6 +81,7 @@
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
 	SET_MODULE_OWNER(dev);
+	random_ether_addr(dev->dev_addr);
 }
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -90,6 +104,7 @@
 
 /* Number of dummy devices to be set up by this module. */
 module_param(numdummies, int, 0);
+MODULE_PARM_DESC(numdimmies, "Number of dummy psuedo devices");
 
 static int __init dummy_init_one(int index)
 {
