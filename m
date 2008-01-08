From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7]: [NET]: Fix drivers to handle napi_disable() disabling
 interrupts.
Date: Mon, 07 Jan 2008 21:40:34 -0800 (PST)
Message-ID: <20080107.214034.227601954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32886
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751157AbYAHFkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:40:35 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id A2B2AC8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:40:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


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
@@ -455,9 +455,14 @@ static void pcnet32_netif_start(struct net_device *dev)
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
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5863190..af80309 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2398,6 +2398,8 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	rtl8169_irq_mask_and_ack(ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
+	tp->intr_mask = 0xffff;
+	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
 #endif
 }
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a74fc11..52ec89b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1168,6 +1168,7 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 			     TX_VLAN_TAG_OFF);
 	}
 
+	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
 	netif_tx_unlock_bh(dev);
 }
@@ -2043,6 +2044,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	err = sky2_rx_start(sky2);
 	sky2_write32(hw, B0_IMSK, imask);
 
+	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
 
 	if (err)
@@ -3861,6 +3863,7 @@ static int sky2_debug_show(struct seq_file *seq, void *v)
 		   last = sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_PUT_IDX)),
 		   sky2_read16(hw, Y2_QADDR(rxqaddr[port], PREF_UNIT_LAST_IDX)));
 
+	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
 	return 0;
 }
-- 
1.5.4.rc2.38.gd6da3

