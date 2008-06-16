From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: RFC: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Mon, 16 Jun 2008 17:15:49 +0800
Message-ID: <48562F45.3040302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56617 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755605AbYFPJTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:19:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max of promiscuity and allmulti plus positive @inc can cause overflow.
Fox example: when allmulti=0xFFFFFFFF, any caller give dev_set_allmulti() a
positive @inc will cause allmulti be off.
This is not what we want, though it's rare case.
The fix is that only negative @inc will cause allmulti or promiscuity be off
and when any caller will make the counters touch the roof, we report error.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/core/dev.c |   29 +++++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5829630..a3c692d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2753,10 +2753,20 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
 
 	ASSERT_RTNL();
 
+	dev->flags |= IFF_PROMISC;
 	if ((dev->promiscuity += inc) == 0)
-		dev->flags &= ~IFF_PROMISC;
-	else
-		dev->flags |= IFF_PROMISC;
+		/*
+		 * Avoid overflow.
+		 * If inc causes overflow, ignore it and warn user.
+		 */
+		if (inc < 0)
+			dev->flags &= ~IFF_PROMISC;
+		else {
+			dev->promiscuity -= inc;
+			printk(KERN_ERR "%s: promiscuity touches roof, "
+				"set promiscuity failed, promiscuity feature "
+				"of device will be broken.\n");
+		}
 	if (dev->flags != old_flags) {
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
@@ -2815,7 +2825,18 @@ void dev_set_allmulti(struct net_device *dev, int inc)
 
 	dev->flags |= IFF_ALLMULTI;
 	if ((dev->allmulti += inc) == 0)
-		dev->flags &= ~IFF_ALLMULTI;
+		/*
+		 * Avoid overflow.
+		 * If inc causes overflow, ignore it and warn user.
+		 */
+		if (inc < 0)
+			dev->flags &= ~IFF_ALLMULTI;
+		else {
+			dev->allmulti -= inc;
+			printk(KERN_ERR "%s: allmulti touches roof, "
+				"set allmulti failed, allmulti feature of "
+				"device will be broken.\n");
+		}
 	if (dev->flags ^ old_flags) {
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_ALLMULTI);
-- 
1.5.3.4




