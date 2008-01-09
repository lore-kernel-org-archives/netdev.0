From: Don Fry <pcnet32@verizon.net>
Subject: Re: [PATCH 5/7]: [NET]: Fix drivers to handle napi_disable()	disabling
 interrupts.
Date: Tue, 08 Jan 2008 22:14:29 -0800
Message-ID: <1199859269.9002.6.camel@Linux.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:61351 "EHLO
	vms048pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbYAIGUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 01:20:08 -0500
Received: from [192.168.1.3] ([96.225.193.28])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JUD000085KW4MZ1@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 09 Jan 2008 00:19:45 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested pcnet32 on x86_64 box and see no problems with the change.
The code is only exercised if doing loopback testing, or changing
the ring size during a receive storm.

Acked-by:  Don Fry <pcnet32@verizon.net>
---

[NET]: Fix drivers to handle napi_disable() disabling interrupts.

When we add the generic napi_disable_pending() breakout
logic to net_rx_action() it means that napi_disable()
can cause NAPI poll interrupt events to be disabled.

And this is exactly what we want.  If a napi_disable()
is pending, and we are looping in the ->poll(), we want
->poll() event interrupts to stay disabled and we want
to complete the NAPI poll ASAP.

When ->poll() break out during device down was being handled on a
per-driver basis, often these drivers would turn interrupts back on
when '!netif_running()' was detected.

And this would just cause a reschedule of the NAPI ->poll() in the
interrupt handler before the napi_disable() could get in there and
grab the NAPI_STATE_SCHED bit.

The vast majority of drivers don't care if napi_disable() might have
the side effect of disabling NAPI ->poll() event interrupts.  In all
such cases, when a napi_disable() is performed, the driver just
disabled interrupts or is about to.

However there were three exceptions to this in PCNET32, R8169, and
SKY2.  To fix those cases, at the subsequent napi_enable() points, I
added code to ensure that the ->poll() interrupt events are enabled in
the hardware.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/pcnet32.c |    5 +++++
 drivers/net/r8169.c   |    2 ++
 drivers/net/sky2.c    |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index ff92aca..90498ff 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -455,9 +455,14 @@ static void pcnet32_netif_start(struct net_device
*dev)
 {
 #ifdef CONFIG_PCNET32_NAPI
 	struct pcnet32_private *lp = netdev_priv(dev);
+	ulong ioaddr = dev->base_addr;
+	u16 val;
 #endif
 	netif_wake_queue(dev);
 #ifdef CONFIG_PCNET32_NAPI
+	val = lp->a.read_csr(ioaddr, CSR3);
+	val &= 0x00ff;
+	lp->a.write_csr(ioaddr, CSR3, val);
 	napi_enable(&lp->napi);
 #endif
 }
-- 
1.5.4.rc2.38.gd6da3

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



