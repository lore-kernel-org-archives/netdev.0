From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 09:04:55 +0200
Message-ID: <20110728070455.GA11251@electric-eye.fr.zoreil.com>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37631 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782Ab1G1HUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 03:20:52 -0400
Content-Disposition: inline
In-Reply-To: <20110725103643.GA11135@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
[...]
> [    1.045727] pata_sch 0000:00:1f.1: setting latency timer to 64
> [    1.045946] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    1.046061] r8169 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [    1.046201] r8169 0000:02:00.0: setting latency timer to 64
> [    1.046257]   alloc irq_desc for 24 on node -1
> [    1.046263]   alloc kstat_irqs on node -1
> [    1.046284] r8169 0000:02:00.0: irq 24 for MSI/MSI-X
> [    1.048097] eth0: RTL8168c/8111c at 0xf8076000, 00:01:c0:09:a1:25, XID 1c4000c0 IRQ 24

RTL_GIGA_MAC_VER_22

[...]
> [    1.082178] eth1: RTL8168c/8111c at 0xf8096000, 00:01:c0:09:a1:26, XID 1c4000c0 IRQ 25

sic.

I miss it (the light fast crash prone motherboard from hell does not count).

[...]
> It works on 2.6.32.32 it crashes on 2.6.32.33. I tried to
> take 2.6.32.43 and apply 1519e57fe81c14bb8fa4855579f19264d1ef63b4,
> that did not help. 2.6.32.43 crashes with and without that patch.

1519e57fe81c14bb8fa4855579f19264d1ef63b4 does not help RTL_GIGA_MAC_VER_22
proper but you may apply it, then move the 'case RTL_GIGA_MAC_VER_22:'
statement a few line below and see if it helps (assuming the fifo overflow
event may be ignored):

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..33c0ead 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -5383,7 +5383,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			switch (tp->mac_version) {
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
@@ -5393,6 +5392,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			case RTL_GIGA_MAC_VER_19:
 			case RTL_GIGA_MAC_VER_20:
 			case RTL_GIGA_MAC_VER_21:
+			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_23:
 			case RTL_GIGA_MAC_VER_24:
 			case RTL_GIGA_MAC_VER_27:
-- 
Ueimor
