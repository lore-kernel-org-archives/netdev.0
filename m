From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/4] cxgb3: rtnl_lock out of loop will be faster
Date: Wed, 12 Dec 2007 16:47:25 +0800
Message-ID: <475FA01D.4090000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:61662 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755740AbXLLIxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 03:53:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH 2/4] [NETDEV] cxgb3: rtnl_lock out of loop will be faster

Before this patch, it gets and releases the lock at each
iteration of the loop. Changing unregister_netdev to
unregister_netdevice and locking outside of the loop will
be faster for this approach.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 cxgb3_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- linux-2.6.24.rc5.org/drivers/net/cxgb3/cxgb3_main.c	2007-12-12 10:19:39.000000000 +0800
+++ linux-2.6.24.rc5/drivers/net/cxgb3/cxgb3_main.c	2007-12-12 15:19:15.000000000 +0800
@@ -2584,9 +2584,11 @@ static void __devexit remove_one(struct 
 		sysfs_remove_group(&adapter->port[0]->dev.kobj,
 				   &cxgb3_attr_group);
 
+		rtnl_lock();
 		for_each_port(adapter, i)
 		    if (test_bit(i, &adapter->registered_device_map))
-			unregister_netdev(adapter->port[i]);
+			unregister_netdevice(adapter->port[i]);
+		rtnl_unlock();
 
 		if (is_offload(adapter)) {
 			cxgb3_adapter_unofld(adapter);

