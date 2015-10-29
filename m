From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: smsc911x: Fix crash if loopback test fails
Date: Thu, 29 Oct 2015 09:45:22 +0300
Message-ID: <1446101122-6440-1-git-send-email-p.fedin@samsung.com>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:58554 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbbJ2Gpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 02:45:30 -0400
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NWY0031HYRSQ520@mailout1.w1.samsung.com> for
 netdev@vger.kernel.org; Thu, 29 Oct 2015 06:45:28 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain hardware in certain situations loopback test fails and the
driver gets removed. During mdiobus_unregister() instance of PHY driver
gets disposed. But by this time it has already been started using
phy_connect_direct().

PHY driver uses DELAYED_WORK in order to maintain its state. Attempting
to dispose the driver without calling phy_disconnect() causes deallocation
of DELAYED_WORK being active. This shortly causes a bad crash in timer
code.

The problem can be discovered by enabling CONFIG_DEBUG_OBJECTS_TIMERS and
CONFIG_DEBUG_OBJECTS_FREE

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 715f3ed..55d7a9c 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1052,6 +1052,7 @@ static int smsc911x_mii_probe(struct net_device *dev)
 #ifdef USE_PHY_WORK_AROUND
 	if (smsc911x_phy_loopbacktest(dev) < 0) {
 		SMSC_WARN(pdata, hw, "Failed Loop Back Test");
+		phy_disconnect(phydev);
 		return -ENODEV;
 	}
 	SMSC_TRACE(pdata, hw, "Passed Loop Back Test");
-- 
2.4.4
