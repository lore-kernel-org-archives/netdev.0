From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] infiniband: make sure the src net is infiniband when create new link
Date: Thu,  2 Jan 2014 17:37:38 +0800
Message-ID: <1388655458-25269-1-git-send-email-liuhangbin@gmail.com>
Cc: David Miller <davem@davemloft.net>, Weiping Pan <wpan@redhat.com>,
	Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:54311 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbaABJiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 04:38:19 -0500
Received: by mail-pa0-f49.google.com with SMTP id kx10so14309130pab.22
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 01:38:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we create a new infiniband link with uninfiniband device, e.g. `ip link
add link em1 type ipoib pkey 0x8001`. We will get a NULL pointer dereference
cause other dev like Ethernet don't have struct ib_device.

The code path is:
rtnl_newlink
  |-- ipoib_new_child_link
        |-- __ipoib_vlan_add
              |-- ipoib_set_dev_features
	            |-- ib_query_device

Fix this bug by make sure the src net is infiniband when create new link.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index c29b5c8..de340c9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -31,6 +31,7 @@
  */
 
 #include <linux/netdevice.h>
+#include <linux/if_arp.h>	/* For ARPHRD_xxx */
 #include <linux/module.h>
 #include <net/rtnetlink.h>
 #include "ipoib.h"
@@ -105,6 +106,8 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 	pdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
 	if (!pdev)
 		return -ENODEV;
+	if (pdev->type != ARPHRD_INFINIBAND)
+		return -ENODEV;
 
 	ppriv = netdev_priv(pdev);
 
-- 
1.8.1.4
