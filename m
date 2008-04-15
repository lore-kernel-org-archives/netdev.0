From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/3][TUN]: Introduce the tun_net structure and
 init/exit net ops.
Date: Tue, 15 Apr 2008 15:51:37 +0400
Message-ID: <480496C9.7090209@openvz.org>
References: <48049666.7040204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Maxim Krasnyansky <maxk@qualcomm.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:53100 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756680AbYDOLRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:17:22 -0400
In-Reply-To: <48049666.7040204@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the first step in making tuntap devices work in net 
namespaces. The structure mentioned is pointed by generic
net pointer with tun_net_id id, and tun driver fills one on 
its load. It will contain only the tun devices list.

So declare this structure and introduce net init and exit hooks.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/tun.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 52 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5b5d875..f359d60 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -63,6 +63,7 @@
 #include <linux/if_tun.h>
 #include <linux/crc32.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -106,6 +107,11 @@ struct tun_struct {
 
 /* Network device part of the driver */
 
+static unsigned int tun_net_id;
+struct tun_net {
+	struct list_head dev_list;
+};
+
 static LIST_HEAD(tun_dev_list);
 static const struct ethtool_ops tun_ethtool_ops;
 
@@ -909,6 +915,37 @@ static const struct ethtool_ops tun_ethtool_ops = {
 	.set_rx_csum	= tun_set_rx_csum
 };
 
+static int tun_init_net(struct net *net)
+{
+	struct tun_net *tn;
+
+	tn = kmalloc(sizeof(*tn), GFP_KERNEL);
+	if (tn == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&tn->dev_list);
+
+	if (net_assign_generic(net, tun_net_id, tn)) {
+		kfree(tn);
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void tun_exit_net(struct net *net)
+{
+	struct tun_net *tn;
+
+	tn = net_generic(net, tun_net_id);
+	kfree(tn);
+}
+
+static struct pernet_operations tun_net_ops = {
+	.init = tun_init_net,
+	.exit = tun_exit_net,
+};
+
 static int __init tun_init(void)
 {
 	int ret = 0;
@@ -916,9 +953,22 @@ static int __init tun_init(void)
 	printk(KERN_INFO "tun: %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	printk(KERN_INFO "tun: %s\n", DRV_COPYRIGHT);
 
+	ret = register_pernet_gen_device(&tun_net_id, &tun_net_ops);
+	if (ret) {
+		printk(KERN_ERR "tun: Can't register pernet ops\n");
+		goto err_pernet;
+	}
+
 	ret = misc_register(&tun_miscdev);
-	if (ret)
+	if (ret) {
 		printk(KERN_ERR "tun: Can't register misc device %d\n", TUN_MINOR);
+		goto err_misc;
+	}
+	return 0;
+
+err_misc:
+	unregister_pernet_gen_device(tun_net_id, &tun_net_ops);
+err_pernet:
 	return ret;
 }
 
@@ -935,6 +985,7 @@ static void tun_cleanup(void)
 	}
 	rtnl_unlock();
 
+	unregister_pernet_gen_device(tun_net_id, &tun_net_ops);
 }
 
 module_init(tun_init);
-- 
1.5.3.4


