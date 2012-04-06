From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 6/6] doc, net: Update ndo_start_xmit return type
 and values
Date: Fri, 6 Apr 2012 01:40:25 +0100
Message-ID: <1333672825.2652.29.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28124 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753052Ab2DFAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:40:28 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit dc1f8bf68b311b1537cb65893430b6796118498a ('netdev: change
transmit to limited range type') changed the required return type and
9a1654ba0b50402a6bd03c7b0fe9b0200a5ea7b1 ('net: Optimize
hard_start_xmit() return checking') changed the valid numerical
return values.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Documentation/networking/driver.txt |   22 ++++++++++++----------
 1 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index 2128e41..da59e28 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -2,16 +2,16 @@ Document about softnet driver issues
 
 Transmit path guidelines:
 
-1) The ndo_start_xmit method must never return '1' under any
-   normal circumstances.  It is considered a hard error unless
+1) The ndo_start_xmit method must not return NETDEV_TX_BUSY under
+   any normal circumstances.  It is considered a hard error unless
    there is no way your device can tell ahead of time when it's
    transmit function will become busy.
 
    Instead it must maintain the queue properly.  For example,
    for a driver implementing scatter-gather this means:
 
-	static int drv_hard_start_xmit(struct sk_buff *skb,
-		   		       struct net_device *dev)
+	static netdev_tx_t drv_hard_start_xmit(struct sk_buff *skb,
+					       struct net_device *dev)
 	{
 		struct drv *dp = netdev_priv(dev);
 
@@ -23,7 +23,7 @@ Transmit path guidelines:
 			unlock_tx(dp);
 			printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 			       dev->name);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 
 		... queue packet to card ...
@@ -35,6 +35,7 @@ Transmit path guidelines:
 		...
 		unlock_tx(dp);
 		...
+		return NETDEV_TX_OK;
 	}
 
    And then at the end of your TX reclamation event handling:
@@ -61,9 +62,9 @@ Transmit path guidelines:
 2) An ndo_start_xmit method must not modify the shared parts of a
    cloned SKB.
 
-3) Do not forget that once you return 0 from your ndo_start_xmit
-   method, it is your driver's responsibility to free up the SKB
-   and in some finite amount of time.
+3) Do not forget that once you return NETDEV_TX_OK from your
+   ndo_start_xmit method, it is your driver's responsibility to free
+   up the SKB and in some finite amount of time.
 
    For example, this means that it is not allowed for your TX
    mitigation scheme to let TX packets "hang out" in the TX
@@ -71,8 +72,9 @@ Transmit path guidelines:
    This error can deadlock sockets waiting for send buffer room
    to be freed up.
 
-   If you return 1 from the ndo_start_xmit method, you must not keep
-   any reference to that SKB and you must not attempt to free it up.
+   If you return NETDEV_TX_BUSY from the ndo_start_xmit method, you
+   must not keep any reference to that SKB and you must not attempt
+   to free it up.
 
 Probing guidelines:
 
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
