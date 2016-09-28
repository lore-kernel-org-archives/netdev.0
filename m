From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH v2 net-next 1/2] net: centralize net_device min/max MTU checking
Date: Wed, 28 Sep 2016 18:20:52 -0400
Message-ID: <20160928222053.33697-2-jarod@redhat.com>
References: <20160912201106.47837-1-jarod@redhat.com>
 <20160928222053.33697-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54434 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754061AbcI1WVH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 18:21:07 -0400
In-Reply-To: <20160928222053.33697-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While looking into an MTU issue with sfc, I started noticing that almost
every NIC driver with an ndo_change_mtu function implemented almost
exactly the same range checks, and in many cases, that was the only
practical thing their ndo_change_mtu function was doing. Quite a few
drivers have either 68, 64, 60 or 46 as their minimum MTU value checked,
and then various sizes from 1500 to 65535 for their maximum MTU value. We
can remove a whole lot of redundant code here if we simple store min_mtu
and max_mtu in net_device, and check against those in net/core/dev.c's
dev_set_mtu().

In theory, there should be zero functional change with this patch, it just
puts the infrastructure in place. Subsequent patches will attempt to start
using said infrastructure, with theoretically zero change in
functionality.

CC: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 include/linux/netdevice.h |  4 ++++
 net/core/dev.c            | 12 ++++++++++--
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 136ae6bb..fbdf923 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1506,6 +1506,8 @@ enum netdev_priv_flags {
  *	@if_port:	Selectable AUI, TP, ...
  *	@dma:		DMA channel
  *	@mtu:		Interface MTU value
+ *	@min_mtu:	Interface Minimum MTU value
+ *	@max_mtu:	Interface Maximum MTU value
  *	@type:		Interface hardware type
  *	@hard_header_len: Maximum hardware header length.
  *
@@ -1726,6 +1728,8 @@ struct net_device {
 	unsigned char		dma;
 
 	unsigned int		mtu;
+	unsigned int		min_mtu;
+	unsigned int		max_mtu;
 	unsigned short		type;
 	unsigned short		hard_header_len;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index c0c291f..5343799 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6493,9 +6493,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 	if (new_mtu == dev->mtu)
 		return 0;
 
-	/*	MTU must be positive.	 */
-	if (new_mtu < 0)
+	if (new_mtu < dev->min_mtu) {
+		net_err_ratelimited("%s: Invalid MTU %d requested, hw min %d\n",
+				    dev->name, new_mtu, dev->min_mtu);
 		return -EINVAL;
+	}
+
+	if (dev->max_mtu > 0 && new_mtu > dev->max_mtu) {
+		net_err_ratelimited("%s: Invalid MTU %d requested, hw max %d\n",
+				    dev->name, new_mtu, dev->min_mtu);
+		return -EINVAL;
+	}
 
 	if (!netif_device_present(dev))
 		return -ENODEV;
-- 
2.10.0
