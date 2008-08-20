From: akpm@linux-foundation.org
Subject: [patch 12/12] driver/net/skge.c: restart the interface when it's options or pauseparam is set
Date: Wed, 20 Aug 2008 16:52:08 -0700
Message-ID: <200808202352.m7KNq8B1006065@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Xiaoming.Zhang@resilience.com, shemminger@vyatta.com,
	xiaoming.zhang@resilience.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44085 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756219AbYHTXyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 19:54:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Xiaoming.Zhang" <Xiaoming.Zhang@resilience.com>

We have an issue of the skge driver: The card won't work when it's options
are changed.  Here's the hardware info:

# lspci -v
05:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit Ethernet Controller (rev 13)
        Subsystem: Marvell Technology Group Ltd. Marvell RDK-8001
        Flags: bus master, 66MHz, medium devsel, latency 32, IRQ 16
        Memory at d042c000 (32-bit, non-prefetchable) [size=16K]
        I/O ports at d000 [size=256]
        [virtual] Expansion ROM at 20400000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data

The happens in both Linux-2.6.26(skge version 1.23) and RHEL5.2(skge
version 1.6).

For example, at first it is set to "speed 1000 duplex full auto-neg on" and
it works, then run

       ethtool -s <ethx> autoneg off
or     ethtool -s <ethx> speed 100 duplex full autoneg off

Then it will stop working. After that if we restart the interface:

	ifconifg <ethx> down
	ifconfig <ethx> up

It will work again. And `ethtool -A' has the same issue.

So we think after setting the options, the interface should be restarted. 

Signed-off-by: Zhang Xiaoming <xiaoming.zhang@resilience.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/skge.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff -puN drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-options-or-pauseparam-is-set drivers/net/skge.c
--- a/drivers/net/skge.c~driver-net-skgec-restart-the-interface-when-its-options-or-pauseparam-is-set
+++ a/drivers/net/skge.c
@@ -353,8 +353,10 @@ static int skge_set_settings(struct net_
 	skge->autoneg = ecmd->autoneg;
 	skge->advertising = ecmd->advertising;
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		skge_up(dev);
+	}
 
 	return (0);
 }
@@ -595,8 +597,10 @@ static int skge_set_pauseparam(struct ne
 			skge->flow_control = FLOW_MODE_NONE;
 	}
 
-	if (netif_running(dev))
-		skge_phy_reset(skge);
+	if (netif_running(dev)) {
+		skge_down(dev);
+		skge_up(dev);
+	}
 
 	return 0;
 }
_
