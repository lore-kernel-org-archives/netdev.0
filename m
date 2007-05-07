From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/6] myri10ge: fix restoring of multicast list after reset
Date: Mon, 07 May 2007 23:50:37 +0200
Message-ID: <463F9F2D.7050106@myri.com>
References: <463F9E9E.8000808@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1890 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S966914AbXEGVui (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 17:50:38 -0400
In-Reply-To: <463F9E9E.8000808@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't count on whatever implementation artifact preserves the
multicast list across a reset cmd, and setup multicast filtering
as part of our reset routine.

The setting of allmulti when adopting firmware with the rx-filter
broadcast bug is also moved into the multicast setup routine where
it belongs.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:20:45.000000000 +0200
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2007-05-07 23:21:27.000000000 +0200
@@ -290,6 +290,8 @@
 
 #define myri10ge_pio_copy(to,from,size) __iowrite64_copy(to,from,size/8)
 
+static void myri10ge_set_multicast_list(struct net_device *dev);
+
 static inline void put_be32(__be32 val, __be32 __iomem * p)
 {
 	__raw_writel((__force __u32) val, (__force void __iomem *)p);
@@ -820,10 +822,8 @@
 	mgp->rx_done.cnt = 0;
 	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
-	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
-	if (mgp->adopted_rx_filter_bug)
-		(void)myri10ge_send_cmd(mgp, MXGEFW_ENABLE_ALLMULTI, &cmd, 1);
+	myri10ge_set_multicast_list(mgp->dev);
 	return status;
 }
 
@@ -2283,7 +2283,7 @@
 	myri10ge_change_promisc(mgp, dev->flags & IFF_PROMISC, 1);
 
 	/* This firmware is known to not support multicast */
-	if (!mgp->fw_multicast_support || mgp->adopted_rx_filter_bug)
+	if (!mgp->fw_multicast_support)
 		return;
 
 	/* Disable multicast filtering */
@@ -2295,7 +2295,7 @@
 		goto abort;
 	}
 
-	if (dev->flags & IFF_ALLMULTI) {
+	if ((dev->flags & IFF_ALLMULTI) || mgp->adopted_rx_filter_bug) {
 		/* request to disable multicast filtering, so quit here */
 		return;
 	}


