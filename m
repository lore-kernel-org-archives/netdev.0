From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/4] cxgb2: rtnl_lock out of loop will be faster
Date: Wed, 12 Dec 2007 16:46:13 +0800
Message-ID: <475F9FD5.3000208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: maintainers@chelsio.com, netdev@vger.kernel.org,
	Wang Chen <wangchen@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:65337 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753517AbXLLIu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 03:50:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH 1/4] [NETDEV] cxgb2: rtnl_lock out of loop will be faster

Before this patch, it gets and releases the lock at each
iteration of the loop. Changing unregister_netdev to
unregister_netdevice and locking outside of the loop will
be faster for this approach.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 cxgb2.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

--- linux-2.6.24.rc5.org/drivers/net/chelsio/cxgb2.c	2007-12-12 10:19:39.000000000 +0800
+++ linux-2.6.24.rc5/drivers/net/chelsio/cxgb2.c	2007-12-12 16:24:14.000000000 +0800
@@ -46,6 +46,7 @@
 #include <linux/mii.h>
 #include <linux/sockios.h>
 #include <linux/dma-mapping.h>
+#include <linux/rtnetlink.h>
 #include <asm/uaccess.h>
 
 #include "cpl5_cmd.h"
@@ -1387,10 +1388,12 @@ static void __devexit remove_one(struct 
 	struct adapter *adapter = dev->priv;
 	int i;
 
+	rtnl_lock();
 	for_each_port(adapter, i) {
 		if (test_bit(i, &adapter->registered_device_map))
-			unregister_netdev(adapter->port[i].dev);
+			unregister_netdevice(adapter->port[i].dev);
 	}
+	rtnl_unlock();
 
 	t1_free_sw_modules(adapter);
 	iounmap(adapter->regs);

