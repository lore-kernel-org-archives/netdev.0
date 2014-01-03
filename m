From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH v2] infiniband: make sure the src net is infiniband when create new link
Date: Fri,  3 Jan 2014 11:33:45 +0800
Message-ID: <1388720025-26472-1-git-send-email-liuhangbin@gmail.com>
Cc: network dev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Weiping Pan <wpan@redhat.com>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:58398 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbaACDeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:34:01 -0500
Received: by mail-pb0-f48.google.com with SMTP id md12so15202895pbc.35
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 19:34:00 -0800 (PST)
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
 drivers/infiniband/ulp/ipoib/ipoib_netlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
index c29b5c8..cdc7df4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_netlink.c
@@ -31,6 +31,7 @@
  */
 
 #include <linux/netdevice.h>
+#include <linux/if_arp.h>      /* For ARPHRD_xxx */
 #include <linux/module.h>
 #include <net/rtnetlink.h>
 #include "ipoib.h"
@@ -103,7 +104,7 @@ static int ipoib_new_child_link(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 
 	pdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
-	if (!pdev)
+	if (!pdev || pdev->type != ARPHRD_INFINIBAND)
 		return -ENODEV;
 
 	ppriv = netdev_priv(pdev);
-- 
1.8.1.4
