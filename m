From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [PATCH] r8169: add phy_reset parameter
Date: Mon, 22 Jun 2009 18:13:18 +0100
Message-ID: <4A3FBBAE.6010005@simon.arlott.org.uk>
References: <4A3E7FC5.6060400@simon.arlott.org.uk> <20090621.142930.251405926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:48746 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752744AbZFVRNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 13:13:17 -0400
In-Reply-To: <20090621.142930.251405926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/09 22:29, David Miller wrote:
> From: Simon Arlott <simon@fire.lp0.eu>
> Date: Sun, 21 Jun 2009 19:45:25 +0100
> 
>> When booting over the network the physical link will already be up
>> and configured appropriately, so there is no need to reset it and
>> cause auto-negotiation to occur again. Adding an option to disable
>> this makes it possible to avoid a 2 second delay while booting.
>> 
>> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
> 
> This is getting out of control.

I'll look into getting ipconfig to detect link up notifications so its
sleep()s can then just be removed...

> We're not going to add a hundred different obscure module options to
> eliminate delays and device resets.

What about detecting link up before calling rtl8169_phy_reset instead?

I've tried not resetting the PHY but still setting the speed to auto
1000-FD, however this still resets the link.

The downside is that the speed won't be reset if the link is up while
booting. This may actually be desirable but it's not the current
behaviour. It could be possible to check if the speed is already set
to auto 1000-FD, although as the comment setting it indicates, the
8101 is a special case.

On my system the PHY/link speed is also getting reset by the boot ROM,
so I can't check that any change would be persisted.

This works ok for me:
[    0.469009] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.469134]   alloc irq_desc for 18 on node -1
[    0.469143]   alloc kstat_irqs on node -1
[    0.469164] r8169 0000:00:09.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[    0.469315] r8169 0000:00:09.0: no PCI Express capability
[    0.470354] eth0: RTL8169sc/8110sc at 0xbf700000, 00:30:18:b0:25:c2, XID 18000000 IRQ 18
[    0.470498] r8169: eth0: PHY reset skipped (link up)
[    0.470606] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    0.470719]   alloc irq_desc for 19 on node -1
[    0.470728]   alloc kstat_irqs on node -1
[    0.470742] r8169 0000:00:0b.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[    0.470875] r8169 0000:00:0b.0: no PCI Express capability
[    0.471870] eth1: RTL8169sc/8110sc at 0xbf704000, 00:30:18:b0:25:c3, XID 18000000 IRQ 19
(eth1 has no link)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4e22462..ae3e174 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1798,13 +1798,18 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	rtl8169_phy_reset(dev, tp);
+	/* Reset PHY/speed only if the link is not already up. */
+	if (tp->link_ok(ioaddr)) {
+		printk(KERN_INFO PFX "%s: PHY reset skipped (link up)\n", dev->name);
+	} else {
+		rtl8169_phy_reset(dev, tp);
 
-	/*
-	 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
-	 * only 8101. Don't panic.
-	 */
-	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+		/*
+		 * rtl8169_set_speed_xmii takes good care of the Fast Ethernet
+		 * only 8101. Don't panic.
+		 */
+		rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL);
+	}
 
 	if ((RTL_R8(PHYstatus) & TBI_Enable) && netif_msg_link(tp))
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);

-- 
Simon Arlott
