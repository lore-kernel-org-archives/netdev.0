From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 3/4] ixp2000: rtnl_lock out of loop will be faster
Date: Wed, 12 Dec 2007 16:48:28 +0800
Message-ID: <475FA05C.1060705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org,
	Wang Chen <wangchen@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:53563 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756173AbXLLIwf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 03:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH 3/4] [NETDEV] ixp2000: rtnl_lock out of loop will be faster

Before this patch, it gets and releases the lock at each
iteration of the loop. Changing unregister_netdev to
unregister_netdevice and locking outside of the loop will
be faster for this approach.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 ixpdev.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff -Nurp linux-2.6.24.rc5.org/drivers/net/ixp2000/ixpdev.c linux-2.6.24.rc5/drivers/net/ixp2000/ixpdev.c
--- linux-2.6.24.rc5.org/drivers/net/ixp2000/ixpdev.c	2007-12-12 10:19:41.000000000 +0800
+++ linux-2.6.24.rc5/drivers/net/ixp2000/ixpdev.c	2007-12-12 16:25:44.000000000 +0800
@@ -15,6 +15,7 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/moduleparam.h>
+#include <linux/rtnetlink.h>
 #include <asm/hardware/uengine.h>
 #include <asm/mach-types.h>
 #include <asm/io.h>
@@ -375,14 +376,16 @@ int ixpdev_init(int __nds_count, struct 
 	ixp2000_uengine_load(1, &ixp2400_tx);
 	ixp2000_uengine_start_contexts(1, 0xff);
 
+	rtnl_lock();
 	for (i = 0; i < nds_count; i++) {
-		err = register_netdev(nds[i]);
+		err = register_netdevice(nds[i]);
 		if (err) {
 			while (--i >= 0)
-				unregister_netdev(nds[i]);
+				unregister_netdevice(nds[i]);
 			goto err_free_tx;
 		}
 	}
+	rtnl_unlock();
 
 	for (i = 0; i < nds_count; i++) {
 		printk(KERN_INFO "%s: IXP2000 MSF ethernet (port %d), "
@@ -395,6 +398,7 @@ int ixpdev_init(int __nds_count, struct 
 	return 0;
 
 err_free_tx:
+	rtnl_unlock();
 	for (i = 0; i < TX_BUF_COUNT; i++)
 		free_page((unsigned long)phys_to_virt(tx_desc[i].buf_addr));
 
@@ -412,8 +416,10 @@ void ixpdev_deinit(void)
 
 	/* @@@ Flush out pending packets.  */
 
+	rtnl_lock();
 	for (i = 0; i < nds_count; i++)
-		unregister_netdev(nds[i]);
+		unregister_netdevice(nds[i]);
+	rtnl_unlock();
 
 	ixp2000_uengine_stop_contexts(1, 0xff);
 	ixp2000_uengine_stop_contexts(0, 0xff);

