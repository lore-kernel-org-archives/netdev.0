From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] dynamic net_device for serial eql balancer
Date: Tue, 15 Jul 2003 15:57:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030715155733.0ee5a14d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch against 2.6.0-test1 to dynamically allocate pseudo network device.
Compiles and loaded/unloaded but don't have multi-port serial load balancing to test 
more fuly.

diff -Nru a/drivers/net/eql.c b/drivers/net/eql.c
--- a/drivers/net/eql.c	Tue Jul 15 15:50:48 2003
+++ b/drivers/net/eql.c	Tue Jul 15 15:50:48 2003
@@ -162,22 +162,12 @@
 static char version[] __initdata = 
 	"Equalizer2002: Simon Janes (simon@ncm.com) and David S. Miller (davem@redhat.com)\n";
 
-static int __init eql_init(struct net_device *dev)
+static void __init eql_setup(struct net_device *dev)
 {
-	static unsigned int version_printed;
-	equalizer_t *eql;
+	equalizer_t *eql = dev->priv;
 
 	SET_MODULE_OWNER(dev);
 
-	if (version_printed++ == 0)
-		printk(version);
-
-	dev->priv = kmalloc(sizeof (equalizer_t), GFP_KERNEL);
-	if (dev->priv == NULL)
-		return -ENOMEM;
-	memset(dev->priv, 0, sizeof (equalizer_t));
-	eql = dev->priv;
-
 	init_timer(&eql->timer);
 	eql->timer.data     	= (unsigned long) dev->priv;
 	eql->timer.expires  	= jiffies + EQL_DEFAULT_RESCHED_IVAL;
@@ -203,8 +193,6 @@
 
 	dev->type       	= ARPHRD_SLIP;
 	dev->tx_queue_len 	= 5;		/* Hands them off fast */
-
-	return 0;
 }
 
 static int eql_open(struct net_device *dev)
@@ -598,23 +586,28 @@
 	return -EINVAL;
 }
 
-static struct net_device dev_eql;
+static struct net_device *dev_eql;
 
 static int __init eql_init_module(void)
 {
-	strcpy(dev_eql.name, "eql");
-	dev_eql.init = eql_init;
-	if (register_netdev(&dev_eql) != 0) {
-		printk("eql: register_netdev() returned non-zero.\n");
-		return -EIO;
-	}
-	return 0;
+	int err;
+
+	printk(version);
+
+	dev_eql = alloc_netdev(sizeof(equalizer_t), "eql", eql_setup);
+	if (!dev_eql)
+		return -ENOMEM;
+
+	err = register_netdev(dev_eql);
+	if (err) 
+		kfree(dev_eql);
+	return err;
 }
 
 static void __exit eql_cleanup_module(void)
 {
-	kfree(dev_eql.priv);
-	unregister_netdev(&dev_eql);
+	unregister_netdev(dev_eql);
+	kfree(dev_eql);
 }
 
 module_init(eql_init_module);
