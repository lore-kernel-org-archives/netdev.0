From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/7]: [NET]: Do not grab device reference when scheduling a
 NAPI poll.
Date: Mon, 07 Jan 2008 21:38:14 -0800 (PST)
Message-ID: <20080107.213814.196185913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750962AbYAHFiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:38:15 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BDEC6C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:38:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET]: Do not grab device reference when scheduling a NAPI poll.

It is pointless, because everything that can make a device go away
will do a napi_disable() first.

The main impetus behind this is that now we can legally do a NAPI
completion in generic code like net_rx_action() which a following
changeset needs to do.  net_rx_action() can only perform actions
in NAPI centric ways, because there may be a one to many mapping
between NAPI contexts and network devices (SKY2 is one example).

We also want to get rid of this because it's an extra atomic in the
NAPI paths, and also because it is one of the last instances where the
NAPI interfaces care about net devices.

The one remaining netdev detail the NAPI stuff cares about is the
netif_running() check which will be killed off in a subsequent
changeset.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1e6af4f..e393995 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1277,7 +1277,6 @@ static inline int netif_rx_schedule_prep(struct net_device *dev,
 static inline void __netif_rx_schedule(struct net_device *dev,
 				       struct napi_struct *napi)
 {
-	dev_hold(dev);
 	__napi_schedule(napi);
 }
 
@@ -1308,7 +1307,6 @@ static inline void __netif_rx_complete(struct net_device *dev,
 				       struct napi_struct *napi)
 {
 	__napi_complete(napi);
-	dev_put(dev);
 }
 
 /* Remove interface from poll list: it must be in the poll list
-- 
1.5.4.rc2.38.gd6da3

